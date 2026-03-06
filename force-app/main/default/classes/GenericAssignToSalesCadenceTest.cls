@isTest
public class GenericAssignToSalesCadenceTest {
    
    @testSetup
    public static void setupEnvironment() {
        Profile p = [select id from Profile where name='System Administrator'];
        
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
      
        
    } 
    @isTest 
    public static void assignOwnersTest() {
        List<Contact> conList = [SELECT id, LastName, AffiliatedId__c FROM Contact WHERE LastName Like 'Test%']; 
        String salesCadenceName = 'TourGen-Affiliate Marketing';
        set<Id> setContactIds = new set<Id>();
        List<String> cadenceContactsId = new List<String>();
        for (Contact contact : conList) {
            cadenceContactsId.add(contact.Id);
            setContactIds.add(contact.Id);
        }
        // Set mock callout class     
        Test.setMock(HttpCalloutMock.class, new AssignContactInOverflowCadenceTestMock());  
        Test.startTest();
        FlowInvocablemethods.genericAssignSalesCadence(cadenceContactsId);
        //GenericAssignToSalesCadence ba= new GenericAssignToSalesCadence(setContactIds, salesCadenceName);
        Test.stopTest();       
    }
}