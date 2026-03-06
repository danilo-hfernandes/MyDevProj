@RestResource(urlMapping='/getAllTours')
global with sharing class TourListAPI {

    @HttpGet
    global static String getAllTours() {
        System.debug('Fetching all Tour__c records');

        // Query to fetch all Tour__c records
        List<Tour__c> tourRecords = [
            SELECT Id, Date__c, Day__c, Tour_Time__c, Available_Tours__c, Wave__c
            FROM Tour__c
        ];

        System.debug('Total Tours Found: ' + tourRecords.size());

        // Prepare JSON response
        List<Map<String, Object>> responseList = new List<Map<String, Object>>();
        for (Tour__c tour : tourRecords) {
            Map<String, Object> recordMap = new Map<String, Object>();
            recordMap.put('Total_Availability', tour.Available_Tours__c);
            recordMap.put('Time', tour.Tour_Time__c);
            recordMap.put('Day', tour.Day__c);
            recordMap.put('Date', tour.Date__c);
            recordMap.put('Wave', tour.Wave__c);
            responseList.add(recordMap);
        }

        // Return JSON response
        return JSON.serialize(new Map<String, Object>{
            'success' => true,
            'totalRecords' => tourRecords.size(),
            'tours' => responseList
        });
    }
}