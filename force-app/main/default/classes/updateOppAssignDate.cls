public class updateOppAssignDate {/*implements Database.Batchable<sObject>{
   public Database.QueryLocator start(Database.BatchableContext bc) {
        system.debug('3===');
        //String MatchId='a1G4z00000Ff8uzEAB';
        String MatchId = System.Label.Count_ChangingAssignee;
        String query;
        //String affiliate='Holidays Lounge';
        //String query='select id,Cadence_Flag__c,Assign_to_Sales_Cadence__c,leadassist__Use_Round_Robin__c from contact where (Affiliate_name__c like \'%' + affiliate + '%\'  OR Account.Affiliate_name__c like \'%' + affiliate + '%\' )' +(Test.isRunningTest()?' limit 20':'');
        //String query = 'select id,name,match_group_name__c,Active_Advantage_Match_Group__c,actioncadenceid from contact where  match_group_name__c=\''+MatchRule+'\' and Active_Advantage_Match_Group__c!=null' +(Test.isRunningTest()?' limit 20':'');
        if(Test.isRunningTest()){
            query = 'SELECT leadassist__MatchGroup__c, Id, Name,leadassist__Record_Id__c, CreatedDate, leadassist__Record_Name__c, leadassist__Time_Assigned__c FROM leadassist__MatchLog__c '+(Test.isRunningTest()?' limit 20':'');
        }
        else{
            query = 'SELECT leadassist__MatchGroup__c, Id, Name,leadassist__Record_Id__c, CreatedDate, leadassist__Record_Name__c, leadassist__Time_Assigned__c FROM leadassist__MatchLog__c where leadassist__MatchGroup__c=\''+MatchId+'\''+(Test.isRunningTest()?' limit 20':'');
        }return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext bc, List<leadassist__MatchLog__c> scope) {        
        system.debug('4='+scope.size());
        map<id,leadassist__MatchLog__c> Mli=new map<id,leadassist__MatchLog__c>();
        for(leadassist__MatchLog__c l:scope){
            if(!Mli.keyset().contains(l.leadassist__Record_Id__c)){
                Mli.put(l.leadassist__Record_Id__c,l);
            }   
        }
        list<Opportunity> oppList=new list<Opportunity>();
        list<Opportunity> updateOpp= new list<Opportunity>();
        oppList=[select id,name,Opp_Assign_Date__c from opportunity where id IN: Mli.keyset() ];
        system.debug('21='+oppList.size());
        for(Opportunity o:oppList){
            DateTime dT =Mli.get(o.id).CreatedDate;
            Date myDate = date.newinstance(dT.year(), dT.month(), dT.day());
            o.Opp_Assign_Date__c=myDate;
            updateOpp.add(o);
        }
        system.debug('32='+updateOpp.size());
        update updateOpp;   
    }
    public void finish(Database.BatchableContext bc) {
        //do something 
    }  */   
}