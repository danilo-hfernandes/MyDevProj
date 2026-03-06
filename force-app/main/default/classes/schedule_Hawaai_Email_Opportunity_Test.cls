@isTest
public class schedule_Hawaai_Email_Opportunity_Test {
    
    
    @isTest 
    public static void assignOwnersTestTRM() {
        
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
        acc.Enrollment_Date__c = System.today() - 15;
        Insert acc;
        
        Opportunity opp= new Opportunity();
        opp.name='test11';
        opp.Automated_Hawaii_Opportunity__c=true;
        opp.accountId=acc.Id;
        opp.CloseDate=system.today();
        opp.StageName='New';
        opp.RecordTypeId='0123t000000mliUAAQ';
        insert opp;
        
        //List<Opportunity> oppList = [SELECT Id,Name,Account_Enrollment_Date__c,Account_Affiliate_Id__c,AccountId,Account.email__c,leadassist__Use_Round_Robin__c,Account.TRM_Owner_Flag__c,Account.Preferred_Language__c,Membership_Upgrade_Group__c FROM Opportunity WHERE name = 'test11'];  
        // system.debug('82 test='+opp.Account_Enrollment_Date__c);
        //ystem.debug('83 test ='+opp.Account_Affiliate_Id__c);
        // Set mock callout class     
        // Test.setMock(HttpCalloutMock.class, new AssignContactInOverflowCadenceTestMock());  
        Test.startTest();
        schedule_Hawaai_Email_Opportunity ba= new schedule_Hawaai_Email_Opportunity();
        Id jobid= Database.executeBatch(ba,20);
        Test.stopTest();       
    }
    
    @isTest 
    public static void assignOwnersTest2GradeTRM() {
        
        Apex_Trigger_On_Off__c cs3 = new Apex_Trigger_On_Off__c();
        cs3.isEnable__c = true;
        cs3.Name = 'UpdateTimeZoneAccount';
        insert cs3;
        
        Apex_Trigger_On_Off__c cs5 = new Apex_Trigger_On_Off__c();
        cs5.isEnable__c = true;
        cs5.Name = 'LeadAndAccountTrigger';
        insert cs5;
        Account acc2 = new Account();
        acc2.Name = 'Test2aa2';
         acc2.First_Name__c='Test';
        acc2.last_Name__c='Test';
        acc2.email__c='test2@g.com';
        acc2.Preferred_Language__c='ENG';
        acc2.Affiliated_Id__c=1002243;
        acc2.TRM_Owner_Flag__c='Yes';
        acc2.Enrollment_Date__c = System.today() - 40;
        Insert acc2;
        
        TimeShare__c tm=new timeshare__c();
        tm.name='test';
        tm.Unit_Size__c='1 Bedroom';
        tm.Unit_Type__c='Grand Imperial Jungle Aqua Master Suite';
        tm.Ownership__c='Deeded';        
        tm.Timeshare_Owner__c=acc2.id;
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
        opp2.accountId=acc2.Id;
        opp2.CloseDate=system.today();
        opp2.StageName='New';
        opp2.RecordTypeId='0123t000000mliUAAQ';
        insert opp2;
        
        //List<Opportunity> oppList = [SELECT Id,Name,Account_Enrollment_Date__c,Account_Affiliate_Id__c,AccountId,Account.email__c,leadassist__Use_Round_Robin__c,Account.TRM_Owner_Flag__c,Account.Preferred_Language__c,Membership_Upgrade_Group__c FROM Opportunity WHERE name = 'test11'];  
        // system.debug('82 test='+opp.Account_Enrollment_Date__c);
        //ystem.debug('83 test ='+opp.Account_Affiliate_Id__c);
        // Set mock callout class     
        // Test.setMock(HttpCalloutMock.class, new AssignContactInOverflowCadenceTestMock());  
        Test.startTest();
        schedule_Hawaai_Email_Opportunity ba= new schedule_Hawaai_Email_Opportunity();
        Id jobid= Database.executeBatch(ba,20);
        Test.stopTest();       
    }
    
