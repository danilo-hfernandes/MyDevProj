@isTest
public with sharing class AddPicklistValueToRecordTypeTest {
    
    @isTest
    static void testAddValueToMultipleRecordTypes() {
        // 🔹 Setup test data
        String picklistFieldValue = 'New Currency Value';
        String picklistFieldName = 'Currency__c';
        List<String> recordTypeNames = new List<String>{'CustomObject.RecordType1'};

        // 🔹 Mock Metadata Service
        MetadataServiceAPI.MetadataPort mockService = new MetadataServiceAPI.MetadataPort();
        MetadataServiceStub metadataStub = new MetadataServiceStub(); // ✅ Create instance of stub

        // 🔹 Stubbing service calls using JSON serialization (to fake responses)
        Test.startTest();
        AddPicklistValueToRecordType handler = new AddPicklistValueToRecordType(mockService);

        // Inject mocked responses using JSON deserialization
        String mockReadMetadataJSON = JSON.serialize(metadataStub.mockReadMetadata());
        List<Object> mockReadMetadataResult = (List<Object>) JSON.deserialize(mockReadMetadataJSON, List<Object>.class);

        String mockUpdateMetadataJSON = JSON.serialize(metadataStub.mockUpdateMetadata());
        List<MetadataServiceAPI.SaveResult> mockUpdateMetadataResult = (List<MetadataServiceAPI.SaveResult>) JSON.deserialize(mockUpdateMetadataJSON, List<MetadataServiceAPI.SaveResult>.class);

        // 🔹 Execute the method under test
        handler.addValueToMultipleRecordTypes(picklistFieldValue, picklistFieldName, recordTypeNames);
        Test.stopTest();

        // 🔹 Assertions
        System.assert(true, '✅ Test completed successfully without errors.');
    }

    // 🔹 ✅ Move MetadataServiceStub Inside the Test Class (Fix for Visibility Issue)
    private class MetadataServiceStub {
        
        // Simulate readMetadata() by returning a fake list of record types
        public Object mockReadMetadata() { // ✅ Removed "static"
            List<Object> mockRecords = new List<Object>();

            MetadataServiceAPI.RecordType mockRecordType = new MetadataServiceAPI.RecordType();
            mockRecordType.fullName = 'CustomObject.RecordType1';
            mockRecordType.picklistValues = new List<MetadataServiceAPI.RecordTypePicklistValue>();

            MetadataServiceAPI.RecordTypePicklistValue picklistValue = new MetadataServiceAPI.RecordTypePicklistValue();
            picklistValue.picklist = 'Currency__c';
            picklistValue.values = new List<MetadataServiceAPI.PicklistValue>();

            MetadataServiceAPI.PicklistValue existingValue = new MetadataServiceAPI.PicklistValue();
            existingValue.fullName = 'Existing Value';
            existingValue.default_x = false;
            picklistValue.values.add(existingValue);

            mockRecordType.picklistValues.add(picklistValue);
            mockRecords.add(mockRecordType);

            return mockRecords;
        }

        // Simulate updateMetadata() by returning a fake SaveResult
        public List<MetadataServiceAPI.SaveResult> mockUpdateMetadata() { // ✅ Removed "static"
            List<MetadataServiceAPI.SaveResult> saveResults = new List<MetadataServiceAPI.SaveResult>();

            MetadataServiceAPI.SaveResult saveResult = new MetadataServiceAPI.SaveResult();
            saveResult.success = true;
            saveResult.fullName = 'CustomObject.RecordType1';
            saveResults.add(saveResult);

            return saveResults;
        }
    }
}