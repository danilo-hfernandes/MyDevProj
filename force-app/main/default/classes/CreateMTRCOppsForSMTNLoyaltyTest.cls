@isTest(SeeAllData=true)
public class CreateMTRCOppsForSMTNLoyaltyTest {
    
    /*@testSetup 
    static void setup() {
        
        Account a = new Account();
        a.Name = 'test account';
        a.Affiliated_Id__c = 1002222;
        a.Preferred_Language__c = 'ENG';
        a.Master_Record_Id__c = 'test';
        a.First_Name__c = 'test';
        a.Last_Name__c = 'test';
        a.Enrollment_Date__c = System.Today();
        insert a;
        
        /*TimeShare__c tm=new timeshare__c();
        tm.name='test';
        tm.Unit_Size__c='1 Bedroom';
        tm.Unit_Type__c='Grand Imperial Jungle Aqua Master Suite';
        tm.Ownership__c='Deeded';        
        tm.Timeshare_Owner__c=a.id;
        tm.Usage__c='Biennial Odd';
        tm.Week__c='2';
        tm.Fees_Billing_Period__c='Annually';
        tm.MF_Paid_Until_Month__c='2';
        tm.MF_Paid_Until_Year__c='2';
        tm.MF_Amount__c=2;
        tm.First_Year_Use__c='2';
        tm.Master_Record_Id__c='2';
        insert tm;
        
        Opportunity opp2= new Opportunity();
        opp2.name='test13';
        opp2.Automated_Hawaii_Opportunity__c=true;
        opp2.accountId=a.Id;
        opp2.CloseDate=system.today();
        opp2.StageName='New';
        opp2.RecordTypeId='0123t000000mliUAAQ';
        insert opp2;       
    }*/
    
    @isTest
    static void testAccCreateOpp(){
        Test.startTest();
        /*Account a = new Account();
        a.Name = 'test account';
        a.Affiliated_Id__c = 1002222;
        a.Preferred_Language__c = 'ENG';
        a.Master_Record_Id__c = 'test';
        a.First_Name__c = 'test';
        a.Last_Name__c = 'test';
        a.Enrollment_Date__c = System.Today();
        insert a;*/
        //Test.setMock(HttpCalloutMock.class, new AssigningContactInCadenceTestMock());
        
        CreateMTRCOppsForSMTNLoyalty instancevar = new CreateMTRCOppsForSMTNLoyalty();
        ID batchprocessid = Database.executeBatch(instancevar);
        Test.stopTest();
        
    }
    
}