    @isTest 
    public static void assignOwnersTest2Grade() {
        
        Apex_Trigger_On_Off__c cs3 = new Apex_Trigger_On_Off__c();
        cs3.isEnable__c = true;
        cs3.Name = 'UpdateTimeZoneAccount';
        insert cs3;
        
        Apex_Trigger_On_Off__c cs5 = new Apex_Trigger_On_Off__c();
        cs5.isEnable__c = true;
        cs5.Name = 'LeadAndAccountTrigger';
        insert cs5;
        Account acc2 = new Account();
        acc2.Name = 'Test2aa2';
         acc2.First_Name__c='Test';
        acc2.last_Name__c='Test';
        acc2.email__c='test2@g.com';
        acc2.Preferred_Language__c='ENG';
        acc2.Affiliated_Id__c=1002243;
        acc2.TRM_Owner_Flag__c='No';
        acc2.Enrollment_Date__c = System.today() - 50;
        Insert acc2;
        
        TimeShare__c tm=new timeshare__c();
        tm.name='test';
        tm.Unit_Size__c='1 Bedroom';
        tm.Unit_Type__c='Grand Imperial Jungle Aqua Master Suite';
        tm.Ownership__c='Deeded';        
        tm.Timeshare_Owner__c=acc2.id;
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
        opp2.accountId=acc2.Id;
        opp2.CloseDate=system.today();
        opp2.StageName='New';
        opp2.RecordTypeId='0123t000000mliUAAQ';
        insert opp2;
        
        //List<Opportunity> oppList = [SELECT Id,Name,Account_Enrollment_Date__c,Account_Affiliate_Id__c,AccountId,Account.email__c,leadassist__Use_Round_Robin__c,Account.TRM_Owner_Flag__c,Account.Preferred_Language__c,Membership_Upgrade_Group__c FROM Opportunity WHERE name = 'test11'];  
        // system.debug('82 test='+opp.Account_Enrollment_Date__c);
        //ystem.debug('83 test ='+opp.Account_Affiliate_Id__c);
        // Set mock callout class     
        // Test.setMock(HttpCalloutMock.class, new AssignContactInOverflowCadenceTestMock());  
        Test.startTest();
        schedule_Hawaai_Email_Opportunity ba= new schedule_Hawaai_Email_Opportunity();
        Id jobid= Database.executeBatch(ba,20);
        Test.stopTest();       
    }
    
    
    @isTest 
    public static void assignOwnersTest3SPATRM() {
        
        Apex_Trigger_On_Off__c cs3 = new Apex_Trigger_On_Off__c();
        cs3.isEnable__c = true;
        cs3.Name = 'UpdateTimeZoneAccount';
        insert cs3;
        
        Apex_Trigger_On_Off__c cs5 = new Apex_Trigger_On_Off__c();
        cs5.isEnable__c = true;
        cs5.Name = 'LeadAndAccountTrigger';
        insert cs5;
        Account acc = new Account();
        acc.Name = 'Testaa33';
         acc.First_Name__c='Test';
        acc.last_Name__c='Test';
        acc.email__c='test@g.com';
        acc.Affiliated_Id__c=1002243;
        acc.TRM_Owner_Flag__c='Yes';
        acc.Preferred_Language__c='SPA';
        acc.Enrollment_Date__c = System.today() - 61;
        Insert acc;
        
        Opportunity opp= new Opportunity();
        opp.name='test11';
        opp.Automated_Hawaii_Opportunity__c=true;
        opp.accountId=acc.Id;
        opp.CloseDate=system.today();
        opp.StageName='New';
        opp.RecordTypeId='0123t000000mliUAAQ';
        insert opp;
        
        //List<Opportunity> oppList = [SELECT Id,Name,Account_Enrollment_Date__c,Account_Affiliate_Id__c,AccountId,Account.email__c,leadassist__Use_Round_Robin__c,Account.TRM_Owner_Flag__c,Account.Preferred_Language__c,Membership_Upgrade_Group__c FROM Opportunity WHERE name = 'test11'];  
        // system.debug('82 test='+opp.Account_Enrollment_Date__c);
        //ystem.debug('83 test ='+opp.Account_Affiliate_Id__c);
        // Set mock callout class     
        // Test.setMock(HttpCalloutMock.class, new AssignContactInOverflowCadenceTestMock());  
        Test.startTest();
        schedule_Hawaai_Email_Opportunity ba= new schedule_Hawaai_Email_Opportunity();
        Id jobid= Database.executeBatch(ba,20);
        Test.stopTest();       
    }
    
