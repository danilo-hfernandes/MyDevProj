public class ChangeTargetAssignee implements Database.Batchable<sObject>,Database.Stateful{
    
    Integer count=0;
    String nmber = System.Label.Count_ChangingAssignee;
            String ownerid = System.Label.PrevOwner_ChangingAssignee;
            String newOwner = System.Label.NewOwner_ChangingAssignee;
    public Database.QueryLocator start(Database.BatchableContext bc) {
        system.debug('3===');
        
        //String ownerid='0053t000009j8Z3AAI';
        String cadenceId='77C3t000000XwNgEAK';
        String query;
        // String query='SELECT Id, name,ActionCadenceAssigneeId,ownerid, ActionCadenceId FROM contact where actioncadenceid!=null' +(Test.isRunningTest()?' limit 20':'');
        if(Test.isRunningTest()){
        //query='SELECT Id, name,ActionCadenceAssigneeId,ownerid, ActionCadenceId FROM contact where actioncadenceid=\''+cadenceId+'\'' +(Test.isRunningTest()?' limit 20':'');
        query='SELECT Id, name,ActionCadenceAssigneeId,ownerid, ActionCadenceId FROM lead where actioncadenceid!=null' +(Test.isRunningTest()?' limit 20':'');
        }
        else{
            //query='SELECT Id, name,ActionCadenceAssigneeId,ownerid, ActionCadenceId FROM contact where ownerid=\''+ownerid+'\' and actioncadenceid=\''+cadenceId+'\'' +(Test.isRunningTest()?' limit 20':'');
            query='SELECT Id, name,ActionCadenceAssigneeId,ownerid, ActionCadenceId FROM lead where ActionCadenceAssigneeId=\''+ownerid+'\' and actioncadenceid!=null' +(Test.isRunningTest()?' limit 20':'');
        }
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<lead> scope) {
        List<lead> contactToUpdate=new List<lead>();
                Set<Id> targetsToChange= new Set<Id>();

                Integer n=integer.valueof(nmber);

         for(lead con: scope){
                    system.debug('47='+con);
            system.debug('47='+count);

            if(count<n){
                system.debug('51');
                count++;
                con.ownerid=newOwner;
                contactToUpdate.add(con);
                targetsToChange.add(con.id);
            }
            
        }
        system.debug('20=='+targetsToChange.size());
        update contactToUpdate;
        System.enqueueJob(new ChangeTargetAssigneeQueueable(targetsToChange)); 
        
    }
 /*   public void execute(Database.BatchableContext bc, List<Contact> scope) {
        List<Contact> contactToUpdate=new List<Contact>();
        List<Contact> mainContactList=new List<Contact>();
        
        List<id> contactToUse=new List<id>();
        Set<id> contactIdList=new Set<id>();
        Set<Id> targetsToChange= new Set<Id>();
        system.debug('29= new owner='+newOwner);
        system.debug('30=old owner'+ownerid);
        system.debug('31 number='+nmber);
        system.debug('31='+scope.size());
        
        for(contact con:scope){

                contactIdList.add(con.id);
            
        }
        
        system.debug('34='+contactIdList.size());
        list<ActionCadenceStepTracker> stepTracker= new lisT<ActionCadenceStepTracker>();
        
        stepTracker=[SELECT Id, StepTitle, StepType,targetid FROM ActionCadenceStepTracker where actioncadenceid='77C3t000000XwNgEAK' and targetid IN: contactIdList and StepTitle='Call 1 Active Advantage Program' and state='Active' ];
        
        for(ActionCadenceStepTracker acst:stepTracker ){
            
            contactToUse.add(acst.targetid);
        }
        
        system.debug('44='+contactToUse.size());
        Integer n=integer.valueof(nmber);
        system.debug('number='+n);
        for(Contact con: scope){
                    system.debug('47='+con);
            system.debug('47='+count);

            if(contactToUse.contains(con.id) && count<n){
                system.debug('51');
                count++;
                con.ownerid=newOwner;
                contactToUpdate.add(con);
                targetsToChange.add(con.id);
            }
            
        }
        system.debug('20=='+targetsToChange.size());
        update contactToUpdate;
        System.enqueueJob(new ChangeTargetAssigneeQueueable(targetsToChange)); 
    }*/
    public void finish(Database.BatchableContext bc) {
        
        system.debug('62='+count);
        //do something 
    }   
    
    
}