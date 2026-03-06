@IsTest
public class CurrencyPicklistUpdaterTest {
    @IsTest
    static void testUpdatePicklist() {
        // Step 1: Setup test data
        List<Currency_Configuration__c> testCurrencies = new List<Currency_Configuration__c>();
        for (Integer i = 1; i <= 3; i++) {
            testCurrencies.add(new Currency_Configuration__c(
                Name = 'Currency_' + i,
                Exchange_Rate__c = 1.23,                          
                Country__c = 'Country ' + i,
                Currency__c = 'Currency_' + i
            ));
            
        }
        insert testCurrencies;

        // Additional assertions can be added if necessary
    }
}