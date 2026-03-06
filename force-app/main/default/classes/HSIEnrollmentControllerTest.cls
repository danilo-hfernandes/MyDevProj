@isTest
public class HSIEnrollmentControllerTest {
    
    @testSetup static void createRec() {
        Account acc = new Account();
        //acc.Affiliated_Id__c = 1002258;
        acc.Affiliated_Id__c = 1002266;
        acc.First_Name__c = 'D';
        acc.Last_Name__c = 'S';
        acc.Name = 'DS';
        acc.Email__c = 'ds@dd.com';
        acc.Phone = '1233211231';
        acc.BillingStreet = 'S1';
        acc.BillingCity = 'Los Angeles';
        acc.BillingPostalCode = '90001';
        acc.BillingState = 'CA';
        acc.BillingCountry = 'US';
        insert acc;
    }
    

    @isTest static void callAPITestSuccess(){
        test.startTest();
        List<Account> acc = [Select Id from Account where Affiliated_Id__c = 1002266 /*Affiliated_Id__c = 1002258*/];
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        HSIEnrollmentController.registerRecordToHSI(acc[0].Id);
        test.stopTest();
    }
    
    @isTest static void callAPITestError(){
        test.startTest();
        List<Account> acc = [Select Id from Account where Affiliated_Id__c = 1002266 /*Affiliated_Id__c = 1002258*/];
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorFailed());
        HSIEnrollmentController.registerRecordToHSI(acc[0].Id);
        test.stopTest();
    }
    
    public class MockHttpResponseGenerator implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req){
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            String str = '{"IsSucceed": true,"Errors": [],"MemberNumber": "AP-SMTNC-1299","ContactId": 2691909}';
            res.setBody(str);
            res.setStatusCode(200);
            return res;
        }
    }
    public class MockHttpResponseGeneratorFailed implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req){
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            String str = '{"IsSucceed": false,"Errors": [{"Code":"13","Description":"Invalid Phone Number"},{"Code":"0","Description":"failed on member registration validations on api/SalesforceMemberRegistration/Register"}]}';
            res.setBody(str);
            res.setStatusCode(400);
            return res;
        }
    }
}