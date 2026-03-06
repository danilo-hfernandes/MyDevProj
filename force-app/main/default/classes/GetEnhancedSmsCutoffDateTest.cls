@IsTest
private class GetEnhancedSmsCutoffDateTest {

    @IsTest
    static void testGetCutoffDate_RecordExists() {
        // Arrange
        Date expectedDate = Date.newInstance(2026, 1, 1);

        Enhanced_SMS_Cutoff_Date__c cs = new Enhanced_SMS_Cutoff_Date__c(
            Name = 'Default',
            Cutoff_Date__c = expectedDate
        );
        insert cs;

        // Act
        Test.startTest();
        List<GetEnhancedSmsCutoffDate.Output> results =
            GetEnhancedSmsCutoffDate.getCutoffDate(new List<String>{'test'});
        Test.stopTest();

        // Assert
        System.assertEquals(1, results.size(), 'Should return one result');
        System.assertNotEquals(null, results[0], 'Result should not be null');
        System.assertEquals(
            expectedDate,
            results[0].cutoffDate,
            'Returned cutoff date should match the Custom Setting value'
        );
    }


    @IsTest
    static void testGetCutoffDate_NoRecord() {
        // No Custom Setting record inserted

        Test.startTest();
        List<GetEnhancedSmsCutoffDate.Output> results =
            GetEnhancedSmsCutoffDate.getCutoffDate(new List<String>{'test'});
        Test.stopTest();

        // Assert
        System.assertEquals(1, results.size(), 'Should still return one result');
        System.assertEquals(
            null,
            results[0].cutoffDate,
            'Cutoff date should be null when no Custom Setting exists'
        );
    }
}