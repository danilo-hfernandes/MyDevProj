@isTest
global class MetadataServiceAPIMock implements HttpCalloutMock {
    global HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        
        // Example response body, should match the expected Metadata API response structure
        String mockResponse = '{' +
            '"records": [' +
            '   {"fullName": "Account.RecordType1", "picklistValues": [{"picklist": "PicklistFieldName", "values": [{"fullName": "ExistingValue"}]}]},' +
            '   {"fullName": "Account.RecordType2", "picklistValues": [{"picklist": "PicklistFieldName", "values": [{"fullName": "ExistingValue"}]}]}' +
            ']' +
        '}';
        res.setBody(mockResponse);
        res.setStatusCode(200);
        return res;
    }
}