    @isTest 
    public static void assignOwnersTest3SPA() {
        
        Apex_Trigger_On_Off__c cs3 = new Apex_Trigger_On_Off__c();
        cs3.isEnable__c = true;
        cs3.Name = 'UpdateTimeZoneAccount';
        insert cs3;
        
        Apex_Trigger_On_Off__c cs5 = new Apex_Trigger_On_Off__c();
        cs5.isEnable__c = true;
        cs5.Name = 'LeadAndAccountTrigger';
        insert cs5;
        Account acc = new Account();
        acc.Name = 'Testaa33';
         acc.First_Name__c='Test';
        acc.last_Name__c='Test';
        acc.email__c='test@g.com';
        acc.Affiliated_Id__c=1002243;
        acc.TRM_Owner_Flag__c='No';
        acc.Preferred_Language__c='SPA';
        acc.Enrollment_Date__c = System.today() - 61;
        Insert acc;
        
        Opportunity opp= new Opportunity();
        opp.name='test11';
        opp.Automated_Hawaii_Opportunity__c=true;
        opp.accountId=acc.Id;
        opp.CloseDate=system.today();
        opp.StageName='New';
        opp.RecordTypeId='0123t000000mliUAAQ';
        insert opp;
        
        //List<Opportunity> oppList = [SELECT Id,Name,Account_Enrollment_Date__c,Account_Affiliate_Id__c,AccountId,Account.email__c,leadassist__Use_Round_Robin__c,Account.TRM_Owner_Flag__c,Account.Preferred_Language__c,Membership_Upgrade_Group__c FROM Opportunity WHERE name = 'test11'];  
        // system.debug('82 test='+opp.Account_Enrollment_Date__c);
        //ystem.debug('83 test ='+opp.Account_Affiliate_Id__c);
        // Set mock callout class     
        // Test.setMock(HttpCalloutMock.class, new AssignContactInOverflowCadenceTestMock());  
        Test.startTest();
        schedule_Hawaai_Email_Opportunity ba= new schedule_Hawaai_Email_Opportunity();
        Id jobid= Database.executeBatch(ba,20);
        Test.stopTest();       
    }
    
    @isTest 
    public static void assignOwnersTest4GradeABTRM() {
        
        Apex_Trigger_On_Off__c cs3 = new Apex_Trigger_On_Off__c();
        cs3.isEnable__c = true;
        cs3.Name = 'UpdateTimeZoneAccount';
        insert cs3;
        
        Apex_Trigger_On_Off__c cs5 = new Apex_Trigger_On_Off__c();
        cs5.isEnable__c = true;
        cs5.Name = 'LeadAndAccountTrigger';
        insert cs5;
        Account acc2 = new Account();
        acc2.Name = 'Test2aa4';
         acc2.First_Name__c='Test';
        acc2.last_Name__c='Test';
        acc2.email__c='test2@g.com';
        acc2.Preferred_Language__c='SPA';
        acc2.Affiliated_Id__c=1002243;
        acc2.TRM_Owner_Flag__c='Yes';
        acc2.Enrollment_Date__c = System.today() - 61;
        Insert acc2;
        
        TimeShare__c tm=new timeshare__c();
        tm.name='Imperial Gardens Nuevo Vallarta';
        tm.Unit_Size__c='1 Bedroom';
        tm.Unit_Type__c='1 Bdrm. 2 Bth Suite';
        tm.Ownership__c='Deeded';        
        tm.Timeshare_Owner__c=acc2.id;
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
        opp2.accountId=acc2.Id;
        opp2.CloseDate=system.today();
        opp2.StageName='New';
        opp2.RecordTypeId='0123t000000mliUAAQ';
        insert opp2;
        
        //List<Opportunity> oppList = [SELECT Id,Name,Account_Enrollment_Date__c,Account_Affiliate_Id__c,AccountId,Account.email__c,leadassist__Use_Round_Robin__c,Account.TRM_Owner_Flag__c,Account.Preferred_Language__c,Membership_Upgrade_Group__c FROM Opportunity WHERE name = 'test11'];  
        // system.debug('82 test='+opp.Account_Enrollment_Date__c);
        //ystem.debug('83 test ='+opp.Account_Affiliate_Id__c);
        // Set mock callout class     
        // Test.setMock(HttpCalloutMock.class, new AssignContactInOverflowCadenceTestMock());  
        Test.startTest();
        schedule_Hawaai_Email_Opportunity ba= new schedule_Hawaai_Email_Opportunity();
        Id jobid= Database.executeBatch(ba,20);
        Test.stopTest();       
    }
    
