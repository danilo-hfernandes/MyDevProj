@istest
public class InventoryAvailablityCreateBatchTest {
@istest
    public static void InventoryAvailablityCreateBatchTest1(){
       Uploaded_Inventory_Availability__c invtup = new Uploaded_Inventory_Availability__c();
        insert invtup;
        InventoryAvailablityCreateBatch ab = new InventoryAvailablityCreateBatch();
        Database.executeBatch(ab);
    }
}