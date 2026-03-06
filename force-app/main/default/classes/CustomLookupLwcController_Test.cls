@isTest
public class CustomLookupLwcController_Test {
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
    }
    @isTest static void test1() {
        Account objacc = [select id from Account where Name = 'Test Sample'];
    	CustomLookupLwcController.fetchLookupData('Sample','Account');
        CustomLookupLwcController.fetchDefaultRecord(objacc.Id, 'Account');
    }
}