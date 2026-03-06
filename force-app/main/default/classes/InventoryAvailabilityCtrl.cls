/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 07-08-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   07-08-2021   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/ 
public class InventoryAvailabilityCtrl { 
    // 1
    @AuraEnabled 
    public static searchWrapper AvailabityByDate(Date fromDatevar, Date toDatevar,String oppId,Integer nightsInt,Integer extraNightsInt){  //263 ,Integer extraNightsInt
        System.debug('AvailabityByDate toDatevar = '+toDatevar);
        searchWrapper wrp = new searchWrapper();
        wrp.InventoryAvailability = InventoryAvailabilitySearch.getAvailabityByDate(fromDatevar,toDatevar,oppId,nightsInt,extraNightsInt);   //263 ,extraNightsInt
        wrp.mapforMinNights = InventoryAvailabilitySearch.getMinimumAvailability(fromDatevar,toDatevar,nightsInt,null,null,null,null);
        Map<String,String> mapOfRelatedAcc = new MAp<String,String>();
        boolean isAffresult = InventoryAvailabilitySearch.AffValidate(oppId);
        wrp.locationOption.add(new InventoryAvailabilitySearch.CustomSelectOption('--None--','--None--'));
        wrp.programType.add(new InventoryAvailabilitySearch.CustomSelectOption('--None--','--None--'));
        wrp.programType.add(new InventoryAvailabilitySearch.CustomSelectOption('MKT','MKT'));
       if(isAffresult == true){
        	wrp.programType.add(new InventoryAvailabilitySearch.CustomSelectOption('CBB','CBB'));
        } 
        if(wrp.InventoryAvailability.size() > 0){
           for(Inventory_Availability__c rpInst : wrp.InventoryAvailability){
                mapOfRelatedAcc.put(rpInst.Plaza__c,rpInst.Plaza__c);
            }
            for(String idval : mapOfRelatedAcc.keyset()){ 
                wrp.locationOption.add(new InventoryAvailabilitySearch.CustomSelectOption(mapOfRelatedAcc.get(idval),idval));
            }
        }else{
            wrp.MessageNote = 'No Availability found based on given search';
        }
        system.debug('Date WRP== '+wrp);
        return wrp;
    } 
    // 2
    @AuraEnabled
    public static searchWrapper getAllResort(String programName,String PlazzaName,Date fromDateValue,Date toDateValue,String oppId,Integer nightsInt,Integer extraNightsInt){  //263
        searchWrapper plazzwrp = new searchWrapper();
        plazzwrp.resortOption.add(new InventoryAvailabilitySearch.CustomSelectOption('--None--','--None--'));
        Set<String> resortNameUnique = new Set<String>();
        plazzwrp.InventoryAvailability = InventoryAvailabilitySearch.getAllResortName(programName,PlazzaName,fromDateValue,toDateValue,oppId,nightsInt,extraNightsInt); //263
        plazzwrp.mapforMinNights = InventoryAvailabilitySearch.getMinimumAvailability(fromDateValue,toDateValue,nightsInt,programName,PlazzaName,null,null);
        if(plazzwrp.InventoryAvailability.size() > 0){
            for(Inventory_Availability__c invMng : plazzwrp.InventoryAvailability){                                     
                resortNameUnique.add(invMng.Site_Name__c);
            }
            for(String st : resortNameUnique){                                     
                //finAccWrapper.financialAccList.add(new QRA_CommunityUtility.CustomSelectOption(finAcc.Id,finAcc.Name));
                plazzwrp.resortOption.add(new InventoryAvailabilitySearch.CustomSelectOption(st,st));
                system.debug('--plazzwrp.resortOption--'+plazzwrp.resortOption);
            }
        }else{
            plazzwrp.MessageNote = 'No Availability found based on given search';
        }
        
        system.debug('plazza WRP== '+plazzwrp);
        return plazzwrp;
    }
    
