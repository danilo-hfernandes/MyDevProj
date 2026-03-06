@isTest
public class AccountTrigger_Test {
    
    @isTest
    static void test1() {
        Apex_Trigger_On_Off__c cs3 = new Apex_Trigger_On_Off__c();
        cs3.isEnable__c = true;
        cs3.Name = 'UpdateTimeZoneAccount';
        insert cs3;
        
        Apex_Trigger_On_Off__c cs2 = new Apex_Trigger_On_Off__c();
        cs2.isEnable__c = true;
        cs2.Name = 'AccountTrigger';
        insert cs2;
        
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
        
        Id oppRecordTypeId = [Select id from RecordType where sObjectType = 'Opportunity' and developerName ='Membership_Upgrade' ].id ;
        Account a = new Account();
        a.Name = 'test account';
        a.Tee_Up_Agent__c = u.id;
        a.Membership_Upgrade_Opportunity__c = 'Yes';
        a.Affiliated_Id__c = 1002266;
        a.Preferred_Language__c = 'ENG';
        a.Master_Record_Id__c = 'test';
        a.First_Name__c = 'test';
        a.Last_Name__c = 'test';
//        a.Test_Amadeu__c = 'test';
        insert a;
        
        a.name = 'test Acc';
        a.Email__c = 'test@gmail.com';
        update a;
        
        Opportunity o = new Opportunity();
        o.name = 'test opp';
        o.CloseDate = System.today();
        o.AccountId = a.id;
        o.Closed_Lost_Date__c = system.today();
        o.RecordTypeId = oppRecordTypeId;
        o.StageName = 'In Process';
        insert o;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        //Create your product
        Product2 prod = new Product2(
            Name = 'Vida Voucher-Profit Agility',
            //ProductCode = 'Pro-X',
            isActive = true
        );
        insert prod;
        
        //Create your pricebook entry
        PricebookEntry pbEntry = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = prod.Id,
            UnitPrice = 100.00,
            IsActive = true
        );
        insert pbEntry;
        
        
        OpportunityLineItem oli = new OpportunityLineItem(
            OpportunityId = o.Id,
            Quantity = 5,
            PricebookEntryId = pbEntry.Id,
            TotalPrice = pbEntry.UnitPrice
        );
        insert oli;
        
        
    }
    
    @isTest
    static void test2() {
        Apex_Trigger_On_Off__c cs3 = new Apex_Trigger_On_Off__c();
        cs3.isEnable__c = true;
        cs3.Name = 'UpdateTimeZoneAccount';
        insert cs3;
        
        Apex_Trigger_On_Off__c cs2 = new Apex_Trigger_On_Off__c();
        cs2.isEnable__c = true;
        cs2.Name = 'AccountTrigger';
        insert cs2;
        
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
        
        Account acc = new Account();
        acc.Name = 'test account';
        acc.Tee_Up_Agent__c = u.id;
        acc.Membership_Upgrade_Opportunity__c = 'Yes';
        acc.Affiliated_Id__c = 1002243;
        acc.Email__c = 'test@gmail.com';
        acc.Phone = '98745632';
        acc.Alternate_Phone__c = '98745632';
        acc.Email_2__c = 'test@gmail.com';
        insert acc; 
        
        Id oppRecordTypeId = [Select id from RecordType where sObjectType = 'Opportunity' and developerName ='Membership_Upgrade' ].id ;
        Account a = new Account();
        a.Name = 'test account';
        a.Tee_Up_Agent__c = u.id;
        a.Membership_Upgrade_Opportunity__c = 'Yes';
        a.Affiliated_Id__c = 1002447;
        a.Email__c = 'test@gmail.com';
        a.Phone = '98745632';
        //a.Bypass_Sync_to_SQL__c = false;
        
        insert a;

		     
        Opportunity o = new Opportunity();
        o.name = 'test opp';
        o.CloseDate = System.today();
        o.AccountId = a.id;
        o.Closed_Lost_Date__c = system.today();
        o.RecordTypeId = oppRecordTypeId;
        o.StageName = 'In Process';
        insert o;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        //Create your product
        Product2 prod = new Product2(
            Name = 'Vida Voucher-Profit Agility',
            //ProductCode = 'Pro-X',
            isActive = true
        );
        insert prod;
        
        //Create your pricebook entry
        PricebookEntry pbEntry = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = prod.Id,
            UnitPrice = 100.00,
            IsActive = true
        );
        insert pbEntry;
        
        
        OpportunityLineItem oli = new OpportunityLineItem(
            OpportunityId = o.Id,
            Quantity = 5,
            PricebookEntryId = pbEntry.Id,
            TotalPrice = pbEntry.UnitPrice
        );
        insert oli;
        
        delete a;
    }
    
    @isTest
    static void test3() {
        Apex_Trigger_On_Off__c cs2 = new Apex_Trigger_On_Off__c();
        cs2.isEnable__c = true;
        cs2.Name = 'AccountTrigger';
        insert cs2;
        
        /*Apex_Trigger_On_Off__c cs1 = new Apex_Trigger_On_Off__c();
        cs1.isEnable__c = true;
        cs1.Name = 'Contact-Trigger';
        insert cs1;*/
        
        Test.setMock(HttpCalloutMock.class, new MockPaymentAPI());
        
        Account a = new Account();
        a.Name = 'test account';
        a.Affiliated_Id__c = 1002336;
        a.Preferred_Language__c = 'ENG';
        a.Master_Record_Id__c = 'test';
        a.First_Name__c = 'test';
        a.Last_Name__c = 'test';
        a.Enrollment_Date__c = System.Today();
        insert a;
        
        Contact c = new Contact();
        c.LastName = a.Last_Name__c;
        c.FirstName = a.Last_Name__c;
        c.AffiliatedId__c = a.Affiliated_Id__c;
        c.AccountId = a.Id;
        insert c;
        
        Test.startTest();
        a.Parent_Child_Contact_Id__c = c.Id;
        a.Marketing_Email_opt_out__c = true;
        update a;
        Test.stopTest();
        
    }
    
    @isTest
    static void test4() {


         Apex_Trigger_On_Off__c cs3 = new Apex_Trigger_On_Off__c();
        cs3.isEnable__c = true;
        cs3.Name = 'UpdateTimeZoneAccount';
        insert cs3;
        
        Apex_Trigger_On_Off__c cs2 = new Apex_Trigger_On_Off__c();
        cs2.isEnable__c = true;
        cs2.Name = 'AccountTrigger';
        insert cs2;

		Test.startTest();
        
        User u = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Member Engagement Manager'].Id,
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
        
        Account acc = new Account();
        acc.Name = 'test account';
        acc.Tee_Up_Agent__c = u.id;
        acc.Membership_Upgrade_Opportunity__c = 'Yes';
        acc.Affiliated_Id__c = 1002243;
        acc.Email__c = 'test@gmail.com';
        acc.Phone = '98745632';
        acc.Alternate_Phone__c = '98745632';
        acc.Email_2__c = 'test@gmail.com';
        insert acc; 
        
        acc.Name = 'test account updated';
        update acc;
      
        Account AccUpd = [Select Id, Name from Account where Id = :acc.Id  LIMIT 1] ;        
		AccUpd.name = 'new Account name';
        update AccUpd;
         
		Test.stopTest();
        
    }    
    
    
    
    
}