@isTest
public class AssigningContactIn71Cadence2Test {
    
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
        
        User u2=[SELECT Id FROM User where name ='Salesforce'];
        
        
        Account acc = new Account();
        acc.Name = 'Test';
        acc.ownerid=u2.id;
        acc.Enrollment_Date__c = System.today() - 80;
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
        opp1.StageName='Closed lost';
        insert opp1;
        
    } 
    @isTest 
    public static void assignOwnersTest() {
        List<Contact> conList = [SELECT id, LastName, AffiliatedId__c FROM Contact WHERE LastName Like 'Test%'];  
        // Set mock callout class     
        Test.setMock(HttpCalloutMock.class, new AssigningContactIn71DaysCadence2TestMock());  
        Test.startTest();
        AssigningContactIn71DaysCadence2 ba= new AssigningContactIn71DaysCadence2();
        Id jobid= Database.executeBatch(ba,5);
        Test.stopTest();       
    }
}