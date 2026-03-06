@isTest
public class AccountTriggerHelperTest {
    
     @testSetup static void setup() {
         
         
        Profile p = [select id from Profile where name='System Administrator'];
        
        /*UserRole r = new UserRole(DeveloperName = 'System_Administrator', Name = 'System Administrator');
        insert r;*/

        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String guid = h.SubString(0,8); 
        
        User u = new user(alias = 'test123', email='dev_test@nerdsoft.com',
                          emailencodingkey='UTF-8', firstName='Test', lastname='Name', languagelocalekey='en_US',
                          localesidkey='en_IN', profileid = p.Id, country='India',
                          timezonesidkey='Asia/Kolkata', username='test_skyviauser_dev@nerdsoft.com.hsi.1', Assigned_Contacts__c=4);
         insert u;
         
         Id standardPbId = Test.getStandardPricebookId();
         
         Product2 prd1 = new Product2 (Name='Membership Upgrade Vida Week',isActive = true);
         insert prd1;
         
         PricebookEntry pbe1 = new PricebookEntry (Product2ID=prd1.id,Pricebook2ID=standardPbId,UnitPrice=0, isActive=true);
         insert pbe1;
         
     }
    @isTest
    static void test() {
        Apex_Trigger_On_Off__c cs3 = new Apex_Trigger_On_Off__c();
        cs3.isEnable__c = true;
        cs3.Name = 'UpdateTimeZoneAccount';
        insert cs3;
        
        Apex_Trigger_On_Off__c cs5 = new Apex_Trigger_On_Off__c();
        cs5.isEnable__c = true;
        cs5.Name = 'LeadAndAccountTrigger';
        insert cs5;
        
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
        List<Account> accList = new List<Account>();
        Account a1 = new Account();
        a1.Name = 'test account';
        a1.Tee_Up_Agent__c = u.id;
        a1.Membership_Upgrade_Opportunity__c = 'Yes';
        a1.Affiliated_Id__c = 1002274;
        accList.add(a1);
        
        insert accList;
        AccountTriggerHelper accounttr = new AccountTriggerHelper();
        accounttr.CreateHSIEnrollment(accList);  
    }
    @isTest
    static void test2() {
        
        Apex_Trigger_On_Off__c cs3 = new Apex_Trigger_On_Off__c();
        cs3.isEnable__c = true;
        cs3.Name = 'UpdateTimeZoneAccount';
        insert cs3;
        
        Apex_Trigger_On_Off__c cs5 = new Apex_Trigger_On_Off__c();
        cs5.isEnable__c = true;
        cs5.Name = 'LeadAndAccountTrigger';
        insert cs5;
        
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
        
        List<Account> accList = new List<Account>();
        Account a = new Account();
        a.Name = 'test account';
        a.Tee_Up_Agent__c = u.id;
        a.Membership_Upgrade_Opportunity__c = 'Yes';
        a.Affiliated_Id__c = 1002266;
        accList.add(a);
        
        Account a1 = new Account();
        a1.Name = 'test account';
        a1.Tee_Up_Agent__c = u.id;
        a1.Membership_Upgrade_Opportunity__c = 'Yes';
        a1.Affiliated_Id__c = 1002274;
        accList.add(a1);
        
        
        
        
        insert accList;
        AccountTriggerHelper accounttr = new AccountTriggerHelper();
        accounttr.CreateHSIEnrollment(accList); 
        AccountTriggerHelper.membershipUpgradeVidaWeekOpp(accList);
    }
    @isTest
    static void test3(){
        
        Apex_Trigger_On_Off__c cs3 = new Apex_Trigger_On_Off__c();
        cs3.isEnable__c = true;
        cs3.Name = 'UpdateTimeZoneAccount';
        insert cs3;
        
        Apex_Trigger_On_Off__c cs5 = new Apex_Trigger_On_Off__c();
        cs5.isEnable__c = true;
        cs5.Name = 'LeadAndAccountTrigger';
        insert cs5;
        
        Apex_Trigger_On_Off__c cs2 = new Apex_Trigger_On_Off__c();
        cs2.isEnable__c = true;
        cs2.Name = 'AccountTrigger';
        insert cs2;
        
        Account acc3 = new Account();
        acc3.Name = 'Test103';
        acc3.Email__c='test4@gmail.com';
        acc3.Affiliated_Id__c = 1002243;    
        acc3.Enrollment_Date__c = System.today() - 35;
        insert acc3;  
        
        Account acc4 = new Account();
        acc4.Name = 'Test103';
        acc4.Email__c='test4@gmail.com';
        acc4.Affiliated_Id__c = 1002277;    
        acc4.Enrollment_Date__c = System.today() - 35;
        insert acc4; 
        
        Account acc7 = new Account();
        acc7.Name = 'Test107';
        acc7.Email__c='test7@gmail.com';
        acc7.Affiliated_Id__c = 1002477;
        acc7.AccountSource = 'SMTN Open Lead - 1 year';
        insert acc7;
        
        acc7.Email__c='test788@gmail.com';
		update acc7;
        
        set<Id> setaccIds = new set<Id>();
        setaccIds.add(acc7.Id);
        AccountTriggerHelper.syncEmailToOpportunity(setaccIds);
        
    }
    
