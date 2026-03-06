trigger leadTriggerOM on Lead (after insert, before insert, after update, before Update) {
    Apex_Trigger_On_Off__c leadTrigger = Apex_Trigger_On_Off__c.getValues('Lead-Trigger');

    if(leadTrigger != null && leadTrigger.isEnable__c){
        Apex_Trigger_On_Off__c cs = Apex_Trigger_On_Off__c.getValues('LeadDupliateTriggerLogic');
        Apex_Trigger_On_Off__c cs2 = Apex_Trigger_On_Off__c.getValues('LeadSalesCadenceAssignment');
        Apex_Trigger_On_Off__c updateTimeZone = Apex_Trigger_On_Off__c.getValues('UpdateTimeZoneLead');
        List<Lead> leadlist = new List<Lead>();
        List<Lead> listlead = new List<Lead>();
        //List<Id> careFreeLeadList = new List<Id>();
        Id leadCFRecTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Carefree_Destinations').getRecordTypeId();
        Id socialAdSalesRecTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Ad_Sales').getRecordTypeId(); 

        User targetUserCFDFB = [ SELECT Id FROM User WHERE FirstName = 'Jennifer' AND LastName = 'Moorhead' and isActive = true LIMIT 1 ]; //CVT-9

        if(trigger.isAfter && trigger.isInsert){
            for (Lead lead : Trigger.new) {
                if(lead.leadSource.contains('CFD FB')) {
                    string JSONBody = JSON.serialize(lead);
                    if(!Test.isRunningTest()){
                        OM.sendLead(JSONBody);
                    }
                }
                /* if(lead.RecordTypeId == leadCFRecTypeId && lead.Match_Affiliate_Id__c == 1002256 && lead.LeadSource == 'TN Abandoned Cart' && lead.isduplicate){
careFreeLeadList.add(lead.Id);
}*/
            }
            /*if(careFreeLeadList != null && careFreeLeadList.size() > 0){
LeadConversionController.convertLeads(careFreeLeadList);
}*/
            if(updateTimeZone != null && updateTimeZone.isEnable__c)
                UpdateTimeZoneBasedOnAreaCodeController.updateLeadTimeZone(Trigger.new, null);
        }
        if(trigger.isAfter && trigger.isUpdate && updateTimeZone != null && updateTimeZone.isEnable__c){
            UpdateTimeZoneBasedOnAreaCodeController.updateLeadTimeZone(Trigger.new, Trigger.oldMap);
        } 
        //VVA-156 DNC AI Dialler
        if (trigger.isAfter && trigger.isUpdate) {
            for (Lead newLd : Trigger.new) {
                Lead oldLd = Trigger.oldMap.get(newLd.Id);
        
                // Check if DoNotCall changed to TRUE
                if (newLd.DoNotCall == true && oldLd.DoNotCall != true) {
                    System.debug('DoNotCall changed to TRUE for Lead Id: ' + newLd.Id);
        
                    // Call API Controller (async)
                    if(!Test.isRunningTest()){
                        System.debug('Calling DNC API for Lead Id: ' + newLd.Id);
                        DNCAPICallController.sendDNCRequest(newLd.Id);
                    }
                }
            }
}
              
        
        if(cs != null && cs.isEnable__c){
            if(trigger.isBefore && trigger.isInsert){
                Id tsNationRecTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('TS_Nation').getRecordTypeId();
                //leadTriggerOMHandler.smtnMXLeadMatchGroup(trigger.new);
                system.debug('31==');
                List<Lead> existingLeadRecords = new List<Lead>();
                set<String> phone = new set<String>();
                set<String> email = New set<String>();
                // Maps to track duplicate emails and phones within the same batch
                Map<String, Lead> emailToLeadMap = new Map<String, Lead>();
                Map<String, Lead> phoneToLeadMap = new Map<String, Lead>();
                for(Lead lead : Trigger.new){
                    /*if(lead.Raise_Away_Product__c == 'Raise Away-All Inclusive DR 5-Night $249 Resort Fee'){
                        lead.Lead_Original_Source__c = 'DR $150';
                    }
                    else if(lead.Raise_Away_Product__c == 'Raise Away-All Inclusive MX 5-Night $249 Resort Fee')
                    {
                        lead.Lead_Original_Source__c = 'MX $440';
                    }*/
                    system.debug('37==');
                    if (!String.isEmpty(lead.Email)) {
                        email.add(lead.Email);
                        if (emailToLeadMap.containsKey(lead.Email)) {
                            lead.Is_Duplicate__c = true; // Mark as duplicate
                        } else {
                            emailToLeadMap.put(lead.Email, lead); // Store first occurrence
                        }
                    }
                    if (!String.isEmpty(lead.Phone)) {
                        phone.add(lead.Phone);
                        if (phoneToLeadMap.containsKey(lead.Phone)) {
                            lead.Is_Duplicate__c = true; // Mark as duplicate
                        } else {
                            phoneToLeadMap.put(lead.Phone, lead); // Store first occurrence
                        }
                    }
                }
                //2023-05-31 - duplicated logic changed due to MAINT-562
                system.debug('46==');
                if(phone.size() > 0 && email.size() > 0){
                    existingLeadRecords = [Select id,Email,Phone,OwnerId,Owner.IsActive,Is_Duplicate__c,CreatedDate,Owner.Profile.Name,Lead_Original_Source__c,LeadSource,RecordTypeId from Lead where /*Is_Duplicate__c = false*/ /*and*/ (Email IN: email OR Phone IN: phone) order by createddate desc];
                }else if(email.size() > 0){
                    existingLeadRecords = [Select id,Email,Phone,OwnerId,Owner.IsActive,Is_Duplicate__c,CreatedDate,Owner.Profile.Name,Lead_Original_Source__c,LeadSource,RecordTypeId  from Lead where /*Is_Duplicate__c = false*/ /*and*/ Email != NULL AND Email IN: email order by createddate desc];
                }else if(phone.size() > 0){
                    existingLeadRecords = [Select id,Email,Phone,OwnerId,Owner.IsActive,Is_Duplicate__c,CreatedDate,Owner.Profile.Name,Lead_Original_Source__c,LeadSource,RecordTypeId from Lead where /*Is_Duplicate__c = false*/ /*and*/ Phone IN: phone order by createddate desc];
                }
                system.debug('56==');
                
                /*if(existingLeadRecords.size()==0){
for(Lead newLead:trigger.new){

system.debug('60=='+newlead.Name);

Id leadRecTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('SMTN_Mexico').getRecordTypeId();        

if(newLead.leadSource=='SMTN MX Voucher' &&  newLead.recordtypeid==leadRecTypeId){
system.debug('66=='+newlead.Name);

newLead.SMTN_match_group__c='TRUE';
newLead.is_duplicate__C=false;
newLead.leadassist__Use_Round_Robin__c='TRUE';
newLead.Assign_to_Sales_Cadence__c=true;
}
}
}*/
                Date fifteenDaysAgo = Date.today().addDays(-15);
                List<String> leadSourceString = new List<String>{'Offsite MX Voucher', 'TBS MX Voucher','Marival Affiliate Marketing','Vidanta MX Affiliate Marketing','Vidanta Affiliate Marketing'};
                    String zappierUserId = System.Label.ZappierUserId;
                String salesforceUserId = System.Label.SalesforceUserId;                
                for(Lead newLead: Trigger.new){//SalesforceUserId
                    if(!(newLead.RecordTypeId == leadCFRecTypeId && ((leadSourceString.contains(newLead.LeadSource) && System.UserInfo.getUserId() == zappierUserId) || (newLead.LeadSource == 'TBS MX Voucher' && newLead.OwnerId == salesforceUserId)))){
                        system.debug('58==');
                        for(Lead existingLead: existingLeadRecords){
                            if(newLead.Email == existingLead.Email || newLead.Phone == existingLead.Phone){
                                if(!newLead.LeadSource.contains('Gunn Marketing/CCR') || ((newLead.LeadSource.contains('Gunn Marketing/CCR') && (newLead.Lead_Original_Source__c == 'Day Drive'|| newLead.Lead_Original_Source__c == 'Mini Vac')) && (existingLead.LeadSource.contains('Gunn Marketing/CCR') && (existingLead.Lead_Original_Source__c == 'Day Drive'|| existingLead.Lead_Original_Source__c == 'Mini Vac')))){
                                    Date recordCreatedDate = existingLead.CreatedDate.date();
                                    //2023-05-31 - duplicated logic changed due to MAINT-562
                                    //2026-02-09 - do not set parent if newLead is Ad Sales but existing is not (to avoid assignment issues)
                                    if(!existingLead.Is_Duplicate__c && !(newLead.RecordTypeId == socialAdSalesRecTypeId && existingLead.RecordTypeId != socialAdSalesRecTypeId)){
	                                    newLead.Parent_Lead__c = existingLead.Id;
                                    }
                                    //2023-05-31 - duplicated logic changed due to MAINT-562
                                    if(recordCreatedDate >= fifteenDaysAgo && !(newLead.RecordTypeId == socialAdSalesRecTypeId && existingLead.RecordTypeId != socialAdSalesRecTypeId)){
                                        newLead.Is_Duplicate__c = true;
                                    }
                                    
                                    
                                    //2023-05-31 - duplicated logic changed due to MAINT-562
                                    //2023-10-19 - HSIMU2-349 - Don't override new lead owner by the parent lead owner if the parent owner is a system admin
                                    if(!existingLead.Is_Duplicate__c && existingLead.Owner.IsActive && (existingLead.Owner.Profile.Name != 'System Administrator')){
                                        if(!newLead.LeadSource.startsWith('CFD FB')){ // CVT-9
                                            newLead.OwnerId = existingLead.OwnerId;
                                        }
                                    }
                                    if(newLead.RecordTypeId == tsNationRecTypeId && newLead.LeadSource == 'Timeshare Nation TCS' && existingLead.RecordTypeId == tsNationRecTypeId && existingLead.LeadSource == 'Timeshare Nation TCS'){
                                        newLead.addError('Error - Duplicate found with the same Email or Phone, Lead Record Type (TS Nation) and Lead Source (Timeshare Nation TCS)');
                                    }
                                }
                            }                            
                        }
                    }
                }
                
                
                for(lead newlead:trigger.new){
                    if(newlead.leadsource=='Vacation VIP - Web'){
                        newlead.recordtypeid=leadCFRecTypeId;
                    }
                }

                // CVT-9
                for(lead newlead:trigger.new){
                    if(newLead.LeadSource.startsWith('CFD FB')){ // CVT-9 
                        newLead.OwnerId = targetUserCFDFB.Id;
                    }
                }

            }
        }
        
        if(cs2 != null && cs2.isEnable__c){
            if(trigger.isAfter && trigger.isUpdate){
                system.debug('90==');
                if(checkRecursive.runOnceLeadTrigger()){
                    
                    List<Lead> VVIPDuplicateLeads= new list<Lead>();
                    Set<Id> leadListToMXSalesCadence = new Set<Id>();
                    Set<Id> leadListToSalesCadence = new Set<Id>();
                    Set<Id> leadListToVIRefSalesCadence = new Set<Id>();
                    List<Lead> fileTrackerLeadList = new List<Lead>();
                    User zappierUser = [SELECT Id,Username FROM User WHERE Email = 'zappier@nerdsoft.com' OR Email = 'zappier@nerdsoft.com.invalid' LIMIT 1];
                    //User devAccountSandboxUser = [SELECT Id,Username FROM User WHERE Email = 'dev@nerdsoft.com' AND Username LIKE '%dev@nerdsoft.com.hsi.full%'LIMIT 1];
                    //User devAccountUser = [SELECT Id,Username FROM User WHERE Email = 'dev@nerdsoft.com' OR Email = 'dev@nerdsoft.com.invalid' LIMIT 1];
                    //Id leadCFRecTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Carefree_Destinations').getRecordTypeId();
                    Id fileTrackerRecTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Filetracker_Reservations').getRecordTypeId(); 
                    Set<Id> LeadIdSet = new Set<Id>();
                    for(Lead led : trigger.new){
                        system.debug('106=='+ led.LeadSource);
                        if(zappierUser != null )//&& !(led.Marketing_Email_opt_out__c)
                        {
                            System.debug('leadCFRecTypeId : '+leadCFRecTypeId);
                            System.debug('led.RecordTypeId : '+led.RecordTypeId);
                            System.debug('led.Status : '+led.Status);
                            System.debug('led.CreatedById : '+led.CreatedById);
                            System.debug('zappierUser.Id : '+zappierUser.Id);
                            System.debug('led.leadassist__Use_Round_Robin__c : '+led.leadassist__Use_Round_Robin__c);
                            System.debug('Trigger.oldMap.get(led.Id).leadassist__Use_Round_Robin__c : '+Trigger.oldMap.get(led.Id).leadassist__Use_Round_Robin__c);
                            System.debug('led.leadassist__Use_Round_Robin__c : '+led.leadassist__Use_Round_Robin__c);
                            System.debug('led.LeadSource : '+led.LeadSource);
                            Date myDate = date.newinstance(2022, 10, 5);
                            
                            if(((led.LeadSource == 'GBT - FBLA - RMKT') || (led.LeadSource == 'CV - GBT') && led.First_Action_Cadence_Id__c == null) || (trigger.oldMap != null && ((led.LeadSource != trigger.oldMap.get(led.Id).LeadSource) || (led.Sales_Cadence_Assignment_Attempt__c != trigger.oldMap.get(led.Id).Sales_Cadence_Assignment_Attempt__c) || (led.leadassist__Use_Round_Robin__c != trigger.oldMap.get(led.Id).leadassist__Use_Round_Robin__c))) && ((led.LeadSource == 'Timeshare Nation TCS') || (led.LeadSource == 'Vacation VIP - Web') || (led.LeadSource == 'VVIP Westgate Orlando') || (led.LeadSource == 'VVIP Westgate Las Vegas') || (led.LeadSource == 'SMTN Rental Offer') || (led.LeadSource == 'Vacation VIP Retraveler') || (led.LeadSource == 'VIN Open Survey') || (led.LeadSource == 'SMTN Open Survey') || (led.LeadSource == 'VI Referral') || (led.LeadSource == 'SMTN MX Voucher') || (led.LeadSource == 'GBT - FBLA - RMKT') || (led.LeadSource == 'CV - GBT') || (led.RecordTypeId == leadCFRecTypeId && led.CreatedById == zappierUser.Id && led.Is_Duplicate__c==false)) && !led.isConverted && led.CreatedDate > myDate &&
                               ((led.First_Action_Cadence_Id__c == '' || led.First_Action_Cadence_Id__c == null) || (led.Sales_Cadence_Assignment_Attempt__c >= 1 && led.Sales_Cadence_Assignment_Attempt__c <= 3)) && led.leadassist__Use_Round_Robin__c == 'ASSIGNED')
                            {
                                if(led.LeadSource == 'CFD Mexico' || led.LeadSource == 'CFD FB Mexico' || led.LeadSource == 'CFD Mexico FB' || led.LeadSource == 'CFD Riviera Maya' || led.LeadSource == 'CFD FB Riviera Maya' ||
                                   led.LeadSource == 'CFD FB Mexico Golf' || led.LeadSource == 'CFD FB Mexico Spring Break' || led.LeadSource == 'CFD FB Acapulco' || led.LeadSource == 'CFD FB Los Cabos' ||
                                   led.LeadSource == 'CFD FB Puerto Vallarta' || led.LeadSource == 'CFD FB Nuevo Vallarta' || led.LeadSource == 'CFD FB Puerto Penasco' || led.LeadSource == 'CFD FB Cancun' ||
                                   led.LeadSource == 'CFD FB Mexico Summer' || led.LeadSource == 'CFD FB Cinco de Mayo' || led.LeadSource == 'CFD FB Mexico COVID' || led.LeadSource == 'CFD MX Checkout' || led.LeadSource == 'CFD Google Mexico' ||
                                   led.LeadSource == 'CFD Google Acapulco' || led.LeadSource == 'CFD Google Cancun' || led.LeadSource == 'CFD Google Riviera Maya' || led.LeadSource == 'CFD Google Puerto Penasco' || led.LeadSource == 'CFD Google Puerto Vallarta' ||
                                   led.LeadSource == 'CFD Google Nuevo Vallarta')
                                {
                                    System.debug('IN leadListToMXSalesCadence : '+led.LeadSource);
                                    // Added by Mitul
                                    //leadListToMXSalesCadence.add(led.Id);
                                    LeadIdSet.add(led.Id);
                                }
                                else if(led.LeadSource != 'Timeshare Nation TCS' && led.LeadSource != 'SMTN Rental Offer' && led.LeadSource != 'VIN Open Survey' && led.LeadSource != 'SMTN Open Survey' && led.LeadSource != 'VI Referral' && led.LeadSource != 'VVIP Westgate Las Vegas' && led.LeadSource != 'VVIP Westgate Orlando' && led.LeadSource != 'Vacation VIP Retraveler' && led.LeadSource != 'TRM Contactable' && led.LeadSource != 'TRM Open' && led.LeadSource != 'Vacation VIP - Web' && led.LeadSource != 'SMTN MX Voucher' && led.LeadSource != 'CV - GBT' && led.LeadSource != 'GBT - FBLA - RMKT' )
                                {
                                    System.debug('IN leadListToSalesCadence : '+led.LeadSource);
                                    // Added by Mitul
                                    //leadListToSalesCadence.add(led.Id);
                                    LeadIdSet.add(led.Id);
                                }
                                else if(led.LeadSource == 'VI Referral')  //TGR-592
                                {
                                    System.debug('IN leadListToVIRefSalesCadence : '+led.LeadSource);
                                    // Added by Mitul
                                    //leadListToVIRefSalesCadence.add(led.Id);
                                    LeadIdSet.add(led.Id);
                                }
                                else if(led.LeadSource == 'Vacation VIP Retraveler')
                                {
                                    System.debug('IN leadListToVacationVIPRetravelerCadence : '+led.LeadSource);
                                    // Added by Victor
                                    //leadListToVIRefSalesCadence.add(led.Id);
                                    //LeadIdSet.add(led.Id);
                                }
                                else if(led.LeadSource == 'VVIP Westgate Orlando' || led.LeadSource == 'VVIP Westgate Las Vegas')
                                {
                                    System.debug('IN leadListToVacationVIPWestgateCadence : '+led.LeadSource);
                                    // Added by Victor
                                    //leadListToVIRefSalesCadence.add(led.Id);
                                    LeadIdSet.add(led.Id);
                                }
                                /*else if(led.LeadSource == 'SMTN Open Survey' || led.LeadSource == 'VIN Open Survey')
{
System.debug('IN leadListToTourGen-SMTNOpenSurveyCadence or TourGen-VIN Open Survey: '+led.LeadSource);
// Added by Victor
//leadListToVIRefSalesCadence.add(led.Id);
LeadIdSet.add(led.Id);
}*/
                                /* else if(led.LeadSource == 'SMTN MX Voucher')
{
system.debug('165==');
LeadIdSet.add(led.Id);
}*/
                                else if(led.LeadSource == 'SMTN Rental Offer')
                                {
                                    system.debug('SMTN Rental Offer added == '+led.Id);
                                    LeadIdSet.add(led.Id);
                                }
                                
                                else if(led.LeadSource == 'Timeshare Nation TCS')
                                {
                                    system.debug('Timeshare Nation TCS added == '+led.Id);
                                    LeadIdSet.add(led.Id);
                                }
                                
                                //SAS-65 2026-2-6
                                else if((led.LeadSource == 'GBT - FBLA - RMKT' || led.LeadSource == 'CV - GBT') && led.Is_Duplicate__c == False)
                                {
                                    system.debug('Social Ad-Sales - GBT added == '+led.Id);
                                    LeadIdSet.add(led.Id);
                                }                                
                                
                                else if(led.LeadSource == 'Vacation VIP - Web')
                                {
                                    if((led.First_Action_Cadence_Id__c == '' || led.First_Action_Cadence_Id__c == null)){
                                        if(led.Is_Duplicate__c==false){
                                            System.debug('IN leadListToTourGen-VacationVIPPlusMembersSalesCadence : '+led.LeadSource);
                                            // Added by Mitul
                                            //leadListToVIRefSalesCadence.add(led.Id);
                                            LeadIdSet.add(led.Id);
                                        }
                                        else
                                        {
                                            VVIPDuplicateLeads.add(led);
                                        }
                                    }
                                }
                            }
                        }
                        if(led.RecordTypeId == fileTrackerRecTypeId){
                            fileTrackerLeadList.add(led);
                        }
                    }
                    if(fileTrackerLeadList != null && fileTrackerLeadList.size() > 0){
                        FileTrackerLeadConversionController.convertLeads(fileTrackerLeadList);
                    }
                    
                    
                    
                    //Checking for VVIP Duplicates lead is already in sales cadence
                    List<Lead> existingVVIPLeadRecords = new List<Lead>();
                    set<String> phone1 = new set<String>();
                    set<String> email1 = New set<String>();
                    
                    for(Lead lead : VVIPDuplicateLeads){
                        if(lead.Phone != null){
                            phone1.add(lead.Phone);
                        }
                        if(lead.Email != null){
                            email1.add(lead.Email);
                        }
                    }
                    if(phone1.size() > 0 || email1.size() > 0){
                        existingVVIPLeadRecords = [Select id,Email,Phone,OwnerId,createddate,Owner.IsActive from Lead where (Email IN: email1 OR Phone IN: phone1) and actioncadenceid=null and createddate < N_DAYS_AGO:15];
                        
                        for(Lead newLead: VVIPDuplicateLeads){
                            for(Lead existingLead: existingVVIPLeadRecords){
                                if(newLead.Email == existingLead.Email || newLead.Phone == existingLead.Phone){
                                    LeadIdSet.add(newLead.Id);
                                }
                            }
                        }
                    }
                    // Added by Mitul
                    if(LeadIdSet != null && LeadIdSet.size() > 0){
                        System.enqueueJob(new leadTriggerOMHandler(LeadIdSet)); 
                    }
                    /*
System.debug('leadListToMXSalesCadence : '+leadListToMXSalesCadence);
System.debug('leadListToSalesCadence : '+leadListToSalesCadence);
if(leadListToMXSalesCadence.size()>0 && leadListToMXSalesCadence != null){
for(Id ldMXId : leadListToMXSalesCadence){                        
//leadTriggerOMHandler.leadTriggerOMHandler(ldMXId, 'TourGen-FB-MX *New Lead');
System.enqueueJob(new leadTriggerOMHandler(ldMXId, 'TourGen-FB-MX *New Lead')); 
}
}
if(leadListToSalesCadence.size()>0 && leadListToSalesCadence != null){
for(Id ldId : leadListToSalesCadence){                        
//leadTriggerOMHandler.leadTriggerOMHandler(ldId, 'TourGen-FB-Other*New Lead');
System.enqueueJob(new leadTriggerOMHandler(ldId, 'TourGen-FB-Other*New Lead'));
}
}
if(leadListToVIRefSalesCadence.size()>0 && leadListToVIRefSalesCadence != null){
for(Id ldVIRefId : leadListToVIRefSalesCadence){                        
//leadTriggerOMHandler.leadTriggerOMHandler(ldVIRefId, 'TourGen-VI Referral-*New Lead');
System.enqueueJob(new leadTriggerOMHandler(ldVIRefId, 'TourGen-VI Referral-*New Lead'));
}
}*/
                }
            }
        }
        
        if(trigger.isBefore){
            //Id leadVIRefRecTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('VI_Referral').getRecordTypeId();
            List<Lead> leadsToMatchAffiliate = new List<Lead>();
            List<Lead> leadsToOverrideOwner = new List<Lead>();
            Map<Id,String> leadSourceMap = new Map<Id,String>();
            Map<String,String> leadSourceAffiliateMap = new Map<String,String>();
            Map<String,String> leadSourceAffiliateNameMap = new Map<String,String>();
            for(Lead ld : Trigger.New)
            {
                if(ld.LeadSource != null){
                    leadsToMatchAffiliate.add(ld);
                }
                String ldFullName = ld.FirstName+' '+ld.LastName;
                if(ldFullName.contains('_test') || ldFullName.contains('_Test'))
                {
                    leadsToOverrideOwner.add(ld);
                }
                /*if((ld.RecordTypeId == leadVIRefRecTypeId || ld.LeadSource == 'VI Referral') && ld.Match_Affiliate_Id__c == null)
{
ld.Match_Affiliate_Id__c = 1002261;
}*/
            }
            if(leadsToMatchAffiliate != null && leadsToMatchAffiliate.size()>0)
            {
                for(Lead ldm : leadsToMatchAffiliate)
                {
                    leadSourceMap.put(ldm.Id,ldm.LeadSource);
                }
                List<Lead_Source_Settings__c> ldSourceSettings = new List<Lead_Source_Settings__c>();
                ldSourceSettings = [SELECT Id,Lead_Source__c,Affiliate_Id__r.Affiliate_Id__c,Affiliate_Id__r.Affiliate_Name__c FROM Lead_Source_Settings__c WHERE Affiliate_Id__c != NULL AND Lead_Source__c IN : leadSourceMap.values()];
                if(ldSourceSettings != null && ldSourceSettings.size()>0)
                {
                    for(Lead_Source_Settings__c ldsSettings : ldSourceSettings)
                    {
                        leadSourceAffiliateMap.put(ldsSettings.Lead_Source__c,ldsSettings.Affiliate_Id__r.Affiliate_Id__c);
                        leadSourceAffiliateNameMap.put(ldsSettings.Lead_Source__c,ldsSettings.Affiliate_Id__r.Affiliate_Name__c);
                    }
                    
                    for(Lead leadMatch : leadsToMatchAffiliate)
                    {
                        if(leadSourceAffiliateMap.get(leadMatch.LeadSource) != null)
                        {
                            if(leadSourceAffiliateMap.get(leadMatch.LeadSource).isNumeric())
                            {
                                leadMatch.Match_Affiliate_Id__c = Integer.valueOf(leadSourceAffiliateMap.get(leadMatch.LeadSource));
                            }
                            if(leadSourceAffiliateNameMap.get(leadMatch.LeadSource) != null)
                            {
                                if(leadSourceAffiliateNameMap.get(leadMatch.LeadSource) != 'No Affiliate Id'){
                                    leadMatch.Match_Affiliate_Name__c = leadSourceAffiliateNameMap.get(leadMatch.LeadSource);
                                }
                            }
                        }
                    }
                    
                }
            }
            //logic to not assign any test records to agents in Prod
            MU_Jobs_test_Record_Filter__c testRecordsFilterSettings = MU_Jobs_test_Record_Filter__c.getValues('Filters Enabled');
            if(testRecordsFilterSettings != null)
            {
                if(testRecordsFilterSettings.Any_Test_Record__c && leadsToOverrideOwner != null && leadsToOverrideOwner.size()>0)
                {
                    //original admin owner map
                    Map<Id, User> m = new Map<Id, User>([SELECT Id,Username FROM User WHERE Username = 'dev@nerdsoft.com.hsi' OR Username = 'dev@nerdsoft.com.hsi.full' OR Username = 'dev@nerdsoft.com.hsi.1' OR Username = 'dev@nerdsoft.com.hsi.1.full' OR Username = 'zappier@nerdsoft.com' OR Username = 'zappier@nerdsoft.com.full']);
                    
                    List<User> devAccountUser = new List<User>();
                    
                    for(Id userid : m.keySet())
                    {
                        if(m.get(userid).Username == 'dev@nerdsoft.com.hsi' || m.get(userid).Username == 'dev@nerdsoft.com.hsi.full')
                        {
                            devAccountUser.add(m.get(userid));
                        }
                    }                
                    
                    if(m != null && m.size()>0)
                    {
                        if(devAccountUser != null && devAccountUser.size()>0){
                            for(Lead ld : leadsToOverrideOwner)
                            {
                                if(m.get(ld.CreatedById) != null)
                                {
                                    ld.OwnerId = ld.CreatedById;
                                }
                                else if(m.get(ld.OwnerId) == null)
                                {
                                    ld.OwnerId = devAccountUser[0].Id;
                                }
                            }                    
                        }
                    }
                    
                }
            }
        }

        //NSEA-503 - Create Hashed fields for Leads - Hashed for acoustic         
        if (Trigger.isBefore && Trigger.isUpdate) {
            // Only call the helper if at least one Lead has missing hashed fields
            Boolean needsUpdate = false;
    
            for (Lead l : Trigger.new) {
                if (l.Hashed_Email__c == null ||
                    l.Hashed_FirstName__c == null ||
                    l.Hashed_LastName__c == null ||
                    l.Hashed_Phone__c == null) {
                    needsUpdate = true;
                    break; // No need to check more — we’ll handle all in helper
                }
            }
    
            if (needsUpdate) {
                Base64FieldHelper.populateBase64Fields(Trigger.new, 'Lead');
            }
    
        } else if (Trigger.isBefore && Trigger.isInsert) {
            // Always populate on insert
            Base64FieldHelper.populateBase64Fields(Trigger.new, 'Lead');
        }

        
        if(trigger.IsBefore && trigger.isUpdate)        
        {
            Id Public_Reservation_Inquiry_Id = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Public_Reservation_Inquiry').getRecordTypeId();            
            Id Carefree_Destinations_Id = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Carefree_Destinations').getRecordTypeId();            
            Id SMTN_Mexico_Id = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('SMTN_Mexico').getRecordTypeId();            
            Id VI_Referral_Id = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('VI_Referral').getRecordTypeId();
            Map<String,Lead> leadsPhones = new Map<String,Lead>();
            Map<String,Lead> leadsEmails = new Map<String,Lead>();
            Map<Decimal,Lead> leadsAffiliateIds = new Map<Decimal,Lead>();
            Set<Id> convertingLeadAccountsIds = new Set<Id>();
            Set<Id> convertingLeadContactsIds = new Set<Id>();
            List<Opportunity> listOpportunity = new List<Opportunity>();
            List<Lead> listLeadOppCreation = new List<Lead>();
            set<Id> setLemonJuiceAcc = new set<Id>();
            //Id leadVIRefRecTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('VI_Referral').getRecordTypeId();
            for(Lead ld : Trigger.New)
            {
                /*if(ld.Raise_Away_Product__c == 'Raise Away-All Inclusive DR 5-Night $249 Resort Fee'){
                    ld.Lead_Original_Source__c = 'DR $150';
                }
                else if(ld.Raise_Away_Product__c == 'Raise Away-All Inclusive MX 5-Night $249 Resort Fee')
                {
                    ld.Lead_Original_Source__c = 'MX $440';
                }*/
                
                if((ld.Status == 'DNC' || ld.Status == 'Bad Email') && !ld.Marketing_Email_opt_out__c){
                    ld.Marketing_Email_opt_out__c = true;
                }
                if(trigger.oldMap.get(ld.Id).Marketing_Email_opt_out__c != ld.Marketing_Email_opt_out__c){//ld.Marketing_Email_opt_out__c && !trigger.oldMap.get(ld.Id).Marketing_Email_opt_out__c && 
                    listlead.add(ld);
                }                
                if(trigger.oldMap.get(ld.Id).Closing_Agent__c != ld.Closing_Agent__c){
                    String runningUserName = UserInfo.getName();
                    if (String.isBlank(runningUserName)) {
                        runningUserName = 'Unknown User';
                    }
                    
                    String ts = Datetime.now().format('yyyy-MM-dd HH:mm');
                    
                    String newVal = String.isBlank(ld.Closing_Agent__c)
                        ? '[cleared]'
                        : '\'' + ld.Closing_Agent__c.trim() + '\'';
                    
                    String entry =
                        'Closing Agent = ' + newVal +
                        ' assigned by ' + runningUserName +
                        ' at ' + ts;
                    
                    String existing = String.isBlank(ld.Comments__c)
                        ? ''
                        : ld.Comments__c.trim();
                    
                    String combined = String.isBlank(existing)
                        ? entry
                        : existing + ' | ' + entry;
                    
                    // Keep within 255 chars (retain most recent part)
                    if (combined.length() > 255) {
                        combined = combined.substring(combined.length() - 255);
                    }
                    
                    ld.Comments__c = combined;
                }                
                //if(ld.IsConverted && (ld.RecordTypeId == leadVIRefRecTypeId || ld.LeadSource == 'VI Referral'))
                System.debug('Lead check IsConverted : '+ld.IsConverted);
                System.debug('Lead check Match_Affiliate_Id__c : '+ld.Match_Affiliate_Id__c);
                if(ld.IsConverted && ld.Match_Affiliate_Id__c != null && ld.Match_Affiliate_Id__c != 1002421 && !ld.LeadSource.contains('Gunn Marketing/CCR') && ld.Lead_Original_Source__c != 'Mini Vac' && ld.Lead_Original_Source__c != 'Day Drive')//Allow Duplicates for 1002421 Affiliate
                {
                    if(ld.Phone != null){
                        leadsPhones.put(ld.Phone,ld);
                    }
                    if(ld.Email != null){
                        leadsEmails.put(ld.Email,ld);
                    }
                    leadsAffiliateIds.put(ld.Match_Affiliate_Id__c,ld);
                    convertingLeadAccountsIds.add(ld.ConvertedAccountId);
                    convertingLeadContactsIds.add(ld.ConvertedContactId);
                }
                if(ld.IsConverted && ld.Status == 'New' && ld.LeadSource == 'SMTN Rental Offer' && ld.RecordTypeId == Public_Reservation_Inquiry_Id){
                    listLeadOppCreation.add(ld);
                }
                if(ld.IsConverted && ld.LeadSource == 'LemonJuice Owners' && ld.RecordTypeId == Carefree_Destinations_Id){
                    setLemonJuiceAcc.add(ld.ConvertedAccountId);
                }
            }
            if(setLemonJuiceAcc != null  && setLemonJuiceAcc.size() > 0){
                List<Account> updateLemonJuiceAccount = new List<Account>();
                for(String accId : setLemonJuiceAcc){
                    Account acc = new Account();
                    acc.Id = accId;
                    acc.Membership_Status__c = 'Inactive';
                    acc.Affiliated_Id__c = 1002436;
                    acc.Affiliate_Name__c = 'CoolVacay Plus';
                    updateLemonJuiceAccount.add(acc);
                }
                if(updateLemonJuiceAccount != null && updateLemonJuiceAccount.size() > 0){
                    update updateLemonJuiceAccount;
                }
            }
            if(listLeadOppCreation != null && listLeadOppCreation.size() >0){
                for(Lead objlead : listLeadOppCreation){
                    Opportunity opp = new Opportunity();
                    opp.Name = 'Travel Opportunity';
                    opp.StageName = 'New';
                    opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Travel').getRecordTypeId();
                    opp.CloseDate = System.Today();
                    opp.AccountId = objlead.ConvertedAccountId;
                    listOpportunity.add(opp);
                }
                if(listOpportunity != null && listOpportunity.size() > 0){
                    insert listOpportunity;
                }
            }
            if(listlead != null && listlead.size() > 0){
                UnsubscribeRecordsHandler.unsubscribe(listlead, 'Lead');
            }
            if(leadsPhones.size()>0 || leadsEmails.size()>0)
            {
                
                Map<Id,Account> duplicatedAccounts = new Map<Id,Account>();
                //try{
                duplicatedAccounts = new Map<Id,Account>([Select Id,Email__c,Phone,Affiliated_Id__c,Master_Record_Id__c,CreatedDate,SystemModStamp,LastReferencedDate, (SELECT Id,AffiliatedId__c,Phone,Email FROM Contacts where (AffiliatedId__c IN: leadsAffiliateIds.keySet()) AND (Email IN: leadsEmails.keySet() OR Phone IN: leadsPhones.keySet())) FROM Account where (Affiliated_Id__c IN: leadsAffiliateIds.keySet()) AND (Email__c IN: leadsEmails.keySet() OR Phone IN: leadsPhones.keySet()) order by createddate desc]);
                //}
                /*catch(QueryException e)
{
System.debug( e.getMessage() );                
}*/
                
                Map<Id,Contact> duplicatedContacts = new Map<Id,Contact>();
                if(duplicatedAccounts != null && duplicatedAccounts.size()>0){
                    
                    //try{
                    duplicatedContacts = new Map<Id,Contact>([SELECT Id,AffiliatedId__c,Phone,Email,AccountId FROM Contact where (AffiliatedId__c IN: leadsAffiliateIds.keySet()) AND AccountId IN: duplicatedAccounts.keySet() AND (Email IN: leadsEmails.keySet() OR Phone IN: leadsPhones.keySet())]);
                    //}
                    /*catch(QueryException e1)
{
System.debug( e1.getMessage() );
}*/
                    
                    System.debug('duplicatedAccounts query : '+duplicatedAccounts);
                    for(Id accountIdCheck : convertingLeadAccountsIds)
                    {
                        if(duplicatedAccounts.get(accountIdCheck) != null){
                            duplicatedAccounts.remove(accountIdCheck);
                        }
                    }
                    for(Id contactIdCheck : convertingLeadContactsIds)
                    {
                        if(duplicatedContacts.get(contactIdCheck) != null){
                            duplicatedContacts.remove(contactIdCheck);
                        }
                    }
                }
                if(duplicatedAccounts != null && duplicatedAccounts.size()>0)
                {
                    Map<String,Account> accountsPhones = new Map<String,Account>();
                    Map<String,Account> accountsEmails = new Map<String,Account>();
                    for(Account acc : duplicatedAccounts.values())
                    {
                        accountsPhones.put(acc.Phone,acc);
                        accountsEmails.put(acc.Email__c,acc);
                    }
                    for(Lead duplicatedLead : leadsPhones.values())
                    {
                        if(accountsEmails.get(duplicatedLead.Email) != null)
                        {                     
                            if(AccountFlags.hasInsertRun)
                            {
                                duplicatedLead.addError('An account with this Email ('+duplicatedLead.Email+') already exists, please select one of the suggested accounts in the "Choose Existing" section, or cancel the conversion.');
                            }
                        }
                        else if(accountsPhones.get(duplicatedLead.Phone) != null)
                        {
                            if(AccountFlags.hasInsertRun)
                            {
                                duplicatedLead.addError('An account with this Phone ('+duplicatedLead.Phone+') already exists, please select one of the suggested accounts in the "Choose Existing" section, or cancel the conversion.');
                            }
                        }                       
                    }
                }
                if(duplicatedContacts != null && duplicatedContacts.size()>0)
                {
                    Map<String,Contact> contactsPhones = new Map<String,Contact>();
                    Map<String,Contact> contactsEmails = new Map<String,Contact>();
                    
                    for(Contact contt : duplicatedContacts.values())
                    {
                        contactsPhones.put(contt.Phone,contt);
                        contactsEmails.put(contt.Email,contt);
                    }
                    
                    for(Lead duplicatedLead2 : leadsPhones.values())
                    {
                        if(contactsEmails.get(duplicatedLead2.Email) != null)
                        {                        
                            if(ContactFlags.hasInsertRun)
                            {
                                duplicatedLead2.addError('A contact with this Email ('+duplicatedLead2.Email+') already exists, please select one of the suggested contacts in the "Choose Existing" section, or cancel the conversion.');
                            }
                        }
                        else if(contactsPhones.get(duplicatedLead2.Phone) != null)
                        {
                            if(ContactFlags.hasInsertRun)
                            {
                                duplicatedLead2.addError('A contact with this Phone ('+duplicatedLead2.Phone+') already exists, please select one of the suggested contacts in the "Choose Existing" section, or cancel the conversion.');
                            }                        
                        }
                    }
                }
            }
        }
    }
}