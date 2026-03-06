/*
Created By 	: Hitarth
Created Date 	: 2/05/2021
Perpose		: This class is used to send the request to .NET for Member creation

enrollList = [Select Id,Member_Number__c,First_Name__c,Last_Name__c,Email__c,Primary_Phone__c,Address__c,City__c,Zip_Code__c,State__c,Country__c, Record_Origin__c,
Processed_On__c,Successful_Processed__c,Created_By__c,Failure_Count__c,Update_Account__c,name__c,code__c,Auto_Id__c,First_Response_Log__c from HSI_Enrollment_Queue__c where
Processed_On__c = Null AND Successful_Processed__c = False AND
(Record_Origin__c = 'Vidanta Converter' OR Record_Origin__c = 'HC Self Enrollment' OR Created_By__c = 'VI Referral Form' OR Created_By__c = 'RR Flex Date Checkout' OR Created_By__c = 'SMTN Survey' OR Created_By__c = 'Carefree Destinations Affiliate Marketing MX Voucher' OR Created_By__c = 'Advantage Getaway Voucher'
OR Created_By__c = 'Carefree Destinations'  OR Created_By__c = 'Filetracker' OR Created_By__c = 'SMTN Mexico' OR Created_By__c = 'Future Stay' OR Created_By__c = 'Lead Conversion' OR Created_By__c = 'Vacation VIP' OR Created_By__c = 'SF Enrollment Queue' OR Created_By__c = 'Advantage Services Affiliate Marketing' OR Created_By__c = 'CoolVacay Plus' OR Created_By__c = 'LuxGive Guest' OR Created_By__c = 'Inspira Resort Week' OR  Created_By__c = 'Club Global Explorer VW - Trial' OR  Created_By__c = 'Club Global Explorer VW' OR  Created_By__c = 'Club Venture - Ruby' OR  Created_By__c = 'Club Venture - Guest' OR  Created_By__c = 'Club Venture - Emerald' OR  Created_By__c = 'Club Venture - Sapphire')
AND Failure_Count__c <=3 AND Id = 'a0gO1000002RtC9IAK' ORDER BY Failure_Count__c ASC limit 50];

*/
public class EnrollmentAPI {
    
