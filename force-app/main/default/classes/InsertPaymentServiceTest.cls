@isTest
public class InsertPaymentServiceTest {
    @isTest
    static void test1() {
        String userid = UserInfo.getUserId();
        Test.setMock(HttpCalloutMock.class, new MockPaymentAPI());
        Account a = new Account();
        a.First_Name__c = 'first';
        a.Last_Name__c = 'last';
        a.Name = 'test';
        insert a;
        
        Opportunity o = new Opportunity();
        o.AccountId = a.id;
        o.name = 'test opp';
        o.StageName = 'CallDocuSign';
        o.CloseDate = System.today();
        o.Amount = 500;
        insert o;
        
        Opportunity o2 = new Opportunity();
        o2.AccountId = a.id;
        o2.name = 'test opp';
        o2.StageName = 'CallDocuSign';
        o2.CloseDate = System.today();
        o2.Amount = 500;
        insert o2;
        
        Opportunity o3 = new Opportunity();
        //o3.Amount = 123;
        o3.AccountId = a.id;
        o3.name = 'test opp';
        o3.StageName = 'CallDocuSign';
        o3.CloseDate = System.today();
        o3.Amount = 500;
        insert o3;
        
        Payment__c p = new Payment__c();
        p.Name = 'payment';
        p.Opportunity__c = o.id;
        p.Transaction_Type__c = 'Payment';
        p.Payment_Amount__c = 500;
        p.Credit_Card_Number__c = '23431231234';
        p.Paid_On__c = System.today();
        p.Payment_Type__c = 'USCA';
        p.CC_Processing_Fee__c = 10.0;
        insert p;
        
        Payment__c p2 = new Payment__c();
        p2.Name = 'payment';
        p2.Opportunity__c = o2.id;
        p2.Transaction_Type__c = 'Payment';
        p2.Payment_Amount__c = 500;
        p2.Credit_Card_Number__c = '23431231234';
        p2.Paid_On__c = System.today();
        insert p2;
        
        Payment__c p3 = new Payment__c();
        p3.Name = 'payment';
        p3.Opportunity__c = o3.id;
        p3.Transaction_Type__c = 'Payment';
        p3.Payment_Amount__c = 500;
        p3.Credit_Card_Number__c = '23431231234';
        p3.Paid_On__c = System.today();
        insert p3;
        
        ContentVersion cvlist = new Contentversion(); 
        cvlist.Title = 'Contract_Payment'; 
        cvlist.PathOnClient = 'test'; 
        cvlist.VersionData = EncodingUtil.base64Decode('Unit Test Attachment Body'); 
        List<ContentVersion> cvl = new List<ContentVersion>(); 
        cvl.add(cvlist); 
        insert cvl;
        
        Test.startTest();
        InsertpaymentService ps = new InsertPaymentService();  
        String JsonMsg='{"OpportunityId" : "'+ o.Id +'","sendEmail" : "'+ true +'","Amount":' + p.Payment_Amount__c + ',"CardLast4":' + p.Credit_Card_Number__c + ',"RecordType": "Hawaii Collection", "CardFirstName":"Test", "CardLastName" : "Test"}';// + ',"CardLast4":' + p.Credit_Card_Number__c +',"PaymentOrd":' + p.Payment_Number__c + ',"PaidOn":' + p.Paid_On__c + ',"CardLastName":' + p.Name + ',"CardFirstName":' + p.name + ',"RecType":"TFG","PaymentTypeStr":"Payment","CardExpdate":"12/12/2019"}';
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = 'services/apexrest/insertpayment/*';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        InsertpaymentService.responsewrapper rp = new InsertpaymentService.responsewrapper();
        
        InsertPaymentService.createRecord();
        test.stopTest();
    }
    
