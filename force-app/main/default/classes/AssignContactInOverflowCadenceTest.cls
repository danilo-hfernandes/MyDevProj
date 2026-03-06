@isTest
public class AssignContactInOverflowCadenceTest {
    
    @testSetup
    public static void setupEnvironment() {
        Profile p = [select id
                     from
                     Profile
                     where
                     name='System Administrator'];
        
        
        
        User user = new user(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', firstName='Test', lastname='Name', languagelocalekey='en_US',
                             localesidkey='en_IN', profileid = p.Id, country='India',
                             timezonesidkey='Asia/Kolkata', username='test101_g@noemail.com', Assigned_Contacts__c=4);
        insert user;
        
        // Set up user
        User u1 = [SELECT Id FROM User WHERE UserName='test101_g@noemail.com'];
        System.RunAs(u1){
            // Add startTest and stopTest to avoid mixed DML error
            Test.startTest();
            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'HighVelocitySalesUser'];
            
            insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps.Id);
            Test.stopTest();
        }      
        
        User u2=[SELECT Id,Assigned_Contacts__c FROM User where name ='Salesforce'];
        
        Account acc = new Account();
        acc.Name = 'Test';
        acc.ownerid=u2.id;
        acc.Enrollment_Date__c = System.today() - 51;
        Insert acc;
        
        Contact con = new Contact();
        con.AccountId = acc.Id;
        con.Preferred_Language__c='ENG';
        con.LastName = 'Test';  
        con.AffiliatedId__c = 1002243;
        con.ownerid=u2.id;
        con.Assign_to_Sales_Cadence__c=false;
        con.Membership_Status__c='Active';
        Insert con;
        
        Contact con1 = new Contact();
        con1.AccountId = acc.Id;
        con1.LastName = 'Test1';  
        con1.ownerid=u2.id;
        con1.Assign_to_Sales_Cadence__c=false;
        con1.Preferred_Language__c='ENG';
        con1.AffiliatedId__c = 1002243;
        con1.Membership_Status__c='Active';
        Insert con1;
        
        Opportunity opp1= new Opportunity();
        opp1.name='test';
        opp1.accountId=acc.Id;
        opp1.CloseDate=system.today();
        opp1.StageName='Attempting to Contact 2';
        opp1.RecordTypeId='0123t000000mliUAAQ';
        insert opp1;
        Test.setCreatedDate(opp1.Id, DateTime.newInstance(2000,10,10));
        
        Account acc1 = new Account();
        acc1.Name = 'Test';
        acc1.ownerid=u2.id;
        acc1.Enrollment_Date__c = System.today() - 51;
        Insert acc1;
        
        Contact con2 = new Contact();
        con2.AccountId = acc1.Id;
        con2.Preferred_Language__c='ENG';
        con2.LastName = 'Test';  
        con2.AffiliatedId__c = 1002243;
        con2.ownerid=u2.id;
        con2.Assign_to_Sales_Cadence__c=false;
        con2.Membership_Status__c='Active';
        Insert con2;
        
        Contact con3 = new Contact();
        con3.AccountId = acc1.Id;
        con3.LastName = 'Test1';  
        con3.ownerid=u2.id;
        con3.Assign_to_Sales_Cadence__c=false;
        con3.Preferred_Language__c='ENG';
        con3.AffiliatedId__c = 1002243;
        con3.Membership_Status__c='Active';
        Insert con3;
        
        Opportunity opp2= new Opportunity();
        opp2.name='test';
        opp2.accountId=acc1.Id;
        opp2.CloseDate=system.today();
        opp2.StageName='Attempting to Contact 2';
        opp2.RecordTypeId='0123t000000mliUAAQ';
        insert opp2;
        Test.setCreatedDate(opp2.Id, DateTime.newInstance(2000,10,10));
        
        Account acc3 = new Account();
        acc3.Name = 'Test';
        acc3.ownerid=u2.id;
        acc3.Enrollment_Date__c = System.today() - 51;
        Insert acc3;
        
        Contact con4 = new Contact();
        con4.AccountId = acc3.Id;
        con4.Preferred_Language__c='ENG';
        con4.LastName = 'Test';  
        con4.AffiliatedId__c = 1002243;
        con4.ownerid=u2.id;
        con4.Assign_to_Sales_Cadence__c=false;
        con4.Membership_Status__c='Active';
        Insert con4;
        
        Contact con5 = new Contact();
        con5.AccountId = acc3.Id;
        con5.LastName = 'Test1';  
        con5.ownerid=u2.id;
        con5.Assign_to_Sales_Cadence__c=false;
        con5.Preferred_Language__c='ENG';
        con5.AffiliatedId__c = 1002243;
        con5.Membership_Status__c='Active';
        Insert con5;
        
        Opportunity opp3= new Opportunity();
        opp3.name='test';
        opp3.accountId=acc3.Id;
        opp3.CloseDate=system.today();
        opp3.StageName='Attempting to Contact 2';
        opp3.RecordTypeId='0123t000000mliUAAQ';
        insert opp3;
        Test.setCreatedDate(opp3.Id, DateTime.newInstance(2000,10,10));
        
    } 
    @isTest 
    public static void assignOwnersTest() {
        List<Contact> conList = [SELECT id, LastName, AffiliatedId__c FROM Contact WHERE LastName Like 'Test%'];  
        // Set mock callout class     
        Test.setMock(HttpCalloutMock.class, new AssignContactInOverflowCadenceTestMock());  
        Test.startTest();
        AssignContactInOverflowCadence ba= new AssignContactInOverflowCadence();
        Id jobid= Database.executeBatch(ba,3);
        Test.stopTest();       
    }
}