@RestResource(urlMapping='/OneAgency/v1/leadOrPurchase')
global without sharing class OneAgencyLeadPurchaseService {
    
    private static final String SUCCESS = 'Success';
    private static final String ERROR = 'Error';
    
    // ==============================================================
    //  MAIN ENTRY POINT
    // ==============================================================
    @HttpPost
    global static ResponseWrapper processRequest() {
        
        ResponseWrapper response = new ResponseWrapper();
        response.Message = SUCCESS;
        response.errorMessage = '';
        response.Success = false;
        
        RestRequest req = RestContext.request;
        System.debug('[OneAgency] RAW REQUEST: ' + req.requestBody.toString());
        
        try {
            
            // ------------------------------------------------------------
            // Dynamic JSON Parsing
            // ------------------------------------------------------------
            Map<String,Object> receivedData = 
                (Map<String,Object>) JSON.deserializeUntyped(req.requestBody.toString());
            
            if (receivedData == null || receivedData.isEmpty()) {
                throw new MyException('Empty JSON payload received.');
            }
            
            System.debug('[OneAgency] Parsed Data = ' + receivedData);
            
            // ------------------------------------------------------------
            // Detect if it's a lead or purchase
            // ------------------------------------------------------------
            Map<String,Object> billingInfo = getMap(receivedData, 'BillingInfo');
            String orderNumber = getString(receivedData, 'OrderNumber');
            
            Boolean isPurchase = 
                (billingInfo != null && orderNumber != null && orderNumber != '');
            
            if (isPurchase) {
                System.debug('[OneAgency] TYPE DETECTED = PURCHASE');
                handlePurchase(receivedData, response);
            } else {
                System.debug('[OneAgency] TYPE DETECTED = LEAD (HALO-OPTIN)');
                handleLead(receivedData, response);
            }
            
            if (response.Message == SUCCESS) {
                response.Success = true;
            }
            
        } catch (Exception ex) {
            logError('OneAgencyLeadPurchaseService', ex, req.requestBody.toString());
            response.Message = ERROR;
            response.errorMessage = ex.getMessage();
            response.Success = false;
        }
        
        return response;
    }
    
    
    // ==============================================================
    //  LEAD HANDLER
    // ==============================================================
    private static void handleLead(Map<String,Object> payload, ResponseWrapper response) {
        try {
            System.debug('[OneAgency] Creating Lead (HALO-OPTIN)...');
            
            // ------------------------------------------------------------
            // Extract all relevant fields from the payload
            // ------------------------------------------------------------
            String firstName      = getString(payload, 'FirstName');
            String lastName       = getString(payload, 'LastName');
            String email          = getString(payload, 'Email');
            String phone          = getString(payload, 'Phone');
            String marketingCons  = getString(payload, 'MarketingConsent');
            String oneLeadId      = getString(payload, 'ONELeadId');
            String leadSource     = getString(payload, 'LeadSource');
            String adults         = getString(payload, 'Adults');
            String children       = getString(payload, 'Children');
            String checkIn        = getString(payload, 'CheckIn');
            String checkOut       = getString(payload, 'CheckOut');
            
            Map<String,Object> visitorSession = getMap(payload, 'VisitorSession');
            Map<String,Object> offerDetails   = getMap(payload, 'OfferDetails');
            
            // ------------------------------------------------------------
            // Extract nested VISITOR SESSION fields
            // ------------------------------------------------------------
            String gclid           = visitorSession != null ? getString(visitorSession, 'GCLID')             : '';
            String fbclid          = visitorSession != null ? getString(visitorSession, 'FBCLID')            : '';
            String utmSource       = visitorSession != null ? getString(visitorSession, 'UTMSource')         : '';
            String utmTerm         = visitorSession != null ? getString(visitorSession, 'UTMTerm')           : '';
            String adsetId         = visitorSession != null ? getString(visitorSession, 'AdsetId')           : '';
            String adId            = visitorSession != null ? getString(visitorSession, 'AdId')              : '';
            String oneDotSessionId = visitorSession != null ? getString(visitorSession, 'ONEDotSessionId')   : '';
            
            // ------------------------------------------------------------
            // Extract nested OFFER DETAILS fields
            // ------------------------------------------------------------
            String offerDestination = offerDetails != null ? getString(offerDetails, 'OfferDestination') : '';
            String offerPrice       = offerDetails != null ? getString(offerDetails, 'OfferPrice')       : '';
            String offerIncludes    = offerDetails != null ? getString(offerDetails, 'OfferIncludes')    : '';
            
            // ------------------------------------------------------------
            // Create Lead
            // ------------------------------------------------------------
            Lead newLead = new Lead();
            
            // REQUIRED Main Fields
            newLead.FirstName        = firstName;
            newLead.LastName         = lastName;
            newLead.Email            = email;
            newLead.Phone            = phone;
            newLead.LeadSource       = leadSource;
            
            // BOOLEAN marketing consent
            newLead.Marketing_Consent__c = (marketingCons != null && marketingCons.toLowerCase() == 'true');
            
            // Identifiers
            newLead.ONE_Lead_Id__c   = oneLeadId;
            
            // Visitor Session
            newLead.GCLID__c            = gclid;
            newLead.FBCLID__c           = fbclid;
            newLead.UTM_Source__c       = utmSource;
            newLead.UTM_Term__c         = utmTerm;
            newLead.Adset_Id__c         = adsetId;
            newLead.Ad_Id__c            = adId;
            newLead.ONE_Dot_Session_Id__c = oneDotSessionId;
            
            // Offer Details
            newLead.Destination__c   = offerDestination;
            
            // Extract
            Decimal offerPriceDec = offerDetails != null ? getDecimal(offerDetails, 'OfferPrice') : null;
            
            // Set on Lead
            newLead.Product_Price__c = offerPriceDec;
            
            newLead.MKT_Offer__c     = offerIncludes;
            
            // Guest Counts
            newLead.Adults__c   = adults;
            newLead.Children__c = children;
            
            // Dates (CheckIn/CheckOut)
            newLead.Check_in__c  = (checkIn != null && checkIn != '')  ? Date.valueOf(checkIn)  : null;
            newLead.Check_out__c = (checkOut != null && checkOut != '') ? Date.valueOf(checkOut) : null;
            
            Id Carefree_Destinations_Id = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Carefree_Destinations').getRecordTypeId();         
            newLead.RecordTypeId = Carefree_Destinations_Id;
            newLead.Company = 'CFD';
            // ------------------------------------------------------------
            // INSERT Lead
            // ------------------------------------------------------------
            insert newLead;
            
            response.LeadId = newLead.Id;
            response.Message = SUCCESS;
            
            System.debug('[OneAgency] LEAD CREATED: ' + newLead.Id);
            
        } catch (Exception ex) {
            response.Message = ERROR;
            response.errorMessage = ex.getMessage();
            logError('OneAgencyLeadPurchaseService.handleLead', ex, payload);
        }
    }
    
    
    
    // ==============================================================
    //  PURCHASE HANDLER  (LEAD → ACCOUNT, CONTACT, OPP, OLI, PAYMENT)
    // ==============================================================
    private static void handlePurchase(Map<String,Object> payload, ResponseWrapper response) {
        Savepoint sp = Database.setSavepoint();
        
        try {
            System.debug('[OneAgency] Creating PURCHASE objects...');
            
            // ---------------------------
            // Extract top-level fields
            // ---------------------------
            String firstName     = getString(payload, 'FirstName');
            String lastName      = getString(payload, 'LastName');
            String email         = getString(payload, 'Email');
            String phone         = getString(payload, 'Phone');
            String marketingCons = getString(payload, 'MarketingConsent');
            String oneLeadId     = getString(payload, 'ONELeadId');
            String leadSource    = getString(payload, 'LeadSource');
            String adults        = getString(payload, 'Adults');
            String children      = getString(payload, 'Children');
            String checkInStr    = getString(payload, 'CheckIn');
            String checkOutStr   = getString(payload, 'CheckOut');
            String orderNumber   = getString(payload, 'OrderNumber');
            
            Map<String,Object> visitorSession = getMap(payload, 'VisitorSession');
            Map<String,Object> offerDetails   = getMap(payload, 'OfferDetails');
            Map<String,Object> billingInfo    = getMap(payload, 'BillingInfo');
            List<Object>       purchasedItems = getList(payload, 'PurchasedItems');
            
            // ---------------------------
            // VisitorSession fields → Account
            // ---------------------------
            String gclid           = visitorSession != null ? getString(visitorSession, 'GCLID')           : '';
            String fbclid          = visitorSession != null ? getString(visitorSession, 'FBCLID')          : '';
            String utmSource       = visitorSession != null ? getString(visitorSession, 'UTMSource')       : '';
            String utmTerm         = visitorSession != null ? getString(visitorSession, 'UTMTerm')         : '';
            String adsetId         = visitorSession != null ? getString(visitorSession, 'AdsetId')         : '';
            String adId            = visitorSession != null ? getString(visitorSession, 'AdId')            : '';
            String oneDotSessionId = visitorSession != null ? getString(visitorSession, 'ONEDotSessionId') : '';
            
            // ---------------------------
            // OfferDetails → Opportunity
            // ---------------------------
            String  offerDestination = offerDetails != null ? getString(offerDetails, 'OfferDestination') : '';
            Decimal offerPrice       = offerDetails != null ? getDecimal(offerDetails, 'OfferPrice')      : null;
            String  offerIncludes    = offerDetails != null ? getString(offerDetails, 'OfferIncludes')    : '';
            
            // ---------------------------
            // BillingInfo → Account + Payment
            // ---------------------------
            String cardholderName   = billingInfo != null ? getString(billingInfo, 'CardholderName')     : '';
            String billStreet       = billingInfo != null ? getString(billingInfo, 'Address')             : '';
            String billCity         = billingInfo != null ? getString(billingInfo, 'City')               : '';
            String billState        = billingInfo != null ? getString(billingInfo, 'State')              : '';
            String billZip          = billingInfo != null ? getString(billingInfo, 'Zip')                : '';
            String billCountry      = billingInfo != null ? getString(billingInfo, 'Country')            : '';
            String ccType           = billingInfo != null ? getString(billingInfo, 'CreditCardType')     : '';
            String ccLast4          = billingInfo != null ? getString(billingInfo, 'CreditCardLast4')    : '';
            Decimal totalAmount     = billingInfo != null ? getDecimal(billingInfo, 'TotalAmount')       : null;
            String transactionId    = billingInfo != null ? getString(billingInfo, 'TransactionId')      : '';
            String authorizationCode= billingInfo != null ? getString(billingInfo, 'AuthorizationCode')  : '';
            
            // -------------------------------------------------
            // 1) Create ACCOUNT
            // -------------------------------------------------
            Boolean marketingConsentBool = (marketingCons != null && marketingCons.toLowerCase() == 'true');
            // Assuming *opt-out* means the inverse of consent:
            Boolean emailOptOut = !marketingConsentBool;
            
            Account acc = new Account();
            acc.First_Name__c         = firstName;
            acc.Last_Name__c          = lastName;
            acc.Email__c              = email;
            acc.Phone                 = phone;
            acc.Marketing_Email_opt_out__c = emailOptOut;
            acc.ONE_Lead_Id__c        = oneLeadId;
            acc.AccountSource         = leadSource;
            
            // Visitor session fields
            acc.GCLID__c              = gclid;
            acc.FBCLID__c             = fbclid;
            acc.UTM_Source__c         = utmSource;
            acc.UTM_Term__c           = utmTerm;
            acc.Adset_Id__c           = adsetId;
            acc.Ad_Id__c              = adId;
            acc.ONE_Dot_Session_Id__c = oneDotSessionId;
            
            // Billing address
            acc.BillingStreet         = billStreet;
            acc.BillingCity           = billCity;
            acc.BillingState          = billState;
            acc.BillingPostalCode     = billZip;
            acc.BillingCountry        = billCountry;
            
            // Static fields
            acc.Affiliated_Id__c      = 1002256;
            acc.Preferred_Language__c = 'ENG';
            
            insert acc;
            
            // -------------------------------------------------
            // 2) Create CONTACT
            // -------------------------------------------------
            Contact con = new Contact();
            con.AccountId                    = acc.Id;
            con.FirstName                    = firstName;
            con.LastName                     = lastName;
            con.Email                        = email;
            con.Phone                        = phone;
            con.Marketing_Email_opt_out__c   = emailOptOut;
            con.LeadSource                   = leadSource;
            insert con;
            
            // -------------------------------------------------
            // 3) Create OPPORTUNITY
            // -------------------------------------------------
            Opportunity opp = new Opportunity();
            opp.AccountId          = acc.Id;
            opp.Name               = (String.isNotBlank(acc.First_Name__c) || String.isNotBlank(acc.Last_Name__c))
                ? (String.valueOf(acc.First_Name__c) + ' ' + String.valueOf(acc.Last_Name__c)).trim()
                : 'OneAgency Voucher ' + System.today();
            opp.StageName          = 'New';
            opp.CloseDate          = System.today();
            opp.RecordTypeId       = Schema.SObjectType.Opportunity
                .getRecordTypeInfosByDeveloperName()
                .get('Voucher')
                .getRecordTypeId();
            
            // Mapping fields
            opp.LeadSource         = leadSource;
            opp.Destination__c     = offerDestination;
            opp.Offer_Price__c     = offerPrice;
            opp.Offer_Includes__c  = offerIncludes;
            opp.Adults__c          = adults;
            opp.Children_0_17__c   = children;
            opp.Order_Number__c    = orderNumber;
            
            if (String.isNotBlank(checkInStr)) {
                opp.Check_in__c = Date.valueOf(checkInStr);
            }
            if (String.isNotBlank(checkOutStr)) {
                opp.Check_Out__c = Date.valueOf(checkOutStr);
            }
            
            insert opp;
            
            // -------------------------------------------------
            // 4) Create OPPORTUNITY LINE ITEMS
            // -------------------------------------------------
            // Collect product names needed for PricebookEntry lookup
            Set<String> productNames = new Set<String>();
            for (Object itemObj : purchasedItems) {
                Map<String,Object> itemMap = (Map<String,Object>) itemObj;
                String label = getString(itemMap, 'label');
                String productName = mapLabelToProductName(label);
                if (String.isNotBlank(productName)) {
                    productNames.add(productName);
                }
            }
            
            if (!productNames.isEmpty()) {
                // Query PBEs from Standard Price Book (or main active PB)
                List<PricebookEntry> pbeList = [
                    SELECT Id, Product2Id, Product2.Name, Pricebook2Id
                    FROM PricebookEntry
                    WHERE IsActive = true
                    AND Product2.Name IN :productNames
                    AND Pricebook2.IsActive = true
                ];
                
                Map<String, PricebookEntry> nameToPbe = new Map<String, PricebookEntry>();
                for (PricebookEntry pbe : pbeList) {
                    nameToPbe.put(pbe.Product2.Name, pbe);
                }
                
                List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
                OpportunityLineItem primaryOli; // for Payment link (base-package if possible)
                
                for (Object itemObj : purchasedItems) {
                    Map<String,Object> itemMap = (Map<String,Object>) itemObj;
                    
                    String slug      = getString(itemMap, 'slug');
                    String label     = getString(itemMap, 'label');
                    String productName = mapLabelToProductName(label);
                    if (String.isBlank(productName)) {
                        continue; // nothing to map
                    }
                    
                    PricebookEntry pbe = nameToPbe.get(productName);
                    if (pbe == null) {
                        // If any product is missing, rollback entire transaction (Option A)
                        throw new MyException('No active PricebookEntry found for product name: ' + productName);
                    }
                    
                    Decimal value    = getDecimal(itemMap, 'value');
                    // quantity might come as Integer/Decimal; we'll parse via string
                    Decimal qtyDec   = getDecimal(itemMap, 'quantity');
                    if (qtyDec == null) qtyDec = 1;
                    
                    OpportunityLineItem oli = new OpportunityLineItem();
                    oli.OpportunityId   = opp.Id;
                    oli.PricebookEntryId= pbe.Id;
                    oli.Quantity        = qtyDec;
                    oli.TotalPrice      = value;
                    
                    oliList.add(oli);
                    
                    if (primaryOli == null && slug == 'base-package') {
                        primaryOli = oli;
                    }
                }
                
                if (!oliList.isEmpty()) {
                    insert oliList;
                    if (primaryOli == null) {
                        primaryOli = oliList[0];
                    }
                    
                    // -------------------------------------------------
                    // 5) Create PAYMENT
                    // -------------------------------------------------
                    Payment__c pm = new Payment__c();
                    pm.RecordTypeId        = Schema.SObjectType.Payment__c
                        .getRecordTypeInfosByName()
                        .get('Voucher')
                        .getRecordTypeId();
                    // Name = "<FirstName> <LastName> - yyyy-MM-dd"
                    String nmFirst = acc.First_Name__c != null ? acc.First_Name__c : firstName;
                    String nmLast  = acc.Last_Name__c  != null ? acc.Last_Name__c  : lastName;
                    pm.Name                  = (nmFirst + ' ' + nmLast + ' - ' + String.valueOf(System.today())).trim();
                    
                    pm.Opportunity__c        = opp.Id;
                    pm.Paid_On__c            = System.today();
                    pm.Payment_Type__c       = 'Payment';
                    pm.Transaction_Type__c   = 'Payment';
                    
                    pm.CC_Holder_Name__c     = cardholderName;
                    pm.Credit_Card_Type__c   = ccType;
                    pm.Credit_Card_Last_4_Digits__c = ccLast4;
                    pm.Payment_Amount__c     = totalAmount;
                    pm.Transaction_Id__c     = transactionId;
                    pm.Authorization_Code__c = authorizationCode;
                    
                    // Link to primary Opp Line Item
                    pm.Opportunity_Product__c = primaryOli.Id;
                    pm.Product_Id__c          = primaryOli.Product_Id__c; // auto-number on OLI
                    
                    insert pm;
                    
                    response.PaymentId     = pm.Id;
                }
            }
            
            // -------------------------------------------------
            // Set response ids
            // -------------------------------------------------
            response.AccountId    = acc.Id;
            response.ContactId    = con.Id;
            response.OpportunityId= opp.Id;
            response.Message      = SUCCESS;
            
            System.debug('[OneAgency] PURCHASE CREATED - Acc: ' + acc.Id + ', Opp: ' + opp.Id);
            
        } catch (Exception ex) {
            Database.rollback(sp);
            response.Message = ERROR;
            response.errorMessage = ex.getMessage();
            logError('OneAgencyLeadPurchaseService.handlePurchase', ex, payload);
        }
    }
    
    // Map UI labels from JSON to actual Product2.Name used in PricebookEntry
    private static String mapLabelToProductName(String label) {
        if (String.isBlank(label)) return null;
        
        // Normalize just in case
        String l = label.trim();
        
        if (l == 'Package Price') {
            return 'Base Package';
        } else if (l == 'Booking Fee') {
            return 'Booking Fee';
        } else if (l == 'SeaWorld® Orlando (One Day Admission)') {
            return 'Sea World Tickets';
        } else if (l == 'LEGOLAND® (One Day Admission)') {
            return 'Legoland Tickets';
        } else if (l == 'Travel Protection Insurance') {
            return 'Trip Protection Insurance';
        }
        
        // Default: try using label as-is (fallback)
        return l;
    }
    
    
    // ==============================================================
    //  SAFE JSON EXTRACTION HELPERS
    // ==============================================================
    
    private static String getString(Map<String,Object> data, String key) {
        return (data != null && data.containsKey(key) && data.get(key) != null)
            ? String.valueOf(data.get(key))
            : '';
    }
    
    private static Decimal getDecimal(Map<String,Object> data, String key) {
        try {
            return (data != null && data.containsKey(key) && data.get(key) != null)
                ? Decimal.valueOf(String.valueOf(data.get(key)))
                : null;
        } catch (Exception e) { return null; }
    }
    
    private static Boolean getBoolean(Map<String,Object> data, String key) {
        try {
            return (data != null && data.containsKey(key) && data.get(key) != null)
                ? Boolean.valueOf(String.valueOf(data.get(key)))
                : null;
        } catch (Exception e) { return null; }
    }
    
    private static Map<String,Object> getMap(Map<String,Object> data, String key) {
        return (data != null && data.containsKey(key) && data.get(key) instanceof Map<String,Object>)
            ? (Map<String,Object>) data.get(key)
            : null;
    }
    
    private static List<Object> getList(Map<String,Object> data, String key) {
        return (data != null && data.containsKey(key) && data.get(key) instanceof List<Object>)
            ? (List<Object>) data.get(key)
            : new List<Object>();
    }
    
    
    // ==============================================================
    //  ERROR LOGGING + EMAIL ALERTS
    // ==============================================================
    private static void logError(String context, Exception ex, Object dataToLog) {
        
        System.debug('[ERROR] ' + context 
                     + ' - Line: ' + ex.getLineNumber() 
                     + ' - Message: ' + ex.getMessage());
        
        // Save to Error Handler
        try {
            Error_Handler__c err = new Error_Handler__c();
            err.Name = 'OneAgency Webservice Error';
            err.Error_Message__c = 'Context: ' + context +
                ' | Line: ' + ex.getLineNumber() +
                ' | Message: ' + ex.getMessage() +
                ' | Payload: ' + String.valueOf(dataToLog);
            insert err;
        } catch (Exception e2) {}
        
        // Email Alert
        try {
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new String[] {
                'victor.goncalves@nerdsoft.com'
                    });
            email.setSubject('OneAgency API – Error Processing Request');
            email.setPlainTextBody(
                'Context: ' + context + '\n' +
                'Exception: ' + ex.getMessage() + '\n' +
                'Line: ' + ex.getLineNumber() + '\n' +
                'Payload:\n' + dataToLog
            );
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
        } catch (Exception e3) {}
    }
    
    
    // ==============================================================
    //  RESPONSE WRAPPER
    // ==============================================================
    global class ResponseWrapper {
        webservice String Message;
        webservice Boolean Success;
        webservice String errorMessage;
        webservice Id LeadId;
        webservice Id AccountId;
        webservice Id ContactId;
        webservice Id OpportunityId;
        webservice Id PaymentId;
    }
    
    public class MyException extends Exception {}
}