@isTest
private class TourListAPITest {

    @isTest
    static void testGetAllTours_withData() {
        // Create test records (Available_Tours__c is read-only, skip setting it)
        insert new Tour__c(
            Date__c = Date.today(),
            Day__c = 'Monday',
            Tour_Time__c = Time.newInstance(9, 0, 0, 0),
            Wave__c = 'Morning'
        );

        insert new Tour__c(
            Date__c = Date.today().addDays(1),
            Day__c = 'Tuesday',
            Tour_Time__c = Time.newInstance(10, 30, 0, 0),
            Wave__c = 'Afternoon'
        );

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;

        String result = TourListAPI.getAllTours();
        System.debug('TourListAPI Response: ' + result);

        System.assert(result.contains('"success":true'));
        System.assert(result.contains('"totalRecords":2'));
        System.assert(result.contains('"tours"'));
    }

    @isTest
    static void testGetAllTours_noData() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;

        String result = TourListAPI.getAllTours();
        System.debug('Empty Response: ' + result);

        System.assert(result.contains('"success":true'));
        System.assert(result.contains('"totalRecords":0'));
        System.assert(result.contains('"tours":[]'));
    }
}