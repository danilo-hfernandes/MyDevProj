global class ScheduleTourGenerator implements Schedulable {

    global void execute(SchedulableContext sc) {

        Database.executeBatch(
            new TourGeneratorBatch(
                Date.today(),                // Start from today
                Date.today().addYears(1),    // End 1 year from today
                Time.newInstance(8,0,0,0),   // Start time
                Time.newInstance(23,30,0,0), // End time
                30                            // Interval minutes
            ),
            200 // Batch size
        );
    }
}