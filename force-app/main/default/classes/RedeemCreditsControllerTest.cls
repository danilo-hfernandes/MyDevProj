@isTest
public class RedeemCreditsControllerTest {
    @isTest
    static void getCreditsDataTest(){
        Account acc = new Account(Name = 'Test Account', Affiliated_Id__c = 1235, Member_Number__c = '13523412', Membership_Annual_Due__c = 149, First_Name__c ='Test' , Last_Name__c = 'Account');
        insert acc;
        
        Id mAnnualDuesRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Membership_Annual_Dues').getRecordTypeId();
        Opportunity opp2 = new Opportunity (Name='Opp2',StageName='New',CloseDate=Date.today(),AccountId = acc.id, RecordTypeId = mAnnualDuesRecordTypeId);
        insert opp2;
        
        Id standardPbId = Test.getStandardPricebookId();
        
        Product2 prd1 = new Product2 (Name='Annual Dues-Renewal',isActive = true);
        insert prd1;
        
        PricebookEntry pbe1 = new PricebookEntry (Product2ID=prd1.id,Pricebook2ID=standardPbId,UnitPrice=0, isActive=true);
        insert pbe1;
        
        OpportunityLineItem lineItem1 = new OpportunityLineItem (OpportunityID=opp2.id,Product2Id = prd1.Id,PriceBookEntryID=pbe1.id, quantity=1, totalprice=149, retail_price__c = 149);
        insert lineItem1;
        
        Test.setMock(HttpCalloutMock.class, new ApplyCreditsControllerTest.MockGetMemberCreditsHttpResponseGenerator());
        Test.startTest();
        
        RedeemCreditsController.getCreditsData(opp2.Id);
        RedeemCreditsController.createPaymentRecord(opp2.Id,149,149);
        
        Test.stopTest();
    }


}