    @isTest
    static void test4(){
        
        /*Apex_Trigger_On_Off__c cs3 = new Apex_Trigger_On_Off__c();
cs3.isEnable__c = true;
cs3.Name = 'UpdateTimeZoneAccount';
insert cs3;

Apex_Trigger_On_Off__c cs5 = new Apex_Trigger_On_Off__c();
cs5.isEnable__c = true;
cs5.Name = 'LeadAndAccountTrigger';
insert cs5;*/
        
        Apex_Trigger_On_Off__c cs2 = new Apex_Trigger_On_Off__c();
        cs2.isEnable__c = true;
        cs2.Name = 'AccountTrigger';
        insert cs2;
        
        Account acc1 = new Account();
        acc1.Name = 'Test101';
        acc1.Email__c='test1@gmail.com';
        acc1.Affiliated_Id__c = 1002348;    
        insert acc1;
        
        Account acc2 = new Account();
        acc2.Name = 'Test102';
        acc2.Email__c='test2@gmail.com';
        acc2.Affiliated_Id__c = 1002421;    
        insert acc2;
        
        Account acc3 = new Account();
        acc3.Name = 'Test103';
        acc3.Email__c='test4@gmail.com';
        acc3.Affiliated_Id__c = 1002344;        
        insert acc3;
        
        Account acc4 = new Account();
        acc4.Name = 'Test104';
        acc4.Email__c='test5@gmail.com';
        acc4.Affiliated_Id__c = 1002266;
        acc4.Affiliate_Name__c = 'Not Think Direct';
        insert acc4;
        
        Account acc5 = new Account();
        acc5.Name = 'Test105';
        acc5.Email__c='test6@gmail.com';
        acc5.Affiliated_Id__c = 1002266;
        acc5.Affiliate_Name__c = 'Think Direct';
        insert acc5;
        
        Account acc6 = new Account();
        acc6.Name = 'Test106';
        acc6.Email__c='test6@gmail.com';
        acc6.Affiliated_Id__c = 1002241;
        insert acc6;
        
        Account acc1002348 = new Account();
        acc1002348.Name = 'Test1002348';
        acc1002348.Email__c='test1002348@gmail.com';
        acc1002348.Affiliated_Id__c = 1002348;
        insert acc1002348;
        
        Account acc1002464 = new Account();
        acc1002464.Name = 'Test1002464';
        acc1002464.Email__c='test10024648@gmail.com';
        acc1002464.Affiliated_Id__c = 1002464;
        insert acc1002464;
        
        Account acc1002478 = new Account();
        acc1002478.Name = 'Test1002478';
        acc1002478.Email__c='test1002478@gmail.com';
        acc1002478.Affiliated_Id__c = 1002478;
        insert acc1002478;
        
        
        

        Account acc10 = new Account();
        acc10.Name = 'Test110';
        acc10.Email__c='test10@gmail.com';
        acc10.Affiliated_Id__c = 1002440;
        insert acc10;
        
        Account acc11 = new Account();
        acc11.Name = 'Test111';
        acc11.Email__c='test11@gmail.com';
        acc11.Affiliated_Id__c = 1002436;
        insert acc11;
        
        Account acc12 = new Account();
        acc12.Name = 'Test112';
        acc12.Email__c='test12@gmail.com';
        acc12.Affiliated_Id__c = 1002445;
        insert acc12;
        
        Account acc13 = new Account();
        acc13.Name = 'Test113';
        acc13.Email__c='test13@gmail.com';
        acc13.Affiliated_Id__c = 1002442;
        insert acc13;
        
        Account acc14 = new Account();
        acc14.Name = 'Test114';
        acc14.Email__c='test14@gmail.com';
        acc14.Affiliated_Id__c = 1002256;
        insert acc14;
        
        
        Account acc15 = new Account();
        acc15.Name = 'Test104';
        acc15.Email__c='test5@gmail.com';
        acc15.Affiliated_Id__c = 1002261;
        insert acc15;
        
        Account acc16 = new Account();
        acc16.Name = 'Test1045';
        acc16.Email__c='test55@gmail.com';
        acc16.Affiliated_Id__c = 1002348;
        insert acc16;
        
        Account acc17 = new Account();
        acc17.Name = 'Test10517';
        acc17.Email__c='test1717@gmail.com';
        acc17.Affiliated_Id__c = 1002458;
        acc17.Affiliate_Name__c = 'Club Global Explorer VW - Trial';
        insert acc17;
        
        Account acc18 = new Account();
        acc18.Name = 'Test10518';
        acc18.Email__c='test1718@gmail.com';
        acc18.Affiliated_Id__c = 1002459;
        acc18.Affiliate_Name__c = 'Club Global Explorer VW';
        insert acc18;
        
        Account acc19 = new Account();
        acc19.Name = 'Test1051819';
        acc19.Email__c='test171819@gmail.com';
        acc19.Affiliated_Id__c = 1002460;
        acc19.Affiliate_Name__c = 'Filetracker';
        insert acc19;        
                
        //Book With Us
        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 standardPricebook = new Pricebook2(
            Id = pricebookId,
            IsActive = true
        );
        update standardPricebook;
        
        Product2 objprod = new Product2();
        objprod.Name = 'Book With Us';
        insert objprod;
        
       Account acc8 = new Account();
        acc8.Name = 'Test108';
        acc8.Email__c='test8@gmail.com';
        acc8.Affiliated_Id__c = 1002418;
        acc8.AccountSource = 'TRM Book With Us';
        insert acc8;

        Account acc9 = new Account();
        acc9.Name = 'Test109';
        acc9.Email__c='test9@gmail.com';
        acc9.Affiliated_Id__c = 1002433;
        acc9.Master_Record_Id__c = '';
        //acc3.Enrollment_Date__c = System.today() - 35;
        insert acc9;
    }
    
