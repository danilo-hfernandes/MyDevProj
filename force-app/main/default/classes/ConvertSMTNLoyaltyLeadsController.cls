public class ConvertSMTNLoyaltyLeadsController {
    public static void convertLead(List<Lead> leadList){
        system.debug('>>>>LeadList>>>'+leadList);
        //LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        for(Lead myLead : leadList){
            Database.LeadConvert lc = new Database.LeadConvert();
            lc.setLeadId(myLead.id);
            lc.setConvertedStatus('Closed Won');
            Database.LeadConvertResult lcr = Database.convertLead(lc);
            System.debug(lcr.isSuccess());
            Opportunity opp = new Opportunity();
            opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Membership_Upgrade').getRecordTypeId();
            opp.Id = lcr.getOpportunityId();
            opp.CloseDate = date.today().addDays(15);
            opp.StageName = 'New';
            update opp;
        }
    }
}