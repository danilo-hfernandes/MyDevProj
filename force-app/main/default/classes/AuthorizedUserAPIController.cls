/**
* @File Name : AuthorizedUserAPIController.cls
* @Description :
* @Author : Shivani Chauhan
* @Last Modified By : Shivani Chauhan
* @Last Modified On : November 26, 2024
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | November 26, 2024 |   | Initial Version
**/

public class AuthorizedUserAPIController {
	@AuraEnabled(cacheable=true)
    public static List<Authorize_Users__c> getAuthorizedUserRecords(Id accountId) {
        return [
            SELECT Id, First_Name__c,Last_Name__c,Email__c,Email_Confirmation__c, Primary_Phone__c, Country__c, IsEnabled__c,Member_Number__c
            FROM Authorize_Users__c
            WHERE Account__c = :accountId
        ];
    }
	public static string GetToken(){
		String matrixAPI = 'https://matrix.nerdsoft.com/token';
		string banana = '2FihOuY0hvaIx9JkscRv23BJaO3dcSjzSD1Dcy0M';
		string userName =  'authorizeduserapi@nerdsoft.com';
		string password =  'ZrbBp!LDE60ISP%26H';
		string clientId =  '2FihOuY0hvaIx9JkscRv23BJaO3dcSjzSD1Dcy0M:2FihOuY0hvaIx9JkscRv23BJaO3dcSjzSD1Dcy0M';
		TokenReturn respObj = new TokenReturn(); 
		
		string msgTokenBody = 'banana='+banana +'&grant_type=password&username='+ userName +'&password='+ password + '&client_id=' + clientId;
		if(!test.isRunningTest()){
			Http http = new Http();
			HttpRequest request = new HttpRequest();
			request.setEndpoint(matrixAPI);
			request.setMethod('POST');
			request.setHeader('Content-Type','application/x-www-form-urlencoded');
			request.setBody(msgTokenBody);
			HttpResponse response = http.send(request);
			respObj = (TokenReturn)JSON.deserialize(response.getBody() , TokenReturn .class);
			system.debug('--msgTokenBody---'+msgTokenBody);
			system.debug('--request---'+request);
			system.debug('--response---'+response);
			system.debug('response.getStatusCode()'+response.getStatusCode());
		}
		else
		{
			respObj.access_token = 'token';
		}
		
		system.debug('respObj'+respObj);
		system.debug('respObj.access_token'+respObj.access_token);
		return respObj.access_token;
	}
	public Class TokenReturn{
		private String access_token {get; set;}
	}
	@AuraEnabled
	public static void getAuthorizedUser(String accountId){//String authorizedUserId
		system.debug('>>>accountId>>'+accountId);
		try{
			String baseURL;
			Boolean runningInASandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
			if(runningInASandbox){
				baseURL = 'http://webapihsicorev2-qa.azurewebsites.net';
			}
			else{ 
				baseURL = 'https://webapihsicorev2.azurewebsites.net';
			}
			Account objacc = [select id,Contact_Id__c,Member_Number__c,Affiliated_Id__c from Account where Id =: accountId limit 1];
			//List<Authorize_Users__c> listAuthorizedUser = [select id,Account__c, Account__r.Contact_Id__c,First_Name__c,Last_Name__c,Email__c,Contact_Id__c from Authorize_Users__c where Id =:authorizedUserId limit 1];
			//List<Authorize_Users__c> existinglistAuthorizedUser = [select id,Account__c, Account__r.Contact_Id__c,First_Name__c,Last_Name__c,Email__c from Authorize_Users__c where Id NOT = :authorizedUserId and Account__c = : listAuthorizedUser[0].Account__c];
			List<Authorize_Users__c> updateListAuthorizedUser = new List<Authorize_Users__c>();
			String gToken = GetToken();
			system.debug('--gToken--'+gToken);
			String endPoint = baseURL+'/api/AuthorizedUser/GetAuthorizedUser/'+objacc.Contact_Id__c;
			Http http = new Http();
			HttpRequest request = new HttpRequest();
			request.setEndpoint(endpoint);
			request.setMethod('GET');
			request.setHeader('Authorization', 'Bearer '+gToken);
			system.debug('--request--'+request);
			HttpResponse hhtpResponse = http.send(request);
			system.debug('response.getStatusCode()'+hhtpResponse.getStatusCode());
			system.debug('hhtpResponse.getBody()'+hhtpResponse.getBody());
			
			String response = JSON.serializePretty( JSON.deserializeUntyped(hhtpResponse.getBody()) );
			if(hhtpResponse.getStatusCode() == 200){
				List<Object> receivedData = (List<Object>)JSON.deserializeUntyped(response);
				system.debug('>>>>>>receivedData>>>>>'+receivedData);
				for(Object objData : receivedData){
					system.debug('>>objData>>'+objData);
					Map<String, Object> mapData = (Map<String, Object>)objData;
					system.debug('>>mapData>>'+(Decimal)mapData.get('ContactId'));
					Authorize_Users__c objUser = new Authorize_Users__c();
					objUser.First_Name__c = (String)mapData.get('FirstName');
					objUser.Last_Name__c = (String)mapData.get('LastName');
					objUser.Email__c = (String)mapData.get('Email');
					objUser.Email_Confirmation__c = (String)mapData.get('EmailConfirmation');
					objUser.Primary_Phone__c = (String)mapData.get('PrimaryPhone');
					objUser.Country__c = (String)mapData.get('Country');
					objUser.IsEnabled__c = (boolean)mapData.get('IsEnabled');
					objUser.Contact_Id__c = (Decimal)mapData.get('ContactId');
					objUser.Member_Number__c = (String)mapData.get('MemberNumber');
					objUser.Account__C = objacc.Id;
					updateListAuthorizedUser.add(objUser);
				}
				upsert updateListAuthorizedUser Contact_Id__c;
			}
			else if(hhtpResponse.getStatusCode() != 200){
				Map<String,Object> receivedData = (Map<String,Object>)JSON.deserializeUntyped(response);
				String message = String.valueOf(receivedData.get('Message'));
				system.debug('--message-'+message);
				Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();                    
				String[] sendingTo = new String[]{'shivani.chauhan@nerdsoft.com', 'danilo.fernandes@nerdsoft.com'};//,'danilo.fernandes@nerdsoft.com'
				semail.setCcAddresses(new String[]{UserInfo.getuserid()});
				semail.setToAddresses(sendingTo); 
				semail.setSubject('Authorization User GET API Failed'); 
				semail.setPlainTextBody('Message : '+message+ ' ContactId : '+String.valueOf(objacc.Contact_Id__c));
				Messaging.sendEmail(new Messaging.SingleEmailMessage[] {semail}); 
			}
		}
		catch(Exception ex){
			System.debug('ERROR: '+ ex);  
			Error_Handler__c err = new Error_Handler__c();
			err.Name = 'Authorization GET API , Apex Class : AuthorizedUserAPIController';
			err.Error_Message__c = 'Message:' + ex.getMessage()  + ' - Exception occurrred on LineNumber: ' + ex.getLineNumber();
			insert err;
		}

	}
	@AuraEnabled
	public static String postAuthorizedUser(String accountId, String firstName, String lastName, String email,String emailConfirmation, String phone, String country, Boolean isEnabled){
		try{
			String baseURL;
			Boolean runningInASandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
			if(runningInASandbox){
				baseURL = 'http://webapihsicorev2-qa.azurewebsites.net';
			}
			else{ 
				baseURL = 'https://webapihsicorev2.azurewebsites.net';
			}
			Account objacc = [select id,Contact_Id__c,Member_Number__c,Affiliated_Id__c from Account where Id =: accountId limit 1];
			//List<Authorize_Users__c> listAuthorizedUser = [select id,Account__c, Account__r.Contact_Id__c,Account__r.Member_Number__c,Account__r.Affiliated_Id__c,First_Name__c,Last_Name__c,Email__c,Email_Confirmation__c,Primary_Phone__c,Country__c,IsEnabled__c from Authorize_Users__c where Id =:authorizedUserId  limit 1];
			MemberWrapper objwrapper = new MemberWrapper();
			objwrapper.ContactId = objacc.Contact_Id__c;
			objwrapper.AffiliateId = objacc.Affiliated_Id__c;
			objwrapper.MemberNumber = objacc.Member_Number__c;
			objwrapper.FirstName = firstName;
			objwrapper.LastName = lastName;
			objwrapper.Email = email;
			objwrapper.EmailConfirmation = emailConfirmation;
			objwrapper.PrimaryPhone = phone;
			objwrapper.Country = country;
			objwrapper.IsEnabled = isEnabled;
            
			String payload = JSON.serialize(objwrapper);
			String gToken = GetToken();
			system.debug('--gToken--'+gToken);
			String endPoint = baseURL+'/api/AuthorizedUser/PostAuthorizedUser/'+objacc.Contact_Id__c;
			Http http = new Http();
			HttpRequest request = new HttpRequest();
			request.setEndpoint(endpoint);
			request.setMethod('POST');
			request.setBody(payload);
			request.setHeader('content-type', 'application/json');
			request.setHeader('Authorization', 'Bearer '+gToken);
			system.debug('--request--'+request);
			HttpResponse hhtpResponse = http.send(request);
			system.debug('response.getStatusCode()'+hhtpResponse.getStatusCode());
			system.debug('hhtpResponse.getBody()'+hhtpResponse.getBody());
			
			String response = JSON.serializePretty( JSON.deserializeUntyped(hhtpResponse.getBody()) );
			Map<String,Object> receivedData = (Map<String,Object>)JSON.deserializeUntyped(response);
			String message = String.valueOf(receivedData.get('Message'));
			system.debug('--message-'+message);
			if(hhtpResponse.getStatusCode() != 200){
				Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();                    
				String[] sendingTo = new String[]{'shivani.chauhan@nerdsoft.com', 'danilo.fernandes@nerdsoft.com'};//,'danilo.fernandes@nerdsoft.com'
				semail.setCcAddresses(new String[]{UserInfo.getuserid()});
				semail.setToAddresses(sendingTo); 
				semail.setSubject('Authorization User POST API Failed'); 
				semail.setPlainTextBody('Message : '+message+ ' Request : '+payload+' ContactId : '+String.valueOf(objacc.Contact_Id__c));
				Messaging.sendEmail(new Messaging.SingleEmailMessage[] {semail}); 
			}
            return message;
		}
		catch(Exception ex){
			System.debug('ERROR: '+ ex);  
			Error_Handler__c err = new Error_Handler__c();
			err.Name = 'Authorization POST API , Apex Class : AuthorizedUserAPIController';
			err.Error_Message__c = 'Message:' + ex.getMessage()  + ' - Exception occurrred on LineNumber: ' + ex.getLineNumber();
			insert err;
		}
        return null;
	}
	@AuraEnabled
	public static String changeAuthorizedUserStatus(String authorizedUserId, Boolean isEnabled){
		try{
			String baseURL;
			Boolean runningInASandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
			if(runningInASandbox){
				baseURL = 'http://webapihsicorev2-qa.azurewebsites.net';
			}
			else{ 
				baseURL = 'https://webapihsicorev2.azurewebsites.net';
			}
			List<Authorize_Users__c> listAuthorizedUser = [select id, IsEnabled__c, Contact_Id__c, Account__r.Contact_Id__c from Authorize_Users__c where Id =:authorizedUserId  limit 1];
			
			StatusWrapper objwrapper = new StatusWrapper();
			objwrapper.contactId = listAuthorizedUser[0].Contact_Id__c;
			objwrapper.mustEnable = isEnabled;
             // Fetch the current user's name using UserInfo.getUserId() and a SOQL query - HMR-379
       		Id currentUserId = UserInfo.getUserId();
        	User currentUser = [SELECT Name FROM User WHERE Id = :currentUserId LIMIT 1];
        	objwrapper.modifiedBy = currentUser.Name;
			//objwrapper.modifiedBy = UserInfo.getUserId();
			String payload = JSON.serialize(objwrapper);
			String gToken = GetToken();
			system.debug('--gToken--'+gToken);
			String endPoint = baseURL+'/api/AuthorizedUser/ChangeAuthorizedUserStatus/'+listAuthorizedUser[0].Account__r.Contact_Id__c;
			Http http = new Http();
			HttpRequest request = new HttpRequest();
			request.setEndpoint(endpoint);
			request.setMethod('POST');
			request.setBody(payload);
			request.setHeader('content-type', 'application/json');
			request.setHeader('Authorization', 'Bearer '+gToken);
			system.debug('--request--'+request);
			HttpResponse hhtpResponse = http.send(request);
			system.debug('response.getStatusCode()'+hhtpResponse.getStatusCode());
			system.debug('hhtpResponse.getBody()'+hhtpResponse.getBody());
			
			String response = JSON.serializePretty( JSON.deserializeUntyped(hhtpResponse.getBody()) );
			Map<String,Object> receivedData = (Map<String,Object>)JSON.deserializeUntyped(response);
			String message = String.valueOf(receivedData.get('Message'));
			system.debug('--message-'+message);
			Authorize_Users__c existingRecord = new Authorize_Users__c();
			existingRecord.Id = authorizedUserId;
			existingRecord.IsEnabled__c = isEnabled;
            update existingRecord;
			if(hhtpResponse.getStatusCode() != 200){
				Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();                    
				String[] sendingTo = new String[]{'shivani.chauhan@nerdsoft.com', 'danilo.fernandes@nerdsoft.com'};//,'danilo.fernandes@nerdsoft.com'
				semail.setCcAddresses(new String[]{UserInfo.getuserid()});
				semail.setToAddresses(sendingTo); 
				semail.setSubject('Authorization User- Change Authorized User Status API Failed'); 
				semail.setPlainTextBody('Message : '+message+ ' Request : '+payload+' ContactId : '+String.valueOf(listAuthorizedUser[0].Account__r.Contact_Id__c));
				Messaging.sendEmail(new Messaging.SingleEmailMessage[] {semail}); 
			}
			return message;
		}
		catch(Exception ex){
			System.debug('ERROR: '+ ex);  
			Error_Handler__c err = new Error_Handler__c();
			err.Name = 'Change AuthorizedUser Status API , ApexClass : AuthorizedUserAPIController';
			err.Error_Message__c = 'Message:' + ex.getMessage()  + ' - Exception occurrred on LineNumber: ' + ex.getLineNumber();
			insert err;
		}
		return null;
	}
	/*public static void getAuthorizedUserCountries(String accountId, List<Authorize_Users__c> listAuthorizedUser){
		try{
			String baseURL;
			Boolean runningInASandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
			if(runningInASandbox){
				baseURL = 'http://webapihsicorev2-qa.azurewebsites.net';
			}
			else{ 
				baseURL = '';
			}
			Account objacc = [select id,Contact_Id__c,Member_Number__c,Affiliated_Id__c from Account where Id =: accountId limit 1];
			String gToken = GetToken();
			system.debug('--gToken--'+gToken);
			String endPoint = baseURL+'/api/AuthorizedUser/GetAuthorizedUserCountries/'+objacc.Contact_Id__c;
			Http http = new Http();
			HttpRequest request = new HttpRequest();
			request.setEndpoint(endpoint);
			request.setMethod('GET');
			request.setBody('');
			request.setHeader('content-type', 'application/json');
			request.setHeader('Authorization', 'Bearer '+gToken);
			system.debug('--request--'+request);
			HttpResponse hhtpResponse = http.send(request);
			system.debug('response.getStatusCode()'+hhtpResponse.getStatusCode());
			system.debug('hhtpResponse.getBody()'+hhtpResponse.getBody());
			
			String response = JSON.serializePretty( JSON.deserializeUntyped(hhtpResponse.getBody()) );
			Map<String,Object> receivedData = (Map<String,Object>)JSON.deserializeUntyped(response);
			String message = String.valueOf(receivedData.get('Message'));
			system.debug('--message-'+message);
			if(hhtpResponse.getStatusCode() != 200){
				Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();                    
				String[] sendingTo = new String[]{'shivani.chauhan@nerdsoft.com','danilo.fernandes@nerdsoft.com'};//,'danilo.fernandes@nerdsoft.com'
				semail.setCcAddresses(new String[]{UserInfo.getuserid()});
				semail.setToAddresses(sendingTo); 
				semail.setSubject('Get AuthorizedUser Countries API Failed'); 
				semail.setPlainTextBody('Message : '+message+ ' AccountId : '+String.valueOf(accountId));
				Messaging.sendEmail(new Messaging.SingleEmailMessage[] {semail}); 
			}
		}
		catch(Exception ex){
			System.debug('ERROR: '+ ex);  
			Error_Handler__c err = new Error_Handler__c();
			err.Name = 'Get AuthorizedUser Countries API , Apex Class : AuthorizedUserAPIController';
			err.Error_Message__c = 'Message:' + ex.getMessage()  + ' - Exception occurrred on LineNumber: ' + ex.getLineNumber();
			insert err;
		}
		
	}*/
	public class MemberWrapper {
		public Decimal ContactId;
		public Decimal AffiliateId ;
		public String MemberNumber;
		public String FirstName ;
		public String LastName ;
		public String Email ;
		public String EmailConfirmation;
		public String PrimaryPhone ;
		public String Country ;
		public Boolean IsEnabled;

		// Constructor to initialize with JSON input
		public MemberWrapper() {}
	}
	public class StatusWrapper {
		public Decimal contactId;
		public Boolean mustEnable;
		public String modifiedBy;

		// Constructor to initialize with JSON input
		public StatusWrapper() {}
	}
}