global class InventoryAvailabilityUpdateScheduler implements Schedulable {
    global void execute(SchedulableContext SC) {
        InventoryAvailablityUpdateBatch batch = new InventoryAvailablityUpdateBatch();
        Database.executeBatch(batch, 100);
    }
}