    @isTest 
    public static void assignOwnersTest4GradeAB() {
        
        Apex_Trigger_On_Off__c cs3 = new Apex_Trigger_On_Off__c();
        cs3.isEnable__c = true;
        cs3.Name = 'UpdateTimeZoneAccount';
        insert cs3;
        
        Apex_Trigger_On_Off__c cs5 = new Apex_Trigger_On_Off__c();
        cs5.isEnable__c = true;
        cs5.Name = 'LeadAndAccountTrigger';
        insert cs5;
        Account acc2 = new Account();
        acc2.Name = 'Test2aa4';
         acc2.First_Name__c='Test';
        acc2.last_Name__c='Test';
        acc2.email__c='test2@g.com';
        acc2.Preferred_Language__c='SPA';
        acc2.Affiliated_Id__c=1002243;
        acc2.TRM_Owner_Flag__c='No';
        acc2.Enrollment_Date__c = System.today() - 61;
        Insert acc2;
        
        TimeShare__c tm=new timeshare__c();
        tm.name='Imperial Gardens Nuevo Vallarta';
        tm.Unit_Size__c='1 Bedroom';
        tm.Unit_Type__c='1 Bdrm. 2 Bth Suite';
        tm.Ownership__c='Deeded';        
        tm.Timeshare_Owner__c=acc2.id;
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
        opp2.accountId=acc2.Id;
        opp2.CloseDate=system.today();
        opp2.StageName='New';
        opp2.RecordTypeId='0123t000000mliUAAQ';
        insert opp2;
        
        //List<Opportunity> oppList = [SELECT Id,Name,Account_Enrollment_Date__c,Account_Affiliate_Id__c,AccountId,Account.email__c,leadassist__Use_Round_Robin__c,Account.TRM_Owner_Flag__c,Account.Preferred_Language__c,Membership_Upgrade_Group__c FROM Opportunity WHERE name = 'test11'];  
        // system.debug('82 test='+opp.Account_Enrollment_Date__c);
        //ystem.debug('83 test ='+opp.Account_Affiliate_Id__c);
        // Set mock callout class     
        // Test.setMock(HttpCalloutMock.class, new AssignContactInOverflowCadenceTestMock());  
        Test.startTest();
        schedule_Hawaai_Email_Opportunity ba= new schedule_Hawaai_Email_Opportunity();
        Id jobid= Database.executeBatch(ba,20);
        Test.stopTest();       
    }
    
    @isTest 
    public static void assignOwnersTest5GradeCTRM() {
        
        Apex_Trigger_On_Off__c cs3 = new Apex_Trigger_On_Off__c();
        cs3.isEnable__c = true;
        cs3.Name = 'UpdateTimeZoneAccount';
        insert cs3;
        
        Apex_Trigger_On_Off__c cs5 = new Apex_Trigger_On_Off__c();
        cs5.isEnable__c = true;
        cs5.Name = 'LeadAndAccountTrigger';
        insert cs5;
        Account acc2 = new Account();
        acc2.Name = 'Test2aa5';
         acc2.First_Name__c='Test';
        acc2.last_Name__c='Test';
        acc2.email__c='test2@g.com';
        acc2.Preferred_Language__c='ENG';
        acc2.Affiliated_Id__c=1002243;
        acc2.TRM_Owner_Flag__c='Yes';
        acc2.Enrollment_Date__c = System.today() - 45;
        Insert acc2;
        
        TimeShare__c tm=new timeshare__c();
        tm.name='Imperial Jungle Aqua';
        tm.Unit_Size__c='1 Bedroom';
        tm.Unit_Type__c='Imperial Jungle Aqua Suite';
        tm.Ownership__c='Deeded';        
        tm.Timeshare_Owner__c=acc2.id;
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
        opp2.accountId=acc2.Id;
        opp2.CloseDate=system.today();
        opp2.StageName='New';
        opp2.RecordTypeId='0123t000000mliUAAQ';
        insert opp2;
        
        //List<Opportunity> oppList = [SELECT Id,Name,Account_Enrollment_Date__c,Account_Affiliate_Id__c,AccountId,Account.email__c,leadassist__Use_Round_Robin__c,Account.TRM_Owner_Flag__c,Account.Preferred_Language__c,Membership_Upgrade_Group__c FROM Opportunity WHERE name = 'test11'];  
        // system.debug('82 test='+opp.Account_Enrollment_Date__c);
        //ystem.debug('83 test ='+opp.Account_Affiliate_Id__c);
        // Set mock callout class     
        // Test.setMock(HttpCalloutMock.class, new AssignContactInOverflowCadenceTestMock());  
        Test.startTest();
        schedule_Hawaai_Email_Opportunity ba= new schedule_Hawaai_Email_Opportunity();
        Id jobid= Database.executeBatch(ba,20);
        Test.stopTest();       
    }
    
