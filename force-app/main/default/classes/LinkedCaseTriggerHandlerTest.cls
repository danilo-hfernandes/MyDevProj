@isTest
public class LinkedCaseTriggerHandlerTest {

    @isTest
    static void testAfterInsertUpdate() {
        // Test Data Setup
        Case parentCase = new Case(
            Subject = 'Test Parent Case',
            Status = 'New'
        );
        insert parentCase;

        Linked_Case__c linkedCase = new Linked_Case__c(
            Parent_Case__c = parentCase.Id
        );

        Test.startTest();
        insert linkedCase;
        update linkedCase;
        Test.stopTest();
    }
}