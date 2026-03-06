@isTest
public class TRMCadenceBatchTest {
    
    @testSetup
    public static void setupEnvironment() {
        
        Apex_Trigger_On_Off__c cs = new Apex_Trigger_On_Off__c();
        cs.isEnable__c = true;
        cs.Name = 'LeadDupliateTriggerLogic';
        
        Apex_Trigger_On_Off__c cs2 = new Apex_Trigger_On_Off__c();
        cs2.isEnable__c = true;
        cs2.Name = 'LeadSalesCadenceAssignment';
        
        insert cs;
        insert cs2;
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
        
        Lead leadrec = new Lead();
        leadrec.Status = 'New';
        leadrec.Email = 'test@test1.com';
        leadrec.LastName = 'test';
        leadrec.Company = 'test';
        leadrec.Phone = '1234567891';
        leadrec.leadsource='TRM Open';
        leadrec.country='India';
        leadrec.Assign_to_Sales_Cadence__c=false;
        insert leadrec;
        
    } 
    @isTest 
    public static void assignOwnersTest() {
        List<Lead> leadList = [SELECT Id,Assign_to_Sales_Cadence__c ,Match_Group_Name__c FROM Lead Where  LastName Like 'test%'];  
        // Set mock callout class     
        Test.setMock(HttpCalloutMock.class, new TRMCadenceBatchTestMock());  
        Test.startTest();
        TRMCadenceBatch ba= new TRMCadenceBatch();
        Id jobid= Database.executeBatch(ba,5);
        Test.stopTest();        
    }
}