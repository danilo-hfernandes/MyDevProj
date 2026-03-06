@isTest
public class filesUploadServiceTest {
    @isTest
    static void filesUploadServiceTest1() {
        Account a = new Account();
        a.Name = 'first';
        
        insert a;

        Opportunity o = new Opportunity();
        o.Amount = 123;
        o.AccountId = a.id;
        o.name = 'test opp';
        o.StageName = 'CallDocuSign';
        o.CloseDate = System.today();
        o.Amount = 500;
         
        insert o;
        
        Note n = new Note();
        n.body = 'Test Body'; 
        n.Title = 'Test Subject';
        n.ParentId = o.Id;
        insert n;

        Test.setMock(HttpCalloutMock.class, new MockInsertPaymentService());
        filesUploadService ps = new filesUploadService(); 
        String JsonMsg='{"Body" : "abc","ContentType":"Invoice.pdf","Name":"InsertFile Invoice","OppId": "'+o.id+'","Email": true}';// + ',"CardLast4":' + p.Credit_Card_Number__c +',"PaymentOrd":' + p.Payment_Number__c + ',"PaidOn":' + p.Paid_On__c + ',"CardLastName":' + p.Name + ',"CardFirstName":' + p.name + ',"RecType":"TFG","PaymentTypeStr":"Payment","CardExpdate":"12/12/2019"}';
        RestRequest req = new RestRequest();
       	RestResponse res = new RestResponse();
        req.requestURI = 'services/apexrest/InsertFile/*';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        filesUploadService.responsewrapper rp = new filesUploadService.responsewrapper();
        filesUploadService.createRecord();

    }

    @isTest
    static void filesUploadServiceTest2() {
        Account a = new Account();
        a.Name = 'first';
        
        insert a;
       
        Opportunity o = new Opportunity();
        o.Amount = 123;
        o.AccountId = a.id;
        o.name = 'test opp';
        o.StageName = 'CallDocuSign';
        o.CloseDate = System.today();
        o.Amount = 500;
         
        insert o;
        
        Note n = new Note();
        n.body = 'Test Body'; 
        n.Title = 'Test Subject';
        n.ParentId = o.Id;
        insert n;

 
        Test.setMock(HttpCalloutMock.class, new MockInsertPaymentService());
        filesUploadService ps = new filesUploadService(); 
        String JsonMsg='{"Body" : "abc","ContentType":"Invoice.pdf","Name":"InsertFile Invoice","OppId": "+o.id+"}';// + ',"CardLast4":' + p.Credit_Card_Number__c +',"PaymentOrd":' + p.Payment_Number__c + ',"PaidOn":' + p.Paid_On__c + ',"CardLastName":' + p.Name + ',"CardFirstName":' + p.name + ',"RecType":"TFG","PaymentTypeStr":"Payment","CardExpdate":"12/12/2019"}';
       	RestRequest req = new RestRequest();
       	RestResponse res = new RestResponse();

        req.requestURI = 'services/apexrest/InsertFile/*';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response= res;

        filesUploadService.responsewrapper rp = new filesUploadService.responsewrapper();
        filesUploadService.createRecord();

    }
}