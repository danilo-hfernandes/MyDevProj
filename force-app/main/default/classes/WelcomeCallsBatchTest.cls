@isTest
public class WelcomeCallsBatchTest {
    @isTest
    static void testBatchAndSchedulable() {
        // Create test data for your Account and Contact records here
        // Make sure to cover the scenarios you want to test

        // Example: Create test accounts and contacts
       
        Test.setMock(HttpCalloutMock.class, new AssignContactInOverflowCadenceTestMock());  
        Test.startTest();
        
         Account testAccount1 = new Account(Name = 'Test Account 1', Affiliated_Id__c = 1002222,Enrollment_Date__c=System.today().addDays(-45), Membership_Status__c=
                                         'Active',Preferred_Language__c = 'ENG',Membership_Product_Config_Ext_Db__c='A1002277', Dues_Last_Paid_Until__c= System.today().addDays(-30));
        insert testAccount1;
        
        Account testAccount2 = new Account(Name = 'Test Account 2', Affiliated_Id__c = 1002222,Enrollment_Date__c=System.today().addDays(-15), Membership_Status__c=
                                         'Active',Preferred_Language__c = 'ENG',Membership_Product_Config_Ext_Db__c='A1002222', Dues_Last_Paid_Until__c= System.today().addDays(-30));
        insert testAccount2;
        
         Account testAccount3 = new Account(Name = 'Test Account 3', Affiliated_Id__c = 1002222,Enrollment_Date__c=System.today().addDays(-15), Membership_Status__c=
                                         'Active',Preferred_Language__c = 'ENG',Membership_Product_Config_Ext_Db__c='A1001467', Dues_Last_Paid_Until__c= System.today().addDays(-30));
        insert testAccount3;
        
      
        
        Contact testContact1 = new Contact(AccountId = testAccount1.Id, LastName = 'Test Account 1',Membership_Status__c=
                                         'Active',Preferred_Language__c = 'ENG',Membership_Product_Config_Ext_Db__c='A1002277');
        insert testContact1;
        
         Contact testContact2 = new Contact(AccountId = testAccount2.Id, LastName = 'Test Account 2',Membership_Status__c=
                                         'Active',Preferred_Language__c = 'ENG',Membership_Product_Config_Ext_Db__c='A1002222');
        insert testContact2;
        
         Contact testContact3 = new Contact(AccountId = testAccount3.Id, LastName = 'Test Account 3',Membership_Status__c=
                                         'Active',Preferred_Language__c = 'ENG',Membership_Product_Config_Ext_Db__c='A1001467');
        insert testContact3;
     
        WelcomeCallsBatch batchController = new WelcomeCallsBatch();
        Database.executeBatch(batchController);
        Test.stopTest();
    }
}