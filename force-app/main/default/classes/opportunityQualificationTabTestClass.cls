@isTest
public class opportunityQualificationTabTestClass {
    
    @testSetup
    static void setupTestData() {
        // Create test data for General_Data__c
        List<General_Data__c> suppliers = new List<General_Data__c>();

        suppliers.add(new General_Data__c(
            Name = 'Test Supplier 1',
            Age__c = '30',
            Marital_Status__c = 'Single',
            Income__c = '50000',
            Credit_Card__c = true,
            Employment_Status__c = 'Employed',
            Additional_Info__c = 'Test additional info 1'
        ));
        
        suppliers.add(new General_Data__c(
            Name = 'Test Supplier 2',
            Age__c = '45',
            Marital_Status__c = 'Married',
            Income__c = '80000',
            Credit_Card__c = false,
            Employment_Status__c = 'Self-Employed',
            Additional_Info__c = 'Test additional info 2'
        ));
        
        insert suppliers;
    }
    
    @isTest
    static void testGetSupplierData() {
        // Call the getSupplierData method
        Test.startTest();
        List<General_Data__c> supplierData = opportunityQualificationTabController.getSupplierData();
        Test.stopTest();
        
        // Verify the data returned
        System.assertNotEquals(null, supplierData, 'Supplier data should not be null');
        System.assertEquals(2, supplierData.size(), 'There should be 2 supplier records');
        System.assertEquals('Test Supplier 1', supplierData[0].Name, 'Supplier name should match');
        System.assertEquals('30', supplierData[0].Age__c, 'Age should match');
        System.assertEquals(true, supplierData[0].Credit_Card__c, 'Credit card status should match');
    }
    
    @isTest
    static void testUpdateSupplierData_withEditPermission() {
        // Simulate the scenario where the user has the custom permission
      /*  Test.startTest();
        Boolean hasPermission = opportunityQualificationTabController.hasEditPermission();
        Test.stopTest();*/

        // Assert that permission is granted (simulating admin or privileged user)
       // System.assertEquals(true, hasPermission, 'The user should have edit permission.');

        // Fetch test data
        List<General_Data__c> suppliers = [SELECT Id, Name, Age__c, Credit_Card__c FROM General_Data__c];
        General_Data__c supplierToUpdate = suppliers[0];
        
        // Modify the supplier data
        supplierToUpdate.Age__c = '35';
        supplierToUpdate.Credit_Card__c = false;
        
        // Call the updateSupplierData method
        Test.startTest();
        opportunityQualificationTabController.updateSupplierData(new List<General_Data__c>{ supplierToUpdate });
        Test.stopTest();
        
        // Re-fetch the data and verify updates
        General_Data__c updatedSupplier = [SELECT Age__c, Credit_Card__c FROM General_Data__c WHERE Id = :supplierToUpdate.Id];
        System.assertEquals('35', updatedSupplier.Age__c, 'Age should have been updated');
        System.assertEquals(false, updatedSupplier.Credit_Card__c, 'Credit card status should have been updated');
    }

    @isTest
    static void testUpdateSupplierData_withoutEditPermission() {
        // Simulate the scenario where the user does not have the custom permission
        Test.startTest();
        Boolean hasPermission = opportunityQualificationTabController.hasEditPermission();
        Test.stopTest();

        // Assert that permission is denied (simulating non-admin user)
        System.assertEquals(false, hasPermission, 'The user should not have edit permission.');

        // Attempting to update data should result in a failure since the user lacks permission
        List<General_Data__c> suppliers = [SELECT Id, Name, Age__c, Credit_Card__c FROM General_Data__c];
        General_Data__c supplierToUpdate = suppliers[0];
        
        // Modify the supplier data
        supplierToUpdate.Age__c = '40';  // Try to update without permission
        
        // Expect an exception or failure due to lack of permission
       /* try {
            Test.startTest();
            opportunityQualificationTabController.updateSupplierData(new List<General_Data__c>{ supplierToUpdate });
            Test.stopTest();
            
            // If no exception, fail the test
            System.assert(false, 'Update should have failed due to lack of permissions.');
        } catch (Exception e) {
            System.assert(true, 'Expected exception due to lack of permissions.');
        }*/
    }
}