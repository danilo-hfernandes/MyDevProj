trigger contactUpdateTrigger on Contact (before insert,before update, After Update, After Insert) {
 Apex_Trigger_On_Off__c cs = Apex_Trigger_On_Off__c.getValues('contactTrigger');
    if(cs != null && cs.isEnable__c){
        if(trigger.isbefore) {
            contactTriggerHandler.updateMembershipProdconfig(trigger.new);
        }
        
        if(trigger.isBefore) {
            System.debug('Test');
        }
        
        if(trigger.isAfter){
            set<String> affiliateName = new set<String>();
            set<String> accountId = new set<String>();
            MAP<String,String> accountMap = new MAP<String,String>();
            List<Contact> contactList = new List<Contact>();
            List<Account> accountList = new List<Account>();
            List<Account> updatedAccounts = new List<Account>();
            List<Contact> updatedContacts = new List<Contact>();
            Set<Id> conSet = new Set<Id>();
            List<Account> accList = new List<Account>();
            List<Contact> conList = new List<Contact>();
            MAP<String,String> accMap = new MAP<String,String>();
            List<Account> aUpdate = new List<Account>();
            set<String> accId = new Set<String>();
            
            
            for(Contact con : trigger.new) {
                conSet.add(con.Id);
                System.debug('conset ' + conSet);
            }
            contactList = [Select Id, Name, AccountId, Membership_Product_Configuration__c, Parent_Id_Ext_Db__c, updated__c FROM Contact WHERE Parent_Id_Ext_Db__c = null AND updated__c = false AND Membership_Product_Configuration__c != null AND Id IN :conSet];
            
            for(Contact c : contactList) {
                c.updated__c = true;
                updatedContacts.add(c);
                accountId.add(c.AccountId);
                accountMap.put(c.AccountId, c.Membership_Product_Configuration__c);
            }
            
            accountList = [Select Id, Name FROM Account WHERE Id IN :accountId];
            
            for(Account a : accountList) {
                a.Membership_Product_Configuration__c = accountMap.get(a.Id);
                updatedAccounts.add(a);
            }
            update updatedAccounts;
            update updatedContacts;
            
            conList = [Select Id, AccountId, Parent_Id_Ext_Db__c FROM Contact WHERE Parent_Id_Ext_Db__c = null AND Id IN :conSet];
            System.debug('conList ' + conList);
            
            for(Contact con : conList) {
                accId.add(con.AccountId);
                accMap.put(con.Accountid, con.id);
                System.debug('accMap ' + accMap);
            }
            
            accList = [Select Id, Parent_Child_Contact_Id__c FROM Account WHERE Id IN :accId];
            System.debug('accList ' + accList);
            
            for(Account acc : accList) {
                if(acc.Parent_Child_Contact_Id__c == null || acc.Parent_Child_Contact_Id__c != '') {
                acc.Parent_Child_Contact_Id__c = accMap.get(acc.id);
                aUpdate.add(acc);
                }
            }
            update aUpdate;      
             
        }
    } 
}