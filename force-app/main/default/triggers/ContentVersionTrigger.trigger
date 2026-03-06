trigger ContentVersionTrigger on ContentVersion (before insert, before Update) {
    if(trigger.isBefore && (trigger.isInsert) || (trigger.isUpdate)){
        List<ContentVersion> newContents = new List<ContentVersion>();
        List<String> masterRecordIds = new List<String>();
        Map<Id,Account> accounts = new Map<Id,Account>();
        Map<String,Id> accountMasterRecordId = new Map<String,Id>();
        for(ContentVersion cv : trigger.new){
            if(trigger.isInsert && cv.String_Version_Data__c != '' && cv.String_Version_Data__c != null && cv.Master_Record_Id__c != null && cv.Master_Record_Id__c != ''){
                masterRecordIds.add(cv.Master_Record_Id__c);
                newContents.add(cv);
            }
            else if(cv.String_Version_Data__c != '' && cv.String_Version_Data__c != null && (cv.Master_Record_Id__c == null || cv.Master_Record_Id__c == ''))
            {
                //System.debug('cv after clear functions : '+cv.String_Version_Data__c.escapeHtml4().stripHtmlTags().replaceAll('<',':--').replaceAll('>','--:').replaceAll('&','and').replaceAll('©',''));
                cv.VersionData = Blob.valueOf(cv.String_Version_Data__c.escapeHtml4().stripHtmlTags().replaceAll('<',':--').replaceAll('>','--:').replaceAll('&','and').replaceAll('©',''));
            }
        }
        if(masterRecordIds.size() > 0 && masterRecordIds != null)
        {
            accounts = new Map<Id,Account>([SELECT Id,Master_Record_Id__c FROM Account WHERE Master_Record_Id__c IN : masterRecordIds]);
        }
        if(accounts.size()>0 && accounts != null){
            for(Id accId : accounts.keySet())
            {
                accountMasterRecordId.put(accounts.get(accId).Master_Record_Id__c,accId);
            }
        }
        if(newContents.size()>0 && newContents != null){
            for(ContentVersion cvRec : newContents){
                if(accountMasterRecordId.get(cvRec.Master_Record_Id__c) != null)
                {
                    //System.debug('cvRec after clear functions: '+cvRec.String_Version_Data__c.escapeHtml4().stripHtmlTags().replaceAll('<',':--').replaceAll('>','--:').replaceAll('&','and').replaceAll('©',''));
                    cvRec.VersionData = Blob.valueOf(cvRec.String_Version_Data__c.escapeHtml4().stripHtmlTags().replaceAll('<',':--').replaceAll('>','--:').replaceAll('&','and').replaceAll('©',''));
                    cvRec.FirstPublishLocationId = accountMasterRecordId.get(cvRec.Master_Record_Id__c);
                }
                else
                {
                    cvRec.addError('Master_Record_Id__c not found');
                }
            }
        }
    }
}