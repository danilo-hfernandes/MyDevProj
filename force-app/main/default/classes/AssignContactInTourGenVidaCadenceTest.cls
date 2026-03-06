@isTest
public class AssignContactInTourGenVidaCadenceTest {
    
    @isTest
    public static void setupEnvironment() {
        List<Opportunity> oppList = new List<Opportunity>();
        
        Cadence_Batch_Contol__c assignCad = new Cadence_Batch_Contol__c();
        assignCad.Name = 'AssignContactInTourGenVidaCadence';
        assignCad.isInitialLoad__c = true;
        assignCad.Query_Limit__c = 1;
        insert assignCad;
        
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
            //Test.startTest();
            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'HighVelocitySalesUser'];
            
            insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps.Id);
            //Test.stopTest();
        }      
        
        User u2=[SELECT Id,Assigned_Contacts__c FROM User where name ='Salesforce'];
        
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
        con.Affiliate_Name__c='test';
        con.ownerid=u2.id;
        con.Assign_to_Sales_Cadence__c=false;
        con.Membership_Status__c='Active';
        Insert con;
        
        Id voucherRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('VI_Referral_Date_Request').getRecordTypeId();
        Opportunity opp1= new Opportunity();
        opp1.name='test22';
        opp1.accountId=acc.Id;
        opp1.CloseDate=system.today();
        opp1.StageName='Attempting to Contact 2';
        opp1.Arrived__c=true;
        opp1.Check_in__c=System.today().addDays(-60);
        opp1.RecordTypeId=voucherRecordTypeId;
        opp1.Bypass_Cadence__c = false;
        insert opp1;     
        
        oppList.add(opp1);
        
        
        Contact conList = [SELECT id, Master_Record_Id__c FROM Contact WHERE LastName = 'Test' LIMIT 1];  
        
        conList.Master_Record_Id__c='test';
        update conList;
        set<Id> cadenceContactsId = new set<Id>();
        
        cadenceContactsId.add(conList.Id);
        
        // Set mock callout class     
        Test.setMock(HttpCalloutMock.class, new AssignContactInTourGenCadenceTestMock());  
        Test.startTest();
        AssignContactInTourGenVidaCadence ba= new AssignContactInTourGenVidaCadence();
        Database.executeBatch(ba);
        System.enqueueJob(new AssignContactInTourGenVidaQueueable(cadenceContactsId));
        Test.stopTest();
        
    }    
}