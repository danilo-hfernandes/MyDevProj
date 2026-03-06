public class MXVoucherProductController {
    @AuraEnabled
    public static searchWrapper getAllProductNames(){
        searchWrapper wrp = new searchWrapper();
        Map<String,String> mapOfProducts = new Map<String,String>();
        
        wrp.productOption.add(new MXVoucherAvailabilitySearch.CustomSelectOption('--None--','--None--'));
        wrp.locationOption.add(new MXVoucherAvailabilitySearch.CustomSelectOption('--None--','--None--'));
        wrp.SectionOption.add(new MXVoucherAvailabilitySearch.CustomSelectOption('--None--','--None--'));
        wrp.RoomSizeOption.add(new MXVoucherAvailabilitySearch.CustomSelectOption('--None--','--None--'));
        
        wrp.MXVoucherAvailability = MXVoucherAvailabilitySearch.getProductDetails(); 
        if(wrp.MXVoucherAvailability.size() > 0){
            for(MX_Voucher_Product__c rpInst : wrp.MXVoucherAvailability){
                mapOfProducts.put(rpInst.Product_Name__c,rpInst.Product_Name__c);
                
            }
            for(String idval : mapOfProducts.keyset()){ 
                wrp.productOption.add(new MXVoucherAvailabilitySearch.CustomSelectOption(mapOfProducts.get(idval),idval));
            }
        }else{
            wrp.MessageNote = 'No Products found based on given search';
        }
        return wrp;
    }
    
    @AuraEnabled
    public static searchWrapper AvailabityCheck(String productName){
        searchWrapper wrp = new searchWrapper();
        Map<String,String> mapOfLocation = new Map<String,String>();
        Map<String,String> mapOfSectionName = new Map<String,String>();
        Map<String,String> mapOfRoomSize	 = new Map<String,String>();
        
        wrp.locationOption.add(new MXVoucherAvailabilitySearch.CustomSelectOption('--None--','--None--'));
        wrp.SectionOption.add(new MXVoucherAvailabilitySearch.CustomSelectOption('--None--','--None--'));
        wrp.RoomSizeOption.add(new MXVoucherAvailabilitySearch.CustomSelectOption('--None--','--None--'));
        
        wrp.MXVoucherAvailability = MXVoucherAvailabilitySearch.getAvailabity(productName); 
        if(wrp.MXVoucherAvailability.size() > 0){
            for(MX_Voucher_Product__c rpInst : wrp.MXVoucherAvailability){
                mapOfLocation.put(rpInst.Location__c,rpInst.Location__c);
                
            }
            for(String idval : mapOfLocation.keyset()){ 
                wrp.locationOption.add(new MXVoucherAvailabilitySearch.CustomSelectOption(mapOfLocation.get(idval),idval));
            }
        }else{
            wrp.MessageNote = 'No Availability found based on given search';
        }
        return wrp;
    }
    
    // 2
    @AuraEnabled
    public static searchWrapper getAllResort(String LocationName, String productName){
        searchWrapper plazzwrp = new searchWrapper();
        plazzwrp.SectionOption.add(new MXVoucherAvailabilitySearch.CustomSelectOption('--None--','--None--'));
        Set<String> resortNameUnique = new Set<String>();
        plazzwrp.MXVoucherAvailability = MXVoucherAvailabilitySearch.getAllResortName(LocationName,productName);
        if(plazzwrp.MXVoucherAvailability.size() > 0){
            for(MX_Voucher_Product__c invMng : plazzwrp.MXVoucherAvailability){                                     
                resortNameUnique.add(invMng.Section_Name__c);
            }
            for(String st : resortNameUnique){                                     
                //finAccWrapper.financialAccList.add(new QRA_CommunityUtility.CustomSelectOption(finAcc.Id,finAcc.Name));
                plazzwrp.SectionOption.add(new MXVoucherAvailabilitySearch.CustomSelectOption(st,st));
                system.debug('--plazzwrp.SectionOption--'+plazzwrp.SectionOption);
            }
        }else{
            plazzwrp.MessageNote = 'No Availability found based on given search';
        }
        return plazzwrp;
    }
    
    //3
    @AuraEnabled
    public static searchWrapper roomType(String LocationName,String SectionName, String productName){
        searchWrapper wrp = new searchWrapper();
        wrp.roomType.add(new MXVoucherAvailabilitySearch.CustomSelectOption('--None--','--None--')); 
        Map<String,String> mapOfLocation = new MAp<String,String>();
        wrp.MXVoucherAvailability = MXVoucherAvailabilitySearch.getroomSize(LocationName,SectionName,productName);
        
        if(wrp.MXVoucherAvailability.size() > 0){
            for(MX_Voucher_Product__c rpInst : wrp.MXVoucherAvailability){
                mapOfLocation.put(rpInst.Room_Size__c,rpInst.Room_Size__c);
            }
            for(String idval : mapOfLocation.keyset()){ 
                //tranwrapperInst.accRelatedAccList.add(new QRA_CommunityUtility.CustomSelectOption(idval,mapOfLocation.get(idval)));
                wrp.roomType.add(new MXVoucherAvailabilitySearch.CustomSelectOption(mapOfLocation.get(idval),idval));
            }
        }else{
            wrp.MessageNote = 'No Availability found based on given search';
        }
        
        return wrp;
    } 
    
    @AuraEnabled
    public static searchWrapper getAllProgram(String resoertName,String PlazzaName,String roomType, String productName){
        searchWrapper wrp = new searchWrapper();
        wrp.MXVoucherAvailability = MXVoucherAvailabilitySearch.getAllProgram(resoertName,PlazzaName,roomType,productName);
        if(wrp.MXVoucherAvailability.size() == 0){
            wrp.MessageNote = 'No Availability found based on given search';
        }
        return wrp;
    }
    @AuraEnabled  
    public static String closeMethod() {  
        return 'Success';  
    }  
    
    public class searchWrapper{
        @AuraEnabled
        public String MessageNote;
         @AuraEnabled
        public list<MXVoucherAvailabilitySearch.CustomSelectOption> productOption;
        @AuraEnabled
        public list<MXVoucherAvailabilitySearch.CustomSelectOption> locationOption;
        @AuraEnabled
        public List<MXVoucherAvailabilitySearch.CustomSelectOption> SectionOption;
        @AuraEnabled
        public List<MXVoucherAvailabilitySearch.CustomSelectOption> RoomSizeOption;
        @AuraEnabled
        public List<MXVoucherAvailabilitySearch.CustomSelectOption> roomType;
        @AuraEnabled
        public List<MX_Voucher_Product__c> MXVoucherAvailability;
        public searchWrapper(){
            this.productOption = new list<MXVoucherAvailabilitySearch.CustomSelectOption>();
            this.locationOption = new list<MXVoucherAvailabilitySearch.CustomSelectOption>();
            this.SectionOption = new list<MXVoucherAvailabilitySearch.CustomSelectOption>();
            this.roomType = new list<MXVoucherAvailabilitySearch.CustomSelectOption>();
            this.RoomSizeOption = new list<MXVoucherAvailabilitySearch.CustomSelectOption>();
            this.MXVoucherAvailability = new List<MX_Voucher_Product__c>();
        }
    }
    @AuraEnabled
    public static OpportunityLineItem CreateProduct(String selectedMXId, String oppId, Decimal inputPrice, String productName){
        system.debug('inputPrice---'+inputPrice);
        if(selectedMXId != null){
            MX_Voucher_Product__c mxvoucherQuery = [Select id ,Location__c,Input_Price__c,Minimal_Price__c,Room_Size__c,Section_Name__c,Suggested_Price__c from MX_Voucher_Product__c Where id=:selectedMXId]; 
            List<PricebookEntry> pricebookList = [select id ,Name,Pricebook2Id ,Product2Id,UnitPrice from PricebookEntry where IsActive= true and Product2.Name =: productName];//Product2.Name = 'MX Voucher'];
            
            
            List<OpportunityLineItem> oppProductList = new List<OpportunityLineItem>();
            OpportunityLineItem oli = new OpportunityLineItem();
            oli.OpportunityId = oppId;
            system.debug('--inputPrice--'+inputPrice); 
            if(inputPrice != null && inputPrice != 0){
            	oli.Retail_Price__c = inputPrice;  
            }else{
                oli.Retail_Price__c = mxvoucherQuery.Suggested_Price__c;
            }
            oli.MX_Voucher_Product__c = mxvoucherQuery.Id;
            oli.TotalPrice = inputPrice;  
            //oli.UnitPrice= inputPrice;
            oli.Location__c= mxvoucherQuery.Location__c;
            oli.Section_Name__c = mxvoucherQuery.Section_Name__c;
            oli.Room_Size__c = mxvoucherQuery.Room_Size__c;
            oli.PricebookEntryId=pricebookList[0].Id;
            
            try{
                insert oli;
                system.debug('--oli--'+oli);    
                
            }catch (Exception ex){
                ApexPages.Message msg = new ApexPages.Message(Apexpages.Severity.ERROR, ex.getdmlMessage(0) );
                String errorMessage = string.valueof(msg);
                system.debug('---e---'+ex+'---line---'+ex.getLineNumber());
                if(errorMessage.contains('The minimum price for Hawaii Collection')){
                    throw new AuraHandledException('The minimum price for Hawaii Collection Silver is $995 and Hawaii Collection Gold is $1695 and Hawaii Collection Platinum is 3095');    
                }
            }
            system.debug('---create lineite,');
            return oli;
        }
        return null;
    }
}