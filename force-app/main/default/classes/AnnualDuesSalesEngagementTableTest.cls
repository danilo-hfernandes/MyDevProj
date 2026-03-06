@isTest
public class AnnualDuesSalesEngagementTableTest {
    @isTest
    static void testBatchAndSchedulable() {
        // Create test data for your Account and Contact records here
        // Make sure to cover the scenarios you want to test
        
        // Example: Create test accounts and contacts
                
        Test.startTest();
        Membership_Product_Configuration__c objmember = new Membership_Product_Configuration__c();
        objmember.Responsible_Party__c = 'Member';
        objmember.Name = 'Test';
        insert objmember;
        Account testAccount1 = new Account(Name = 'Test Account 1', Affiliated_Id__c = 1002222, Membership_Status__c=
                                           'Active',Preferred_Language__c = 'ENG', Dues_Last_Paid_Until__c= System.today().addDays(-30), Membership_Product_Configuration__c = objmember.Id);
        insert testAccount1;
        
        Account testAccount2 = new Account(Name = 'Test Account 1', Affiliated_Id__c = 1002243, Membership_Status__c=
                                           'Active',Preferred_Language__c = 'SPA', Dues_Last_Paid_Until__c= System.today().addDays(-30) , Membership_Product_Configuration__c = objmember.Id);
        insert testAccount2;
        
        Account testAccount3 = new Account(Name = 'Test Account 1', Affiliated_Id__c = 1002277, Membership_Status__c=
                                           'Active',Preferred_Language__c = 'SPA', Dues_Last_Paid_Until__c= System.today().addDays(-30) , Membership_Product_Configuration__c = objmember.Id);
        insert testAccount3;
        
        Account testAccount4 = new Account(Name = 'Test Account 4', Affiliated_Id__c = 1002256, Membership_Status__c=
                                           'Active',Preferred_Language__c = 'SPA', Dues_Last_Paid_Until__c= System.today().addDays(-30) ,Enrollment_Date__c= System.today().addDays(-60) , Membership_Product_Configuration__c = objmember.Id);
        insert testAccount4;
        
        Contact testContact1 = new Contact(AccountId = testAccount1.Id, LastName = 'Test Account 1');
        insert testContact1;
        
        Contact testContact11 = new Contact(AccountId = testAccount1.Id, LastName = 'Test Account 1');
        insert testContact11;
        
        Contact testContact2 = new Contact(AccountId = testAccount2.Id, LastName = 'Test Account 1');
        insert testContact2;
        
        Contact testContact22 = new Contact(AccountId = testAccount2.Id, LastName = 'Test Account 1');
        insert testContact22;
        
        Contact testContact3 = new Contact(AccountId = testAccount3.Id, LastName = 'Test Account 1');
        insert testContact3;
        
        Contact testContact33 = new Contact(AccountId = testAccount3.Id, LastName = 'Test Contact 1');
        insert testContact33;
        
        Account testAccountv1 = new Account(Name = 'Test Account 1', Affiliated_Id__c = 1002222, Membership_Status__c=
                                            'Active',Preferred_Language__c = 'ENG', Dues_Last_Paid_Until__c= System.today().addDays(+30) , Membership_Product_Configuration__c = objmember.Id);
        insert testAccountv1;
        
        Account testAccountv2 = new Account(Name = 'Test Account 1', Affiliated_Id__c = 1002243, Membership_Status__c=
                                            'Active',Preferred_Language__c = 'ENG', Dues_Last_Paid_Until__c= System.today().addDays(+30) , Membership_Product_Configuration__c = objmember.Id);
        insert testAccountv2;
        
        Account testAccountv3 = new Account(Name = 'Test Account 1', Affiliated_Id__c = 1002277, Membership_Status__c=
                                            'Active',Preferred_Language__c = 'ENG', Dues_Last_Paid_Until__c= System.today().addDays(+30) , Membership_Product_Configuration__c = objmember.Id);
        insert testAccountv3;
        
        
        Contact testContactv1 = new Contact(AccountId = testAccountv1.Id, LastName = 'Test Account 1');
        insert testContactv1;
        
        Contact testContactv2 = new Contact(AccountId = testAccountv2.Id, LastName = 'Test Account 1');
        insert testContactv2;
        
        Contact testContactv3 = new Contact(AccountId = testAccountv3.Id, LastName = 'Test Account 1');
        insert testContactv3;
        
        //2023-10-17 - HSIMU2-341 - Annual Dues SPA added - Preferred_Language__c
        
        Account testAccount5 = new Account(Name = 'Test Account 5', Affiliated_Id__c = 1002243, Membership_Status__c=
                                           'Active',Preferred_Language__c = 'SPA', Dues_Last_Paid_Until__c= System.today().addDays(-30) , Membership_Product_Configuration__c = objmember.Id,Enrollment_Date__c= System.today().addDays(-60));
        insert testAccount5;
        
        Account testAccount6 = new Account(Name = 'Test Account 6', Affiliated_Id__c = 1002277, Membership_Status__c=
                                           'Active',Preferred_Language__c = 'SPA', Dues_Last_Paid_Until__c= System.today().addDays(-30) , Membership_Product_Configuration__c = objmember.Id,Enrollment_Date__c= System.today().addDays(-60));
        insert testAccount6;
        
        Contact testContact5 = new Contact(AccountId = testAccount5.Id, LastName = 'Test Account 5');
        insert testContact5;
        
        Contact testContact6 = new Contact(AccountId = testAccount6.Id, LastName = 'Test Account 6');
        insert testContact6;
        
        //Test account with generic affiliate
        Account testAccount7 = new Account(Name = 'Test Account 7', Affiliated_Id__c = 1000000, Membership_Status__c=
                                           'Active',Preferred_Language__c = 'SPA', Dues_Last_Paid_Until__c= System.today().addDays(-30) , Membership_Product_Configuration__c = objmember.Id,Enrollment_Date__c= System.today().addDays(-60));
        insert testAccount7;
        
        Contact testContact7 = new Contact(AccountId = testAccount7.Id, LastName = 'Test Account 7');
        insert testContact7;

		List<Contact> annualDuesContacts = AnnualDuesSalesEngagementTable.getContacts();
        
        Test.stopTest();
        
    }
}