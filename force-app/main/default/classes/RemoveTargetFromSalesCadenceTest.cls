@isTest
public class RemoveTargetFromSalesCadenceTest {
    
    @testSetup
    public static void setupEnvironment() {
        Profile p = [select id
                     from
                     Profile
                     where
                     name='System Administrator'];
        
        
        
        User user = new user(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', firstName='t', lastname='t', languagelocalekey='en_US',
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
        acc.Affiliate_Name__c='Mayan International Add-On';
        acc.Dues_Last_Paid__c=System.today()-200;
        acc.Affiliated_Id__c=1002222;
        acc.Enrollment_Date__c = System.today()-12;
        acc.Membership_Status__c='Inactive';
        Insert acc;
        
        
        Contact con = new Contact();
        con.AccountId = acc.Id;
        con.Preferred_Language__c='ENG';
        con.LastName = 'Test1';  
        con.Parent_Id_Ext_Db__c='Test';
        con.AffiliatedId__c = 1002243;
        con.ownerid=u2.id;
        con.Match_Group_Name__c='TourGen-Rebook';
        con.Active_Advantage_Match_Group__c='TRUE';
        con.Assign_to_Sales_Cadence__c=false;
        con.Membership_Status__c='Active';
        con.Affiliate_name__c='Holidays Lounge';
        Insert con;
        
        Datetime yesterday = Datetime.now().addDays(-11);
        Test.setCreatedDate(con.Id, yesterday);
        
        
        Contact con1 = new Contact();
        con1.AccountId = acc.Id;
        con1.Preferred_Language__c='ENG';
        con1.LastName = 'Test1';  
        con1.AffiliatedId__c = 1002243;
        con1.ownerid=u2.id;
        con1.Remove_from_Cadence__c=true;
        con1.Match_Group_Name__c='Tour Gen Loyalty';
        con1.Master_Record_Id__c='Test';
        con1.Parent_Id_Ext_Db__c='Test';
        con1.Assign_to_Sales_Cadence__c=false;
        con1.Membership_Status__c='Active';
        Insert con1;
        
        Id leadCFRecTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Carefree_Destinations').getRecordTypeId();
        
        
        Lead leadrec = new Lead();
        leadrec.Status = 'New';
        leadrec.Email = 'test@test1.com';
        leadrec.LastName = 'test';
        leadrec.Company = 'test';
        leadrec.LeadSource = 'CFD FB';
        leadrec.Phone = '1234567891';
        leadrec.RecordTypeId = leadCFRecTypeId;
        
        insert leadrec;
        
        Datetime yesterday1 = Datetime.now().addDays(-11);
        Test.setCreatedDate(con1.Id, yesterday1);
        
        
    } 
    @isTest 
    public static void assignOwnersTest() {
        //List<Lead> leadList = [select id from Lead WHERE LastName Like 'Test%'];
        List<Contact> conList = [Select id,Same_Name_as_Account_Name__c, Master_Record_Id__c, Assign_to_Sales_Cadence__c,Account.Enrollment_Date__c,Account.Membership_Status__c,Account.Affiliated_Id__c,SMTN_Loyalty_Campaign_SSR_Match_Group__c  From Contact WHERE LastName Like 'Test%'];  
        // Set mock callout class     
        Test.setMock(HttpCalloutMock.class, new RemoveTargetFromSalesCadenceTestMock());  
        Test.startTest();
        RemoveTargetFromSalesCadence ba= new RemoveTargetFromSalesCadence();
        Id jobid= Database.executeBatch(ba,20);
        Test.stopTest();        
    }
    
    
}