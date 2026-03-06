public class InventoryAvailabilitySearchCtrl {
    //5
    @AuraEnabled
    public static Boolean checkUserPermission(){
        // query current user information  
        Boolean permissionChecked = true;        
        User oUser = [select id,UserRole.Name FROM User Where id =: userInfo.getUserId()];
        if(oUser.UserRole.Name.contains('TourGen Sales Agent'))
        {
            permissionChecked=false;
        }
        return permissionChecked;
    }
    // 1
    @AuraEnabled
    public static searchWrapper AvailabityByDate(Date fromDatevar, Date toDatevar,String oppId,Integer nightsInt,Integer extraNightsInt){ //263 ,Integer extraNightsInt
        searchWrapper wrp = new searchWrapper();
        wrp.InventoryAvailability = InventoryAvailabilitySearch.getAvailabityByDate(fromDatevar,toDatevar,'AllProgram',nightsInt,extraNightsInt); //263 ,extraNightsInt
        wrp.mapforMinNights = InventoryAvailabilitySearch.getMinimumAvailability(fromDatevar,toDatevar,nightsInt,null,null,null,null);
        Map<String,String> mapOfRelatedAcc = new MAp<String,String>();
        
        wrp.locationOption.add(new InventoryAvailabilitySearch.CustomSelectOption('--None--','--None--'));
        wrp.programType.add(new InventoryAvailabilitySearch.CustomSelectOption('--None--','--None--'));
        wrp.programType.add(new InventoryAvailabilitySearch.CustomSelectOption('MKT','MKT'));
        
        /* wrp.programType.add(new InventoryAvailabilitySearch.CustomSelectOption('CBB','CBB')); */
        
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
        return wrp;
    }
    
    //3
    // 2
    @AuraEnabled
    public static searchWrapper getAllResort(String programName,String PlazzaName,Date fromDateValue,Date toDateValue,String oppId,Integer nightsInt,Integer extraNightsInt){  //263
        searchWrapper plazzwrp = new searchWrapper();
        plazzwrp.resortOption.add(new InventoryAvailabilitySearch.CustomSelectOption('--None--','--None--'));
        Set<String> resortNameUnique = new Set<String>();
        plazzwrp.InventoryAvailability = InventoryAvailabilitySearch.getAllResortName(programName,PlazzaName,fromDateValue,toDateValue,'AllProgram',nightsInt,extraNightsInt); //263
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
        
        
        return plazzwrp;
    }
    //3
    @AuraEnabled
    public static searchWrapper roomType(String programName,String resoertName,String PlazzaName,Date fromDateValue,Date toDateValue,String oppId,Integer nightsInt,Integer extraNightsInt){  //263
        searchWrapper wrp = new searchWrapper();
        wrp.roomType.add(new InventoryAvailabilitySearch.CustomSelectOption('--None--','--None--')); 
        Map<String,String> mapOfRelatedAcc = new MAp<String,String>();
        wrp.InventoryAvailability = InventoryAvailabilitySearch.getroomType(programName,resoertName,PlazzaName,fromDateValue,toDateValue,'AllProgram',nightsInt,extraNightsInt);   //263
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
        
        return wrp;
    } 
    //4
    @AuraEnabled
    public static searchWrapper InventoryAvailabilityBasedOnroomType(String programName,String resoertName,String PlazzaName,String roomType,Date fromDateValue,Date toDateValue,String oppId,Integer nightsInt,Integer extraNightsInt){  //263
        searchWrapper wrp = new searchWrapper();
        wrp.InventoryAvailability = InventoryAvailabilitySearch.InventoryAvailabilityBasedOnroomType(programName,resoertName,PlazzaName,roomType,fromDateValue,toDateValue,'AllProgram',nightsInt,extraNightsInt);   //263
        wrp.mapforMinNights = InventoryAvailabilitySearch.getMinimumAvailability(fromDateValue,toDateValue,nightsInt,programName,PlazzaName,resoertName,roomType);
        if(wrp.InventoryAvailability.size() == 0){
            wrp.MessageNote = 'No Availability found based on given search';
        }
        return wrp;
    }
    // 2 - Program type
    @AuraEnabled
    public static searchWrapper getAllProgram(String programName,String resoertName,String PlazzaName,String roomType,Date fromDateValue,Date toDateValue,String oppId,Integer nightsInt,Integer extraNightsInt){  //263
        searchWrapper wrp = new searchWrapper();
        wrp.InventoryAvailability = InventoryAvailabilitySearch.getAllProgram(programName,resoertName,PlazzaName,roomType,fromDateValue,toDateValue,'AllProgram',nightsInt,extraNightsInt);   //263
        wrp.mapforMinNights = InventoryAvailabilitySearch.getMinimumAvailability(fromDateValue,toDateValue,nightsInt,programName,PlazzaName,resoertName,roomType);
        if(wrp.InventoryAvailability.size() == 0){
            wrp.MessageNote = 'No Availability found based on given search';
        }
        return wrp;
    }
    /* 
@AuraEnabled
public static searchWrapper getAllProgram(String programName,String resoertName,String PlazzaName,String roomType,Date fromDateValue,Date toDateValue,String oppId){
searchWrapper plazzwrp = new searchWrapper();
plazzwrp.resortOption.add(new InventoryAvailabilitySearch.CustomSelectOption('--None--','--None--'));
Set<String> resortNameUnique = new Set<String>();
plazzwrp.InventoryAvailability = InventoryAvailabilitySearch.getAllProgram(programName,resoertName,PlazzaName,roomType,fromDateValue,toDateValue,oppId);
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


return plazzwrp;
}
*/
    
    
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
            this.mapforMinNights = new Map<String, Decimal>();
            this.MessageNote = '';
        }
    }
}