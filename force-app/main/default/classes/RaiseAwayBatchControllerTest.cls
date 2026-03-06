@isTest
public class RaiseAwayBatchControllerTest {
    @testSetup
    public static void setupEnvironment() {
        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 standardPricebook = new Pricebook2(
            Id = pricebookId,
            IsActive = true
        );
        update standardPricebook;
        
        Product2 prd1 = new Product2 (Name='Raise Away-Grand Mayan Grand Mayan Master Room',isActive = true, Product_Type__c = 'Base');
        insert prd1;
        
        PricebookEntry pbe1 = new PricebookEntry (Product2ID=prd1.id,Pricebook2ID=standardPricebook.Id,UnitPrice=0, isActive=true);
        insert pbe1;
        
        Product2 prd2 = new Product2 (Name='Vidanta Resort Fee',isActive = true, Product_Type__c = 'Fee');
        insert prd2;
        
        PricebookEntry pbe2 = new PricebookEntry (Product2ID=prd2.id,Pricebook2ID=standardPricebook.Id,UnitPrice=0, isActive=true);
        insert pbe2;
        
        Id leadCarefreeRecTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Carefree_Destinations').getRecordTypeId();
        Lead leadrec = new Lead();
        leadrec.FirstName = 'Test';
        leadrec.LastName = 'Test';
        leadrec.Company = 'test';
        leadrec.LeadSource = 'Raise Away';
        leadrec.Status = 'New';
        leadrec.Phone = '987456321';
        leadrec.Email = 'test@ds.com';
        leadrec.Street = 'Test Street 1';
        leadrec.City = 'Test City';
        leadrec.State = 'CA';
        leadrec.Country = 'US';
        leadrec.PostalCode = '1234';
        leadrec.RecordTypeId = leadCarefreeRecTypeId;
        insert leadrec;
        
    } 
    @isTest 
    public static void assignOpportunityTest() {
        Test.setMock(HttpCalloutMock.class, new VoucherEmailActivationMock()); 
        Test.startTest();
        RaiseAwayBatchController ba= new RaiseAwayBatchController();
        Id jobid= Database.executeBatch(ba,1);
        Test.stopTest();       
    }
}