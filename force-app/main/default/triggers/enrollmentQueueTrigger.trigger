trigger enrollmentQueueTrigger on HSI_Enrollment_Queue__c (before Insert, after Insert, After Update) {
    
    if(trigger.isAfter && trigger.isInsert){
        set<id> enrolid = New set<Id>();

        for(HSI_Enrollment_Queue__c hsienrol : trigger.new){
            //modified 2022-04-05 adding VI Referral
            //modified 2022-04-05 adding Public Reservation Inquiry           
            //modified 2023-03-16 adding SF Leads and Internal Source          
            if(hsienrol.Record_Origin__c != 'Internal Source' && hsienrol.Record_Origin__c != 'Filetracker' && hsienrol.Record_Origin__c != 'Think Direct' && hsienrol.Record_Origin__c != 'Club Global Explorer VW'&& hsienrol.Record_Origin__c != 'Club Global Explorer VW - Trial' && hsienrol.Record_Origin__c != 'Club Venture - Guest' && hsienrol.Record_Origin__c != 'Club Venture - Emerald' && hsienrol.Record_Origin__c != 'Club Venture - Ruby' && hsienrol.Record_Origin__c != 'Club Venture - Sapphire' && hsienrol.Record_Origin__c != 'SMTN Survey' && hsienrol.Record_Origin__c != 'Carefree Destinations' && hsienrol.Record_Origin__c != 'SMTN Mexico' && hsienrol.Record_Origin__c != 'VI Referral Form' && hsienrol.Record_Origin__c != 'Public Reservation Inquiry'  && hsienrol.Record_Origin__c != 'Webform' && hsienrol.Record_Origin__c != 'SF Leads' && hsienrol.Record_Origin__c != 'Advantage Services Affiliate Marketing' && hsienrol.Record_Origin__c != 'Vidanta Converter' && hsienrol.Record_Origin__c != 'Advantage Getaway Voucher' && hsienrol.Record_Origin__c != 'LuxGive Guest' && hsienrol.Record_Origin__c != 'Inspira Resort Week' && hsienrol.Record_Origin__c != 'Raise Away Guest' && hsienrol.Record_Origin__c != 'Raise Away Voucher' && hsienrol.Record_Origin__c != 'Engaged Good Guest' &&  hsienrol.Record_Origin__c !='Reserve Collection' &&  hsienrol.Record_Origin__c !='One Agency Bulk Voucher Sheetn'){
                enrolid.add(hsienrol.id);
            }
           
        }
        if(enrolid.size() > 0 && enrolid != null ){
            EnrollmentQueueHelper.UpdateEnrollmentRecord(enrolid);
        }
        
    }
    
    if(trigger.isBefore && trigger.isInsert){
        EnrollmentQueueHelper.updatePhone(trigger.new);
    }

    // --- Added after update logic ---
    if (trigger.isAfter && trigger.isUpdate) {
        List<HSI_Enrollment_Queue__c> retryList = new List<HSI_Enrollment_Queue__c>();

    for (Integer i = 0; i < Trigger.new.size(); i++) {
        HSI_Enrollment_Queue__c oldRec = Trigger.old[i];
        HSI_Enrollment_Queue__c newRec = Trigger.new[i];

        // Only add if Failure_Count__c > 0 and it increased
        if (newRec.Successful_Processed__c == false
            && newRec.Failure_Count__c != null 
            && newRec.Failure_Count__c > 0
            && (oldRec.Failure_Count__c == null || newRec.Failure_Count__c > oldRec.Failure_Count__c)) {
            retryList.add(newRec);
            System.debug(LoggingLevel.ERROR, '🔄 Retry detected: Record Id = ' + newRec.Id 
                + ', Failure_Count__c = ' + newRec.Failure_Count__c);
        }
    }
        if (!retryList.isEmpty()) {
            System.debug('Enqueuing API Callout job for retryList size: ' + retryList.size());
            System.enqueueJob(new EnrollmentQueueAPICallout(retryList));
        }
    }
}