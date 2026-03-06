public class TimeshareDetailsWithProduct {
    List<timeshareWrapper> listTimeshareWrapper = new List<timeshareWrapper>();
    /* wrapper class */  
    public class timeshareWrapper {
        @AuraEnabled  public Integer timeshareNumber{get;set;}
        @AuraEnabled  public string timeshareName{get;set;}
        @AuraEnabled  public string timeshareId{get;set;}
        @AuraEnabled  public string PreferredCompany{get;set;}
        @AuraEnabled  public decimal Mortgage{get;set;}
        @AuraEnabled  public boolean isAddExisting{get;set;}
        @AuraEnabled public String accountId{get;set;}
        @AuraEnabled public String productaddedId{get;set;}
        @AuraEnabled public String productaddedName{get;set;}
        @AuraEnabled  public boolean isMTRCProductExist{get;set;}
        @AuraEnabled public boolean disableAddButton{get;set;}
        //@AuraEnabled  public decimal timeshareMultiplier{get;set;}
        
    }
    public class productWrapper {
        @AuraEnabled public product2 prd { get; set; }
        @AuraEnabled public Boolean selected { get; set; }
        @AuraEnabled public decimal unitprice{get;set;}
        @AuraEnabled public decimal vendorDiscount{get;set;}
        @AuraEnabled public Opportunitylineitem oppLineItem { get; set; }
        @AuraEnabled public List<SelectOptions> ReasontoSellPicklist;
        @AuraEnabled public String ReasontoSellPickselectedValue{get;set;}
        @AuraEnabled public Decimal productMFMultiplier{get;set;}
        
    }
    public class SelectOptions{
        @AuraEnabled 
        public string label;
        @AuraEnabled 
        public string value;
        public selectOptions(String Idstr,String Name){
            this.label = Name;
            this.value = Idstr;
        }
    }
    
    // Comparator to sort productWrapper by a custom product name order
    public class ProductWrapperComparator implements System.Comparator<TimeshareDetailsWithProduct.productWrapper> {
        
        // Cannot be static inside a non-static inner class → so just make it an instance field
        private Map<String, Integer> orderMap = new Map<String, Integer>{
            'CV Sapphire' => 1,
                'Trade In Property' => 2,
                'Trade In Property With Mortgage' => 3
                };
                    /* SAS-64
                     ,
                '$1998 Resale Subscription - Title Fee Credit/Balance Paid by Seller at Closing' => 3,
                'Maintenance Fee Protection - Travel Cash' => 4
                      */
                    
                    public Integer compare(
                        TimeshareDetailsWithProduct.productWrapper a,
                        TimeshareDetailsWithProduct.productWrapper b
                    ) {
                        Integer oa = orderMap.containsKey(a.prd.Name) ? orderMap.get(a.prd.Name) : 999;
                        Integer ob = orderMap.containsKey(b.prd.Name) ? orderMap.get(b.prd.Name) : 999;
                        
                        // Same rank? Alphabetical fallback
                        if (oa == ob) {
                            String an = (a.prd != null && a.prd.Name != null) ? a.prd.Name : '';
                            String bn = (b.prd != null && b.prd.Name != null) ? b.prd.Name : '';
                            return an.compareTo(bn);
                        }
                        
                        return oa - ob;
                    }
    }


    
    
    @AuraEnabled
    public static string saveProductLineItem(List<productWrapper> proWrapperlist,Id OppId,Id timeshareId,Id productId, String timeshareNumber){
        List<PricebookEntry> pricebookList = [select id ,Product2.Family,Name,Pricebook2Id ,Product2Id,UnitPrice,Product2.Name from PricebookEntry where IsActive= true];
        List<Timeshare__c> timeshareList = [select id,MF_Amount__c,Opportunity__c,Opportunity__r.RecordType.DeveloperName,VIDA_File_Fee_Amount__c,Resort__c,Resort__r.MFP_Multiplier__c, Usage_Fee__c,Trade_In_Value__c,Listing_type__c, Listing_Price__c from Timeshare__c where Id =: timeshareId];

        List<Opportunity> oppList = [select id, Record_Type_Name__c, Account.BillingStreet, Account.BillingCity, Account.BillingState, Account.BillingCountry from Opportunity where Id =: OppId];
        
        for(productWrapper wrp : proWrapperlist){
            if(wrp.selected){
                Map<Id,Id> PriceBookId = new Map<Id,Id>();
                Map<Id,String> getProductFamily = new Map<Id,String>();
                Map<Id,String> getProductName = new Map<Id,String>();
                system.debug('--pricebookList---'+pricebookList);
                for(PricebookEntry ppe : pricebookList){
                    system.debug('ppe.Product2.Family'+ppe.Product2.Family);
                    PriceBookId.put(ppe.Product2Id,ppe.Id);
                    getProductFamily.put(ppe.Product2Id,ppe.Product2.Family);
                    getProductName.put(ppe.Product2Id,ppe.Product2.Name);
                }
                system.debug('--wrp.ReasontoSellPickselectedValue--'+getProductFamily);
                system.debug('--wrp.ReasontoSellPickselectedValue--'+getProductFamily.get(productId));
                /*if((wrp.ReasontoSellPickselectedValue == null || wrp.ReasontoSellPickselectedValue == '') && 
(getProductFamily.get(productId) != 'Equity Product') && (getProductFamily.get(productId) != 'Gold') &&
(getProductFamily.get(productId) != 'Platinum') && (getProductFamily.get(productId) != 'Silver'))
{
throw new AuraHandledException('Please select Reason to Sell');
}*/
                OpportunityLineItem oli = new OpportunityLineItem();
                oli.OpportunityId = oppId;
                oli.PricebookEntryId=PriceBookId.get(productId);
                oli.Timeshare__c = timeshareId;
                //oli.Timeshare_Picklist__c = 'Timeshare 1';
                oli.Reason_to_Sell__c = wrp.ReasontoSellPickselectedValue;
                if(wrp.vendorDiscount == null){
                    oli.Vendor_Discount__c = 0;
                }else{
                    oli.Vendor_Discount__c = wrp.vendorDiscount;
                }
                //2024-04-17 HSIMU2-687 Multiplier for MFP Products - 3 [mfpMultiplier]
                Decimal mfpMultiplier = null;
                if(timeshareList[0].Resort__c != null)
                {
                    if(timeshareList[0].Resort__r.MFP_Multiplier__c != null)
                    {
                        mfpMultiplier = timeshareList[0].Resort__r.MFP_Multiplier__c;
                    }
                }
                //2023-12-01 - HSIMU2-444 - min MFP for Membership_Add_On updated from 2 to 1.5 
                System.debug('>>>>>wrp.productMFMultiplier>>>>'+wrp.productMFMultiplier);
                if(wrp.productMFMultiplier == null && (getProductName.get(productId) == 'Sapphire Usage Match')){                    
                        throw new AuraHandledException('The Minimum Price for the Sapphire Usage Match product is: 2x Usage Fee.');
                }
                if(wrp.productMFMultiplier == null){
                    oli.Multiplier__c = null;
                    if((getProductName.get(productId) == 'Sapphire Usage Match' && mfpMultiplier == null)){
                        throw new AuraHandledException('Multiplier minimum number is 2');
                    }                    
                    else if((getProductName.get(productId) == 'Maintenance Fee Protection' && mfpMultiplier == null) && oppList[0].Record_Type_Name__c != 'Hawaii Collection Membership' && oppList[0].Record_Type_Name__c != 'SFX Membership' && oppList[0].Record_Type_Name__c != 'MTRC Retail' && oppList[0].Record_Type_Name__c != 'Membership Add-On'){
                        throw new AuraHandledException('Multiplier minimum number is 2');
                    }
                    else if((getProductName.get(productId) == 'Maintenance Fee Protection' && mfpMultiplier == null) && (oppList[0].Record_Type_Name__c == 'Hawaii Collection Membership' || oppList[0].Record_Type_Name__c == 'SFX Membership' || oppList[0].Record_Type_Name__c == 'MTRC Retail' || oppList[0].Record_Type_Name__c == 'Membership Add-On')){
                        throw new AuraHandledException('Multiplier minimum number is 1.5');
                    }
                    //HMR-601
                    else if((getProductName.get(productId) == 'HC Vida Collection Weeks Usage Fee TC Rebate' && mfpMultiplier == null) && (oppList[0].Record_Type_Name__c == 'Hawaii Collection Membership' || oppList[0].Record_Type_Name__c == 'Membership Add-On')){
                        throw new AuraHandledException('Multiplier minimum number is 1.5');
                    }
                    else if((getProductName.get(productId) == 'Vida Reserve Week Rebate' && mfpMultiplier == null) && (oppList[0].Record_Type_Name__c == 'Reserve Collection Membership' || oppList[0].Record_Type_Name__c == 'Membership Add-On')){
                        throw new AuraHandledException('Multiplier minimum number is 1.5');
                    }
                    else if(getProductName.get(productId) == 'Maintenance Fee Protection' && mfpMultiplier != null){
                        throw new AuraHandledException('Multiplier minimum number is '+String.valueOf(mfpMultiplier));
                    }                    
                }else{
                    if(wrp.productMFMultiplier < 2.0 && (getProductName.get(productId) == 'Sapphire Usage Match' && mfpMultiplier == null)){
                        throw new AuraHandledException('Multiplier minimum number is 2.0');
                    }                    
                    else if(wrp.productMFMultiplier < 1.5 && (getProductName.get(productId) == 'Maintenance Fee Protection' && mfpMultiplier == null) && (oppList[0].Record_Type_Name__c == 'Hawaii Collection Membership' || oppList[0].Record_Type_Name__c == 'SFX Membership' || oppList[0].Record_Type_Name__c == 'MTRC Retail' || oppList[0].Record_Type_Name__c == 'Membership Add-On')){
                        throw new AuraHandledException('Multiplier minimum number is 1.5');
                    }
                    //HMR-601
                    else if(wrp.productMFMultiplier < 1.5 && (getProductName.get(productId) == 'HC Vida Collection Weeks Usage Fee TC Rebate') && (oppList[0].Record_Type_Name__c == 'Hawaii Collection Membership' || oppList[0].Record_Type_Name__c == 'Membership Add-On')){
                        throw new AuraHandledException('Multiplier minimum number is 1.5');
                    }
                    else if(wrp.productMFMultiplier < 1.5 && (getProductName.get(productId) == 'Vida Reserve Week Rebate') && (oppList[0].Record_Type_Name__c == 'Reserve Collection Membership' || oppList[0].Record_Type_Name__c == 'Membership Add-On')){
                        throw new AuraHandledException('Multiplier minimum number is 1.5');
                    }
                    else if((getProductName.get(productId) == 'Maintenance Fee Protection' && mfpMultiplier != null) && (oppList[0].Record_Type_Name__c == 'Hawaii Collection Membership' || oppList[0].Record_Type_Name__c == 'SFX Membership' || oppList[0].Record_Type_Name__c == 'MTRC Retail' || oppList[0].Record_Type_Name__c == 'Membership Add-On')){
                        
                        if(wrp.productMFMultiplier < mfpMultiplier){
                            throw new AuraHandledException('Multiplier minimum number is '+String.valueOf(mfpMultiplier));
                        }
                        
                    }
                    oli.Multiplier__c = wrp.productMFMultiplier;
                }
                if(getProductFamily.get(productId) == 'Equity Product'){
                    oli.Retail_Price__c = 0;
                    oli.Equity_value__c = wrp.unitprice;
                }
                /*else if(getProductName.get(productId) == 'Sapphire Usage Match' && wrp.productMFMultiplier != null && timeshareList.size()>0 && timeshareList != null)
                {
                    system.debug('wrp.productMFMultiplier'+wrp.productMFMultiplier);
                    system.debug('timeshareList[0].MF_Amount__c'+timeshareList[0].MF_Amount__c);
                    oli.Retail_Price__c = wrp.productMFMultiplier * timeshareList[0].MF_Amount__c;
                }*/
                //logic added B-09353 - Enable MFP Multiplier default to 2 for MTRC Retail, MTRC, Hawaii collection, and SFX
                else if(getProductName.get(productId) == 'Maintenance Fee Protection' && wrp.productMFMultiplier != null && timeshareList.size()>0 && timeshareList != null)
                {
                    system.debug('wrp.productMFMultiplier'+wrp.productMFMultiplier);
                    system.debug('timeshareList[0].MF_Amount__c'+timeshareList[0].MF_Amount__c);
                    oli.Retail_Price__c = wrp.productMFMultiplier * timeshareList[0].MF_Amount__c;
                }
                //SAS-2,SAS-64
                /*
                else if(getProductName.get(productId) == 'Maintenance Fee Protection - Travel Cash' && wrp.productMFMultiplier != null && timeshareList.size()>0 && timeshareList != null)
                {
                    system.debug('wrp.productMFMultiplier'+wrp.productMFMultiplier);
                    system.debug('timeshareList[0].MF_Amount__c'+timeshareList[0].MF_Amount__c);
                    oli.Retail_Price__c = wrp.productMFMultiplier * timeshareList[0].MF_Amount__c;
                }
                */
                //HMR-601
                else if((getProductName.get(productId) == 'Sapphire Usage Match' || getProductName.get(productId) == 'HC Vida Collection Weeks Usage Fee TC Rebate' || getProductName.get(productId) == 'Vida Reserve Week Rebate' ) && wrp.productMFMultiplier != null && timeshareList.size()>0 && timeshareList != null)
                {
                    System.debug('Sapphire Usage Match wrp.productMFMultiplier == '+wrp.productMFMultiplier);
                    if(getProductName.get(productId) == 'Sapphire Usage Match' && wrp.productMFMultiplier < 2.0){
                        throw new AuraHandledException('The Minimum Price for the Sapphire Usage Match product is: 2x Usage Fee.');
                    }
                    //If (timeshareList[0].Usage_Fee__c > 0 ){
                    If (timeshareList[0].VIDA_File_Fee_Amount__c > 0 ){
                        oli.Retail_Price__c = wrp.productMFMultiplier * timeshareList[0].VIDA_File_Fee_Amount__c;    
                    } else
                    {
                        throw new AuraHandledException('Timeshare Usage Fee is missing.');
                    }    
                }
                /* Disbale Back to Vidanta Pass HMR-119
else if(getProductName.get(productId) == 'Back to Vidanta Pass'){
oli.Retail_Price__c = (timeshareList[0].VIDA_File_Fee_Amount__c != null? (timeshareList[0].VIDA_File_Fee_Amount__c * 1.1): 0);
}*/
                else if(getProductName.get(productId) == 'Back to Vidanta Pass TC'){
                    oli.Retail_Price__c = (timeshareList[0].VIDA_File_Fee_Amount__c != null? (timeshareList[0].VIDA_File_Fee_Amount__c * 1.1): 0);
                }
                //SAS-55
                else if((getProductName.get(productId) == 'Trade In Property' || getProductName.get(productId) == 'Trade In Property With Mortgage') && timeshareList.size()>0 && timeshareList != null)
                {
                    
					//block account with sample address
                    Boolean containsSample = false;
                    if (oppList != null && !oppList.isEmpty() && oppList[0].Account != null) {
                        List<String> fieldsToCheck = new List<String>{
                            oppList[0].Account.BillingStreet,
                            oppList[0].Account.BillingCity,
                            oppList[0].Account.BillingState,
                            oppList[0].Account.BillingCountry
                            };
                            for (String value : fieldsToCheck) {
                                if (value != null && value.toUpperCase().contains('SAMPLE_')) {
                                    containsSample = true;
                                    break;
                                }
                            }
                    }
                    if (containsSample) {
	                    throw new AuraHandledException('Account sample address not accepted.');
                    }
                    
                    //If (timeshareList[0].Usage_Fee__c > 0 ){
                    If (timeshareList[0].Trade_In_Value__c > 0 && (getProductName.get(productId) == 'Trade In Property' || getProductName.get(productId) == 'Trade In Property With Mortgage')){
	                    oli.Equity_Value__c = timeshareList[0].Trade_In_Value__c;
                    } else If ((getProductName.get(productId) == 'Trade In Property' || getProductName.get(productId) == 'Trade In Property With Mortgage'))
                    {
                        throw new AuraHandledException('Trade In Value is missing.');
                    }  
                    system.debug('timeshareList[0].Trade_In_Value__c'+timeshareList[0].Trade_In_Value__c);
/*                    
                    if ((   String.isBlank(timeshareList[0].Listing_type__c) ||
                            timeshareList[0].Listing_Price__c == null ||
                            timeshareList[0].Listing_Price__c == 0
                        ) && getProductName.get(productId) == '$1998 Resale Subscription - Title Fee Credit/Balance Paid by Seller at Closing') 
                    {
                        throw new AuraHandledException('Timeshare Listing Price and Type are required fields for this product.');
                    }
  */                  

                }
                else{
                    oli.Retail_Price__c = wrp.unitprice;
                }
                try{
                    system.debug('--oli--'+oli);
                    insert oli;
                    
                    //HMR-664
                    If (timeshareNumber == '1'){
                        oppList[0].Timeshare_1_OppProd_Id__c = oli.Id; //Timeshare_1_Product_Id__c    Timeshare_1_OppProd_Id__c
                    }Else If (timeshareNumber == '2'){
                        oppList[0].Timeshare_2_OppProd_Id__c = oli.Id;
                    }Else If (timeshareNumber == '3'){
                        oppList[0].Timeshare_3_OppProd_Id__c = oli.Id;
                    }Else If (timeshareNumber == '4'){
                        oppList[0].Timeshare_4_OppProd_Id__c = oli.Id;
                    }Else If (timeshareNumber == '5'){
                        oppList[0].Timeshare_5_OppProd_Id__c = oli.Id;
                    }Else If (timeshareNumber == '6'){
                        oppList[0].Timeshare_6_OppProd_Id__c = oli.Id;
                    }Else If (timeshareNumber == '7'){
                        oppList[0].Timeshare_7_OppProd_Id__c = oli.Id;
                    }Else If (timeshareNumber == '8'){
                        oppList[0].Timeshare_8_OppProd_Id__c = oli.Id;
                    }Else If (timeshareNumber == '9'){
                        oppList[0].Timeshare_9_OppProd_Id__c = oli.Id;
                    }Else If (timeshareNumber == '10'){
                        oppList[0].Timeshare_10_OppProd_Id__c = oli.Id;
                    }  
                    Update oppList;
                    
                    
                }catch (Exception ex){
                    system.debug('---e---'+ex);
                    ApexPages.Message msg = new ApexPages.Message(Apexpages.Severity.ERROR, ex.getdmlMessage(0) );
                    String errorMessage = string.valueof(msg);
                    if(errorMessage.contains('You can only add products from related Business Units')){
                        throw new AuraHandledException('You can only add products from related Business Units');    
                    }else if(errorMessage.contains('Be Below $2500')){
                        throw new AuraHandledException('Sales Price Cannot Be Below $2500');    
                    }else if(errorMessage.contains('$9995')){
                        throw new AuraHandledException('Net Value Can Not Be Below $9,995 for Platinum Products');
                    }else if(errorMessage.contains('$4,995')){
                        throw new AuraHandledException('Net Value Can Not Be Below $4,995 for Gold Products');    
                    }else if(errorMessage.contains('$2,495')){
                        throw new AuraHandledException('Net Value Can Not Be Below $2,495 for Silver Products');    
                    }else{
                        throw new AuraHandledException(errorMessage);    
                    }
                    //throw new AuraHandledException('error from apex');
                }
                system.debug('---create lineite,');
                break;
            }
        }
        return 'true';
    }
    
    @AuraEnabled
    public static string saveProductLineItemMTRC(List<productWrapper> proWrapperlist,Id OppId,Id productId){
        List<PricebookEntry> pricebookList = [select id ,Name,Pricebook2Id ,Product2Id,Product2.Family,UnitPrice from PricebookEntry where IsActive= true];
        
        system.debug('---wrp.selected----'+proWrapperlist);
        for(productWrapper wrp : proWrapperlist){
            system.debug('---wrp.selected----'+wrp.selected);
            if(wrp.selected){
                // Create new timeshare and Resort here
                Timeshare__c tm = new Timeshare__c();
                Id profileId=userinfo.getProfileId();
                system.debug('--profileId-'+profileId);
                // My Travel reward club - Resort
                if(!test.isRunningTest()){
                    tm.Resort__c = label.MTRC_Resort_Id;
                }
                tm.Master_Record_Id__c = 'null';
                tm.Mortgage_Monthly_Payment__c = '0';
                //tm.Equity_Value__c = 150;
                insert tm;
                system.debug('--tm'+tm.id);
                Map<Id,Id> PriceBookId = new Map<Id,Id>();
                Map<Id,String> getProductFamily = new Map<Id,String>();
                for(PricebookEntry ppe : pricebookList){
                    system.debug('--ppe.Product2.Family--'+ppe.Product2.Family);
                    PriceBookId.put(ppe.Product2Id,ppe.Id);
                    getProductFamily.put(ppe.Product2Id,ppe.Product2.Family);
                }
                system.debug('--wrp.ReasontoSellPickselectedValue--'+wrp.ReasontoSellPickselectedValue);
                if((wrp.ReasontoSellPickselectedValue == null || wrp.ReasontoSellPickselectedValue == '') && 
                   (getProductFamily.get(productId) != 'Equity Product') && (getProductFamily.get(productId) != 'MTRC Gold') &&
                   (getProductFamily.get(productId) != 'MTRC Platinum') && (getProductFamily.get(productId) != 'MTRC Silver'))
                {
                    throw new AuraHandledException('Please select Reason to Sell');
                }
                OpportunityLineItem oli = new OpportunityLineItem();
                oli.OpportunityId = oppId;
                oli.PricebookEntryId=PriceBookId.get(productId);
                oli.Timeshare__c = tm.Id;
                //oli.Timeshare_Picklist__c = 'Timeshare 1';
                oli.Reason_to_Sell__c = wrp.ReasontoSellPickselectedValue;
                if(wrp.vendorDiscount == null){
                    oli.Vendor_Discount__c = 0;
                }else{
                    oli.Vendor_Discount__c = wrp.vendorDiscount;
                }
                oli.Retail_Price__c = wrp.unitprice;
                try{
                    system.debug('--oli--'+oli);
                    insert oli;
                }catch (Exception ex){
                    system.debug('---e---'+ex);
                    ApexPages.Message msg = new ApexPages.Message(Apexpages.Severity.ERROR, ex.getdmlMessage(0) );
                    String errorMessage = string.valueof(msg);
                    if(errorMessage.contains('You can only add products from related Business Units')){
                        throw new AuraHandledException('You can only add products from related Business Units');    
                    }else if(errorMessage.contains('Be Below $2500')){
                        throw new AuraHandledException('Sales Price Cannot Be Below $2500');    
                    }else if(errorMessage.contains('$9995')){
                        throw new AuraHandledException('Net Value Can Not Be Below $9,995 for Platinum Products');
                    }else if(errorMessage.contains('$4,995')){
                        throw new AuraHandledException('Net Value Can Not Be Below $4,995 for Gold Products');    
                    }else if(errorMessage.contains('$2,495')){
                        throw new AuraHandledException('Net Value Can Not Be Below $2,495 for Silver Products');    
                    }else{
                        throw new AuraHandledException(errorMessage);    
                    }
                    //throw new AuraHandledException('error from apex');
                }
                system.debug('---create lineite,');
                break;
            }
        }
        return 'true';
    }
    
    //2024-04-17 HSIMU2-687 Multiplier for MFP Products - 3 [mfpMultiplier]
    @AuraEnabled 
    public static List<productWrapper> AllActiveProductList(Id oppId,Id timeshareIdentifier){
        List<productWrapper> productListObj = new List<productWrapper>();
        List<PricebookEntry> pricebookList = new List<PricebookEntry>();
        Opportunity opp = [SELECT Id,RecordType.DeveloperName,Account.Affiliated_Id__c FROM Opportunity WHERE Id =: oppId LIMIT 1];
        //2024-04-17 HSIMU2-687 Multiplier for MFP Products - 3 [mfpMultiplier] - new query
        List<Timeshare__c> timeshares = [select id,MF_Amount__c,Opportunity__c,Opportunity__r.RecordType.DeveloperName,VIDA_File_Fee_Amount__c,Resort__c,Resort__r.MFP_Multiplier__c, Usage_Fee__c from Timeshare__c where Id =: timeshareIdentifier];
        // Below commented code is if we have conditional based add product required.
        //List<Opportunitylineitem> oppLineItemList = [select id from Opportunitylineitem where Opportunity =: oppId]; 
        // Get the all line item and check if MTRC product is there or not, if there show only equity value    
        /* List<OpportunityLineItem> oppLineItemList = [Select id,OpportunityId,Date_Custom__c,Product2Id,PricebookEntry.Product2.Name,Retail_Price__c,Timeshare__c,Equity_Value__c,Settlement_Fee_Formula__c,Charge_Settlement_Fee__c,Vendor_Discount__c,Sales_Price__c,Reason_to_Sell__c,File_Fee__c,Simple_Product_Name__c,Agent_Email__c,Manager_File_Fee_Override__c,Notes_Instructions__c,TCS_File_Id__c,AFOV_File_Id__c,Net_Value_for_MTRC__c 
from OpportunityLineItem 
where OpportunityId =: oppId and (Product2.Name LIKE '%My Travel Rewards Club%')];

system.debug('--oppLineItemList--'+oppLineItemList);
if(oppLineItemList != null && oppLineItemList.size() > 0){
// MTRC product
pricebookList = [select id ,Name,Pricebook2Id ,Product2Id,UnitPrice from PricebookEntry where IsActive= true and Name  LIKE '%Equity%'];
}else{
// For MHP user can see only Equity product
Id profileId=userinfo.getProfileId();
system.debug('--profileId-'+profileId);
pricebookList = [select id ,Name,Pricebook2Id ,Product2Id,UnitPrice from PricebookEntry where IsActive= true and (NOT Name  LIKE '%Membership Upgrade%') and (NOT Name  LIKE '%Equity%') and (NOT Name  LIKE '%My Travel rewards Club%')];

} */
        //List<PricebookEntry> pricebookList = [select id ,Name,Pricebook2Id ,Product2Id,UnitPrice from PricebookEntry where IsActive= true];
        
        //2023-05-05 adding MTRC Vida MFP Add On with Creditsm product, with multiplier 0, for Membership Add On Opportunities
        //HMR-601   pricebookList = [select id ,Name,Pricebook2Id ,Product2Id,UnitPrice,Product2.Name from PricebookEntry where IsActive= true and (Name LIKE '%Maintenance Fee Protection%' OR Product2.Name = 'MTRC Vida MFP Add On with Credits' OR Product2.Name = 'Back to Vidanta Pass TC')];//Disbale Back to Vidanta Pass HMR-119  Product2.Name = 'Back to Vidanta Pass' OR

        //SAS-2, SAS-55
        If(opp.RecordType.DeveloperName == 'Social_Ad_Sales'){
            pricebookList = [select id ,Name,Pricebook2Id ,Product2Id,UnitPrice,Product2.Name 
                             from PricebookEntry 
                             where IsActive= true and 
                             (
                              Product2.Name = 'Trade In Property' 
                              OR Product2.Name = 'Trade In Property With Mortgage' 
                              OR Product2.Name = 'CV Sapphire')];
            /*
             Product2.Name = '$1998 Resale Subscription - Title Fee Credit/Balance Paid by Seller at Closing' 
                              OR Product2.Name = 'Maintenance Fee Protection - Travel Cash' OR  
			*/
        }
        else if(opp.RecordType.DeveloperName == 'Reserve_Collection_Membership' || opp.RecordType.DeveloperName == 'Membership_Add_On'){
            pricebookList = [select id ,Name,Pricebook2Id ,Product2Id,UnitPrice,Product2.Name from PricebookEntry where IsActive= true and 
                             (Name LIKE '%Maintenance Fee Protection%' OR Product2.Name = 'MTRC Vida MFP Add On with Credits' OR Product2.Name = 'Back to Vidanta Pass TC'
                              OR Product2.Name = 'HC Vida Collection Weeks Usage Fee TC Rebate' OR Product2.Name = 'HC Collection Weeks' OR  Product2.Name = 'Vida Reserve Week' OR  Product2.Name = 'Vida Reserve Week Rebate'
                              OR  Product2.Name = 'Sapphire Usage Match')];
        }
        Else {
            pricebookList = [select id ,Name,Pricebook2Id ,Product2Id,UnitPrice,Product2.Name from PricebookEntry where IsActive= true and 
                             (Name LIKE '%Maintenance Fee Protection%' OR Product2.Name = 'MTRC Vida MFP Add On with Credits' OR Product2.Name = 'Back to Vidanta Pass TC'
                              OR Product2.Name = 'HC Vida Collection Weeks Usage Fee TC Rebate' OR Product2.Name = 'HC Collection Weeks' OR  Product2.Name = 'Vida Reserve Week' OR  Product2.Name = 'Vida Reserve Week Rebate')];
        }
        
		system.debug('--pricebookList--'+pricebookList);
       
        Map<Id,Decimal> listpriceMap = new Map<Id,Decimal>();
        Map<Id,Id> PriceBookId = new Map<Id,Id>();
        Set<Id> activeProductId = new Set<Id>();
        //2024-04-17 HSIMU2-687 Multiplier for MFP Products - 3 [mfpMultiplier]
        Decimal mfpMultiplier = null;
        if(timeshares[0].Resort__c != null)
        {
            if(timeshares[0].Resort__r.MFP_Multiplier__c != null)
            {
                mfpMultiplier = timeshares[0].Resort__r.MFP_Multiplier__c;
            }
        }
        
        
        // Get all existing products already added to the Opportunity - HMR-601 Phase 2 HMR-644
        Set<Id> existingProductIds = new Set<Id>();
        for (OpportunityLineItem oli : [
            SELECT PricebookEntry.Product2Id 
            FROM OpportunityLineItem 
            WHERE OpportunityId = :oppId
            AND Timeshare__c = :timeshareIdentifier
        ]) {
            existingProductIds.add(oli.PricebookEntry.Product2Id);
        }
        
        
        for(PricebookEntry ppe : pricebookList){
            //HMR-601   if((ppe.Product2.Name == 'MTRC Vida MFP Add On with Credits' && opp.RecordType.DeveloperName == 'Membership_Add_On' && opp.Account.Affiliated_Id__c == 1002409) || ppe.Product2.Name == 'Back to Vidanta Pass TC' || ppe.Product2.Name != 'MTRC Vida MFP Add On with Credits'){ //(ppe.Product2.Name == 'Back to Vidanta Pass' &&  opp.RecordType.DeveloperName == 'Hawaii_Collection_Membership') ||
            if((ppe.Product2.Name == 'MTRC Vida MFP Add On with Credits' && opp.RecordType.DeveloperName == 'Membership_Add_On' && opp.Account.Affiliated_Id__c == 1002409) || 
               ppe.Product2.Name == 'Back to Vidanta Pass TC' || 
               ppe.Product2.Name != 'MTRC Vida MFP Add On with Credits'
              ){ 
                  
                  if (!existingProductIds.contains(ppe.Product2Id)) {  // HMR-601 - Phase 2 HMR-644
                      PriceBookId.put(ppe.Product2Id,ppe.Id);
                      listpriceMap.put(ppe.Product2Id,ppe.UnitPrice);
                      activeProductId.add(ppe.Product2Id);
                  }
              }
        }
        system.debug('---HMR-601---');
        system.debug('---activeProductId:'+activeProductId);
        List<Product2> productList = [select id,Name,ProductCode,Description,Family from product2 where ID IN:activeProductId];
        
        system.debug('---HMR-601---');
        system.debug('---productList:'+productList);
        
        for(Product2 pro : productList){
            productWrapper wrp = new productWrapper();
            if(listpriceMap.containskey(pro.id)){
                wrp.unitprice = listpriceMap.get(pro.Id);
            }
            Schema.DescribeFieldResult fieldResult = Opportunitylineitem.Reason_to_Sell__c.getDescribe();
            //get Account Industry Picklist Values
            wrp.ReasontoSellPicklist = new List<SelectOptions>();
            List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
            for (Schema.PicklistEntry p: pList) {
                wrp.ReasontoSellPicklist.add(new SelectOptions(p.getValue(), p.getLabel()));
            }
            wrp.vendorDiscount = 0;
            wrp.prd = pro;
            wrp.selected = false;
            
            system.debug('---HMR-601---');
            system.debug('---pro.Name:'+pro.Name);
            system.debug('---opp.RecordType.DeveloperName:'+opp.RecordType.DeveloperName);
            
            //logic added B-09353 - Enable MFP Multiplier default to 2 for MTRC Retail, MTRC, Hawaii collection, and SFX
            //2023-12-01 - HSIMU2-444 - min MFP for Membership_Add_On updated from 2 to 1.5
            //2024-04-17 HSIMU2-687 Multiplier for MFP Products - 3 [mfpMultiplier]
            if((opp.RecordType.DeveloperName == 'MTRC_Retail'  || opp.RecordType.DeveloperName == 'Membership_Add_On') && !(pro.Name == 'Maintenance Fee Protection' && mfpMultiplier != null)){
                if(pro.Name == 'Sapphire Usage Match')
                {
                    wrp.productMFMultiplier = 2; //Multipler default = 2
                }
                else if(pro.Name != 'MTRC Vida MFP Add On with Credits' && opp.RecordType.DeveloperName != 'Membership_Add_On'){
                    wrp.productMFMultiplier = 2; //Multipler default = 2
                }
                else if(opp.RecordType.DeveloperName != 'Membership_Add_On')
                {
                    wrp.productMFMultiplier = 0; //Multipler default = 0
                }
                else if(opp.RecordType.DeveloperName == 'Membership_Add_On' && pro.Name != 'HC Collection Weeks' && pro.Name != 'Vida Reserve Week') //HMR-601
                {
                    wrp.productMFMultiplier = 1.5; //Multipler default = 1.5
                }
                else if(pro.Name == 'HC Vida Collection Weeks Usage Fee TC Rebate' && opp.RecordType.DeveloperName == 'Hawaii_Collection_Membership')  //HMR-601
                {
                    system.debug('---HMR-601---');
                    wrp.productMFMultiplier = 1.5; //Multipler default = 1.5
                }
            }
            //HMR-601   else if ((opp.RecordType.DeveloperName == 'Membership_Upgrade' || pro.Name != 'Back to Vidanta Pass TC' || opp.RecordType.DeveloperName == 'SFX_Membership') && !(pro.Name == 'Maintenance Fee Protection' && mfpMultiplier != null)) { //&& (pro.Name != 'Back to Vidanta Pass' && opp.RecordType.DeveloperName == 'Hawaii_Collection_Membership')
            else if (
                (opp.RecordType.DeveloperName == 'Membership_Upgrade' || pro.Name != 'Back to Vidanta Pass TC' || opp.RecordType.DeveloperName == 'SFX_Membership') && 
                !(pro.Name == 'Maintenance Fee Protection' && mfpMultiplier != null) &&
                !(pro.Name == 'Sapphire Usage Match' && mfpMultiplier != null) &&
                !(pro.Name == 'HC Collection Weeks') && !(pro.Name == 'Vida Reserve Week') &&
                opp.RecordType.DeveloperName != 'Social_Ad_Sales'  //SAS-2 
            ) { 
                wrp.productMFMultiplier = 1.5; //Multipler default = 1.5
            }
            
            //SAS-2
            //SAS-64
/*
            else if (opp.RecordType.DeveloperName == 'Social_Ad_Sales') 
            {
                If(pro.Name == 'Maintenance Fee Protection - Travel Cash') {
                    wrp.productMFMultiplier = 1.5; //Multipler default = 1.5
            		system.debug('SAS-2---wrp.productMFMultiplier:'+wrp.productMFMultiplier);        
                }
                else if (pro.Name == 'Maintenance Fee Protection'){
                    wrp.productMFMultiplier = 2; //Multipler default = 2
                }
                else {
                    wrp.productMFMultiplier = null; 
                }
            }
  */          
            else if(pro.Name == 'Maintenance Fee Protection' && mfpMultiplier != null)
            {
                wrp.productMFMultiplier = mfpMultiplier; //Multipler default = Resort MFP Multiplier
            }
            else if(pro.Name == 'Sapphire Usage Match' && mfpMultiplier != null)
            {
                wrp.productMFMultiplier = 2.0; //Multipler default
            }
			else
            {
                wrp.productMFMultiplier = null;
            }
            system.debug('---wrp.productMFMultiplier:'+wrp.productMFMultiplier);
            system.debug('SAS-2---pro.Name:'+pro.Name);
            
            productListObj.add(wrp);
        }

        productListObj.sort(new ProductWrapperComparator());

        return productListObj;
    }
    
    @AuraEnabled 
    public static List<productWrapper> AllActiveMTRCProductList(){  
        List<productWrapper> productListObj = new List<productWrapper>();
        List<PricebookEntry> pricebookList = new List<PricebookEntry>();
        Boolean isTBSProfile = true;
        Id profileId=userinfo.getProfileId();
        system.debug('--profileId-'+profileId);
        pricebookList = [select id ,Name,Pricebook2Id ,Product2Id,UnitPrice from PricebookEntry where IsActive= true and Name LIKE '%My Travel Rewards Club%' order by UnitPrice ASC];            
        
        Map<Id,Decimal> listpriceMap = new Map<Id,Decimal>();
        Map<Id,Id> PriceBookId = new Map<Id,Id>();
        Set<Id> activeProductId = new Set<Id>();
        for(PricebookEntry ppe : pricebookList){
            PriceBookId.put(ppe.Product2Id,ppe.Id);
            listpriceMap.put(ppe.Product2Id,ppe.UnitPrice);
            activeProductId.add(ppe.Product2Id);
        }
        List<Product2> productList = [select id,Name,ProductCode,Description,Family from product2 where ID IN:activeProductId order by Order_for_MTRC_view__c asc];
        for(Product2 pro : productList){
            productWrapper wrp = new productWrapper();
            if(listpriceMap.containskey(pro.id)){
                wrp.unitprice = listpriceMap.get(pro.Id);
            }
            Schema.DescribeFieldResult fieldResult = Opportunitylineitem.Reason_to_Sell__c.getDescribe();
            //get Account Industry Picklist Values
            wrp.ReasontoSellPicklist = new List<SelectOptions>();
            List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
            for (Schema.PicklistEntry p: pList) {
                wrp.ReasontoSellPicklist.add(new SelectOptions(p.getValue(), p.getLabel()));
            }
            wrp.vendorDiscount = 0;
            wrp.prd = pro;
            wrp.selected = false;
            productListObj.add(wrp);
        }
        return productListObj;
    }
    
    @AuraEnabled 
    public static List<timeshareWrapper> timeshareWrapper(String recordId){  
        // recordId = '0067g00000FmXkaAAF'; // membership
        // recordId = '0063t00000wL43kAAC';
        
        system.debug('302='+recordId);
        List<timeshareWrapper> listTimeshareWrapper = new List<timeshareWrapper>();
        system.debug('-recordId--'+recordId);
        if(recordId != null){
            List<Opportunity> oppList = [select id,AccountId,Timeshare_1__c,Timeshare_2__c,Timeshare_3__c,Timeshare_4__c,Timeshare_5__c,Timeshare_6__c,
                                         Timeshare_7__c,Timeshare_8__c,Timeshare_9__c,Timeshare_10__c,
                                         Timeshare_1__r.Name,Timeshare_2__r.Name,Timeshare_3__r.Name,Timeshare_4__r.Name,Timeshare_5__r.Name,
                                         Timeshare_6__r.Name,Timeshare_7__r.Name,Timeshare_8__r.Name,Timeshare_9__r.Name,Timeshare_10__r.Name,
                                         TS_1_Mortgage__c,TS_2_Mortgage__c,TS_3_Mortgage__c,TS_4_Mortgage__c,TS_5_Mortgage__c,TS_6_Mortgage__c,
                                         TS_7_Mortgage__c,
                                         Forbidden_or_Accepted_1__c,Forbidden_or_Accepted_2__c,Forbidden_or_Accepted_3__c,Forbidden_or_Accepted_4__c,Forbidden_or_Accepted_5__c,
                                         Forbidden_or_Accepted_6__c,Forbidden_or_Accepted_7__c,Forbidden_or_Accepted_8__c,Forbidden_or_Accepted_9__c,Forbidden_or_Accepted_10__c,
                                         Timeshare_1_OppProd_Id__c,Timeshare_2_OppProd_Id__c,Timeshare_3_OppProd_Id__c,Timeshare_4_OppProd_Id__c,Timeshare_5_OppProd_Id__c,
                                         Timeshare_6_OppProd_Id__c,Timeshare_7_OppProd_Id__c,Timeshare_8_OppProd_Id__c,Timeshare_9_OppProd_Id__c,Timeshare_10_OppProd_Id__c,
                                         RecordTypeId,RecordType.Name,RecordType.DeveloperName
                                         
                                         from Opportunity where Id =:recordId];
            system.debug('317='+oppList);
            List<OpportunityLineItem> oppLineitemList = [select id,Name,product2.Name,product2.Family,Timeshare__c from OpportunityLineItem where OpportunityId =:recordId];
            system.debug('--oppLineitemList--'+oppLineitemList.size());
            //Map<Id,Id> isProductAdded = new Map<Id,Id>();
            //Map<Id,String> isProductAddedName = new Map<Id,String>();
            Map<Id, OpportunityLineItem> oppLineitemMap = new Map<Id, OpportunityLineItem>();
            Boolean sapphireProductAdded = false;
            for(OpportunityLineItem opLineitem : oppLineitemList){
                // isProductAdded.put(opLineitem.Timeshare__c,opLineitem.Id);
                //isProductAddedName.put(opLineitem.Timeshare__c,opLineitem.Name);
                oppLineitemMap.put(opLineitem.Id,opLineitem);
                if(oppList[0].RecordType.DeveloperName == 'Reserve_Collection_Membership'  && opLineitem.Product2.Name == 'Reserve Collection-Sapphire'){//|| oppList[0].RecordType.DeveloperName == 'Membership_Add_On'
                    sapphireProductAdded = true;
                }
            } 
            Id profileId=userinfo.getProfileId();
            
            
            if(oppList != null && oppList.size() > 0){
                Opportunity opp = oppList[0];
                // Timeshare 1
                if(opp.Timeshare_1__c != null){
                    system.debug('-opp.Timeshare_1__c---'+opp.Timeshare_1__c);
                    timeshareWrapper wrap = new timeshareWrapper();
                    wrap.timeshareName = opp.Timeshare_1__r.Name;
                    //wrap.timeshareMultiplier = opp.Timeshare_1__r.Multiplier__c;
                    wrap.timeshareId = opp.Timeshare_1__c;
                    wrap.PreferredCompany = opp.Forbidden_or_Accepted_1__c;
                    wrap.Mortgage = opp.TS_1_Mortgage__c;
                    wrap.isAddExisting = false;
                    wrap.isMTRCProductExist = false;
                    wrap.timeshareNumber = 1;
                    wrap.accountId =  opp.AccountId;
                    wrap.disableAddButton = opp.RecordType.DeveloperName == 'Reserve_Collection_Membership' ? !sapphireProductAdded : false;
                    
                    //if(isProductAdded.containskey(opp.Timeshare_1__c)){
                    if(opp.Timeshare_1_OppProd_Id__c != null){
                        //wrap.productaddedId = isProductAdded.get(opp.Timeshare_1__c);
                        //wrap.productaddedName = isProductAddedName.get(opp.Timeshare_1__c);
                        wrap.productaddedId = opp.Timeshare_1_OppProd_Id__c;
                        wrap.productaddedName = oppLineitemMap.containsKey(opp.Timeshare_1_OppProd_Id__c) ? oppLineitemMap.get(opp.Timeshare_1_OppProd_Id__c).Name : null;
                    }
                    
                    listTimeshareWrapper.add(wrap);
                }
                // Timeshare 2
                if(opp.Timeshare_2__c != null){
                    system.debug('-opp.Timeshare_2__c---'+opp.Timeshare_2__c);
                    timeshareWrapper wrap = new timeshareWrapper();
                    wrap.timeshareName = opp.Timeshare_2__r.Name;
                    //wrap.timeshareMultiplier = opp.Timeshare_2__r.Multiplier__c;
                    wrap.timeshareId = opp.Timeshare_2__c;
                    wrap.PreferredCompany = opp.Forbidden_or_Accepted_2__c;
                    wrap.Mortgage = opp.TS_2_Mortgage__c;
                    wrap.isAddExisting = false;
                    wrap.isMTRCProductExist = false;
                    wrap.timeshareNumber = 2;
                    wrap.accountId =  opp.AccountId;
                    wrap.disableAddButton = opp.RecordType.DeveloperName == 'Reserve_Collection_Membership' ? !sapphireProductAdded : false;
                    //if(isProductAdded.containskey(opp.Timeshare_2__c)){
                    if(opp.Timeshare_2_OppProd_Id__c != null){
                        //wrap.productaddedId = isProductAdded.get(opp.Timeshare_2__c);
                        //wrap.productaddedName = isProductAddedName.get(opp.Timeshare_2__c);
                        wrap.productaddedId = opp.Timeshare_2_OppProd_Id__c;
                        wrap.productaddedName = oppLineitemMap.containsKey(opp.Timeshare_2_OppProd_Id__c) ? oppLineitemMap.get(opp.Timeshare_2_OppProd_Id__c).Name : null;
                    }
                    listTimeshareWrapper.add(wrap);
                }
                // Timeshare 3
                if(opp.Timeshare_3__c != null){
                    system.debug('-opp.Timeshare_3__c---'+opp.Timeshare_3__c);
                    timeshareWrapper wrap = new timeshareWrapper();
                    wrap.timeshareName = opp.Timeshare_3__r.Name;
                    //wrap.timeshareMultiplier = opp.Timeshare_3__r.Multiplier__c;
                    wrap.timeshareId = opp.Timeshare_3__c;
                    wrap.PreferredCompany = opp.Forbidden_or_Accepted_3__c;
                    wrap.Mortgage = opp.TS_3_Mortgage__c;
                    wrap.isAddExisting = false;
                    
                    wrap.isMTRCProductExist = false;
                    
                    wrap.timeshareNumber = 3;
                    wrap.accountId =  opp.AccountId;
                    wrap.disableAddButton = opp.RecordType.DeveloperName == 'Reserve_Collection_Membership' ? !sapphireProductAdded : false;
                    //if(isProductAdded.containskey(opp.Timeshare_3__c)){
                    if(opp.Timeshare_3_OppProd_Id__c != null){
                        //wrap.productaddedId = isProductAdded.get(opp.Timeshare_3__c);
                        //wrap.productaddedName = isProductAddedName.get(opp.Timeshare_3__c);
                        wrap.productaddedId = opp.Timeshare_3_OppProd_Id__c;
                        wrap.productaddedName = oppLineitemMap.containsKey(opp.Timeshare_3_OppProd_Id__c) ? oppLineitemMap.get(opp.Timeshare_3_OppProd_Id__c).Name : null;
                    }
                    listTimeshareWrapper.add(wrap);
                }
                // Timeshare 4
                if(opp.Timeshare_4__c != null){
                    system.debug('-opp.Timeshare_4__c---'+opp.Timeshare_4__c);
                    timeshareWrapper wrap = new timeshareWrapper();
                    wrap.timeshareName = opp.Timeshare_4__r.Name;
                    //wrap.timeshareMultiplier = opp.Timeshare_4__r.Multiplier__c;
                    wrap.timeshareId = opp.Timeshare_4__c;
                    wrap.PreferredCompany = opp.Forbidden_or_Accepted_4__c;
                    wrap.Mortgage = opp.TS_4_Mortgage__c;
                    wrap.isAddExisting = false;
                    
                    wrap.isMTRCProductExist = false; 
                    
                    wrap.timeshareNumber = 4;
                    wrap.accountId =  opp.AccountId;
                    wrap.disableAddButton = opp.RecordType.DeveloperName == 'Reserve_Collection_Membership' ? !sapphireProductAdded : false;
                    //if(isProductAdded.containskey(opp.Timeshare_4__c)){
                    if(opp.Timeshare_4_OppProd_Id__c != null){
                        //wrap.productaddedId = isProductAdded.get(opp.Timeshare_4__c);
                        //wrap.productaddedName = isProductAddedName.get(opp.Timeshare_4__c);
                        wrap.productaddedId = opp.Timeshare_4_OppProd_Id__c;
                        wrap.productaddedName = oppLineitemMap.containsKey(opp.Timeshare_4_OppProd_Id__c) ? oppLineitemMap.get(opp.Timeshare_4_OppProd_Id__c).Name : null;
                    }
                    listTimeshareWrapper.add(wrap);
                }
                // Timeshare 5
                if(opp.Timeshare_5__c != null){
                    system.debug('-opp.Timeshare_1__c---'+opp.Timeshare_5__c);
                    timeshareWrapper wrap = new timeshareWrapper();
                    wrap.timeshareName = opp.Timeshare_5__r.Name;
                    //wrap.timeshareMultiplier = opp.Timeshare_5__r.Multiplier__c;
                    wrap.timeshareId = opp.Timeshare_5__c;
                    wrap.PreferredCompany = opp.Forbidden_or_Accepted_5__c;
                    wrap.Mortgage = opp.TS_5_Mortgage__c;
                    wrap.isAddExisting = false;
                    
                    wrap.isMTRCProductExist = false;
                    
                    wrap.timeshareNumber = 5;
                    wrap.accountId =  opp.AccountId;
                    wrap.disableAddButton = opp.RecordType.DeveloperName == 'Reserve_Collection_Membership' ? !sapphireProductAdded : false;
                    //if(isProductAdded.containskey(opp.Timeshare_5__c)){
                    if(opp.Timeshare_5_OppProd_Id__c != null){
                        //wrap.productaddedId = isProductAdded.get(opp.Timeshare_5__c);
                        //wrap.productaddedName = isProductAddedName.get(opp.Timeshare_5__c);
                        wrap.productaddedId = opp.Timeshare_5_OppProd_Id__c;
                        wrap.productaddedName = oppLineitemMap.containsKey(opp.Timeshare_5_OppProd_Id__c) ? oppLineitemMap.get(opp.Timeshare_5_OppProd_Id__c).Name : null;
                    }
                    listTimeshareWrapper.add(wrap);
                }
                // Timeshare 6
                if(opp.Timeshare_6__c != null){
                    system.debug('-opp.Timeshare_1__c---'+opp.Timeshare_6__c);
                    timeshareWrapper wrap = new timeshareWrapper();
                    wrap.timeshareName = opp.Timeshare_6__r.Name;
                    //wrap.timeshareMultiplier = opp.Timeshare_6__r.Multiplier__c;
                    wrap.timeshareId = opp.Timeshare_6__c;
                    wrap.PreferredCompany = opp.Forbidden_or_Accepted_6__c;
                    wrap.Mortgage = opp.TS_6_Mortgage__c;
                    wrap.isAddExisting = false;
                    
                    wrap.isMTRCProductExist = false;
                    
                    wrap.timeshareNumber = 6;
                    wrap.accountId =  opp.AccountId;
                    wrap.disableAddButton = opp.RecordType.DeveloperName == 'Reserve_Collection_Membership' ? !sapphireProductAdded : false;
                    //if(isProductAdded.containskey(opp.Timeshare_6__c)){
                    if(opp.Timeshare_6_OppProd_Id__c != null){
                        //wrap.productaddedId = isProductAdded.get(opp.Timeshare_6__c);
                        //wrap.productaddedName = isProductAddedName.get(opp.Timeshare_6__c);
                        wrap.productaddedId = opp.Timeshare_6_OppProd_Id__c;
                        wrap.productaddedName = oppLineitemMap.containsKey(opp.Timeshare_6_OppProd_Id__c) ? oppLineitemMap.get(opp.Timeshare_6_OppProd_Id__c).Name : null;
                    }
                    listTimeshareWrapper.add(wrap);
                }
                // Timeshare 7
                if(opp.Timeshare_7__c != null){
                    system.debug('-opp.Timeshare_1__c---'+opp.Timeshare_7__c);
                    timeshareWrapper wrap = new timeshareWrapper();
                    wrap.timeshareName = opp.Timeshare_7__r.Name;
                    //wrap.timeshareMultiplier = opp.Timeshare_7__r.Multiplier__c;
                    wrap.timeshareId = opp.Timeshare_7__c;
                    wrap.PreferredCompany = opp.Forbidden_or_Accepted_7__c;
                    wrap.Mortgage = opp.TS_7_Mortgage__c;
                    wrap.isAddExisting = false;
                    
                    wrap.isMTRCProductExist = false;
                    
                    wrap.timeshareNumber = 7;
                    wrap.accountId =  opp.AccountId;
                    wrap.disableAddButton = opp.RecordType.DeveloperName == 'Reserve_Collection_Membership' ? !sapphireProductAdded : false;
                    //if(isProductAdded.containskey(opp.Timeshare_7__c)){
                    if(opp.Timeshare_7_OppProd_Id__c != null){
                        //wrap.productaddedId = isProductAdded.get(opp.Timeshare_7__c);
                        //wrap.productaddedName = isProductAddedName.get(opp.Timeshare_7__c);
                        wrap.productaddedId = opp.Timeshare_7_OppProd_Id__c;
                        wrap.productaddedName = oppLineitemMap.containsKey(opp.Timeshare_7_OppProd_Id__c) ? oppLineitemMap.get(opp.Timeshare_7_OppProd_Id__c).Name : null;
                    }
                    listTimeshareWrapper.add(wrap);
                }
                // Timeshare 8
                if(opp.Timeshare_8__c != null){
                    system.debug('-opp.Timeshare_1__c---'+opp.Timeshare_8__c);
                    timeshareWrapper wrap = new timeshareWrapper();
                    wrap.timeshareName = opp.Timeshare_8__r.Name;
                    //rap.timeshareMultiplier = opp.Timeshare_8__r.Multiplier__c;
                    wrap.timeshareId = opp.Timeshare_8__c;
                    wrap.PreferredCompany = opp.Forbidden_or_Accepted_8__c;
                    wrap.Mortgage = null;
                    wrap.isAddExisting = false;
                    
                    wrap.isMTRCProductExist = false;
                    
                    wrap.timeshareNumber = 8;
                    wrap.accountId =  opp.AccountId;
                    wrap.disableAddButton = opp.RecordType.DeveloperName == 'Reserve_Collection_Membership' ? !sapphireProductAdded : false;
                    //if(isProductAdded.containskey(opp.Timeshare_8__c)){
                    if(opp.Timeshare_8_OppProd_Id__c != null){
                        //wrap.productaddedId = isProductAdded.get(opp.Timeshare_8__c);
                        //wrap.productaddedName = isProductAddedName.get(opp.Timeshare_8__c);
                        wrap.productaddedId = opp.Timeshare_8_OppProd_Id__c;
                        wrap.productaddedName = oppLineitemMap.containsKey(opp.Timeshare_8_OppProd_Id__c) ? oppLineitemMap.get(opp.Timeshare_8_OppProd_Id__c).Name : null;
                    }
                    listTimeshareWrapper.add(wrap);
                }
                // Timeshare 9
                if(opp.Timeshare_9__c != null){
                    system.debug('-opp.Timeshare_1__c---'+opp.Timeshare_9__c);
                    timeshareWrapper wrap = new timeshareWrapper();
                    wrap.timeshareName = opp.Timeshare_9__r.Name;
                    //wrap.timeshareMultiplier = opp.Timeshare_9__r.Multiplier__c;
                    wrap.timeshareId = opp.Timeshare_9__c;
                    wrap.PreferredCompany = opp.Forbidden_or_Accepted_9__c;
                    wrap.Mortgage = null;
                    wrap.isAddExisting = false;
                    
                    wrap.isMTRCProductExist = false;
                    
                    wrap.timeshareNumber = 9;
                    wrap.accountId =  opp.AccountId;
                    wrap.disableAddButton = opp.RecordType.DeveloperName == 'Reserve_Collection_Membership' ? !sapphireProductAdded : false;
                    //if(isProductAdded.containskey(opp.Timeshare_9__c)){
                    if(opp.Timeshare_9_OppProd_Id__c != null){
                        //wrap.productaddedId = isProductAdded.get(opp.Timeshare_9__c);
                        //wrap.productaddedName = isProductAddedName.get(opp.Timeshare_9__c);
                        wrap.productaddedId = opp.Timeshare_9_OppProd_Id__c;
                        wrap.productaddedName = oppLineitemMap.containsKey(opp.Timeshare_9_OppProd_Id__c) ? oppLineitemMap.get(opp.Timeshare_9_OppProd_Id__c).Name : null;
                    }
                    listTimeshareWrapper.add(wrap);
                }
                
                // Timeshare 10
                if(opp.Timeshare_10__c != null){
                    system.debug('-opp.Timeshare_1__c---'+opp.Timeshare_10__c);
                    timeshareWrapper wrap = new timeshareWrapper();
                    wrap.timeshareName = opp.Timeshare_10__r.Name;
                    //wrap.timeshareMultiplier = opp.Timeshare_10__r.Multiplier__c;
                    wrap.timeshareId = opp.Timeshare_10__c;
                    wrap.PreferredCompany = opp.Forbidden_or_Accepted_10__c;
                    wrap.Mortgage = null;
                    wrap.isAddExisting = false;
                    
                    wrap.isMTRCProductExist = false;
                    
                    wrap.timeshareNumber = 10;
                    wrap.accountId =  opp.AccountId;
                    wrap.disableAddButton = opp.RecordType.DeveloperName == 'Reserve_Collection_Membership' ? !sapphireProductAdded : false;
                    //if(isProductAdded.containskey(opp.Timeshare_10__c)){
                    if(opp.Timeshare_10_OppProd_Id__c != null){                        
                        //wrap.productaddedId = isProductAdded.get(opp.Timeshare_10__c);
                        //wrap.productaddedName = isProductAddedName.get(opp.Timeshare_10__c);
                        wrap.productaddedId = opp.Timeshare_10_OppProd_Id__c;
                        wrap.productaddedName = oppLineitemMap.containsKey(opp.Timeshare_10_OppProd_Id__c) ? oppLineitemMap.get(opp.Timeshare_10_OppProd_Id__c).Name : null;
                    }
                    listTimeshareWrapper.add(wrap);
                }
                system.debug('538='+listTimeshareWrapper.isEmpty());
                if(listTimeshareWrapper.isEmpty()){
                    timeshareWrapper wrap = new timeshareWrapper();
                    wrap.accountId =  opp.AccountId;
                    wrap.isAddExisting = true;
                    system.debug('--profileId-'+profileId);
                    if(opp.RecordType.DeveloperName == 'Membership_Upgrade'){
                        wrap.isMTRCProductExist = false;    
                    }else{
                        wrap.isMTRCProductExist = true;    
                    }
                    
                    listTimeshareWrapper.add(wrap);  
                }
                if(oppLineitemList != null){
                    for(OpportunityLineItem opLineitem : oppLineitemList){
                        system.debug('---inside mtrc');
                        if(opLineitem.product2.Name.contains('My Travel Rewards Club')){
                            timeshareWrapper wrap = new timeshareWrapper();
                            wrap.isMTRCProductExist = true;
                            wrap.accountId =  opp.AccountId;
                            system.debug('---inside mtrc'+wrap.isMTRCProductExist);
                            listTimeshareWrapper.add(wrap);  
                        }
                        
                    } 
                }
                
            }
        }
        system.debug('-listTimeshareWrapper---'+listTimeshareWrapper);
        return listTimeshareWrapper; 
    } 
    
    @AuraEnabled
    public static string timesharDelete(Id timeshareId, id oppId, String timeshareNumber){
        List<Opportunity> oppList = [select id,Timeshare_1__c,Timeshare_2__c,Timeshare_3__c,Timeshare_4__c,Timeshare_5__c,Timeshare_6__c,
                                     Timeshare_7__c,Timeshare_8__c,Timeshare_9__c,Timeshare_10__c,
                                     Timeshare_1__r.Name,Timeshare_2__r.Name,Timeshare_3__r.Name,Timeshare_4__r.Name,Timeshare_5__r.Name,
                                     TS_1_Mortgage__c,TS_2_Mortgage__c,TS_3_Mortgage__c,TS_4_Mortgage__c,TS_5_Mortgage__c,TS_6_Mortgage__c,
                                     TS_7_Mortgage__c,
                                     Forbidden_or_Accepted_1__c,Forbidden_or_Accepted_2__c,Forbidden_or_Accepted_3__c,Forbidden_or_Accepted_4__c,Forbidden_or_Accepted_5__c,
                                     Forbidden_or_Accepted_6__c,Forbidden_or_Accepted_7__c,Forbidden_or_Accepted_8__c,Forbidden_or_Accepted_9__c,Forbidden_or_Accepted_10__c,
                                     Timeshare_1_OppProd_Id__c,Timeshare_2_OppProd_Id__c,Timeshare_3_OppProd_Id__c,Timeshare_4_OppProd_Id__c,Timeshare_5_OppProd_Id__c,
                                     Timeshare_6_OppProd_Id__c,Timeshare_7_OppProd_Id__c,Timeshare_8_OppProd_Id__c,Timeshare_9_OppProd_Id__c,Timeshare_10_OppProd_Id__c
                                     from Opportunity where Id =:oppId];
        
        Boolean attachedProduct = False;
        id oliId;
        
        If (timeshareNumber == '1' && oppList[0].Timeshare_1_OppProd_Id__c != null){
            attachedProduct = true;	
            oliId = oppList[0].Timeshare_1_OppProd_Id__c;
        }Else If (timeshareNumber == '2' && oppList[0].Timeshare_2_OppProd_Id__c != null){
            attachedProduct = true;	
            oliId = oppList[0].Timeshare_2_OppProd_Id__c;
        }Else If (timeshareNumber == '3' && oppList[0].Timeshare_3_OppProd_Id__c != null){
            attachedProduct = true;	
            oliId = oppList[0].Timeshare_3_OppProd_Id__c;
        }Else If (timeshareNumber == '4' && oppList[0].Timeshare_4_OppProd_Id__c != null){
            attachedProduct = true;	
            oliId = oppList[0].Timeshare_4_OppProd_Id__c;
        }Else If (timeshareNumber == '5' && oppList[0].Timeshare_5_OppProd_Id__c != null){
            attachedProduct = true;	
            oliId = oppList[0].Timeshare_5_OppProd_Id__c;
        }Else If (timeshareNumber == '6' && oppList[0].Timeshare_6_OppProd_Id__c != null){
            attachedProduct = true;	
            oliId = oppList[0].Timeshare_6_OppProd_Id__c;
        }Else If (timeshareNumber == '7' && oppList[0].Timeshare_7_OppProd_Id__c != null){
            attachedProduct = true;	
            oliId = oppList[0].Timeshare_7_OppProd_Id__c;
        }Else If (timeshareNumber == '8' && oppList[0].Timeshare_8_OppProd_Id__c != null){
            attachedProduct = true;	
            oliId = oppList[0].Timeshare_8_OppProd_Id__c;
        }Else If (timeshareNumber == '9' && oppList[0].Timeshare_9_OppProd_Id__c != null){
            attachedProduct = true;	
            oliId = oppList[0].Timeshare_9_OppProd_Id__c;
        }Else If (timeshareNumber == '10' && oppList[0].Timeshare_10_OppProd_Id__c != null){
            attachedProduct = true;
            oliId = oppList[0].Timeshare_10_OppProd_Id__c;
        }
        system.debug('-attachedProduct---'+attachedProduct);
        system.debug('-oliId---'+oliId);
        if(attachedProduct){
            throw new AuraHandledException('Timeshares cant be removed as its attached with product');
        }                                                 
        
        List<OpportunityLineItem> oppLineItem = [SELECT Id,OpportunityId FROM OpportunityLineItem WHERE OpportunityId =: oppId and Timeshare__c =:timeshareId and Id =:oliId];
        List<Timeshare__c> timeshareDelete = [SELECT Id FROM Timeshare__c WHERE Id =:timeshareId];
        if(oppLineItem != null && oppLineItem.size() > 0){
            throw new AuraHandledException('Timeshares cant be removed as its attached with product');
        }                                                 
        if(oppList != null && oppList.size() > 0){
            Opportunity opp = oppList[0];
            if(opp.Timeshare_1__c == timeshareId && timeshareNumber == '1'){
                opp.Timeshare_1__c = null;
            }else if(opp.Timeshare_2__c == timeshareId && timeshareNumber == '2'){
                opp.Timeshare_2__c = null;
            }else if(opp.Timeshare_3__c == timeshareId && timeshareNumber == '3'){
                opp.Timeshare_3__c = null;
            }else if(opp.Timeshare_4__c == timeshareId && timeshareNumber == '4'){
                opp.Timeshare_4__c = null;
            }else if(opp.Timeshare_5__c == timeshareId && timeshareNumber == '5'){
                opp.Timeshare_5__c = null;
            }else if(opp.Timeshare_6__c == timeshareId && timeshareNumber == '6'){
                opp.Timeshare_6__c = null;
                opp.Forbidden_or_Accepted_6__c = null;
            }else if(opp.Timeshare_7__c == timeshareId && timeshareNumber == '7'){
                opp.Timeshare_7__c = null;
                opp.Forbidden_or_Accepted_7__c = null;
            }else if(opp.Timeshare_8__c == timeshareId && timeshareNumber == '8'){
                opp.Timeshare_8__c = null;
                opp.Forbidden_or_Accepted_8__c = null;
            }else if(opp.Timeshare_9__c == timeshareId && timeshareNumber == '9'){
                opp.Timeshare_9__c = null;
                opp.Forbidden_or_Accepted_9__c = null;
            }else if(opp.Timeshare_10__c == timeshareId && timeshareNumber == '10'){
                opp.Timeshare_10__c = null;
                opp.Forbidden_or_Accepted_10__c = null;
                
            }
            try{
                system.debug('--timeshareNumber--'+timeshareNumber); 
                update opp;  
                delete timeshareDelete;
            }catch(exception e){
                return e.getMessage();
            }
        }
        system.debug('-timeshareId--'+timeshareId); 
        system.debug('-oppId--'+oppId);
        return 'true';
    }
    @AuraEnabled
    public static string saveSelectedTimeshare(Id timeshareId, id oppId){
        
        List<Opportunity> oppList = [select id,Timeshare_1__c,Timeshare_2__c,Timeshare_3__c,Timeshare_4__c,Timeshare_5__c,Timeshare_6__c,
                                     Timeshare_7__c,Timeshare_8__c,Timeshare_9__c,Timeshare_10__c,
                                     Timeshare_1__r.Name,Timeshare_2__r.Name,Timeshare_3__r.Name,Timeshare_4__r.Name,Timeshare_5__r.Name,
                                     TS_1_Mortgage__c,TS_2_Mortgage__c,TS_3_Mortgage__c,TS_4_Mortgage__c,TS_5_Mortgage__c,TS_6_Mortgage__c,
                                     TS_7_Mortgage__c,
                                     Forbidden_or_Accepted_1__c,Forbidden_or_Accepted_2__c,Forbidden_or_Accepted_3__c,Forbidden_or_Accepted_4__c,Forbidden_or_Accepted_5__c
                                     
                                     from Opportunity where Id =:oppId];
        system.debug('--timeshareId---'+timeshareId);
        Timeshare__c timeshareObj =  [select id,Preferred_Company__c,Mortgage_Balance__c from Timeshare__c where id =: timeshareId limit 1];
        system.debug('--timeshareObj---'+timeshareObj);
        if(oppList != null && oppList.size() > 0){
            Opportunity opp = oppList[0];
            if(opp.Timeshare_1__c == null){
                opp.Timeshare_1__c = timeshareId;
            }else if(opp.Timeshare_2__c == null){
                opp.Timeshare_2__c = timeshareId;
            }else if(opp.Timeshare_3__c == null){
                opp.Timeshare_3__c = timeshareId;
            }else if(opp.Timeshare_4__c == null){
                opp.Timeshare_4__c = timeshareId;
            }else if(opp.Timeshare_5__c == null){
                opp.Timeshare_5__c = timeshareId;
            }else if(opp.Timeshare_6__c == null){
                opp.Timeshare_6__c = timeshareId;
                opp.Forbidden_or_Accepted_6__c = timeshareObj.Preferred_Company__c;
            }else if(opp.Timeshare_7__c == null){
                opp.Timeshare_7__c = timeshareId;
                opp.Forbidden_or_Accepted_7__c = timeshareObj.Preferred_Company__c;
            }else if(opp.Timeshare_8__c == null){
                opp.Timeshare_8__c = timeshareId;
                opp.Forbidden_or_Accepted_8__c = timeshareObj.Preferred_Company__c;
            }else if(opp.Timeshare_9__c == null){
                opp.Timeshare_9__c = timeshareId;
                opp.Forbidden_or_Accepted_9__c = timeshareObj.Preferred_Company__c;
            }else if(opp.Timeshare_10__c == null){
                opp.Timeshare_10__c = timeshareId;
                opp.Forbidden_or_Accepted_10__c = timeshareObj.Preferred_Company__c;
                
            }
            update opp;
        }
        system.debug('-timeshareId--'+timeshareId); 
        system.debug('-oppId--'+oppId);
        return 'true';
    }
    @AuraEnabled
    public static Timeshare__c selectedTimeshare(Id timeshareId){
        system.debug('--timeshareId--'+timeshareId);
        return [select id,Preferred_Company__c,Mortgage_Balance__c from Timeshare__c where id =: timeshareId limit 1];
    }
    
    @AuraEnabled
    public static Timeshare__c timesharRecordDetails(Id timeshareId){
        return [select id,Resort__c,Contract__c,MF_Amount__c,Ownership__c,Unit_Size__c,
                MF_Paid_Until_Month__c,MF_Paid_Until_Year__c,Unit_Number__c,Past_Due_MF__c,Week__c,Special_Assessment__c,Mortgage_Balance__c,
                Mortgage_Monthly_Payment__c,Year_Purchased__c,Mortgage_Interest_Rate__c,RTU_Year__c,First_Year_Use__c,SMTN_OwnerId__c,Timeshare_Owner__c,
                Annual_Allocation__c,Points_Anniversary_Effective_Date__c,Fees_Billing_Period__c,Bathrooms__c,
                Renewal_Month__c,Usage__c,Occupancy__c,Week_Type__c,View__c,Mortgage__c,Season__c,Points_Program__c,Number_of_past_due_mortgage_payments__c,
                Usage_Fee__c, VIDA_File_Fee_Amount__c,Listing_type__c, Listing_Price__c from Timeshare__c where id =: timeshareId limit 1];
    }
    @AuraEnabled
    public static string updateOpportunity(Id timeshareId, id oppId){
        List<Opportunity> oppList = [select id,Timeshare_1__c,Timeshare_2__c,Timeshare_3__c,Timeshare_4__c,Timeshare_5__c,Timeshare_6__c,
                                     Timeshare_7__c,Timeshare_8__c,Timeshare_9__c,Timeshare_10__c,
                                     Timeshare_1__r.Name,Timeshare_2__r.Name,Timeshare_3__r.Name,Timeshare_4__r.Name,Timeshare_5__r.Name,
                                     TS_1_Mortgage__c,TS_2_Mortgage__c,TS_3_Mortgage__c,TS_4_Mortgage__c,TS_5_Mortgage__c,TS_6_Mortgage__c,
                                     TS_7_Mortgage__c,
                                     Forbidden_or_Accepted_1__c,Forbidden_or_Accepted_2__c,Forbidden_or_Accepted_3__c,Forbidden_or_Accepted_4__c,Forbidden_or_Accepted_5__c
                                     from Opportunity where Id =:oppId];
        Timeshare__c timeshareObj =  [select id,Preferred_Company__c,Mortgage_Balance__c from Timeshare__c where id =: timeshareId limit 1];
        if(oppList != null && oppList.size() > 0){
            Opportunity opp = oppList[0];
            if(opp.Timeshare_1__c == null || opp.Timeshare_1__c ==timeshareId){
                opp.Timeshare_1__c = timeshareId;
            }else if(opp.Timeshare_2__c == null || opp.Timeshare_2__c ==timeshareId){
                opp.Timeshare_2__c = timeshareId;
            }else if(opp.Timeshare_3__c == null || opp.Timeshare_3__c ==timeshareId){
                opp.Timeshare_3__c = timeshareId;
            }else if(opp.Timeshare_4__c == null || opp.Timeshare_4__c ==timeshareId){
                opp.Timeshare_4__c = timeshareId;
            }else if(opp.Timeshare_5__c == null || opp.Timeshare_5__c ==timeshareId){
                opp.Timeshare_5__c = timeshareId;
            }else if(opp.Timeshare_6__c == null || opp.Timeshare_6__c ==timeshareId){
                opp.Timeshare_6__c = timeshareId;
                opp.Forbidden_or_Accepted_6__c = timeshareObj.Preferred_Company__c;
            }else if(opp.Timeshare_7__c == null || opp.Timeshare_7__c ==timeshareId){
                opp.Timeshare_7__c = timeshareId;
                opp.Forbidden_or_Accepted_7__c = timeshareObj.Preferred_Company__c;
            }else if(opp.Timeshare_8__c == null || opp.Timeshare_8__c ==timeshareId){
                opp.Timeshare_8__c = timeshareId;
                opp.Forbidden_or_Accepted_8__c = timeshareObj.Preferred_Company__c;
            }else if(opp.Timeshare_9__c == null || opp.Timeshare_9__c ==timeshareId){
                opp.Timeshare_9__c = timeshareId;
                opp.Forbidden_or_Accepted_9__c = timeshareObj.Preferred_Company__c;
            }else if(opp.Timeshare_10__c == null || opp.Timeshare_10__c ==timeshareId){
                opp.Timeshare_10__c = timeshareId;
                opp.Forbidden_or_Accepted_10__c = timeshareObj.Preferred_Company__c;
                
            }
            try{
                update opp;    
            }catch(exception e){
                return e.getMessage();
            }
        }
        system.debug('-timeshareId--'+timeshareId); 
        system.debug('-oppId--'+oppId);
        return 'true';
    }    
    
    
}