    @isTest
    static void test2() {
        String userid = UserInfo.getUserId();
        Test.setMock(HttpCalloutMock.class, new MockInsertPaymentService());
        
        Account a = new Account();
        a.First_Name__c = 'first';
        a.Last_Name__c = 'last';
        a.Name = 'Mitul';
        insert a;
        
        Opportunity o = new Opportunity();
        o.AccountId = a.id;
        o.name = 'test opp';
        o.StageName = 'CallDocuSign';
        o.CloseDate = System.today();
        o.Amount = 500;
        insert o;
        
        Opportunity o2 = new Opportunity();
        o2.AccountId = a.id;
        o2.name = 'test opp';
        o2.StageName = 'CallDocuSign';
        o2.CloseDate = System.today();
        o2.Amount = 500;
        insert o2;
        
        Opportunity o3 = new Opportunity();
        o3.AccountId = a.id;
        o3.name = 'test opp';
        o3.StageName = 'CallDocuSign';
        o3.CloseDate = System.today();
        o3.Amount = 500;
        insert o3;
        
        Payment__c p = new Payment__c();
        p.Name = 'payment';
        p.Opportunity__c = o.id;
        p.Transaction_Type__c = 'Payment';
        p.Payment_Amount__c = 500;
        p.Credit_Card_Number__c = '23431231234';
        p.Paid_On__c = System.today();
        insert p;
        
        Payment__c p2 = new Payment__c();
        p2.Name = 'payment';
        p2.Opportunity__c = o2.id;
        p2.Transaction_Type__c = 'Payment';
        p2.Payment_Amount__c = 500;
        p2.Credit_Card_Number__c = '23431231234';
        p2.Paid_On__c = System.today();
        insert p2;
        
        Payment__c p3 = new Payment__c();
        p3.Name = 'payment';
        p3.Opportunity__c = o3.id;
        p3.Transaction_Type__c = 'Payment';
        p3.Payment_Amount__c = 500;
        p3.Credit_Card_Number__c = '23431231234';
        p3.Paid_On__c = System.today();
        insert p3;
        
        Test.startTest();
        InsertpaymentService ps = new InsertPaymentService();  
        String JsonMsg='{"OpportunityId" : "'+ o2.Id +'","Amount":' + p.Payment_Amount__c + ',"CardLast4":' + p.Credit_Card_Number__c + ',"RecordType": "Voucher","PaidOn" : "'+ p.paid_on__c + ',"CardFirstName":' + p.Name + '"}';// + ',"CardLast4":' + p.Credit_Card_Number__c +',"PaymentOrd":' + p.Payment_Number__c + ',"PaidOn":' + p.Paid_On__c + ',"CardLastName":' + p.Name + ',"CardFirstName":' + p.name + ',"RecType":"TFG","PaymentTypeStr":"Payment","CardExpdate":"12/12/2019"}';
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = 'services/apexrest/insertpayment/*';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        InsertpaymentService.responsewrapper rp = new InsertpaymentService.responsewrapper();
        InsertPaymentService.createRecord();
        
        test.stopTest();
       
    }
    
