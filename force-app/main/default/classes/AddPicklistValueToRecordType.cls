public with sharing class AddPicklistValueToRecordType {
    private final MetadataServiceAPI.MetadataPort service;

    // Constructor injection for better testability
    public AddPicklistValueToRecordType(MetadataServiceAPI.MetadataPort serviceInstance) {
        this.service = serviceInstance;
    }

    public void addValueToMultipleRecordTypes(String picklistFieldValue, String picklistFieldName, List<String> recordTypeNames) {
        try {
            MetadataServiceAPI.IReadResult recordTypeResult = service.readMetadata('RecordType', recordTypeNames);

            if (recordTypeResult != null && recordTypeResult.getRecords() != null && recordTypeResult.getRecords().size() > 0) {
                List<MetadataServiceAPI.RecordType> recordTypesToUpdate = new List<MetadataServiceAPI.RecordType>();

                for (Object recordTypeObj : recordTypeResult.getRecords()) {
                    MetadataServiceAPI.RecordType recordType = (MetadataServiceAPI.RecordType) recordTypeObj;

                    if (recordType.picklistValues == null) {
                        recordType.picklistValues = new List<MetadataServiceAPI.RecordTypePicklistValue>();
                    }

                    boolean picklistExists = false;
                    for (MetadataServiceAPI.RecordTypePicklistValue picklistValue : recordType.picklistValues) {
                        if (picklistValue.picklist == picklistFieldName) {
                            picklistExists = true;

                            boolean isSelected = false;
                            if (picklistValue.values == null) {
                                picklistValue.values = new List<MetadataServiceAPI.PicklistValue>();
                            }

                            for (MetadataServiceAPI.PicklistValue value : picklistValue.values) {
                                if (value.fullName == picklistFieldValue) {
                                    isSelected = true;
                                    break;
                                }
                            }

                            if (!isSelected) {
                                MetadataServiceAPI.PicklistValue newPicklistValue = new MetadataServiceAPI.PicklistValue();
                                newPicklistValue.fullName = picklistFieldValue;
                                newPicklistValue.default_x = false;
                                picklistValue.values.add(newPicklistValue);
                            }
                            break;
                        }
                    }

                    if (!picklistExists) {
                        MetadataServiceAPI.RecordTypePicklistValue newPicklist = new MetadataServiceAPI.RecordTypePicklistValue();
                        newPicklist.picklist = picklistFieldName;
                        newPicklist.values = new List<MetadataServiceAPI.PicklistValue>();

                        MetadataServiceAPI.PicklistValue newPicklistValue = new MetadataServiceAPI.PicklistValue();
                        newPicklistValue.fullName = picklistFieldValue;
                        newPicklistValue.default_x = false;
                        newPicklist.values.add(newPicklistValue);

                        recordType.picklistValues.add(newPicklist);
                    }

                    recordTypesToUpdate.add(recordType);
                }

                List<MetadataServiceAPI.SaveResult> recordTypeUpdateResults = service.updateMetadata(recordTypesToUpdate);
                for (MetadataServiceAPI.SaveResult result : recordTypeUpdateResults) {
                    if (result.success) {
                        System.debug('✅ Record type updated successfully: ' + result.fullName);
                    } else {
                        System.debug('❌ Error updating record type: ' + result.errors[0].message);
                    }
                }
            } else {
                System.debug('⚠ No record types found or metadata retrieval failed.');
            }
        } catch (Exception ex) {
            System.debug('❌ Error: ' + ex.getMessage());
        }
    }
}