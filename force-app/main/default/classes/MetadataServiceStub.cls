@isTest
private class MetadataServiceStub {
    
    // Simulate readMetadata() by returning a fake list of record types
    public static Object mockReadMetadata() {
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
    public static List<MetadataServiceAPI.SaveResult> mockUpdateMetadata() {
        List<MetadataServiceAPI.SaveResult> saveResults = new List<MetadataServiceAPI.SaveResult>();

        MetadataServiceAPI.SaveResult saveResult = new MetadataServiceAPI.SaveResult();
        saveResult.success = true;
        saveResult.fullName = 'CustomObject.RecordType1';
        saveResults.add(saveResult);

        return saveResults;
    }
}