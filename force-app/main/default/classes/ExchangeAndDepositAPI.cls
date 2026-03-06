public class ExchangeAndDepositAPI {
    @future(callout=true)
    public static void getSourceList(){
        Boolean runningInASandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
        String endpoint = '';
        if(runningInASandbox){
            //endpoint = 'https://adminportalui-qa.azurewebsites.net/ExchangeDeposit/GetSourceList';
            endpoint = 'https://adminportalui-staging.azurewebsites.net/ExchangeDeposit/GetSourceList';
            System.debug('### Using SANDBOX endpoint: ' + endpoint);
        }
        else{
            endpoint = 'https://adminportalui.azurewebsites.net/ExchangeDeposit/GetSourceList';
            System.debug('### Using PRODUCTION endpoint: ' + endpoint);
        }
        Map<String, String> obj = new Map<String, String>();
        obj.put('Key', 'SalesforceExchangeDeposit');
        obj.put('Value', 'oGII@W}zOPGp<fn!2|bG86EXD12GFo)M');
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod('POST');
        request.setBody(JSON.Serialize(obj));
        request.setHeader('content-type', 'application/json');
        HttpResponse response = http.send(request);
        System.debug('>>>>>>'+response.getBody());
        List<Object> recordList = (LIST<Object>)JSON.deserializeUntyped(response.getBody());
        Set<String> setOfSource = new Set<String>();
        system.debug('>>>recordList>>>'+recordList);
        String picklistapiname = 'Deposits__c.Inventory_Source__c';
        MetadataServiceAPI.MetadataPort service = new MetadataServiceAPI.MetadataPort();   
        service.SessionHeader = new MetadataServiceAPI.SessionHeader_element();
        service.SessionHeader.sessionId = UserInfo.getSessionId();
        set<String> setOfInventorySource = new set<String>();
        List<MetadataServiceAPI.CustomValue> values = new List<MetadataServiceAPI.CustomValue>();
        MetadataServiceAPI.CustomField customField ;
        if(!Test.isRunningTest()){
            customField = (MetadataServiceAPI.CustomField) service.readMetadata('CustomField', new String[] {picklistapiname}).getRecords()[0];        
            // For each on: customField > Get valueset > Get valueSetDefinition > get values
            for(MetadataServiceAPI.CustomValue objCustomValue : customField.valueSet.valueSetDefinition.value){
                values.add(objCustomValue);
                setOfInventorySource.add(objCustomValue.fullName);
            }
        }
        for(object objrecord : recordList){
            Map<String,Object> sourceData = (Map<String,Object>)objrecord;
            String SourceName = String.valueOf(sourceData.get('companyName'));
            if(!setOfInventorySource.contains(SourceName) && !setOfSource.contains(SourceName)){
                setOfSource.add(sourceName);
                MetadataServiceAPI.CustomValue v1 = new MetadataServiceAPI.CustomValue();
                v1.fullName = SourceName;
                v1.description = SourceName;
                v1.Label= SourceName;
                v1.isActive = true;
                v1.default_x=false ;
                values.add(v1);
            }
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
            for (MetadataServiceAPI.SaveResult objResult : lstResults) {
                if (objResult.success) {
                    system.debug('Success');
                }
                else {                       
                    if(objResult.errors.size() > 0){
                        System.debug('eror : ' + objResult.errors[0].message);
                    }
                }
            }
        }
    }
}