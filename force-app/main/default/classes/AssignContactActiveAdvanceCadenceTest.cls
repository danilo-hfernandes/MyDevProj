@isTest
public class AssignContactActiveAdvanceCadenceTest {
    
    @testSetup
    public static void setupTestData() {
        
        // Create related Membership_Product_Configuration__c record
        Membership_Product_Configuration__c mpc = new Membership_Product_Configuration__c(
            Name='Test Holiday',
            Responsible_Party__c = 'Member' // Ensure this matches the query criteria
        );
        Insert mpc;
        
        system.debug('MPC'+mpc);
        // Create test Accounts
        Account account1 = new Account(Name = 'Test Account 1', Affiliate_Name__c = 'Affiliate', Preferred_Language__c = 'Eng', Enrollment_Date__c = System.today() - 14, Membership_Status__c = 'Active', Dues_Last_Paid_Until__c = System.today() + 720 );
        Account account2 = new Account(Name = 'Test Account 2',Affiliate_Name__c = 'Holidays Lounge', Preferred_Language__c = 'Eng', Enrollment_Date__c = System.today() - 14, Membership_Status__c = 'Active', Dues_Last_Paid_Until__c = System.today() + 365);
        insert new List<Account>{account1, account2};
            system.debug('ACcounts1'+account1);
        system.debug('ACcounts2 '+account2);
        Account acc = new Account(
            Name = 'Test Account3',
            Affiliate_Name__c = 'Some Affiliate', // Must not be in AffiliateName1 list
            Preferred_Language__c = 'English',
            Membership_Status__c = 'Active',
            Dues_Last_Paid_Until__c = Date.today().addYears(2),
            Enrollment_Date__c = Date.today().addDays(-16),
            Master_Record_Id__c = account1.Id, // Ensure this is not null,
            Membership_Product_Configuration__c =mpc.ID
        );
        insert acc;
        
        system.debug('Acc3 ======='+acc);
        
        
        // Create test Contacts
        Contact contact1 = new Contact(LastName = 'test Contact 1', AccountId = acc.Id, Master_Record_Id__c='2384611-AP-HPRA-920132',Membership_Status__c = 'Active', Marketing_Email_Opt_Out__c = false,Assign_to_Sales_Cadence__c=true,Parent_Id_Ext_Db__c='',Match_Group_Name__c='TourGen-Active Advantage Program');
        Contact contact2 = new Contact(LastName = 'Test Contact 2', AccountId = account2.Id, Membership_Status__c = 'Active', Marketing_Email_Opt_Out__c = true);
        insert new List<Contact>{contact1, contact2};
            system.debug('contact1'+contact1);
        system.debug('contact2'+contact2);
        
        // Create Opportunities for Voucher Check
        Opportunity opp1 = new Opportunity(Name = 'Test Opportunity 1', StageName = 'Closed Won', CloseDate = Date.today(), AccountId = account1.Id, RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Opportunity' AND DeveloperName = 'Voucher' LIMIT 1].Id);
        insert opp1;
        system.debug('opp1'+opp1);
        
        // Create ActionCadenceTracker records
        ActionCadenceTracker tracker = new ActionCadenceTracker(TargetId = contact2.Id, State = 'Running', ActionCadenceId = '77C3t000000XwNgEAK');
        insert tracker;
        system.debug('tracker'+tracker);
        
        
        // Create Tasks for contacts
        Task task1 = new Task(Subject = 'Call', WhoId = contact1.Id, ActivityDate = System.today().addDays(-10));
        Task task2 = new Task(Subject = 'Outbound', WhoId = contact1.Id, ActivityDate = System.today().addDays(-20));
        insert new List<Task>{task1, task2};
            system.debug('task1'+task1);
        system.debug('task2'+task2);
        
    }
    
    @isTest
    public static void testBatchExecution() {
		Test.startTest();
        
        // Execute the batch class
        AssignContactActiveAdvanceCadence batchClass = new AssignContactActiveAdvanceCadence();
        Database.executeBatch(batchClass, 100);
        
        Test.stopTest();
        
        // Assertions
        // Verify if contacts are updated correctly
        List<Account> updatedAccounts = [SELECT Id,Dues_Last_Paid_Until__c,Membership_Product_Configuration__r.Responsible_Party__c,Enrollment_Date__c,Membership_Status__c,Affiliate_Name__c from Account where Name = 'Test Account3'];
        
        List<Contact> updatedContacts = [SELECT Id, Assign_to_Sales_Cadence__c, Match_Group_Name__c,
                                         Account.Affiliate_Name__c,Marketing_Email_Opt_Out__c,
                                         Parent_Id_Ext_Db__c,Account.Preferred_Language__c,Account.Membership_Status__c,
                                         Account.Dues_Last_Paid_Until__c,Master_Record_Id__c,
                                         Account.Membership_Product_Configuration__r.Responsible_Party__c,
                                         Account.Enrollment_Date__c 
                                         FROM Contact where LastName = 'Contact 1' ];
        system.debug('updatedContacts'+updatedContacts);
        
        // Check contacts with the correct Affiliate Name and no recent tasks
        for(Contact con : updatedContacts){
            system.debug('con.Account.Affiliate_Name__c'+con.Account.Affiliate_Name__c);
            if(con.Account.Affiliate_Name__c != 'Holidays Lounge'){
                System.assertEquals(true, con.Assign_to_Sales_Cadence__c, 'Contact should have Assign_to_Sales_Cadence__c set to true');
            } else {
                System.assertEquals(null, con.Assign_to_Sales_Cadence__c, 'Contact should not be updated because of Affiliate_Name__c being "Holidays Lounge"');
            }
        }
    }
    
    @isTest
    public static void testSchedulableExecution() {
        Test.startTest();
        
        // Schedule the class
        String jobId = System.schedule('Test Scheduled Batch Job', '0 0 12 * * ?', new AssignContactActiveAdvanceCadence());
        
        Test.stopTest();
        
        // Assert that the job was scheduled
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE Id = :jobId];
        System.assertEquals('0 0 12 * * ?', ct.CronExpression, 'Cron expression should match the scheduled job');
        System.assert(ct.NextFireTime != null, 'Next fire time should be set for the scheduled job');
    }
}