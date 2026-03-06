public class LinkedCaseTriggerHandler {
	//After Update
    public void afterUpdate(List<Linked_Case__c> newLinkedCase) {
        set<Id> setcaseIds = new set<Id>();
        for(Linked_Case__c obj : newLinkedCase){
            if(obj.Parent_Case__c != null){
                setcaseIds.add(obj.Parent_Case__c);
            }
        }
        if(setcaseIds != null && setcaseIds.size() > 0){
            DepositTriggerHandler.calculateMFPAmount(setcaseIds);
        }
    }
    //After Insert
    public void afterInsert(List<Linked_Case__c> newLinkedCase) {
        set<Id> setcaseIds = new set<Id>();
        for(Linked_Case__c obj : newLinkedCase){
            if(obj.Parent_Case__c != null){
                setcaseIds.add(obj.Parent_Case__c);
            }
        }
        if(setcaseIds != null && setcaseIds.size() > 0){
            DepositTriggerHandler.calculateMFPAmount(setcaseIds);
        }
    }
}