    @isTest
    static void test3() {
        String userid = UserInfo.getUserId();
        Test.setMock(HttpCalloutMock.class, new MockPaymentAPI());
        
        Account a = new Account();
        a.First_Name__c = 'first';
        a.Last_Name__c = 'last';
        a.Name = 'Mitul';
        insert a;
        
        Opportunity o = new Opportunity();
        o.AccountId = a.id;
        o.name = 'test opp';
        o.StageName = 'CallDocuSign';
        o.CloseDate = System.today();
        o.Amount = 500;
        insert o;
        
        Opportunity o2 = new Opportunity();
        o2.AccountId = a.id;
        o2.name = 'test opp';
        o2.StageName = 'CallDocuSign';
        o2.CloseDate = System.today();
        o2.Amount = 500;
        insert o2;
        
        Opportunity o3 = new Opportunity();
        //o3.Amount = 123;
        o3.AccountId = a.id;
        o3.name = 'test opp';
        o3.StageName = 'CallDocuSign';
        o3.CloseDate = System.today();
        o3.Amount = 500;
        insert o3;
        
        
        Payment__c p = new Payment__c();
        p.Name = 'payment';
        p.Opportunity__c = o.id;
        p.Transaction_Type__c = 'Payment';
        p.Payment_Amount__c = 500;
        p.Credit_Card_Number__c = '23431231234';
        p.Paid_On__c = System.today();
        p.Payment_Type__c = 'CAN';
        insert p;
        
        Payment__c p2 = new Payment__c();
        p2.Name = 'payment';
        p2.Opportunity__c = o2.id;
        p2.Transaction_Type__c = 'Payment';
        p2.Payment_Amount__c = 500;
        p2.Credit_Card_Number__c = '23431231234';
        p2.Paid_On__c = System.today();
        insert p2;
        
        Payment__c p3 = new Payment__c();
        p3.Name = 'payment';
        p3.Opportunity__c = o3.id;
        p3.Transaction_Type__c = 'Payment';
        p3.Payment_Amount__c = 500;
        p3.Credit_Card_Number__c = '23431231234';
        p3.Paid_On__c = System.today();
        insert p3;
        
        ContentVersion cvlist = new Contentversion(); 
        cvlist.Title = 'Contract_Payment'; 
        cvlist.PathOnClient = 'test'; 
        cvlist.VersionData = EncodingUtil.base64Decode('Unit Test Attachment Body'); 
        List<ContentVersion> cvl = new List<ContentVersion>(); 
        cvl.add(cvlist); 
        insert cvl;
        
        
        
        Test.startTest();
        InsertpaymentService ps = new InsertPaymentService();  
        String JsonMsg='{"OpportunityId" : "'+ o.Id +'","sendEmail" : "'+ true +'","Amount":' + p.Payment_Amount__c + ',"CardLast4":' + p.Credit_Card_Number__c + ',"RecType": "WWPT CAN"}';// + ',"CardLast4":' + p.Credit_Card_Number__c +',"PaymentOrd":' + p.Payment_Number__c + ',"PaidOn":' + p.Paid_On__c + ',"CardLastName":' + p.Name + ',"CardFirstName":' + p.name + ',"RecType":"TFG","PaymentTypeStr":"Payment","CardExpdate":"12/12/2019"}';
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = 'services/apexrest/insertpayment/*';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        InsertpaymentService.responsewrapper rp = new InsertpaymentService.responsewrapper();
        InsertPaymentService.createRecord();
        test.stopTest();
    }
    
    @isTest
    static void test4() {
        String userid = UserInfo.getUserId();
        Test.setMock(HttpCalloutMock.class, new MockPaymentAPI());
        Account a = new Account();
        a.First_Name__c = 'first';
        a.Last_Name__c = 'last';
        a.Name = 'Mitul';
        insert a;
        
        Opportunity o = new Opportunity();
        o.AccountId = a.id;
        o.name = 'test opp';
        o.StageName = 'CallDocuSign';
        o.CloseDate = System.today();
        o.Amount = 500;
        insert o;
        
        Opportunity o2 = new Opportunity();
        o2.AccountId = a.id;
        o2.name = 'test opp';
        o2.StageName = 'CallDocuSign';
        o2.CloseDate = System.today();
        o2.Amount = 500;
        insert o2;
        
        Opportunity o3 = new Opportunity();
        //o3.Amount = 123;
        o3.AccountId = a.id;
        o3.name = 'test opp';
        o3.StageName = 'CallDocuSign';
        o3.CloseDate = System.today();
        o3.Amount = 500;
        insert o3;
        
        Payment__c p = new Payment__c();
        p.Name = 'payment';
        p.Opportunity__c = o.id;
        p.Transaction_Type__c = 'Payment';
        p.Payment_Amount__c = 500;
        p.Credit_Card_Number__c = '23431231234';
        p.Paid_On__c = System.today();
        p.Payment_Type__c = 'TCS';
        insert p;
        
        Payment__c p2 = new Payment__c();
        p2.Name = 'payment';
        p2.Opportunity__c = o2.id;
        p2.Transaction_Type__c = 'Payment';
        p2.Payment_Amount__c = 500;
        p2.Credit_Card_Number__c = '23431231234';
        p2.Paid_On__c = System.today();
        insert p2;
        
        Payment__c p3 = new Payment__c();
        p3.Name = 'payment';
        p3.Opportunity__c = o3.id;
        p3.Transaction_Type__c = 'Payment';
        p3.Payment_Amount__c = 500;
        p3.Credit_Card_Number__c = '23431231234';
        p3.Paid_On__c = System.today();
        insert p3;
        
        ContentVersion cvlist = new Contentversion(); 
        cvlist.Title = 'Contract_Payment'; 
        cvlist.PathOnClient = 'test'; 
        cvlist.VersionData = EncodingUtil.base64Decode('Unit Test Attachment Body'); 
        List<ContentVersion> cvl = new List<ContentVersion>(); 
        cvl.add(cvlist); 
        insert cvl;
        
        Test.startTest();
        InsertpaymentService ps = new InsertPaymentService();  
        String JsonMsg='{"OpportunityId" : "'+ o.Id +'","sendEmail" : "'+ true +'","Amount":' + p.Payment_Amount__c + ',"CardLast4":' + p.Credit_Card_Number__c + ',"RecType": "WWPT"}';// + ',"CardLast4":' + p.Credit_Card_Number__c +',"PaymentOrd":' + p.Payment_Number__c + ',"PaidOn":' + p.Paid_On__c + ',"CardLastName":' + p.Name + ',"CardFirstName":' + p.name + ',"RecType":"TFG","PaymentTypeStr":"Payment","CardExpdate":"12/12/2019"}';
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = 'services/apexrest/insertpayment/*';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        InsertpaymentService.responsewrapper rp = new InsertpaymentService.responsewrapper();
        
        InsertPaymentService.createRecord();
        test.stopTest();
    }
        