    @isTest 
    public static void assignOwnersTest5GradeC() {
        
        Apex_Trigger_On_Off__c cs3 = new Apex_Trigger_On_Off__c();
        cs3.isEnable__c = true;
        cs3.Name = 'UpdateTimeZoneAccount';
        insert cs3;
        
        Apex_Trigger_On_Off__c cs5 = new Apex_Trigger_On_Off__c();
        cs5.isEnable__c = true;
        cs5.Name = 'LeadAndAccountTrigger';
        insert cs5;
        Account acc2 = new Account();
        acc2.Name = 'Test2aa5';
         acc2.First_Name__c='Test';
        acc2.last_Name__c='Test';
        acc2.email__c='test2@g.com';
        acc2.Preferred_Language__c='ENG';
        acc2.Affiliated_Id__c=1002243;
        acc2.TRM_Owner_Flag__c='No';
        acc2.Enrollment_Date__c = System.today() - 42;
        Insert acc2;
        
        TimeShare__c tm=new timeshare__c();
        tm.name='Imperial Jungle Aqua';
        tm.Unit_Size__c='1 Bedroom';
        tm.Unit_Type__c='Imperial Jungle Aqua Suite';
        tm.Ownership__c='Deeded';        
        tm.Timeshare_Owner__c=acc2.id;
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
        opp2.accountId=acc2.Id;
        opp2.CloseDate=system.today();
        opp2.StageName='New';
        opp2.RecordTypeId='0123t000000mliUAAQ';
        insert opp2;
        
        //List<Opportunity> oppList = [SELECT Id,Name,Account_Enrollment_Date__c,Account_Affiliate_Id__c,AccountId,Account.email__c,leadassist__Use_Round_Robin__c,Account.TRM_Owner_Flag__c,Account.Preferred_Language__c,Membership_Upgrade_Group__c FROM Opportunity WHERE name = 'test11'];  
        // system.debug('82 test='+opp.Account_Enrollment_Date__c);
        //ystem.debug('83 test ='+opp.Account_Affiliate_Id__c);
        // Set mock callout class     
        // Test.setMock(HttpCalloutMock.class, new AssignContactInOverflowCadenceTestMock());  
        Test.startTest();
        schedule_Hawaai_Email_Opportunity ba= new schedule_Hawaai_Email_Opportunity();
        Id jobid= Database.executeBatch(ba,20);
        Test.stopTest();       
    }
    
