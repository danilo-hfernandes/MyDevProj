@isTest
public class MU_SalesCadenceQueueableTest {
    
	@isTest static void test1() {
        
        Account a = new Account();
        a.Name = 'test account';
        a.Preferred_Language__c = 'ENG';
        a.Membership_Status__c = 'Active';
        insert a;
        
        contact ct = new contact();
        ct.AccountId = a.id;
        ct.LastName = 'test contact';
        ct.Member_Number__c = 'SLV-010-8721701';
        insert ct;
        
        Test.setMock(HttpCalloutMock.class, new AssignContactTourGenLoyaltyTestMock());  
        Test.startTest();
        Set<Id> recordIds = new Set<Id>{ct.Id};
        String salesCadenceName = 'TourGen-SMTN Loyalty';
        MembershipUpgradeSalesCadenceQueueable queueable = new MembershipUpgradeSalesCadenceQueueable(recordIds, salesCadenceName);
        Id queueableId = System.enqueueJob(queueable);
        Test.stopTest();
    }
}