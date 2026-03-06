public class InventoryManager {
    
    //input parameters: Map<String, Date> inputMap
	//Map<Unique_key_for_product_Id__c,Opportunity Check-Out Date> inputMap
    //Unique_key_for_product_Id__c = formula field = TEXT(Plaza__c)+'-'+Resort_Name__c+'-'+TEXT(Unit_Type__c)+'-'+TEXT(Check_In_Date__c)+'-'+Program__c
    
    // Main method to manage inventory adjustments
    public static void subtractInventoryAvailability(Map<String, Date> inputMap){
        Map<String, List<Inventory_Availability__c>> inventoryMap = generateInventoryMap(inputMap);
        for (String key : inventoryMap.keySet()) {
            List<Inventory_Availability__c> inventoryList = inventoryMap.get(key);
            for (Inventory_Availability__c inventory : inventoryList) {                
                inventory.New_Availability__c -= 1;                
            }
            if (!inventoryList.isEmpty()) {
                update inventoryList;
            }
        }        
        
    }

    public static void addInventoryAvailability(Map<String, Date> inputMap){
        system.debug('addInventoryAvailability entered');
        Map<String, List<Inventory_Availability__c>> inventoryMap = generateInventoryMap(inputMap);        
        for (String key : inventoryMap.keySet()) {
            List<Inventory_Availability__c> inventoryList = inventoryMap.get(key);
            for (Inventory_Availability__c inventory : inventoryList) {
                //for the first (main) inventory in the range, identified in the field Opportunity.Inventory_Availability_Id__c - it's already handled in the OpportunityTrigger_New
                if(inputMap.get(inventory.Unique_key_for_product_Id__c) == null){
                    inventory.New_Availability__c += 1;
                }
            }            
            if (!inventoryList.isEmpty()) {
                system.debug('inventoryList inventory.New_Availability__c += 1 entered');
                update inventoryList;
            }
        }
    }

    public static Map<String, Boolean> checkInventoryAvailability(Map<String, Date> inputMap) {
        Map<String, List<Inventory_Availability__c>> inventoryMap = generateInventoryMap(inputMap);
        Map<String, Boolean> availabilityStatus = new Map<String, Boolean>();
        for (String key : inventoryMap.keySet()) {
            List<Inventory_Availability__c> inventoryList = inventoryMap.get(key);
            Boolean allAvailable = true;
            for (Inventory_Availability__c inventory : inventoryList) {
                if (inventory.New_Availability__c <= 0) {
                    allAvailable = false;
                    break;
                }
            }
            availabilityStatus.put(key, allAvailable);
        }        
        return availabilityStatus;
    }

    // Method to generate Inventory map based on input keys and date range
    private static Map<String, List<Inventory_Availability__c>> generateInventoryMap(Map<String, Date> inputMap) {
        Map<String, List<Inventory_Availability__c>> inventoryMap = new Map<String, List<Inventory_Availability__c>>();
        List<String> keysToQuery = new List<String>();

        // Collect all keys based on the inputMap
        for (String key : inputMap.keySet()) {
            Date checkOutDate = inputMap.get(key);
            String checkInDateStr = extractCheckInDate(key);
            Date checkInDate = Date.valueOf(checkInDateStr);
            
            if (checkInDate != null && checkOutDate != null) {
                for (Date currentDate = checkInDate; currentDate <= checkOutDate; currentDate = currentDate.addDays(1)) {
                    // Generate the new key directly by replacing the check-in date with currentDate
                    String newKey = key.replace(checkInDateStr, String.valueOf(currentDate));
                    keysToQuery.add(newKey);
                }
            }
        }

        // Perform a single SOQL query after collecting all keys
        if (!keysToQuery.isEmpty()) {
            List<Inventory_Availability__c> inventoryRecords = [SELECT Id, Unique_Key_for_Product_Id__c, New_Availability__c 
                                                                FROM Inventory_Availability__c 
                                                                WHERE Unique_Key_for_Product_Id__c IN :keysToQuery];

            // Map the fetched inventory records to their respective original keys
            for (String key : inputMap.keySet()) {
                Date checkOutDate = inputMap.get(key);
                String checkInDateStr = extractCheckInDate(key);
                Date checkInDate = Date.valueOf(checkInDateStr);
                List<Inventory_Availability__c> rangeInventory = new List<Inventory_Availability__c>();

                for (Date currentDate = checkInDate; currentDate <= checkOutDate; currentDate = currentDate.addDays(1)) {
                    String newKey = key.replace(checkInDateStr, String.valueOf(currentDate));
                    for (Inventory_Availability__c inventory : inventoryRecords) {
                        if (inventory.Unique_Key_for_Product_Id__c == newKey) {
                            rangeInventory.add(inventory);
                        }
                    }
                }

                inventoryMap.put(key, rangeInventory); // Map the original key to its corresponding inventory list
            }
        }
        return inventoryMap;
    }

    private static String extractCheckInDate(String key) {
        System.debug('extractCheckInDate key = ' + key);
        
        // Regular expression to match YYYY-MM-DD
        Pattern datePattern = Pattern.compile('(\\d{4})-(\\d{2})-(\\d{2})');
        Matcher matcher = datePattern.matcher(key);
        
        while (matcher.find()) {
            String potentialDate = matcher.group();
            try {
                Date validDate = Date.valueOf(potentialDate); // Validate if it's a date
                System.debug('Valid date found: ' + validDate);
                return potentialDate; // Return the first valid date found as String
            } catch (Exception e) {
                // Ignore and continue
            }
        }
        
        return null; // Return null if no date found
    }
}