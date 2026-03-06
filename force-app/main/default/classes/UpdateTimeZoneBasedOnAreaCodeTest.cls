@isTest
public class UpdateTimeZoneBasedOnAreaCodeTest {
    @testSetup static void testRecords() {
        
        Apex_Trigger_On_Off__c cs = new Apex_Trigger_On_Off__c();
        cs.isEnable__c = true;
        cs.Name = 'LeadDupliateTriggerLogic';
        
        Apex_Trigger_On_Off__c cs2 = new Apex_Trigger_On_Off__c();
        cs2.isEnable__c = true;
        cs2.Name = 'LeadSalesCadenceAssignment';
        
        Apex_Trigger_On_Off__c cs3 = new Apex_Trigger_On_Off__c();
        cs3.isEnable__c = false;
        cs3.Name = 'UpdateTimeZoneAccount';
        
        Apex_Trigger_On_Off__c cs4 = new Apex_Trigger_On_Off__c();
        cs4.isEnable__c = false;
        cs4.Name = 'UpdateTimeZoneLead';
        
        Apex_Trigger_On_Off__c cs5 = new Apex_Trigger_On_Off__c();
        cs5.isEnable__c = true;
        cs5.Name = 'LeadAndAccountTrigger';
        insert cs5;
        
        insert cs;
        insert cs2;
        insert cs3;
        insert cs4;
        
        Account objacc = new Account();
        objacc.Name = 'Test Sample';
        objacc.Phone = '631-00-000';
        insert objacc;
        
        Lead objlead = new Lead();
        objlead.LastName = 'Test Sample';
        objlead.Phone = '631-00-000';
        objlead.Company = '360DC';
        objlead.LeadSource = 'VI Referral';
        objlead.Email = 'test@gmail.com';
        insert objlead;

        Timezone__mdt objtimezone = new Timezone__mdt();
        objtimezone.DeveloperName = 'X631';
        objtimezone.Timezone__c = 'Eastern';
        //insert objtimezone;`	
    }
    @isTest static void test1() { 
        Account objacc = new Account();
        objacc.Name = 'Test Sample';
        objacc.Phone = '631-00-000';
        insert objacc;
        
        List<Account> lstaccount = [select id, Phone, Timezone__c from Account where Name ='Test Sample' limit 1];
        BatchToUpdateAccTimezoneBasedOnAreaCode objbatch = new BatchToUpdateAccTimezoneBasedOnAreaCode();
		Database.executeBatch(objbatch, 10);
        BatchToUpdateLeadTimezoneBasedOnAreaCode objbatchLead = new BatchToUpdateLeadTimezoneBasedOnAreaCode(); 
		Database.executeBatch(objbatchLead);
        UpdateTimeZoneBasedOnAreaCodeController.genericUpdateTimeZone(lstaccount, null, 'Account', null);
    }
}