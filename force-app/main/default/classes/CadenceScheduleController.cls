/**
* @File Name : CadenceScheduleController.cls
* @Description :
* @Author :
* @Last Modified By :
* @Last Modified On : May 16, 2025
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | March 7, 2025 |   | Initial Version
**/

public with sharing class CadenceScheduleController {

    @AuraEnabled(cacheable=true)
    public static List<String> getObjects() {
        /*List<String> standardObjects = new List<String>();
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();

        for (String objectName : schemaMap.keySet()) {
            if (!schemaMap.get(objectName).getDescribe().isCustom()) {
                standardObjects.add(objectName);
            }
        }

        return standardObjects;*/
		List<String> allowedObjects = new List<String>{'Account', 'Contact', 'Case', 'Opportunity'};
        return allowedObjects;
    }

    @AuraEnabled(cacheable=true)
	public static List<Map<String, String>> getFields(String objectName) {
		List<Map<String, String>> fieldList = new List<Map<String, String>>();
		Schema.DescribeSObjectResult objDescribe = Schema.getGlobalDescribe().get(objectName).getDescribe();
		
		for (String fieldName : objDescribe.fields.getMap().keySet()) {
			Schema.DescribeFieldResult fieldDescribe = objDescribe.fields.getMap().get(fieldName).getDescribe();
			Map<String, String> fieldInfo = new Map<String, String>();
			fieldInfo.put('label', fieldDescribe.getLabel());
			fieldInfo.put('apiName', fieldDescribe.getName());
			fieldInfo.put('type', fieldDescribe.getType().name());
			fieldList.add(fieldInfo);
		}
		
		return fieldList;
	}



    @AuraEnabled(cacheable=true)
    public static List<String> getPicklistValues(String objectName, String fieldName) {
        List<String> picklistValues = new List<String>();
        
        Schema.DescribeSObjectResult objDescribe = Schema.getGlobalDescribe().get(objectName).getDescribe();
        Schema.DescribeFieldResult fieldDescribe = objDescribe.fields.getMap().get(fieldName).getDescribe();
        
        if (fieldDescribe.getType() == Schema.DisplayType.Picklist) {
            for (Schema.PicklistEntry entry : fieldDescribe.getPicklistValues()) {
                picklistValues.add(entry.getLabel());
            }
        }
        
        return picklistValues;
    }
    @AuraEnabled(cacheable=true)
    public static List<leadassist__MatchGroup__c> getMatchGroups(String objectName) {
        return [select id, Name from leadassist__MatchGroup__c where leadassist__Object_Type__c =: objectName and leadassist__Active__c = true];
    }

    @AuraEnabled(cacheable=true)
    public static List<ActionCadence> getCadences(String objectName) {
        return [select id, Name from ActionCadence where State = 'Active'];
    }

    @AuraEnabled
    public static void saveCadenceSchedule(String config) {
        System.debug('>>config>>>'+config);
        Map<String, Object> configData = (Map<String, Object>) JSON.deserializeUntyped(config);
        System.debug('configData'+configData);
        System.debug('configData'+(String) configData.get('objectName'));
        System.debug('configData'+configData.get('fields'));
        String cadenceName = (String) configData.get('cadenceId');
        //ActionCadence objCadence = [select id, Name from ActionCadence where Id =: cadenceId];
        //String objMatchGroup = [select id, Name from ActionCadence where Id =: cadenceId];
        Cadence_Schedule__c schedule = new Cadence_Schedule__c();
        schedule.Object_Name__c = (String) configData.get('objectName');
       // schedule.Fields__c = (String)configData.get('fields');
        schedule.Filter_Declarations__c = (String) configData.get('filters');
        schedule.Match_Group_Name__c = (String) configData.get('matchGroupId');
        schedule.Cadence_Name__c = cadenceName;
        schedule.Active__c = true;
        schedule.Name = cadenceName;
        schedule.Filter_Logic__c = (String) configData.get('filterLogic');
        insert schedule;
    }
}