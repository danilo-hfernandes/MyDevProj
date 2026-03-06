@isTest
public class TourGenVidaTravelersNewTest {
    
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
        
        Apex_Trigger_On_Off__c cs3 = new Apex_Trigger_On_Off__c();
        cs3.isEnable__c = true;
        cs3.Name = 'UpdateTimeZoneAccount';
        insert cs3;
        
         Apex_Trigger_On_Off__c cs5 = new Apex_Trigger_On_Off__c();
        cs5.isEnable__c = true;
        cs5.Name = 'LeadAndAccountTrigger';
        insert cs5;
        User u2=[SELECT Id,Assigned_Contacts__c FROM User where name ='Salesforce'];
        
        Account acc = new Account();
        acc.Name = 'Test';
        acc.ownerid=u2.id;
        acc.Affiliated_id__c=1002275;
date dt=Date.newInstance(2020, 5, 5);
        acc.Enrollment_Date__c = dt;
        acc.Preferred_Language__c = 'ENG';
        Insert acc;
        
        Contact con = new Contact();
        con.AccountId = acc.Id;
        con.Preferred_Language__c='ENG';
        con.LastName = 'Test';  
        con.AffiliatedId__c = 1002243;
        con.ownerid=u2.id;
        con.Original_Source__c='Vidanta';
        con.Master_Record_Id__c='test';
        CON.Affiliate_Name__c='TEST';
        con.Assign_to_Sales_Cadence__c=false;
        con.Membership_Status__c='Active';
        con.Match_Group_Name__c='SFX Gold';
        con.Preferred_Language__c = 'ENG';
        
        Insert con;
        
        con.Master_Record_Id__c='test';
        update con;
        
        Opportunity opp = new Opportunity();
        opp.Name='Opp1';
        opp.StageName='Negotiation';
        opp.CloseDate=Date.today();
        opp.AccountId = acc.id;
        opp.Check_in__c = date.today() - 720;
        opp.Reservation_Status__c = 'Confirmed';
            insert opp;  
    } 
    @isTest 
    public static void assignOwnersTest() {
        List<Opportunity> oppList = [SELECT Id,Name,AccountId from Opportunity  WHERE Name Like 'Opp1%'];  
        // Set mock callout class     
        Test.setMock(HttpCalloutMock.class, new SFXGoldQueueableMock());  
        Test.startTest();
        TourGenVidaTravelersNew ba= new TourGenVidaTravelersNew();
        Id jobid= Database.executeBatch(ba,5);
        Test.stopTest();       
    }
}