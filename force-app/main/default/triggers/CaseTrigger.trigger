trigger CaseTrigger on Case (before update,after insert,before insert, after update) {
    Apex_Trigger_On_Off__c caseCS = Apex_Trigger_On_Off__c.getValues('Case Trigger');
    Id exchangeAndDepositRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Exchanges_and_Deposits').getRecordTypeId();
    Id advantageWeekRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Advantage_Week_Requests').getRecordTypeId();
    Id exchangeAndDepositQueueId = [SELECT Id,Name FROM Group WHERE Type = 'Queue' AND Name = 'Exchanges and Deposits'].Id;
    map<Id, Id> mapAccountIdVsOwnerId = new map<Id, Id>();
    set<Id> exchangeAndDepositAccIds = new set<Id>();
    
    if(trigger.isBefore){
        for(Case obj : trigger.new){
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
        }
    }
    
    if(checkRecursive.accountTrigger) {
        if(trigger.isInsert && trigger.isBefore){
            Set<String> membernumberSet = new Set<String>();
            for(Case cs : trigger.new){
                if((cs.Status == null || cs.Status == 'New') && cs.RecordTypeId == exchangeAndDepositRecordTypeId ){ 
                    cs.Status = 'E&D - New';
                }
                if(cs.RecordTypeId == exchangeAndDepositRecordTypeId && cs.MFP_Entitlement_Amount__c != null){
                    cs.Balance_MFP_Amount__c = cs.MFP_Entitlement_Amount__c;
                    cs.Total_MFP_Amount__c = cs.MFP_Entitlement_Amount__c;
                }
                if(cs.Member_Number__c != null){
                    membernumberSet.add(cs.Member_Number__c); 
                }
                //Exchanges_and_Deposits
                if(caseCS != null && caseCS.isEnable__c && cs.RecordTypeId == exchangeAndDepositRecordTypeId && cs.AccountId != null){
                    exchangeAndDepositAccIds.add(cs.AccountId);
                }
                
            }
            /* Exchanges_and_Deposits */
            if(caseCS != null && caseCS.isEnable__c){
                if(exchangeAndDepositAccIds != null && exchangeAndDepositAccIds.size() > 0){
                    List<Case> caseList = [SELECT Id, OwnerId, AccountId FROM Case where AccountId IN: exchangeAndDepositAccIds and RecordTypeId =: exchangeAndDepositRecordTypeId Order By CreatedDate ASC];//and ID NOT IN: mapCaseIdVsAccountId.KeySet()
                    System.debug('caseList >>> ' + caseList);
                    if(caseList != null && caseList.size() > 0) {
                        for(Case objcase : caseList){
                            if(!mapAccountIdVsOwnerId.containsKey(objcase.AccountId))
                                mapAccountIdVsOwnerId.put(objcase.AccountId, objcase.OwnerId);
                        }  
                    } 
                    List<Case> updateCaseList = new List<Case>();
                    system.debug('>>>>>mapAccountIdVsOwnerId>>>>>'+mapAccountIdVsOwnerId);
                    for(Case cs : Trigger.new) {
                        if(mapAccountIdVsOwnerId.containsKey(cs.AccountId)){
                            cs.OwnerId = mapAccountIdVsOwnerId.get(cs.AccountId); 
                            cs.Existing_Case__c = true;
                        }
                        else{
                            cs.Existing_Case__c = false;
                        }
                    }
                }
            }
            /* Exchanges_and_Deposits */
            if(membernumberSet != null){
                List<Account> accList = [select id,Member_Number__c from Account where Member_Number__c IN : membernumberSet];
                if(accList != null && accList.size() > 0){
                    Map<String,Id > memberNumberAccountIdMap = new Map<String,Id>();
                    for(Account acc : accList){
                        memberNumberAccountIdMap.put(acc.Member_Number__c,acc.Id);
                    }
                    if(memberNumberAccountIdMap != null){
                        for(Case c : trigger.new){
                            if(memberNumberAccountIdMap.containskey(c.Member_Number__c)){
                                system.debug('--inside'+memberNumberAccountIdMap.get(c.Member_Number__c));
                                c.AccountId = memberNumberAccountIdMap.get(c.Member_Number__c);
                                system.debug('--inside'+c.AccountId);
                                if((c.Status == null || c.Status == 'New') && c.RecordTypeId == exchangeAndDepositRecordTypeId){
                                    c.Status = 'E&D - New';
                                }
                            }
                        }
                    }
                }else{
                    List<Contact> contactList = [select id,Member_Number__c,AccountId from Contact where Member_Number__c IN : membernumberSet];
                    if(contactList != null && contactList.size() > 0){
                        Map<String,Contact > memberNumberContact = new Map<String,Contact>();
                        for(Contact con : contactList){
                            memberNumberContact.put(con.Member_Number__c,con);
                        }
                        if(memberNumberContact != null){
                            for(Case c : trigger.new){
                                if(memberNumberContact.containskey(c.Member_Number__c)){
                                    system.debug('--inside'+memberNumberContact.get(c.Member_Number__c));
                                    Contact con = memberNumberContact.get(c.Member_Number__c);
                                    system.debug('----c.ContactId'+con.Id);
                                    c.AccountId = con.AccountId;
                                    c.ContactId = con.Id;
                                    system.debug('----c.AccountId'+c.AccountId);
                                    system.debug('----c.ContactId'+c.ContactId);
                                }
                            }
                        }
                    }  
                }
            }
        }
        if(trigger.isUpdate && trigger.isAfter){
            system.debug('trigger.new => ' + trigger.new);
            system.debug('exchangeAndDepositQueueId => ' + exchangeAndDepositQueueId);
            exchangeAndDepositAccIds = new Set<Id>();
            mapAccountIdVsOwnerId = new map<Id, Id>();
            Set<Id> setCaseId = new Set<Id>();
            Set<Id> updateMFPCaseId = new Set<Id>();
            
            for (Case c1: Trigger.new) {
                if(caseCS != null && caseCS.isEnable__c &&  Trigger.oldMap.get(c1.Id).OwnerId == exchangeAndDepositQueueId  && c1.OwnerId != Trigger.oldMap.get(c1.Id).OwnerId && c1.RecordTypeId == exchangeAndDepositRecordTypeId && c1.AccountId != null){
                    exchangeAndDepositAccIds.add(c1.AccountId);
                    setCaseId.add(c1.Id);
                    if(!mapAccountIdVsOwnerId.containsKey(c1.AccountId))
                        mapAccountIdVsOwnerId.put(c1.AccountId, c1.OwnerId);
                }
                if((c1.MFP_Entitlement_Amount__c != Trigger.oldMap.get(c1.Id).MFP_Entitlement_Amount__c) || (c1.Amount_of_Points__c != Trigger.oldMap.get(c1.Id).Amount_of_Points__c)){
                    updateMFPCaseId.add(c1.Id);
                }
                
            }
            if(caseCS != null && caseCS.isEnable__c){
                if(exchangeAndDepositAccIds != null && exchangeAndDepositAccIds.size() > 0){
                    List<Case> caseList = [SELECT Id, OwnerId, AccountId FROM Case where AccountId IN: exchangeAndDepositAccIds and RecordTypeId =: exchangeAndDepositRecordTypeId and OwnerId =: exchangeAndDepositQueueId and Id NOT IN : setCaseId Order By CreatedDate ASC];//and ID NOT IN: mapCaseIdVsAccountId.KeySet()
                    System.debug('caseList >>> ' + caseList);
                    List<Case> UpdateCaseList = new List<Case>();
                    if(caseList != null && caseList.size() > 0) {
                        for(Case cs : caseList){
                            if(mapAccountIdVsOwnerId.containsKey(cs.AccountId)){
                                cs.OwnerId = mapAccountIdVsOwnerId.get(cs.AccountId); 
                                cs.Existing_Case__c = true;
                                UpdateCaseList.add(cs);
                            }
                        }
                        if(UpdateCaseList != null && UpdateCaseList.size() > 0){
                            update UpdateCaseList;
                        } 
                    } 
                }
                
            }
            if(updateMFPCaseId != null){
                DepositTriggerHandler.calculateMFPAmount(updateMFPCaseId);
            }
        }
        if(trigger.isUpdate && trigger.isBefore) {            
            Set<Id> AccountIds = new Set<Id>();
            set<Id> setTimeshareIds = new set<Id>();
            List<Case> caseListTimeshareUpdate = new List<Case>();
            List<Opportunity> oppListUpdate = new List<Opportunity>();
            for (Case c1: Trigger.new) {
                if(c1.Tee_Up_Agent__c != null) {
                    AccountIds.add(c1.AccountId);
                }
                if(c1.RecordTypeId == exchangeAndDepositRecordTypeId && c1.AccountId != null && c1.Ownership_Resort_Timeshare__c != null){
                    setTimeshareIds.add(c1.Ownership_Resort_Timeshare__c);
                }
                /*if(c1.RecordTypeId == exchangeAndDepositRecordTypeId && trigger.oldmap.get(c1.Id).OwnerId != c1.OwnerId){
Request reqInfo = Request.getCurrent();
Quiddity currentType = reqInfo.getQuiddity();
system.debug('>>currentType>>>'+currentType);
c1.OwnerId = trigger.oldmap.get(c1.Id).OwnerId;
}*/
                System.debug('This is the AccountIds ' + AccountIds);
            }
            if(AccountIds.size() > 0) {
                List<Opportunity> oppList = new List<Opportunity>();
                Date d = system.today().addDays(-15);
                Id oppRecordTypeId = [Select id from RecordType where sObjectType = 'Opportunity' and developerName ='Membership_Upgrade' ].id ;
                oppList = [Select Id, Closed_Lost_Date__c, StageName, Name, AccountId, (Select Id FROM OpportunityLineItems), IsClosed, RecordTypeId FROM Opportunity WHERE AccountId IN :AccountIds AND RecordTypeId = :oppRecordTypeId];
                
                System.debug('THis is the opp list ' + oppList);
                
                if(oppList != null && oppList.size() > 0) {
                    for(Case cs : Trigger.New) {
                        for(Opportunity o : oppList) {
                            if(!Test.isRunningTest()) {
                                if(cs.Accountid == o.AccountId && (o.StageName == 'Closed Refunded' || o.StageName == 'Pitched - Did Not Close/Lost') && o.Closed_Lost_Date__c > d && cs.Membership_Upgrade_Opportunity__c == 'Yes' && cs.Tee_Up_Agent__c != null) { 
                                    cs.addError('There is a Membership Upgrade Opportunity related to this account that is Closed Lost less than 15 days ago.  Navigate to following link:  https://holidaysystems.lightning.force.com/'+o.id);
                                }
                                else if(cs.AccountId == o.AccountId && o.IsClosed == false && cs.Membership_Upgrade_Opportunity__c == 'Yes' && cs.Tee_Up_Agent__c != null) {
                                    cs.AddError('There is already an open Membership Upgrade Opportunity for this Contact.  Navigate to following link:  https://holidaysystems.lightning.force.com/'+o.id);
                                    
                                }
                            }
                        }
                        
                    }
                }
                checkRecursive.accountTrigger = false;
            }
            if(setTimeshareIds != null && setTimeshareIds.size() > 0){
                Map<String, Decimal> mapTimeshareIdToTotalPrice = new Map<String, Decimal>();
                Map<String, Boolean> mapTimeshareIdToMFP = new Map<String, Boolean>();
                Map<String, Timeshare__c>  mapTimeshareIdToResortDetails = new Map<String, Timeshare__c>();
                List<OpportunityLineItem> opplineItem = [select id, TotalPrice,Timeshare__c from OpportunityLineItem where Product2.Name = 'Maintenance Fee Protection' and Timeshare__c IN: setTimeshareIds];
                if(opplineItem != null && opplineItem.size() > 0){
                    for(OpportunityLineItem oppline : opplineItem){
                        mapTimeshareIdToTotalPrice.put(oppline.Timeshare__c, oppline.TotalPrice);
                        mapTimeshareIdToMFP.put(oppline.Timeshare__c,true);
                        
                    }
                }
                List<Timeshare__c> resortList = [select id, Resort__c, Resort__r.HSI_Resort_Id__c,Amount_of_Points__c,MF_Transaction_Amount__c,MFProtection__c from Timeshare__c where Id IN: setTimeshareIds];
                for(Timeshare__c objTimeshare : resortList){
                    mapTimeshareIdToResortDetails.put(objTimeshare.Id, objTimeshare);
                    if(!mapTimeshareIdToMFP.containsKey(objTimeshare.Id)){
                        mapTimeshareIdToMFP.put(objTimeshare.Id,objTimeshare.MFProtection__c);
                    }
                }
                //List<Case> UpdateCaseList = new List<Case>();
                for (Case c1: Trigger.new) {
                    if(c1.RecordTypeId == exchangeAndDepositRecordTypeId && c1.AccountId != null && c1.Ownership_Resort_Timeshare__c != null){
                        if(c1.Exchange_Type__c != null && c1.Exchange_Type__c == 'Maintenance Fee Protection'){
                            c1.MF_Protection__c = mapTimeshareIdToMFP.get(c1.Ownership_Resort_Timeshare__c);
							
                            if(c1.Ownership_Resort_Timeshare__c != Trigger.oldMap.get(c1.Id).Ownership_Resort_Timeshare__c || c1.Exchange_Type__c != Trigger.oldMap.get(c1.Id).Exchange_Type__c ){ //TGR-468
                                c1.Amount_of_Points__c = mapTimeshareIdToResortDetails.get(c1.Ownership_Resort_Timeshare__c).Amount_of_Points__c;
                                c1.MFP_Entitlement_Amount__c = (mapTimeshareIdToTotalPrice != null && mapTimeshareIdToTotalPrice.containsKey(c1.Ownership_Resort_Timeshare__c) && mapTimeshareIdToTotalPrice.get(c1.Ownership_Resort_Timeshare__c) != 0.0)? mapTimeshareIdToTotalPrice.get(c1.Ownership_Resort_Timeshare__c) :  mapTimeshareIdToResortDetails.get(c1.Ownership_Resort_Timeshare__c).MF_Transaction_Amount__c;
                            } //TGR-468

                        }
                        else if(c1.Exchange_Type__c != null && c1.Exchange_Type__c == 'Credit Conversion'){
                            c1.MF_Protection__c = false;
                            if(c1.Ownership_Resort_Timeshare__c != Trigger.oldMap.get(c1.Id).Ownership_Resort_Timeshare__c || c1.Exchange_Type__c != Trigger.oldMap.get(c1.Id).Exchange_Type__c ){ //TGR-468
                            	c1.Amount_of_Points__c = mapTimeshareIdToResortDetails.get(c1.Ownership_Resort_Timeshare__c).Amount_of_Points__c; //468
                                c1.MFP_Entitlement_Amount__c = null;
                            } //TGR-468
                            c1.Total_MFP_Amount__c = null;       
                        }
                        c1.HSI_Id__c = mapTimeshareIdToResortDetails.get(c1.Ownership_Resort_Timeshare__c).Resort__r.HSI_Resort_Id__c;
                    }
                }
            }
        }
        
        if(trigger.isInsert && trigger.isAfter) {
            Set<Id> accIdset = New Set<id>();
            set<Id> caseIds = New Set<Id>();
            List<Contact> contactRecords = New List<Contact>();
            List<Case> updcase = New list<Case>();
            List<Case> caseListToCreateOpp = new List<Case>();
            Map<String, String> mapContactIDsToAssignCadence = new Map<String, String>();
            for(Case cs : Trigger.new){
                accIdset.add(cs.AccountId);
                caseIds.add(cs.id);
                if(cs.AccountId != null && cs.Form_Source__c == 'Halo Resort Request' && cs.RecordTypeId == advantageWeekRecordTypeId){//Advantage_Week_Requests
                    caseListToCreateOpp.add(cs);
                }
            }
            updcase = [Select id,Account_Name__c,ContactId,AccountId,Arrival_Date__c,Check_in_Date__c,Record_Type_Developer_Name__c,Member_Number__c,Member_Number_Formula__c from Case where Id IN:caseIds];
            if(accIdset.size() > 0 && accIdset != null){
                contactRecords = [Select id, AccountId, Name, Parent_Id_Ext_Db__c , Account.Name 
                                  from Contact where accountid IN :accIdset AND Parent_Id_Ext_Db__c  = null];
                
                if(contactRecords.size() > 0 && contactRecords != Null){
                    Map<String, String> mapContactIdToCaseId = new map<String, String>();
                    for(Case cs : updcase){
                        for(Contact ct : contactRecords){
                            if(cs.ContactId == null && cs.AccountId == ct.AccountId && cs.Account_Name__c == ct.Name){
                                cs.ContactId = ct.Id;
                            }
                        }
                        //TourGen-Arrival Cadences for Monster Reservations
                        if((cs.Member_Number__c == '142519-support@monsterrg.com' || cs.Member_Number_Formula__c == '142519-support@monsterrg.com') && cs.Record_Type_Developer_Name__c == 'Flight_Confirmation'){
                            //30 days or less
                            if(cs.Arrival_Date__c <=System.today()+30 || cs.Check_in_Date__c <=System.today()+30){
                                //mapContactIDsToAssignCadence.put(cs.ContactId, 'TourGen-Arrival Monster 30 Day');
                                mapContactIdToCaseId.put(cs.ContactId, cs.Id);
                            }
                            //31 days or more
                            else  if(cs.Arrival_Date__c > System.today()+30 || cs.Check_in_Date__c > System.today()+30){
                                //mapContactIDsToAssignCadence.put(cs.ContactId, 'TourGen-Arrival Monster');
                                mapContactIdToCaseId.put(cs.ContactId, cs.Id);
                            }
                        }
                        else if(cs.Record_Type_Developer_Name__c == 'Flight_Confirmation'){
                            //30 days or less
                            if(cs.Arrival_Date__c <=System.today()+30 || cs.Check_in_Date__c <=System.today()+30){
                                //mapContactIDsToAssignCadence.put(cs.ContactId, '30 days or less');
                                mapContactIdToCaseId.put(cs.ContactId, cs.Id);
                            }
                            //31 days or more
                            else  if(cs.Arrival_Date__c > System.today()+30 || cs.Check_in_Date__c > System.today()+30){
                                //mapContactIDsToAssignCadence.put(cs.ContactId, '31 days or more');
                                mapContactIdToCaseId.put(cs.ContactId, cs.Id);  
                            }
                        }
                        system.debug('>>>>mapContactIDsToAssignCadence>>>>>'+mapContactIDsToAssignCadence);
                    }
                    /*if(mapContactIDsToAssignCadence != null && mapContactIDsToAssignCadence.size() > 0){
List<Contact> contactsUpdateToAssignCadence = new List<Contact>();
List<Contact> conList = [select id,leadassist__Use_Round_Robin__c,Match_Group_Name__c from Contact where Id IN : mapContactIDsToAssignCadence.Keyset()];
for(contact con:conList){
con.leadassist__Use_Round_Robin__c='True';
con.Assign_to_Sales_Cadence__c = true;
con.Cadence_Flag__c = 1;
con.Match_Group_Name__c = mapContactIDsToAssignCadence.get(con.Id);
contactsUpdateToAssignCadence.add(con);
}
if(contactsUpdateToAssignCadence.size()>0 && contactsUpdateToAssignCadence.size()!=null){
update contactsUpdateToAssignCadence;
}
}*/
                    //Update Case Owner As Contact Owner For Flight Confirmation Cases
                    if(mapContactIdToCaseId != null && mapContactIdToCaseId.size() > 0){ 
                        map<Id, Id> mapCaseIdToOwnerId = new map<Id, Id>();
                        List<Case> caseOwnerUpdate = new List<Case>();
                        List<Contact> conList = [select id,OwnerId from Contact where Id IN : mapContactIdToCaseId.Keyset()];
                        for(contact con:conList){
                            mapCaseIdToOwnerId.put(mapContactIdToCaseId.get(con.Id),con.OwnerId);
                        }
                        for(Case cs : updcase){
                            cs.OwnerId = mapCaseIdToOwnerId.get(cs.Id);
                        }
                        if(updcase.size() > 0 && updcase != Null){
                            try{
                                update updcase;
                            }catch(Exception e){
                                system.debug('exception' + e);
                            }
                        }  
                    }
                }
            }
            if(caseListToCreateOpp != null && caseListToCreateOpp.size() > 0){
                CaseTriggerHandler.createTravelOpportunity(caseListToCreateOpp);
            } 
        }
    }
}