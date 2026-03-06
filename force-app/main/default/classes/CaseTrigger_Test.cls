@isTest
public class CaseTrigger_Test {
    @isTest
    static void test1() {
        Apex_Trigger_On_Off__c obj = new Apex_Trigger_On_Off__c();
        obj.Name = 'Case Trigger';
        obj.isEnable__c = true;
        insert obj; 
        
        User u = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
            LastName = 'last',
            Email = 'puser000@amamama.com',
            Username = 'puser000@amamama.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            Tee_Up_Agent__c = true
        );
        insert u;
        
        Account a = new Account();
        a.Name = 'test account';
        a.Member_Number__c = 'SLV-010-8721701';
        insert a;
        
        contact ct = new contact();
        ct.AccountId = a.id;
        ct.LastName = 'test account';
        insert ct;
        
        Id oppRecordTypeId = [Select id from RecordType where sObjectType = 'Opportunity' and developerName ='Membership_Upgrade' ].id ;
        Case c = new Case();
        c.Status = 'New';
        c.Member_Number__c = 'SLV-010-8721701';
        c.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Exchanges_and_Deposits').getRecordTypeId();
        c.AccountId = a.id;
        c.OwnerId = [SELECT Id,Name FROM Group WHERE Type = 'Queue' AND Name = 'Exchanges and Deposits'].Id;
        c.Profile_Name__c = 'Internal Credits';
        insert c;
        
        Opportunity o = new Opportunity();
        o.name = 'test opp';
        o.CloseDate = System.today();
        o.AccountId = c.AccountId;
        o.RecordTypeId = oppRecordTypeId;
        o.StageName = 'In Process';
        
