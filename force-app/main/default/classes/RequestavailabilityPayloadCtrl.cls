public class RequestavailabilityPayloadCtrl {
	public string getAvailabilityPayload(List<Inventory_Availability__c> InventoryAvailabilityList){ 
        
        
    	String payload  = '';
        Integer invRecordCount = 1;	
        payload = '{"availabilities": [';
			for(Inventory_Availability__c inv : InventoryAvailabilityList){  
            	payLoad = payLoad + '{"Id": "'+inv.Id+'",'+
                    '"Plaza__c": "'+inv.Plaza__c+'",'+
                    '"Resort_Name__c": "'+inv.Resort_Name__c+'",'+
                    '"Site_Name__c": "'+inv.Site_Name__c+'",'+
                    '"Unit_Type__c": "'+inv.Unit_Type__c+'",'+
                    '"Check_In_Date__c": "'+inv.Check_In_Date__c+'",'+
                    '"New_Availability__c": '+inv.New_Availability__c+','+
                    '"Room_Type__c": "'+inv.Inventory_Management__r.Room_Type__c+'",'+
                    '"Capacity__c": "'+inv.Inventory_Management__r.Capacity__c+'",'+
                    '"Size_Upgrade__c": '+inv.Inventory_Management__r.Size_Upgrade__c+','+
                    '"Property_Upgrade__c": '+inv.Inventory_Management__r.Property_Upgrade__c+','+
                    '"Total_Upgrade__c": '+inv.Inventory_Management__r.Total_Upgrade__c+','+
                    
                    '}';
                if(InventoryAvailabilityList.size() != invRecordCount){
                    payLoad = payLoad + ',';
                }
                invRecordCount++;
            } 
            payLoad = payLoad +']}';
        
        return payLoad;
    }
}