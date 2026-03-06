@isTest
public class AssignContactActiveDailyReturnCycleTest {
    
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
        
        /*Apex_Trigger_On_Off__c cs3 = new Apex_Trigger_On_Off__c();
        cs3.isEnable__c = true;
        cs3.Name = 'UpdateTimeZoneAccount';
        insert cs3;
        
        Apex_Trigger_On_Off__c cs5 = new Apex_Trigger_On_Off__c();
        cs5.isEnable__c = true;
        cs5.Name = 'LeadAndAccountTrigger';
        insert cs5;*/
        
        User u2=[SELECT Id,Assigned_Contacts__c FROM User where name ='Salesforce'];

        Account acc = new Account();
        acc.Name = 'Test12322';
        acc.ownerid=u2.id;
        acc.Enrollment_Date__c = System.today() - 20;
        acc.Preferred_Language__c='Eng';
        acc.Affiliate_Name__c='Test';
        acc.Dues_Last_Paid_Until__c=Date.newInstance(2022, 12, 12);
        acc.Membership_Status__c='Active';
        Insert acc;
        
        Membership_Product_Configuration__c mpc=new Membership_Product_Configuration__c(Responsible_Party__c='Member');
        insert mpc;
        
        Contact con = new Contact();
        con.AccountId = acc.Id;
        con.Membership_Product_Configuration__c=mpc.id;
        con.Preferred_Language__c='ENG';
        con.LastName = 'Test2322';  
        //con.AffiliatedId__c = 1002243;
        con.Affiliate_Name__c='test';
        con.ownerid=u2.id;
        con.email='eed@g.com';
        con.Master_Record_Id__c='test';
        con.Assign_to_Sales_Cadence__c=false;
        con.Membership_Status__c='Active';
        con.Active_Advantage_Match_Group__c='TRUE';
        con.Membership_Status__c='Active';
        Insert con;        
        //LastActivityDate(con.Id, System.now().addDays(-91));
    } 
    
    @isTest 
    public static void assignOwnersTest() {
        List<Contact> conList = [SELECT Id,ActionCadenceId,name,LastActivityDate,Assign_to_Sales_Cadence__c ,AccountId,Cadence_Flag__c,Affiliate_Name__c,Active_Advantage_Match_Group__c,Account.Affiliate_Name__c,Account.LastModifiedDate,Is_Main_Contact__c,Membership_Status__c,Last_SRR_Assignment_Date_Attempt__c FROM Contact WHERE LastName Like 'Test%'];
        System.debug('conList = '+conList);
        System.debug('conList LastActivityDate= '+conList[0].LastActivityDate);
        // Set mock callout class     
        Test.setMock(HttpCalloutMock.class, new AssignContactAdvanceCadenceTestMock());  
        Test.startTest();
        AssignContactActiveDailyReturnCycle ba= new AssignContactActiveDailyReturnCycle();
        Id jobid= Database.executeBatch(ba,5);
        Test.stopTest();       
    }
    
}