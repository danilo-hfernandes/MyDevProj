@isTest
public class AccountTrigger_Test2 {
    
    @testSetup static void setup() {
        Profile p = [select id from Profile where name='CC Agent'];
        UserRole r = new UserRole(DeveloperName = 'HSI_Customer_Care_Agent_Test', Name = 'HSI Customer Care Agent');
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String guid = h.SubString(0,8);
        insert r;
        User u = new user(alias = 'test123', email='ccagenttest@nerdsoft.com',
                          emailencodingkey='UTF-8', firstName='Test', lastname='Name', languagelocalekey='en_US',
                          localesidkey='en_IN', profileid = p.Id, country='India',
                          timezonesidkey='Asia/Kolkata', username=guid+'ccagenttest@nerdsoft.com.hsi', Assigned_Contacts__c=4, UserRoleId=r.Id);
        
        insert u;
        
        Profile p2 = [select id from Profile where name='Tour Generation'];
        
        b = Crypto.GenerateAESKey(128);
        h = EncodingUtil.ConvertTohex(b);
        guid = h.SubString(0,8);
        
        UserRole r2 = new UserRole(DeveloperName = 'TourGen', Name = 'TourGen');
        insert r2;
        
        User u2 = new user(alias = 'test123', email='tourgenagent@nerdsoft.com',
                          emailencodingkey='UTF-8', firstName='Test', lastname='Name', languagelocalekey='en_US',
                          localesidkey='en_IN', profileid = p2.Id, country='India',
                          timezonesidkey='Asia/Kolkata', username=guid+'tourgenagent@nerdsoft.com.hsi', Assigned_Contacts__c=4, UserRoleId=r2.Id);
        
        insert u2;
        
    }
    
    @isTest
    static void sucessTest1(){
        
        Apex_Trigger_On_Off__c cs2 = new Apex_Trigger_On_Off__c();
        cs2.isEnable__c = true;
        cs2.Name = 'AccountTrigger';
        insert cs2;
        
        User u = [SELECT Id,UserRole.Name,Profile.Name FROM User WHERE Email = 'ccagenttest@nerdsoft.com' LIMIT 1];
        Account acc = new Account(Name = 'Test Account',OwnerId = u.Id,Email__c = 'test@gmail.com' ,Affiliated_Id__c = 1002277);
        insert acc;
        
        Account acc1 = new Account(Name = 'Test Account',OwnerId = u.Id,Email__c = 'test@gmail.com', Affiliated_Id__c = 1002243);
        insert acc1;
        
        
        
        Contact cont= New Contact();
        cont.FirstName='test';
        cont.LastName = 'testname';
        cont.AffiliatedId__c = 12345;
        cont.AccountId = acc.id;
        cont.OwnerId = acc.OwnerId;
        
        Insert cont;
        
        Contact cont2= New Contact();
        cont2.FirstName='test2';
        cont2.LastName = 'test2name';
        cont2.AffiliatedId__c = 12345;
        cont2.AccountId = acc.id;
        cont2.OwnerId = acc.OwnerId;
        
        Insert cont2;
        
        Test.startTest();
        
        System.RunAs(u){
            acc.Membership_Status__c = 'Active';
            acc.Parent_Child_Contact_Id__c = cont.Id;
            update acc;
        }
        
        Test.stopTest();
    }
    
    @isTest
    static void failedTest1(){
        Apex_Trigger_On_Off__c cs2 = new Apex_Trigger_On_Off__c();
        cs2.isEnable__c = true;
        cs2.Name = 'AccountTrigger';
        insert cs2;
        
        User u = [SELECT Id,UserRole.Name,Profile.Name FROM User WHERE Email = 'ccagenttest@nerdsoft.com' LIMIT 1];
        Account acc = new Account(Name = 'Test Account',OwnerId = u.Id);
        insert acc;
  
        Test.startTest();
        
        System.RunAs(u){
            try{
                acc.Membership_Status__c = 'BrowseExpired';
                update acc;
            }
            Catch(Exception e)
            {
                System.debug('e get message : '+e.getMessage());
                System.assertEquals(true, e.getMessage().contains('You are not allowed to make this change.'));
            }
        }
        
        Test.stopTest();
    }
    
    @isTest
    static void failedTest2(){
        Apex_Trigger_On_Off__c cs2 = new Apex_Trigger_On_Off__c();
        cs2.isEnable__c = true;
        cs2.Name = 'AccountTrigger';
        insert cs2;
        
        User u = [SELECT Id,UserRole.Name,Profile.Name FROM User WHERE Email = 'tourgenagent@nerdsoft.com' LIMIT 1];
        Account acc = new Account(Name = 'Test Account',OwnerId = u.Id);
        insert acc;
        
        Account acc2 = new Account(Name = 'Test Account',OwnerId = u.Id,Email__c = 'test@gmail.com',Alternate_Phone__c = '98745632', Affiliated_Id__c = 1002257);
        insert acc2;
        
		Account acc3 = new Account(Name = 'Test Account',OwnerId = u.Id,Email__c = 'test@gmail.com',Alternate_Phone__c = '98745632', Affiliated_Id__c = 1002453);
        insert acc3;
        
        Test.startTest();
        
        System.RunAs(u){
            try{
                acc.Membership_Status__c = 'Active';
                update acc;
            }
            Catch(Exception e)
            {
                System.debug('e get message : '+e.getMessage());
                System.assertEquals(true, e.getMessage().contains('You are not allowed to make this change.'));
            }
        }
        
        Test.stopTest();
    }
}