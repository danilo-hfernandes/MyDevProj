public class SFXGoldMemberTry implements Database.Batchable<sObject>,schedulable{
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        
        String UseRoundRobin='FALSE';
        String originalSource='Vidanta';
        String PreferredLanguage='ENG';
        
        //date dt1=Date.newInstance(2020, 1, 1);
        //date dt2=Date.newInstance(2020, 4, 30);
        // New date range Added by Mitul 08/09/2022 - B-08576
		date dt1=Date.newInstance(2020, 4, 1); 
        date dt2=Date.newInstance(2020, 7, 31);
        
        system.debug('--dt1-'+dt1);
        system.debug('--dt2-'+dt2);
        //String query='SELECT Id,Name,Assign_to_Sales_Cadence__c,Match_Group_Name__c,leadassist__Use_Round_Robin__c FROM Contact where Account.Affiliated_id__c=1002275 and Account.enrollment_date__C>=:dt1 and Account.enrollment_date__C<=:dt2 AND  leadassist__Use_Round_Robin__c=\''+UseRoundRobin+'\' AND  Original_Source__c=\''+originalSource+'\' AND Assign_to_Sales_Cadence__c=FALSE ';
        // Query updated by Mitul - Added Preferred Language option  - 08/09/2022 - B-08576
        List<Contact> contactList = [SELECT Id,Name,Assign_to_Sales_Cadence__c,Match_Group_Name__c,leadassist__Use_Round_Robin__c FROM Contact where Account.Affiliated_id__c=1002275 and Account.enrollment_date__C>=:dt1 and Account.enrollment_date__C<=:dt2 AND  leadassist__Use_Round_Robin__c=:UseRoundRobin AND  Original_Source__c=:originalSource AND  Preferred_Language__c=:PreferredLanguage AND Assign_to_Sales_Cadence__c=FALSE];
        system.debug('--contactList-'+contactList);
        String query='SELECT Id,Name,Assign_to_Sales_Cadence__c,Match_Group_Name__c,leadassist__Use_Round_Robin__c FROM Contact where Account.Affiliated_id__c=1002275 and Account.enrollment_date__C>=:dt1 and Account.enrollment_date__C<=:dt2 AND  leadassist__Use_Round_Robin__c=\''+UseRoundRobin+'\' AND  Original_Source__c=\''+originalSource+'\' AND  Preferred_Language__c=\''+PreferredLanguage+'\' AND Assign_to_Sales_Cadence__c=FALSE ';
        system.debug('11='+query);
        //return contactList;
        //return Database.getQueryLocator(query);
        return Database.getQueryLocator([SELECT Id,Name,Assign_to_Sales_Cadence__c,Match_Group_Name__c,leadassist__Use_Round_Robin__c FROM Contact where leadassist__Use_Round_Robin__c=:UseRoundRobin AND  Original_Source__c=:originalSource AND  Preferred_Language__c=:PreferredLanguage AND Assign_to_Sales_Cadence__c=FALSE limit 5]);
    }
    public void execute(Database.BatchableContext bc, List<Contact> scope) {
        
        System.debug('16--'+scope.size());
        
        Set<ID> cadenceLeadsId=new set<Id>();
        List<Contact> ContactToUpdate=new List<Contact>();
        
        List<Contact> leadList=new list<Contact>();
        for(Contact l : scope)
        {
            l.leadassist__Use_Round_Robin__c='TRUE';
            l.Assign_to_Sales_Cadence__c=true;
            l.Match_Group_Name__c='SFX Gold';
            ContactToUpdate.add(l);
            cadenceLeadsId.add(l.id);
        }        
        
        if(ContactToUpdate.size() > 0 ){
            System.debug('32--'+ContactToUpdate);
            update ContactToUpdate;
        } 
        
        System.enqueueJob(new SFXGoldMemberQueueable(cadenceLeadsId)); 
    }
    public void finish(Database.BatchableContext bc) {
        //do something 
    }   
    
    public void execute(SchedulableContext SC) {
        database.executebatch(new SFXGoldMember(),1);
    }
}