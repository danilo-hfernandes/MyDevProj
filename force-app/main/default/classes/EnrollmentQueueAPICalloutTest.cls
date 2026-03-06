@IsTest
public class EnrollmentQueueAPICalloutTest {

    // Mock class to simulate HTTP response
    class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            // Simulate API returning IsValid = true and a ContactId
            res.setBody('{"IsValid": true, "ContactId": "0037d00000ABC123"}');
            return res;
        }
    }

    @IsTest
    static void testQueueableWithCallout() {
        // Setup test data
        List<HSI_Enrollment_Queue__c> enrollments = new List<HSI_Enrollment_Queue__c>();
        for (Integer i = 0; i < 3; i++) {
            enrollments.add(new HSI_Enrollment_Queue__c(
                Member_Number__c = 'TEST' + i,
                Failure_Count__c = 1,
                Successful_Processed__c = false,
                Record_Origin__c = 'TestOrigin'
            ));
        }
        insert enrollments;

        // Assign callout mock
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        // Execute queueable
        Test.startTest();
        System.enqueueJob(new EnrollmentQueueAPICallout(enrollments));
        Test.stopTest();

        // Verify results
        List<HSI_Enrollment_Queue__c> updatedEnrollments = [
            SELECT Id, Successful_Processed__c, Processed_On__c, Comments__c, Contact_Id__c
            FROM HSI_Enrollment_Queue__c
            WHERE Id IN :enrollments
        ];

        for (HSI_Enrollment_Queue__c rec : updatedEnrollments) {
            System.assertEquals(true, rec.Successful_Processed__c, 'Record should be marked as successful');
            System.assertNotEquals(null, rec.Processed_On__c, 'Processed_On__c should be set');
            System.assert(rec.Comments__c.contains('enrollment processed'), 'Comments should be populated');
            System.assertEquals('0037d00000ABC123', rec.Contact_Id__c, 'ContactId should be set from mock');
        }
    }

    @IsTest
    static void testQueueableWithBlankMemberNumber() {
        // Setup a record with blank Member_Number__c
        HSI_Enrollment_Queue__c record = new HSI_Enrollment_Queue__c(
            Member_Number__c = '',
            Failure_Count__c = 1,
            Record_Origin__c = 'TestOrigin'
        );
        insert record;

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        Test.startTest();
        System.enqueueJob(new EnrollmentQueueAPICallout(new List<HSI_Enrollment_Queue__c>{record}));
        Test.stopTest();

        // Fetch record to confirm no changes occurred
        HSI_Enrollment_Queue__c fetched = [SELECT Id, Successful_Processed__c FROM HSI_Enrollment_Queue__c WHERE Id = :record.Id];
        System.assertEquals(false, fetched.Successful_Processed__c, 'Blank Member_Number__c should not be processed');
    }
}