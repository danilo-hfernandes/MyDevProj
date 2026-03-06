global class UpdateCaseOwnerBatch implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Voucher_Sales').getRecordTypeId();
        Id recordTypeIdViReferral = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('New_Vacation_Innovations_Referral').getRecordTypeId();
        Id recordTypeIdMxTraveller = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('MX_Traveler').getRecordTypeId();
        Id recordTypeIdSharelife = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Sharelife').getRecordTypeId();
        String query = 'SELECT Id, OwnerId, Coast_Formula__c, RecordTypeId FROM Case WHERE (RecordTypeId =\''+String.escapeSingleQuotes(recordTypeId)+'\' AND (OwnerId =\''+String.escapeSingleQuotes(Label.EastCoastQueueId)+'\' OR OwnerId =\''+String.escapeSingleQuotes(Label.WestCoastQueueId)+'\') AND (Coast_Formula__c =\'East Coast\' OR Coast_Formula__c =\'West Coast\')) OR (RecordTypeId =\''+String.escapeSingleQuotes(recordTypeIdViReferral)+'\' AND OwnerId =\''+String.escapeSingleQuotes(Label.NewVacationInnovationsReferralQueueId)+'\') OR '+
            			'(RecordTypeId =\''+String.escapeSingleQuotes(recordTypeIdMxTraveller)+'\' AND (OwnerId =\''+String.escapeSingleQuotes(Label.MX_Traveler_East_English_2)+'\' OR OwnerId =\''+String.escapeSingleQuotes(Label.MX_Traveler_East_Spanish_2)+'\' OR OwnerId =\''+String.escapeSingleQuotes(Label.MX_Traveler_West_English_2)+'\' OR OwnerId =\''+String.escapeSingleQuotes(Label.MX_Traveler_West_Spanish_2)+'\') AND (Coast_Formula__c =\'East Coast\' OR Coast_Formula__c =\'West Coast\')) OR '+
            			'(RecordTypeId =\''+String.escapeSingleQuotes(recordTypeIdSharelife)+'\' AND (OwnerId =\''+String.escapeSingleQuotes(Label.Sharelife_East_Coast_QueueId)+'\' OR OwnerId =\''+String.escapeSingleQuotes(Label.Sharelife_West_Coast_QueueId)+'\') AND (Coast_Formula__c =\'East Coast\' OR Coast_Formula__c =\'West Coast\'))';
        system.debug('query--'+query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Case> caseList) {
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Voucher_Sales').getRecordTypeId();
        Id recordTypeIdViReferral = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('New_Vacation_Innovations_Referral').getRecordTypeId();
        Id recordTypeIdMxTraveller = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('MX_Traveler').getRecordTypeId();
        Id recordTypeIdSharelife = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Sharelife').getRecordTypeId();
        
        // process each batch of records default size is 200
        List<Case> caseListUpdate1 = new List<Case>();
        List<Case> caseListUpdate2 = new List<Case>();
        Map<Id,Id> caseIdWithOwnerIdMap = new Map <Id,Id>();
        
        for(Case caseRec : caseList) {
            caseIdWithOwnerIdMap.put(caseRec.Id, caseRec.OwnerId);
            caseRec.OwnerId = Label.SystemAdminUserId; //Sys Admin user id
            caseListUpdate1.add(caseRec);
        }
        update caseListUpdate1;
        
        for(Case caseRec : caseListUpdate1) {
            if(caseRec.RecordTypeId == recordTypeId){
                if(caseRec.Coast_Formula__c == 'East Coast'){
                    caseRec.OwnerId = Label.EastCoastQueueId; //East Coast Queue Id
                }else if(caseRec.Coast_Formula__c == 'West Coast'){
                    caseRec.OwnerId = Label.WestCoastQueueId; // West Coast Queue Id
                }
            }else if(caseRec.RecordTypeId == recordTypeIdViReferral){
                caseRec.OwnerId = Label.NewVacationInnovationsReferralQueueId;
            }else if(caseRec.RecordTypeId == recordTypeIdMxTraveller || caseRec.RecordTypeId == recordTypeIdSharelife){
                caseRec.OwnerId = caseIdWithOwnerIdMap.get(caseRec.Id);
            }
            
            caseListUpdate2.add(caseRec);
        }
        update caseListUpdate2;
    }   
    
    global void finish(Database.BatchableContext BC) {
        // execute any post-processing operations like sending email
    }
}