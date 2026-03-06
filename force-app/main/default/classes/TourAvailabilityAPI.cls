@RestResource(urlMapping='/getAvailability')
global with sharing class TourAvailabilityAPI {

    @HttpPost
    global static String getAvailability() {
        RestRequest req = RestContext.request;
        String requestBody = req.requestBody.toString();
        System.debug('Incoming Request Body: ' + requestBody);
        
        Map<String, Object> requestData = (Map<String, Object>) JSON.deserializeUntyped(requestBody);

        if (!requestData.containsKey('Date__c') || String.isEmpty((String) requestData.get('Date__c')))
            return errorResponse('Missing or empty Date__c field');

        if (!requestData.containsKey('Tour_Time__c') || String.isEmpty((String) requestData.get('Tour_Time__c')))
            return errorResponse('Missing or empty Tour_Time__c field');

        if (!requestData.containsKey('Wave__c') || String.isEmpty((String) requestData.get('Wave__c')))
            return errorResponse('Missing or empty Wave__c field');

        Date dateValue;
        Time tourTimeValue;
        String waveValue = (String) requestData.get('Wave__c');

        try {
            dateValue = Date.valueOf((String) requestData.get('Date__c'));
        } catch (Exception e) {
            return errorResponse('Invalid Date__c format. Use YYYY-MM-DD.');
        }

        try {
            String timeStr = ((String) requestData.get('Tour_Time__c')).replace('Z', '');
            List<String> parts = timeStr.split(':');
            Integer hour = Integer.valueOf(parts[0]);
            Integer minute = Integer.valueOf(parts[1]);
            Integer second = Integer.valueOf(parts[2].substring(0, 2));
            tourTimeValue = Time.newInstance(hour, minute, second, 0);
        } catch (Exception e) {
            return errorResponse('Invalid Tour_Time__c format. Use HH:mm:ss or HH:mm:ss.SSSZ.');
        }

        List<Tour__c> matchingRecords = [
            SELECT Id, Available_Tours__c, Tour_Time__c, Date__c, Wave__c
            FROM Tour__c
            WHERE Date__c = :dateValue
            AND Tour_Time__c = :tourTimeValue
            AND Wave__c = :waveValue
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];

        if (matchingRecords.isEmpty()) {
            return JSON.serialize(new Map<String, Object>{
                'Date__c' => dateValue,
                'Tour_Time__c' => tourTimeValue,
                'Wave__c' => waveValue,
                'Total_Availability' => 0
            });
        }

        Tour__c matchedTour = matchingRecords[0];

        return JSON.serialize(new Map<String, Object>{
            'Date__c' => matchedTour.Date__c,
            'Tour_Time__c' => matchedTour.Tour_Time__c,
            'Wave__c' => matchedTour.Wave__c,
            'Total_Availability' => matchedTour.Available_Tours__c
        });
    }

    private static String errorResponse(String message) {
        return JSON.serialize(new Map<String, Object>{
            'success' => false,
            'message' => message
        });
    }
}