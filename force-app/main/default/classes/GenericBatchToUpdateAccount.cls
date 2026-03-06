public class GenericBatchToUpdateAccount implements Database.Batchable<sObject>{
    public Database.QueryLocator start(Database.BatchableContext BC){
        String strCarefree = '%Carefree%';
        String query = 'SELECT Id,Hashed_Email__c,Hashed_Phone__c,Hashed_FirstName__c,Hashed_LastName__c,Email,Phone,FirstName, LastName FROM lead where RecordType.name like : strCarefree and (Hashed_Email__c = null OR Hashed_Phone__c = null OR Hashed_FirstName__c = null OR Hashed_LastName__c= null) limit 50000';
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext BC, List<Lead> scope){
        List<Lead> listLead = new List<Lead>(); 
        for (Lead l : scope) {
            if (String.isNotBlank(l.Email) && String.isBlank(l.Hashed_Email__c))
                l.Hashed_Email__c = EncodingUtil.base64Encode(Blob.valueOf(l.Email.trim()));
            
            if (String.isNotBlank(l.Phone) && String.isBlank(l.Hashed_Phone__c))
                l.Hashed_Phone__c = EncodingUtil.base64Encode(Blob.valueOf(l.Phone.trim()));
            
            if (String.isNotBlank(l.FirstName) && String.isBlank(l.Hashed_FirstName__c))
                l.Hashed_FirstName__c = EncodingUtil.base64Encode(Blob.valueOf(l.FirstName.trim()));
            
            if (String.isNotBlank(l.LastName) && String.isBlank(l.Hashed_LastName__c))
                l.Hashed_LastName__c = EncodingUtil.base64Encode(Blob.valueOf(l.LastName.trim()));
            listLead.add(l);
        }
        System.debug('>>listLead>>'+listLead);
        if(listLead != null && listLead.size() > 0){
            update listLead;
        }
    }
    public void finish(Database.BatchableContext BC){ 
    }
    
}
/**public class GenericBatchToUpdateAccount implements Database.Batchable<sObject> ,Schedulable{
public GenericBatchToUpdateAccount(){
}
public void execute(SchedulableContext SC) {
GenericBatchToUpdateAccount objBatch = new GenericBatchToUpdateAccount(); 
database.executebatch(objBatch, 200);
}
public Database.QueryLocator start(Database.BatchableContext BC){
String query = 'SELECT Id,AccountId, Account.Marketing_Email_opt_out__c,Marketing_Email_opt_out__c FROM Contact WHERE Marketing_Email_opt_out__c = true and Is_Main_Contact__c = true and Account.Marketing_Email_opt_out__c = false';
return Database.getQueryLocator(query);
}
public void execute(Database.BatchableContext BC, List<Contact> scope){
List<Account> listAccObject = new List<Account>();
for(Contact obj : scope){
if(!(obj.Account.Marketing_Email_opt_out__c)){
Account acc = new Account();
acc.Id = obj.AccountId;
acc.Marketing_Email_opt_out__c = true;
listAccObject.add(acc);
}
}
system.debug('>>>>listAccObject>>>'+listAccObject);
if(listAccObject != null && listAccObject.size() > 0){
update listAccObject;
}
}
public void finish(Database.BatchableContext BC){ 
}
}**/


/** Timeshare Owner Update Logic 
public class GenericBatchToUpdateAccount implements Database.Batchable<sObject> ,Schedulable{
public map<String,String> mapMemberConfigIdvsFlag = new map<String,String>();
public GenericBatchToUpdateAccount(){
List<Timeshare_Owner_Flag__c>  listTimeshareOwnerFlag = [select id, Name, Timeshare_Owner__c from Timeshare_Owner_Flag__c];
if(listTimeshareOwnerFlag.size() > 0){
for(Timeshare_Owner_Flag__c objtimeshare : listTimeshareOwnerFlag){
mapMemberConfigIdvsFlag.put(objtimeshare.Name, objtimeshare.Timeshare_Owner__c);
}
}
}
public void execute(SchedulableContext SC) {
GenericBatchToUpdateAccount objBatch = new GenericBatchToUpdateAccount(); 
database.executebatch(objBatch, 1);
}
public Database.QueryLocator start(Database.BatchableContext BC){
// Retrieve the key set from the map
Set<String> keys = new set<String>{'A1002421','A1002256','A1002266','A1002225','A1002258','A1002426','A1002427','A1002195','A1002432','S1228','U1231','U1347','U1378','U1302','U1314','U1298','U1285','U1318','U1359','U1296','U1385','U1317','U1341','U1308','U1343','U1291','U1297','U1303','U1141','U1123','U1142','U1143','U1140','U1122','A1002254','A1002275','A1002219','A1002241','A1002274','A1002185','A1002023','A1002088','A1002030','A1002229','A1002359','A1002261','A1002336','A1002348','A1002335','A1002351','U986','U432','U257','U534','U984','U119','U426','U681','U895','A1001087'};//mapMemberConfigIdvsFlag.keySet();
// Construct the dynamic SOQL query
String query = 'SELECT Id, MembershipProductConfigId_Formula__c, Timeshare_Owner__c FROM Account WHERE MembershipProductConfigId_Formula__c IN :keys';

return Database.getQueryLocator(query);
}
public void execute(Database.BatchableContext BC, List<Account> scope){
List<Account> listAcc = new List<Account>();
for(Account objacc : scope){
if(objacc.MembershipProductConfigId_Formula__c != null && mapMemberConfigIdvsFlag != null && mapMemberConfigIdvsFlag.containsKey(objacc.MembershipProductConfigId_Formula__c) && objacc.Timeshare_Owner__c != mapMemberConfigIdvsFlag.get(objacc.MembershipProductConfigId_Formula__c)){
Account acc = new Account();
acc.Id = objacc.Id;
acc.Timeshare_Owner__c = mapMemberConfigIdvsFlag.get(objacc.MembershipProductConfigId_Formula__c);
listAcc.add(acc);
}
}
system.debug('>>>>listAcc>>>'+listAcc);
if(listAcc != null && listAcc.size() > 0){
update listAcc;
}
}
public void finish(Database.BatchableContext BC){ 

}
}
*/