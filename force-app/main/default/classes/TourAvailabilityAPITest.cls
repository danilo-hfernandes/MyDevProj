@isTest
private class TourAvailabilityAPITest {

    private static String buildRequestBody(String dateVal, String timeVal, String waveVal) {
        return JSON.serialize(new Map<String, String>{
            'Date__c' => dateVal,
            'Tour_Time__c' => timeVal,
            'Wave__c' => waveVal
        });
    }

    @isTest
    static void testSuccessReturnsZeroIfNoAvailabilitySet() {
        Date testDate = Date.today();
        Time testTime = Time.newInstance(10, 0, 0, 0);
        String wave = 'Morning';

        insert new Tour__c(
            Date__c = testDate,
            Tour_Time__c = testTime,
            Wave__c = wave
        );

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(buildRequestBody(String.valueOf(testDate), '10:00:00Z', wave));
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;

        String result = TourAvailabilityAPI.getAvailability();
        System.assert(result.contains('"Date__c"'));
        System.assert(result.contains('"Wave__c"'));
        System.assert(result.contains('"Total_Availability"'));
    }

    @isTest
    static void testMissingDate() {
        RestContext.request = new RestRequest();
        RestContext.request.requestBody = Blob.valueOf(buildRequestBody('', '10:00:00Z', 'Morning'));

        String result = TourAvailabilityAPI.getAvailability();
        System.assert(result.contains('Missing or empty Date__c'));
    }

    @isTest
    static void testMissingTime() {
        RestContext.request = new RestRequest();
        RestContext.request.requestBody = Blob.valueOf(buildRequestBody(String.valueOf(Date.today()), '', 'Morning'));

        String result = TourAvailabilityAPI.getAvailability();
        System.assert(result.contains('Missing or empty Tour_Time__c'));
    }

    @isTest
    static void testMissingWave() {
        RestContext.request = new RestRequest();
        RestContext.request.requestBody = Blob.valueOf(buildRequestBody(String.valueOf(Date.today()), '10:00:00Z', ''));

        String result = TourAvailabilityAPI.getAvailability();
        System.assert(result.contains('Missing or empty Wave__c'));
    }

    @isTest
    static void testInvalidDateFormat() {
        RestContext.request = new RestRequest();
        RestContext.request.requestBody = Blob.valueOf(buildRequestBody('03-24-2025', '10:00:00Z', 'Morning'));

        String result = TourAvailabilityAPI.getAvailability();
        System.assert(result.contains('Invalid Date__c format'));
    }

    @isTest
    static void testInvalidTimeFormat() {
        RestContext.request = new RestRequest();
        RestContext.request.requestBody = Blob.valueOf(buildRequestBody(String.valueOf(Date.today()), '10-00-00', 'Morning'));

        String result = TourAvailabilityAPI.getAvailability();
        System.assert(result.contains('Invalid Tour_Time__c format'));
    }

    @isTest
    static void testNoMatchingRecord() {
        RestContext.request = new RestRequest();
        RestContext.request.requestBody = Blob.valueOf(buildRequestBody(String.valueOf(Date.today()), '12:34:56Z', 'NonexistentWave'));

        String result = TourAvailabilityAPI.getAvailability();
        System.assert(result.contains('"Total_Availability":0'));
    }
}