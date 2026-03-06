public class CustomAddProductsController {
    
    @AuraEnabled
    public static Map<String,Boolean> checkOppLineItemCreatePermission(){
        Map<String,Boolean> accessMap = new Map<String,Boolean>();
        
        Boolean hasCreateAccess = Schema.sObjectType.OpportunityLineItem.isCreateable();
        
        if(hasCreateAccess)
        {
            accessMap.put('true',true);
        }
        else
        {
            accessMap.put('true',false);
        }        
       
        return accessMap;
    }
    
    @AuraEnabled
    public static Map<String,List<PriceBookEntry>> fetchPriceBookEntries(String oppId) {
        Map<String,List<PriceBookEntry>> pbeMap = new Map<String,List<PriceBookEntry>>();
        List<PriceBookEntry> priceBookEntries = new List<PriceBookEntry>();
        
        List<String> fieldNames = new List<String>();
        
        // Retrieve the fields from the Custom_Add_Products_List field set
        /*for (Schema.FieldSetMember field : Schema.SObjectType.PriceBookEntry.FieldSets.Custom_Add_Products_List.getFields()) {
            fieldNames.add(field.getFieldPath());
        }*/
        Id currentUserId = UserInfo.getUserId();
        String oppRecordTypeName = [SELECT RecordType.Name FROM Opportunity WHERE Id =: oppId].RecordType.Name;
        
        User currentUser = [SELECT Id,UserRoleId,UserRole.Name,ProfileId,Profile.Name FROM User WHERE Id =: currentUserId];
        String currentUserRole = 'currentUserRole';
        String currentUserProfile = 'currentUserProfile';
        
        if(currentUser.UserRoleId != null)
        {
            currentUserRole = currentUser.UserRole.Name;            
        }
        if(currentUser.ProfileId != null)
        {
            currentUserProfile = currentUser.Profile.Name;            
        }
        
        String soqlQuery = '';
                
        String queryFields = 'Id, Name, Product2.File_Fee_Percentage__c, Product2.Flat_File_Fee__c, Product2.Flat_File_Fee_Amount__c, ProductCode, UnitPrice, Product2.Description, Product2.Family, Product2Id, Product2.Profiles_Enabled__c, Product2.Roles_Enabled__c, Product2.Qualifications__c,Product2.Opportunity_Record_Types_Enabled__c' + String.join(new List<String>(fieldNames), ', ');
        //Incentive products visible only for system admin in this custom button
        if(currentUser.Profile.Name != 'System Administrator'){
            soqlQuery = 'SELECT ' + queryFields + ' FROM PriceBookEntry WHERE Product2.Product_Type__c != \'Incentive\' AND Product2.Opportunity_Record_Types_Enabled__c INCLUDES (\''+oppRecordTypeName+'\') AND (Product2.Roles_Enabled__c INCLUDES (\''+currentUserRole+'\') OR Product2.Profiles_Enabled__c INCLUDES (\''+currentUserProfile+'\')) AND IsActive = true ORDER BY Name';
        }
        else
        {
            soqlQuery = 'SELECT ' + queryFields + ' FROM PriceBookEntry WHERE Product2.Opportunity_Record_Types_Enabled__c INCLUDES (\''+oppRecordTypeName+'\') AND (Product2.Roles_Enabled__c INCLUDES (\''+currentUserRole+'\') OR Product2.Profiles_Enabled__c INCLUDES (\''+currentUserProfile+'\')) AND IsActive = true ORDER BY Name';            
        }
        System.debug('soqlQuery = '+soqlQuery);
        // Execute the dynamic SOQL query using Database.query
        priceBookEntries = (List<PriceBookEntry>)Database.query(soqlQuery);
        
        pbeMap.put('true',priceBookEntries);
        return pbeMap;
    }
    
    @AuraEnabled
    public static Map<String,List<OpportunityLineItem>> generateOppLineItems(List<PriceBookEntry> pbeList, String oppId){        
        Map<String,List<OpportunityLineItem>> oliMap = new Map<String,List<OpportunityLineItem>>();
        List<OpportunityLineItem> oppLineItems = new List<OpportunityLineItem>();
        for (PriceBookEntry pbe : pbeList) {
            OpportunityLineItem oli = new OpportunityLineItem();            
            oli.OpportunityId = oppId;
            oli.Product2Id = pbe.Product2Id;            
            oli.PricebookEntryId = pbe.Id;
            oli.UnitPrice = pbe.UnitPrice;
            oli.Price_Book_Entry_Name__c = pbe.name;
            oli.Quantity = 1;
            // Added based on new calculation File fee
            oli.File_Fee_Percentage__c = pbe.Product2.File_Fee_Percentage__c;
            oli.Flat_File_Fee__c = pbe.Product2.Flat_File_Fee__c;
            oli.Flat_File_Fee_Amount__c = pbe.Product2.Flat_File_Fee_Amount__c;
            // Set other desired fields from PriceBookEntry or related objects            
            oppLineItems.add(oli);
        }
        oliMap.put('true',oppLineItems);
        return oliMap;
    }

    @AuraEnabled
    public static Map<String,String> saveOppLineItems(List<OpportunityLineItem> oliList){        
        Map<String,String> oliMap = new Map<String,String>();
        try {
            insert oliList;
            oliMap.put('true', 'true');
        } catch (Exception ex) {            
            oliMap.put('false', ex.getMessage());
        }
        return oliMap;
    }
}