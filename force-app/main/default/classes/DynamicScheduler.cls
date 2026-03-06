public with sharing class DynamicScheduler implements Schedulable {
    private String query;

    public DynamicScheduler(String query) {
        this.query = query;
    }

    public void execute(SchedulableContext sc) {
        List<SObject> records = Database.query(query);
        // Process the records as needed
    }
}