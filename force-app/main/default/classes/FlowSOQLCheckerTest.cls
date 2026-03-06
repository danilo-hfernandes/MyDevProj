@isTest
public class FlowSOQLCheckerTest {
    
    @isTest
    static void testGetSOQLQueryCount() {
        Test.startTest();
        
        // Prepare input (not used in method, but Flow requires List input)
        List<String> inputList = new List<String>{ 'Test' };
        
        // Call the Invocable Method
        List<Integer> queryCount = FlowSOQLChecker.getSOQLQueryCount(inputList);
        
        Test.stopTest();
        
        // Assert that the returned query count is not null and is non-negative
        System.assertNotEquals(queryCount, null, 'Query count should not be null');
        System.assert(queryCount[0] >= 0, 'Query count should be a positive number or zero');
        
        System.debug('✅ Test Passed! Query Count: ' + queryCount[0]);
    }
}