@isTest
public class AssignRemainingHCOppportunityTest {
    @isTest 
    public static void assignOwnersTest() {
        
        Apex_Trigger_On_Off__c cs3 = new Apex_Trigger_On_Off__c();
        cs3.isEnable__c = true;
        cs3.Name = 'UpdateTimeZoneAccount';
        insert cs3;
        
        Apex_Trigger_On_Off__c cs5 = new Apex_Trigger_On_Off__c();
        cs5.isEnable__c = true;
        cs5.Name = 'LeadAndAccountTrigger';
        insert cs5;
        
        Account acc = new Account();
        acc.Name = 'Testaa1';
        acc.First_Name__c='Test';
        acc.last_Name__c='Test';
        acc.email__c='test@g.com';
        acc.Affiliated_Id__c=1002243;
        acc.TRM_Owner_Flag__c='Yes';
        acc.Enrollment_Date__c = System.today() - 10;
        Insert acc;
        
        Opportunity opp= new Opportunity();
        opp.name='test11';
        opp.Automated_Hawaii_Opportunity__c=true;
        opp.accountId=acc.Id;
        opp.CloseDate=system.today();
        opp.StageName='New';
        opp.RecordTypeId='0123t000000mliUAAQ';
        insert opp;
        
        Task objtask = new Task();
        objtask.Subject = 'Membership Upgrade-Call 1';
        objtask.ActivityDate = System.today();
        objtask.WhatId = opp.Id;
       // objtask.OwnerId = opp.OwnerId;
        insert objtask;
        
        Test.startTest();
        AssignRemainingHCOppportunity ba= new AssignRemainingHCOppportunity();
        Id jobid= Database.executeBatch(ba,20);
        Test.stopTest();       
    }
}