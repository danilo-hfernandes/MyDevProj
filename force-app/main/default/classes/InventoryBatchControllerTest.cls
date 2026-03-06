@isTest
public class InventoryBatchControllerTest {
    
    @testSetup
    static void setup() {

    }

    @isTest
    static void testRunBatchSuccess() {
        // Create an instance of the controller
        InventoryBatchController controller = new InventoryBatchController();
        
        // Run the batch execution
        Test.startTest();
        PageReference result = controller.runBatch();
        Test.stopTest();
        
        // Verify the redirection
        System.assertNotEquals(null, result);
        System.assertEquals('/lightning/r/Report/00O3t000005ubh2EAA/view?queryScope=userFolders', result.getUrl());
    }

    @isTest
    static void testRunBatchFailure() {
        // Create an instance of the controller
        InventoryBatchController controller = new InventoryBatchController();
        

        // Verify the redirection
        PageReference result = controller.runBatch();
        System.assertNotEquals(null, result);
        System.assertEquals('/lightning/r/Report/00O3t000005ubh2EAA/view?queryScope=userFolders', result.getUrl());
    }
}