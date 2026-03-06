public with sharing class Base64FieldHelper {

    public static void populateBase64Fields(List<SObject> records, String sObjectTypeName) {
        System.debug('=== Entering Base64FieldHelper.populateBase64Fields ===');
        System.debug('sObjectTypeName: ' + sObjectTypeName);
        System.debug('Records received: ' + records);
        
        for (SObject rec : records) {
        System.debug('Processing record: ' + rec);
            
            if (sObjectTypeName == 'Lead') {
                Lead l = (Lead) rec;

                if (String.isNotBlank(l.Email) && String.isBlank(l.Hashed_Email__c))
                    l.Hashed_Email__c = EncodingUtil.base64Encode(Blob.valueOf(l.Email.trim()));

                if (String.isNotBlank(l.Phone) && String.isBlank(l.Hashed_Phone__c))
                    l.Hashed_Phone__c = EncodingUtil.base64Encode(Blob.valueOf(l.Phone.trim()));

                if (String.isNotBlank(l.FirstName) && String.isBlank(l.Hashed_FirstName__c))
                    l.Hashed_FirstName__c = EncodingUtil.base64Encode(Blob.valueOf(l.FirstName.trim()));

                if (String.isNotBlank(l.LastName) && String.isBlank(l.Hashed_LastName__c))
                    l.Hashed_LastName__c = EncodingUtil.base64Encode(Blob.valueOf(l.LastName.trim()));

                   }

/*            if (sObjectTypeName == 'Account') {
                Account a = (Account) rec;

                if (String.isNotBlank(a.Phone) && String.isBlank(a.Hashed_Phone__c))
                    a.Hashed_Phone__c = EncodingUtil.base64Encode(Blob.valueOf(a.Phone.trim()));

                if (String.isNotBlank(a.Email__c) && String.isBlank(a.Hashed_Email__c))
                    a.Hashed_Email__c = EncodingUtil.base64Encode(Blob.valueOf(a.Email__c.trim()));                

                if (String.isNotBlank(a.First_Name__c) && String.isBlank(a.Hashed_First_Name__c))
                    a.Hashed_First_Name__c = EncodingUtil.base64Encode(Blob.valueOf(a.First_Name__c.trim()));
                
                if (String.isNotBlank(a.Last_Name__c) && String.isBlank(a.Hashed_Last_Name__c))
                    a.Hashed_Last_Name__c = EncodingUtil.base64Encode(Blob.valueOf(a.Last_Name__c.trim()));
*/
                
/*                // Optional: if you also have Email__c, FirstName__c, LastName__c custom fields
                if (Schema.sObjectType.Account.fields.getMap().containsKey('Email__c')) {
                    if (String.isNotBlank((String)a.get('Email__c')) && String.isBlank((String)a.get('Hashed_Email__c')))
                        a.put('Hashed_Email__c', EncodingUtil.base64Encode(Blob.valueOf(((String)a.get('Email__c')).trim())));
                }

                if (Schema.sObjectType.Account.fields.getMap().containsKey('FirstName__c')) {
                    if (String.isNotBlank((String)a.get('FirstName__c')) && String.isBlank((String)a.get('Hashed_FirstName__c')))
                        a.put('Hashed_FirstName__c', EncodingUtil.base64Encode(Blob.valueOf(((String)a.get('FirstName__c')).trim())));
                }

                if (Schema.sObjectType.Account.fields.getMap().containsKey('LastName__c')) {
                    if (String.isNotBlank((String)a.get('LastName__c')) && String.isBlank((String)a.get('Hashed_LastName__c')))
                        a.put('Hashed_LastName__c', EncodingUtil.base64Encode(Blob.valueOf(((String)a.get('LastName__c')).trim())));
                }

            }
*/
        }
    }
}