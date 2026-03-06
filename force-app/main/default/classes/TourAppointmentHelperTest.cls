@isTest
private class TourAppointmentHelperTest {
    
@testSetup
static void setupData() {
    
            
        Account acc = new Account(Name = 'Test Account',Email__c = 'victor.goncalves@nerdsoft.com');
        insert acc;

        //Pricebook2  standardPb = [select id, name, isActive from Pricebook2 where IsStandard = true limit 1];
        Id  standardPb = Test.getStandardPricebookId();
        Pricebook2 pbk1 = new Pricebook2 (Name='Test Pricebook Entry 1',Description='Test Pricebook Entry 1', isActive=true);
        insert pbk1;
        
        Product2 prd1 = new Product2 (Name='Test Product Entry 1',Description='Test Product Entry 1', isActive = true);
        insert prd1;        
        
        PricebookEntry pbe1 = new PricebookEntry (Product2ID=prd1.id,Pricebook2ID=standardPb,UnitPrice=50, isActive=true);
        insert pbe1;
        
        Opportunity opp1 = new Opportunity (Name='Opp1',StageName='Negotiation',CloseDate=Date.today(),Pricebook2Id = pbe1.Pricebook2Id,AccountId = acc.id);
        insert opp1;
    
    // Create a lead with required fields
    Lead testLead = new Lead(
        LastName = 'Test',
        Company = 'Test Co',
        Email = 'test@example.com',
        Phone = '123-456-7890',
        Tour_Time__c = Time.newInstance(10, 0, 0, 0)
    );
    insert testLead;

    // Create a tour
    Tour__c tour = new Tour__c(
        Date__c = Date.today(),
        Tour_Time__c = Time.newInstance(10, 0, 0, 0),
        Tour_Allotment__c = 10,
        Booked_Tours__c = 2
    );
    insert tour;

    // Create an appointment linked to the lead and matching the tour
    Tour_appointment__c appt = new Tour_appointment__c(
        Lead_ID__c = testLead.Id,
        Appointment_Date__c = Date.today(),
        Appointment_Time__c = Time.newInstance(10, 0, 0, 0),
        TA_Rebooked_From_Comp__c = false,
        Opportunity__c = opp1.Id,
        Opp_Status__c = 'Booked'
    );
    insert appt;

    // Link the appointment to the tour for cancellation test
    appt.Tour__c = tour.Id;
    update appt;
}



    @isTest
    static void testUpdateTourDetails() {
        Tour_appointment__c appt = [SELECT Id, Lead_ID__c, TA_Rebooked_From_Comp__c FROM Tour_appointment__c LIMIT 1];
        List<Tour_appointment__c> apptList = new List<Tour_appointment__c>{appt};

        Test.startTest();
        TourAppointmentHelper.updateTourDetails(apptList);
        Test.stopTest();
    }

    @isTest
    static void testProcessAfterEvents() {
        Tour_appointment__c appt = [SELECT Id, Appointment_Date__c, Appointment_Time__c FROM Tour_appointment__c LIMIT 1];

        Test.startTest();
        TourAppointmentHelper.processAfterEvents(new List<Tour_appointment__c>{appt});
        Test.stopTest();
    }

    @isTest
    static void testProcessCancelledAppointments() {
        Tour_appointment__c appt = [SELECT Id FROM Tour_appointment__c WHERE Tour__c != null LIMIT 1];

        Test.startTest();
        TourAppointmentHelper.processCancelledAppointments(new Set<Id>{appt.Id});
        Test.stopTest();
    }
}