    //3
    @AuraEnabled
    public static searchWrapper roomType(String programName,String resoertName,String PlazzaName,Date fromDateValue,Date toDateValue,String oppId,Integer nightsInt,Integer extraNightsInt){  //263
        searchWrapper wrp = new searchWrapper();
        wrp.roomType.add(new InventoryAvailabilitySearch.CustomSelectOption('--None--','--None--')); 
        Map<String,String> mapOfRelatedAcc = new MAp<String,String>();
        wrp.InventoryAvailability = InventoryAvailabilitySearch.getroomType(programName,resoertName,PlazzaName,fromDateValue,toDateValue,oppId,nightsInt,extraNightsInt); //263
        wrp.mapforMinNights = InventoryAvailabilitySearch.getMinimumAvailability(fromDateValue,toDateValue,nightsInt,programName,PlazzaName,resoertName,null);
        if(wrp.InventoryAvailability.size() > 0){
            for(Inventory_Availability__c rpInst : wrp.InventoryAvailability){
                mapOfRelatedAcc.put(rpInst.Unit_Type__c,rpInst.Unit_Type__c);
            }
            for(String idval : mapOfRelatedAcc.keyset()){ 
                //tranwrapperInst.accRelatedAccList.add(new QRA_CommunityUtility.CustomSelectOption(idval,mapOfRelatedAcc.get(idval)));
                wrp.roomType.add(new InventoryAvailabilitySearch.CustomSelectOption(mapOfRelatedAcc.get(idval),idval));
            }
        }else{
             wrp.MessageNote = 'No Availability found based on given search';
        }
        system.debug('room type== '+wrp);
        return wrp;
    } 
    //4
    @AuraEnabled
    public static searchWrapper InventoryAvailabilityBasedOnroomType(String programName,String resoertName,String PlazzaName,String roomType,Date fromDateValue,Date toDateValue,String oppId,Integer nightsInt,Integer extraNightsInt){  //263
        searchWrapper wrp = new searchWrapper();
        wrp.InventoryAvailability = InventoryAvailabilitySearch.InventoryAvailabilityBasedOnroomType(programName,resoertName,PlazzaName,roomType,fromDateValue,toDateValue,oppId,nightsInt,extraNightsInt); //263
        wrp.mapforMinNights = InventoryAvailabilitySearch.getMinimumAvailability(fromDateValue,toDateValue,nightsInt,programName,PlazzaName,resoertName,roomType);
        if(wrp.InventoryAvailability.size() == 0){
            wrp.MessageNote = 'No Availability found based on given search';
        }
        system.debug('wrp 1 == '+wrp);
        return wrp;
    }
    // 2
    @AuraEnabled
    public static searchWrapper getAllProgram(String programName,String resoertName,String PlazzaName,String roomType,Date fromDateValue,Date toDateValue,String oppId,Integer nightsInt,Integer extraNightsInt){  //263
        searchWrapper wrp = new searchWrapper();
        wrp.InventoryAvailability = InventoryAvailabilitySearch.getAllProgram(programName,resoertName,PlazzaName,roomType,fromDateValue,toDateValue,oppId,nightsInt,extraNightsInt);//263
        wrp.mapforMinNights = InventoryAvailabilitySearch.getMinimumAvailability(fromDateValue,toDateValue,nightsInt,programName,PlazzaName,resoertName,roomType);
        if(wrp.InventoryAvailability.size() == 0){
            wrp.MessageNote = 'No Availability found based on given search';
        }
        return wrp;
    }
    //5
    @AuraEnabled
    public static string bookedInventoryInOppMethod(String selectedInvId,String oppId, String selectedSupplier,Date toDateValue, Integer nightsInt, Integer extraNightsInt){  //263 extraNightsInt
        //oppId = '0067g00000G3DPM';
        String message = '';
        Inventory_Availability__c inv = [select id,Unique_key_for_product_Id__c,Plaza__c,Resort_Name__c,Unit_Type__c,Program__c,Check_In_Date__c,Site_Name__c,Selected__c,New_Availability__c,
                                         Inventory_Management__r.Capacity__c,Inventory_Management__r.Size_Upgrade__c,Inventory_Management__r.Property_Upgrade__c,
                                         Inventory_Management__r.Total_Upgrade__c,Inventory_Management__r.Room_Type__c,
                                         Inventory_Management__r.Property_Address__c,
                                         Inventory_Management__r.Property_City__c,
                                         Inventory_Management__r.Property_State__c,
                                         Inventory_Management__r.Property_Country__c,
                                         Inventory_Management__r.Property_Zipcode__c,
                                         Inventory_Management__r.Property_Phone__c,
                                         Inventory_Management__r.Extra_Night__c //263
                                         from Inventory_Availability__c 
                                         where id =: selectedInvId];
        
        List<Inventory_Availability__c> invsToCheck = InventoryAvailabilitySearch.filteredDateRangeList(new List<Inventory_Availability__c>{inv},toDateValue,nightsInt,extraNightsInt);  //263
        
        if(invsToCheck != null && invsToCheck.size()>0){
            
            Opportunity oppRecord = [select id,Destination__c,Status_Confirmed__c,Room_Type__c,Property__c,Rooms__c,Check_in__c,Check_Out__c,Reservation_Status__c,
                                     Inventory_Availability_Id__c,Property_Address__c,
                                     Property_City__c,Property_State__c,Property_Country__c,Property_Zipcode__c,Supplier__c,
                                     Property_Phone__c,Capacity__c,Record_Type_Name__c from Opportunity where Id =:oppId];
            
            oppRecord.Destination__c = inv.Plaza__c;
            oppRecord.Property__c = inv.Resort_Name__c;
            oppRecord.Program__c = inv.Program__c;
            oppRecord.Site_Name__c = inv.Site_Name__c;
            oppRecord.Rooms__c = inv.Unit_Type__c;
            oppRecord.Check_in__c = inv.Check_In_Date__c;
            oppRecord.Property_Address__c = inv.Inventory_Management__r.Property_Address__c;
            oppRecord.Property_City__c = inv.Inventory_Management__r.Property_City__c;
            oppRecord.Property_State__c = inv.Inventory_Management__r.Property_State__c;
            oppRecord.Property_Country__c = inv.Inventory_Management__r.Property_Country__c;
            oppRecord.Property_Zipcode__c = inv.Inventory_Management__r.Property_Zipcode__c;
            oppRecord.Property_Phone__c = inv.Inventory_Management__r.Property_Phone__c;
            oppRecord.Status_Confirmed__c = false;
            oppRecord.Supplier__c = selectedSupplier;
            if(oppRecord.Check_in__c != null && oppRecord.Supplier__c != 'Marival' && selectedSupplier != 'Marival'){
                //oppRecord.Check_Out__c = oppRecord.Check_in__c.addDays(7);
                oppRecord.Check_Out__c = inv.Check_In_Date__c.addDays(nightsInt+extraNightsInt);  //263
            }
            else if(oppRecord.Check_in__c != null && (oppRecord.Supplier__c == 'Marival' || selectedSupplier == 'Marival')){
                //oppRecord.Check_Out__c = oppRecord.Check_in__c.addDays(4);
                oppRecord.Check_Out__c = inv.Check_In_Date__c.addDays(nightsInt+extraNightsInt);  //263
            }
            oppRecord.Reservation_Status__c = 'Pending';
            if(oppRecord.Reservation_Status__c == 'Pending'){
                //oppRecord.StageName = 'Closed Booked';
            } 
            oppRecord.Inventory_Availability_Id__c  = inv.Id;
            oppRecord.Booking_Agent__c = userinfo.getUserId();
            oppRecord.Capacity__c = inv.Inventory_Management__r.Capacity__c;   
            oppRecord.Room_Type__c = inv.Inventory_Management__r.Room_Type__c;   
            try{
                update oppRecord;
                Map<String, Date> subtractInvMap = new Map<String, Date>();
                subtractInvMap.put(inv.Unique_key_for_product_Id__c,inv.Check_In_Date__c.addDays(nightsInt+extraNightsInt-1)); //263 
                InventoryManager.subtractInventoryAvailability(subtractInvMap);
                /*inv.New_Availability__c = inv.New_Availability__c - 1;
                update inv;*/
                
                
                // Upgrade Opportunity line item
                if(inv.Inventory_Management__r.Total_Upgrade__c != null && inv.Inventory_Management__r.Total_Upgrade__c > 0){
                    List<OpportunityLineItem> oppMXProductList = [select id,MX_Voucher_Product__c from OpportunityLineItem where OpportunityId =: oppId and MX_Voucher_Product__c != null];
                    if(oppMXProductList.size() ==0){
                        List<PricebookEntry> pricebookList = [select id ,Name,Pricebook2Id ,Product2Id,UnitPrice from PricebookEntry where IsActive= true and Product2.Name = 'Upgrade Property'];
                        
                        OpportunityLineItem oli = new OpportunityLineItem();
                        oli.OpportunityId = oppId;
                        oli.PricebookEntryId=pricebookList[0].Id;
                        oli.Retail_Price__c = inv.Inventory_Management__r.Total_Upgrade__c;  
                        oli.TotalPrice = inv.Inventory_Management__r.Total_Upgrade__c;  
                        
                        insert oli;
                    }
                }
                
                //263
                //create a new "Additional Nights“ Opportunity Product with price = number of Additional Nights * Inventory_Management__c.Extra_Night__c.
                if(extraNightsInt != null ){
                    if(extraNightsInt > 0){
                        List<PricebookEntry> pricebookList = [select id ,Name,Pricebook2Id ,Product2Id,UnitPrice from PricebookEntry where IsActive= true and Product2.Name = 'Additional Nights'];

                        OpportunityLineItem oliAddNights = new OpportunityLineItem();
                        oliAddNights.OpportunityId = oppId;
                        oliAddNights.PricebookEntryId=pricebookList[0].Id;
                        oliAddNights.Retail_Price__c = inv.Inventory_Management__r.Extra_Night__c ; 
                        oliAddNights.Quantity = extraNightsInt ; 
                        oliAddNights.TotalPrice = extraNightsInt * inv.Inventory_Management__r.Extra_Night__c ; 
                        
                        insert oliAddNights;
                    }
                }
                				
                
                message = 'Reservation booked';
            }catch(Exception e){
                message = e.getMessage();
            }
        }
        else
        {
            message = 'There\'s no inventory availability for this period, please change.';
        }
        return message;
    }
    //6
    @AuraEnabled
    public static Opportunity checkbookingifExist(String oppId){
        //oppId = '0067g00000G3DPM';
        String message = '';
        Opportunity oppRecord = [select id,Destination__c,Property__c,Rooms__c,Check_in__c,Check_Out__c,Reservation_Status__c,
                                 Inventory_Availability_Id__c,Capacity__c,Record_Type_Name__c,Supplier__c from Opportunity where Id =:oppId];
        return oppRecord;
        
    }
    //7
    @AuraEnabled
    public static Integer getNumberOfNightsByOpportunityId(Id opportunityId) {
       //System.debug('entro no getNumberOfNightsByOpportunityId');
        // Query OpportunityLineItems related to the Opportunity
        Integer non = 7;
        List<OpportunityLineItem> oliList = [
            SELECT Id, Product2.Number_Of_Nights__c 
            FROM OpportunityLineItem 
            WHERE OpportunityId = :opportunityId 
            AND Product2.Number_Of_Nights__c != null
        ];
        
        //System.debug('oliList getNumberOfNightsByOpportunityId '+oliList);
        
        // Iterate through the OpportunityLineItems and return the first non-null Number_Of_Nights__c 
        for (OpportunityLineItem oli : oliList) {
            if (oli.Product2 != null && oli.Product2.Number_Of_Nights__c != null) {
                non = Integer.valueOf(oli.Product2.Number_Of_Nights__c);
            }
        }
        
        // Return null if no suitable OpportunityLineItems were found
        return non;
    }
    //8
    @AuraEnabled
    public static Boolean checkVidantaInfluencerProducts(String oppId){
        List<String> vidantaInfluencerProduct = new List<String>{'Vida Influencer-Grand Mayan Master Room','Vida Influencer-Grand Mayan 1BR Suite','Vida Influencer-Grand Mayan 2BR Suite','Vida Influencer-Grand Luxxe Master Room','Vida Influencer-Grand Luxxe 1BR Suite','Vida Influencer-Grand Luxxe 2BR Suite'};
        List<OpportunityLineItem> opplineRecord = [select id,Product2.Name from OpportunityLineItem where opportunityId =:oppId and Product2.Name IN : vidantaInfluencerProduct];
        if(opplineRecord != null && opplineRecord.size() > 0){
            return true;
        }
        return false;
    }
    
    public class searchWrapper{
        @AuraEnabled
        public String MessageNote;
        @AuraEnabled
        public list<InventoryAvailabilitySearch.CustomSelectOption> locationOption;
        @AuraEnabled
        public List<InventoryAvailabilitySearch.CustomSelectOption> resortOption;
        @AuraEnabled
        public List<InventoryAvailabilitySearch.CustomSelectOption> programType;
        @AuraEnabled
        public List<InventoryAvailabilitySearch.CustomSelectOption> roomType;
        @AuraEnabled
        public List<Inventory_Availability__c> InventoryAvailability;
        @AuraEnabled
        public Map<String, Decimal> mapforMinNights;
        public searchWrapper(){
            this.locationOption = new list<InventoryAvailabilitySearch.CustomSelectOption>();
            this.resortOption = new list<InventoryAvailabilitySearch.CustomSelectOption>();
            this.roomType = new list<InventoryAvailabilitySearch.CustomSelectOption>();
            this.programType = new list<InventoryAvailabilitySearch.CustomSelectOption>();
            this.InventoryAvailability = new List<Inventory_Availability__c>();
            this.MessageNote = '';
            this.mapforMinNights =  new Map<String, Decimal>();
        }
    }
}