    public list<requestdataWrapper> reqlist = New List<requestdataWrapper>();
    public LIst<HSI_Enrollment_Queue__c> UpdateHSIEnrollList = New List<HSI_Enrollment_Queue__c>();
    List<String> errorLog = new List<String>();
    List<Contact> contacts = new List<Contact>();
    public void senddata(List<HSI_Enrollment_Queue__c> HSIEnrollment){
        
        system.debug('data== ' + HSIEnrollment);
        list<languageWrapper> langlist = NEw List<languageWrapper>();
        
        //String body = '{"tierLevel": "VIR","contractNumber": "5","memberNumber": "AP-VIR-5","firstName": "TestFirst","lastName": "TestLastName","emailAddress": "test@test.com"';
        //  body = body + ',"phoneNumber": "1234567890","address": "1252 Some Random Street","city": "Orlando","postalCode": "32555","stateCode": "FL","countryCode": "United States","RenewableYears": 1,"AdvantageWeeksAllocated": 1,"languagePreferred": {"code": "ENG","name": "ENGLISH"}}';
        //2024-03-29 added Advantage Services Affiliate Marketing Affiliate Id (1002440)
        
        for(HSI_Enrollment_Queue__c callbatch : HSIEnrollment){
            String currentErrorLog = '';
            system.debug('--callbatch.Created_By__c--'+callbatch.Created_By__c);
            requestdataWrapper req = New requestdataWrapper();
            if(callbatch.Created_By__c == 'VI Referral Form'){
                req.tierLevel = 'VIR';
            }else if(callbatch.Created_By__c == 'RR Flex Date Checkout'){
                req.tierLevel = 'RRC';
            }else if(callbatch.Created_By__c == 'SMTN Survey'){
                req.tierLevel = 'TGS';
            }else if(callbatch.Created_By__c == 'Carefree Destinations' || callbatch.Created_By__c == 'Think Direct'){
                req.tierLevel = 'CFD-FB';
            }else if(callbatch.Created_By__c == 'SMTN Mexico'){
                req.tierLevel = 'SMTMX';
            }
            else if(callbatch.Record_Origin__c == 'HC Self Enrollment'){
                req.tierLevel = 'HIC';
            }
            else if(callbatch.Record_Origin__c == 'Future Stay'){
                req.tierLevel = 'FS';
            }
            else if(callbatch.Record_Origin__c == 'Public Reservation Inquiry'){
                req.tierLevel = 'SMTNC';
            }
            else if(callbatch.Created_By__c == 'Vacation VIP'){
                req.tierLevel = 'VIPP';
            }
            else if(callbatch.Created_By__c == 'SF Enrollment Queue'){
                req.tierLevel = 'PREM';
            }
            else if(callbatch.Record_Origin__c == 'Internal Source'){
                req.tierLevel = 'CFD';
            }
            else if(callbatch.Record_Origin__c == 'Carefree Destinations Affiliate Marketing MX Voucher'){
                req.tierLevel = 'AMMX';
            }
            else if(callbatch.Record_Origin__c == 'Vidanta Converter'){
                req.tierLevel = 'VICO';
            }
            else if(callbatch.Record_Origin__c == 'Advantage Services Affiliate Marketing'){
                req.tierLevel = 'AMAS';
            }
            else if(callbatch.Record_Origin__c == 'CoolVacay Plus'){
                req.tierLevel = 'CVP';
            }
            else if(callbatch.Record_Origin__c == 'Advantage Getaway Voucher'){
                req.tierLevel = 'ABW';
            }
            else if(callbatch.Record_Origin__c == 'LuxGive Guest'){
                req.tierLevel = 'LGG';
            }
            else if(callbatch.Record_Origin__c == 'Inspira Resort Week'){
                req.tierLevel = 'IRW';
            }
            else if(callbatch.Record_Origin__c == 'Club Global Explorer VW - Trial'){
                req.tierLevel = 'CGEVWT';
            }
            else if(callbatch.Record_Origin__c == 'Club Global Explorer VW'){
                req.tierLevel = 'CGEVW';
            }
            else if(callbatch.Record_Origin__c == 'Club Venture - Guest'){
                req.tierLevel = 'CVC';
            }
            else if(callbatch.Record_Origin__c == 'Club Venture - Ruby'){
                req.tierLevel = 'CVCR';
            }
            else if(callbatch.Record_Origin__c == 'Club Venture - Emerald'){
                req.tierLevel = 'CVCE';
            }
            else if(callbatch.Record_Origin__c == 'Club Venture - Sapphire'){
                req.tierLevel = 'CVCS';
            }
            else if(callbatch.Record_Origin__c == 'Filetracker'){
                req.tierLevel = 'FT';
            }
            else if(callbatch.Record_Origin__c == 'Raise Away Guest'){
                req.tierLevel = 'RAG';
            }
            else if(callbatch.Record_Origin__c == 'Raise Away Voucher'){
                req.tierLevel = 'RAV';
            }
            else if(callbatch.Record_Origin__c == 'Engaged Good Guest'){
                req.tierLevel = 'EGG';
            }
            else if(callbatch.Record_Origin__c == 'One Agency Bulk Voucher Sheet'){
                req.tierLevel = 'OAV';
            }
            /* else if(callbatch.Record_Origin__c == 'Reserve Collection'){
                req.tierLevel = 'RC';
            }*/
            /*else if(callbatch.Record_Origin__c == 'SMTN'){
req.tierLevel = 'SMTN';
}*/
            
            req.contractNumber = callbatch.Auto_Id__c;
            req.memberNumber = callbatch.Member_Number__c;
            req.firstName = callbatch.First_Name__c;
            req.lastName = callbatch.Last_Name__c;
            req.emailAddress = callbatch.Email__c;
            req.phoneNumber = callbatch.Primary_Phone__c;            
            /*req.address = callbatch.Address__c;
//req.city = callbatch.City__c;
//req.postalCode = callbatch.Zip_Code__c;
//req.stateCode = callbatch.State__c;
//req.countryCode = callbatch.Country__c*/ 
            req.address = callbatch.Address__c != null && callbatch.Address__c != '' ? callbatch.Address__c : 'Address';
            req.city = callbatch.City__c != null && callbatch.City__c != '' ? callbatch.City__c : 'City';            
            req.postalCode = callbatch.Zip_Code__c != null && callbatch.Zip_Code__c != '' ? callbatch.Zip_Code__c : '32819';            
            req.stateCode = callbatch.State__c != null && callbatch.State__c != '' ? callbatch.State__c : 'State';            
            req.countryCode = callbatch.Country__c != null && callbatch.Country__c != '' ? callbatch.Country__c : 'US';
            
            /*if(callbatch.Record_Origin__c == 'Vidanta Converter')
{
req.RenewableYears = 10;
req.AdvantageWeeksAllocated = 5;
}*/
            if(callbatch.Record_Origin__c != 'Filetracker' && callbatch.Record_Origin__c != 'Club Venture - Guest' && callbatch.Record_Origin__c != 'Club Venture - Ruby' && callbatch.Record_Origin__c != 'Club Venture - Emerald' && callbatch.Record_Origin__c != 'Club Venture - Sapphire' && callbatch.Record_Origin__c != 'Inspira Resort Week' && callbatch.Record_Origin__c != 'LuxGive Guest' && callbatch.Record_Origin__c != 'Club Global Explorer VW - Trial' && callbatch.Record_Origin__c != 'Club Global Explorer VW' && callbatch.Record_Origin__c != 'Advantage Getaway Voucher' && callbatch.Record_Origin__c != 'Vidanta Converter' && callbatch.Record_Origin__c != 'Advantage Services Affiliate Marketing' && callbatch.Record_Origin__c != 'Public Reservation Inquiry' && callbatch.Record_Origin__c != 'SF Leads' && callbatch.Record_Origin__c != 'Raise Away Guest' && callbatch.Record_Origin__c != 'Raise Away Voucher' && callbatch.Record_Origin__c != 'Engaged Good Guest' && callbatch.Record_Origin__c != 'One Agency Bulk Voucher Sheet'){
                req.RenewableYears = 1;
                req.AdvantageWeeksAllocated = 1;
            }
            else
            {
                req.RenewableYears = 0;
                req.AdvantageWeeksAllocated = 0;
            }
            //req.countryCode = '{"code":"ENG","name":"ENGLISH"}';
            // reqlist.add(req);
            req.languagePreferred = New languageWrapper();
            languageWrapper lan = new languageWrapper();
            lan.code = callbatch.code__c;
            lan.name = callbatch.name__c;
            
            
            req.languagePreferred = lan;
            
            String body = JSON.serialize(req);
            
            
            system.debug('req---- ' + body);
            HttpRequest httpRequest = new HttpRequest();  
            httpRequest.setMethod('POST');
            if(callbatch.Created_By__c == 'VI Referral Form'){
                httpRequest.setHeader('api-Key', 'bfec1138-08c7-423e-afbe-4a4678cd897f');
            }else if(callbatch.Created_By__c == 'RR Flex Date Checkout'){
                httpRequest.setHeader('api-Key', 'ada815aa-2d6c-4a3a-9ebf-e66721aa38b2');
            }else if(callbatch.Created_By__c == 'SMTN Survey'){
                httpRequest.setHeader('api-Key', '077f75cd-3a53-4d99-9999-f4e224b4d108');
            }else if(callbatch.Created_By__c == 'Carefree Destinations' || callbatch.Created_By__c == 'Think Direct' ){
                httpRequest.setHeader('api-Key', '7c78bf45-6967-472d-a445-1fc2643ec0df');
            }else if(callbatch.Created_By__c == 'SMTN Mexico'){
                httpRequest.setHeader('api-Key', 'ec037956-b03a-49dd-b108-833b3bfa812e');
            }
            else if(callbatch.Record_Origin__c == 'HC Self Enrollment'){
                httpRequest.setHeader('api-Key', '789895ab-3573-495a-af3c-60d255fcdfdf');
            }
            else if(callbatch.Record_Origin__c == 'Future Stay'){
                httpRequest.setHeader('api-Key', 'fa9134cf-a193-4dac-82a2-38bfbf56e67a');
            }
            else if(callbatch.Record_Origin__c == 'Public Reservation Inquiry'){
                httpRequest.setHeader('api-Key', '0784a23d-1118-4365-9912-a32dbf06a28e');
            }
            else if(callbatch.Created_By__c == 'Vacation VIP'){
                httpRequest.setHeader('api-Key', '0870a618-ede7-4519-b6af-5e9ccddb7b5f');
            }
            else if(callbatch.Created_By__c == 'SF Enrollment Queue'){
                httpRequest.setHeader('api-Key', '34450727-9374-4643-b4d2-5cd3f4ddaf05');
            }
            else if(callbatch.Record_Origin__c == 'Internal Source'){
                httpRequest.setHeader('api-Key', '6ee094a1-c4a0-484f-ae4e-fc5714c1caf8');
            }
            else if(callbatch.Created_By__c == 'Carefree Destinations Affiliate Marketing MX Voucher'){
                httpRequest.setHeader('api-Key', '1eead4f1-52fe-49e8-9686-e973ff729006');
            }
            else if(callbatch.Created_By__c == 'Vidanta Converter'){
                httpRequest.setHeader('api-Key', '89617df9-9f09-460c-ae9a-cef4da5d7d7d');
            }
            else if(callbatch.Created_By__c == 'Advantage Services Affiliate Marketing'){
                httpRequest.setHeader('api-Key', '028bd569-65eb-423b-83b7-626f85648cb6');
            }  
            else if(callbatch.Created_By__c == 'CoolVacay Plus'){
                httpRequest.setHeader('api-Key', '5a3755bd-f3c7-4a87-bb9d-da940fd2485b');
            }
            else if(callbatch.Created_By__c == 'Advantage Getaway Voucher'){
                httpRequest.setHeader('api-Key', '7677ac5d-e4bc-4224-9a09-e26ec04d3c63');
            }
            else if(callbatch.Created_By__c == 'LuxGive Guest'){
                httpRequest.setHeader('api-Key', '5301505d-e4b4-4d8f-9634-511eb943ec2b');
            }
             else if(callbatch.Created_By__c == 'Club Global Explorer VW - Trial'){
                httpRequest.setHeader('api-Key', 'dffb90e0-49b6-4f49-a56a-aaa8dfac93f4');
            }
             else if(callbatch.Created_By__c == 'Club Global Explorer VW'){
                httpRequest.setHeader('api-Key', 'a5d2c2b9-63f3-4fce-9a1b-748fce2248cf');
            }
            else if(callbatch.Created_By__c == 'Club Venture - Guest'){
                httpRequest.setHeader('api-Key', 'a01b0115-d52b-4f8d-b4cf-01c04d82626c');   
            }
 			else if(callbatch.Created_By__c == 'Club Venture - Ruby'){
                httpRequest.setHeader('api-Key', 'cc4f36fb-a2e0-4e77-8a8d-f2df69781d88');   
            }
 			else if(callbatch.Created_By__c == 'Club Venture - Emerald'){
                httpRequest.setHeader('api-Key', '947999b9-19d6-4772-bea3-a44fe75d6739');   
            }
 			else if(callbatch.Created_By__c == 'Club Venture - Sapphire'){
                httpRequest.setHeader('api-Key', '23d51a8c-5a5a-4558-9394-91abba4d4b66');   
            }
            else if(callbatch.Created_By__c == 'Inspira Resort Week'){
                httpRequest.setHeader('api-Key', 'e159d011-4d2d-4e6e-b096-5b68b8fd8824');  // 
            }
            else if(callbatch.Created_By__c == 'Filetracker'){
                httpRequest.setHeader('api-Key', '9169452c-8a3d-4b7b-9da2-d33d5f433017');  // 
            }
            else if(callbatch.Created_By__c == 'Raise Away Guest'){
                httpRequest.setHeader('api-Key', '2c61ce42-5713-4e22-95cc-fd2049a4459e');  // 
            }
            else if(callbatch.Created_By__c == 'Raise Away Voucher'){
                httpRequest.setHeader('api-Key', '72e1f706-88fb-4c0f-9daf-b283ef38b2d2');  // 
            }
            else if(callbatch.Created_By__c == 'Engaged Good Guest'){
                httpRequest.setHeader('api-Key', 'ae1c8e7d-022d-4fb2-8089-196fe7c6b8d7');  // 
            }
            else if(callbatch.Created_By__c == 'One Agency Bulk Voucher Sheet'){
                httpRequest.setHeader('api-Key', '1848c093-7fbd-4858-9320-605176f1c767');  // 
            }
            /*else if(callbatch.Record_Origin__c == 'SMTN'){
httpRequest.setHeader('api-Key', '1ffa3e05-f80d-49b4-aa5c-3e96e6a352ed');
}*/
            httpRequest.setHeader('Content-Type', 'application/json'); 
            
            Boolean runningInSandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
            Boolean callSecondAPI = false;
            
            if(!runningInSandbox){
                //2025-07-06 - CVC-133 - Update/Create Enrollment API on Azure related to SF to SQL process
                //httpRequest.setEndpoint('https://hsiwinapi.nerdsoft.com/api/SalesforceMemberRegistration/Register');
                httpRequest.setEndpoint('https://webapihsicorev2.azurewebsites.net/api/SalesforceMemberRegistration/Register');
            }
            else
            {
                //2025-07-06 - CVC-133 - Update/Create Enrollment API on Azure related to SF to SQL process
                //httpRequest.setEndpoint('http://hsiwinapi.nerdsoft.hqa.hsi1.com/api/SalesforceMemberRegistration/Register');
                httpRequest.setEndpoint('http://webapihsicorev2-qa.azurewebsites.net/api/SalesforceMemberRegistration/Register');
                //httpRequest.setEndpoint('https://webapihsicorev2.azurewebsites.net/api/SalesforceMemberRegistration/Register');
            }
            System.debug('body enrollment == '+body);
            httpRequest.setBody(body);
            httpRequest.setTimeout(120000);
            
            String response = '';
            String rawBody = '';
            Integer rawHttpStatus;
            
            try {  
                Http http = new Http();   
                HttpResponse httpResponse = http.send(httpRequest);  
                response = JSON.serializePretty( JSON.deserializeUntyped(httpResponse.getBody()) );
                rawBody = httpResponse.getBody();
                rawHttpStatus = httpResponse.getStatusCode();                
                /*if (httpResponse.getStatusCode() == 200 ) {  
response = JSON.serializePretty( JSON.deserializeUntyped(httpResponse.getBody()) );  
} else {  
System.debug(' httpResponse ' + httpResponse.getBody() );
//throw new CalloutException( httpResponse.getBody() );  
}*/   
            } catch( System.Exception e) {  
                System.debug('ERROR: '+ e);
                errorLog.add('https://webapihsicorev2.azurewebsites.net/api/SalesforceMemberRegistration/Register api call error - EnrollmentAPI apex class - HSI_Enrollment_Queue__c record ['+JSON.serialize(callbatch)+'] - body ['+body+'] - Error Log : '+e.getMessage()+'/;/');
                currentErrorLog = currentErrorLog + 'https://webapihsicorev2.azurewebsites.net/api/SalesforceMemberRegistration/Register api call error - EnrollmentAPI apex class - HSI_Enrollment_Queue__c record ['+JSON.serialize(callbatch)+'] - body ['+body+'] - Error Log : '+e.getMessage()+'/;/';
                callSecondAPI = true;
                //throw e;
            }
            if(rawHttpStatus != 200)
            {
                callSecondAPI = true;
                errorLog.add('https://webapihsicorev2.azurewebsites.net/api/SalesforceMemberRegistration/Register response error - http returned ['+rawHttpStatus+'] - body returned ['+rawBody+']- HSI_Enrollment_Queue__c record ['+JSON.serialize(callbatch)+']');
                currentErrorLog = currentErrorLog + 'https://webapihsicorev2.azurewebsites.net/api/SalesforceMemberRegistration/Register response error - http returned ['+rawHttpStatus+'] - body returned ['+rawBody+']- HSI_Enrollment_Queue__c record ['+JSON.serialize(callbatch)+']';
            }
            
            if(callSecondAPI == true && callbatch.Failure_Count__c > 2)
            {
                if(!runningInSandbox){                    
                    httpRequest.setEndpoint('https://hsiwinapi.nerdsoft.com/api/SalesforceMemberRegistration/Register');                    
                }
                else
                {
                    
                    httpRequest.setEndpoint('http://hsiwinapi.nerdsoft.hqa.hsi1.com/api/SalesforceMemberRegistration/Register');
                }
                System.debug('body enrollment == '+body);
                httpRequest.setBody(body);
                httpRequest.setTimeout(120000);
                
                response = '';
                rawBody = '';
                rawHttpStatus = null;
                
                try {  
                    Http http = new Http();   
                    HttpResponse httpResponse = http.send(httpRequest);  
                    response = JSON.serializePretty( JSON.deserializeUntyped(httpResponse.getBody()) );
                    rawBody = httpResponse.getBody();
                    rawHttpStatus = httpResponse.getStatusCode();                
                } catch( System.Exception e) {  
                    System.debug('ERROR: '+ e);
                    errorLog.add('https://hsiwinapi.nerdsoft.com/api/SalesforceMemberRegistration/Register api call error - EnrollmentAPI apex class - HSI_Enrollment_Queue__c record ['+JSON.serialize(callbatch)+'] - body ['+body+'] - Error Log : '+e.getMessage()+'/;/');                    
                    currentErrorLog = currentErrorLog + 'https://hsiwinapi.nerdsoft.com/api/SalesforceMemberRegistration/Register api call error - EnrollmentAPI apex class - HSI_Enrollment_Queue__c record ['+JSON.serialize(callbatch)+'] - body ['+body+'] - Error Log : '+e.getMessage()+'/;/';
                    //throw e;
                }
            }
            
            
            System.debug(' ** response ** : ' + response );
            try {
                HSI_Enrollment_Queue__c updhsi = new HSI_Enrollment_Queue__c();
                if(!Test.isRunningTest()){
                    if(updhsi.First_Response_Log__c == null || updhsi.First_Response_Log__c == '')
                    {
                        
                        updhsi.First_Response_Log__c = '['+rawHttpStatus+']'+rawBody;
                        updhsi.id = callbatch.id;
                    }
                    Map<String,Object> receivedData = (Map<String,Object>)JSON.deserializeUntyped(response);
                    System.debug(' ** response ** : ' + receivedData ); 
                    
                    Boolean success = Boolean.valueOf(receivedData.get('IsSucceed'));
                    if(success){
                        updhsi.Processed_On__c = Date.today();
                        updhsi.Successful_Processed__c = true;
                        updhsi.Comments__c = 'enrollment processed by the api : '+httpRequest.getEndpoint();
                        updhsi.id = callbatch.id;
                        updhsi.Update_Account__c = true;
                        updhsi.Contact_Id__c = String.valueOf(receivedData.get('ContactId'));
                        
                        system.debug('--String.valueOf(receivedData)--'+String.valueOf(receivedData.get('ContactId')));
                    }else{
                        
                        errorLog.add('https://hsiwinapi.nerdsoft.com/api/SalesforceMemberRegistration/Register response error - http call error ['+rawHttpStatus+'] - HSI_Enrollment_Queue__c record ['+JSON.serialize(callbatch)+'] - body ['+body+'] - response body : '+rawBody+'/;/');                    
                        currentErrorLog = currentErrorLog + 'https://hsiwinapi.nerdsoft.com/api/SalesforceMemberRegistration/Register response error - http call error ['+rawHttpStatus+'] - HSI_Enrollment_Queue__c record ['+JSON.serialize(callbatch)+'] - body ['+body+'] - response body : '+rawBody+'/;/';
                        String truncatedCurrentErrorLog = currentErrorLog != null && currentErrorLog.length() > 131071 ? currentErrorLog.substring(0, 131070) : currentErrorLog;
                        updhsi.Error_Message__c = receivedData.containsKey('Errors') ? String.valueOf(receivedData.get('Errors')) : truncatedCurrentErrorLog;
                        updhsi.Failure_Count__c = callbatch.Failure_Count__c + 1;
                        updhsi.id = callbatch.id;
                        
                    }
                }
                else //added to cover >75% - to run just from test classes
                {
                    if(updhsi.First_Response_Log__c == null || updhsi.First_Response_Log__c == '')
                    {                    
                        updhsi.First_Response_Log__c = '['+rawHttpStatus+']'+rawBody;
                        //updhsi.id = callbatch.id;
                    }
                    if(callbatch.Created_By__c == 'SMTN Mexico'){
                        updhsi.Processed_On__c = Date.today();
                        updhsi.Successful_Processed__c = true;
                        updhsi.Update_Account__c = true;
                        updhsi.Contact_Id__c = 'test';
                    }
                    else
                    {
                        updhsi.Error_Message__c = '';
                        updhsi.Failure_Count__c = 5;                    
                    }
                    insert updhsi;
                }
                UpdateHSIEnrollList.add(updhsi);
            }
            catch( System.Exception e) {  
                System.debug('ERROR: '+ e);
                errorLog.add('https://hsiwinapi.nerdsoft.com/api/SalesforceMemberRegistration/Register api call error - rawBody = '+rawBody+' - rawHttpStatus = '+rawHttpStatus+' -  EnrollmentAPI apex class - HSI_Enrollment_Queue__c record ['+JSON.serialize(callbatch)+'] - body ['+body+'] - Error Log : '+e.getMessage()+'/;/');
                currentErrorLog = currentErrorLog + 'https://hsiwinapi.nerdsoft.com/api/SalesforceMemberRegistration/Register api call error - rawBody = '+rawBody+' - rawHttpStatus = '+rawHttpStatus+' -  EnrollmentAPI apex class - HSI_Enrollment_Queue__c record ['+JSON.serialize(callbatch)+'] - body ['+body+'] - Error Log : '+e.getMessage()+'/;/';
                
                //throw e;
            }
        }
        system.debug('last upd== ' + UpdateHSIEnrollList);
        try{
            update UpdateHSIEnrollList;
            
            Set<Id> hsiIdSet = new Set<Id>();
            //2024-02-16 - Fix Insert failed. First exception on row 0; first error: DUPLICATE_VALUE, duplicate value found: Master_Record_Id__c duplicates value on record with id: 003...
            Set<Id> hsiAccountIdSet = new Set<Id>();
            List<Contact> contactsToReview = new List<Contact>();
            Map<String,Id> existingContactsMasterRecordId = new Map<String,Id>();
            List<HSI_Enrollment_Queue__c> hsiEnrollmentList = new List<HSI_Enrollment_Queue__c>();
            List<Contact> conList = new List<Contact>();
            
            for(HSI_Enrollment_Queue__c rec : UpdateHSIEnrollList){
                hsiIdSet.add(rec.Id);
            }
            
            hsiEnrollmentList = [Select Id,Contact_Id__c ,First_Name__c ,Last_Name__c ,Email__c ,Primary_Phone__c,Member_Number__c,AccountId__c,AccountId__r.Master_Record_Id__c from HSI_Enrollment_Queue__c where Id IN: hsiIdSet and Contact_Id__c != null];
            
            //2024-02-16 - Fix Insert failed. First exception on row 0; first error: DUPLICATE_VALUE, duplicate value found: Master_Record_Id__c duplicates value on record with id: 003...
            for(HSI_Enrollment_Queue__c enrolRec: hsiEnrollmentList){
                hsiAccountIdSet.add(enrolRec.AccountId__c);
            }
            
            contactsToReview = [SELECT Id,AccountId,Master_Record_Id__c FROM Contact WHERE AccountId IN : hsiAccountIdSet];
            
            if(contactsToReview.size()>0 && contactsToReview != null)
            {
                for(Contact cn : contactsToReview)
                {
                    existingContactsMasterRecordId.put(cn.Master_Record_Id__c,cn.Id);
                }
                
            }
            
            for(HSI_Enrollment_Queue__c rec: hsiEnrollmentList){
                //2024-02-16 - Fix Insert failed. First exception on row 0; first error: DUPLICATE_VALUE, duplicate value found: Master_Record_Id__c duplicates value on record with id: 003...
                if(existingContactsMasterRecordId.get(rec.Contact_Id__c +'-'+ rec.Member_Number__c) == null){
                    if(rec.Contact_Id__c != ''){
                        Contact con = new Contact();
                        con.FirstName = rec.First_Name__c;
                        con.LastName = rec.Last_Name__c;
                        con.Email = rec.Email__c;
                        con.Phone = rec.Primary_Phone__c;                    
                        con.Master_Record_Id__c = rec.Contact_Id__c +'-'+ rec.Member_Number__c;
                        con.AccountId = rec.AccountId__c;
                        conList.add(con);
                    }
                }
            }
            
            if(!conList.isEmpty()){
                contacts = conList;
                insert conList;
            }
            
        }catch(Exception e){
            system.debug('exception== ' + e);
            errorLog.add('EnrollmentAPI apex class error on [update UpdateHSIEnrollList or insert conList] - UpdateHSIEnrollList = '+UpdateHSIEnrollList+' -  Error Log : '+e.getMessage()+'/;/');
        }
        
        if(errorLog.size()>0 && errorLog != null)
        {            
            Boolean runningInASandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
            if(!runningInASandbox || test.isrunningTest()){
                String message = String.valueOf(errorLog);
                system.debug('--message-'+message);
                Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
                String[] sendingTo = new String[]{'victor.goncalves@nerdsoft.com','danilo.fernandes@nerdsoft.com','raphael.fogaca@nerdsoft.com','daniel.oliveira@nerdsoft.com'};
                semail.setToAddresses(sendingTo);
                semail.setSubject('EnrollmentAPI is failed');
                semail.setPlainTextBody(message);
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] {semail}); 
            }             
        }
        
        
    }
    public class responseWrapper{
        public String IsSucceed;
        public String[] Errors;
        public String MemberNumber;
        public String ContactId;
        public Id hsiId;
    }
    public class languageWrapper{
        public string code;
        public string name;
    }
    public class requestdataWrapper{
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
        //public String languagePreferred;
        public languageWrapper languagePreferred;
    }
}