public with sharing class GetEmailData {
    
   @AuraEnabled(cacheable=false)
    public static String sendRequest(Id recordId, Integer page) {

        String finalResult = '';
        Integer totalPages = 99999;
 

            try {
    
    			//for testing only (production Id):
    			//recordId = '006Vm00000YLmfQIAT';
                
                system.debug('Entered sendRequest');
                
                Boolean runningInASandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
                String endpoint = '';
                if(runningInASandbox){
                    endpoint = 'https://webapihsicorev2.azurewebsites.net/api/SalesforceStorage/GetEmail';      //PROD
     //               endpoint = 'https://webapihsicorev2-qa.azurewebsites.net/api/SalesforceStorage/GetEmail';      //QA
    //                endpoint = 'https://webapihsicorev2-staging2.azurewebsites.net/api/SalesforceStorage/GetEmail';  //Staging
                }
                else{
                    endpoint = 'https://webapihsicorev2.azurewebsites.net/api/SalesforceStorage/GetEmail';
                }

                // Construct the endpoint with the query parameter
                endpoint = endpoint + '?SfObjectId=' + EncodingUtil.urlEncode(recordId, 'UTF-8') + '&page=' + page + '&limit=10'; 

                
                system.debug('endpoint=' + endpoint);
                            
                Http http = new Http();
                HttpRequest request = new HttpRequest();
                request.setEndpoint(endpoint); // API endpoint
                request.setMethod('GET');
                request.setHeader('Content-Type', 'application/json');
                request.setTimeout(30000); // 30 seconds
                
                System.debug('HTTP Request: ' + request.getEndpoint());
                System.debug('HTTP Body: ' + request.getBody());
    
                
                // Send request
                HttpResponse response = http.send(request);
                if (response.getStatusCode() == 200) {
 
                    String responseBody = response.getBody();
                    finalResult+=responseBody; // Append data

                    System.debug('responseBody: ' + responseBody);

                    // Parse the response to get TotalPages
                    Map<String, Object> parsedResponse = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
                    if (parsedResponse.containsKey('Result')) {
                        Map<String, Object> result = (Map<String, Object>) parsedResponse.get('Result');
                        if (result.containsKey('TotalPages')) {
                            totalPages = Integer.valueOf(result.get('TotalPages')); // Update totalPages from response
                            system.debug('TotalPages: ' + totalPages);
                        }
                    }

                    page++;
                    
                    return response.getBody(); // Return response as string
                } else {
                    throw new CalloutException('Error: ' + response.getStatus() + ' - ' + response.getBody());
                }
            } catch (Exception e) {
                System.debug('e.getMessage(): ' + e.getMessage());
                throw new AuraHandledException('Failed to call API: ' + e.getMessage());
            }
        }
        
    
      @AuraEnabled(cacheable=false)
    public static String sendRequestAcoustic(Id recordId, Integer page) {

        String finalResult = '';
        Integer totalPages = 99999;
 

            try {
    
    
                system.debug('Entered sendRequest Acoustic');
                
                Boolean runningInASandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
                String endpoint = '';
                if(runningInASandbox){
                    endpoint = 'https://webapihsicorev2.azurewebsites.net/api/SalesforceStorage/GetAcoustic';  //Prod
                    //endpoint = 'https://webapihsicorev2-qa.azurewebsites.net/api/SalesforceStorage/GetAcoustic';      //QA
    //                endpoint = 'https://webapihsicorev2-staging2.azurewebsites.net/api/SalesforceStorage/GetAcoustic';  //Staging
                }
                else{
                    endpoint = 'https://webapihsicorev2.azurewebsites.net/api/SalesforceStorage/GetAcoustic';  //Prod
                }
                
                
                String prefix = String.valueOf(recordId).substring(0, 3);
                
                if (prefix == '00Q') {
                    // 'Lead'
                    endpoint = endpoint + '?leadId=' + EncodingUtil.urlEncode(recordId, 'UTF-8') + '&page=' + page + '&limit=10';  
                } else if (prefix == '003') {
                    // 'Contact';
                    endpoint = endpoint + '?contactId=' + EncodingUtil.urlEncode(recordId, 'UTF-8') + '&page=' + page + '&limit=10';  
                } else if (prefix == '001') {
                    // 'Account';
                    endpoint = endpoint + '?sfObjectId=' + EncodingUtil.urlEncode(recordId, 'UTF-8') + '&page=' + page + '&limit=10';  
                } else {
                    endpoint = endpoint + '?sfObjectId=' + EncodingUtil.urlEncode(recordId, 'UTF-8') + '&page=' + page + '&limit=10';  
                }
                
                
                // Construct the endpoint with the query parameter
//                endpoint = endpoint + '?SfObjectId=' + EncodingUtil.urlEncode(recordId, 'UTF-8') + '&page=' + page + '&limit=10'; 
                //endpoint = endpoint + '?leadId=' + EncodingUtil.urlEncode('00Q4z000021kDKpEAM', 'UTF-8') + '&page=' + page + '&limit=10';  //test <<<<<<<<<<<<<<<
 
                
                system.debug('endpoint=' + endpoint);
                            
                Http http = new Http();
                HttpRequest request = new HttpRequest();
                request.setEndpoint(endpoint); // API endpoint
                request.setMethod('GET');
                request.setHeader('Content-Type', 'application/json');
                request.setTimeout(30000); // 30 seconds

                System.debug('HTTP Request: ' + request.getEndpoint());
                System.debug('HTTP Body: ' + request.getBody());
    
                
                // Send request
                HttpResponse response = http.send(request);
                if (response.getStatusCode() == 200) {
 
                    String responseBody = response.getBody();
                    finalResult+=responseBody; // Append data

                    System.debug('responseBody: ' + responseBody);

                    // Parse the response to get TotalPages
                    Map<String, Object> parsedResponse = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
                    if (parsedResponse.containsKey('Result')) {
                        Map<String, Object> result = (Map<String, Object>) parsedResponse.get('Result');
                        if (result.containsKey('TotalPages')) {
                            totalPages = Integer.valueOf(result.get('TotalPages')); // Update totalPages from response
                            system.debug('TotalPages: ' + totalPages);
                        }
                    }

                    page++;
                    
                    return response.getBody(); // Return response as string
                } else {
                    throw new CalloutException('Error: ' + response.getStatus() + ' - ' + response.getBody());
                }
            } catch (Exception e) {
                System.debug('e.getMessage(): ' + e.getMessage());
                throw new AuraHandledException('Failed to call API: ' + e.getMessage());
            }
        }

    
        
      @AuraEnabled(cacheable=false)
    public static String sendRequestInvoice(Id recordId, Integer page) {

        String finalResult = '';
        Integer totalPages = 99999;
 

            try {
    
    
                system.debug('Entered sendRequest Invoice');
                
                Boolean runningInASandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
                String endpoint = '';
                if(runningInASandbox){
					endpoint = 'https://webapihsicorev2.azurewebsites.net/api/SalesforceStorage/GetInvoiceMailing';      //Prod
                    //endpoint = 'https://webapihsicorev2-qa.azurewebsites.net/api/SalesforceStorage/GetInvoiceMailing';      //QA
    //                endpoint = 'https://webapihsicorev2-staging2.azurewebsites.net/api/SalesforceStorage/GetInvoiceMailing';  //Staging
                } 
                else{
                    endpoint = 'https://webapihsicorev2.azurewebsites.net/api/SalesforceStorage/GetInvoiceMailing';      //Prod
                }  
                  
                String MemberNumber;
                String prefix = String.valueOf(recordId).substring(0, 3);
                
                if (Test.isRunningTest()) {
                    System.debug('This code is running in a test execution.');
                	endpoint = 'https://webapihsicorev2.azurewebsites.net/api/SalesforceStorage/GetInvoiceMailing?page=1&limit=10&memberNumber=AP-CBRSRRA-418132';
                } else {
                    if (prefix == '003') {
                        // 'Contact';
                        MemberNumber = [SELECT Member_Number__c FROM Contact WHERE id = :recordId ].Member_Number__c;
                    } else if (prefix == '001') {
                        // 'Account';
                        MemberNumber = [SELECT Member_Number__c FROM Account WHERE id = :recordId ].Member_Number__c;
                    }
                    endpoint = endpoint + '?memberNumber=' + EncodingUtil.urlEncode(MemberNumber, 'UTF-8') + '&page=' + page + '&limit=10';  
                } 
                
                 
                system.debug('endpoint=' + endpoint);
                            
                Http http = new Http();
                HttpRequest request = new HttpRequest();
                request.setEndpoint(endpoint); // API endpoint
                request.setMethod('GET');
                request.setHeader('Content-Type', 'application/json');
                request.setTimeout(30000); // 30 seconds

                System.debug('HTTP Request: ' + request.getEndpoint());
                System.debug('HTTP Body: ' + request.getBody());
    
                
                // Send request
                HttpResponse response = http.send(request);
                if (response.getStatusCode() == 200) {
 
                    String responseBody = response.getBody();
                    finalResult+=responseBody; // Append data

                    System.debug('responseBody: ' + responseBody);

/*
                    // Parse the response to get TotalPages
                    Map<String, Object> parsedResponse = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
                    if (parsedResponse.containsKey('Result')) {
                        Map<String, Object> result = (Map<String, Object>) parsedResponse.get('Result');
                        if (result.containsKey('TotalPages')) {
                            totalPages = Integer.valueOf(result.get('TotalPages')); // Update totalPages from response
                            system.debug('TotalPages: ' + totalPages);
                        }
                    }
*/
                    
                   // try {
                        Map<String, Object> parsedResponse = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
                        
                        // Retrieve TotalPages directly
                        if (parsedResponse.containsKey('TotalPages')) {
                            totalPages = Integer.valueOf(parsedResponse.get('TotalPages'));
                            System.debug('TotalPages: ' + totalPages);
                        }
                        
                        // Retrieve CurrentPage if needed
                        if (parsedResponse.containsKey('CurrentPage')) {
                            Integer currentPage = Integer.valueOf(parsedResponse.get('CurrentPage'));
                            System.debug('CurrentPage: ' + currentPage);
                        }
                        
                        // Retrieve Items array
                        if (parsedResponse.containsKey('Items')) {
                            List<Object> items = (List<Object>) parsedResponse.get('Items');
                            System.debug('Items: ' + items);
                        }
                 //   } catch (Exception e) {
                 //       System.debug('Error: ' + e.getMessage());
                 //       throw new AuraHandledException('Failed to parse response: ' + e.getMessage());
                 //   }
 
                    
                    
                    page++;
                    
                    return response.getBody(); // Return response as string
                } else {
                    throw new CalloutException('Error: ' + response.getStatus() + ' - ' + response.getBody());
                }
            } catch (Exception e) {
                System.debug('e.getMessage(): ' + e.getMessage());
                throw new AuraHandledException('Failed to call API: ' + e.getMessage());
            }
        }
    
 
    
    @AuraEnabled(cacheable=false)
    public static String sendRequestSingleEmail(Id recordId, Integer page) {
        
        String finalResult = '';
        Integer totalPages = 99999;
        
        
        try {
            
            
            system.debug('Entered sendRequestSingleEmail');
            system.debug('recordId:'+recordId);
            
            Boolean runningInASandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
            String endpoint = '';
            if(runningInASandbox){
                endpoint = 'https://webapihsicorev2.azurewebsites.net/api/SalesforceStorage/GetEmail';      //PROD
                //               endpoint = 'https://webapihsicorev2-qa.azurewebsites.net/api/SalesforceStorage/GetEmail';      //QA
                //                endpoint = 'https://webapihsicorev2-staging2.azurewebsites.net/api/SalesforceStorage/GetEmail';  //Staging
            }
            else{
                endpoint = 'https://webapihsicorev2.azurewebsites.net/api/SalesforceStorage/GetEmail';
            }

            system.debug('endpoint:'+endpoint);
            

            Id PreviousId;
            List<EmailMessage> messages = [SELECT Previous_Id__c FROM EmailMessage WHERE Id = :recordId LIMIT 1];
            if (!messages.isEmpty()) {
                PreviousId = messages[0].Previous_Id__c;
            } else {
                System.debug('No EmailMessage found with the given Id.');
                PreviousId = Id.valueOf('001000000000001');
            }
            system.debug('PreviousId:'+PreviousId);

            // Construct the endpoint with the query parameter
            endpoint = endpoint + '?SfObjectId=' + EncodingUtil.urlEncode(PreviousId, 'UTF-8') + '&page=1&limit=10'; 
//            endpoint = endpoint + '?SfObjectId=' + EncodingUtil.urlEncode(recordId, 'UTF-8') + '&page=1&limit=10'; 

            //for test: //////////////////////////
           // endpoint = 'https://webapihsicorev2-qa.azurewebsites.net/api/SalesforceStorage/GetEmail?sfObjectId=02sVm00000LlvDFIAZ&page=1&limit=1';
                          
            
            system.debug('endpoint=' + endpoint);
            
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(endpoint); // API endpoint
            request.setMethod('GET');
            request.setHeader('Content-Type', 'application/json');
            request.setTimeout(30000); // 30 seconds

            System.debug('HTTP Request: ' + request.getEndpoint());
            System.debug('HTTP Body: ' + request.getBody());
            
            
            // Send request
            HttpResponse response = http.send(request);
            if (response.getStatusCode() == 200) {
                
                String responseBody = response.getBody();
                finalResult+=responseBody; // Append data
                
                System.debug('responseBody: ' + responseBody);
                
                return response.getBody(); // Return response as string
            } else {
                throw new CalloutException('Error: ' + response.getStatus() + ' - ' + response.getBody());
            }
        } catch (Exception e) {
            System.debug('e.getMessage(): ' + e.getMessage());
            throw new AuraHandledException('Failed to call API: ' + e.getMessage());
        }
    }
   
}