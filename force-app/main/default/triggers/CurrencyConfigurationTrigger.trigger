trigger CurrencyConfigurationTrigger on Currency_Configuration__c (after  insert) {
    
    // Collect the IDs of the inserted records
    List<String> recordIds = new List<String>();
    for (Currency_Configuration__c record : Trigger.new) {
        recordIds.add(record.Id);
    }

    // Call the updatePicklist method of CurrencyPicklistUpdater
    if (!recordIds.isEmpty()) {
       // CurrencyPicklistUpdater.updatePicklist(recordIds);
    }
    
}