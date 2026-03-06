@IsTest
public class ConvertCFDLeadWithProductAndPaymentTest {
    
    @testSetup 
    static void setup() {
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String guid = h.SubString(0,8);
        
        Lead ld = new Lead();
        
        ld.RecordTypeId= '0123t000000dXngAAE';
        ld.FirstName= 'Karol';
        ld.LastName= 'Clopp';
        ld.Status= 'New';
        ld.LeadSource= 'CFD FB Mexico';
        ld.Phone= '3096421828';
        ld.Company= 'VVCompany1828';
        ld.Email='carolklopp1828@gmail.com';
        ld.Street='Street';
        ld.City='City';
        ld.PostalCode='32819';
        ld.State='State';
        ld.Country='Country';
        ld.Lead_Form_External_Id__c=guid;
        ld.Match_Affiliate_Id__c = 1002266;
        
        insert ld;
        
        Account a = new Account();
        a.Name = 'test account';
        a.Affiliated_Id__c = 1002266;        
        insert a;
        
        Contact c = new Contact();
        c.AccountId = a.Id;
        c.LastName = 'test';
        c.AffiliatedId__c = a.Affiliated_Id__c;
        insert c;
        
        Product2 p = new Product2();
        p.Name = 'CFD Mexico Voucher';
        p.isActive = true;
        insert p;
        
        
        id pricebookId = Test.getStandardPricebookId();
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = p.Id, UnitPrice = 499, IsActive = true);
        insert standardPrice;
        
        Membership_Product_Configuration__c mpc = new Membership_Product_Configuration__c();
        mpc.Affiliated_Id__c = String.valueOf(ld.Match_Affiliate_Id__c);
        mpc.Name = 'test';
        
        insert mpc;
        
    }
    
    static testMethod void testConvertLeadNewAccount(){
               
        Lead ld = [SELECT Id,Lead_Form_External_Id__c FROM Lead WHERE Email = 'carolklopp1828@gmail.com'];
        
        Test.startTest();
        
        String guid = ld.Lead_Form_External_Id__c;
        
        //Test.setMock(HttpCalloutMock.class, new ConvertCFDLeadWithProductAndPaymentMock());
                
        String requestJson='{"reqJson": {"Lead_Form_External_Id":"'+guid+'","Add_Cruise":"true"} }';
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = 'services/apexrest/ConvertCFDLeadWithProductAndPayment';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(requestJson);
        RestContext.request = req;
        RestContext.response= res;
        
        ConvertCFDLeadWithProductAndPayment clead = new ConvertCFDLeadWithProductAndPayment();
        
        ConvertCFDLeadWithProductAndPayment.ResponseWrapper rp = new ConvertCFDLeadWithProductAndPayment.ResponseWrapper();
        
        ConvertCFDLeadWithProductAndPayment.requestJson reqJs = new ConvertCFDLeadWithProductAndPayment.requestJson();
        
        reqJs.Lead_Form_External_Id = guid;
        reqJs.Add_Cruise = 'true';
        
        System.debug('reqJs : '+reqJs);
        
        ConvertCFDLeadWithProductAndPayment.GetData(reqJs);
        
        ConvertCFDLeadWithProductAndPayment.GetData(reqJs);

        Test.stopTest();
    }
    
    static testMethod void testConvertLeadExistingAccount(){
        
        
        
        Account a = [SELECT Id,Email__c FROM Account WHERE Name = 'test account'];        
        a.Email__c = 'carolklopp1828@gmail.com';
        update a;
        
        Contact c = [SELECT Id FROM Contact WHERE LastName = 'test'];       
        c.Email = a.Email__c;
        update c;
        
        Lead ld = [SELECT Id,Lead_Form_External_Id__c FROM Lead WHERE Email = 'carolklopp1828@gmail.com'];
        
        Test.startTest();
        
        String guid = ld.Lead_Form_External_Id__c;
        
        //Test.setMock(HttpCalloutMock.class, new ConvertCFDLeadWithProductAndPaymentMock());
                
        String requestJson='{"reqJson": {"Lead_Form_External_Id":"'+guid+'","Add_Cruise":"true"} }';
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = 'services/apexrest/ConvertCFDLeadWithProductAndPayment';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(requestJson);
        RestContext.request = req;
        RestContext.response= res;
        
        ConvertCFDLeadWithProductAndPayment clead = new ConvertCFDLeadWithProductAndPayment();
        
        ConvertCFDLeadWithProductAndPayment.ResponseWrapper rp = new ConvertCFDLeadWithProductAndPayment.ResponseWrapper();
        
        ConvertCFDLeadWithProductAndPayment.requestJson reqJs = new ConvertCFDLeadWithProductAndPayment.requestJson();
        
        reqJs.Lead_Form_External_Id = guid;
        
        System.debug('reqJs : '+reqJs);
        
        ConvertCFDLeadWithProductAndPayment.GetData(reqJs);

        Test.stopTest();
    }

}