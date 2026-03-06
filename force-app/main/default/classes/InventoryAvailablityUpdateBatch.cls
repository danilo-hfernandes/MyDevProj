global class InventoryAvailablityUpdateBatch implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id,Plaza__c,program__c,Resort_Name__c,New_Availability__c,Unit_Type__c,Check_In_Date__c,Name FROM Uploaded_Inventory_Availability__c where isMerged__c = false';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Uploaded_Inventory_Availability__c> uploadInventoryAvvList) {
        Map<String,Uploaded_Inventory_Availability__c> tempMapforInvAvil = new Map<String,Uploaded_Inventory_Availability__c>();
        
        Set<String> setUniqKey = new Set<String>();
        Set<String> setUniqKeyforProductId = new Set<String>();
        system.debug('--uploadInventoryAvvList--'+uploadInventoryAvvList.size());
        for(Uploaded_Inventory_Availability__c uIv : uploadInventoryAvvList){
            String uniqKey = uIv.Plaza__c+'-'+uIv.Resort_Name__c+'-'+uIv.Unit_Type__c+'-';
            String dateFormatString = 'yyyy-MM-dd';
            Date d = uIv.Check_In_Date__c;
            Datetime dt = Datetime.newInstance(d.year(), d.month(),d.day());
            String dateString = dt.format(dateFormatString);
            
            system.debug('--uniqKey---'+uniqKey);
            System.debug('--dateString---'+dateString); // 2016-02-29
            // To find the existing Inventory Availability based on uniqkey and date
            setUniqKey.add(uniqKey+dateString+'-'+uIv.program__c);
            // To find the existing Inventory Availability based on uniqkey and date and update the new value
            string st = uniqKey+dateString+'-'+uIv.program__c;
            system.debug('--st'+st);
            setUniqKey.add(uniqKey+dateString+'-'+uIv.program__c);
            tempMapforInvAvil.put(uniqKey+dateString+'-'+uIv.program__c,uIv);
            
        }
        List<Inventory_Availability__c> invAvaUpdateList = new List<Inventory_Availability__c>();
        Set<Id> uplInvAvaUpdateList = new Set<Id>();
        
        List<Inventory_Availability__c> invAvil = [select id,program__c,New_Availability__c,Unique_key_for_product_Id__c,Check_In_Date__c from Inventory_Availability__c where Unique_key_for_product_Id__c in :setUniqKey];
        for(Inventory_Availability__c inv: invAvil){
            system.debug('--inv.Unique_key_for_product_Id__c--'+inv.Unique_key_for_product_Id__c);
            if(tempMapforInvAvil.containsKey(inv.Unique_key_for_product_Id__c)){
               Uploaded_Inventory_Availability__c upInv = tempMapforInvAvil.get(inv.Unique_key_for_product_Id__c);
                inv.New_Availability__c = upInv.New_Availability__c;
                invAvaUpdateList.add(inv);
                 uplInvAvaUpdateList.add(upInv.Id);
            }
        }
        try{
            update invAvaUpdateList;
            List<Uploaded_Inventory_Availability__c> uList = [select id from Uploaded_Inventory_Availability__c where id IN : uplInvAvaUpdateList];
            List<Uploaded_Inventory_Availability__c> uListUpdate = new List<Uploaded_Inventory_Availability__c>();
            for(Uploaded_Inventory_Availability__c u : uList){
                u.isMerged__c = true;
                uListUpdate.add(u);
            }
            update uListUpdate;
            system.debug('--uplInvAvaUpdateList--'+uplInvAvaUpdateList.size());
        }catch(Exception e){
            system.debug('---e---'+e);
        }
        
    }   
    
    global void finish(Database.BatchableContext BC) {
         InventoryAvailablityCreateBatch b=new InventoryAvailablityCreateBatch();
     Id batchId = Database.executeBatch(b,100);
    }
}