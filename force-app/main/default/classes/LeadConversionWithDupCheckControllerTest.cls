@isTest
public class LeadConversionWithDupCheckControllerTest {
    
    @isTest
    static void simpleTest() {
        
        Apex_Trigger_On_Off__c cs1 = new Apex_Trigger_On_Off__c();
        cs1.isEnable__c = true;
        cs1.Name = 'Lead-Trigger';
        
        Apex_Trigger_On_Off__c cs = new Apex_Trigger_On_Off__c();
        cs.isEnable__c = true;
        cs.Name = 'LeadDupliateTriggerLogic';
        
        // Create a non-duplicate Lead
        Lead lead1 = new Lead(
            FirstName = 'Test',
            LastName = 'Lead1',
            Company = 'TestCo',
            Email = 'test1@example.com',
            Phone = '1234567890'            
        );

        // Create a duplicate Lead (same email & affiliate ID)
        Lead lead2 = new Lead(
            FirstName = 'Test',
            LastName = 'Lead2',
            Company = 'TestCo',
            Email = 'test1@example.com',
            Phone = '1234567890'
        );

        insert new List<Lead>{ lead1, lead2 };

        // Run the method with both lead IDs
        List<Id> inputLeads = new List<Id>{ lead1.Id, lead2.Id };

        Test.startTest();
        LeadConversionWithDupCheckController.assignLeads(inputLeads);
        Test.stopTest();
    }
}