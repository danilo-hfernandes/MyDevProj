@istest
public class InventoryAvailablityUpdateBatchTest {
@istest
    public static void InventoryAvailablityUpdateBatchTest1(){
       Uploaded_Inventory_Availability__c invtup = new Uploaded_Inventory_Availability__c();
        invtup.Check_In_Date__c=system.today();
        invtup.Plaza__c='VALLARTA';
        invtup.Resort_Name__c='Test Resort';
        invtup.Unit_Type__c='1BR';
        insert invtup;
        
        Inventory_Availability__c inav = new Inventory_Availability__c();
        invtup.Check_In_Date__c=system.today();
        invtup.Plaza__c='VALLARTA';
        invtup.Resort_Name__c='Test Resort';
        invtup.Unit_Type__c='1BR';
        insert inav;
        
        InventoryAvailablityUpdateBatch ab = new InventoryAvailablityUpdateBatch();
        Database.executeBatch(ab);
    }
}