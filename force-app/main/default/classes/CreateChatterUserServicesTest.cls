@isTest
public class CreateChatterUserServicesTest {

    @isTest
    public static void createUserTest1(){
        
        String JsonMsg = '{"LastName": "User1","FirstName": "Test","Alias": "tUsr3","CommunityNickname": "tUsr3","Email": "ts@email.com","Username": "ts@email.com","phone": "2222222222","ActiveStatus":true}';
        System.debug('JSON serialize --> ' + JsonMsg);
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestUri ='/services/apexrest/demourl';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(JsonMsg);
        
        RestContext.request = req;
        RestContext.response= res;
        
        test.startTest();
        CreateChatterUserServices.createUser();
        test.stopTest();
        
        system.debug('responce== '+res);
    }
    
    @isTest
    public static void createUserTest2(){
        
        String JsonMsg = '{"LastName": "User 3","FirstName": "Chatter","Alias": "chUsr3","CommunityNickname": "chUsr3","Email": "chusr3@email.com","Username": "chusr3@email.com","phone": "2222222222","ActiveStatus":false}';
        System.debug('JSON serialize --> ' + JsonMsg);
        
        RestRequest req = new RestRequest();
        req.requestUri ='/services/apexrest/demourl';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        
        test.startTest();
        CreateChatterUserServices.createUser();
        test.stopTest();
    }
}