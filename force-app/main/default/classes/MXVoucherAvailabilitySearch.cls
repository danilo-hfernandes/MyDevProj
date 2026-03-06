public class MXVoucherAvailabilitySearch {
    
     @AuraEnabled
    public static List<MX_Voucher_Product__c> getProductDetails(){
        List<String> excludeProduct = new List<String>{'MX Voucher 5/4', 'MX Voucher 8/7'};
        List<MX_Voucher_Product__c> MXVoucherAvailabilityList = new List<MX_Voucher_Product__c>();
        String InventoryQuery = 'Select id ,Product_Name__c,Input_Price__c,Location__c,Minimal_Price__c,Room_Size__c,Section_Name__c,Suggested_Price__c from MX_Voucher_Product__c where  Product_Name__c != null and Product_Name__c NOT IN :excludeProduct';
        
        MXVoucherAvailabilityList = Database.query(InventoryQuery); 
        system.debug('--MXVoucherAvailabilityList--'+MXVoucherAvailabilityList.size());
        return MXVoucherAvailabilityList;
    }
    
    @AuraEnabled
    public static List<MX_Voucher_Product__c> getAvailabity(String productName){
        
        List<MX_Voucher_Product__c> MXVoucherAvailabilityList = new List<MX_Voucher_Product__c>();
        String InventoryQuery = 'Select id ,Input_Price__c,Location__c,Minimal_Price__c,Room_Size__c,Section_Name__c,Suggested_Price__c from MX_Voucher_Product__c where  Product_Name__c =: productName';
        
        MXVoucherAvailabilityList = Database.query(InventoryQuery); 
        system.debug('--MXVoucherAvailabilityList--'+MXVoucherAvailabilityList.size());
        return MXVoucherAvailabilityList;
    }
    
    //2
    @AuraEnabled
    public static List<MX_Voucher_Product__c> getAllResortName(String LocationName, String productName){
        List<MX_Voucher_Product__c> MXVoucherAvailabilityList = new List<MX_Voucher_Product__c>();
        String InventoryQuery = 'Select id ,Input_Price__c,Location__c,Minimal_Price__c,Room_Size__c,Section_Name__c,Suggested_Price__c from MX_Voucher_Product__c';
        String QueryWhereCondition = '';
        if(LocationName != null){
            QueryWhereCondition = ' where  Location__c =: LocationName and Product_Name__c =: productName';
        }
        
        system.debug('---find query-'+InventoryQuery+QueryWhereCondition);
        MXVoucherAvailabilityList = Database.query(InventoryQuery+QueryWhereCondition); 
        system.debug('--MXVoucherAvailabilityList--'+MXVoucherAvailabilityList.size());
        return MXVoucherAvailabilityList;
    }
    
    //3
    @AuraEnabled
    public static List<MX_Voucher_Product__c> getroomSize(String LocationName,String SectionName, String productName){
        
        List<MX_Voucher_Product__c> MXVoucherAvailabilityList = new List<MX_Voucher_Product__c>();
        String VoucherQuery = 'Select id ,Input_Price__c,Location__c,Minimal_Price__c,Room_Size__c,Section_Name__c,Suggested_Price__c from MX_Voucher_Product__c ';
        String QueryWhereCondition = '';
        if(LocationName != null && SectionName != null){
            QueryWhereCondition = ' where  Location__c =: LocationName AND Section_Name__c =: SectionName and Product_Name__c =: productName' ;
        }
        
        
        system.debug('---find query-'+VoucherQuery+QueryWhereCondition);
        MXVoucherAvailabilityList = Database.query(VoucherQuery+QueryWhereCondition);  
        system.debug('--MXVoucherAvailabilityList--'+MXVoucherAvailabilityList.size());
        return MXVoucherAvailabilityList;
    }
    
    @AuraEnabled
    public static List<MX_Voucher_Product__c> getAllProgram(String resoertName,String PlazzaName,string roomType, String productName){
        List<MX_Voucher_Product__c> MXVoucherAvailabilityList = new List<MX_Voucher_Product__c>();
        String InventoryQuery = 'Select id ,Input_Price__c,Location__c,Minimal_Price__c,Room_Size__c,Section_Name__c,Suggested_Price__c from MX_Voucher_Product__c ';
        String QueryWhereCondition = '';
        if(resoertName != null && PlazzaName != null){
            QueryWhereCondition = 'where  Location__c =: PlazzaName and Section_Name__c =: resoertName and Room_Size__c =: roomType and Product_Name__c =: productName';
        }
        
        system.debug('---find query-'+InventoryQuery+QueryWhereCondition);
        MXVoucherAvailabilityList = Database.query(InventoryQuery+QueryWhereCondition); 
        system.debug('--MXVoucherAvailabilityList--'+MXVoucherAvailabilityList.size());
        return MXVoucherAvailabilityList;
        
    }
    
    public class CustomSelectOption {
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String value;
        @AuraEnabled
        public Boolean selected;
        @AuraEnabled
        public String recordId;
        
        public CustomSelectOption(String label, String value) {
            this.label = label;
            this.value = value;
            this.selected = false;
            this.recordId = '';
        }
        public CustomSelectOption(String label, String value, Boolean selected) {
            this.label = label;
            this.value = value;
            this.selected = selected;
            this.recordId = '';
        }
        public CustomSelectOption(String label, String value, String recordId) {
            this.label = label;
            this.value = value;
            this.selected = false;
            this.recordId = recordId;
        }
        
   
}
}