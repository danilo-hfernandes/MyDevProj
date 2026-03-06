public class LeadConversionController {
    
    /*@InvocableMethod
    public static list<Id> assignLeads(List<Id> LeadIds){
        list<Id> opportunityIds = new list<Id>();
        //LeadStatus cLeadStatus=[Select Id,MasterLabel from LeadStatus where isConverted=true limit 1];
        List<Database.LeadConvert> massLeadConvert=new List<Database.LeadConvert>();
        for(Id currentLead:LeadIds){
            Database.LeadConvert LeadConvert=new Database.LeadConvert();
            LeadConvert.setLeadId(currentLead);
            LeadConvert.setConvertedStatus('Closed Won');
            LeadConvert.setDoNotCreateOpportunity(false);
            massLeadConvert.add(LeadConvert);
        }
        if(!massLeadConvert.isEmpty()){
            List<Database.LeadConvertResult> lcr=Database.convertLead(massLeadConvert);
            system.debug('lcr:: '+lcr);
            for(Database.LeadConvertResult objConvetedlead : lcr){
                opportunityIds.add(objConvetedlead.getOpportunityId());
            }
        }
        System.debug('>>>>>>>>>opportunityIds>>'+opportunityIds);
        return opportunityIds;
    }*/
    
    // commented due to duplicate implementation issues
    @InvocableMethod
    public static list<Id> assignLeads(List<Id> LeadIds){
        list<Id> opportunityIds = new list<Id>();
		map<String,Lead> mapEmailVsLead = new map<String, Lead>();
        map<String,Lead> mapPhoneVsLead = new map<String, Lead>();
        map<String,Lead> mapAffiliateVsLead = new map<String, Lead>();
        set<String> setDupLeadIds = new set<String>();
        Set<String> emails = new Set<String>();
    	Set<String> phones = new Set<String>();
		List<Lead> listLead = [select id, Email,Phone,Affiliate_Id__c,LeadSource,Lead_Original_Source__c from Lead where Id IN: LeadIds];
        for (Lead l : listLead) {
            if (l.Email != null) emails.add(l.Email.toLowerCase());
            if (l.Email != null) emails.add(l.Email);
            if (l.Phone != null) phones.add(l.Phone.replaceAll('[^0-9]', ''));
            if (l.Phone != null) phones.add(l.Phone);
        }
         // Query existing Leads with matching Email or Phone
        List<Lead> existingLeads = [SELECT Id, Email, Phone, Affiliate_Id__c,LeadSource,Lead_Original_Source__c, CreatedDate FROM Lead WHERE (Email IN :emails OR Phone IN :phones) AND Id NOT IN : LeadIds];
		System.debug('>>>>>Test>>>>'+existingLeads.size());
        System.debug('>>>>>Test>>>>'+existingLeads);
        for(Lead objlead : existingLeads){
            mapEmailVsLead.put(objLead.Email, objLead);
            mapEmailVsLead.put(objLead.Email.toLowerCase(), objLead);
            mapPhoneVsLead.put(objLead.Phone, objLead);
            mapPhoneVsLead.put(objLead.Phone.replaceAll('[^0-9]', ''), objLead);
            mapAffiliateVsLead.put(objLead.Email+''+objLead.Affiliate_Id__c , objLead);
            mapAffiliateVsLead.put(objLead.Email.toLowerCase()+''+objLead.Affiliate_Id__c , objLead);
            mapAffiliateVsLead.put(objLead.Phone+''+objLead.Affiliate_Id__c , objLead);
            mapAffiliateVsLead.put(objLead.Phone.replaceAll('[^0-9]', '')+''+objLead.Affiliate_Id__c , objLead);
        }
		 for (Lead lead : listLead) {
             if((lead.email != null && mapEmailVsLead.containsKey(lead.email)) || (lead.phone != null && mapPhoneVsLead.containsKey(lead.phone))){
                System.debug('>Lead.Id>>>'+lead.Id);
				//Find the Affiliate ID of an existing lead that matches this lead by email. If none, try phone. If still none, return 0.
                Decimal affiliateId = mapEmailVsLead.containsKey(lead.email) ? mapEmailVsLead.get(lead.email).Affiliate_Id__c : (mapPhoneVsLead.containsKey(lead.phone) ? mapPhoneVsLead.get(lead.phone).Affiliate_Id__c : 0);
				//If find an existing Lead with the same Email AND Affiliate, return that Affiliate. Otherwise, try matching Phone AND Affiliate. If neither exists, return 0
                Decimal sameAffiliateId = mapAffiliateVsLead.containsKey(lead.email+''+lead.Affiliate_Id__c) ?mapAffiliateVsLead.get(lead.email+''+lead.Affiliate_Id__c).Affiliate_Id__c :  (mapAffiliateVsLead.containsKey(lead.phone+''+lead.Affiliate_Id__c) ? mapAffiliateVsLead.get(lead.phone+''+lead.Affiliate_Id__c).Affiliate_Id__c : 0);
                System.debug('>>>>affiliateId>>>'+affiliateId);
                System.debug('>>>>sameAffiliateId>>>'+sameAffiliateId);
                System.debug('>>>>lead.Affiliate_Id__c>>>'+lead.Affiliate_Id__c);

                 if ((lead.Affiliate_Id__c == sameAffiliateId || lead.Affiliate_Id__c == affiliateId)  && !lead.LeadSource.contains('Gunn Marketing/CCR') && lead.Lead_Original_Source__c != 'Mini Vac' && lead.Lead_Original_Source__c != 'Day Drive') {
                    // Same affiliate -> it's a duplicate
                 //    setDupLeadIds.add(lead.Id); 

                     if (lead.Affiliate_Id__c == 1002478) {
                         // Only allow duplicate if existing lead affiliate is also 1002478 and within a 12-month period. - MSR-229

                         Boolean validDuplicateFound = false;
                         Datetime twelveMonthsAgo = System.now().addMonths(-12);
                         
                         for (Lead existing : existingLeads) {
                             
                             Boolean emailMatch = (lead.Email != null && existing.Email == lead.Email);
                             Boolean phoneMatch = (lead.Phone != null && existing.Phone == lead.Phone);
                             
                             if ((emailMatch || phoneMatch)
                                 && existing.Affiliate_Id__c == 1002478
                                 && existing.CreatedDate >= twelveMonthsAgo) {
                                     
                                     validDuplicateFound = true;
                                     break;
                                 }
                         }
                         
                         if (validDuplicateFound) {
                             setDupLeadIds.add(lead.Id);
                         }
                         
                     } else {
                         // For all other affiliates → keep existing behavior
                         system.debug('setDupLeadIds add lead Id = '+lead.Id);
                         setDupLeadIds.add(lead.Id);
                     }
  
                     
                     
                     
                     
                     
                 }
                 
             }
        }
        System.debug('>>>>setDupLeadIds>>>'+setDupLeadIds);
        //LeadStatus cLeadStatus=[Select Id,MasterLabel from LeadStatus where isConverted=true limit 1];
        List<Database.LeadConvert> massLeadConvert=new List<Database.LeadConvert>();
        for(Id currentLead:LeadIds){
            System.debug('>>currentLead>>'+currentLead);
            if(!setDupLeadIds.contains(currentLead)){
                System.debug('>>>>setDupLeadIds>>>'+setDupLeadIds);
                Database.LeadConvert LeadConvert=new Database.LeadConvert();
                LeadConvert.setLeadId(currentLead);
                LeadConvert.setConvertedStatus('Closed Won');
                LeadConvert.setDoNotCreateOpportunity(false);
                massLeadConvert.add(LeadConvert);
            }
        }
        if(!massLeadConvert.isEmpty()){
            Database.DMLOptions dml = new Database.DMLOptions();
			dml.DuplicateRuleHeader.AllowSave = true;
            List<Database.LeadConvertResult> lcr=Database.convertLead(massLeadConvert, dml);
            system.debug('lcr:: '+lcr);
            for(Database.LeadConvertResult objConvetedlead : lcr){
                if (!objConvetedlead.isSuccess()) {     
                    System.debug('Lead Conversion Failed: ' + objConvetedlead.getErrors()); 
                } else 
                {     
                    System.debug('Lead Converted Successfully! Opportunity ID: ' + objConvetedlead.getOpportunityId()); 
                }
                opportunityIds.add(objConvetedlead.getOpportunityId());
            }
        }
        
        System.debug('>>>>>>>>>opportunityIds>>'+opportunityIds);
        return opportunityIds;
    }
}