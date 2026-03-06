@isTest
public class AuthorizedUserAPIControllerTest {
    @isTest
    static void getDataTest(){
        Account acc = new Account(Name = 'Test Account', Affiliated_Id__c = 1235, Member_Number__c = '13523412', First_Name__c ='Test' , Last_Name__c = 'Account', Contact_Id__c =225631);
        insert acc;
        
        Authorize_Users__c objauth = new Authorize_Users__c();
        objauth.First_Name__c = 'Test';
        objauth.Last_Name__c = 'Test';
        objauth.Account__c = acc.Id;
        insert objauth;
        
        AuthorizedUserAPIController.getAuthorizedUserRecords(acc.Id);
        AuthorizedUserAPIController.GetToken();
        
        Test.setMock(HttpCalloutMock.class, new AuthorizedUserAPIControllerTest.POSTMockAPI());
        Test.startTest();
        AuthorizedUserAPIController.postAuthorizedUser(acc.Id, 'test', 'test', 'test@gmail.com', 'test@gmail.com', '987745613', 'test', true);
        AuthorizedUserAPIController.changeAuthorizedUserStatus(objauth.Id, true);
        Test.setMock(HttpCalloutMock.class, new AuthorizedUserAPIControllerTest.GETMockAPI());
        AuthorizedUserAPIController.getAuthorizedUser(acc.Id);
        Test.setMock(HttpCalloutMock.class, new AuthorizedUserAPIControllerTest.POSTFailedMockAPI());
        AuthorizedUserAPIController.postAuthorizedUser(acc.Id, 'test', 'test', 'test@gmail.com', 'test@gmail.com', '987745613', 'test', true);
        AuthorizedUserAPIController.changeAuthorizedUserStatus(objauth.Id, true);
        Test.stopTest();
    }
     @isTest
    static void getDataTest1(){
        Account acc = new Account(Name = 'Test Account', Affiliated_Id__c = 1235, Member_Number__c = '13523412', First_Name__c ='Test' , Last_Name__c = 'Account', Contact_Id__c =225631);
        insert acc;
        
        Authorize_Users__c objauth = new Authorize_Users__c();
        objauth.First_Name__c = 'Test';
        objauth.Last_Name__c = 'Test';
        objauth.Account__c = acc.Id;
        insert objauth;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AuthorizedUserAPIControllerTest.POSTFailedMockAPI());
        AuthorizedUserAPIController.postAuthorizedUser(acc.Id, 'test', 'test', 'test@gmail.com', 'test@gmail.com', '987745613', 'test', true);
        Test.setMock(HttpCalloutMock.class, new AuthorizedUserAPIControllerTest.POSTFailedMockAPI());
        AuthorizedUserAPIController.changeAuthorizedUserStatus(objauth.Id, true);
        Test.stopTest();
    }
     @isTest
    static void getDataTest2(){
        Account acc = new Account(Name = 'Test Account', Affiliated_Id__c = 1235, Member_Number__c = '13523412', First_Name__c ='Test' , Last_Name__c = 'Account', Contact_Id__c =225631);
        insert acc;
        
        Authorize_Users__c objauth = new Authorize_Users__c();
        objauth.First_Name__c = 'Test';
        objauth.Last_Name__c = 'Test';
        objauth.Account__c = acc.Id;
        insert objauth;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AuthorizedUserAPIControllerTest.POSTFailedMockAPI());
        AuthorizedUserAPIController.changeAuthorizedUserStatus(objauth.Id, true);
        Test.stopTest();
    }
    
    public class POSTMockAPI implements HTTpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake response
            //SendToCyberSource.ParamTransaction pt = new SendToCyberSource.ParamTransaction(); 
            
            HttpResponse res = new HttpResponse();
            res.setHeader('content-type','application/json');
            res.setHeader('api-key', 'asfasd2323');
            res.setBody('{"isvalid" : true, "message": "success"}');
            	
            res.setStatusCode(200);
            return res;
        }   
    }
    public class POSTFailedMockAPI implements HTTpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake response
            //SendToCyberSource.ParamTransaction pt = new SendToCyberSource.ParamTransaction(); 
            
            HttpResponse res = new HttpResponse();
            res.setHeader('content-type','application/json');
            res.setHeader('api-key', 'asfasd2323');
            res.setBody('{"isvalid" : true, "message": "success"}');
            	
            res.setStatusCode(400);
            return res;
        }   
    }
    public class GetMockAPI implements HTTpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake response
            //SendToCyberSource.ParamTransaction pt = new SendToCyberSource.ParamTransaction(); 
            
            HttpResponse res = new HttpResponse();
            res.setHeader('content-type','application/json');
            res.setHeader('api-key', 'asfasd2323');
            res.setBody('{["FirstName" : "test", "LastName": 874596, "Email":"test@gmail.com","EmailConfirmation" : "test@gmail.com","PrimaryPhone": 23,"Country": "US", "ContactId":"225631", "MemberNumber" : "AMVlDF2562", "IsEnabled" : true], ["FirstName" : "test", "LastName": 874596, "Email":"test@gmail.com","EmailConfirmation" : "test@gmail.com","PrimaryPhone": 23,"Country": "US", "ContactId":"2256351", "MemberNumber" : "AMVlDF29662", "IsEnabled" : true]}');
            	
            res.setStatusCode(200);
            return res;
        }   
    }
}