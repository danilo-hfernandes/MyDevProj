public class AssignRemainingLeadsInCadence implements Database.Batchable<sObject>,schedulable{
    public Database.QueryLocator start(Database.BatchableContext bc) {
        User zappierUser = [SELECT Id,Username FROM User WHERE Email = 'zappier@nerdsoft.com.invalid'  LIMIT 1];//OR Email = 'zappier@nerdsoft.com.invalid'
        Id leadCFRecTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Carefree_Destinations').getRecordTypeId();
        //String dt15min = DateTime.now().addMinutes(-15).format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        String query = '';
        //queryV1 = 'SELECT Id,CreatedDate,Status,RecordType.DeveloperName,leadassist__Use_Round_Robin__c,LeadSource,CreatedBy.Email,Is_Duplicate__c,ActionCadenceAssigneeId,ActionCadenceId,ActionCadenceState,Owner.Name,Sales_Cadence_Assignment_Attempt__c,First_Action_Cadence_Id__c FROM Lead WHERE (First_Action_Cadence_Id__c = \'\' OR First_Action_Cadence_Id__c = null) AND (LeadSource = \'Vacation VIP - Web\' OR LeadSource = \'VI Referral\' OR ((RecordTypeId = \''+leadCFRecTypeId+'\' AND CreatedById = \''+zappierUser.Id+'\' AND Is_Duplicate__c=false) AND (LeadSource != \'TRM Contactable\' AND LeadSource != \'TRM Open\')) ) AND ActionCadenceId = NULL AND IsConverted = FALSE AND (Sales_Cadence_Assignment_Attempt__c = 0 OR Sales_Cadence_Assignment_Attempt__c = 1 OR Sales_Cadence_Assignment_Attempt__c = 2) AND leadassist__Use_Round_Robin__c = \'ASSIGNED\' AND CreatedDate = LAST_N_DAYS:3 ORDER BY CreatedDate ASC';
        //queryV2 = 'SELECT Id,CreatedDate,Status,RecordType.DeveloperName,leadassist__Use_Round_Robin__c,LeadSource,CreatedBy.Email,Is_Duplicate__c,ActionCadenceAssigneeId,ActionCadenceId,ActionCadenceState,Owner.Name,Sales_Cadence_Assignment_Attempt__c,First_Action_Cadence_Id__c FROM Lead WHERE (First_Action_Cadence_Id__c = \'\' OR First_Action_Cadence_Id__c = null) AND (LeadSource = \'Vacation VIP - Web\' OR LeadSource = \'Vacation VIP Retraveler\' OR LeadSource = \'VI Referral\' OR ((RecordTypeId = \''+leadCFRecTypeId+'\' AND CreatedById = \''+zappierUser.Id+'\' AND Is_Duplicate__c=false) AND (LeadSource != \'TRM Contactable\' AND LeadSource != \'TRM Open\')) ) AND ActionCadenceId = NULL AND IsConverted = FALSE AND (Sales_Cadence_Assignment_Attempt__c = 0 OR Sales_Cadence_Assignment_Attempt__c = 1 OR Sales_Cadence_Assignment_Attempt__c = 2) AND (leadassist__Use_Round_Robin__c = \'ASSIGNED\' OR ((LeadSource = \'CFD Google Mexico\' OR LeadSource = \'CFD MX Checkout\' OR (Lead_Form_External_Id__c != \'\' AND Lead_Form_External_Id__c != null)) AND leadassist__Use_Round_Robin__c = \'FALSE\' AND Created_How_Long_Ago__c > 15)) AND CreatedDate = LAST_N_DAYS:3 ORDER BY CreatedDate ASC';
        //queryV3 = 'SELECT Id,CreatedDate,Status,RecordType.DeveloperName,leadassist__Use_Round_Robin__c,LeadSource,CreatedBy.Email,Is_Duplicate__c,ActionCadenceAssigneeId,ActionCadenceId,ActionCadenceState,Owner.Name,Sales_Cadence_Assignment_Attempt__c,First_Action_Cadence_Id__c FROM Lead WHERE (First_Action_Cadence_Id__c = \'\' OR First_Action_Cadence_Id__c = null) AND (LeadSource = \'Vacation VIP - Web\' OR LeadSource = \'Vacation VIP Retraveler\' OR LeadSource = \'VVIP Westgate Las Vegas\' OR LeadSource = \'VVIP Westgate Orlando\' OR LeadSource = \'VIN Open Survey\' OR LeadSource = \'SMTN Open Survey\' OR LeadSource = \'VI Referral\' OR ((RecordTypeId = \''+leadCFRecTypeId+'\' AND CreatedById = \''+zappierUser.Id+'\' AND Is_Duplicate__c=false) AND (LeadSource != \'TRM Contactable\' AND LeadSource != \'TRM Open\')) ) AND ActionCadenceId = NULL AND IsConverted = FALSE AND (Sales_Cadence_Assignment_Attempt__c = 0 OR Sales_Cadence_Assignment_Attempt__c = 1 OR Sales_Cadence_Assignment_Attempt__c = 2) AND (leadassist__Use_Round_Robin__c = \'ASSIGNED\' OR ((LeadSource = \'CFD Google Mexico\' OR LeadSource = \'CFD MX Checkout\' OR (Lead_Form_External_Id__c != \'\' AND Lead_Form_External_Id__c != null AND LeadSource != \'Vacation VIP Retraveler\')) AND leadassist__Use_Round_Robin__c = \'FALSE\' AND Created_How_Long_Ago__c > 15)) AND CreatedDate = LAST_N_DAYS:3 ORDER BY CreatedDate ASC';
        query = 'SELECT Id,CreatedDate,Status,RecordType.DeveloperName,leadassist__Use_Round_Robin__c,LeadSource,CreatedBy.Email,Is_Duplicate__c,ActionCadenceAssigneeId,ActionCadenceId,ActionCadenceState,Owner.Name,Sales_Cadence_Assignment_Attempt__c,First_Action_Cadence_Id__c FROM Lead WHERE (First_Action_Cadence_Id__c = \'\' OR First_Action_Cadence_Id__c = null) AND (LeadSource = \'Timeshare Nation TCS\' OR LeadSource = \'CV - GBT\' OR LeadSource = \'GBT - FBLA - RMKT\' OR LeadSource = \'Vacation VIP - Web\' OR LeadSource = \'Vacation VIP Retraveler\' OR LeadSource = \'VVIP Westgate Las Vegas\' OR LeadSource = \'VVIP Westgate Orlando\' OR LeadSource = \'VIN Open Survey\' OR LeadSource = \'SMTN Rental Offer\'  OR LeadSource = \'SMTN Open Survey\' OR ((RecordTypeId = \''+leadCFRecTypeId+'\' AND CreatedById = \''+zappierUser.Id+'\' AND Is_Duplicate__c=false) AND (LeadSource != \'TRM Contactable\' AND LeadSource != \'TRM Open\')) ) AND ActionCadenceId = NULL AND IsConverted = FALSE AND (Sales_Cadence_Assignment_Attempt__c = 0 OR Sales_Cadence_Assignment_Attempt__c = 1 OR Sales_Cadence_Assignment_Attempt__c = 2) AND (leadassist__Use_Round_Robin__c = \'ASSIGNED\' OR ((LeadSource = \'CFD Google Mexico\' OR LeadSource = \'CFD MX Checkout\' OR (Lead_Form_External_Id__c != \'\' AND Lead_Form_External_Id__c != null AND LeadSource != \'Vacation VIP Retraveler\')) AND leadassist__Use_Round_Robin__c = \'FALSE\' AND Created_How_Long_Ago__c > 16)) AND CreatedDate = LAST_N_DAYS:3 ORDER BY CreatedDate ASC';
        //LeadSource = \'SMTN MX Voucher\' OR LeadSource = \'VI Referral\' OR
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<Lead> scope) {
        for(Lead ld : scope){
            if (ld.leadassist__Use_Round_Robin__c == 'ASSIGNED'){
                if(ld.Sales_Cadence_Assignment_Attempt__c == 0 || ld.Sales_Cadence_Assignment_Attempt__c == 1 || ld.Sales_Cadence_Assignment_Attempt__c == 2)
                {
                    ld.Sales_Cadence_Assignment_Attempt__c = ld.Sales_Cadence_Assignment_Attempt__c+1;
                }
            }
            if(ld.leadassist__Use_Round_Robin__c == 'FALSE' )//&& ld.LeadSource != 'Vacation VIP Retraveler'
            {                
                if(ld.Sales_Cadence_Assignment_Attempt__c == 0 || ld.Sales_Cadence_Assignment_Attempt__c == 1 || ld.Sales_Cadence_Assignment_Attempt__c == 2)
                {
                    ld.Sales_Cadence_Assignment_Attempt__c = ld.Sales_Cadence_Assignment_Attempt__c+1;
                    ld.leadassist__Use_Round_Robin__c = 'TRUE';
                }
            }
        }
        update scope;
    }
    
    public void finish(Database.BatchableContext bc) {
        //do something 
    }
    
    public void execute(SchedulableContext SC) {
        database.executebatch(new AssignRemainingLeadsInCadence(),20);
    }
}