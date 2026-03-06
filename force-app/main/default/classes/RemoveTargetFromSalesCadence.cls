public class RemoveTargetFromSalesCadence implements Database.Batchable<sObject>{
    public Database.QueryLocator start(Database.BatchableContext bc) {
        system.debug('3===');
        //String query = System.label.RemoveTargetFromSalesCadenceQuery;
		string query;
        if(Test.isRunningTest()){
            query='select id,name from contact';
        }
        else{
            list<String> cadenceIds=new list<String>{'77C3t000000XwNgEAK'};
            query = 'select Id, name, ActionCadence.Name,Assign_to_Sales_Cadence__c,Match_Group_Name__c,Cadence_Flag__c,ActionCadenceId, AffiliatedId__c, Account.Affiliated_Id__c  from contact where ActionCadenceId != null and ActionCadenceId IN : cadenceIds';
            //query = 'select id, Status, OwnerId,leadassist__Use_Round_Robin__c,Assign_to_Sales_Cadence__c,First_Action_Cadence_Id__c from Lead where ActionCadenceId IN : cadenceIds';  
                system.debug('Contact query=== '+query);
        }return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext bc, List<Contact> scope) {
        List<Lead> updateLead = new List<Lead>();
        system.debug('Contact records=== '+scope);
        List<Contact> ContactToUpdate=new List<Contact>();
        List<Contact> notParentContacts=new List<Contact>();
        Set<Id> targetsToRemove= new Set<Id>();
        /*for(Lead objLead : scope){
            objLead.leadassist__Use_Round_Robin__c = 'FALSE';
            objLead.Assign_to_Sales_Cadence__c= true;
            objLead.First_Action_Cadence_Id__c='null';
            updateLead.add(objLead);
            targetsToRemove.add(objLead.Id);
        }
        if(updateLead != null && updateLead.size() > 0){
            update updateLead;
        }*/
        if(scope.size()>0){
            for (Contact contact : scope) {
                    notParentContacts.add(contact);
            }
        }
        if(notParentContacts.size()>0){
            for (Contact objcon : notParentContacts) {
                objcon.Assign_to_Sales_Cadence__c = False;
                objcon.Match_Group_Name__c = '';
                objcon.Cadence_Flag__c = 0;
                ContactToUpdate.add(objcon);
                targetsToRemove.add(objcon.id);
            }
        }
        if(ContactToUpdate.size()>0){
            system.debug('26='+ContactToUpdate.size());
            system.debug('27='+ContactToUpdate);
            ContactToUpdate =  GenericMatchGroupAssignmentHandler.removeMatchGroup(ContactToUpdate);
            update ContactToUpdate;
        }
        system.debug('targetsToRemove== '+targetsToRemove);
        system.debug('targetsToRemove size== '+targetsToRemove.size());
        System.enqueueJob(new RemoveTargetFromSalesCadenceQueueable(targetsToRemove)); 
    }
    public void finish(Database.BatchableContext bc) {
        //do something 
    }   
}