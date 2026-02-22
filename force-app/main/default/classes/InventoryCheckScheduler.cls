public with sharing class InventoryCheckScheduler implements Schedulable{
    public void execute(SchedulableContext context) {
        InventoryCheckBatch batch = new InventoryCheckBatch();
        Database.executeBatch(batch);
    }
}