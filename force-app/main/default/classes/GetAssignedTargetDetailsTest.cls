@isTest(seeAllData = true)
public class GetAssignedTargetDetailsTest {
    
    // Utility method to create test data
    private static void createTestData() {
        
        // Create test Target records
        Lead leadrec = new Lead();
        leadrec.LastName = 'test';
        leadrec.Company = 'test';
        leadrec.LeadSource = 'CFD FB';
        leadrec.Phone = '1234567891';
        leadrec.Email = 'd3rths@ds.com';
        insert leadrec;
    }
    
    // Test method for getMultipleCadenceNamewithTargetList
    @isTest
    static void testGetMultipleCadenceNamewithTargetList() {
        // Create test data
        createTestData();
        
        // Create test input
        List<String> listOfSalesCadenceNames = new List<String>{'Welcome Calls-VI-ENG', 'Welcome Calls- Advantage Program/HSI-ENG'};
            Set<Id> targetIds = new Set<Id>{[SELECT Id FROM Lead LIMIT 1].Id};
                
                // Call the method and check results
                Test.startTest();
        Map<String, List<Id>> result = GetAssignedTargetDetails.getMultipleCadenceNamewithTargetList(listOfSalesCadenceNames, targetIds);
        Test.stopTest();
    }
    
    // Test method for getSingleCadenceNamewithTargetList
    @isTest
    static void testGetSingleCadenceNamewithTargetList() {
        // Create test data
        createTestData();
        
        // Test input
        String salesCadenceName = 'Welcome Calls-VI-ENG';
        
        // Call the method and check results
        Test.startTest();
        List<Id> result = GetAssignedTargetDetails.getSingleCadenceNamewithTargetList(salesCadenceName);
        Test.stopTest();
    }
}