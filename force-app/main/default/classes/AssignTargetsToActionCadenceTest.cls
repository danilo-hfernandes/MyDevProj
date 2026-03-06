@isTest(seeAllData=true)
public class AssignTargetsToActionCadenceTest {
    @IsTest
    static void testBatchAssignmentToCadence() {
        // Set the mock for HTTP callouts
        Test.setMock(HttpCalloutMock.class, new AssigningContactInCadenceTestMock());

        // Execute the batch job with a batch size of 20
        Test.startTest();
        Database.executeBatch(new AssignTargetsToActionCadenceBatch(), 20);
        Test.stopTest();
    }
}