global class BatchToUpdateAccTimezoneBasedOnAreaCode implements Database.Batchable<sObject> , Database.Stateful{
    global set<Id> setIds;
    public BatchToUpdateAccTimezoneBasedOnAreaCode(){
        setIds = new set<Id>();
    }
    public Database.QueryLocator start(Database.BatchableContext BC){
       String query = 'select id, Phone, timezone__c from Account where Phone != null and timezone__c = null';
       return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext BC, List<sObject> scope){
        set<Id> setSObjectIds = new set<Id>();
        setSObjectIds = UpdateTimeZoneBasedOnAreaCodeController.genericUpdateTimeZone(scope, null, 'Account', setIds);
        setIds.addAll(setSObjectIds);
    }
    public void finish(Database.BatchableContext BC){ 
        
    }
 }