        insert o;
        c.OwnerId = u.Id;
        update c;
    }
    @isTest
    static void test2() {
        Apex_Trigger_On_Off__c obj = new Apex_Trigger_On_Off__c();
        obj.Name = 'Case Trigger';
        obj.isEnable__c = true;
        insert obj; 
        
        User u = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
            LastName = 'last',
            Email = 'puser000@amamama.com',
            Username = 'puser000@amamama.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            Tee_Up_Agent__c = true
        );
        
        insert u;
        
        
        Account a = new Account();
        a.Name = 'test account';
        insert a;
        
        contact ct = new contact();
        ct.AccountId = a.id;
        ct.LastName = 'test account';
        ct.Member_Number__c = 'SLV-010-8721701';
        insert ct;
        
        Id oppRecordTypeId = [Select id from RecordType where sObjectType = 'Opportunity' and developerName ='Membership_Upgrade' ].id ;
        Case c = new Case();
        c.Status = 'Working On It';
        c.Tee_Up_Agent__c = u.id;
        c.Membership_Upgrade_Opportunity__c = 'Yes';
        c.Member_Number__c = 'SLV-010-8721701';
        c.AccountId = a.id;
        
        insert c;
        
        Opportunity o = new Opportunity();
        o.name = 'test opp';
        o.CloseDate = System.today();
        o.AccountId = c.AccountId;
        o.RecordTypeId = oppRecordTypeId;
        o.StageName = 'In Process';
        
        insert o;
        update c;
    }
    @isTest
    static void test3() {
        
        User u = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
            LastName = 'last',
            Email = 'puser000@amamama.com',
            Username = 'puser000@amamama.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            Tee_Up_Agent__c = true
            
        );
        
        insert u;
        
        Account a = new Account();
        a.Name = 'test account';
        insert a;
        
        contact ct = new contact();
        ct.AccountId = a.id;
        ct.LastName = 'test account';
        ct.Member_Number__c = 'SLV-010-8721701';
        insert ct;
        
        Id caseRecordTypeId = [Select id from RecordType where sObjectType = 'Case' and developerName ='Flight_Confirmation' ].id ;
        Case c = new Case();
        c.Status = 'Working On It';
        c.Tee_Up_Agent__c = u.id;
        c.RecordTypeId=caseRecordTypeId;
        c.Check_in_Date__c=system.today()-15;
        c.Membership_Upgrade_Opportunity__c = 'Yes';
        c.Member_Number__c = 'SLV-010-8721701';
        c.AccountId = a.id;
        
        insert c;
        
        Test.setMock(HttpCalloutMock.class, new AssigningContactInCadenceTestMock());  
        
    }
    @isTest
    static void test4() {
        
        User u = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
            LastName = 'last',
            Email = 'puser000@amamama.com',
            Username = 'puser000@amamama.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            Tee_Up_Agent__c = true
            
        );
        
        insert u;
        
        
        Account a = new Account();
        a.Name = 'test account';
        insert a;
        
        contact ct = new contact();
        ct.AccountId = a.id;
        ct.LastName = 'test account';
        ct.Member_Number__c = 'SLV-010-8721701';
        insert ct;
        
        Id caseRecordTypeId = [Select id from RecordType where sObjectType = 'Case' and developerName ='Flight_Confirmation' ].id ;
        Case c = new Case();
        c.Status = 'Working On It';
        c.Tee_Up_Agent__c = u.id;
        c.RecordTypeId=caseRecordTypeId;
        c.Check_in_Date__c=system.today()-45;
        c.Membership_Upgrade_Opportunity__c = 'Yes';
        c.Member_Number__c = 'SLV-010-8721701';
        c.AccountId = a.id;
        
        insert c;
        
        Test.setMock(HttpCalloutMock.class, new AssigningContactInCadenceTestMock());  
    }
    @isTest
    static void test5() {
        
        User u = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
            LastName = 'last',
            Email = 'puser000@amamama.com',
            Username = 'puser000@amamama.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            Tee_Up_Agent__c = true
            
        );
        
        insert u;
        
        
        Account a = new Account();
        a.Name = 'test account';
        insert a;
        
        contact ct = new contact();
        ct.AccountId = a.id;
        ct.LastName = 'test account';
        ct.Member_Number__c = 'SLV-010-8721701';
        insert ct;
        
        /*Id caseRecordTypeId = [Select id from RecordType where sObjectType = 'Case' and developerName ='Guest_Voucher' ].id ;
Case c = new Case();
c.Status = 'Working On It';
c.Tee_Up_Agent__c = u.id;
c.RecordTypeId=caseRecordTypeId;
c.Check_in_Date__c=system.today()-45;
c.Membership_Upgrade_Opportunity__c = 'Yes';
c.Member_Number__c = 'SLV-010-8721701';
c.AccountId = a.id;

insert c;*/
        
    }
    
    @testSetup 
    static void setup() {
        Apex_Trigger_On_Off__c obj = new Apex_Trigger_On_Off__c();
        obj.Name = 'Case Trigger';
        obj.isEnable__c = true;
        insert obj; 
        
        User u = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
            LastName = 'last',
            Email = 'puser000@amamama.com',
            Username = 'puser000@amamama.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            Tee_Up_Agent__c = true
        );   
        insert u;
        
        Account a = new Account();
        a.Name = 'test account';
        insert a;
        
        contact ct = new contact();
        ct.AccountId = a.id;
        ct.LastName = 'test account';
        ct.Member_Number__c = 'SLV-010-8721701';
        insert ct;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'test opp';
        opp.AccountId = a.id;
        opp.StageName = 'Closed Refunded';
        opp.CloseDate = system.today()-15;
        insert opp;
        
        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Exchanges_and_Deposits').getRecordTypeId();
        Id exchangeAndDepositQueueId = [SELECT Id,Name FROM Group WHERE Type = 'Queue' AND Name = 'Exchanges and Deposits'].Id;
        
        Case cs = new Case();
        cs.Status = 'New';
        cs.Tee_Up_Agent__c = u.id;
        cs.RecordTypeId=caseRecordTypeId;
        cs.Check_in_Date__c=system.today()-45;
        cs.Membership_Upgrade_Opportunity__c = 'Yes';
        cs.Member_Number__c = 'SLV-010-8721701';
        cs.AccountId = a.id;
        cs.OwnerId = u.id;
        insert cs;
        
        Timeshare__c ts = new Timeshare__c();
        ts.Name = 'Test Imperial Garden';
        ts.Unit_Size__c = '1 Bedroom';
        ts.Ownership__c = 'A&A';
        ts.Fees_Billing_Period__c = 'Annually';
        ts.Usage__c = 'Annual';
        ts.MF_Amount__c = 12;
        ts.Week_Type__c = 'Fixed';
        ts.Week__c = '12';
        ts.First_Year_Use__c = '12';
        ts.Timeshare_Owner__c = a.Id;
        insert ts;
        
        cs.Ownership_Resort_Timeshare__c = ts.Id;
        update cs;        
        
    }
    
    @isTest
    static void test6() {
        
        Apex_Trigger_On_Off__c obj = new Apex_Trigger_On_Off__c();
        obj.Name = 'Case Trigger';
        obj.isEnable__c = true;
        insert obj; 
        
        
        Account acct = [SELECT Id FROM Account WHERE Name='test account' LIMIT 1];
        User u = [SELECT Id FROM User WHERE LastName='last' LIMIT 1];
        
        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Exchanges_and_Deposits').getRecordTypeId();
        Id exchangeAndDepositQueueId = [SELECT Id,Name FROM Group WHERE Type = 'Queue' AND Name = 'Exchanges and Deposits'].Id;
        
        Timeshare__c ts = new Timeshare__c();
        ts.Name = 'Test Imperial Garden';
        ts.Unit_Size__c = '1 Bedroom';
        ts.Ownership__c = 'A&A';
        ts.Fees_Billing_Period__c = 'Annually';
        ts.Usage__c = 'Annual';
        ts.MF_Amount__c = 12;
        ts.Week_Type__c = 'Fixed';
        ts.Week__c = '12';
        ts.First_Year_Use__c = '12';
        ts.Timeshare_Owner__c = acct.Id;
        insert ts;
        
        Case c = [select id, OwnerId from Case limit 1];
        Test.startTest();
        //c.Tee_Up_Agent__c = null;
        c.OwnerId = exchangeAndDepositQueueId;
        c.Ownership_Resort_Timeshare__c = ts.Id;
        update c;
        Test.stopTest();
    }
}