    @isTest
    static void test5(){
        
        Apex_Trigger_On_Off__c cs2 = new Apex_Trigger_On_Off__c();
        cs2.isEnable__c = true;
        cs2.Name = 'AccountTrigger';
        insert cs2;
        
        User u = [SELECT Id,UserRole.Name,Profile.Name,Username FROM User WHERE Username = 'test_skyviauser_dev@nerdsoft.com.hsi.1' LIMIT 1];
        
        System.debug('u.Username = '+u.Username);
        
        Test.startTest();
        
        List<Account> accList = new List<Account>();
        
        System.RunAs(u){
            
            //Test Skyvia Batch Size = 20
            For(Decimal i = 0; i<20 ; i++)
            {
                Account acc3 = new Account();
                acc3.Name = 'Test107'+i;
                acc3.Email__c='test7'+i+'@gmail.com';
                acc3.AccountSource = 'Contacts';
                acc3.Affiliated_Id__c = 1002265;
                acc3.Enrollment_Date__c = System.today();
                accList.add(acc3);
            }
            
            insert accList;
        }
        
        Test.stopTest();
    }

    @isTest
    static void test6(){             
        Account acc3 = new Account();
        acc3.Name = 'Test108';
        acc3.Email__c='test8@gmail.com';
        acc3.AccountSource = 'Contacts';
        acc3.Affiliated_Id__c = 1002265;
        acc3.Enrollment_Date__c = System.today();
        insert acc3;

        Contact cont= New Contact();
        cont.Email = 'test9@gmail.com';
        cont.FirstName='test';
        cont.LastName = 'testname';
        cont.AffiliatedId__c = 12345;
        cont.AccountId = acc3.id;
        cont.Sales_Room_Id__c = '2222';
        cont.Subscriber_Id__c = '12345';        
        insert cont;
        
        Test.startTest();
        
        acc3.Parent_Child_Contact_Id__c = cont.Id;
        update acc3;
        
		Map<Id,String> syncPrimaryContactFirstName = new Map<Id,String>();
        Map<Id,String> syncPrimaryContactLastName = new Map<Id,String>();
		syncPrimaryContactFirstName.put(cont.AccountId,cont.FirstName);
        syncPrimaryContactLastName.put(cont.AccountId,cont.LastName);

        Map<Id,String> records = new Map<Id,String>();
        records.put(cont.AccountId,cont.Email);


        Map<Id,String> records2 = new Map<Id,String>();
        records2.put(acc3.Parent_Child_Contact_Id__c,acc3.Email__c);
        
        AccountTriggerHelper.syncEmail(records,'Account');
        AccountTriggerHelper.syncEmail(records2,'Contact');
        AccountTriggerHelper.syncNameAccountANDContact(syncPrimaryContactFirstName,syncPrimaryContactLastName,'Contact');
        AccountTriggerHelper.syncNameAccountANDContact(syncPrimaryContactFirstName,syncPrimaryContactLastName,'Account');
        
        
        Test.stopTest();
    }
     @isTest
    static void test7() {
        Apex_Trigger_On_Off__c cs3 = new Apex_Trigger_On_Off__c();
        cs3.isEnable__c = true;
        cs3.Name = 'UpdateTimeZoneAccount';
        insert cs3;
        
        Apex_Trigger_On_Off__c cs5 = new Apex_Trigger_On_Off__c();
        cs5.isEnable__c = true;
        cs5.Name = 'LeadAndAccountTrigger';
        insert cs5;
        
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
        
        List<Account> accList = new List<Account>();
        Account a = new Account();
        a.Name = 'test account';
        a.Tee_Up_Agent__c = u.Id;
        a.Membership_Upgrade_Opportunity__c = 'Yes';
        a.Affiliated_Id__c = 1002266;
        accList.add(a);
        
        Account a1 = new Account();
        a1.Name = 'test account';
        a1.Tee_Up_Agent__c = u.Id;
        a1.Membership_Upgrade_Opportunity__c = 'Yes';
        a1.Affiliated_Id__c = 1002274;
        accList.add(a1);
        
        insert accList;
        
        AccountTriggerHelper accounttr = new AccountTriggerHelper();
        accounttr.CreateHSIEnrollment(accList); 
        AccountTriggerHelper.membershipUpgradeVidaWeekOpp(accList);
    }

    
    @isTest
    static void test8(){
        
        Apex_Trigger_On_Off__c cs2 = new Apex_Trigger_On_Off__c();
        cs2.isEnable__c = true;
        cs2.Name = 'AccountTrigger';
        insert cs2;
        
        Account acc1 = new Account();
        acc1.Name = 'Test1018';
        acc1.Email__c='test18@gmail.com';
        acc1.Affiliated_Id__c = 1002348;    
        insert acc1;
        
        Account acc2 = new Account();
        acc2.Name = 'Test102';
        acc2.Email__c='test2@gmail.com';
        acc2.Affiliated_Id__c = 1002452;    
        insert acc2;
          
        Account acc3 = new Account();
        acc3.Name = 'Test103';
        acc3.Email__c='test3@gmail.com';
        acc3.Affiliated_Id__c = 1002470;    
        insert acc3;
          
        Account acc4 = new Account();
        acc4.Name = 'Test104';
        acc4.Email__c='test4@gmail.com';
        acc4.Affiliated_Id__c = 1002471;    
        insert acc4;
     
    }
    
