public with sharing class CurrencyPicklistUpdater {
    @Future (callout=true)
    
    
   // @InvocableMethod(label='Update Currency Picklist' description='Update the Opportunity Currency picklist field dynamically.')
    public static void updatePicklist(List<string> currenciesToUpdate){
         
        
        //insert picklist value from object 
        
        System.debug('currenciesToUpdate : ' + currenciesToUpdate);
        
        String picklistFieldName = 'Currency__c';    
        String queryCurrencyConfiguration = '';    
        String picklistapiname = 'Opportunity.Currency__c';   
        MetadataServiceAPI.MetadataPort service = new MetadataServiceAPI.MetadataPort();   
        service.SessionHeader = new MetadataServiceAPI.SessionHeader_element();
        service.SessionHeader.sessionId = UserInfo.getSessionId();
        //set<String> setOfInventorySource = new set<String>();
        List<MetadataServiceAPI.CustomValue> values = new List<MetadataServiceAPI.CustomValue>();
        MetadataServiceAPI.CustomField customField ;    
        if(!Test.isRunningTest()){
            customField = (MetadataServiceAPI.CustomField) service.readMetadata('CustomField', new String[] {picklistapiname}).getRecords()[0];        
            // For each on: customField > Get valueset > Get valueSetDefinition > get values
            for(MetadataServiceAPI.CustomValue objCustomValue : customField.valueSet.valueSetDefinition.value){
                values.add(objCustomValue); ///
                //setOfInventorySource.add(objCustomValue.fullName);
                System.debug('objCustomValue.fullName : ' + objCustomValue.fullName);
            }
        }
        // Fetch currency names from Currency_Configuration__c object
        queryCurrencyConfiguration = '';
        List<Currency_Configuration__c> currencies = [SELECT Name FROM Currency_Configuration__c where Id in:currenciesToUpdate]; //queryCurrencyConfiguration
        ///List<String> currencyNames = new List<String>();
        
        System.debug('currencies : ' + currencies);
        
        for (Currency_Configuration__c curr : currencies) {
            /// currencyNames.add(curr.Name);
            
            MetadataServiceAPI.CustomValue v1 = new MetadataServiceAPI.CustomValue();
            v1.fullName = curr.Name;
            v1.description = curr.Name;
            v1.Label= curr.Name;
            v1.isActive = true;
            v1.default_x=false ;
            values.add(v1);
            System.debug('curr.Name : ' + curr.Name);
            
        }
        
        //valueSetDefinition
        MetadataServiceAPI.ValueSetValuesDefinition vsd = new MetadataServiceAPI.ValueSetValuesDefinition();
        vsd.value = values;
        vsd.sorted = true;
        if(!Test.isRunningTest()){
            //valueSet
            MetadataServiceAPI.ValueSet vs = new MetadataServiceAPI.ValueSet();
            vs.valueSetDefinition = vsd;
            //Set valueSet
            customField.valueSet = vs;
            
            // Update Custom Field 
            List<MetadataServiceAPI.SaveResult> lstResults = service.updateMetadata( new MetadataServiceAPI.Metadata[] { customField });
            System.debug('customField : ' + customField);
            
            for (MetadataServiceAPI.SaveResult objResult : lstResults) {
                if (objResult.success) {
                    system.debug('Success');
                }
                else {                       
                    if(objResult.errors.size() > 0){
                        System.debug('error : ' + objResult.errors[0].message);
                    }
                }
            } 
        } 
        
        //add picklist value x record type relationship
        for (Currency_Configuration__c curr2 : currencies) {
            
            List<String> recordTypeNames = new List<String>{
                'Opportunity.Hawaii_Collection_Membership',
                'Opportunity.Membership_Upgrade',
                'Opportunity.SFX_Membership'
            };
   			AddPicklistValueToRecordType.addValueToMultipleRecordTypes(curr2.Name, picklistFieldName, recordTypeNames);

            
        }
        
        
        
    }
    
    
    
   
}