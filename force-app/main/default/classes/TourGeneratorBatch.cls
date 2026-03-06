global class TourGeneratorBatch implements Database.Batchable<SObject> {

    global Date targetDate;       
    global Date endDate;          
    global Time startTime;
    global Time endTime;
    global Integer intervalMinutes;

    global TourGeneratorBatch(Date targetDate, Date endDate, Time startTime, Time endTime, Integer intervalMinutes) {
        this.targetDate = targetDate;
        this.endDate = endDate;
        this.startTime = startTime;
        this.endTime = endTime;
        this.intervalMinutes = intervalMinutes;
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([SELECT Id FROM Account LIMIT 1]);
    }

    global void execute(Database.BatchableContext bc, List<SObject> scope) {

        Map<Integer, String> dayMap = new Map<Integer, String>{
            1 => 'Sunday', 2 => 'Monday', 3 => 'Tuesday',
            4 => 'Wednesday', 5 => 'Thursday', 6 => 'Friday', 7 => 'Saturday'
        };
        String dayName = dayMap.get(targetDate.toStartOfWeek().daysBetween(targetDate) + 1);

        DateTime slotDT = DateTime.newInstance(targetDate, startTime);

        while (slotDT.time() <= endTime) {
            Time tourTime = slotDT.time();

            // Check if slot exists
            Integer existingCount = [SELECT count() FROM Tour__c
                                     WHERE Date__c = :targetDate
                                     AND Tour_Time__c = :tourTime];

            if (existingCount == 0) {
                insert new Tour__c(
                    Date__c = targetDate,
                    Day__c = dayName,
                    Tour_Time__c = tourTime,
                    Tour_Allotment__c = 1000
                );
            }

            slotDT = slotDT.addMinutes(intervalMinutes);
        }

        System.debug('Tours generated for ' + targetDate);
    }

    global void finish(Database.BatchableContext bc) {
        System.debug('Finished generating tours for ' + targetDate);

        // Chain next day
        Date nextDay = targetDate.addDays(1);
        if (nextDay <= endDate) {
            Database.executeBatch(
                new TourGeneratorBatch(nextDay, endDate, startTime, endTime, intervalMinutes),
                1
            );
        }
    }
}