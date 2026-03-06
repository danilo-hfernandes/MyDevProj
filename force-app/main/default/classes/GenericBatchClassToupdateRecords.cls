public class GenericBatchClassToupdateRecords implements Database.Batchable<sObject> , Schedulable{
    public String ObjName;
    public GenericBatchClassToupdateRecords(String ObjectName){
        ObjName = ObjectName;
    }
    public void execute(SchedulableContext SC) {
        GenericBatchClassToupdateRecords objBatch1 = new GenericBatchClassToupdateRecords('Lead'); 
        database.executebatch(objBatch1, 1);
        GenericBatchClassToupdateRecords objBatch2 = new GenericBatchClassToupdateRecords('Account'); 
        database.executebatch(objBatch2, 1);
        GenericBatchClassToupdateRecords objBatch3 = new GenericBatchClassToupdateRecords('Contact'); 
        database.executebatch(objBatch3, 1);
    }
    public Database.QueryLocator start(Database.BatchableContext BC){
        String whereClause='';
        // Construct the dynamic SOQL query
        if(ObjName == 'Account'){
            whereClause = ' and Email_Opt_Out__c = true';
        }
        else {
            whereClause = ' and HasOptedOutOfEmail= true';
        }
        String query = 'SELECT Id, Marketing_Email_opt_out__c FROM '+ObjName+' WHERE Marketing_Email_opt_out__c= false'+whereClause;
        
        return Database.getQueryLocator(query);
    } 
    public void execute(Database.BatchableContext BC, List<SObject> scope){
        List<SObject> listSObject = new List<SObject>();
        for(SObject obj : scope){
            obj.put('Marketing_Email_opt_out__c',true);
            listSObject.add(obj);
        }
        system.debug('>>>>listSObject>>>'+listSObject);
        if(listSObject != null && listSObject.size() > 0){
            update listSObject;
        }
    }
    public void finish(Database.BatchableContext BC){ 
    }
}