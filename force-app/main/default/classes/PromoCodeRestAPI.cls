/*
 Created By 	: Mitul
 Created Date 	: 3/25/2021
 Perpose		: This clsse used to get the Promotional code details based on Promo Code Name
 Used			: End ustomer will pass the promo code to get the discount if apply

*/

@RestResource(urlMapping='/Promotionalcode/*')
global with sharing class PromoCodeRestAPI {
    
    @HttpGet
    global static PromocodeResponseWrapper promoCodeQueryReturn() {
        try{
             RestRequest request = RestContext.request;
            // grab the promocode name from the end of the URL
            String promoCodeName = request.requestURI.substring(request.requestURI.lastIndexOf('/')+1);
            system.debug('--request---'+request);
            system.debug('--promoCodeName--'+promoCodeName);
            if(promoCodeName.contains('%20')){
                promoCodeName = promoCodeName.replace('%20', ' ');
            }
            system.debug('--promoCodeName--'+promoCodeName);
            List<Promotional_Code__c> lsList = new List<Promotional_Code__c>();
            if(promoCodeName != null && promoCodeName != ''){
                lsList = [SELECT Id,Name,Voucher_Product__r.Id,Voucher_Product__c,Voucher_Product__r.Name,Discount__c,Discount_Type__c,End_Date__c,Expired_Error_Message__c,
                    Invalid_Error_Message__c,Location__c,Resort_Id__c,Start_Date__c,Status__c,Type__c FROM Promotional_Code__c 
                         where Name =: promoCodeName and Status__c ='Active'];
                
            }
            
            if(lsList.size() > 0){
                PromocodeResponseWrapper wrp = new PromocodeResponseWrapper();
                wrp.APIstatus = 'SUCCESS';
                wrp.error_Message = null;
                wrp.Promocode_Name = lsList[0].Name;
                wrp.Voucher_Product = lsList[0].Voucher_Product__r.Name;
                wrp.Voucher_Id = lsList[0].Voucher_Product__r.Id;
                wrp.Discount = lsList[0].Discount__c;
                wrp.Discount_Type = lsList[0].Discount_Type__c;
                wrp.Start_Date = lsList[0].Start_Date__c;
                wrp.End_Date = lsList[0].End_Date__c;
                wrp.PromoType = lsList[0].Type__c;
                wrp.Invalid_Error_Message = lsList[0].Invalid_Error_Message__c;
                wrp.Expired_Error_Message = lsList[0].Expired_Error_Message__c;
                wrp.Location = lsList[0].Location__c;
                wrp.Resort_Id = lsList[0].Resort_Id__c;
                wrp.Status = lsList[0].status__c;
                return  wrp;
            }else{
                PromocodeResponseWrapper wrp = new PromocodeResponseWrapper();   
                wrp.APIstatus = 'ERROR';
                wrp.error_Message = 'Promo code not found or it is expired';
                wrp.Promocode_Name = null;
                return wrp;
            }
        }catch(Exception e){
            system.debug('--e---'+e);
        }
        return null;
        
    }
    global class PromocodeResponseWrapper{
        webservice String APIstatus;
        webservice String error_Message;
        webservice String Promocode_Name;
        webservice String Voucher_Product;
        webservice String Voucher_Id;
        webservice decimal Discount;
        webservice String Discount_Type;
        webservice date Start_Date;
        webservice date End_Date;
        webservice String Invalid_Error_Message;
        webservice String Expired_Error_Message;
        webservice string PromoType;
        webservice String Location;
        webservice String Resort_Id;
        webservice String Status;
        
    }
}