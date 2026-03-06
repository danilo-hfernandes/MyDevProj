@isTest
public class ResortWeekPremiumCashBackReturnTest {

    @isTest
    static void testSendResortWeekRefundAPI_Success() {

        // Set up test data
        Account testAccount = new Account(Name = 'Test Account', Member_Number__c = 'TestMember123');
        insert testAccount;

        Contact testContact = new Contact(FirstName = 'Test', LastName = 'Contact', AccountId = testAccount.Id); //, Is_Main_Contact__c = true
        insert testContact;

        testAccount.Parent_Child_Contact_Id__c = testContact.Id;
        Update testAccount;
        
        Opportunity testOpportunity = new Opportunity(Name = 'Test Opportunity', StageName = 'New', CloseDate = Date.today().addDays(10), AccountId = testAccount.Id);
        insert testOpportunity;

        
        // Step 1: Create a Product (Resort Weeks)
        Product2 testProduct = new Product2(
            Name = 'Resort Weeks', 
            IsActive = true
        );
        insert testProduct;
        
        
        // Step 3: Create a PricebookEntry for the Product
        PricebookEntry testPricebookEntry = new PricebookEntry(
            Pricebook2Id = '01s3t0000009EwQAAU' , //standardPricebook.Id,
            Product2Id = testProduct.Id,
            UnitPrice = 100, 
            IsActive = true
        );
        insert testPricebookEntry;
        
        OpportunityLineItem testOpportunityLineItem = new OpportunityLineItem(
            OpportunityId = testOpportunity.Id,
            PricebookEntryId = testPricebookEntry.Id, //'01u3t00000SbCimAAF', 
            //PricebookEntryId = '01u3t00000SbCimAAF', 
            UnitPrice = 100,
            Quantity = 1,
            Request_Id__c = '12345',
            Inventory_Id__c = '54321'
        );
        insert testOpportunityLineItem;

        //Prepare the RequestWrapper input
        ResortWeekPremiumCashBackReturn.RequestWrapper reqWrapper = new ResortWeekPremiumCashBackReturn.RequestWrapper();
        reqWrapper.OppId = testOpportunity.Id;
        reqWrapper.TransactionTypeId = '76';

        // Add to the list
        List<ResortWeekPremiumCashBackReturn.RequestWrapper> input = new List<ResortWeekPremiumCashBackReturn.RequestWrapper>{reqWrapper};
            
        Test.startTest();

        // Mock the HTTP response
        Test.setMock(HttpCalloutMock.class, new RefundAPIHttpMock());

        // Execute the method
        List<ResortWeekPremiumCashBackReturn.ReturnValueClass> results = ResortWeekPremiumCashBackReturn.sendResortWeekRefundAPI(input);
        
        // Verify the results
        System.assertEquals(1, results.size(), 'There should be one result returned.');
        System.assertEquals('Refund was sent successfully.', results[0].returnValue, 'Expected success message.');
        
        Test.stopTest();
    }

    /*
    @isTest
    static void testSendResortWeekRefundAPI_NoOpportunities() {
        // Execute the method with no opportunities
        List<String> oppIds = new List<String>();
        List<ResortWeekPremiumCashBackReturn.ReturnValueClass> results = ResortWeekPremiumCashBackReturn.sendResortWeekRefundAPI(oppIds);

        // Verify the results
        System.assertEquals(1, results.size(), 'There should be one result returned.');
        System.assertEquals('No Opportunity found.', results[0].returnValue, 'Expected "No Opportunity found" message.');
    }
*/
    @isTest
    static void testSendResortWeekRefundAPI_Error() {

        // Set up test data
        Account testAccount = new Account(Name = 'Test Account', Member_Number__c = 'TestMember123');
        insert testAccount;

        Contact testContact = new Contact(FirstName = 'Test', LastName = 'Contact', AccountId = testAccount.Id);
        insert testContact;

        testAccount.Parent_Child_Contact_Id__c = testContact.Id;
        Update testAccount;

        Opportunity testOpportunity = new Opportunity(Name = 'Test Opportunity', StageName = 'New', CloseDate = Date.today().addDays(10), AccountId = testAccount.Id);
        insert testOpportunity;


        // Step 1: Create a Product (Resort Weeks)
        Product2 testProduct = new Product2(
            Name = 'Resort Weeks', 
            IsActive = true
        );
        insert testProduct;
        
        
        // Step 3: Create a PricebookEntry for the Product
        PricebookEntry testPricebookEntry = new PricebookEntry(
            Pricebook2Id = '01s3t0000009EwQAAU' , //standardPricebook.Id,
            Product2Id = testProduct.Id,
            UnitPrice = 100, 
            IsActive = true
        );
        insert testPricebookEntry;
        
        OpportunityLineItem testOpportunityLineItem = new OpportunityLineItem(
            OpportunityId = testOpportunity.Id,
            PricebookEntryId = testPricebookEntry.Id, //'01u3t00000SbCimAAF', 
            //PricebookEntryId = '01u3t00000SbCimAAF', 
            UnitPrice = 100,
            Quantity = 1,
            Request_Id__c = '12345',
            Inventory_Id__c = '54321'
        );
        insert testOpportunityLineItem;
        
        /*
        OpportunityLineItem testOpportunityLineItem = new OpportunityLineItem(
            OpportunityId = testOpportunity.Id,
            PricebookEntryId = '01u3t00000SbCimAAF', 
            UnitPrice = 100,
            Quantity = 1,
            Request_Id__c = '12345',
            Inventory_Id__c = '54321'
        );
        insert testOpportunityLineItem;
        */

        //Prepare the RequestWrapper input
        ResortWeekPremiumCashBackReturn.RequestWrapper reqWrapper = new ResortWeekPremiumCashBackReturn.RequestWrapper();
        reqWrapper.OppId = testOpportunity.Id;
        reqWrapper.TransactionTypeId = '76';

        // Add to the list
        List<ResortWeekPremiumCashBackReturn.RequestWrapper> input = new List<ResortWeekPremiumCashBackReturn.RequestWrapper>{reqWrapper};

        Test.startTest();

        // Mock the HTTP response to simulate an error
        Test.setMock(HttpCalloutMock.class, new RefundAPIHttpMockError());
        
        // Execute the method
		List<ResortWeekPremiumCashBackReturn.ReturnValueClass> results = ResortWeekPremiumCashBackReturn.sendResortWeekRefundAPI(input);
        
        // Verify the results
        System.assertEquals(1, results.size(), 'There should be one result returned.');
        System.assertEquals('We could not complete the cancellation.', results[0].returnValue, 'Expected error message.');
		//System.assertEquals('No Opportunity found.', results[0].returnValue, 'Expected error message.');

        Test.stopTest();

    }
}