    @isTest 
    public static void assignOwnersTest6GradeBTRM() {
        
        Apex_Trigger_On_Off__c cs3 = new Apex_Trigger_On_Off__c();
        cs3.isEnable__c = true;
        cs3.Name = 'UpdateTimeZoneAccount';
        insert cs3;
        
        Apex_Trigger_On_Off__c cs5 = new Apex_Trigger_On_Off__c();
        cs5.isEnable__c = true;
        cs5.Name = 'LeadAndAccountTrigger';
        insert cs5;
        Account acc2 = new Account();
        acc2.Name = 'Test2aa6';
         acc2.First_Name__c='Test';
        acc2.last_Name__c='Test';
        acc2.email__c='test2@g.com';
        acc2.Preferred_Language__c='ENG';
        acc2.Affiliated_Id__c=1002243;
        acc2.TRM_Owner_Flag__c='Yes';
        acc2.Enrollment_Date__c = System.today() - 41;
        Insert acc2;
        
        TimeShare__c tm=new timeshare__c();
        tm.name='Imperial Gardens Nuevo Vallarta';
        tm.Unit_Size__c='1 Bedroom';
        tm.Unit_Type__c='Imperial 1 Bdddrm';
        tm.Ownership__c='Deeded';        
        tm.Timeshare_Owner__c=acc2.id;
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
        opp2.accountId=acc2.Id;
        opp2.CloseDate=system.today();
        opp2.StageName='New';
        opp2.RecordTypeId='0123t000000mliUAAQ';
        insert opp2;
        
        //List<Opportunity> oppList = [SELECT Id,Name,Account_Enrollment_Date__c,Account_Affiliate_Id__c,AccountId,Account.email__c,leadassist__Use_Round_Robin__c,Account.TRM_Owner_Flag__c,Account.Preferred_Language__c,Membership_Upgrade_Group__c FROM Opportunity WHERE name = 'test11'];  
        // system.debug('82 test='+opp.Account_Enrollment_Date__c);
        //ystem.debug('83 test ='+opp.Account_Affiliate_Id__c);
        // Set mock callout class     
        // Test.setMock(HttpCalloutMock.class, new AssignContactInOverflowCadenceTestMock());  
        Test.startTest();
        schedule_Hawaai_Email_Opportunity ba= new schedule_Hawaai_Email_Opportunity();
        Id jobid= Database.executeBatch(ba,20);
        Test.stopTest();       
    }
    
    @isTest 
    public static void assignOwnersTest6GradeB() {
        
        Apex_Trigger_On_Off__c cs3 = new Apex_Trigger_On_Off__c();
        cs3.isEnable__c = true;
        cs3.Name = 'UpdateTimeZoneAccount';
        insert cs3;
        
        Apex_Trigger_On_Off__c cs5 = new Apex_Trigger_On_Off__c();
        cs5.isEnable__c = true;
        cs5.Name = 'LeadAndAccountTrigger';
        insert cs5;
        Account acc2 = new Account();
        acc2.Name = 'Test2aa6';
         acc2.First_Name__c='Test';
        acc2.last_Name__c='Test';
        acc2.email__c='test2@g.com';
        acc2.Preferred_Language__c='ENG';
        acc2.Affiliated_Id__c=1002243;
        acc2.TRM_Owner_Flag__c='No';
        acc2.Enrollment_Date__c = System.today() - 46;
        Insert acc2;
        
        TimeShare__c tm=new timeshare__c();
        tm.name='Imperial Gardens Nuevo Vallarta';
        tm.Unit_Size__c='1 Bedroom';
        tm.Unit_Type__c='Imperial 1 Bdddrm';
        tm.Ownership__c='Deeded';        
        tm.Timeshare_Owner__c=acc2.id;
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
        opp2.accountId=acc2.Id;
        opp2.CloseDate=system.today();
        opp2.StageName='New';
        opp2.RecordTypeId='0123t000000mliUAAQ';
        insert opp2;
        
        //List<Opportunity> oppList = [SELECT Id,Name,Account_Enrollment_Date__c,Account_Affiliate_Id__c,AccountId,Account.email__c,leadassist__Use_Round_Robin__c,Account.TRM_Owner_Flag__c,Account.Preferred_Language__c,Membership_Upgrade_Group__c FROM Opportunity WHERE name = 'test11'];  
        // system.debug('82 test='+opp.Account_Enrollment_Date__c);
        //ystem.debug('83 test ='+opp.Account_Affiliate_Id__c);
        // Set mock callout class     
        // Test.setMock(HttpCalloutMock.class, new AssignContactInOverflowCadenceTestMock());  
        Test.startTest();
        schedule_Hawaai_Email_Opportunity ba= new schedule_Hawaai_Email_Opportunity();
        Id jobid= Database.executeBatch(ba,20);
        Test.stopTest();       
    }
    
