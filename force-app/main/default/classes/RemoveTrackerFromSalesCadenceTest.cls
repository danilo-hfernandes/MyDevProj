@IsTest
private class RemoveTrackerFromSalesCadenceTest {
    private class Mock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse r = new HttpResponse();
            r.setStatusCode(200);
            r.setStatus('OK');
            r.setBody('{"ok":true}');
            return r;
        }
    }

    @IsTest static void coverQueueable() {
        Test.setMock(HttpCalloutMock.class, new Mock());
        Set<Id> ids = new Set<Id>{ (Id) '001000000000001' }; // static fake Id
        Test.startTest();
        System.enqueueJob(new RemoveTrackerFromSalesCadenceQueueable(ids, null));
        Test.stopTest();
    }
}