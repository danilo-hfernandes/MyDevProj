public class LeadConversionWithDupCheckController {
    
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
    
    @InvocableMethod
    public static list<Id> assignLeads(List<Id> LeadIds){
        list<Id> opportunityIds = new list<Id>();
        map<String,Lead> mapEmailVsLead = new map<String, Lead>();
        map<String,Lead> mapPhoneVsLead = new map<String, Lead>();
        set<String> setDupLeadIds = new set<String>();
        Set<String> emails = new Set<String>();
        Set<String> phones = new Set<String>();
        List<Lead> listLead = [select id, Email,Phone,Affiliate_Id__c from Lead where Id IN: LeadIds];
        for (Lead l : listLead) {
            if (l.Email != null) emails.add(l.Email.toLowerCase());
            if (l.Email != null) emails.add(l.Email);
            if (l.Phone != null) phones.add(l.Phone.replaceAll('[^0-9]', ''));
            if (l.Phone != null) phones.add(l.Phone);
        }
        
        // Query existing Leads with matching Email or Phone
        List<Lead> existingLeads = [SELECT Id, Email, Phone, Affiliate_Id__c FROM Lead WHERE (Email IN :emails OR Phone IN :phones) AND Id NOT IN : LeadIds];
        
        system.debug('existingLeads dup check: '+existingLeads);
            
        for(Lead objlead : existingLeads){
            mapEmailVsLead.put(objLead.Email, objLead);
            mapEmailVsLead.put(objLead.Email.toLowerCase(), objLead);
            mapPhoneVsLead.put(objLead.Phone, objLead);
            mapPhoneVsLead.put(objLead.Phone.replaceAll('[^0-9]', ''), objLead);
        }
        for (Lead lead : listLead) {
            if((lead.email != null && mapEmailVsLead.containsKey(lead.email)) || (lead.phone != null && mapPhoneVsLead.containsKey(lead.phone))){
                Decimal affiliateId = mapEmailVsLead.containsKey(lead.email) ? mapEmailVsLead.get(lead.email).Affiliate_Id__c : (mapPhoneVsLead.containsKey(lead.phone) ? mapPhoneVsLead.get(lead.phone).Affiliate_Id__c : 0);
                    if (lead.Affiliate_Id__c == affiliateId) {
                        // Same affiliate -> it's a duplicate
                        system.debug('setDupLeadIds add lead Id = '+lead.Id);
                        setDupLeadIds.add(lead.Id); 
                    }
            }
        }
        //LeadStatus cLeadStatus=[Select Id,MasterLabel from LeadStatus where isConverted=true limit 1];
        List<Database.LeadConvert> massLeadConvert=new List<Database.LeadConvert>();
        for(Id currentLead:LeadIds){
            if(!setDupLeadIds.contains(currentLead)){
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