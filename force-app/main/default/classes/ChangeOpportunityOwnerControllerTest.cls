@isTest
public class ChangeOpportunityOwnerControllerTest {
    @testSetup static void testRecords() {
        Apex_Trigger_On_Off__c mm = new Apex_Trigger_On_Off__c();
        mm.Name = 'LeadAndAccountTrigger';
        mm.isEnable__c = true;
        insert mm;
        
        Apex_Trigger_On_Off__c mm1 = new Apex_Trigger_On_Off__c();
        mm1.Name = 'UpdateTimeZoneAccount';
        mm1.isEnable__c = true;
        insert mm1;
        
            
        Account objacc = new Account();
        objacc.Name = 'Test Sample';
        objacc.Phone = '631-00-000';
        insert objacc;
        
        Contact objcon = new Contact();
        objcon.LastName = 'Sample Test';
        objcon.email = 'testSample@gmail.com';
        insert objcon;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Mitul Test';
        opp.AccountId = objacc.Id;
        opp.StageName = 'New';
        opp.CloseDate = system.today();
        insert opp;
    }
    @isTest static void test1() {
        Test.startTest();
        List<Opportunity> oppList = [select id from Opportunity where Name = 'Test Sample' limit 1];
        list<Id> setConId = new list<Id>();
        setConId.add(oppList[0].Id);
        Test.setCurrentPage(Page.ChangeOpportunityOwner);
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(oppList);
        stdSetController.setSelected(oppList);
        ChangeOpportunityOwnerController ext = new ChangeOpportunityOwnerController(stdSetController);
        ChangeOpportunityOwnerController.updateOpportunityOwner(setConId, UserInfo.getUserId());
        Test.stopTest();
    }
}