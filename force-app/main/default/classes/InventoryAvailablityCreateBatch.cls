global class InventoryAvailablityCreateBatch implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id,Program__c,Plaza__c,Available_Weeks__c,Week__c,Year__c,Unique_key_for_without_Checkin_Date__c,Resort_Name__c,isMerged__c,New_Availability__c,Unit_Type__c,Check_In_Date__c,Name FROM Uploaded_Inventory_Availability__c where isMerged__c = false';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Uploaded_Inventory_Availability__c> uploadInventoryAvvList) {
        List<Inventory_Availability__c> invCreateList = new List<Inventory_Availability__c>();
        
        Set<string> uniqkeyset = new set<String>();
        
        for(Uploaded_Inventory_Availability__c uIvtemp : uploadInventoryAvvList){
            uniqkeyset.add(uIvtemp.Unique_key_for_without_Checkin_Date__c);
        }
        List<Inventory_Management__c> invMangList = [select id,Unique_key_for_Product_Id__c from Inventory_Management__c where Unique_key_for_Product_Id__c in :uniqkeyset];
        Map<String,Id> keyAndIdMapping = new Map<String,Id>();
        for(Inventory_Management__c invMg : invMangList){
            keyAndIdMapping.put(invMg.Unique_key_for_Product_Id__c,invMg.Id);
        }
        Set<Id> uploadIdSet = new Set<Id>();
        for(Uploaded_Inventory_Availability__c uIv : uploadInventoryAvvList){
            
            Inventory_Availability__c inv = new Inventory_Availability__c();
            if(keyAndIdMapping.containskey(uIv.Unique_key_for_without_Checkin_Date__c)){
                inv.Inventory_Management__c = keyAndIdMapping.get(uIv.Unique_key_for_without_Checkin_Date__c);
                inv.Available_Weeks__c = uIv.Available_Weeks__c;
                inv.Check_In_Date__c = uIv.Check_In_Date__c;
                inv.New_Availability__c = uIv.New_Availability__c;
                inv.Plaza__c = uIv.Plaza__c;
                inv.Resort_Name__c = uIv.Resort_Name__c;
                inv.Unit_Type__c = uIv.Unit_Type__c;
                inv.Week__c = uIv.Week__c;
                inv.Year__c = uIv.Year__c;
                inv.Program__c = uIv.Program__c;
                invCreateList.add(inv);
                uIv.isMerged__c = true;
                uploadIdSet.add(uIv.Id);
            }
            
            
        }
        if(invCreateList != null && invCreateList.size() > 0){
            insert invCreateList;
             List<Uploaded_Inventory_Availability__c> uList = [select id from Uploaded_Inventory_Availability__c where id IN : uploadIdSet];
            List<Uploaded_Inventory_Availability__c> uListUpdate = new List<Uploaded_Inventory_Availability__c>();
            for(Uploaded_Inventory_Availability__c u : uList){
                u.isMerged__c = true;
                uListUpdate.add(u);
            }
            update uListUpdate;
            
         }
    }   
    
    global void finish(Database.BatchableContext BC) {
        //If we found any new record that need to be match with new Parent record as well and for that we have to map the product Id
        // To get the product Id and Parent Record (Inventory Management) mapping for the relationship to Inventory Management to Inventory Availability
        // setUniqKeyforProductId.add(uniqKey);
    }
}