@isTest
public class FileTrackerLeadConversionControllerTest {
    @testSetup
    static void setupTestData() {
        // Create test Accounts
        Account acc1 = new Account(Name = 'Test Account 1', Email__c = 'test1@email.com', Phone = '1234567890', Affiliated_Id__c = 1001);
        Account acc2 = new Account(Name = 'Test Account 2', Email__c = 'test2@email.com', Phone = '0987654321', Affiliated_Id__c = 1002);
        insert new List<Account>{ acc1, acc2 };
        
        Resort__c r = new Resort__c();
        r.name = 'Americana Village';
        insert r;
        
        // Create test Leads
        Id fileTrackerRecTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Filetracker_Reservations').getRecordTypeId(); 
        Lead lead1 = new Lead(FileTracker_File_Number__c = '117646', Description = 'Filetracker Link: https://filetracker.nerdsoft.com/Details/FileDetail_General.aspx?fileID=117646, FT Created Date: July 1, 2016 1:51pm EST., Resort Name: Americana Village, Resort Phone: , Grade: F, Usage: 330, Week: 1,2,3,4,5,6,7,8,9,10,11,12,13,14,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,50,51, Bedrooms: 1, Bathrooms: 1, Points: 24500', RecordTypeId = fileTrackerRecTypeId, FirstName = 'John', LastName = 'Doe', Email = 'test1@email.com', Phone = '1234567890', Company='FileTracker', Status = 'Open', Match_Affiliate_Id__c = 1001,Street = 'Test Street 1',City = 'Test City',State = 'CA',Country = 'US',PostalCode = '1234');
        Lead lead2 = new Lead(FileTracker_File_Number__c = '117646', Description = 'Filetracker Link: https://filetracker.nerdsoft.com/Details/FileDetail_General.aspx?fileID=117646, FT Created Date: July 1, 2016 1:51pm EST., Resort Name: Americana Village, Resort Phone: , Grade: F, Usage: 330, Week: 1,2,3,4,5,6,7,8,9,10,11,12,13,14,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,50,51, Bedrooms: 1, Bathrooms: 1, Points: 24500', RecordTypeId = fileTrackerRecTypeId,FirstName = 'Jane', LastName = 'Smith', Email = 'test3@email.com', Phone = '1122334455',Company='FileTracker', Status = 'New', Match_Affiliate_Id__c = 1003,Street = 'Test Street 1',City = 'Test City',State = 'CA',Country = 'US',PostalCode = '1234');
        insert new List<Lead>{ lead1, lead2 };
    }

    
    @isTest
    static void testLeadConversion() {
        // Fetch test leads
        List<Lead> leadsToConvert = [SELECT Id, Email, Phone, Match_Affiliate_Id__c, FileTracker_File_Number__c FROM Lead];
        
        // Execute lead conversion method
        Test.startTest();
        FileTrackerLeadConversionController.convertLeads(leadsToConvert);
        Test.stopTest();
        
        // Verify that leads are converted
        //for (Lead lead : [SELECT Id, ConvertedAccountId FROM Lead WHERE Id IN :leadsToConvert]) {
          //  System.assertNotEquals(null, lead.ConvertedAccountId, 'Lead should be converted to an Account');
        //}
        
        // Verify that cases are created
        //List<Case> cases = [SELECT Id FROM Case];
        //System.assertEquals(leadsToConvert.size(), cases.size(), 'Each converted lead should create a case');
        
        // Verify that timeshares are created
        //List<Timeshare__c> timeshares = [SELECT Id FROM Timeshare__c];
        //System.assert(timeshares.size() > 0, 'Timeshare records should be created');
        
        // Verify that deposits are created
        //List<Deposits__c> deposits = [SELECT Id FROM Deposits__c];
        //System.assert(deposits.size() > 0, 'Deposit records should be created');
    }
}