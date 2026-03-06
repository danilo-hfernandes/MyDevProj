/*@IsTest
private class TourAppointmentCompControllerTest {
    
    @TestSetup
    static void setupTestData() {
        
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.Email__c = 'victor.goncalves@nerdsoft.com';
        insert acc;
        
        // Create an Opportunity
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(10),
            AccountId = acc.Id
        );
        insert opp;

        // Create a Tour record
        Tour__c tour = new Tour__c(
            Name = 'Test Tour',
            Date__c = Date.today().addDays(2),
            Tour_Time__c = Time.newInstance(10, 0, 0, 0),
            Booked_Tours__c =5,
            Tour_Allotment__c=10,
            Location__c = 'Test Location',
            Wave__c = 'Wave 1'
        );
        insert tour;
        system.debug('Tour Test record'+tour);

        // Create a Tour Appointment
        Tour_appointment__c tourApp = new Tour_appointment__c(
            Name = 'Test Tour Appointment',
            Opportunity__c = opp.Id,
            Tour__c = tour.Id,
            Appointment_Date__c = tour.Date__c,
            Appointment_Time__c = tour.Tour_Time__c,
            Opp_Status__c = 'Booked'
        );
        insert tourApp;
    }

    @IsTest
    static void testGetTourAppointment() {
        // Fetch Opportunity ID
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        
        // Call the method
        Test.startTest();
        Tour_appointment__c result = TourAppointmentCompController.getTourAppointment(opp.Id);
        Test.stopTest();

        // Assertions
        System.assertNotEquals(result, null, 'Tour Appointment should not be null');
        System.assertEquals(result.Opp_Status__c, 'Booked', 'Status should be Booked');
    }

    @IsTest
    static void testCreateRebookTourAppointment() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Tour__c tour = [SELECT Id FROM Tour__c LIMIT 1];

        // Call method
        Test.startTest();
        String response = TourAppointmentCompController.createRebookTourAppointment(opp.Id, tour.Id);
        Test.stopTest();

        // Verify new appointment was created
        List<Tour_appointment__c> updatedTours = [SELECT Id, Opp_Status__c FROM Tour_appointment__c WHERE Opportunity__c = :opp.Id];
        System.assertEquals(updatedTours.size(), 2, 'Should have two tour appointments');
        System.assertEquals(updatedTours[0].Opp_Status__c, 'Rescheduled', 'Existing tour should be Rescheduled');
        System.assertEquals(updatedTours[1].Opp_Status__c, 'Booked', 'New tour should be Booked');
        System.assertEquals(response, 'Tour rebooked successfully!', 'Response should confirm rebooking');
    }

    @IsTest
    static void testGetToursByDateTime() {
        Date testDate = Date.today().addDays(2);
       String testTime = '10:00 AM';  // Matches the stored format
        system.debug('Date'+testDate);
		system.debug('Time'+testTime);
        // Call method
        Test.startTest();
        List<Tour__c> tours = TourAppointmentCompController.getToursByDateTime(testDate, testTime);
        Test.stopTest();

        // Verify result
        //System.assertEquals(tours.size(), 1, 'Should return 1 tour');
        System.assertEquals(tours[0].Tour_Time__c, Time.newInstance(10, 0, 0, 0), 'Time should match');
    }

    @IsTest
    static void testCreateRebookTourAppointment_InvalidTourId() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        system.debug('Opportunity'+opp);

        // Call method with invalid tour ID
        Test.startTest();
        try {
            TourAppointmentCompController.createRebookTourAppointment(opp.Id, 'InvalidTourId');
            System.assert(false, 'Exception expected but not thrown');
        } catch (Exception e) {
           // System.assert(e.getMessage().contains('Tour record not found'), 'Expected error message for invalid tour ID');
        }
        Test.stopTest();
    }
}
*/
@IsTest
public class TourAppointmentCompControllerTest {

    /* -------------------------
       TEST DATA SETUP
    --------------------------*/
    @TestSetup
    static void setupData() {

            Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
            
            String uniqueEmail = 'testuser' + System.currentTimeMillis() + '@example.com';
            
            User u = new User(
                Alias = 'tuser',
                Email = uniqueEmail,
                UserName = uniqueEmail,
                LastName = 'User',
                TimeZoneSidKey = 'America/New_York',
                LocaleSidKey = 'en_US',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                ProfileId = p.Id,
                IsActive = true
            );
            insert u;

        // Create Lead
        Lead l = new Lead(
            FirstName = 'John',
            LastName = 'Doe',
            Company = 'Test Company',
            Email = 'john.doe@test.com',
            Phone = '3055551234',
            Leadsource = 'CFD'
        );
        insert l;

        // Create Opportunity
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(10)
        );
        insert opp;

