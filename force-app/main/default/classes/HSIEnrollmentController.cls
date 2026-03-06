public class HSIEnrollmentController {
    
    @AuraEnabled
    public static String registerRecordToHSI(String accId){
        requestdataWrapper req = New requestdataWrapper();
        List<Account> accList = new List<Account>();
        String returnString = '';
		Set<Id> accountsToCheck = new Set<Id>();
        //2022-10-27 added Vacation VIP Affiliate Id (1002335)

        accList = [SELECT Id,
                   Auto_Id__c,
                   Member_Number__c,
                   First_Name__c,
                   Last_Name__c,
                   Email__c,
                   Phone,
                   BillingStreet,
                   BillingCity,
                   BillingPostalCode,
                   BillingState,
                   BillingCountry,
                   Affiliated_Id__c
                   FROM ACCOUNT 
                   WHERE Id =: accId 
                   AND (Affiliated_Id__c = 1002241 OR Affiliated_Id__c = 1002335 OR Affiliated_Id__c = 1002418 OR Affiliated_Id__c = 1002258 OR Affiliated_Id__c = 1002266 OR Affiliated_Id__c = 1002256)];
        
        if(!accList.isEmpty()){
            //req.isPublicCheckout = false;
            //2022-10-27 added Vacation VIP Affiliate Id (1002335)
            if(accList[0].Affiliated_Id__c == 1002335){
                req.tierLevel = 'VIPV';
            }

            else if(accList[0].Affiliated_Id__c == 1002241)
            {
                req.tierLevel = 'SMTNC';
            }
            else if(accList[0].Affiliated_Id__c == 1002418)
            {
                req.tierLevel = 'VBWU';
            }
            else if(accList[0].Affiliated_Id__c == 1002258)
            {
                req.tierLevel = 'CFDG';
            }
            else if(accList[0].Affiliated_Id__c == 1002256)
            {
                req.tierLevel = 'CFD';
                accountsToCheck.add(accId);
            }
            else if(accList[0].Affiliated_Id__c == 1002266)
            {
                req.tierLevel = 'CFD-FB';
                accountsToCheck.add(accId);
            }
            req.contractNumber = accList[0].Auto_Id__c;
            req.memberNumber = accList[0].Member_Number__c;
            req.firstName = accList[0].First_Name__c;
            req.lastName = accList[0].Last_Name__c;
            req.emailAddress = accList[0].Email__c;
            req.phoneNumber = accList[0].Phone;
            /*req.address = accList[0].BillingStreet;
			req.city = accList[0].BillingCity;
			req.postalCode = accList[0].BillingPostalCode;
			req.stateCode = accList[0].BillingState;
			req.countryCode = accList[0].BillingCountry;*/
            req.address = accList[0].BillingStreet != null && accList[0].BillingStreet != '' ? accList[0].BillingStreet : 'Address';
            req.city = accList[0].BillingCity != null && accList[0].BillingCity != '' ? accList[0].BillingCity : 'City';
            req.postalCode = accList[0].BillingPostalCode != null && accList[0].BillingPostalCode != '' ? accList[0].BillingPostalCode : '32819';
            req.stateCode = accList[0].BillingState != null && accList[0].BillingState != '' ? accList[0].BillingState : 'State';
            req.countryCode = accList[0].BillingCountry != null && accList[0].BillingCountry != '' ? accList[0].BillingCountry : 'US';
            if(accList[0].Affiliated_Id__c == 1002256 || accList[0].Affiliated_Id__c == 1002266){
                req.RenewableYears = 1;
                req.AdvantageWeeksAllocated = 1;
            }
            else
            {
                req.RenewableYears = 0;
                req.AdvantageWeeksAllocated = 0;
            }
            //req.source = '1';
            req.languagePreferred = New languageWrapper();
            languageWrapper lan = new languageWrapper();
            lan.code = 'ENG';
            lan.name = 'ENGLISH';
            
            
            req.languagePreferred = lan;
            
            String body = JSON.serialize(req);
            system.debug('body--'+body);
            HttpRequest httpRequest = new HttpRequest();
            httpRequest.setTimeout(120000);
            httpRequest.setMethod('POST');            
            
            //2022-10-27 added Vacation VIP Affiliate Id (1002335)
            if(accList[0].Affiliated_Id__c == 1002335){
                httpRequest.setHeader('api-key','ced3d224-5343-41f2-87d1-3b51eaa1938e');
            }
       
            else if(accList[0].Affiliated_Id__c == 1002241)
            {
                httpRequest.setHeader('api-key','0784a23d-1118-4365-9912-a32dbf06a28e');
            }
            else if(accList[0].Affiliated_Id__c == 1002418)
            {
                httpRequest.setHeader('api-key','cb22595a-99d1-40a4-aa0a-1a5d279bd338');
            }
            else if(accList[0].Affiliated_Id__c == 1002258)
            {
                httpRequest.setHeader('api-key','a2714ed4-9735-40bb-a1e9-4cdf0bb3d3f4');
            }
            else if(accList[0].Affiliated_Id__c == 1002256)
            {
                httpRequest.setHeader('api-key','6ee094a1-c4a0-484f-ae4e-fc5714c1caf8');
            }
            else if(accList[0].Affiliated_Id__c == 1002266)
            {
                httpRequest.setHeader('api-key','7c78bf45-6967-472d-a445-1fc2643ec0df');
            }
            
            httpRequest.setHeader('Content-Type', 'application/json');
            
            Boolean runningInASandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
            
            if(runningInASandbox){
                httpRequest.setEndpoint('http://hsiwinapi.nerdsoft.hqa.hsi1.com/api/SMTNRegistration/Register');
            }
            else{
                httpRequest.setEndpoint('http://HSIWinAPI.nerdsoft.com/api/SMTNRegistration/Register');                 
            }            
            
            httpRequest.setBody(body);
            String response = '';
            try {  
                Http http = new Http();
                
                HttpResponse httpResponse = http.send(httpRequest);  
                system.debug('httpResponse.getBody()-'+httpResponse.getBody());
                response = JSON.serializePretty( JSON.deserializeUntyped(httpResponse.getBody()) );

                //if(!Test.isRunningTest()){
                    Map<String,Object> receivedData = (Map<String,Object>)JSON.deserializeUntyped(response);
                    System.debug(' ** response ** : ' + receivedData ); 
                    system.debug('asd-'+receivedData.get('IsSucceed'));
                    system.debug('assss-'+String.valueOf(receivedData.get('Errors')));
                    
                    Boolean success = Boolean.valueOf(receivedData.get('IsSucceed'));
                    if(success){
                        accList[0].Contact_Id__c = Integer.valueOf(receivedData.get('ContactId'));
                        accList[0].Member_Number__c = String.valueOf(receivedData.get('MemberNumber'));
                        accList[0].Master_Record_Id__c =  String.valueOf(receivedData.get('ContactId')) +'-'+ String.valueOf(receivedData.get('MemberNumber'));
                        update accList;
                        returnString = 'Success';
                        if(accountsToCheck.size()>0 && accountsToCheck != null)
                        {
                            List<HSI_Enrollment_Queue__c> enrollList = New List<HSI_Enrollment_Queue__c>();                            
                            enrollList = [Select Id,Member_Number__c,First_Name__c,Last_Name__c,Email__c,Primary_Phone__c,Address__c,City__c,Zip_Code__c,State__c,Country__c, Record_Origin__c,
                                          Processed_On__c,Successful_Processed__c,Created_By__c,Failure_Count__c,Update_Account__c,name__c,code__c,Auto_Id__c,First_Response_Log__c from HSI_Enrollment_Queue__c where
                                          Processed_On__c = Null AND Successful_Processed__c = False AND Failure_Count__c <=3 AND AccountId__c = : accId ORDER BY Failure_Count__c ASC limit 1];
                            if(enrollList != null && enrollList.size()>0){
                                HSI_Enrollment_Queue__c updhsi = enrollList[0];
                                updhsi.Processed_On__c = Date.today();
                                updhsi.Successful_Processed__c = true;
                                updhsi.Comments__c = 'account enrolled immediately by the button (HSIEnrollmentController)';
                                update updhsi;
                            }
                        }
                    }else{
                        String errString = '';
                        List<Object> err = (List<Object>)receivedData.get('Errors');
                        for (Object datum : err){
                            Map<String, Object> innerData = (Map<String, Object>)datum;
                            errString += innerData.get('Description');
                        }
                        returnString = errString;
                    }
                //}
            } catch( System.Exception e) {
                System.debug('ERROR: '+ e);
                returnString = e.getMessage();
            }
            System.debug(' ** response ** : ' + response ); 
        }else{
            returnString = 'The affiliate Id does not have access to this feature';
        }
        return returnString;
    }
    
    public class requestdataWrapper{
        //public boolean isPublicCheckout;
        //public string source;
        public String tierLevel;
        public String contractNumber;
        public String memberNumber;
        public String firstName;
        public String lastName;
        public String emailAddress;
        public String phoneNumber;
        public String address;
        public String city;
        public String postalCode;
        public String stateCode;
        public String countryCode;
        public Integer RenewableYears;
        public Integer AdvantageWeeksAllocated;
        public languageWrapper languagePreferred;
    }
    
    public class responseWrapper{
        public String IsSucceed;
        public String[] Errors;
        public String MemberNumber;
        public String ContactId;
    }
    
    public class languageWrapper{
        public string code;
        public string name;
    }
    
}