@isTest
public class OpportunityTravelerTabControllerTest {
    
    @testSetup
    static void setupTestData() {
        // Create test Opportunity
        Opportunity testOpp = new Opportunity(Name = 'Test Opportunity', StageName = 'Prospecting', CloseDate = Date.today());
        insert testOpp;
        
        // Create test Traveler records related to the Opportunity
        Traveler__c traveler1 = new Traveler__c(
            First_Name__c = 'John',
            Last_Name__c = 'Doe',
            Date_Of_Birth__c = Date.newInstance(1990, 1, 1),
            Age__c = 30,
            Occupation__c = 'Engineer',
            Relation__c = 'Self',
            Opportunity__c = testOpp.Id
        );
        
        Traveler__c traveler2 = new Traveler__c(
            First_Name__c = 'Jane',
            Last_Name__c = 'Doe',
            Date_Of_Birth__c = Date.newInstance(1992, 2, 2),
            Age__c = 28,
            Occupation__c = 'Doctor',
            Relation__c = 'Spouse',
            Opportunity__c = testOpp.Id
        );
        
        insert traveler1;
        insert traveler2;
    }

    @isTest
    static void testGetTravelerData() {
        // Retrieve the Opportunity created in testSetup
        Opportunity testOpp = [SELECT Id FROM Opportunity LIMIT 1];
        
        // Call the getTravelerData method
        Test.startTest();
        List<Traveler__c> travelers = OpportunityTravelerTabController.getTravelerData(testOpp.Id);
		
        Test.stopTest();
        
        // Assert that traveler data is retrieved
        System.assertNotEquals(null, travelers);
        System.assertEquals(2, travelers.size());
        System.assertEquals('John', travelers[0].First_Name__c);
        System.assertEquals('Jane', travelers[1].First_Name__c);
    }

    @isTest
    static void testInsertTravelerData() {
        // Retrieve the Opportunity created in testSetup
        Opportunity testOpp = [SELECT Id FROM Opportunity LIMIT 1];
        
        // Create traveler data for insertion
        List<Map<String, String>> travelerData = new List<Map<String, String>>();
        
        Map<String, String> traveler1 = new Map<String, String>{
            'First_Name__c' => 'Sam',
            'Last_Name__c' => 'Smith',
            'Date_Of_Birth__c' => '1985-07-07',
            'Age__c' => '36',
            'Occupation__c' => 'Teacher',
            'Relation__c' => 'Friend',
                'Id' => '001'
        };
        
        Map<String, String> traveler2 = new Map<String, String>{
            'First_Name__c' => 'Linda',
            'Last_Name__c' => 'Brown',
            'Date_Of_Birth__c' => '1995-03-15',
            'Age__c' => '26',
            'Occupation__c' => 'Nurse',
            'Relation__c' => 'Cousin',
			'Id' => '002'
        };
        
        travelerData.add(traveler1);
        travelerData.add(traveler2);
        
        // Call the insertTravelerData method
        Test.startTest();
        List<Traveler__c> insertedTravelers = OpportunityTravelerTabController.insertTravelerData(testOpp.Id, travelerData);
        Test.stopTest();
        
    }
    
    @isTest
    static void testInsertTravelerDataWithErrorHandling() {
        // Test error handling by passing incorrect data (invalid Date of Birth)
        Opportunity testOpp = [SELECT Id FROM Opportunity LIMIT 1];
        
        List<Map<String, String>> travelerData = new List<Map<String, String>>();
        
        Map<String, String> traveler1 = new Map<String, String>{
            'First_Name__c' => 'Invalid',
            'Last_Name__c' => 'Data',
            'Date_Of_Birth__c' => 'InvalidDate',
            'Age__c' => '40',
            'Occupation__c' => 'None',
            'Relation__c' => 'None'
        };
        
        travelerData.add(traveler1);
        
        // Call the insertTravelerData method and handle the exception
        Test.startTest();
        List<Traveler__c> result = OpportunityTravelerTabController.insertTravelerData(testOpp.Id, travelerData);
        Test.stopTest();
        
        // Assert that no traveler data is inserted and error is handled
        System.assertEquals(null, result);
        
        // Verify the error handler record was created
        List<Error_Handler__c> errorRecords = [SELECT Id, Name, Error_Message__c FROM Error_Handler__c WHERE Name = 'Apex Class : OpportunityTravelerTabController'];
        System.assertNotEquals(0, errorRecords.size());
        System.assert(errorRecords[0].Error_Message__c.contains('Exception occurrred'));
    }
}