        // Create Tour
        Tour__c tour = new Tour__c(
            Name = 'Morning Tour',
            Date__c = Date.today(),
            Tour_Time__c = Time.newInstance(10, 0, 0, 0),
            Booked_Tours__c = 0,
            Tour_Allotment__c = 10,
            Wave__c = 'Wave 1',
            Location__c = 'Main Office'
        );
        insert tour;

        // Existing Tour Appointment (non-cancelled)
        Tour_appointment__c ta = new Tour_appointment__c(
            Name = 'Existing Appointment',
            Opportunity__c = opp.Id,
            Tour__c = tour.Id,
            Opp_Status__c = 'Booked',
            Appointment_Date__c = tour.Date__c,
            Appointment_Time__c = tour.Tour_Time__c,
            Lead_Type__c = 'Lead',
            Lead_ID__c = l.Id
        );
        insert ta;

        // Cancelled appointment (should be skipped)
        Tour_appointment__c cancelledTA = new Tour_appointment__c(
            Name = 'Cancelled Appointment',
            Opportunity__c = opp.Id,
            Tour__c = tour.Id,
            Opp_Status__c = 'Cancelled'
        );
        insert cancelledTA;
    }

    /* -------------------------
       getTourAppointment
    --------------------------*/
    @IsTest
    static void testGetTourAppointment() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];

        Test.startTest();
        Tour_appointment__c ta =
            TourAppointmentCompController.getTourAppointment(opp.Id);
        Test.stopTest();

        System.assertNotEquals(null, ta);
        System.assertNotEquals('Cancelled', ta.Opp_Status__c);
    }

    /* -------------------------
       createRebookTourAppointment
    --------------------------*/
    @IsTest
    static void testCreateRebookTourAppointment() {

        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Tour__c tour = [SELECT Id FROM Tour__c LIMIT 1];
        User u = [SELECT Id FROM User WHERE IsActive = true LIMIT 1];

        Test.startTest();
        String result = TourAppointmentCompController.createRebookTourAppointment(
            opp.Id,
            tour.Id,
            u.Id,
            u.Id
        );
        Test.stopTest();

        System.assertEquals('Tour rebooked successfully!', result);

        // Verify new appointment created
        Tour_appointment__c newTA = [
            SELECT Opp_Status__c, TA_Rebooked_From_Comp__c
            FROM Tour_appointment__c
            WHERE Opportunity__c = :opp.Id
            AND Opp_Status__c = 'Booked'
            LIMIT 1
        ];

        System.assertEquals('Booked', newTA.Opp_Status__c);
        System.assertEquals(true, newTA.TA_Rebooked_From_Comp__c);
    }

    /* -------------------------
       getToursByDateTime (with time)
    --------------------------*/
/*    @IsTest
    static void testGetToursByDateTime_WithTime() {

        Test.startTest();
        List<Tour__c> tours =
            TourAppointmentCompController.getToursByDateTime(
                Date.today(),
                '10:00 AM'
            );
        Test.stopTest();

        System.assertEquals(1, tours.size());
    }

    /* -------------------------
       getToursByDateTime (no time)
    --------------------------*/
/*    @IsTest
    static void testGetToursByDateTime_NoTime() {

        Test.startTest();
        List<Tour__c> tours =
            TourAppointmentCompController.getToursByDateTime(
                Date.today(),
                null
            );
        Test.stopTest();

        System.assert(tours.size() > 0);
    }
*/

    /* -------------------------
       getToursByDateTime - Exception
    --------------------------*/
    @IsTest
    static void testGetToursByDateTime_NullDate() {
        Boolean exceptionThrown = false;
    
        Test.startTest();
        try {
            TourAppointmentCompController.getToursByDateTime(null, '10:00 AM');
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        Test.stopTest();
    
        System.assertEquals(true, exceptionThrown, 'Expected AuraHandledException');
    }

    /* -------------------------
       getActiveUsers
    --------------------------*/
    @IsTest
    static void testGetActiveUsers() {

        Test.startTest();
        List<Map<String, String>> users =
            TourAppointmentCompController.getActiveUsers();
        Test.stopTest();

        System.assert(users.size() > 0);
        System.assert(users[0].containsKey('label'));
        System.assert(users[0].containsKey('value'));
    }

    /* -------------------------
       convertStringToTime
    --------------------------*/
    @IsTest
    static void testConvertStringToTime() {

        Time t = TourAppointmentCompController.convertStringToTime('4:30 PM');
        System.assertEquals(16, t.hour());
        System.assertEquals(30, t.minute());
    }

    /* -------------------------
       convertStringToTime - Exception
    --------------------------*/
    @IsTest
    static void testConvertStringToTime_Blank() {
        Boolean exceptionThrown = false;
    
        try {
            TourAppointmentCompController.convertStringToTime('');
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
    
        System.assertEquals(true, exceptionThrown, 'Expected AuraHandledException');
    }

}