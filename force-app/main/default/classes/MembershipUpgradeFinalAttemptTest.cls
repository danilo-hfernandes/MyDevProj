@isTest
public class MembershipUpgradeFinalAttemptTest {
    
    @testSetup 
    static void setup() {
        
        Account a = new Account();
        a.Name = 'test account';
        a.Preferred_Language__c = 'ENG';
        a.Membership_Status__c = 'Active';
        insert a;
        
        contact ct = new contact();
        ct.AccountId = a.id;
        ct.LastName = 'test contact';
        ct.Member_Number__c = 'SLV-010-8721701';
        ct.Assign_to_Sales_Cadence__c = false;
        insert ct;
    }
    
    @isTest static void test1() {
        
        Account a = [SELECT Id FROM Account WHERE Name='test account' LIMIT 1];
        Contact con = [SELECT Id FROM Contact WHERE Name='test contact' LIMIT 1];

        Id oppRecordTypeId = [Select id from RecordType where sObjectType = 'Opportunity' and developerName ='Membership_Upgrade' ].id ;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'test opp';
        opp.AccountId = a.id;
        opp.ContactId = con.id;
        opp.StageName = 'Auto Open';
        opp.CloseDate = system.today()-10;
        opp.Opp_Assign_Date__c = system.today()-50;
        opp.RecordTypeId = oppRecordTypeId;
        insert opp;

        Task task = new Task();
        task.WhatId = opp.id;
        task.Status = 'Completed';
        task.Priority = 'Normal';
        task.Subject = 'Call';
        task.ActivityDate = system.today()-10;
		insert task;

        Test.startTest();
        MembershipUpgradeFinalAttempt batch = new MembershipUpgradeFinalAttempt();
        Id batchId = Database.executeBatch(batch);
        Test.stopTest();
    }
    
    @isTest static void test2() {
        
        Account a = [SELECT Id FROM Account WHERE Name='test account' LIMIT 1];
        Contact con = [SELECT Id FROM Contact WHERE Name='test contact' LIMIT 1];

        Id oppRecordTypeId = [Select id from RecordType where sObjectType = 'Opportunity' and developerName ='Hawaii_Collection_Membership' ].id ;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'test opp';
        opp.AccountId = a.id;
        opp.ContactId = con.id;
        opp.StageName = 'Unable to Reach';
        opp.CloseDate = system.today()-10;
        opp.Opp_Assign_Date__c = system.today()-50;
        opp.RecordTypeId = oppRecordTypeId;
        insert opp;

        Task task = new Task();
        task.WhatId = opp.id;
        task.Status = 'Completed';
        task.Priority = 'Normal';
        task.Subject = 'Call';
        task.ActivityDate = system.today()-10;
		insert task;

        Test.startTest();
        MembershipUpgradeFinalAttempt batch = new MembershipUpgradeFinalAttempt();
        Id batchId = Database.executeBatch(batch);
        Test.stopTest();
    }
    
    @isTest static void test3() {
        
        Account a = [SELECT Id FROM Account WHERE Name='test account' LIMIT 1];
        Contact con = [SELECT Id FROM Contact WHERE Name='test contact' LIMIT 1];

        Id oppRecordTypeId = [Select id from RecordType where sObjectType = 'Opportunity' and developerName ='MTRC_Retail' ].id ;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'test opp';
        opp.AccountId = a.id;
        opp.ContactId = con.id;
        opp.StageName = 'Auto Open';
        opp.CloseDate = system.today()-10;
        opp.Opp_Assign_Date__c = system.today()-50;
        opp.RecordTypeId = oppRecordTypeId;
        insert opp;

        Task task = new Task();
        task.WhatId = opp.id;
        task.Status = 'Completed';
        task.Priority = 'Normal';
        task.Subject = 'Call';
        task.ActivityDate = system.today()-10;
		insert task;

        Test.startTest();
        MembershipUpgradeFinalAttempt batch = new MembershipUpgradeFinalAttempt();
        Id batchId = Database.executeBatch(batch);
        Test.stopTest();
    }
    
    @isTest static void test4() {
        
        Account a = [SELECT Id FROM Account WHERE Name='test account' LIMIT 1];
        Contact con = [SELECT Id FROM Contact WHERE Name='test contact' LIMIT 1];

        Id oppRecordTypeId = [Select id from RecordType where sObjectType = 'Opportunity' and developerName ='SFX_Membership' ].id ;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'test opp';
        opp.AccountId = a.id;
        opp.ContactId = con.id;
        opp.StageName = 'Attempting to Contact 3';
        opp.CloseDate = system.today()-10;
        opp.Opp_Assign_Date__c = system.today()-50;
        opp.RecordTypeId = oppRecordTypeId;
        insert opp;

        Task task = new Task();
        task.WhatId = opp.id;
        task.Status = 'Completed';
        task.Priority = 'Normal';
        task.Subject = 'Call';
        task.ActivityDate = system.today()-10;
		insert task;

        Test.startTest();
        MembershipUpgradeFinalAttempt batch = new MembershipUpgradeFinalAttempt();
        Id batchId = Database.executeBatch(batch);
        Test.stopTest();
    }
}