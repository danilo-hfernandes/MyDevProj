/**
 * @description       : 
 * @author            : Shivani Chauhan
 * @group             : 
 * @last modified on  : 12-04-2024
 * @last modified by  : Shivani Chauhan
**/
public with sharing class DepositsRecords {
    public static Boolean isCaseOwnerShipUpdate = true;
    @AuraEnabled(cacheable=true)
    public static List<Case> getCases(String parentCaseId) {
        system.debug('>>parentCaseId>>>'+parentCaseId);
        String recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Exchanges_and_Deposits').getRecordTypeId();
        Case objparentCase = [select id, AccountId from Case where Id =: parentCaseId];
        return [SELECT Id, CaseNumber, Subject,Account_Name__c,Ownership_Resort_Timeshare__c,Ownership_Resort_Timeshare__r.Name, Balance_MFP_Amount__c,Amount_of_Points__c FROM Case where AccountId =: objparentCase.AccountId and  Id !=:parentCaseId and CreatedDate >= LAST_N_DAYS:365 and RecordTypeId = :recordTypeId and MFP_Amount_Used__c = false and Balance_MFP_Amount__c > 0 and Balance_MFP_Amount__c != null];
    }
    
    @AuraEnabled(cacheable=true)
    public static Case getParentCaseDetails(String parentCaseId) {
        system.debug('Fetching Parent Case for Id: ' + parentCaseId);
        
        try {
            return [SELECT Id, AccountId, Profile_Name__c, Payment_Type__c, Client_Deposit_Payment_Schedule_Profile__c
                    FROM Case 
                    WHERE Id =: parentCaseId LIMIT 1];
        } catch (Exception e) {
            throw new AuraHandledException('Error fetching case: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static String createLinkedCase(String parentCaseId, String childCaseId, Decimal balanceAmount, String timeshareId, Integer points) {
        system.debug('>>>>>balanceAmount>>>>'+balanceAmount);
        Linked_Case__c linkedCase = new Linked_Case__c(
            Parent_Case__c = parentCaseId,
            Child_Case__c = childCaseId,
            MFP_Amount__c = balanceAmount,
            Timeshare__c = timeshareId,
			Points__c =  points
        );
        insert linkedCase;

        Case objChildCase = new Case();
        objChildCase.Id =  childCaseId;
        objChildCase.MFP_Amount_Used__c = true;
        update objChildCase;

        return 'Linked Case created';
    }
    @AuraEnabled(cacheable = true)
    public static List<Deposits__c> fetchInventoryData(Id caseRecordId){
        try {
            system.debug('>>caseRecordId>>'+caseRecordId);
            return [select id,Name,Check_in_Date__c,Request_Type__c,Lowest_Price_GPR__c,Member_Price__c,file_tracker_number__c,Deposit_Resort_Name__c,Points__c,Reservation_Number__c,Inventory_Cost__c,Status__c,Resort_Id__c,Resort_Id__r.Name,MFP_Entitlement_Amount_Reservation__c from Deposits__c where Case__c =: caseRecordId or Lead__c =: caseRecordId];//Linked_Case_1__c,Linked_Case_1__r.CaseNumber
            
        } catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled(cacheable=true)
    public static LeadDetails fetchAccountAndCaseDetails(String leadId){
        Lead objlead = [select id, ConvertedAccountId from Lead where Id =: leadId];
        String accountId = objlead.ConvertedAccountId;
        if(accountId != null){
            Case objcase = [select id from Case where AccountId =: accountId  Order by CreatedDate DESC];
            LeadDetails objwrapper = new LeadDetails();
            objwrapper.accountId = accountId;
            objwrapper.caseId = objcase.Id;
            System.debug('>>>objwrapper>>'+objwrapper);
            return objwrapper;
        }
        return null;
    }

    @AuraEnabled 
    public static Map<String, String> timeShareRecords(Id caseRecordId){
        try {

            Id accountId = [Select AccountId from Case where id =: caseRecordId].AccountId;
            system.debug('>>caseRecordId>>'+caseRecordId);
            List<Timeshare__c> timeShareRecords = [select id, Name from Timeshare__c where Timeshare_Owner__c =: accountId ];
             Map<String, String> timeShareRecordsList = new  Map<String, String>();
            for(Timeshare__c obj: timeShareRecords){
                timeShareRecordsList.put(obj.Id, obj.Name);
                system.debug('>>>>timeshare record name>>>'+obj.Name);
            }
           
            if(timeShareRecordsList.size() > 0){
                system.debug('timeshare whole list>>>'+timeShareRecordsList);
                return timeShareRecordsList;
            }
            return null;
        } catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static Boolean getMFPValue(Id timeshareId){
        List<OpportunityLineItem> opplineItem = [select id, TotalPrice from OpportunityLineItem where Product2.Name = 'Maintenance Fee Protection' and Timeshare__c =: timeshareId limit 1];
        if(opplineItem != null && opplineItem.size() > 0){
            return true;
        }
        else{
            List<Timeshare__c> resortList = [select id, MFProtection__c from Timeshare__c where Id =: timeshareId limit 1];
            return resortList[0].MFProtection__c;
        }
    }
   /* @AuraEnabled
    public static String getCaseData(Id caseRecordId){
        return [select id,Ownership_Resort_Timeshare__c from Case where Id =: caseRecordId].Ownership_Resort_Timeshare__c;
    }*/
    @AuraEnabled   
     public static void updateCaseData(List<Case> caseRecords, Id timeshareId){
        try {
            system.debug('caseRecords>>>'+caseRecords);
            system.debug('>>>>timeshareId>>>>'+timeshareId);
            List<OpportunityLineItem> opplineItem = [select id, TotalPrice from OpportunityLineItem where Product2.Name = 'Maintenance Fee Protection' and Timeshare__c =: timeshareId limit 1];
            List<Timeshare__c> resortList = [select id, Resort__c, Resort__r.HSI_Resort_Id__c,Amount_of_Points__c,MFProtection__c from Timeshare__c where Id =: timeshareId limit 1];
            if(caseRecords.size() > 0 && isCaseOwnerShipUpdate){
                system.debug('caseRecords>>>'+caseRecords);
                if(opplineItem != null && opplineItem.size() > 0){
                    Case objcase = new Case();
                    objcase = caseRecords[0];
                    if(caseRecords[0].Exchange_Type__c != null && caseRecords[0].Exchange_Type__c == 'Maintenance Fee Protection'){
                        objcase.MF_Protection__c = true;//resortList[0].MFProtection__c;
                        objcase.Amount_of_Points__c = resortList[0].Amount_of_Points__c;
                        objcase.MFP_Entitlement_Amount__c = opplineItem[0].TotalPrice;
                    }
                    objcase.HSI_Id__c = resortList[0].Resort__r.HSI_Resort_Id__c;
                }
                update caseRecords;
                isCaseOwnerShipUpdate = false;
            }
        } catch(Exception e) {
            throw new AuraHandledException(e.getMessage()+'>>>>Line Number>>'+e.getLineNumber());
        }
    }
    public class LeadDetails{
        @AuraEnabled
        public String accountId;
        @AuraEnabled
        public String caseId;
    }
}