    @isTest
    static void test5SFX(){
        String userid = UserInfo.getUserId();
        Test.setMock(HttpCalloutMock.class, new MockPaymentAPI());
        Account a = new Account();
        a.First_Name__c = 'first';
        a.Last_Name__c = 'last';
        a.Name = 'Victor';
        insert a;
        
        Opportunity o = new Opportunity();
        o.AccountId = a.id;
        o.name = 'test opp';
        o.StageName = 'CallDocuSign';
        o.CloseDate = System.today();
        o.Amount = 500;
        o.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('SFX_Membership').getRecordTypeId();
        insert o;
        
        Opportunity o2 = new Opportunity();
        o2.AccountId = a.id;
        o2.name = 'test opp';
        o2.StageName = 'CallDocuSign';
        o2.CloseDate = System.today();
        o2.Amount = 500;
        insert o2;
        
        Opportunity o3 = new Opportunity();
        //o3.Amount = 123;
        o3.AccountId = a.id;
        o3.name = 'test opp';
        o3.StageName = 'CallDocuSign';
        o3.CloseDate = System.today();
        o3.Amount = 500;
        insert o3;
        
        Payment__c p = new Payment__c();
        p.Name = 'payment';
        p.Opportunity__c = o.id;
        p.Transaction_Type__c = 'Payment';
        p.Payment_Amount__c = 500;
        p.Credit_Card_Number__c = '23431231234';
        p.Paid_On__c = System.today();
        p.Payment_Type__c = 'TCS';
        insert p;
        
        Payment__c p2 = new Payment__c();
        p2.Name = 'payment';
        p2.Opportunity__c = o2.id;
        p2.Transaction_Type__c = 'Payment';
        p2.Payment_Amount__c = 500;
        p2.Credit_Card_Number__c = '23431231234';
        p2.Paid_On__c = System.today();
        insert p2;
        
        Payment__c p3 = new Payment__c();
        p3.Name = 'payment';
        p3.Opportunity__c = o3.id;
        p3.Transaction_Type__c = 'Payment';
        p3.Payment_Amount__c = 500;
        p3.Credit_Card_Number__c = '23431231234';
        p3.Paid_On__c = System.today();
        insert p3;
        
        ContentVersion cvlist = new Contentversion(); 
        cvlist.Title = 'Contract_Payment'; 
        cvlist.PathOnClient = 'test'; 
        cvlist.VersionData = EncodingUtil.base64Decode('Unit Test Attachment Body'); 
        List<ContentVersion> cvl = new List<ContentVersion>(); 
        cvl.add(cvlist); 
        insert cvl;
        
        Test.startTest();
        InsertpaymentService ps = new InsertPaymentService();  
        String JsonMsg='{"OpportunityId" : "'+ o.Id +'","sendEmail" : "'+ true +'","Amount":' + p.Payment_Amount__c + ',"CardLast4":' + p.Credit_Card_Number__c + ',"RecType": "WWPT"}';// + ',"CardLast4":' + p.Credit_Card_Number__c +',"PaymentOrd":' + p.Payment_Number__c + ',"PaidOn":' + p.Paid_On__c + ',"CardLastName":' + p.Name + ',"CardFirstName":' + p.name + ',"RecType":"TFG","PaymentTypeStr":"Payment","CardExpdate":"12/12/2019"}';
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = 'services/apexrest/insertpayment/*';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        InsertpaymentService.responsewrapper rp = new InsertpaymentService.responsewrapper();
        
        InsertPaymentService.createRecord();
        test.stopTest();
    }
	@isTest
    static void test6Exit(){
        String userid = UserInfo.getUserId();
        Test.setMock(HttpCalloutMock.class, new MockPaymentAPI());
        Account a = new Account();
        a.First_Name__c = 'first';
        a.Last_Name__c = 'last';
        a.Name = 'Daniel';
        insert a;
        
        Opportunity o = new Opportunity();
        o.AccountId = a.id;
        o.name = 'test opp';
        o.StageName = 'CallDocuSign';
        o.CloseDate = System.today();
        o.Amount = 1500;
        o.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Membership_Add_On').getRecordTypeId();
        insert o;
        
        OpportunityLineItem tOLI = new OpportunityLineItem();
        tOLI.Quantity = 1;
        tOLI.OpportunityId = o.id;
        tOLI.Product2Id = '01t4z000009eq01AAA';
        tOLI.PriceBookEntryID = '01u4z00000KtFtPAAV';
        tOLI.totalprice = 0;
        tOLI.retail_price__c = 400;
        insert tOLI;
            
        Payment__c p = new Payment__c();
        p.Name = 'payment';
        p.Opportunity__c = o.id;
        p.Transaction_Type__c = 'Payment';
        p.Payment_Amount__c = 500;
        p.Credit_Card_Number__c = '23431231234';
        p.Paid_On__c = System.today();
        p.Payment_Type__c = 'TCS';
        p.Product_Id__c = tOLI.Product_Id__c;
        p.Opportunity_Product__c = tOLI.id;
        insert p;
        
                
        ContentVersion cvlist = new Contentversion(); 
        cvlist.Title = 'Contract_Payment'; 
        cvlist.PathOnClient = 'test'; 
        cvlist.VersionData = EncodingUtil.base64Decode('Unit Test Attachment Body'); 
        List<ContentVersion> cvl = new List<ContentVersion>(); 
        cvl.add(cvlist); 
        insert cvl;

              
        Test.startTest();
        InsertpaymentService ps = new InsertPaymentService();  
        String JsonMsg='{"OpportunityId" : "'+ o.Id +'","sendEmail" : "'+ true +'","Amount":' + p.Payment_Amount__c + ',"CardLast4":' + p.Credit_Card_Number__c + ',"RecType": "WWPT"}';// + ',"CardLast4":' + p.Credit_Card_Number__c +',"PaymentOrd":' + p.Payment_Number__c + ',"PaidOn":' + p.Paid_On__c + ',"CardLastName":' + p.Name + ',"CardFirstName":' + p.name + ',"RecType":"TFG","PaymentTypeStr":"Payment","CardExpdate":"12/12/2019"}';
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = 'services/apexrest/insertpayment/*';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        InsertpaymentService.responsewrapper rp = new InsertpaymentService.responsewrapper();
        
        InsertPaymentService.createRecord();
        test.stopTest();
    } 
  }