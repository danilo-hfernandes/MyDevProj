public class InventoryBatchController {
    public PageReference runBatch() {
        try {
            // Execute the batch class
            InventoryAvailablityUpdateBatch batch = new InventoryAvailablityUpdateBatch();
            Database.executeBatch(batch);
            
            // Add success message
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Inventory Availability Update Batch has been started.'));
        } catch (Exception e) {
            // Add failure message
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Failed to start Inventory Availability Update Batch: ' + e.getMessage()));
        }
        
        // Redirect back to the previous page
        return new PageReference('/' + 'lightning/r/Report/00O3t000005ubh2EAA/view?queryScope=userFolders');
    }
}