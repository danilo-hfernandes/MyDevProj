@isTest
public class TeeUpLeadControllerTest {

    /*@isTest
    static void coverControllerMethods() {

        // Get any active user to use as Closing Agent
        User u = [SELECT Id FROM User WHERE IsActive = true LIMIT 1];

        // Create Lead using org-required fields (your sample pattern)
        Lead leadrec = new Lead();
        leadrec.LastName = 'test';
        leadrec.Company = 'test';
        leadrec.LeadSource = 'CFD FB';
        leadrec.Phone = '1234567891';
        leadrec.Email = 'd3rths@ds.com';
        insert leadrec;

        Test.startTest();

        // Cover fetch users
        TeeUpLeadController.fetchRecord();

        // Cover fetch lead info
        TeeUpLeadController.fetchOldAgentName(leadrec.Id);

        // Cover updateLead - main path
        TeeUpLeadController.updateLead(
            leadrec.Id,
            u.Id
        );

        Test.stopTest();
    }

    @isTest
    static void coverAlreadyAssignedPath() {

        User u = [SELECT Id FROM User WHERE IsActive = true LIMIT 1];

        // Create Lead
        Lead leadrec = new Lead();
        leadrec.LastName = 'test2';
        leadrec.Company = 'test';
        leadrec.LeadSource = 'CFD FB';
        leadrec.Phone = '1234567891';
        leadrec.Email = 'd3rths2@ds.com';

        // Pre-populate to trigger block condition
        leadrec.Tee_Up_Agent__c = u.Id;
        insert leadrec;

        Test.startTest();

        try {
            TeeUpLeadController.updateLead(
                leadrec.Id,
                u.Id
            );
        } catch (Exception e) {
            // Expected path – no asserts needed
        }

        Test.stopTest();
    }*/
}