    @isTest 
    public static void assignOwnersTest7GradeATRM() {
        
        Apex_Trigger_On_Off__c cs3 = new Apex_Trigger_On_Off__c();
        cs3.isEnable__c = true;
        cs3.Name = 'UpdateTimeZoneAccount';
        insert cs3;
        
        Apex_Trigger_On_Off__c cs5 = new Apex_Trigger_On_Off__c();
        cs5.isEnable__c = true;
        cs5.Name = 'LeadAndAccountTrigger';
        insert cs5;
        
        Account acc2 = new Account();
        acc2.Name = 'Test2aa7';
         acc2.First_Name__c='Test';
        acc2.last_Name__c='Test';
        acc2.email__c='test2@g.com';
        acc2.Preferred_Language__c='ENG';
        acc2.Affiliated_Id__c=1002243;
        acc2.TRM_Owner_Flag__c='Yes';
        acc2.Enrollment_Date__c = System.today() - 43;
        Insert acc2;
        
        TimeShare__c tm=new timeshare__c();
        tm.name='The Estates East Cape';
        tm.Unit_Size__c='1 Bedroom';
        tm.Unit_Type__c='3 Bdrm. 4 1/2 Bth Presidential Loft';
        tm.Ownership__c='Deeded';        
        tm.Timeshare_Owner__c=acc2.id;
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
        opp2.accountId=acc2.Id;
        opp2.CloseDate=system.today();
        opp2.StageName='New';
        opp2.RecordTypeId='0123t000000mliUAAQ';
        insert opp2;
        
        //List<Opportunity> oppList = [SELECT Id,Name,Account_Enrollment_Date__c,Account_Affiliate_Id__c,AccountId,Account.email__c,leadassist__Use_Round_Robin__c,Account.TRM_Owner_Flag__c,Account.Preferred_Language__c,Membership_Upgrade_Group__c FROM Opportunity WHERE name = 'test11'];  
        // system.debug('82 test='+opp.Account_Enrollment_Date__c);
        //ystem.debug('83 test ='+opp.Account_Affiliate_Id__c);
        // Set mock callout class     
        // Test.setMock(HttpCalloutMock.class, new AssignContactInOverflowCadenceTestMock());  
        Test.startTest();
        schedule_Hawaai_Email_Opportunity ba= new schedule_Hawaai_Email_Opportunity();
        Id jobid= Database.executeBatch(ba,20);
        Test.stopTest();       
    }
    
    @isTest 
    public static void assignOwnersTest7GradeA() {
        
        Apex_Trigger_On_Off__c cs3 = new Apex_Trigger_On_Off__c();
        cs3.isEnable__c = true;
        cs3.Name = 'UpdateTimeZoneAccount';
        insert cs3;
        
        Apex_Trigger_On_Off__c cs5 = new Apex_Trigger_On_Off__c();
        cs5.isEnable__c = true;
        cs5.Name = 'LeadAndAccountTrigger';
        insert cs5;
        
        Account acc2 = new Account();
        acc2.Name = 'Test2aa7';
         acc2.First_Name__c='Test';
        acc2.last_Name__c='Test';
        acc2.email__c='test2@g.com';
        acc2.Preferred_Language__c='ENG';
        acc2.Affiliated_Id__c=1002243;
        acc2.TRM_Owner_Flag__c='No';
        acc2.Enrollment_Date__c = System.today() - 42;
        Insert acc2;
        
        TimeShare__c tm=new timeshare__c();
        tm.name='The Estates East Cape';
        tm.Unit_Size__c='1 Bedroom';
        tm.Unit_Type__c='3 Bdrm. 4 1/2 Bth Presidential Loft';
        tm.Ownership__c='Deeded';        
        tm.Timeshare_Owner__c=acc2.id;
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
        opp2.accountId=acc2.Id;
        opp2.CloseDate=system.today();
        opp2.StageName='New';
        opp2.RecordTypeId='0123t000000mliUAAQ';
        insert opp2;
        
        //List<Opportunity> oppList = [SELECT Id,Name,Account_Enrollment_Date__c,Account_Affiliate_Id__c,AccountId,Account.email__c,leadassist__Use_Round_Robin__c,Account.TRM_Owner_Flag__c,Account.Preferred_Language__c,Membership_Upgrade_Group__c FROM Opportunity WHERE name = 'test11'];  
        // system.debug('82 test='+opp.Account_Enrollment_Date__c);
        //ystem.debug('83 test ='+opp.Account_Affiliate_Id__c);
        // Set mock callout class     
        // Test.setMock(HttpCalloutMock.class, new AssignContactInOverflowCadenceTestMock());  
        Test.startTest();
        schedule_Hawaai_Email_Opportunity ba= new schedule_Hawaai_Email_Opportunity();
        Id jobid= Database.executeBatch(ba,20);
        Test.stopTest();       
    }
    
    
    
    
    
    
}