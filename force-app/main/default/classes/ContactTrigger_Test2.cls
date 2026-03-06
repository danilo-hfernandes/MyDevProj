@isTest
public class ContactTrigger_Test2 {
    
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
        
        Apex_Trigger_On_Off__c tr = new Apex_Trigger_On_Off__c();
        tr.Name = 'Contact-Trigger';
        tr.isEnable__c = true;
        insert tr;
        
        User u = [SELECT Id,UserRole.Name,Profile.Name FROM User WHERE Email = 'ccagenttest@nerdsoft.com' LIMIT 1];
        Account acc = new Account(Name = 'Test Account',OwnerId = u.Id);
        insert acc;
        
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
        Test.setMock(HttpCalloutMock.class, new MockMembershipDataSyncToBE());
        System.RunAs(u){           
            acc.Parent_Child_Contact_Id__c = cont.Id;
            update acc;
            cont.Marketing_Email_opt_out__c = true;
            cont.Membership_Status__c = 'Active';
            update cont;
        }
        
        Test.stopTest();
    }
    
    @isTest
    static void failedTest1(){
        Apex_Trigger_On_Off__c tr = new Apex_Trigger_On_Off__c();
        tr.Name = 'Contact-Trigger';
        tr.isEnable__c = true;
        insert tr;
        
        User u = [SELECT Id,UserRole.Name,Profile.Name FROM User WHERE Email = 'ccagenttest@nerdsoft.com' LIMIT 1];
        Account acc = new Account(Name = 'Test Account',OwnerId = u.Id);
        insert acc;
        
        Contact cont= New Contact();
        cont.FirstName='test';
        cont.LastName = 'testname';
        cont.AffiliatedId__c = 12345;
        cont.AccountId = acc.id;
        cont.OwnerId = acc.OwnerId;
        
        Insert cont;
        
        acc.Parent_Child_Contact_Id__c = '';
        update acc;
        
        Test.startTest();
        
        System.RunAs(u){
            try{                
                cont.Membership_Status__c = 'Active';
                update cont;
            }
            Catch(Exception e)
            {
                System.debug('e get message : '+e.getMessage());
                System.assertEquals(true, e.getMessage().contains('Membership Status changes are only allowed in the main contact.'));
            }
        }
        
        Test.stopTest();
    }
    @isTest 
    public static void assignRaiseAwayContactstoTourGenTest() {
        Apex_Trigger_On_Off__c tr = new Apex_Trigger_On_Off__c();
        tr.Name = 'Contact-Trigger';
        tr.isEnable__c = true;
        insert tr;

        Account acc = new Account(Name = 'Test_Account',affiliated_id__c = 1002464);
        insert acc;
        Contact con = new Contact();
        con.FirstName = 'Test';
        con.LastName = 'TestContact';
        con.AccountId = acc.Id;
        con.Affiliate_Name__c='test';
        con.AffiliatedId__c = 1002464;
        
        Test.setMock(HttpCalloutMock.class, new AssigningContactInCadenceTestMock());
        Test.startTest();
        insert con;
        Test.stopTest();
    }
    
}