/**
* Deposit Trigger Handler 
*/
public without sharing class DepositTriggerHandler {
    public void beforeInsert(List<Deposits__c> newDeposits){
        for(Deposits__c obj : newDeposits){
            
            // Check if Client_Deposit_Payment_Schedule_Profile__c is blank
            if (String.isBlank(obj.Client_Deposit_Payment_Schedule_Profile__c) && !String.isBlank(obj.Profile_Name__c)) {
                // Populate Client_Deposit_Payment_Schedule_Profile__c based on Profile_Name__c
                if (obj.Profile_Name__c == 'Internal Cash') {
                    obj.Client_Deposit_Payment_Schedule_Profile__c = 'Payment after Check In';
                } else if (obj.Profile_Name__c == 'TRP Cash') {
                    //obj.Client_Deposit_Payment_Schedule_Profile__c = '25%Down Payment + Balance at 270 Days'; --> inactive
                    obj.Client_Deposit_Payment_Schedule_Profile__c = '50% at 4 months and 50% at 10 months'; // --> new value
                } else if (obj.Profile_Name__c == 'TRP Credits') {
                    obj.Client_Deposit_Payment_Schedule_Profile__c = 'Full Payment at Deposit';
                } else if (obj.Profile_Name__c == 'Internal Credits') {
                    obj.Client_Deposit_Payment_Schedule_Profile__c = 'Full Payment at Deposit';
                }
            }
            
            if(obj.Lead__c == null && obj.Case__c != null && String.isBlank(obj.CaseType__c))
            {
                obj.CaseType__c = 'E&D';
            }
        }
    }
    //Before Update
    public void beforeUpdate(List<Deposits__c> newDeposits, Map<ID, Deposits__c> oldDepositMap) {
        for(Deposits__c obj : newDeposits){
            
            // Check if Client_Deposit_Payment_Schedule_Profile__c is blank
            if (String.isBlank(obj.Client_Deposit_Payment_Schedule_Profile__c) && !String.isBlank(obj.Profile_Name__c)) {
                // Populate Client_Deposit_Payment_Schedule_Profile__c based on Profile_Name__c
                if (obj.Profile_Name__c == 'Internal Cash') {
                    obj.Client_Deposit_Payment_Schedule_Profile__c = 'Payment after Check In';
                } else if (obj.Profile_Name__c == 'TRP Cash') {
                    //obj.Client_Deposit_Payment_Schedule_Profile__c = '25%Down Payment + Balance at 270 Days'; --> inactive
                    obj.Client_Deposit_Payment_Schedule_Profile__c = '50% at 4 months and 50% at 10 months'; // --> new value
                } else if (obj.Profile_Name__c == 'TRP Credits') {
                    obj.Client_Deposit_Payment_Schedule_Profile__c = 'Full Payment at Deposit';
                } else if (obj.Profile_Name__c == 'Internal Credits') {
                    obj.Client_Deposit_Payment_Schedule_Profile__c = 'Full Payment at Deposit';
                }
            }
            
            if(obj.Lead__c == null && obj.Case__c != null && String.isBlank(obj.CaseType__c))
            {
                obj.CaseType__c = 'E&D';
            }
            
            if(!(Label.System_Admin_Profile_Id.contains(userinfo.getProfileId()))){
                if((obj.Status__c == 'Approved' && oldDepositMap.get(obj.Id).Status__c == obj.Status__c) && (!(oldDepositMap.get(obj.Id).Status__c == 'Approved' && oldDepositMap.get(obj.Id).Status__c != obj.Status__c  && obj.Status__c != 'Cancel')) && (!(obj.Status__c == 'Approved' && obj.Member_Price__c != oldDepositMap.get(obj.Id).Member_Price__c))){
                    obj.addError('You can\'t edit deposit once it is approved');
                }
            }
        }
        updateStatusToNew(newDeposits);
    }
    //Before Delete
    public void beforeDelete(List<Deposits__c> oldDeposits) {
        for(Deposits__c obj : oldDeposits){
            if(obj.Status__c == 'Approved'){
                obj.addError('You can\'t delete deposit once it is approved');
            }
        }
    }
    //After Update
    public void afterUpdate(List<Deposits__c> newDeposits, Map<ID, Deposits__c> oldDepositMap) {
        System.debug('>>>entered calculateMFPAmount>>>');
        // New: For syncing Payment_Type__c changes
        Set<Id> depositIdsToSync = new Set<Id>();
        Map<Id, String> depositIdToNewPaymentType = new Map<Id, String>();
	    Map<Id, Deposits__c> depositsMap = new Map<Id, Deposits__c>();
        set<Id> setcaseIds = new set<Id>();
        set<Id> setDepositIds = new set<Id>();
        List<Deposit_Payment_Tracking__c> pays = new List<Deposit_Payment_Tracking__c>();
        for(Deposits__c obj : newDeposits){
            
            if(oldDepositMap.get(obj.Id).Inventory_Source__c != 'Pull from BE' &&  obj.Inventory_Source__c == 'Pull from BE'){
                ExchangeAndDepositAPI.getSourceList();
            }
            if(obj.Case__c != null && oldDepositMap.get(obj.Id).Status__c != obj.Status__c){
                setcaseIds.add(obj.Case__c);
                if(obj.Status__c == 'Approved' && obj.Lead__c == null)
                {
                    List<Deposit_Payment_Tracking__c> dpTracking = generatePaymentTrackingRecords(obj);
                    if(dpTracking != null && dpTracking.size()>0){
                        pays.addAll(dpTracking);
                    }
                }
            }
            if(obj.Case__c != null && oldDepositMap.get(obj.Id).Case__c != obj.Case__c){
                setcaseIds.add(obj.Case__c);
                setcaseIds.add(oldDepositMap.get(obj.Id).Case__c);
            }
            if (obj.Case__c != null && obj.Points__c != oldDepositMap.get(obj.Id).Points__c) {
                setcaseIds.add(obj.Case__c);
            }
            if (obj.Case__c != null && obj.MFP_Entitlement_Amount_Reservation__c != oldDepositMap.get(obj.Id).MFP_Entitlement_Amount_Reservation__c) {
                setcaseIds.add(obj.Case__c);
            }
            // New: Check if Payment_Type__c or Inventory_Cost__c changed and Total_Cost__c > 0 - to confirm that there's at least 1 payment
            Deposits__c oldDeposit = oldDepositMap.get(obj.Id);
            if ((obj.Payment_Type__c != oldDeposit.Payment_Type__c || obj.Inventory_Cost__c != oldDeposit.Inventory_Cost__c) && obj.Total_Cost__c > 0) {
                depositIdsToSync.add(obj.Id);
                depositsMap.put(obj.Id,obj);
            }
            if(obj.Status__c == 'Cancel' && oldDepositMap.get(obj.Id).Status__c != obj.Status__c){
                setDepositIds.add(obj.Id);
            }
            System.debug('>>>obj.Points__ct>>>'+obj.Points__c);
            System.debug('>>>obj.MFP_Entitlement_Amount_Reservation__c>>>'+obj.MFP_Entitlement_Amount_Reservation__c);
        }
        if(setcaseIds != null && setcaseIds.size() > 0){
            System.debug('>>>calling calculateMFPAmount>>>');
            calculateMFPAmount(setcaseIds);
        }        
        if(pays != null && pays.size() > 0){
            insert pays;
        }
        if(setDepositIds != null && setDepositIds.size() > 0){
            List<Deposit_Payment_Tracking__c> listDepositPaymentUpdate = new List<Deposit_Payment_Tracking__c>();
            List<Deposit_Payment_Tracking__c> listDepositPayment = [select id from Deposit_Payment_Tracking__c where Deposit__c IN : setDepositIds and Payment_Status__c != 'Paid'];
            if(listDepositPayment != null && listDepositPayment.size() > 0){
                for(Deposit_Payment_Tracking__c objdepositPayment : listDepositPayment){
                    objdepositPayment.Payment_Status__c = 'Canceled';
                    listDepositPaymentUpdate.add(objdepositPayment);
                }
            }
            if(listDepositPaymentUpdate != null && listDepositPaymentUpdate.size() > 0){
                update listDepositPaymentUpdate;
            }
        }
        // New: Recreate Deposit_Payment_Tracking__c if deposit Payment_Type__c or Inventory_Cost__c is changed
        // return an error message if there's a payment with Payment_Status__c = 'Paid'
        // requirements in review ^
        /*if (!depositIdsToSync.isEmpty()) {
            List<Deposit_Payment_Tracking__c> trackingRecordsToUpdate = new List<Deposit_Payment_Tracking__c>();
            List<Deposit_Payment_Tracking__c> toInsert = new List<Deposit_Payment_Tracking__c>();
            List<Deposit_Payment_Tracking__c> toDelete = new List<Deposit_Payment_Tracking__c>();
            Set<Id> failedDeposits = new Set<Id>();
            
            // Query existing Deposit_Payment_Tracking__c records for the deposits
            Map<Id, List<Deposit_Payment_Tracking__c>> existingTrackingsMap = new Map<Id, List<Deposit_Payment_Tracking__c>>();
            for (Deposit_Payment_Tracking__c dpt : [
                SELECT Id, Deposit__c, Payment_Status__c
                FROM Deposit_Payment_Tracking__c
                WHERE Deposit__c IN :depositIdsToSync
            ]) {
                if (!existingTrackingsMap.containsKey(dpt.Deposit__c)) {
                    existingTrackingsMap.put(dpt.Deposit__c, new List<Deposit_Payment_Tracking__c>());
                }
                existingTrackingsMap.get(dpt.Deposit__c).add(dpt);
            }
            
            // Process each deposit
            for (Id depositId : depositIdsToSync) {
                Deposits__c deposit = depositsMap.get(depositId);
                List<Deposit_Payment_Tracking__c> existing = existingTrackingsMap.get(depositId);
                
                Boolean hasPaid = false;
                if (existing != null) {
                    for (Deposit_Payment_Tracking__c dpt : existing) {
                        if (dpt.Payment_Status__c == 'Paid') {
                            hasPaid = true;
                            break;
                        }
                    }
                }
                
                if (hasPaid) {
                    failedDeposits.add(depositId);
                    continue; // skip this deposit
                }
                
                // Safe to delete and recreate
                if (existing != null) {
                    toDelete.addAll(existing);
                }
                
                List<Deposit_Payment_Tracking__c> newRecords = generatePaymentTrackingRecords(deposit);
                toInsert.addAll(newRecords);
            }
            
            // Delete and insert
            if (!toDelete.isEmpty()) delete toDelete;
            if (!toInsert.isEmpty()) insert toInsert;
            
            // Add error messages to deposits that failed
            for (Id failedId : failedDeposits) {
                depositsMap.get(failedId).addError(
                    'Cannot update payment tracking: at least one associated payment has already been marked as Paid.'
                );
            }
        }*/
    }
    //method used in the afterUpdateTrigger and DepositPaymentVerificationJob
    public static List<Deposit_Payment_Tracking__c> generatePaymentTrackingRecords(Deposits__c obj) {
        List<Deposit_Payment_Tracking__c> dpayments = new List<Deposit_Payment_Tracking__c>();
        
        if (obj == null) return dpayments;
        
        String profile = obj.Client_Deposit_Payment_Schedule_Profile__c;
        Decimal cost = obj.Inventory_Cost__c;
        
        if (profile == 'Payment after Check In') {
            dpayments.add(new Deposit_Payment_Tracking__c(
                Case__c = obj.Case__c,
                Payment_Type__c = obj.Payment_Type__c,
                Deposit__c = obj.Id,
                Payment_Status__c = 'Not Paid',
                Cost__c = cost,
                Due_Date__c = obj.Check_in_Date__c
            ));
        } else if (profile == '50% at 4 months and 50% at 10 months') {
            dpayments.add(new Deposit_Payment_Tracking__c(
                Case__c = obj.Case__c,
                Payment_Type__c = obj.Payment_Type__c,
                Deposit__c = obj.Id,
                Payment_Status__c = 'Not Paid',
                Cost__c = (cost * 0.5).setScale(2),
                Due_Date__c = System.today().addMonths(4)
            ));
            dpayments.add(new Deposit_Payment_Tracking__c(
                Case__c = obj.Case__c,
                Payment_Type__c = obj.Payment_Type__c,
                Deposit__c = obj.Id,
                Payment_Status__c = 'Not Paid',
                Cost__c = (cost * 0.5).setScale(2),
                Due_Date__c = System.today().addMonths(10)
            ));
        }
        else if (profile == 'Full Payment at Deposit') {
            dpayments.add(new Deposit_Payment_Tracking__c(
                Case__c = obj.Case__c,
                Payment_Type__c = obj.Payment_Type__c,
                Deposit__c = obj.Id,
                Payment_Status__c = 'Not Paid',
                Cost__c = cost,
                Due_Date__c = System.today()
            ));
        }
        /*else if (profile == '25%Down Payment + Balance at 270 Days') {
            dpayments.add(new Deposit_Payment_Tracking__c(
                Case__c = obj.Case__c,
                Payment_Type__c = obj.Payment_Type__c,
                Deposit__c = obj.Id,
                Payment_Status__c = 'Not Paid',
                Cost__c = (cost * 0.25).setScale(2),
                Due_Date__c = System.today()
            ));
            dpayments.add(new Deposit_Payment_Tracking__c(
                Case__c = obj.Case__c,
                Payment_Type__c = obj.Payment_Type__c,
                Deposit__c = obj.Id,
                Payment_Status__c = 'Not Paid',
                Cost__c = (cost * 0.75).setScale(2),
                Due_Date__c = System.today().addDays(270)
            ));
        }*/ 
        
        return dpayments;
    }
    
    //After Insert
    public void afterInsert(List<Deposits__c> newDeposits) {
        set<Id> setcaseIds = new set<Id>();
        List<Deposit_Payment_Tracking__c> pays = new List<Deposit_Payment_Tracking__c>();
        for(Deposits__c obj : newDeposits){            
            if(obj.Case__c != null){
                setcaseIds.add(obj.Case__c);
            }
        }
        if(setcaseIds != null && setcaseIds.size() > 0){
            calculateMFPAmount(setcaseIds);
        }
    }
    
    public static void updateStatusToNew(List<Deposits__c> newDeposits){
        for(Deposits__c record : newDeposits){
            // Only proceed if the status is "Draft"
            if (record.Status__c == 'Draft') {
                Boolean allRequiredFieldsPopulated = true;
                
                // Get the describe information for the object
                Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get('Deposits__c').getDescribe().fields.getMap();
                
                // Loop through all fields to check required fields
                for (String fieldName : fieldMap.keySet()) {
                    Schema.DescribeFieldResult fieldDescribe = fieldMap.get(fieldName).getDescribe();
                    
                    // Check if the field is required
                    if (!fieldDescribe.isNillable()) {
                        Object fieldValue = record.get(fieldName);
                        
                        // Check if required field is empty (null)
                        if (fieldValue == null) {
                            allRequiredFieldsPopulated = false;
                            break; // Stop checking once we find an empty required field
                        }
                        
                        // Additional check for currency fields (must be > 0)
                        if (fieldDescribe.getType() == Schema.DisplayType.Currency && ((Decimal) fieldValue) <= 0) {
                            allRequiredFieldsPopulated = false;
                            break; // Stop checking if any currency field is 0 or negative
                        }
                    }
                }
                
                // If all required fields are populated, update the status to "New"
                if (allRequiredFieldsPopulated) {
                    record.Status__c = 'New';
                }
            }
        }
    }
    public static void calculateMFPAmount(set<Id> caseIds){
        System.debug('>>>entered calculateMFPAmount>>>');
        map<Id, decimal> mapCaseIdToDepositsSum = new map<Id, decimal>();
        map<Id, decimal> mapCaseIdToLinkedCaseSum = new map<Id, decimal>();
        map<Id, decimal> mapCaseIdToDepositsPointsSum = new map<Id, decimal>();
        map<Id, decimal> mapCaseIdToLinkedCasePointsSum = new map<Id, decimal>();
        List<Case> caseList = new List<Case>();
        List<AggregateResult> depositsStats = [SELECT Case__c, SUM(MFP_Entitlement_Amount_Reservation__c) totalMFP, SUM(Points_Number__c) totalPoints FROM Deposits__c WHERE Case__c IN :caseIds and (Status__c = 'Approved' or Status__c = 'New' or Status__c = 'Pending') GROUP BY Case__c ORDER BY Case__c];
        if(depositsStats != null && depositsStats.size() > 0){
            for (AggregateResult result : depositsStats) {
                System.debug('Total: ' + result.get('totalMFP'));
                String caseId = (String)result.get('Case__c');
                Decimal mfpTotal = (decimal)result.get('totalMFP');
                Decimal pointsTotal = (decimal)result.get('totalPoints');
                if(mfpTotal != null && mfpTotal != 0){
                    mapCaseIdToDepositsSum.put(caseId,mfpTotal);
                }
                if(pointsTotal != null && pointsTotal != 0){
                    mapCaseIdToDepositsPointsSum.put(caseId,pointsTotal);
                }
            }
        }
        List<AggregateResult> linkedCaseStats = [SELECT Parent_Case__c, SUM(MFP_Amount__c) totalMFP, SUM(Points__c) totalPoints FROM Linked_Case__c WHERE Parent_Case__c IN :caseIds GROUP BY Parent_Case__c ORDER BY Parent_Case__c];
        if(linkedCaseStats != null && linkedCaseStats.size() > 0){
            for (AggregateResult result : linkedCaseStats) {
                System.debug('Total: ' + result.get('totalMFP'));
                String caseId = (String)result.get('Parent_Case__c');
                Decimal mfpTotal = (decimal)result.get('totalMFP');
                Decimal pointsTotal = (decimal)result.get('totalPoints');
                if(mfpTotal != null && mfpTotal != 0){
                    mapCaseIdToLinkedCaseSum.put(caseId,mfpTotal);
                }
                if(pointsTotal != null && pointsTotal != 0){
                    mapCaseIdToLinkedCasePointsSum.put(caseId,pointsTotal);
                }
            }
        }
        for(Case objcase : [select id, MFP_Entitlement_Amount__c,Balance_MFP_Amount__c,Total_MFP_Amount__c,Amount_of_Points__c,Balance_Points__c,Total_Points__c from Case where Id IN : caseIds]){
            Decimal sumOfLinkedCases = mapCaseIdToLinkedCaseSum.containsKey(objcase.Id)? mapCaseIdToLinkedCaseSum.get(objcase.Id): 0;
            Decimal sumOfDeposits = mapCaseIdToDepositsSum.containsKey(objcase.Id)? mapCaseIdToDepositsSum.get(objcase.Id): 0;
            Decimal MFPEntitlementAmount = objcase.MFP_Entitlement_Amount__c != null? objcase.MFP_Entitlement_Amount__c: 0; 
            Decimal sumOfPointsLinkedCases = mapCaseIdToLinkedCasePointsSum.containsKey(objcase.Id)? mapCaseIdToLinkedCasePointsSum.get(objcase.Id): 0;
            Decimal sumOfPointsDeposits = mapCaseIdToDepositsPointsSum.containsKey(objcase.Id)? mapCaseIdToDepositsPointsSum.get(objcase.Id): 0;
            Decimal pointsTotal = objcase.Amount_of_Points__c != null? objcase.Amount_of_Points__c: 0; 
            System.debug('>>>sumOfDeposits>>>'+sumOfDeposits);
            System.debug('>>>sumOfLinkedCases>>>'+sumOfLinkedCases);
            System.debug('>>>MFPEntitlementAmount>>>'+MFPEntitlementAmount);
            objcase.Balance_MFP_Amount__c = (MFPEntitlementAmount + sumOfLinkedCases) - sumOfDeposits;
            objcase.Total_MFP_Amount__c = (MFPEntitlementAmount + sumOfLinkedCases);
            System.debug('>>>pointsTotal>>>'+pointsTotal);
            System.debug('>>>sumOfPointsLinkedCases>>>'+sumOfPointsLinkedCases);
            System.debug('>>>sumOfPointsDeposits>>>'+sumOfPointsDeposits);
            objcase.Balance_Points__c = (pointsTotal + sumOfPointsLinkedCases) - sumOfPointsDeposits;
            objcase.Total_Points__c = (pointsTotal + sumOfPointsLinkedCases);
            caseList.add(objcase);
        }
        update caseList;
    }
}