        @isTest
    static void test9(){
        
        Apex_Trigger_On_Off__c cs2 = new Apex_Trigger_On_Off__c();
        cs2.isEnable__c = true;
        cs2.Name = 'AccountTrigger';
        insert cs2;
        
        Account a = new Account();
        a.First_Name__c = 'first';
        a.Last_Name__c = 'last';
        a.Name = 'Victor';
        a.Affiliated_Id__c = 1002456;
        insert a;
        
        Opportunity o = new Opportunity();
        o.AccountId = a.id;
        o.name = 'test opp';
        o.StageName = 'New';
        o.CloseDate = System.today();
        o.Amount = 500;
        o.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('SFX_Membership').getRecordTypeId();
        insert o;
        
        Set<Id> sfxOpps = new Set<Id>();
        sfxOpps.add(a.Id);
        
        AccountTriggerHelper.sfxMemberTransfer(sfxOpps);
     
    }

    
    @isTest
    static void test10(){
        
        Apex_Trigger_On_Off__c cs2 = new Apex_Trigger_On_Off__c();
        cs2.isEnable__c = true;
        cs2.Name = 'AccountTrigger';
        insert cs2;
        
        Account acc1 = new Account();
        acc1.Name = 'Test101810';
        acc1.Email__c='test1810@gmail.com';
        acc1.Affiliated_Id__c = 1002453;    
        insert acc1;
        
        Account acc2 = new Account();
        acc2.Name = 'Test10210';
        acc2.Email__c='test210@gmail.com';
        acc2.Affiliated_Id__c = 1002454;    
        insert acc2;
          
        Account acc3 = new Account();
        acc3.Name = 'Test10310';
        acc3.Email__c='test310@gmail.com';
        acc3.Affiliated_Id__c = 1002455;    
        insert acc3;
          
        Account acc4 = new Account();
        acc4.Name = 'Test10410';
        acc4.Email__c='test410@gmail.com';
        acc4.Affiliated_Id__c = 1002348;    
        insert acc4;
     
    }
      @isTest
    static void test11(){
        
        Apex_Trigger_On_Off__c cs2 = new Apex_Trigger_On_Off__c();
        cs2.isEnable__c = true;
        cs2.Name = 'AccountTrigger';
        insert cs2;
        
        Account acc1 = new Account();
        acc1.Name = 'Test101810';
        acc1.Email__c='test1810@gmail.com';
        acc1.Affiliated_Id__c = 1002379; 
        acc1.AccountSource = 'SMTN Open Lead - 1 year';
        insert acc1;
        
        Account acc2 = new Account();
        acc2.Name = 'Test10210';
        acc2.Email__c='test210@gmail.com';
        acc2.Affiliated_Id__c = 1002379;    
        acc2.AccountSource = 'SMTN Open Lead - 1 year';
        insert acc2;
		
		List<Account> acclist = new List<Account>();
        acclist.add(acc1);
        acclist.add(acc2);

		AccountTriggerHelper.MTRCMUOpportunity(acclist);
    }
    
}