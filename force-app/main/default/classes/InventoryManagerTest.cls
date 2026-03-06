@isTest
public class InventoryManagerTest {

    @isTest
    static void testInventoryManager() {
        // Setup test data
        List<Inventory_Availability__c> inventoryList = new List<Inventory_Availability__c>();
        
        // Create test inventory records with necessary fields
        for (Integer i = 0; i < 5; i++) {
            Inventory_Availability__c inventory = new Inventory_Availability__c(
                Plaza__c = 'TestPlaza',
                Resort_Name__c = 'TestResort',
                Unit_Type__c = 'TestUnit',
                Check_In_Date__c = Date.today().addDays(1),
                Program__c = 'TestProgram',
                New_Availability__c = 10
            );
            inventoryList.add(inventory);
        }
        insert inventoryList;

        // Prepare input map for checkout dates
        Map<String, Date> inputMap = new Map<String, Date>{
            'TestPlaza-TestResort-TestUnit-2023-09-01-TestProgram' => Date.today().addDays(2)
        };

        // Test subtractInventoryAvailability method
        InventoryManager.subtractInventoryAvailability(inputMap);
        
        // Verify the New_Availability__c field has been decremented
        List<Inventory_Availability__c> updatedInventory = [
            SELECT Id, New_Availability__c FROM Inventory_Availability__c
            WHERE Unique_Key_for_Product_Id__c IN :inputMap.keySet()
        ];
        
        for (Inventory_Availability__c inv : updatedInventory) {
            System.assertEquals(9, inv.New_Availability__c, 'Availability should be decremented by 1.');
        }

        // Test addInventoryAvailability method
        InventoryManager.addInventoryAvailability(inputMap);
        
        // Verify the New_Availability__c field has been incremented
        updatedInventory = [
            SELECT Id, New_Availability__c FROM Inventory_Availability__c
            WHERE Unique_Key_for_Product_Id__c IN :inputMap.keySet()
        ];
        
        for (Inventory_Availability__c inv : updatedInventory) {
            System.assertEquals(10, inv.New_Availability__c, 'Availability should be incremented back to original value.');
        }

        // Test checkInventoryAvailability method
        Map<String, Boolean> availabilityStatus = InventoryManager.checkInventoryAvailability(inputMap);
        for (String key : availabilityStatus.keySet()) {
            System.assertEquals(true, availabilityStatus.get(key), 'Availability should be true for all keys.');
        }
    }
}