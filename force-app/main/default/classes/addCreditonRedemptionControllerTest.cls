/*
    *********************************************************
    Test class for Apex: addCreditonRedemptionController
    Created Date       : August 23, 2024
    @description       : This is class is controller of AddCreditonRedemption LWC Component
    Test class         : addCreditonRedemptionControllerTest
    Modification Log:
    Ver   Date         Author                               Modification
    1.0   23-08-2024    sifra                                  Initial Version
    *********************************************************
    */
@isTest
public class addCreditonRedemptionControllerTest {

    @testSetup
    static void setupTestData() {
        // Create test data for Redemption__c and related Opportunity
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            CloseDate = Date.today(),
            StageName = 'Prospecting',
            Member_Number__c = '123456'
        );
        insert opp;

        Redemption__c redemption = new Redemption__c(
            Opportunity__c = opp.Id,
            Redemption_Amount__c = 100.0,
            Status__c = 'Reservation Pending',
            Redemption_Type__c='Credits'
        );
        insert redemption;
    }

    @isTest
    static void testMakeApiCalloutSuccess() {
        // Fetch the Redemption record
        Redemption__c redemption = [SELECT Id FROM Redemption__c LIMIT 1];

        // Mock the HTTP response for a successful API callout
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setHeader('Content-Type', 'application/json');
        mockResponse.setBody('{"message":"Success"}');
        mockResponse.setStatusCode(200);

        // Set up the mock for the HTTP callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(mockResponse));

        Test.startTest();
        addCreditonRedemptionController.makeApiCallout(redemption.Id);
        Test.stopTest();

        // Verify the Redemption record was updated correctly
       redemption = [SELECT Add_Credit_Status__c, Status__c FROM Redemption__c WHERE Id = :redemption.Id];
    
        System.assertEquals('Redemption Confirmed', redemption.Status__c);
    }

    @isTest
    static void testMakeApiCalloutError() {
        // Fetch the Redemption record
        Redemption__c redemption = [SELECT Id,Redemption_Type__c FROM Redemption__c where Redemption_Type__c='Credits' LIMIT 1];

        // Mock the HTTP response for a failed API callout
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setHeader('Content-Type', 'application/json');
        mockResponse.setBody('{"message":"Error"}');
        mockResponse.setStatusCode(500);

        // Set up the mock for the HTTP callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(mockResponse));

        Test.startTest();
        addCreditonRedemptionController.makeApiCallout(redemption.Id);
        Test.stopTest();

        // Verify the Redemption record was updated correctly
       redemption = [SELECT Add_Credit_Status__c, Status__c FROM Redemption__c WHERE Id = :redemption.Id];
     
       // System.assertEquals('Redemption Confirmed', redemption.Status__c);
    }
}