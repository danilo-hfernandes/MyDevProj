public class DataSyncToSQL {
    
    public static string GetToken(){
        String matrixAPI = 'https://matrix.nerdsoft.com/Token';
        string userName =  'salesforceupdatecontact@nerdsoft.com';
        string password =  'SF_uc_password1';
        string clientId =  '2FihOuY0hvaIx9JkscRv23BJaO3dcSjzSD1Dcy0M:2FihOuY0hvaIx9JkscRv23BJaO3dcSjzSD1Dcy0M';
        
        string msgTokenBody = 'banana='+clientId+'&grant_type=password&username='+ userName +'&password='+ password + '&client_id=' + clientId;
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(matrixAPI);
        request.setMethod('POST');
        request.setHeader('Content-Type','application/x-www-form-urlencoded');
        request.setBody(msgTokenBody);
        HttpResponse response = http.send(request);
        system.debug('--msgTokenBody---'+msgTokenBody);
        system.debug('--request---'+request);
        system.debug('--response---'+response);
        TokenReturn respObj = new TokenReturn();
        if(!test.isRunningTest()){
            respObj = (TokenReturn)JSON.deserialize(response.getBody() , TokenReturn .class);
        }else{
            respObj.access_token = 'token';
        }
        system.debug('response.getStatusCode()'+response.getStatusCode());
        system.debug('respObj'+respObj);
        system.debug('respObj.access_token'+respObj.access_token);
        return respObj.access_token;      
    }
    public Class TokenReturn{
        private String access_token {get; set;}
    }
    @future(callout=true)
    public static void AccountContactDataSync(Set<Id> AccountContactIdSet, String ObjectName){
        list<SyncAccountContactDataToSQL> syncDataList = New List<SyncAccountContactDataToSQL>();
        if(ObjectName == 'Account'){
            List<Account> accList = [select id,Name,Phone,Contact_Id__c,Member_Number__c,Master_Record_Id__c,First_Name__c,Last_Name__c,
                                     Email__c,BillingCity,BillingCountry,BillingState,BillingStreet,BillingPostalCode,AccountSource,
                                     Alternate_Phone_1__c,Alternate_Phone_Description__c,Alternate_Phone_2__c,Alternate_Phone_2_Description__c,
                                     Alternate_Phone_3__c,Alternate_Phone_3_Description__c,Alternate_Phone__c,LastModifiedBy.Name,Dues_Last_Paid_Until__c,Original_Source__c
                                     from Account where Id IN : AccountContactIdSet];
            for(Account acc : accList){
                SyncAccountContactDataToSQL syncDataObj = New SyncAccountContactDataToSQL();
                //syncDataObj.RecordId = acc.Id;
                //syncDataObj.ContactId = acc.Contact_Id__c;
                syncDataObj.memberNumber = acc.Member_Number__c;
                syncDataObj.FirstName = acc.First_Name__c;
                syncDataObj.LastName = acc.Last_Name__c;
                syncDataObj.FullName = acc.Name; // How we are going to send as First Name and LastName
                syncDataObj.StreetAddress = acc.BillingStreet;
                syncDataObj.City = acc.BillingCity;
                syncDataObj.Region = acc.BillingState;
                syncDataObj.ZipCode = acc.BillingPostalCode;
                syncDataObj.Country = acc.BillingCountry;
                syncDataObj.Email = acc.Email__c;
                syncDataObj.PrimaryPhone = acc.Phone;
                syncDataObj.ModifiedBy  = 'Salesforce';
		        //syncDataObj.DuesLastPaidUntil  = String.valueOf(acc.Dues_Last_Paid_Until__c); 
                //syncDataObj.MembershipExpiration  = String.valueOf(acc.Dues_Last_Paid_Until__c); 
                
                
                /*syncDataObj.MasterRecordId = acc.Master_Record_Id__c;*/
                syncDataObj.AlternatePhone1 = acc.Alternate_Phone__c;
                syncDataObj.AlternatePhone_Desc1 = 'AlternativePhone';//acc.Alternate_Phone_Description__c;
                syncDataObj.AlternatePhone2  = acc.Alternate_Phone_1__c;
                syncDataObj.AlternatePhone_Desc2 = 'AlternativePhone1';//acc.Alternate_Phone_2_Description__c;
                /*syncDataObj.AlternatePhone3  = acc.Alternate_Phone_2__c ;
                syncDataObj.AlternatePhone_Desc3 = acc.Alternate_Phone_2_Description__c;
                syncDataObj.AlternatePhone4  = acc.Alternate_Phone_3__c;
                syncDataObj.AlternatePhone_Desc4 = acc.Alternate_Phone_3_Description__c;*/
                //syncDataObj.ModifiedBy  = acc.LastModifiedBy.Name;
                //syncDataObj.memberNumber = acc.Member_Number__c;
                syncDataObj.AccountSource = acc.AccountSource;
                syncDataObj.ContactId = acc.Contact_Id__c;
                
                //syncDataObj.OriginalSource = acc.Original_Source__c;
                DataSyncToSQL.callHTTPQuest(syncDataObj);
            }
            
            
        }
        if(ObjectName == 'Contact'){
            system.debug('--AccountContactIdSet--'+AccountContactIdSet);
            //2023-12-19 member number filter added [Member_Number__c != NULL]
            List<Contact> conList = [select id,Subscriber_Id__c,FirstName,LastNAme,Phone,Email,Contact_Id__c,Member_Number__c,Master_Record_Id__c,
                                     MailingCity,MailingCountry,MailingState,MailingStreet,MailingPostalCode,Account_Source__c,
                                     Alternate_Phone_1__c,Alternate_Phone_Description__c,Alternate_Phone_2__c,Alternate_Phone_2_Description__c,
                                     Alternate_Phone_3__c,Alternate_Phone_3_Description__c,Alternate_Phone__c,LastModifiedBy.Name
                                     from Contact where Id IN : AccountContactIdSet AND Member_Number__c != NULL];
            for(Contact con : conList){
                SyncAccountContactDataToSQL syncDataObj = New SyncAccountContactDataToSQL();
                //syncDataObj.RecordId = con.Id;
                
                syncDataObj.FirstName = con.FirstName;
                syncDataObj.LastName = con.LastName;
                syncDataObj.FullName = con.FirstName+' '+con.LastName;
                
                //syncDataObj.MasterRecordId = con.Master_Record_Id__c;
                                
                syncDataObj.StreetAddress = con.MailingStreet;
                syncDataObj.City = con.MailingCity;
                syncDataObj.Region = con.MailingState;
                syncDataObj.ZipCode = con.MailingPostalCode;
                syncDataObj.Country = con.MailingCountry;
                syncDataObj.Email = con.Email;
                syncDataObj.PrimaryPhone = con.Phone;
                syncDataObj.ModifiedBy  = con.LastModifiedBy.Name;
                
                syncDataObj.AlternatePhone1 = con.Alternate_Phone__c;
                syncDataObj.AlternatePhone_Desc1 = 'AlternativePhone';//con.Alternate_Phone_Description__c;
                syncDataObj.AlternatePhone2  = con.Alternate_Phone_1__c;
                syncDataObj.AlternatePhone_Desc2 = 'AlternativePhone1';//con.Alternate_Phone_1_Description__c;
                /*syncDataObj.AlternatePhone3  = con.Alternate_Phone_2__c ;
				syncDataObj.AlternatePhone_Desc3 = con.Alternate_Phone_2_Description__c;
				syncDataObj.AlternatePhone4  = con.Alternate_Phone_3__c;
				syncDataObj.AlternatePhone_Desc4 = con.Alternate_Phone_3_Description__c;*/
                //2023-12-19 member number, account source and contact id added
                syncDataObj.memberNumber = con.Member_Number__c;
                syncDataObj.AccountSource = con.Account_Source__c;
                syncDataObj.ContactId = con.Contact_Id__c;
                
                //syncDataObj.ModifiedBy  = 'Salesforce';
                DataSyncToSQL.callHTTPQuest(syncDataObj);
            }
            
        }
    }
    public static void callHTTPQuest(SyncAccountContactDataToSQL syncDataList){
        if(syncDataList != null){ 
            try{
                String gToken = GetToken();
                system.debug('--gToken--'+gToken);
                String payload = JSON.serialize(syncDataList);
                Boolean runningInASandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
                String endpoint = '';
                if(runningInASandbox){
                    //endpoint = 'https://devapi.advantageprogram.com/api/user/UpdateMemberInformationSF';
                    //sandbox api changed 2023-12-08
                    endpoint = 'https://webapihsicorev2-qa.azurewebsites.net/api/user/UpdateMemberInformationSF';
                }
                else{ 
                    endpoint = 'https://api.advantageprogram.com/api/user/UpdateMemberInformationSF';
                }
                system.debug('---payload---'+payload);
                Http http = new Http();
                HttpRequest request = new HttpRequest();
                request.setEndpoint(endpoint); //https://api.advantageprogram.com/api/user/updateuserinformation
                request.setMethod('POST');
                request.setBody(payload);
                request.setHeader('content-type', 'application/json');
                if(!runningInASandbox){
                    request.setHeader('Authorization', 'Bearer '+gToken);
                }
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
                    //String[] sendingTo = new String[]{'amadeu.lettieri@nerdsoft.com','netdev@nerdsoft.com','mitul.thumar@nerdsoft.com','diana.maali@nerdsoft.com'}; 
                    //String[] sendingTo = new String[]{'amadeu.lettieri@nerdsoft.com','Danilo.fernandes@nerdsoft.com','Daniel.Oliveira@nerdsoft.com'}; 
                    String[] sendingTo = new String[]{'Danilo.fernandes@nerdsoft.com','Daniel.Oliveira@nerdsoft.com'}; 
                        semail.setCcAddresses(new String[]{UserInfo.getuserid()});
                    semail.setToAddresses(sendingTo); 
                    semail.setSubject('Account/Contact update failed from Salesforce to SQL database'); 
                    semail.setPlainTextBody('Message : '+message+ 'Request : '+payload);
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] {semail}); 
                }
            }catch(Exception ex){
                System.debug('ERROR: '+ ex);  
                Error_Handler__c err = new Error_Handler__c();
                err.Name = 'Account - Contact Data sync to SQL , Apex Class : DataSyncToSQL';
                err.Error_Message__c = 'Message:' + ex.getMessage()  + ' - Exception occurrred on LineNumber: ' + ex.getLineNumber();
                insert err;
            }
        }
    }
    public static void callHTTPAccountSync(SyncAccountDataToSQL syncDataList){
        if(syncDataList != null){ 
            try{
                String gToken = GetToken();
                system.debug('--gToken--'+gToken);
                String payload = JSON.serialize(syncDataList);
                Boolean runningInASandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
                String endpoint = '';
                if(runningInASandbox){
                    endpoint = 'https://devapi.advantageprogram.com/api/user/MembershipUpgradeExitSF';
                }
                else{ 
                    endpoint = 'https://api.advantageprogram.com/api/user/MembershipUpgradeExitSF';
                }
                system.debug('---payload---'+payload);
                Http http = new Http();
                HttpRequest request = new HttpRequest();
                request.setEndpoint(endpoint);
                request.setMethod('POST');
                request.setBody(payload);
                request.setHeader('content-type', 'application/json');
                if(!runningInASandbox){
                request.setHeader('Authorization', 'Bearer '+gToken);
                }
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
                    //String[] sendingTo = new String[]{'amadeu.lettieri@nerdsoft.com','netdev@nerdsoft.com','mitul.thumar@nerdsoft.com','diana.maali@nerdsoft.com'}; 
                    //String[] sendingTo = new String[]{'amadeu.lettieri@nerdsoft.com','danilo.fernandes@nerdsoft.com','Daniel.Oliveira@nerdsoft.com'}; 
                    String[] sendingTo = new String[]{'Danilo.fernandes@nerdsoft.com','Daniel.Oliveira@nerdsoft.com'}; 
                        semail.setCcAddresses(new String[]{UserInfo.getuserid()});
                    semail.setToAddresses(sendingTo); 
                    semail.setSubject('Account Dues Last Paid Until update failed from Salesforce to SQL database'); 
                    semail.setPlainTextBody('Message : '+message+ 'Request : '+payload +'\nAccountId: ' + syncDataList.accountId );
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] {semail}); 
                }
            }catch(Exception ex){
                System.debug('ERROR: '+ ex);  
                Error_Handler__c err = new Error_Handler__c();
                err.Name = 'Account - Contact Data sync to SQL , Apex Class : DataSyncToSQL';
                err.Error_Message__c = 'Message:' + ex.getMessage()  + ' - Exception occurrred on LineNumber: ' + ex.getLineNumber();
                insert err;
            }
        }
    }
    public class SyncAccountContactDataToSQL{
        //public String Name;
        public String memberNumber;
        //accountsource and contact id added 2023-12-08
        public String AccountSource;
        public Decimal ContactId;
        public string FullName { get; set; }
        public string FirstName { get; set; }
        public string LastName { get; set; }
        public string StreetAddress { get; set; }
        public string City { get; set; }
        public string Region { get; set; }
        public string ZipCode { get; set; }
        public string Country { get; set; }
        public string Email { get; set; }
        public string PrimaryPhone { get; set; }
        public string ModifiedBy { get; set; }
        public string DuesLastPaidUntil{get;set;}
        public String MembershipExpiration{get;set;}
        public string AlternatePhone1 { get; set; }
        public string AlternatePhone_Desc1 { get; set; }
        public string AlternatePhone2 { get; set; }
        public string AlternatePhone_Desc2 { get; set; }
        //public string OriginalSource{get;set;}
        /*public string AlternatePhone3 { get; set; }
        public string AlternatePhone_Desc3 { get; set; }
        public string AlternatePhone4 { get; set; }
        public string AlternatePhone_Desc4 { get; set; }
        public string MasterRecordId { get; set; }*/
        
    }
    
    public class SyncAccountDataToSQL{
        public String MemberNumber{get;set;}
        public string DuesLastPaidUntil{get;set;}
        public string AccountId{get;set;}
    }
    @future(callout=true)
    public static void accountDuesPaidSync(set<Id> accIdsSet){
        List<Account> listacc = [select id,Member_Number__c, Dues_Last_Paid_Until__c from Account where Id IN : accIdsSet];
        for(Account acc : listacc){
            SyncAccountDataToSQL syncDataObj = New SyncAccountDataToSQL();
            syncDataObj.MemberNumber = acc.Member_Number__c;
            syncDataObj.DuesLastPaidUntil  = String.valueOf(acc.Dues_Last_Paid_Until__c); 
            syncDataObj.AccountId = acc.id;
            DataSyncToSQL.callHTTPAccountSync(syncDataObj);
        }
    }
}

/*
Test script for more than one record testing
List<Account> accList = [select id,Name from Account where (Id = '0013t00001rIvxX' or Id= '0015200000nsjOy')];

system.debug('--accList--'+accList.size());
List<Account> accListUpdate = new List<Account>();
for(Account acc : accList){
acc.Name = acc.Name + 'test';
accListUpdate.add(acc);
}
update accListUpdate;
*/