@RestResource(urlMapping='/insertpayment/*')
Global class InsertPaymentService {
    private static final String SUCCESS = 'Success';
    private static final String ERROR = 'Error';
    private static String TEMPLATE = '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd"><html lang="en"><head><meta http-equiv="content-type" content="text/html; charset=utf-8"><title>WWPT Contract</title></head><body><TABLE width="100%"><tr><td align="left"><img src="https://checkout.worldwidepropertytransfers.com/Content/Images/wwpt-logo.png" alt="WWPT Logo" height="100"></td><td align="right"></td></tr></TABLE><br><div style="margin:20px;">Dear [FIRSTLASTNAME], <br><br><br>The documents for your transaction have been electronic signed, the attached document contains your copy.<br><br><br>Best Regards,<br><br><br>Wordwide Property Transfer Contracts Team</div></body></html>'; 
    private static string NOTEBODY = 'Dear [FIRSTLASTNAME],\n\n\n The documents for your transaction have been electronic signed, the attached document contains your copy.\n\n\nBest Regards,\n\n\nWordwide Property Transfer Contracts Team';
    
    private static string NOTEBODYMTRC = 'Dear [FIRSTLASTNAME],\n\n\n The documents for your transaction have been electronic signed, the attached document contains your copy.\n\n\nBest Regards,\n\n\n Contracts Team';
    private static String TEMPLATEInternalHC = '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd"><html lang="en"><head><meta http-equiv="content-type" content="text/html; charset=utf-8"><title>WWPT Contract</title></head><body><TABLE width="100%"><tr><td align="left"><img src="https://marketingresourceshsi.s3.amazonaws.com/logos/Logo-HC-Brand.png" alt="HSI Logo" height="110"></td><td align="right"></td></tr></TABLE><br><div style="margin:20px;">Dear [FIRSTLASTNAME], <br><br><br>The documents for your transaction have been electronic signed, the attached document contains your copy.<br><br><br>Best Regards,<br><br><br> Contracts Team</div></body></html>'; 
    private static String TEMPLATEInternalMTRC = '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd"><html lang="en"><head><meta http-equiv="content-type" content="text/html; charset=utf-8"><title>WWPT Contract</title></head><body><TABLE width="100%"><tr><td align="left"><img src="https://marketingresourceshsi.s3.amazonaws.com/logos/Logo-MTRC-Brand.png" alt="MTRC Logo" height="110"></td><td align="right"></td></tr></TABLE><br><div style="margin:20px;">Dear [FIRSTLASTNAME], <br><br><br>The documents for your transaction have been electronic signed, the attached document contains your copy.<br><br><br>Best Regards,<br><br><br> Contracts Team</div></body></html>'; 
    private static string NOTEBODYSFX = 'Dear [FIRSTLASTNAME],\n\n\n The documents for your transaction have been electronic signed, the attached document contains your copy.\n\n\nBest Regards,\n\n\n SFX Contracts Team';
    private static string TEMPLATEInternalSFX = '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd"> <html lang="en"> <head> <meta http-equiv="content-type" content="text/html; charset=utf-8"> <title>WWPT Contract</title> </head> <body> <TABLE width="100%"> <tr> <td align="left"><img src="https://holidaysystems.my.salesforce.com/file-asset-public/sfx_logopng?oid=00D3t000000dNJ9" alt="SFX Logo" height="110"></td> <td align="right"></td> </tr> </TABLE> <br> <div style="margin:20px;">Dear [FIRSTLASTNAME], <br><br><br>The documents for your transaction have been electronic signed, the attached document contains your copy.<br><br><br>Best Regards,<br><br><br> SFX Contracts Team</div> </body> </html>';
    private static string TEMPLATEInternalLVCMembership = '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd"> <html lang="en"> <head> <meta http-equiv="content-type" content="text/html; charset=utf-8"> <title>WWPT Contract</title> </head> <body> <TABLE width="100%"> <tr> <td align="left"><img src="https://holidaysystems.my.salesforce.com/sfc/p/3t000000dNJ9/a/4z000000leLP/28edbyquQuMns2koGS01iqVun8bvfrzijU_tRe3mqRY" alt="Leading Vacation Club Logo" height="110"></td> <td align="right"></td> </tr> </TABLE> <br> <div style="margin:20px;">Dear [FIRSTLASTNAME], <br><br><br>The documents for your transaction have been electronic signed, the attached document contains your copy.<br><br><br>Best Regards,<br><br><br>Contracts Team</div> </body> </html>';
    private static string NOTEBODYMHP = 'Dear [FIRSTLASTNAME],\n\n\n The documents for your transaction have been electronic signed, the attached document contains your copy.\n\n\nBest Regards,\n\n\nMy Holiday Pass Contracts Team';
    private static String TEMPLATEInternalMHP = '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd"><html lang="en"><head><meta http-equiv="content-type" content="text/html; charset=utf-8"><title>WWPT Contract</title></head><body><TABLE width="100%"><tr><td style="margin:20px;" align="left"><img src="https://wwpt--c.documentforce.com/servlet/servlet.ImageServer?id=0156g000000XYkm&oid=00D6g0000037CaR&lastMod=1604056399000" alt="WWPT Logo" height="150"></td><td align="right"></td></tr></TABLE><br><div style="margin:20px;">Dear [FIRSTLASTNAME], <br><br><br>The documents for your transaction have been electronic signed, the attached document contains your copy.<br><br><br>Best Regards,<br><br><br>My Holiday Pass Contracts Team</div></body></html>';  
    private static String TEMPLATEInternalCGE = '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd"><html lang="en"><head><meta http-equiv="content-type" content="text/html; charset=utf-8"><title>CGE Contract</title></head><body><TABLE width="100%"><tr><td align="left"><img src="https://marketingresourceshsi.s3.amazonaws.com/img2024/Enrollment/CG/images/logo.png" alt="CGE Logo" height="110"></td><td align="right"></td></tr></TABLE><br><div style="margin:20px;">Dear [FIRSTLASTNAME], <br><br><br>The documents for your transaction have been successfully signed electronically. Please find your copy attached to this email.<br>If you have any questions, feel free to reach out.<br><br><br>Best Regards,<br><br><br> Contracts Team</div></body></html>'; 
    private static string TEMPLATEInternalTRM = '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd"> <html lang="en"> <head> <meta http-equiv="content-type" content="text/html; charset=utf-8"> <title>TRM Contract</title> </head> <body> <TABLE width="100%"> <tr> <td align="left"><img src="https://members.timeshareresalemarket.com/Affiliates/1002407/images/yourlogo.png" alt="TRM Logo" height="110"></td> <td align="right"></td> </tr> </TABLE> <br> <div style="margin:20px;">Dear [FIRSTLASTNAME], <br><br><br>The documents for your transaction have been electronic signed, the attached document contains your copy.<br><br><br>Best Regards,<br><br><br>Contracts Team</div> </body> </html>';
    private static String TEMPLATEInternalReserveCollection = '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd"><html lang="en"><head><meta http-equiv="content-type" content="text/html; charset=utf-8"><title>WWPT Contract</title></head><body><TABLE width="100%"><tr><td align="left"><img src="https://holidaysystems.my.salesforce.com/file-asset-public/reserve_collection_logopng?oid=00D3t000000dNJ9" alt="MTRC Logo" height="110"></td><td align="right"></td></tr></TABLE><br><div style="margin:20px;">Dear [FIRSTLASTNAME], <br><br><br>The documents for your transaction have been electronic signed, the attached document contains your copy.<br><br><br>Best Regards,<br><br><br> Contracts Team</div></body></html>'; 
    //private static String TEMPLATEInternalAdSales = '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd"><html lang="en"><head><meta http-equiv="content-type" content="text/html; charset=utf-8"><title>WWPT Contract</title></head><body><TABLE width="100%"><tr><td align="left"><img src="http://sales.sellmytimesharenow.com/Content/Images/smtn_logo.png" alt="SMTN Logo" height="110"></td><td align="right"></td></tr></TABLE><br><div style="margin:20px;">Dear [FIRSTLASTNAME], <br><br><br>The documents for your transaction have been electronic signed, the attached document contains your copy.<br><br><br>Best Regards,<br><br><br> Contracts Team</div></body></html>'; 
    //private static String TEMPLATEInternalAdSales = '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd"><html lang="en"><head><meta http-equiv="content-type" content="text/html; charset=utf-8"><title>WWPT Contract</title></head><body><TABLE width="100%"><tr><td align="left"><img src="https://marketingresourceshsi.s3.amazonaws.com/img2024/SMTN/MFP-Intro/images/logo.png" alt="SMTN Logo" height="110"></td><td align="right"></td></tr></TABLE><br><div style="margin:20px;">Dear [FIRSTLASTNAME], <br><br><br>The documents for your transaction have been electronic signed, the attached document contains your copy.<br><br><br>Best Regards,<br><br><br> Contracts Team</div></body></html>'; 
    private static String TEMPLATEInternalAdSales = '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd"><html lang="en"><head><meta http-equiv="content-type" content="text/html; charset=utf-8"><title>WWPT Contract</title></head><body><TABLE width="100%"><tr><td align="left"><img src="https://marketingresourceshsi.s3.us-east-1.amazonaws.com/logos/CV_logo.png" alt="SMTN Logo" height="110"></td><td align="right"></td></tr></TABLE><br><div style="margin:20px;">Dear [FIRSTLASTNAME], <br><br><br>The documents for your transaction have been electronic signed, the attached document contains your copy.<br><br><br>Best Regards,<br><br><br> Contracts Team</div></body></html>'; 
    
    @Httppost
    global static ResponseWrapper createRecord()
    {
        ResponseWrapper response = new ResponseWrapper();
        response.status = SUCCESS; 
        response.errorMessage = '';
        RestRequest req = RestContext.request;
        
        try {
            Map<String,Object> receivedData = (Map<String,Object>)JSON.deserializeUntyped(req.requestBody.toString());
            String mfpType = receivedData.containsKey('MFPType') ? String.valueOf(receivedData.get('MFPType')) : '';
            Payment__c newPmnt = new Payment__c();
            System.debug('InsertPaymentService => @receivedData='+ receivedData);
            System.debug('InsertPaymentService => @receivedData.containsKey(ProductId)='+ receivedData.containsKey('ProductId'));
            newPmnt.Json_Request__c = receivedData + ' Row Request== ' + req;
            newPmnt.Opportunity__c = receivedData.containsKey('OpportunityId') ? String.valueOf(receivedData.get('OpportunityId')) : '';
            newPmnt.Payment_Amount__c = receivedData.containsKey('Amount') ? (Decimal)receivedData.get('Amount') : 0;
            newPmnt.Credit_Card_Number__c = receivedData.containsKey('CardLast4') ?  String.valueOf(receivedData.get('CardLast4')) : '';
            newPmnt.Payment_Number__c = receivedData.containsKey('PaymentOrd') ?  Integer.valueOf(receivedData.get('PaymentOrd')) : 0;
            newPmnt.CC_Processing_Fee__c = receivedData.containsKey('CCPaymentFee') ? (Decimal)receivedData.get('CCPaymentFee') : 0;
            //cfd voucher fields added
            newPmnt.Product_Id__c = receivedData.containsKey('ProductId') ? String.valueOf(receivedData.get('ProductId')) : '';
            newPmnt.Product_Salesforce_Id__c = receivedData.containsKey('Product2Id') ? String.valueOf(receivedData.get('Product2Id')) : null;
            newPmnt.AuthorizeNet_Transaction_Id__c = receivedData.containsKey('NetTransactionId') ? String.valueOf(receivedData.get('NetTransactionId')) : '';
            newPmnt.Transaction_Type__c = receivedData.containsKey('TransactionType') ? String.valueOf(receivedData.get('TransactionType')) : '';
            newPmnt.CC_Holder_Name__c = receivedData.containsKey('CCHolderName') ? String.valueOf(receivedData.get('CCHolderName')) : '';
            //cfd voucher fields added
            //E-check functionality
            newPmnt.Check_Number__c = receivedData.containsKey('CheckNumber')? Integer.valueOf(receivedData.get('CheckNumber')) : 0;
            newPmnt.Routing_Number__c = receivedData.containsKey('RoutingNumber') ? Integer.valueOf(receivedData.get('RoutingNumber')) : 0;
            
            /* TeeUp
if(receivedData.containsKey('MemberNumber') || receivedData.containsKey('AffiliateId') || receivedData.containsKey('AffiliateName')){
Opportunity opp = [select id, AccountId from Opportunity where Id=: String.valueOf(receivedData.get('OpportunityId'))]; 
Account objacc = new Account();
objacc.Id = opp.AccountId;
objacc.Member_Number__c = String.valueOf(receivedData.get('MemberNumber'));
objacc.Affiliated_Id__c = (Decimal)(receivedData.get('AffiliateId'));
objacc.Affiliate_Name__c = String.valueOf(receivedData.get('AffiliateName'));
update objacc;
}*/
            if(receivedData.containsKey('PaidOn') && String.valueOf(receivedData.get('PaidOn')).length() != 0) {
                newPmnt.Paid_On__c =  Date.valueOf(String.valueOf(receivedData.get('PaidOn')).replace('T',' ')) - (3/24); 
                system.debug('payment paid on == ' + newPmnt.Paid_On__c   + ' received date=  ' + String.valueOf(receivedData.get('PaidOn')).replace('T',' '));
            }
            if(receivedData.containsKey('CardFirstName') && receivedData.containsKey('CardLastName') ){
                datetime myDate =  System.now();
                newPmnt.Name = String.valueOf(receivedData.get('CardLastName'))  + String.valueOf(receivedData.get('CardFirstName')) + myDate.format('yyyyMMdd');
            }
            newPmnt.Payment_Processed__c = true;
            newPmnt.Payment_Type__c = 'Payment';//receivedData.containsKey('PaymentTypeStr') ? String.valueOf(receivedData.get('PaymentTypeStr')) : '';
            //// Record type assignment - As of now we assiging only for the HC quick fix. We may have to map other record type as well in future.
            String RecordtypeName = receivedData.containsKey('RecordType') ?  String.valueOf(receivedData.get('RecordType')) : '';
            Id membershipUpRecordtype = null;
            //CGE-104 - Add CV and CGE 2025-09-15
            if(RecordtypeName.contains('Hawaii Collection') || RecordtypeName.contains('SFX Membership') || RecordtypeName.contains('MTRC Membership Upgrade') || RecordtypeName.contains('Membership Add-On') 
               || RecordtypeName.contains('MTRC Retail') || RecordtypeName.contains('TRM Membership Upgrade')|| RecordtypeName.contains('Club Venture Membership')|| RecordtypeName.contains('Club Global Explorer')){
                membershipUpRecordtype = Schema.SObjectType.Payment__c.getRecordTypeInfosByName().get('Membership Upgrade').getRecordTypeId();
                system.debug('-membershipUpRecordtype--'+membershipUpRecordtype);
                if(membershipUpRecordtype != null){
                    system.debug('-membershipUpRecordtype--'+membershipUpRecordtype);
                    newPmnt.RecordTypeId = membershipUpRecordtype;
                }
            }
            //cfd voucher fields added
            else if(RecordtypeName.contains('Voucher'))
            {
                newPmnt.RecordTypeId = Schema.SObjectType.Payment__c.getRecordTypeInfosByDeveloperName().get('Voucher').getRecordTypeId();
            }
            
            //2023-09-07 - logic added to always override the single payment created in any product other than Exit Product for MU Team by the Exit Product for MU Team
            if(newPmnt.Payment_Amount__c > 0 && newPmnt.Json_Request__c.contains('CreatedBy=Checkout Site') && newPmnt.Product_Id__c != '' && newPmnt.Product_Id__c != null && newPmnt.Opportunity__c != null)
            {                
                Opportunity parentOpp = [SELECT Id,RecordType.DeveloperName,(SELECT Id,Product2.Name,Product2Id,Product_Id__c FROM OpportunityLineItems),(SELECT Id,Product_Id__c FROM Payments__r) FROM Opportunity WHERE Id =: newPmnt.Opportunity__c LIMIT 1];
                
                Map<String,String> exitProductCheck = new Map<String,String>();
                if(parentOpp.Payments__r != null && parentOpp.Payments__r.size()>0){
                    for(Payment__c py : parentOpp.Payments__r)
                    {                        
                        exitProductCheck.put(py.Product_Id__c,py.Id);
                    }
                }
                
                if(parentOpp.OpportunityLineItems != null && parentOpp.OpportunityLineItems.size()>0){
                    for(OpportunityLineItem oli : parentOpp.OpportunityLineItems)
                    {
                        if(oli.Product2.Name == 'Exit Product for MU Team' && newPmnt.Product_Id__c != oli.Product_Id__c && exitProductCheck.get(oli.Product_Id__c) == null)
                        {
                            newPmnt.Product_Id__c = oli.Product_Id__c;                            
                            //HSIMU2-589 SF - Error POSTING Payment on SalesForce
                            //newPmnt.Product_Salesforce_Id__c = oli.Id;
                            newPmnt.Product_Salesforce_Id__c = oli.Product2Id;
                            newPmnt.Opportunity_Product__c = oli.Id;                        
                            
                        }
                    }
                }
            }
            
            //cfd voucher fields added
            Insert newPmnt;
            
            Id SFXRecTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('SFX_Membership').getRecordTypeId();
            Id MTRCRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Membership_Upgrade').getRecordTypeId();
            Id MTRCRetailRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('MTRC_Retail').getRecordTypeId();
            Id HawaiiCollectionRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Hawaii_Collection_Membership').getRecordTypeId();
            Id LeadingVacationClubMembershipRecTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Leading_Vacation_Club_Membership').getRecordTypeId();
            Id CGERecTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Club_Global_Explorer').getRecordTypeId();
            // Club Venture record type ID
            Id CVRecTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Club_Venture_Membership').getRecordTypeId();
			Id TRMMembUpgRecTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('TRM_Membership_Upgrade').getRecordTypeId();
            //Reserve Collection record type ID
            Id rcRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Reserve_Collection_Membership').getRecordTypeId();
            Id adSalesRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Social_Ad_Sales').getRecordTypeId();
            //Membership Add-On record type ID
            Id memAddonRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Membership_Add_On').getRecordTypeId();
            List<Opportunity> op = [select Account.Affiliated_Id__c,Account.Name,Account.Marketing_Brand__c,Account.Marketing_Brand_Logo_Link__c,RecordType.DeveloperName, Credit_Received__c,AccountId,Account.Email__c, RecordTypeId,First_Agent__c,First_Agent__r.Email,(SELECT Id,Product2.Name,Product2Id,Product_Id__c FROM OpportunityLineItems),(SELECT Id,Product_Id__c FROM Payments__r) from Opportunity Where Id=:newPmnt.Opportunity__c Limit 1];
            system.debug('>>>>>'+op);
            if(op != null && op.size() > 0){
                
                system.debug('-receivedData.containsKey--'+receivedData.containsKey('sendEmail'));
                if(receivedData.containsKey('sendEmail') == true){
                    if(String.valueOf(receivedData.get('sendEmail')) == 'true')
                    {
                        String noteTxt = '';
                        String subject = '';
                        String emailBody = '';
                        Integer accountAffiliateId = 0;
                        if(op[0].Account.Affiliated_Id__c != null){
                            accountAffiliateId = Integer.valueOf(op[0].Account.Affiliated_Id__c);
                        }
                        
                        List<OrgWideEmailAddress> oweaList = new List<OrgWideEmailAddress>();
                        
                        if(op[0].RecordTypeId  != SFXRecTypeId){
                            noteTxt = NOTEBODYMTRC.replace( '[FIRSTLASTNAME]', op[0].Account.Name);
                        }
                        else if(op[0].RecordTypeId == SFXRecTypeId) //SFX Opp
                        {
                            noteTxt = NOTEBODYSFX.replace( '[FIRSTLASTNAME]', op[0].Account.Name);
                        }
                        
                        if(op[0].RecordTypeId == SFXRecTypeId){
                            subject = 'SFX Travel Store';
                        }
                        else if(op[0].RecordTypeId == MTRCRecordTypeId || op[0].RecordTypeId == MTRCRetailRecordTypeId){
                            subject = 'MTRC Travel Store';
                        }
                        else if(op[0].RecordTypeId == HawaiiCollectionRecordTypeId){
                            subject = 'Hawaii Collection Travel Store'; 
                        }
                        else if(op[0].RecordTypeId == LeadingVacationClubMembershipRecTypeId){
                            subject = 'Leading Vacation Club'; 
                        }
                        else if(op[0].RecordTypeId == CGERecTypeId){
                            subject = 'Club Global Explorer'; 
                        }
                        // Club CeVenture Membership
                         else if(op[0].RecordTypeId == CVRecTypeId){
                            subject = 'Club Venture Membership'; 
                        }
                        else if(op[0].RecordTypeId == TRMMembUpgRecTypeId){
						    subject = 'Timeshare Resale Market with MFP Plus'; 
						}
                        else if(op[0].RecordTypeId == rcRecordTypeId){
                            subject = 'Reserve Collection'; 
                        }
                        else if(op[0].RecordTypeId == adSalesRecordTypeId){
                            subject = 'Club Venture Ruby '; 
                        }                        
                        subject += ' Completed Contract - ' + op[0].Account.Name;//op[0].Account.Marketing_Brand__c + ' Completed Contract - ' + op[0].Account.Name;
                        
						system.debug('--subject----'+subject); 
						system.debug('--op[0].RecordTypeId----'+op[0].RecordTypeId); 
						system.debug('--adSalesRecordTypeId----'+adSalesRecordTypeId); 

                        
                        // adding condition change record type
                        if(op[0].RecordTypeId  == MTRCRecordTypeId || op[0].RecordTypeId == MTRCRetailRecordTypeId){
                            emailBody = TEMPLATEInternalMTRC.replace( '[FIRSTLASTNAME]', op[0].Account.Name);
                        }
                        if(op[0].RecordTypeId  == MTRCRecordTypeId || op[0].RecordTypeId == MTRCRetailRecordTypeId){
                            emailBody = TEMPLATEInternalMTRC.replace( '[FIRSTLASTNAME]', op[0].Account.Name);
                        }
                        else if(op[0].RecordTypeId == SFXRecTypeId) //SFX Opp
                        {
                            emailBody = TEMPLATEInternalSFX.replace( '[FIRSTLASTNAME]', op[0].Account.Name);
                        }
                        else if(op[0].RecordTypeId == HawaiiCollectionRecordTypeId){
                            emailBody = TEMPLATEInternalHC.replace( '[FIRSTLASTNAME]', op[0].Account.Name);
                        }
                        else if(op[0].RecordTypeId == LeadingVacationClubMembershipRecTypeId){
                            emailBody = TEMPLATEInternalLVCMembership.replace( '[FIRSTLASTNAME]', op[0].Account.Name);
                        }
                        else if(op[0].RecordTypeId == CGERecTypeId){
                            emailBody = TEMPLATEInternalCGE.replace( '[FIRSTLASTNAME]', op[0].Account.Name);
                        }
                        // Club Venture Membership
                        else if(op[0].RecordTypeId == CVRecTypeId){
                            emailBody = TEMPLATEInternalCGE.replace( '[FIRSTLASTNAME]', op[0].Account.Name);
                        }
						else if(op[0].RecordTypeId == TRMMembUpgRecTypeId){
						    emailBody = TEMPLATEInternalTRM.replace( '[FIRSTLASTNAME]', op[0].Account.Name);
						}
                        else if(op[0].RecordTypeId  == rcRecordTypeId || (op[0].RecordTypeId == memAddonRecordTypeId && (accountAffiliateId == 1002467 || accountAffiliateId == 1002468 || accountAffiliateId == 1002469))){
                            emailBody = TEMPLATEInternalReserveCollection.replace( '[FIRSTLASTNAME]', op[0].Account.Name);
                        }
                        else if(op[0].RecordTypeId == adSalesRecordTypeId){
							system.debug('--Ad Sales----'); 
                            emailBody = TEMPLATEInternalAdSales.replace( '[FIRSTLASTNAME]', op[0].Account.Name);
                        }
                    
                        
                        //SAS-55
                        //if(op[0].RecordTypeId == adSalesRecordTypeId){ //SAS-2
						//	system.debug('--Ad Sales----'); 
                        //	oweaList = [SELECT ID,IsAllowAllProfiles,DisplayName,Address FROM OrgWideEmailAddress WHERE Address = 'contracts@smtn.com' AND IsAllowAllProfiles = TRUE];    
                        //}
                        //else{
						//	system.debug('--Not Ad Sales----'); 
                        	oweaList = [SELECT ID,IsAllowAllProfiles,DisplayName,Address FROM OrgWideEmailAddress WHERE Address = 'contract@AdvantageProgram.net' AND IsAllowAllProfiles = TRUE];    
                        //}

                        system.debug('--noteTxt----'+noteTxt); 
                        system.debug('-subject-----'+subject); 
                        system.debug('-emailBody-----'+emailBody); 
                        ContentNote cnt = new ContentNote();
                        cnt.Title = subject;
                        cnt.Content = blob.valueof(noteTxt);
                        insert cnt;
                        
                        ContentDocument cd=[select id from ContentDocument where id=:cnt.Id];
                        ContentDocumentLink cdl=new ContentDocumentLink();
                        cdl.ContentDocumentId=cd.id;
                        cdl.LinkedEntityId=op[0].id;
                        cdl.ShareType='V';
                        cdl.Visibility='AllUsers';
                        insert cdl;
                        system.debug('>>>>cdl>'+cdl);
                        Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
                        List<ContentDocumentLink> contentDocumentList = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: op[0].id];
                        Set<id> contentDo = new Set<id>();
                        for(ContentDocumentLink ctdl : contentDocumentList){
                            contentDo.add(ctdl.ContentDocumentId);
                        }
                        system.debug('>>>>contentDo>'+contentDo);
                        List<ContentVersion> cversionList = [SELECT title, PathOnClient, FileType,versiondata FROM contentversion 
                                                             WHERE title LIKE 'Contract_%' and ContentDocumentId In :contentDo];
                        if(cversionList != null && cversionList.size() > 0 ){
                            system.debug('-cversionList--'+cversionList.size());
                            for ( ContentVersion cversion : cversionList){
                                blob WOCFbody = cversion.versiondata;
                                system.debug('body : '+WOCFbody+'-----------'+cversion.title);
                                efa.setFileName(cversion.title+'.'+cversion.FileType);
                                efa.setBody(WOCFbody);
                            }
                            // Email sending with attachment
                            List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
                            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
                            email.setSubject( subject );
                            //email.setToAddresses(new String[] {'thumarmitul@gmail.com'});
                            email.setToAddresses(new String[] {op[0].Account.Email__c});
                            if(op[0].First_Agent__c != null){
                                email.setBccAddresses(new String[] {op[0].First_Agent__r.Email});
                            }
                            
                            email.setHtmlBody(emailBody);
                            if(oweaList != null && oweaList.size() > 0){
                                email.setOrgWideEmailAddressId(oweaList.get(0).Id);
                            }
                            // Attach file using setFileAttachments function
                            email.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
                            /*allmsg.add(email);
if(mfpType != null && mfpType != ''){
EmailTemplate templateId = [Select id from EmailTemplate where DeveloperName = 'MFP_Reinstatement_Receipt'];
Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
mail.setTemplateID(templateId.Id); 
mail.setTargetObjectId(newPmnt.id);
mail.setSaveAsActivity(true);
allmsg.add(mail); 
}*/
                            // Sends the email
                            Messaging.SendEmailResult [] r =  Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});     
                            system.debug('----r---'+r);
                            
                        }else { 
                            Opportunity ParentOp = [SELECT Id,RecordType.DeveloperName,(SELECT Id,Product2.Name,Product2Id,Product_Id__c FROM OpportunityLineItems),(SELECT Id,Product_Id__c FROM Payments__r) FROM Opportunity WHERE Id =: newPmnt.Opportunity__c LIMIT 1];
                            for(OpportunityLineItem olip : ParentOp.OpportunityLineItems)
                                
                                if (olip.Product2.Name != 'Exit Product for MU Team' && olip.Product2.Name != 'Guest Voucher' && olip.Product2.Name != 'Cancun Cards Add-On SPA' && olip.Product2.Name != 'Cancun Cards Add-On' ) {
                                    system.debug('-else--');
                                    String subjectInternal = 'HSI Missing Contract Email ' + op[0].id;
                                    //String emailBodyInternal = 'Opportunity Id : '+op[0].id+' / '+ 'ProductName : '+olip.Product2.Name +' / '+'Product ID:'+newPmnt.Product_Id__c;
                                    String emailBodyInternal = 'Opportunity Id: ' + op[0].id + '\n'+ 'ProductName: ' + olip.Product2.Name + '\n' + 'Product ID: ' + newPmnt.Product_Id__c;
                                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
                                    email.setSubject( subjectInternal );
                                    //email.setToAddresses(new String[] {'danilo.fernandes@nerdsoft.com', 'daniel.oliveira@nerdsoft.com'});
                                    email.setToAddresses(new String[] {'amadeu.lettieri@vacationinnovations.com','shauwn.rush@vacationinnovations.com','danilo.fernandes@nerdsoft.com', 'daniel.oliveira@nerdsoft.com'});
                                    email.setHtmlBody(emailBodyInternal);
                                    
                                    if (oweaList != null && oweaList.size() > 0){
                                        email.setOrgWideEmailAddressId(oweaList.get(0).Id);
                                    }
                                    // Attach file using setFileAttachments function
                                    // Sends the email
                                    Messaging.SendEmailResult [] r =  Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});   
                                    system.debug('----r---'+r);
                                }
                        }
                    }
                }
            }
            accountAffiliateInformation affObj = new accountAffiliateInformation();
            if(op != null && op.size() > 0){
                List<Account> accList = [Select id,Contact_Id__c,Affiliate_Name__c,
                                         Affiliate_Type__c,Affiliated_Id__c,Breakaway_Price_Markup__c,Breakaway_Revenue_Share__c,
                                         Credits_Balance__c,Display_Mode__c,Dues_Last_Paid_Until__c,Enrollment_Date__c,Enrollment_Term_Years__c,
                                         Member_Prefix__c,Membership_Annual_Due__c,Member_Number__c,Enrollment_Fee__c
                                         from Account where Id =: op[0].AccountId];
                
                affObj.Contact_Id_c = string.valueof(accList[0].Contact_Id__c);
                affObj.Affiliate_Name_c = accList[0].Affiliate_Name__c;
                affObj.Affiliate_Type_c = accList[0].Affiliate_Type__c;
                affObj.Affiliated_Id_c = String.valueof(accList[0].Affiliated_Id__c);
                affObj.Breakaway_Price_Markup_c = string.valueof(accList[0].Breakaway_Price_Markup__c);
                affObj.Breakaway_Revenue_Share_c = String.valueof(accList[0].Breakaway_Revenue_Share__c);
                affObj.Credits_Balance_c = string.valueof(accList[0].Credits_Balance__c);
                affObj.Display_Mode_c = accList[0].Display_Mode__c;
                affObj.Dues_Last_Paid_Until_c = String.valueof(accList[0].Dues_Last_Paid_Until__c);
                affObj.Enrollment_Date_c = string.valueof(accList[0].Enrollment_Date__c);
                affObj.Enrollment_Term_Years_c = string.valueof(accList[0].Enrollment_Term_Years__c);
                affObj.Member_Prefix_c = accList[0].Member_Prefix__c;
                affObj.Membership_Annual_Due_c = string.valueof(accList[0].Membership_Annual_Due__c);
                affObj.Member_Number_c = string.valueof(accList[0].Member_Number__c);
                affObj.Credit_Received_c = string.valueof(op[0].Credit_Received__c);
                affObj.Enrollment_Fee_c = string.valueof(accList[0].Enrollment_Fee__c);
                
                
                // Update MFP Type on Account
                if(mfpType != null && mfpType != ''){
                    Account objacc = new Account();
                    objacc.Id = op[0].AccountId;
                    objacc.MFP_Type__c = mfpType;
                    update objacc;
                    
                }
            }
            response.accAffObj = affObj;
            response.retVal = newPmnt.Id;  
        } catch (Exception ex){
            System.debug('Exception occurrred on LineNumber:' + ex.getLineNumber() + ', Message:' + ex.getMessage());
            response.status = ERROR;
            response.errorMessage = 'Message:' + ex.getMessage()  + ' - Exception occurrred on LineNumber: ' + ex.getLineNumber();
        }
        return response;   
    }
    
    global class ResponseWrapper{
        webservice String status; 
        webservice String errorMessage;
        webservice String retVal;
        webservice accountAffiliateInformation accAffObj;
    }
    global class accountAffiliateInformation{
        public string Contact_Id_c{get;set;}
        public string Affiliate_Name_c{get;set;}
        public string Affiliate_Type_c{get;set;}
        public string Affiliated_Id_c{get;set;}
        public string Breakaway_Price_Markup_c{get;set;}
        public string Breakaway_Revenue_Share_c{get;set;}
        public string Credits_Balance_c{get;set;}
        public string Display_Mode_c{get;set;}
        public string Dues_Last_Paid_Until_c{get;set;}
        public string Enrollment_Date_c{get;set;}
        public string Enrollment_Term_Years_c{get;set;}
        public string Member_Prefix_c{get;set;}
        public string Membership_Annual_Due_c{get;set;}
        public string Member_Number_c{get;set;}
        public string Credit_Received_c{get;set;}
        public string Enrollment_Fee_c{get;set;}
    }
    public class MyException extends Exception {}
}