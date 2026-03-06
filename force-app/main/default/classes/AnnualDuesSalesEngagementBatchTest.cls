@isTest
public class AnnualDuesSalesEngagementBatchTest {
    @isTest
    static void testBatchAndSchedulable() {
        // Create test data for your Account and Contact records here
        // Make sure to cover the scenarios you want to test

        // Example: Create test accounts and contacts
       
        Test.setMock(HttpCalloutMock.class, new AssignContactInOverflowCadenceTestMock());  
        Test.startTest();
        Membership_Product_Configuration__c objmember = new Membership_Product_Configuration__c();
        objmember.Responsible_Party__c = 'Member';
        objmember.Name = 'Test';
        insert objmember;
         Account testAccount1 = new Account(Enrollment_Date__c = System.today(), Name = 'A_test Account 1', Affiliated_Id__c = 1002222, Membership_Status__c=
                                         'Active',Preferred_Language__c = 'ENG', Dues_Last_Paid_Until__c= System.today().addDays(-30), Membership_Product_Configuration__c = objmember.Id);
        insert testAccount1;

         Account testAccount12256 = new Account(Enrollment_Date__c = System.today(), Name = 'A_test Account 1 2256', Affiliated_Id__c = 1002222, Membership_Status__c=
                                         'Active',Preferred_Language__c = 'ENG', Dues_Last_Paid_Until__c= System.today().addDays(-90), Membership_Product_Configuration__c = objmember.Id);
        insert testAccount12256;

        
        Account testAccount2 = new Account(Enrollment_Date__c = System.today(), Name = 'B_test Account 1', Affiliated_Id__c = 1002312, Membership_Status__c=
                                         'Active',Preferred_Language__c = 'SPA', Dues_Last_Paid_Until__c= System.today().addDays(-30) , Membership_Product_Configuration__c = objmember.Id);
        insert testAccount2;
        
        Account testAccount3 = new Account(Enrollment_Date__c = System.today(), Name = 'C_test Account 1', Affiliated_Id__c = 1002276, Membership_Status__c=
                                         'Active',Preferred_Language__c = 'SPA', Dues_Last_Paid_Until__c= System.today().addDays(-30) , Membership_Product_Configuration__c = objmember.Id);
        insert testAccount3;
        

        Account testAccount31 = new Account(Enrollment_Date__c = System.today(), Name = 'C_test Account 31', Affiliated_Id__c = 1002276, Membership_Status__c=
                                         'Active',Preferred_Language__c = 'SPA', Dues_Last_Paid_Until__c= System.today().addDays(-30) , Membership_Product_Configuration__c = objmember.Id);
        insert testAccount31;

        Account testAccount4 = new Account(Name = 'D_test Account 4', Affiliated_Id__c = 1002256, Membership_Status__c=
                                         'Active',Preferred_Language__c = 'SPA', Dues_Last_Paid_Until__c= System.today().addDays(-30) ,Enrollment_Date__c= System.today().addDays(-60) , Membership_Product_Configuration__c = objmember.Id);
        insert testAccount4;
        


         
        Account testAccount41 = new Account(Name = 'D_test Account 5', Affiliated_Id__c = 1002243, Membership_Status__c=
                                         'Active',Preferred_Language__c = 'SPA', Dues_Last_Paid_Until__c= System.today().addDays(-50) ,Enrollment_Date__c= System.today().addDays(-50) , Membership_Product_Configuration__c = objmember.Id);
        insert testAccount41;
 

        Contact testContact1 = new Contact(AccountId = testAccount1.Id, LastName = 'Test_test Account 1');
        insert testContact1;
        
        Contact testContact11 = new Contact(AccountId = testAccount1.Id, LastName = 'Test_test Account 1');
        insert testContact11;
        
        Contact testContact2 = new Contact(AccountId = testAccount2.Id, LastName = 'Test_test Account 1');
        insert testContact2;
        
        Contact testContact22 = new Contact(AccountId = testAccount2.Id, LastName = 'Test_test Account 1');
        insert testContact22;
        
        Contact testContact3 = new Contact(AccountId = testAccount3.Id, LastName = 'Test_test Account 1');
        insert testContact3;
        
        Contact testContact33 = new Contact(AccountId = testAccount3.Id, LastName = 'Test_test Contact 1');
        insert testContact33;
        
        Account testAccountv1 = new Account(Enrollment_Date__c = System.today(), Name = 'Test_test Account 1', Affiliated_Id__c = 1002222, Membership_Status__c='Active',Preferred_Language__c = 'ENG', Dues_Last_Paid_Until__c= System.today().addDays(30) , Membership_Product_Configuration__c = objmember.Id);
        insert testAccountv1;
        
        Account testAccountv12256 = new Account(Enrollment_Date__c = System.today(), Name = 'Test_test Account 12222', Affiliated_Id__c = 1002222, Membership_Status__c='Active',Preferred_Language__c = 'ENG', Dues_Last_Paid_Until__c= System.today().addDays(60) , Membership_Product_Configuration__c = objmember.Id);
        insert testAccountv12256;
        
        Account testAccountv2 = new Account(Enrollment_Date__c = System.today(), Name = 'Test_test Account 1', Affiliated_Id__c = 1002312, Membership_Status__c='Active',Preferred_Language__c = 'ENG', Dues_Last_Paid_Until__c= System.today().addDays(30) , Membership_Product_Configuration__c = objmember.Id);
        insert testAccountv2;
        
        Account testAccountv3 = new Account(Enrollment_Date__c = System.today(), Name = 'Test_test Account 1', Affiliated_Id__c = 1002276, Membership_Status__c='Active',Preferred_Language__c = 'ENG', Dues_Last_Paid_Until__c= System.today().addDays(30) , Membership_Product_Configuration__c = objmember.Id);
        insert testAccountv3;
        
        Account testAccountv311 = new Account(Enrollment_Date__c = System.today(), Name = 'Test_test Account 311', Affiliated_Id__c = 1002276, Membership_Status__c='Active',Preferred_Language__c = 'ENG', Dues_Last_Paid_Until__c= System.today().addDays(30) , Membership_Product_Configuration__c = objmember.Id);
        insert testAccountv311;
        
         Account testAccountv31 = new Account(Enrollment_Date__c = System.today(), Name = 'Test_test Account 31', Affiliated_Id__c = 1002277, Membership_Status__c='Active',Preferred_Language__c = 'ENG', Dues_Last_Paid_Until__c= System.today().addDays(30) , Membership_Product_Configuration__c = objmember.Id);
        insert testAccountv31;
        
        Contact testContactv1 = new Contact(AccountId = testAccountv1.Id, LastName = 'Test_test Account 1');
        insert testContactv1;
        
        Contact testContactv2 = new Contact(AccountId = testAccountv2.Id, LastName = 'Test_test Account 1');
        insert testContactv2;
        
        Contact testContactv3 = new Contact(AccountId = testAccountv3.Id, LastName = 'Test_test Account 1');
        insert testContactv3;
        Contact testContactv31 = new Contact(AccountId = testAccountv31.Id, LastName = 'Test_test Account 31');
        insert testContactv31;
        
        //2023-10-17 - HSIMU2-341 - Annual Dues SPA added - Preferred_Language__c
        
        Account testAccount5 = new Account(Name = 'Test_test Account 5', Affiliated_Id__c = 1002312, Membership_Status__c=
                                           'Active',Preferred_Language__c = 'SPA', Dues_Last_Paid_Until__c= System.today().addDays(-30) , Membership_Product_Configuration__c = objmember.Id,Enrollment_Date__c= System.today().addDays(-60));
        insert testAccount5;
        
        Account testAccount6 = new Account(Name = 'Test_test Account 6', Affiliated_Id__c = 1002276, Membership_Status__c=
                                           'Active',Preferred_Language__c = 'SPA', Dues_Last_Paid_Until__c= System.today().addDays(-30) , Membership_Product_Configuration__c = objmember.Id,Enrollment_Date__c= System.today().addDays(-60));
        insert testAccount6;
        
        Account testAccount61 = new Account(Name = 'Test_test Account 61', Affiliated_Id__c = 1002243, Membership_Status__c=
                                           'Active',Preferred_Language__c = 'SPA', Dues_Last_Paid_Until__c= System.today().addDays(-30) , Membership_Product_Configuration__c = objmember.Id,Enrollment_Date__c= System.today().addDays(-60));
        insert testAccount61;
        
        Account testAccount8 = new Account(Name = 'Test_test Account 8', Affiliated_Id__c = 1002277, Membership_Status__c=
                                           'Active',Preferred_Language__c = 'SPA', Dues_Last_Paid_Until__c= System.today().addDays(-30) , Membership_Product_Configuration__c = objmember.Id,Enrollment_Date__c= System.today().addDays(-60));
        insert testAccount8;
        
        Contact testContact5 = new Contact(AccountId = testAccount5.Id, LastName = 'Test_test Account 5');
        insert testContact5;
        
        Contact testContact6 = new Contact(AccountId = testAccount6.Id, LastName = 'Test_test Account 6');
        insert testContact6;
        
        Contact testContact8 = new Contact(AccountId = testAccount8.Id, LastName = 'Test_test Account 8');
        insert testContact8;
        
        
        //Test account with generic affiliate
        Account testAccount7 = new Account(Name = 'Test_test Account 7', Affiliated_Id__c = 1000000, Membership_Status__c=
                                           'Active',Preferred_Language__c = 'SPA', Dues_Last_Paid_Until__c= System.today().addDays(-30) , Membership_Product_Configuration__c = objmember.Id,Enrollment_Date__c= System.today().addDays(-60));
        insert testAccount7;
        
        Contact testContact7 = new Contact(AccountId = testAccount7.Id, LastName = 'Test_test Account 7');
        insert testContact7;
        

        Account testAccount700 = new Account(Name = 'Test_test Account 700', Affiliated_Id__c = 1000000, Membership_Status__c=
                                           'Active',Preferred_Language__c = 'SPA', Dues_Last_Paid_Until__c= System.today().addDays(-40) , Membership_Product_Configuration__c = objmember.Id,Enrollment_Date__c= System.today().addDays(-60));
        insert testAccount700;
        
        Contact testContact700 = new Contact(AccountId = testAccount700.Id, LastName = 'Test_test Account 700');
        insert testContact700;
        
        Account testAccount1002277 = new Account(Name = 'Test_test Account 1002277', Affiliated_Id__c = 1002222, Membership_Status__c=
                                           'Active',Preferred_Language__c = 'SPA', Dues_Last_Paid_Until__c= System.today().addDays(-40) , Membership_Product_Configuration__c = objmember.Id,Enrollment_Date__c= System.today().addDays(-60));
        insert testAccount1002277;
        Contact testContact1002277 = new Contact(AccountId = testAccount1002277.Id, LastName = 'Test_test Account 1002277');
        insert testContact1002277;
        
        Account testAccount1002276 = new Account(Name = 'Test_test Account 1002276', Affiliated_Id__c = 1002276, Membership_Status__c=
                                           'Active',Preferred_Language__c = 'SPA', Dues_Last_Paid_Until__c= System.today().addDays(-40) , Membership_Product_Configuration__c = objmember.Id,Enrollment_Date__c= System.today().addDays(-60));
        insert testAccount1002276;
        Contact testContact1002276 = new Contact(AccountId = testAccount1002276.Id, LastName = 'Test_test Account 1002276');
        insert testContact1002276;
        
        Account testAccount1002243 = new Account(Name = 'Test_test Account 1002243', Affiliated_Id__c = 1002243, Membership_Status__c=
                                           'Active',Preferred_Language__c = 'SPA', Dues_Last_Paid_Until__c= System.today().addDays(-40) , Membership_Product_Configuration__c = objmember.Id,Enrollment_Date__c= System.today().addDays(-60));
        insert testAccount1002243;
        Contact testContact1002243 = new Contact(AccountId = testAccount1002243.Id, LastName = 'Test_test Account 1002243');
        insert testContact1002243;

        Account testAccount1002310 = new Account(Name = 'Test_test Account 1002310', Affiliated_Id__c = 1002310, Membership_Status__c=
                                           'Active',Preferred_Language__c = 'SPA', Dues_Last_Paid_Until__c= System.today().addDays(-40) , Membership_Product_Configuration__c = objmember.Id,Enrollment_Date__c= System.today().addDays(-60));
        insert testAccount1002310;
        Contact testContact1002310 = new Contact(AccountId = testAccount1002310.Id, LastName = 'Test_test Account 1002310');
        insert testContact1002310;


 
        AnnualDuesSalesEngagementBatchController batchController = new AnnualDuesSalesEngagementBatchController();
        Database.executeBatch(batchController);
        Test.stopTest();
    }
    
    
    
}