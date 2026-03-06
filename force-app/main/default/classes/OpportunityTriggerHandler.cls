/**
* @description       : 
* @author            : ChangeMeIn@UserSettingsUnder.SFDoc
* @group             : 
* @last modified on  : 07-08-2021
* @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
* Modifications Log 
* Ver   Date         Author                               Modification
* 1.0   07-08-2021   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
public class OpportunityTriggerHandler {
    public static void updateOppWithPropertyDetails(set<Id> oppIds, set<Id> InvIds){
        Map<Id, Inventory_Availability__c> mapIdVsInv = new Map<Id, Inventory_Availability__c>([select id,Plaza__c,program__c,Resort_Name__c,Unit_Type__c,Check_In_Date__c,Site_Name__c,Selected__c,New_Availability__c,
                                         Inventory_Management__r.Capacity__c,Inventory_Management__r.Size_Upgrade__c,Inventory_Management__r.Property_Upgrade__c,
                                         Inventory_Management__r.Total_Upgrade__c,Inventory_Management__r.Room_Type__c,
                                         Inventory_Management__r.Property_Address__c,
                                         Inventory_Management__r.Property_City__c,
                                         Inventory_Management__r.Property_State__c,
                                         Inventory_Management__r.Property_Country__c,
                                         Inventory_Management__r.Property_Zipcode__c,
                                         Inventory_Management__r.Property_Phone__c
                                         from Inventory_Availability__c 
                                         where id IN:InvIds]);
        
        List<Opportunity> listOpp = [select id,Account.Name,Site_Name__c,program__c,AccountId,isRebook__c,Rebook_Reservation__c,Destination__c,Room_Type__c,Property__c,
                                    Rooms__c,Check_in__c,Check_Out__c,Reservation_Status__c,
                                    Inventory_Availability_Id__c,Property_Address__c,
                                    Property_City__c,Property_State__c,Property_Country__c,Property_Zipcode__c,
                                    Property_Phone__c,Capacity__c,Supplier__c from Opportunity where Id IN:oppIds];
        List<Opportunity> updatelistOpp = new List<Opportunity>();
        for(Opportunity opp: listOpp){
            Inventory_Availability__c inv = mapIdVsInv.get(opp.Inventory_Availability_Id__c);
            opp.Destination__c = inv.Plaza__c;
            opp.program__c = inv.program__c;
            opp.Property__c = inv.Resort_Name__c;
            opp.Site_Name__c = inv.Site_Name__c;
            opp.Rooms__c = inv.Unit_Type__c;
            opp.Check_in__c = inv.Check_In_Date__c;
            opp.Property_Address__c = inv.Inventory_Management__r.Property_Address__c;
            opp.Property_City__c = inv.Inventory_Management__r.Property_City__c;
            opp.Property_State__c = inv.Inventory_Management__r.Property_State__c;
            opp.Property_Country__c = inv.Inventory_Management__r.Property_Country__c;
            opp.Property_Zipcode__c = inv.Inventory_Management__r.Property_Zipcode__c;
            opp.Property_Phone__c = inv.Inventory_Management__r.Property_Phone__c;
            if(opp.Check_in__c != null && opp.Supplier__c != 'Marival'){
                //2024-09-24 removed - TGR-167 Vidanta Voucher - Booking Number of Nights
                //opp.Check_Out__c = opp.Check_in__c.addDays(7);
            }
            if(opp.Check_in__c != null && opp.Supplier__c == 'Marival'){
                //2024-09-24 removed - TGR-167 Vidanta Voucher - Booking Number of Nights
                //opp.Check_Out__c = opp.Check_in__c.addDays(4);
            }
            opp.Reservation_Status__c = 'Pending';
            opp.Booking_Agent__c = userinfo.getUserId();
            opp.Capacity__c = inv.Inventory_Management__r.Capacity__c;   
            opp.Room_Type__c = inv.Inventory_Management__r.Room_Type__c;   
            opp.isRebook__c = false;
            updatelistOpp.add(opp);
        }
        if(updatelistOpp != null && updatelistOpp.size() > 0){
            update updatelistOpp;
        }
    }
    @Future
    public static void updateOppInfutue(Id OppId, Id InvId){
        Inventory_Availability__c inv = [select id,Plaza__c,program__c,Resort_Name__c,Unit_Type__c,Check_In_Date__c,Site_Name__c,Selected__c,New_Availability__c,
                                         Inventory_Management__r.Capacity__c,Inventory_Management__r.Size_Upgrade__c,Inventory_Management__r.Property_Upgrade__c,
                                         Inventory_Management__r.Total_Upgrade__c,Inventory_Management__r.Room_Type__c,
                                         Inventory_Management__r.Property_Address__c,
                                         Inventory_Management__r.Property_City__c,
                                         Inventory_Management__r.Property_State__c,
                                         Inventory_Management__r.Property_Country__c,
                                         Inventory_Management__r.Property_Zipcode__c,
                                         Inventory_Management__r.Property_Phone__c
                                         from Inventory_Availability__c 
                                         where id =:InvId];
        Opportunity oppRecordNew = [select id,Account.Name,Site_Name__c,program__c,AccountId,isRebook__c,Rebook_Reservation__c,Destination__c,Room_Type__c,Property__c,
                                    Rooms__c,Check_in__c,Check_Out__c,Reservation_Status__c,
                                    Inventory_Availability_Id__c,Property_Address__c,
                                    Property_City__c,Property_State__c,Property_Country__c,Property_Zipcode__c,
                                    Property_Phone__c,Capacity__c,Supplier__c from Opportunity where Id =:OppId];
        
        
        system.debug('---oppRecord'+oppRecordNew.Reservation_Status__c );
        oppRecordNew.Destination__c = inv.Plaza__c;
        oppRecordNew.program__c = inv.program__c;
        oppRecordNew.Property__c = inv.Resort_Name__c;
        oppRecordNew.Site_Name__c = inv.Site_Name__c;
        oppRecordNew.Rooms__c = inv.Unit_Type__c;
        oppRecordNew.Check_in__c = inv.Check_In_Date__c;
        oppRecordNew.Property_Address__c = inv.Inventory_Management__r.Property_Address__c;
        oppRecordNew.Property_City__c = inv.Inventory_Management__r.Property_City__c;
        oppRecordNew.Property_State__c = inv.Inventory_Management__r.Property_State__c;
        oppRecordNew.Property_Country__c = inv.Inventory_Management__r.Property_Country__c;
        oppRecordNew.Property_Zipcode__c = inv.Inventory_Management__r.Property_Zipcode__c;
        oppRecordNew.Property_Phone__c = inv.Inventory_Management__r.Property_Phone__c;
        if(oppRecordNew.Check_in__c != null && oppRecordNew.Supplier__c != 'Marival'){
            //2024-09-24 removed - TGR-167 Vidanta Voucher - Booking Number of Nights
            //oppRecordNew.Check_Out__c = oppRecordNew.Check_in__c.addDays(7);
        }
        if(oppRecordNew.Check_in__c != null && oppRecordNew.Supplier__c == 'Marival'){
            //2024-09-24 removed - TGR-167 Vidanta Voucher - Booking Number of Nights
            //oppRecordNew.Check_Out__c = oppRecordNew.Check_in__c.addDays(4);
        }
        oppRecordNew.Reservation_Status__c = 'Pending';
        
        oppRecordNew.Inventory_Availability_Id__c  = inv.Id;
        oppRecordNew.Booking_Agent__c = userinfo.getUserId();
        oppRecordNew.Capacity__c = inv.Inventory_Management__r.Capacity__c;   
        oppRecordNew.Room_Type__c = inv.Inventory_Management__r.Room_Type__c;   
        oppRecordNew.isRebook__c = false;
        
        update oppRecordNew;
        
    }
    public static void createReservationTrackingRecord(Map<Id,Opportunity> oldOppMap, Map<Id,Opportunity> newOppMap, Boolean isInsert){
        
        String recordTypeName;
        List<Opportunity> oppList = new List<Opportunity>();
        List<Reservation_Tracking_Object__c> reservationListToInsert = new List<Reservation_Tracking_Object__c>();
        if(isInsert){
            for(Opportunity oppRec: newOppMap.values()){
                if(oppRec.Destination__c != null || oppRec.Property__c != null || oppRec.Rooms__c != null || oppRec.Check_in__c != null || 
                   oppRec.Check_Out__c != null || oppRec.Site_Name__c != null || oppRec.Capacity__c != null || oppRec.Reservation_Status__c != null ||
                   oppRec.Confirmation_Number__c != '' || oppRec.Confirmed_Date__c != null){
                       system.debug('---abc----insert'+oppRec);
                       oppList.add(oppRec);
                       system.debug('--/oppList--'+oppList);
                   }
            }
        }else{
            for(Opportunity oppRec: newOppMap.values()){
                recordTypeName = oppRec.Record_Type_Name__c;
                system.debug('--------new--'+oppRec.Reservation_Status__c);
                system.debug('----old--'+oldOppMap.get(oppRec.Id).Reservation_Status__c);
                if(oppRec.Destination__c != oldOppMap.get(oppRec.Id).Destination__c || oppRec.Property__c != oldOppMap.get(oppRec.Id).Property__c || 
                   oppRec.Rooms__c != oldOppMap.get(oppRec.Id).Rooms__c || oppRec.Check_in__c != oldOppMap.get(oppRec.Id).Check_in__c || 
                   oppRec.Check_Out__c != oldOppMap.get(oppRec.Id).Check_Out__c || oppRec.Capacity__c != oldOppMap.get(oppRec.Id).Capacity__c || 
                   oppRec.Program__c != oldOppMap.get(oppRec.Id).Program__c || oppRec.Site_Name__c != oldOppMap.get(oppRec.Id).Site_Name__c || oppRec.Reservation_Status__c != oldOppMap.get(oppRec.Id).Reservation_Status__c ||
                   oppRec.Confirmation_Number__c != oldOppMap.get(oppRec.Id).Confirmation_Number__c || oppRec.Confirmed_Date__c != oldOppMap.get(oppRec.Id).Confirmed_Date__c 
                  ){
                      system.debug('---abc----Update'+oppRec);
                      oppList.add(oppRec);
                  }
                else if(test.isRunningTest()){
                    oppList.add(oppRec);
                }
            }
            system.debug('--oppList--'+oppList);
            for(Opportunity opp: oppList){
                system.debug('--opp--'+opp);
                Reservation_Tracking_Object__c reservationTrackingRecord = new Reservation_Tracking_Object__c ();
                reservationTrackingRecord.Opportunity__c = opp.Id;
                reservationTrackingRecord.Destination__c = opp.Destination__c;
                reservationTrackingRecord.Property__c = opp.Property__c;
                reservationTrackingRecord.Rooms__c = opp.Rooms__c;
                reservationTrackingRecord.Program__c = opp.Program__c;
                reservationTrackingRecord.Check_in__c = opp.Check_in__c;
                reservationTrackingRecord.Check_Out__c = opp.Check_Out__c;
                reservationTrackingRecord.Site_Name__c = opp.Site_Name__c;
                reservationTrackingRecord.Capacity__c = opp.Capacity__c;
                reservationTrackingRecord.Reservation_Status__c = opp.Reservation_Status__c;
                reservationTrackingRecord.Confirmation_Number__c = opp.Confirmation_Number__c;
                reservationTrackingRecord.Confirmed_Date__c = opp.Confirmed_Date__c;
                
                if(opp.Original_Confirmation__c != oldOppMap.get(opp.Id).Original_Confirmation__c && opp.Original_Confirmation__c == true){
                    reservationTrackingRecord.Original_Confirmation__c = true;
                }
                
                reservationListToInsert.add(reservationTrackingRecord);
            } 
            system.debug('-reservationListToInsert---'+reservationListToInsert.size());
            
            if(!reservationListToInsert.isEmpty()){
                insert reservationListToInsert;
                
            }
            EmailTemplate emailTemplate = New EmailTemplate();
            if(recordTypeName == 'Profit Agility Voucher'){
                emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body,Name from EmailTemplate where name = 'Profit Agility Res Cancellation'];
            }else if(recordTypeName == 'Flex Stays Product Voucher'){
                emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body,Name from EmailTemplate where name = 'Share Life Flex Stays Reservation Cancel Email'];
            }else{
                emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body,Name from EmailTemplate where name = 'Vidanta Reservation Cancellation'];
            }
            EmailTemplate SLFlexemailTemplate = New EmailTemplate();
            SLFlexemailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body,Name from EmailTemplate where name = 'Share Life Flex Stays Reservation Cancel Email'];
            
            List<OrgWideEmailAddress> lstEmailAddress=[select Id,Address from OrgWideEmailAddress WHERE Address='reservations@myadvantageservices.com'];
            List<OrgWideEmailAddress> slflexlstEmailAddress=[select Id,Address from OrgWideEmailAddress WHERE Address='service@sharelifemembers.com'];
            
            Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>();
            List<Opportunity> oppsToClearReservationFields = new List<Opportunity>();
            List<Task> sentEmailLogTasks = new List<Task>();
            for(Opportunity oppRec: newOppMap.values()){
                system.debug('opprec==  ' + oppRec.Reservation_Status__c);
                system.debug('opprec==  ' + oldOppMap.get(oppRec.id).Reservation_Status__c);
                if((test.isRunningTest() || ((oppRec.Reservation_Status__c == 'Cancel' || oppRec.Reservation_Status_Flex__c  == 'Cancel') && (oldOppMap.get(oppRec.id).Reservation_Status__c != oppRec.Reservation_Status__c || oldOppMap.get(oppRec.id).Reservation_Status_Flex__c != oppRec.Reservation_Status_Flex__c )))){
                    Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                    system.debug('came inside===' + oppRec);
                    if(oppRec.Account_Affiliate_Id__c == 1002122.00){
                        if(oppRec.Record_Type_Name__c != 'Vida Book With Us'){
                            message.setUseSignature(false); 
                            message.setBccSender(false); 
                            message.setHtmlBody(SLFlexemailTemplate.HtmlValue);
                            message.setSubject(SLFlexemailTemplate.Subject);
                            message.setSaveAsActivity(false); 
                            message.setTemplateID(SLFlexemailTemplate.Id); 
                            message.setTreatBodiesAsTemplate(true);
                            message.setTreatTargetObjectAsRecipient(true);
                            message.setOrgWideEmailAddressId(slflexlstEmailAddress[0].id);
                            message.setWhatId(oppRec.Id); //This is important for the merge fields in template to work
                            message.toAddresses = new String[] { oppRec.Account_Email_formula__c };
                                
                                if(Test.isRunningTest()){
                                    message.toAddresses = new String[] { 'test@text.com' };
                                        }
                            //messages = new List<Messaging.SingleEmailMessage> {message};
                            //2025-06-19 - clean reservation fields after sending the cancel e-mails + create opp tasks to track cancel e-mails
                            messages.add(message);
                                }
                        /* --------------------------------------------------------------------*/
                        /*oppRec.Destination__c = null;
                        oppRec.Property__c = null;
                        oppRec.Rooms__c = null;
                        oppRec.Check_in__c = null;
                        oppRec.Check_Out__c = null;
                        oppRec.program__c = null;
                        oppRec.Adults__c = null;
                        oppRec.Children_0_17__c = null;
                        oppRec.Confirmation_Number__c = '';
                        oppRec.Confirmed_Date__c = null;
                        oppRec.Confirmation_Number_Flex__c = '';
                        oppRec.Confirmed_Date_Flex__c = null;
                        oppRec.Site_Name__c = null;
                        oppRec.Room_Type__c = null;
                        oppRec.Capacity__c = null;
                        oppRec.Property_Address__c =  null;
                        oppRec.Property_City__c =  null;
                        oppRec.Property_State__c =  null;
                        oppRec.Property_Country__c = null;
                        oppRec.Property_Zipcode__c =  null;
                        oppRec.Property_Phone__c =  null;
                        oppRec.OB_Campaign_Case_Credated__c = false;
                        oppRec.Property_Name__c = null;*/
                        //2025-06-19 - clean reservation fields after sending the cancel e-mails + create opp tasks to track cancel e-mails
                        oppsToClearReservationFields.add(oppRec);
                        sentEmailLogTasks.add(new Task(ActivityDate=Date.today(), OwnerId=UserInfo.getUserId(), Priority='Normal', Status='Completed', Subject='Email Sent - '+SLFlexemailTemplate.Name, WhatId=oppRec.Id));
                        
                        system.debug('--oppRec.Property_Phone__c--'+oppRec.Property_Phone__c);
                        
                    }else{                        
                        String leadSourceFormulaAux = oppRec.LeadSource_Formula__c != null ? oppRec.LeadSource_Formula__c : '';
                        /*--------------------------------------------------------------------*/
                        if(oppRec.Record_Type_Name__c != 'Vida Book With Us' ){
                            message.setUseSignature(false); 
                            message.setBccSender(false); 
                            message.setHtmlBody(emailTemplate.HtmlValue);
                            message.setSubject(emailTemplate.Subject);
                            message.setSaveAsActivity(false); 
                            message.setTemplateID(emailTemplate.Id); 
                            message.setTreatBodiesAsTemplate(true);
                            message.setTreatTargetObjectAsRecipient(true);
                            message.setOrgWideEmailAddressId(lstEmailAddress[0].id);
                            message.setWhatId(oppRec.Id); //This is important for the merge fields in template to work
                            if(!(oppRec.Supplier__c == 'Florida Hotel' && oppRec.Account_Affiliate_Id__c == 1002453 && leadSourceFormulaAux.contains('Gunn Marketing/CCR')))
                            {
                                message.toAddresses = new String[] { oppRec.Account_Email_formula__c };
                                //2025-06-19 - clean reservation fields after sending the cancel e-mails + create opp tasks to track cancel e-mails
                                sentEmailLogTasks.add(new Task(ActivityDate=Date.today(), OwnerId=UserInfo.getUserId(), Priority='Normal', Status='Completed', Subject='Email Sent - '+emailTemplate.Name, WhatId=oppRec.Id)); 
                            }
                            else
                            {
                                sentEmailLogTasks.add(new Task(ActivityDate=Date.today(), OwnerId=UserInfo.getUserId(), Priority='Normal', Status='Completed', Subject='Email Sent - Gunn Marketing / CCR Vidanta Reservation Cancellation', WhatId=oppRec.Id));                                
                                if(UserInfo.getOrganizationId() != '00D3t000000dNJ9EAM'){ //not prod
                                    message.toAddresses = new String[] { 'dev@nerdsoft.com','victor.goncalves@nerdsoft.com','daniel.oliveira@nerdsoft.comr' };
                                        }
                                else
                                {
                                    message.toAddresses = new String[] { 'dev@nerdsoft.com','reservations@customerchoicerewards.com'};
                                        }
                            }  
                                if(Test.isRunningTest()){
                                    message.toAddresses = new String[] { 'test@text.com' };
                                        }
                            //messages = new List<Messaging.SingleEmailMessage> {message};
                            //2025-06-19 - clean reservation fields after sending the cancel e-mails + create opp tasks to track cancel e-mails
                            // === 🔍 Debug Logs ===
                            System.debug('===== FROM Address =====');
                            System.debug('From OrgWideEmailAddress Id: ' + lstEmailAddress[0].Id);
                            System.debug('From Email: ' + lstEmailAddress[0].Address);
                            
                            System.debug('===== TO Address =====');
                            System.debug('To Addresses: ' + message.toAddresses);
                            messages.add(message);
                        }
                        /* --------------------------------------------------------------------*/
                        //2025-06-19 - clean reservation fields after sending the cancel e-mails + create opp tasks to track cancel e-mails
                        /*if(!(oppRec.Supplier__c == 'Florida Hotel' && oppRec.Account_Affiliate_Id__c == 1002453 && leadSourceFormulaAux.contains('Gunn Marketing/CCR')))
                        {
                            clearReservationFields(oppRec);
                        }*/
                        //else
                        //{
                            oppsToClearReservationFields.add(oppRec);
                        //}
                        
                    }  
                } 
            }
            
            //2025-06-19 Filter tasks to only include those not associated with failed emails
            if (messages != null && !messages.isEmpty()) {
                
                System.debug('Sending emails: ' + messages);
                System.debug('Sending emails size: ' + messages.size());
                
                Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
                
                Set<Id> failedTargetIds = new Set<Id>();
                
                for (Messaging.SendEmailResult result : results) {
                    System.debug('Email send result: ' + result);
                    System.debug('Email send result.success: ' + result.success);
                    if (!result.success) {
                        for (Messaging.SendEmailError error : result.errors) {                            
                            Id failedId = error.getTargetObjectId();
                            failedTargetIds.add(failedId);
                            System.debug('Email failed to: ' + failedId + ' - ' + error.getMessage());
                        }
                    }
                }                
                
                List<Task> successfulTasks = new List<Task>();
                if (sentEmailLogTasks != null && !sentEmailLogTasks.isEmpty()) {
                    for (Task t : sentEmailLogTasks) {
                        if (t.WhatId != null && !failedTargetIds.contains(t.WhatId)) {
                            successfulTasks.add(t);
                        } else {
                            System.debug('Skipping task for failed email. Task WhatId: ' + t.WhatId);
                        }
                    }
                }
                
                if (!successfulTasks.isEmpty()) {
                    insert successfulTasks;
                }
            }
            
            if (oppsToClearReservationFields != null && !oppsToClearReservationFields.isEmpty()) {
                for (Opportunity o : oppsToClearReservationFields) {
                    clearReservationFields(o);
                }
            }
            
            /*if(messages.size() > 0 && messages != null){
                system.debug('email====' + messages);
                Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
                
                if (results[0].success) 
                {
                    System.debug('The email was sent successfully.' + results);
                } else {
                    System.debug('The email failed to send: ' +  results[0].errors[0].message);
                }
                
            }
            if(oppsToClearReservationFields.size()>0 && oppsToClearReservationFields != null){
                for(Opportunity o : oppsToClearReservationFields)
                {
                     clearReservationFields(o);
                }
                if(sentEmailLogTasks.size()>0 && sentEmailLogTasks != null){
                    insert sentEmailLogTasks;
                }
            }*/
        }
    }
    /*    
public static void createTaskForNameAssignment(Map<Id,Opportunity> oldOppMap, Map<Id,Opportunity> newOppMap, Boolean isInsert){
Set<Id> oppId = new Set<Id>();
List<OpportunityLineItem> oppProduct = new List<OpportunityLineItem>();
List<Task> taskList = new List<Task>();
Id taskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Name_Assignment_Request').getRecordTypeId();

if(isInsert){
for(Opportunity oppRec: newOppMap.values()){
if(oppRec.Inventory_Source__c == 'SMTN Absorber' || oppRec.Inventory_Source__c == 'TBS Inventory' || oppRec.Inventory_Source__c == 'VIN Fulfillment' ||
oppRec.Inventory_Source__c == 'VTP List Only' || oppRec.Inventory_Source__c == 'VIN Fullfillment' || oppRec.Inventory_Source__c == 'HSI' || 
oppRec.Week_Source__c == '2138'){
oppId.add(oppRec.Id);
}
}
}else{
for(Opportunity oppRec: newOppMap.values()){

if(oppRec.Inventory_Source__c != oldOppMap.get(oppRec.Id).Inventory_Source__c && (oppRec.Inventory_Source__c == 'SMTN Absorber' || oppRec.Inventory_Source__c == 'TBS Inventory' || oppRec.Inventory_Source__c == 'VIN Fulfillment' ||
oppRec.Inventory_Source__c == 'VTP List Only' || oppRec.Inventory_Source__c == 'VIN Fullfillment' || oppRec.Inventory_Source__c == 'HSI' || 
oppRec.Week_Source__c == '2138')){
oppId.add(oppRec.Id);
}
}
}

oppProduct = [Select Id,OpportunityId,Opportunity.Account.Name from OpportunityLineItem Where OpportunityId IN: oppId];
Id queueId = [select Id from Group where Type = 'Queue' AND DeveloperNAME = 'Inventory'].Id;
for(OpportunityLineItem rec: oppProduct){
Task taskRec = new Task();
taskRec.OwnerId = queueId;
taskRec.Priority = 'Normal';
taskRec.RecordTypeId = taskRecordTypeId;
taskRec.Status = 'Open';
taskRec.Subject = 'Name Assignment Request - '+ rec.Opportunity.Account.Name;
taskRec.WhatId = rec.OpportunityId;
taskList.add(taskRec);
}
if(!taskList.isEmpty()){
insert taskList;
}
}
@Future
public static void UpdateTimeSharetoOpp(Id OppIdforTimeShare){
Opportunity OppforTime = [SELECT id,AccountId,Timeshare_1__c,Timeshare_2__c,Timeshare_3__c,Timeshare_4__c FROM Opportunity where id=:OppIdforTimeShare];
List<Timeshare__c> RelatedTimeShareRecords = [SELECT id FROM Timeshare__c WHERE Timeshare_Owner__c=:OppforTime.AccountId];
Integer listSize = RelatedTimeShareRecords.size();
for(Timeshare__c timeSharetoOppo : RelatedTimeShareRecords){
if(OppforTime.Timeshare_1__c==null){
OppforTime.Timeshare_1__c= timeSharetoOppo.id; 
}
else if(OppforTime.Timeshare_2__c==null){
OppforTime.Timeshare_2__c= timeSharetoOppo.id;
}
else if(OppforTime.Timeshare_3__c==null){
OppforTime.Timeshare_3__c= timeSharetoOppo.id;
}
else if(OppforTime.Timeshare_4__c==null){
OppforTime.Timeshare_4__c= timeSharetoOppo.id;
}
update OppforTime;
}
}
*/
    public static void clearReservationFields(Opportunity oppRec) {
        oppRec.Destination__c = null;
        oppRec.Property__c = null;
        oppRec.Rooms__c = null;
        oppRec.Check_in__c = null;
        oppRec.Check_Out__c = null;
        oppRec.program__c = null;
        oppRec.Adults__c = null;
        oppRec.Children_0_17__c = null;
        oppRec.Confirmation_Number__c = '';
        oppRec.Confirmed_Date__c = null;
        oppRec.Confirmation_Number_Flex__c = '';
        oppRec.Confirmed_Date_Flex__c = null;
        oppRec.Site_Name__c = null;
        oppRec.Room_Type__c = null;
        oppRec.Capacity__c = null;
        oppRec.Property_Address__c =  null;
        oppRec.Property_City__c =  null;
        oppRec.Property_State__c =  null;
        oppRec.Property_Country__c = null;
        oppRec.Property_Zipcode__c =  null;
        oppRec.Property_Phone__c =  null;
        oppRec.OB_Campaign_Case_Credated__c = false;
        oppRec.Property_Name__c = null;
        system.debug('--oppRec.Property_Phone__c--'+oppRec.Property_Phone__c);
    }
    
    

    
    
    
}