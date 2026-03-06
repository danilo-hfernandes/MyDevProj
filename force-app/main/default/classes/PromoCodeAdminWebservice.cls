@RestResource(urlMapping='/promocodeadminWebservice/*')
Global class PromoCodeAdminWebservice {
    @Httppost
    global static ResponseWrapper createRecord(){
        ResponseWrapper response = new ResponseWrapper();
        response.status = 'SUCCESS';  
        response.errorMessage = '';
        RestRequest req = RestContext.request;
        try{            
            Map<String, Object> promoCodeAdminData = (Map<String, Object>) JSON.deserializeUntyped(req.requestBody.toString());            
            Promo_Code_Admin_Portal__c objpromoCode = new Promo_Code_Admin_Portal__c();
            if(promoCodeAdminData.containsKey('AutoId'))
                objpromoCode.AutoId__c = String.valueOf(promoCodeAdminData.get('AutoId'));
            if(promoCodeAdminData.containsKey('PromoCodeName'))
                objpromoCode.Name = String.valueOf(promoCodeAdminData.get('PromoCodeName'));
            if(promoCodeAdminData.containsKey('Status'))
                objpromoCode.Status__c = String.valueOf(promoCodeAdminData.get('Status'));
            if(promoCodeAdminData.containsKey('Type'))
                objpromoCode.Type__c = String.valueOf(promoCodeAdminData.get('Type'));
            if(promoCodeAdminData.containsKey('StartDate'))
            {
                if(promoCodeAdminData.get('StartDate') != null && promoCodeAdminData.get('StartDate') != ''){
                    objpromoCode.StartDate__c = (Date)JSON.deserialize('"' + promoCodeAdminData.get('StartDate') + '"', Date.class);
                }
                else
                {
                    objpromoCode.StartDate__c = null;
                }
            }
            if(promoCodeAdminData.containsKey('ExpirationDate'))
            {
                if(promoCodeAdminData.get('ExpirationDate') != null && promoCodeAdminData.get('ExpirationDate') != ''){
                    objpromoCode.ExpirationDate__c =(Date)JSON.deserialize('"' + promoCodeAdminData.get('ExpirationDate') + '"', Date.class);
                }
                else
                {
                    objpromoCode.ExpirationDate__c = null;
                }
            }
            if(promoCodeAdminData.containsKey('CheckInDate')){
                if(promoCodeAdminData.get('CheckInDate') != null && promoCodeAdminData.get('CheckInDate') != ''){
                    objpromoCode.CheckInDate__c =(Date)JSON.deserialize('"' + promoCodeAdminData.get('CheckInDate') + '"', Date.class);
                }
                else
                {
                    objpromoCode.CheckInDate__c = null;
                }
            }
            if(promoCodeAdminData.containsKey('ExpiredErrorMessage'))
                objpromoCode.Expired_Error_Message__c = String.valueOf(promoCodeAdminData.get('ExpiredErrorMessage'));
            if(promoCodeAdminData.containsKey('InvalidErrorMessage'))
                objpromoCode.Invalid_Error_Message__c = String.valueOf(promoCodeAdminData.get('InvalidErrorMessage'));
            if(promoCodeAdminData.containsKey('promoCodeDestinationSettings'))
                objpromoCode.Promo_Code_Destination_Settings__c = String.ValueOf(promoCodeAdminData.get('promoCodeDestinationSettings'));
            if(promoCodeAdminData.containsKey('promoCodeResortSettings'))
                objpromoCode.Promo_Code_Resort_Settings__c = String.ValueOf(promoCodeAdminData.get('promoCodeResortSettings'));
            if(promoCodeAdminData.containsKey('promoCodePriceRangeSettings'))
                objpromoCode.Promo_Code_Price_Range_Settings__c = String.valueOf(promoCodeAdminData.get('promoCodePriceRangeSettings'));
            
            if(promoCodeAdminData.containsKey('PromoCodeApplication'))
                objpromoCode.Promo_Code_Application__c = String.valueOf(promoCodeAdminData.get('PromoCodeApplication'));
            
            //upsert objpromoCode AutoId__c;
            objpromoCode.AutoId__c += objpromoCode.Promo_Code_Application__c;
			upsert objpromoCode AutoId__c;
            
        }
        catch(Exception ex){
            response.status = 'Error'; 
            response.errorMessage = ex.getMessage() + ' - Line = ' + ex.getLineNumber() + ex.getCause();
        }
        
        return response;
    }
    global class ResponseWrapper{
        webservice String status; 
        webservice String errorMessage;
    }
}