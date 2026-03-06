@isTest
public class AssignContactProfitAgilityCadenceTest {
    
    @testSetup
    public static void setupEnvironment() {
        
        Profile p = [select id
                     from
                     Profile
                     where
                     name='System Administrator'];
        
        
        
        User user = new user(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', firstName='Jackie', lastname='Summers', languagelocalekey='en_US',
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
        
        Membership_Product_Configuration__c mpc=new Membership_Product_Configuration__c(Responsible_Party__c='Member',Marketing_Brand__c='ProfitAgility');
        insert mpc;
        
        Account acc = new Account();
        acc.Name = 'Test12322';
        acc.ownerid=u1.id;
        acc.Enrollment_Date__c = System.today() - 20;
        acc.Preferred_Language__c='Eng';
        acc.Affiliate_Name__c='Test';
        acc.Dues_Last_Paid_Until__c=Date.newInstance(2022, 12, 12);
        acc.Membership_Status__c='Active';
        acc.Membership_Product_Configuration__c = mpc.id;
        Insert acc;
        
        Contact con = new Contact();
        con.AccountId = acc.Id;
        con.Membership_Product_Configuration__c=mpc.id;
        con.Preferred_Language__c='ENG';
        con.LastName = 'Test2322';  
        con.AffiliatedId__c = 1002243;
        con.Affiliate_Name__c='test';
        con.ownerid=u1.id;
        con.email='eed@g.com';
        con.Master_Record_Id__c='test';
        con.Assign_to_Sales_Cadence__c=false;
        con.Membership_Status__c='Active';
        con.Active_Advantage_Match_Group__c='TRUE';
        Insert con;
        
        acc.Parent_Child_Contact_Id__c = con.Id;
        update acc;
    }
    
    @isTest 
    public static void assignOwnersTest() {
        List<Contact> conList = [SELECT id, LastName, AffiliatedId__c FROM Contact WHERE LastName Like 'Test%'];
        
        Set<Id> contIds = new Set<Id>();
        contIds.add(conList[0].Id);
        // Set mock callout class     
        Test.setMock(HttpCalloutMock.class, new AssignContactAdvanceCadenceTestMock());  
        Test.startTest();
        AssignContactProfitAgilityCadence ba = new AssignContactProfitAgilityCadence();
        Id jobid= Database.executeBatch(ba,1);        
        Test.stopTest();       
    }

}