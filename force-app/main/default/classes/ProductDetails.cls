/*
Created By 	: Mitul
Created Date 	: 3/29/2021
Perpose		: This clsse we used to get the product inforation based on Product ID (Custom Auto generate Number)
Used			: Internal Agent will use the wordpress checkout site and pass the product ID based on that this class will retun the product details if any

*/
@RestResource(urlMapping='/ProductDetails/*')
global with sharing class ProductDetails {
    @HttpGet
    global static OppLineItemListWrapper ProductDetailsData() {
        try{
            String errorMessage= '';
            Boolean allowPayment = true;
            String baseProductId = '';
            RestRequest request = RestContext.request;
            // grab the product Id (Auto Number) from the end of the URL
            String productNumber = request.requestURI.substring(request.requestURI.lastIndexOf('/')+1);
            system.debug('--request---'+request);
            system.debug('--productNumber--'+productNumber);
            if(productNumber.contains('%20')){
                productNumber = productNumber.replace('%20', ' ');
            }
            system.debug('--productNumber--'+productNumber);
            List<OpportunityLineItem> OppLineItemList = new List<OpportunityLineItem>();
            if(productNumber != null && productNumber != ''){
                OppLineItemList = [SELECT Id,Name,OpportunityId,Product2.Product_Type__c,Quantity,TotalPrice,Opportunity.Name,Product2.Name,Product_Id__c,Travel_Apply_Credits__c,UnitPrice,Balance_to_Pay__c,Apply_Credits__c,Opportunity.Account.Member_Number__c, Opportunity.Record_Type_Name__c, Opportunity.Marital_Status__c, Opportunity.Age_Range__c, Opportunity.Major_Credit_Card__c, Opportunity.Household_Income__c FROM OpportunityLineItem 
                                   where Product_Id__c =: productNumber];
                
            }
            Id voucherRecordtypeId = Schema.SObjectType.Payment__c.getRecordTypeInfosByName().get('Voucher').getRecordTypeId();
            Id annualDuesRecordType = Schema.SObjectType.Payment__c.getRecordTypeInfosByName().get('Membership Annual Dues').getRecordTypeId();
            
            if(OppLineItemList.size() > 0 && OppLineItemList[0].Product2.Product_Type__c != null && OppLineItemList[0].Opportunity.Record_Type_Name__c != 'Membership Add-On'){
                String productType = OppLineItemList[0].Product2.Product_Type__c;
                if(productType == 'Base'){
                    allowPayment = true;
                }
                else if(productType != 'Base'){
                    List<OpportunityLineItem> objOppline = [select id,Product_Id__c from OpportunityLineItem where OpportunityId = : OppLineItemList[0].OpportunityId and Product2.Product_Type__c = 'Base' limit 1];
                    if(objOppline != null && objOppline.size() > 0){
                        List<Payment__c> paylist = [select id from Payment__c where Opportunity_Product__c =: objOppline[0].Id or Product_Id__c =: objOppline[0].Product_Id__c limit 1];
                        if(paylist != null && paylist.size() > 0){
                            allowPayment = true;
                        }
                        else{
                            baseProductId = objOppline[0].Product_Id__c;
                            allowPayment = false;
                            errorMessage = 'You cannot submit payment for '+productType+' product until the payment for the base product ('+objOppline[0].Product_Id__c+') has been collected.';
                        }
                    }
                    else{
                        allowPayment = false;
                        errorMessage = 'You cannot submit payment until a base product is attached to the opportunity and payment is collected for it.'; 
                    }
                    
                }
            }
            if(OppLineItemList.size() > 0){
                OppLineItemListWrapper wrp = new OppLineItemListWrapper();
                wrp.allow_Payment = allowPayment;
                wrp.base_product = baseProductId;
                wrp.APIstatus = 'SUCCESS';
                wrp.error_Message = errorMessage;
                wrp.productName = OppLineItemList[0].Product2.Name;
                wrp.OpportunityName = OppLineItemList[0].Opportunity.Name;
                wrp.ProductId = OppLineItemList[0].Product_Id__c;
                wrp.UnitPrice = OppLineItemList[0].UnitPrice;
                wrp.OpportunityId = OppLineItemList[0].OpportunityId;
                wrp.Quantity=OppLineItemList[0].Quantity;
                wrp.TotalPrice=OppLineItemList[0].TotalPrice;
                wrp.BalanceToPay=OppLineItemList[0].Balance_to_Pay__c;
                wrp.CreditsApplied=OppLineItemList[0].Apply_Credits__c;
                wrp.MemberNumber=OppLineItemList[0].Opportunity.Account.Member_Number__c;
                wrp.TravelApplyCredits = OppLineItemList[0].Travel_Apply_Credits__c;
                wrp.OpportunityRecordTypeName = OppLineItemList[0].Opportunity.Record_Type_Name__c;
                wrp.OpportunityMaritalStatus = OppLineItemList[0].Opportunity.Marital_Status__c;
                wrp.OpportunityAgeRange = OppLineItemList[0].Opportunity.Age_Range__c;
                wrp.OpportunityMajorCreditCard = OppLineItemList[0].Opportunity.Major_Credit_Card__c;
                wrp.OpportunityHousehold = OppLineItemList[0].Opportunity.Household_Income__c;
                
                system.debug('--OppLineItemList[0].Product2.Name--'+OppLineItemList[0].Product2.Name);
                if(OppLineItemList[0].Product2.Name.contains('Annual Dues')){
                    system.debug('--OppLineItemList[0].Product2.Name--'+OppLineItemList[0].Product2.Name);
                    wrp.PaymentRecordtype =annualDuesRecordType;
                }else{
                    system.debug('--OppLineItemList[0].Product2.Name--'+OppLineItemList[0].Product2.Name);
                    wrp.PaymentRecordtype =voucherRecordtypeId;
                }    
                // wrp.PaymentRecordtype = OppLineItemList[0].Product2.Name == 'Annual Dues-Renewal'? annualDuesRecordType : voucherRecordtypeId;// Query on Payment cert recordtype and pass that Id while creation payment record
                return  wrp;
            }else{
                OppLineItemListWrapper wrp = new OppLineItemListWrapper();   
                wrp.APIstatus = 'ERROR';
                wrp.error_Message = 'Product Id is not valid';
                wrp.ProductId = productNumber;
                return wrp;
            }
        }catch(Exception e){
            system.debug('--e---'+e+'linenumber'+e.getLineNumber());
        }
        return null;
        
    }
    global class OppLineItemListWrapper{
        webservice String APIstatus;
        webservice String error_Message;
        webservice String productName;
        webservice String OpportunityName;
        webservice String OpportunityId;
        webservice String ProductId;
        webservice decimal UnitPrice;
        webservice String PaymentRecordtype;
        webservice decimal quantity;
        webservice decimal TotalPrice;
        webservice decimal BalanceToPay;
        webservice decimal CreditsApplied;
        webservice string MemberNumber;
        webservice string OpportunityHousehold;
        webservice string OpportunityMajorCreditCard ;
        webservice string OpportunityAgeRange;
        webservice string OpportunityMaritalStatus;
        webservice string OpportunityRecordTypeName;
        webservice boolean allow_Payment;
        webservice String base_product;
        webservice decimal TravelApplyCredits;
        
    }
}