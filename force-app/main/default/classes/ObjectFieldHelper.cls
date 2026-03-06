public with sharing class ObjectFieldHelper {
    
    // Method to retrieve all custom and standard objects visible to the user
   @AuraEnabled(cacheable=true)
public static List<Map<String, String>> getObjectList() {
    List<Map<String, String>> objectOptions = new List<Map<String, String>>();
    Map<String, Schema.SObjectType> globalDesc = Schema.getGlobalDescribe();

    for (String objectName : globalDesc.keySet()) {
        Schema.DescribeSObjectResult describeResult = globalDesc.get(objectName).getDescribe();
        if (describeResult.isAccessible() && !describeResult.isDeprecatedAndHidden()) {
            objectOptions.add(new Map<String, String>{
                'label' => describeResult.getLabel(),
                'value' => objectName
            });
        }
    }
    return objectOptions;
}

@AuraEnabled(cacheable=true)
public static List<Map<String, String>> getFieldList(String objectName) {
    List<Map<String, String>> fieldOptions = new List<Map<String, String>>();
    Schema.SObjectType objectType = Schema.getGlobalDescribe().get(objectName);

    if (objectType != null) {
        Map<String, Schema.SObjectField> fieldsMap = objectType.getDescribe().fields.getMap();
        for (String fieldName : fieldsMap.keySet()) {
            Schema.DescribeFieldResult fieldDesc = fieldsMap.get(fieldName).getDescribe();
            if (fieldDesc.isAccessible() && !fieldDesc.isDeprecatedAndHidden()) {
                fieldOptions.add(new Map<String, String>{
                    'label' => fieldDesc.getLabel(),
                    'value' => fieldName
                });
            }
        }
    }
    return fieldOptions;
}

}