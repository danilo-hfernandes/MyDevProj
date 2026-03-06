public class InventoryAvailabilitySearch {
    public static string programMKT = 'MKT';
    //1 
    @AuraEnabled
    public static List<Inventory_Availability__c> getAvailabityByDate(Date fromDate, Date toDate,String oppId,Integer nights,Integer extraNights){ //263 
        system.debug('-fromDate---'+fromDate);  
        system.debug('---toDate-'+toDate);
        system.debug('---toDate-'+oppId);
        boolean isAffresult = InventoryAvailabilitySearch.AffValidate(oppId);
        List<Inventory_Availability__c> InventoryAvailabilityList = new List<Inventory_Availability__c>();
        String InventoryQuery = 'select id,Unique_key_for_without_Checkin_Date__c,Unique_key_for_product_Id__c,Plaza__c,Program__c,Resort_Name__c,Unit_Type__c,Site_Name__c,Check_In_Date__c,Selected__c ,New_Availability__c,Inventory_Management__r.Room_Type__c,Inventory_Management__r.Capacity__c,Inventory_Management__r.Size_Upgrade__c,Inventory_Management__r.Property_Upgrade__c,Inventory_Management__r.Total_Upgrade__c, Inventory_Management__r.Extra_Night__c from Inventory_Availability__c ';  //263
        String QueryWhereCondition = '';
        String QueryExtraNightsCondition = ''; //263
        
        //263 if “Additional Nights” not 0 only return properties with Inventory_Management__c.Extra_Night__c not blank. - inactive
        If (extraNights == null){
            extraNights = 0;
        }        
        //        If (extraNights > 0){
        //        	QueryExtraNightsCondition = ' and Inventory_Management__r.Extra_Night__c > 0 ';
        //        }
        
        if(fromDate != null && toDate == null){
            QueryWhereCondition = 'where Check_In_Date__c = :fromDate and New_Availability__c > 0 and program__c =:programMKT ' + QueryExtraNightsCondition + 'order by Check_In_Date__c ';
            if(isAffresult == false){
                QueryWhereCondition = 'where Check_In_Date__c = :fromDate and New_Availability__c > 0 and program__c =:programMKT ' + QueryExtraNightsCondition + 'order by Check_In_Date__c ';
            }
        }
        if(fromDate == null && toDate != null){
            QueryWhereCondition = 'where Check_In_Date__c = :toDate and New_Availability__c > 0 and program__c =: programMKT ' + QueryExtraNightsCondition + 'order by Check_In_Date__c';
            if(isAffresult == false){
                QueryWhereCondition = 'where Check_In_Date__c = :toDate and New_Availability__c > 0 and program__c =: programMKT ' + QueryExtraNightsCondition + 'order by Check_In_Date__c';
            }
        }
        if(fromDate != null && toDate != null ){
            QueryWhereCondition = 'where Check_In_Date__c >= :fromDate and Check_In_Date__c <= :toDate and New_Availability__c > 0 and program__c = :programMKT ' + QueryExtraNightsCondition + 'order by Check_In_Date__c';
            if(isAffresult == false){
                QueryWhereCondition = 'where Check_In_Date__c >= :fromDate and Check_In_Date__c <= :toDate and New_Availability__c > 0 and program__c = :programMKT' + QueryExtraNightsCondition + ' order by Check_In_Date__c';
            }
        }
        system.debug('-programMKT--'+programMKT);
        system.debug('---find query-'+InventoryQuery+QueryWhereCondition);
        InventoryAvailabilityList = Database.query(InventoryQuery+QueryWhereCondition);       
        system.debug('--InventoryAvailabilityList--'+InventoryAvailabilityList.size());
        return filteredDateRangeList(InventoryAvailabilityList,toDate,nights,extraNights);   //263 extraNights
    }
    
    public static Map<String, Decimal> getMinimumAvailability(Date fromDate, Date toDate,Integer nights,String programName,String PlazzaName,String resoertName,string roomType){
        System.debug('>>>>>'+programName+'>>>'+PlazzaName);
        List<Inventory_Availability__c> InventoryAvailabilityList = new List<Inventory_Availability__c>();
        String InventoryQuery = 'select id,Unique_key_for_without_Checkin_Date__c,Unique_key_for_product_Id__c,Plaza__c,Program__c,Resort_Name__c,Unit_Type__c,Site_Name__c,Check_In_Date__c,Selected__c ,New_Availability__c,Inventory_Management__r.Room_Type__c,Inventory_Management__r.Capacity__c,Inventory_Management__r.Size_Upgrade__c,Inventory_Management__r.Property_Upgrade__c,Inventory_Management__r.Total_Upgrade__c, Inventory_Management__r.Extra_Night__c from Inventory_Availability__c ';  //263
        String QueryWhereCondition = 'where program__c =:programMKT and New_Availability__c > 0';
        if(PlazzaName != null && PlazzaName != '--None--'){
            QueryWhereCondition = QueryWhereCondition + ' and Plaza__c =: PlazzaName';
        }
        if(resoertName != null && resoertName != '--None--'){
            QueryWhereCondition = QueryWhereCondition + ' and Site_Name__c =: resoertName';
        }
        if(roomType != null && roomType != '--None--'){
            QueryWhereCondition = QueryWhereCondition + ' and Unit_Type__c =: roomType';
        }
        if(fromDate != null){ 
            toDate = toDate != null ? toDate: fromDate.addDays(nights);
            QueryWhereCondition = QueryWhereCondition +' and Check_In_Date__c >=:fromDate and Check_In_Date__c <=:toDate order by Check_In_Date__c ASC';            
        }
        system.debug('---find query-'+InventoryQuery+QueryWhereCondition);
        InventoryAvailabilityList = Database.query(InventoryQuery+QueryWhereCondition);       
        system.debug('--InventoryAvailabilityList--'+InventoryAvailabilityList.size());
        Map<String, Decimal> checkInvMap = new Map<String, Decimal>();
        for(Inventory_Availability__c i2 : InventoryAvailabilityList)
        {
            if(checkInvMap.containsKey(i2.Unique_key_for_without_Checkin_Date__c) && checkInvMap.get(i2.Unique_key_for_without_Checkin_Date__c) != null){
                if(i2.New_Availability__c < checkInvMap.get(i2.Unique_key_for_without_Checkin_Date__c)){
                    checkInvMap.put(i2.Unique_key_for_without_Checkin_Date__c, i2.New_Availability__c); 
                }
            }
            else{
                checkInvMap.put(i2.Unique_key_for_without_Checkin_Date__c, i2.New_Availability__c); 
            }
        }
        return checkInvMap;
    }
    public static List<Inventory_Availability__c> filteredDateRangeList(List<Inventory_Availability__c> inventories,Date toDate,Integer nights,Integer extraNights)  //263 +extraNights
    {
        Map<String, Date> invKeyCheckOutMap = new Map<String, Date>();
        for(Inventory_Availability__c i : inventories){
            invKeyCheckOutMap.put(i.Unique_key_for_product_Id__c,i.Check_In_Date__c.addDays(nights+extraNights-1)); //263 +extraNights
        }
        Map<String, Boolean> checkInvMap = InventoryManager.checkInventoryAvailability(invKeyCheckOutMap);
        List<Inventory_Availability__c> InventoryAvailabilityList2 = new List<Inventory_Availability__c>();
        for(Inventory_Availability__c i2 : inventories)
        {
            if(checkInvMap.get(i2.Unique_key_for_product_Id__c) != null)
            {
                if(checkInvMap.get(i2.Unique_key_for_product_Id__c))
                {
                    InventoryAvailabilityList2.add(i2);
                }
            }
        }
        return InventoryAvailabilityList2;
    }
    //2 - Program type
    
    //3
    //2
    @AuraEnabled
    public static List<Inventory_Availability__c> getAllResortName(String programName,String PlazzaName,Date fromDateValue,Date toDateValue,String oppId,Integer nights, Integer extraNights){   //263 +extraNights
        system.debug('-fromDate---'+fromDateValue);
        system.debug('-toDateValue---'+toDateValue);
        system.debug('-programName---'+programName);
        system.debug('-PlazzaName---'+PlazzaName);
        system.debug('-oppId---'+oppId);
        List<Inventory_Availability__c> InventoryAvailabilityList = new List<Inventory_Availability__c>();
        boolean isAffresult = InventoryAvailabilitySearch.AffValidate(oppId);
        String InventoryQuery = 'select id,Unique_key_for_without_Checkin_Date__c,Unique_key_for_product_Id__c,Program__c,Plaza__c,Resort_Name__c,Unit_Type__c,Site_Name__c,Check_In_Date__c,Selected__c,New_Availability__c,Inventory_Management__r.Room_Type__c,Inventory_Management__r.Capacity__c,Inventory_Management__r.Size_Upgrade__c,Inventory_Management__r.Property_Upgrade__c,Inventory_Management__r.Total_Upgrade__c, Inventory_Management__r.Extra_Night__c from Inventory_Availability__c ';  //263
        String QueryWhereCondition = '';
        if(PlazzaName != null && fromDateValue != null && toDateValue == null){
            QueryWhereCondition = 'where Check_In_Date__c = :fromDateValue and Plaza__c =: PlazzaName  and New_Availability__c > 0 and program__c =:programMKT order by Check_In_Date__c';
            if(isAffresult == false){
                QueryWhereCondition = 'where program__c =:programMKT and Check_In_Date__c = :fromDateValue and Plaza__c =: PlazzaName and New_Availability__c > 0 order by Check_In_Date__c';}
        }
        if(PlazzaName != null && fromDateValue == null && toDateValue != null){
            QueryWhereCondition = 'where Check_In_Date__c = :toDateValue and Plaza__c =: PlazzaName  and New_Availability__c > 0 and program__c =:programMKT order by Check_In_Date__c';
            if(isAffresult == false){
                QueryWhereCondition = 'where Check_In_Date__c = :toDateValue and Plaza__c =: PlazzaName  and program__c =:programMKT and New_Availability__c > 0 order by Check_In_Date__c';
            }
        }
        if(PlazzaName != null && fromDateValue != null && toDateValue != null ){
            QueryWhereCondition = 'where Check_In_Date__c >= :fromDateValue and Check_In_Date__c <= :toDateValue and Plaza__c =: PlazzaName  and New_Availability__c > 0 and program__c =:programMKT  order by Check_In_Date__c';
            if(isAffresult == false){
                QueryWhereCondition = 'where Check_In_Date__c >= :fromDateValue and Check_In_Date__c <= :toDateValue and Plaza__c =: PlazzaName and program__c =:programMKT and New_Availability__c > 0 order by Check_In_Date__c';
            }
        }
        system.debug('-programName--'+programName);
        if(PlazzaName != null && fromDateValue != null && toDateValue != null ){
            QueryWhereCondition = 'where Check_In_Date__c >= :fromDateValue and Check_In_Date__c <= :toDateValue and Plaza__c =: PlazzaName and New_Availability__c > 0 and program__c =:programMKT order by Check_In_Date__c';
            if(isAffresult == false){
                QueryWhereCondition = 'where Check_In_Date__c >= :fromDateValue and program__c =:programMKT and Check_In_Date__c <= :toDateValue and Plaza__c =: PlazzaName and New_Availability__c > 0 order by Check_In_Date__c';
            }
        }
        system.debug('---find query-'+InventoryQuery+QueryWhereCondition);
        InventoryAvailabilityList = Database.query(InventoryQuery+QueryWhereCondition); 
        system.debug('--InventoryAvailabilityList--'+InventoryAvailabilityList.size());
        return filteredDateRangeList(InventoryAvailabilityList,toDateValue,nights,extraNights); // 263 ,extraNights
    }
    //3
    @AuraEnabled
    public static List<Inventory_Availability__c> getroomType(String programName,String resoertName,String PlazzaName,Date fromDateValue,Date toDateValue,String oppId,Integer nights,Integer extraNights){  //263 +extraNights
        system.debug('-fromDate---'+fromDateValue);
        system.debug('-toDateValue---'+toDateValue);
        system.debug('-programName---'+programName);
        system.debug('-PlazzaName---'+PlazzaName);
        system.debug('-resoertName---'+resoertName);
        system.debug('-oppId---'+oppId);
        List<Inventory_Availability__c> InventoryAvailabilityList = new List<Inventory_Availability__c>();
        boolean isAffresult = InventoryAvailabilitySearch.AffValidate(oppId);
        String InventoryQuery = 'select id,Unique_key_for_without_Checkin_Date__c,Unique_key_for_product_Id__c,Program__c,Plaza__c,Resort_Name__c,Unit_Type__c,Check_In_Date__c,Site_Name__c,Selected__c,New_Availability__c,Inventory_Management__r.Room_Type__c,Inventory_Management__r.Capacity__c,Inventory_Management__r.Size_Upgrade__c,Inventory_Management__r.Property_Upgrade__c,Inventory_Management__r.Total_Upgrade__c, Inventory_Management__r.Extra_Night__c from Inventory_Availability__c ';   //263
        String QueryWhereCondition = '';
        if(resoertName != null && PlazzaName != null && fromDateValue != null && toDateValue == null){
            QueryWhereCondition = 'where Check_In_Date__c = :fromDateValue and Plaza__c =: PlazzaName  and Site_Name__c =:resoertName  and New_Availability__c > 0 and program__c =:programMKT order by Check_In_Date__c';
            if(isAffresult == false){
                QueryWhereCondition = 'where Check_In_Date__c = :fromDateValue and Plaza__c =: PlazzaName and program__c =:programMKT and Site_Name__c =:resoertName  and New_Availability__c > 0 order by Check_In_Date__c';
            }
        }
        if(resoertName != null && PlazzaName != null && fromDateValue == null && toDateValue != null){
            QueryWhereCondition = 'where Check_In_Date__c = :toDateValue and Plaza__c =: PlazzaName  and Site_Name__c =:resoertName  and New_Availability__c > 0 and program__c =:programMKT order by Check_In_Date__c';
            if(isAffresult == false){
                QueryWhereCondition = 'where Check_In_Date__c = :toDateValue and Plaza__c =: PlazzaName and program__c =:programMKT and Site_Name__c =:resoertName  and New_Availability__c > 0 order by Check_In_Date__c';
            }
        }
        if(resoertName != null &&  PlazzaName != null && fromDateValue != null && toDateValue != null ){
            QueryWhereCondition = 'where Check_In_Date__c >= :fromDateValue and Check_In_Date__c <= :toDateValue and Plaza__c =: PlazzaName and  Site_Name__c  =:resoertName  and New_Availability__c > 0 and program__c =:programMKT  order by Check_In_Date__c';
            if(isAffresult == false){
                QueryWhereCondition = 'where Check_In_Date__c >= :fromDateValue and Check_In_Date__c <= :toDateValue and Plaza__c =: PlazzaName and program__c =:programMKT and Site_Name__c  =:resoertName  and New_Availability__c > 0 order by Check_In_Date__c';
            }
        }
        if(resoertName != null &&  PlazzaName != null && fromDateValue != null && toDateValue != null ){
            QueryWhereCondition = 'where Check_In_Date__c >= :fromDateValue and Check_In_Date__c <= :toDateValue and Plaza__c =: PlazzaName and Site_Name__c  =:resoertName  and New_Availability__c > 0 and program__c =:programMKT  order by Check_In_Date__c';
            if(isAffresult == false){
                QueryWhereCondition = 'where Check_In_Date__c >= :fromDateValue and Check_In_Date__c <= :toDateValue and Plaza__c =: PlazzaName and program__c =:programMKT AND  Site_Name__c  =:resoertName  and New_Availability__c > 0 order by Check_In_Date__c';
            }
        } 
        
        system.debug('---find query-'+InventoryQuery+QueryWhereCondition);
        InventoryAvailabilityList = Database.query(InventoryQuery+QueryWhereCondition);  
        system.debug('--InventoryAvailabilityList--'+InventoryAvailabilityList.size());
        return filteredDateRangeList(InventoryAvailabilityList,toDateValue,nights, extraNights);  //263 +extraNights
    }
    //4
    @AuraEnabled
    public static List<Inventory_Availability__c> InventoryAvailabilityBasedOnroomType(String programName,String resoertName,String PlazzaName,string roomType,Date fromDateValue,Date toDateValue,String oppId,Integer nights,Integer extraNights){   //263 +extraNights
        system.debug('-fromDate---'+fromDateValue);
        system.debug('-toDateValue---'+toDateValue);
        system.debug('-programName---'+programName);
        system.debug('-PlazzaName---'+PlazzaName);
        system.debug('-resoertName---'+resoertName);
        system.debug('-roomType---'+roomType);
        system.debug('-oppId---'+oppId);
        List<Inventory_Availability__c> InventoryAvailabilityList = new List<Inventory_Availability__c>();
        boolean isAffresult = InventoryAvailabilitySearch.AffValidate(oppId);
        String InventoryQuery = 'select id,Unique_key_for_without_Checkin_Date__c,Unique_key_for_product_Id__c,Program__c,Plaza__c,Resort_Name__c,Unit_Type__c,Check_In_Date__c,Site_Name__c,Selected__c,New_Availability__c,Inventory_Management__r.Room_Type__c,Inventory_Management__r.Capacity__c,Inventory_Management__r.Size_Upgrade__c,Inventory_Management__r.Property_Upgrade__c,Inventory_Management__r.Total_Upgrade__c, Inventory_Management__r.Extra_Night__c from Inventory_Availability__c ';  //263
        String QueryWhereCondition = '';
        if(resoertName != null && PlazzaName != null && fromDateValue != null && toDateValue == null){
            QueryWhereCondition = 'where Check_In_Date__c = :fromDateValue and Plaza__c =: PlazzaName  and Site_Name__c =:resoertName and Unit_Type__c =:roomType  and New_Availability__c > 0 and program__c =:programMKT  order by Check_In_Date__c';
            if(isAffresult == false){
                QueryWhereCondition = 'where Check_In_Date__c = :fromDateValue and Plaza__c =: PlazzaName and program__c =:programMKT and Site_Name__c =:resoertName and Unit_Type__c =:roomType  and New_Availability__c > 0  order by Check_In_Date__c';
            }
        }
        if(resoertName != null && PlazzaName != null && fromDateValue == null && toDateValue != null){
            QueryWhereCondition = 'where Check_In_Date__c = :toDateValue and Plaza__c =: PlazzaName  and  Site_Name__c =:resoertName and Unit_Type__c =:roomType  and New_Availability__c > 0 and program__c =:programMKT  order by Check_In_Date__c';
            if(isAffresult == false){
                QueryWhereCondition = 'where Check_In_Date__c = :toDateValue and Plaza__c =: PlazzaName  and program__c =:programMKT and Site_Name__c =:resoertName and Unit_Type__c =:roomType  and New_Availability__c > 0  order by Check_In_Date__c';
            }
        }
        if(resoertName != null &&  PlazzaName != null && fromDateValue != null && toDateValue != null ){
            QueryWhereCondition = 'where Check_In_Date__c >= :fromDateValue and Check_In_Date__c <= :toDateValue and Plaza__c =: PlazzaName and  Site_Name__c =:resoertName and Unit_Type__c =:roomType  and New_Availability__c > 0 and program__c =:programMKT order by Check_In_Date__c';
            if(isAffresult == false){
                QueryWhereCondition = 'where Check_In_Date__c >= :fromDateValue and Check_In_Date__c <= :toDateValue and Plaza__c =: PlazzaName and program__c =:programMKT and Site_Name__c =:resoertName and Unit_Type__c =:roomType  and New_Availability__c > 0 order by Check_In_Date__c';
            }
        }
        if(resoertName != null &&  PlazzaName != null && fromDateValue != null && toDateValue != null ){
            QueryWhereCondition = 'where Check_In_Date__c >= :fromDateValue and Check_In_Date__c <= :toDateValue and Plaza__c =: PlazzaName and Site_Name__c =:resoertName and Unit_Type__c =:roomType  and New_Availability__c > 0 and program__c =:programMKT order by Check_In_Date__c';
            if(isAffresult == false){
                QueryWhereCondition = 'where Check_In_Date__c >= :fromDateValue and Check_In_Date__c <= :toDateValue and Plaza__c =: PlazzaName and program__c =:programMKT and Site_Name__c =:resoertName and Unit_Type__c =:roomType  and New_Availability__c > 0 order by Check_In_Date__c';
            }
        }
        system.debug('---find query-'+InventoryQuery+QueryWhereCondition);
        InventoryAvailabilityList = Database.query(InventoryQuery+QueryWhereCondition); 
        system.debug('--InventoryAvailabilityList--'+InventoryAvailabilityList.size());
        return filteredDateRangeList(InventoryAvailabilityList,toDateValue,nights, extraNights);  //263 +extraNights
        
    }
    @AuraEnabled
    public static List<Inventory_Availability__c> getAllProgram(String programName,String resoertName,String PlazzaName,string roomType,Date fromDateValue,Date toDateValue,String oppId,Integer nights ,Integer extraNights){  //263 +extraNights
        system.debug('-fromDate---'+fromDateValue);
        system.debug('-toDateValue---'+toDateValue);
        system.debug('-programName---'+programName);
        system.debug('-PlazzaName---'+PlazzaName);
        system.debug('-resoertName---'+resoertName);
        system.debug('-roomType---'+roomType);
        system.debug('-oppId---'+oppId);
        List<Inventory_Availability__c> InventoryAvailabilityList = new List<Inventory_Availability__c>();
        boolean isAffresult = InventoryAvailabilitySearch.AffValidate(oppId);
        String InventoryQuery = 'select id,Unique_key_for_without_Checkin_Date__c,Unique_key_for_product_Id__c,Program__c,Plaza__c,Resort_Name__c,Unit_Type__c,Check_In_Date__c,Site_Name__c,Selected__c,New_Availability__c,Inventory_Management__r.Room_Type__c,Inventory_Management__r.Capacity__c,Inventory_Management__r.Size_Upgrade__c,Inventory_Management__r.Property_Upgrade__c,Inventory_Management__r.Total_Upgrade__c, Inventory_Management__r.Extra_Night__c from Inventory_Availability__c ';  //263
        String QueryWhereCondition = '';
        /*if(programName != '--None--' && resoertName != null && PlazzaName != null && fromDateValue != null && toDateValue == null){
QueryWhereCondition = 'where Check_In_Date__c = :fromDateValue and Plaza__c =: PlazzaName and Program__c =: programName and Site_Name__c =:resoertName and Unit_Type__c =:roomType  and New_Availability__c > 0  order by Check_In_Date__c';
}
if(programName != '--None--' && resoertName != null && PlazzaName != null && fromDateValue == null && toDateValue != null){
QueryWhereCondition = 'where Check_In_Date__c = :toDateValue and Plaza__c =: PlazzaName  and Program__c =: programName and Site_Name__c =:resoertName and Unit_Type__c =:roomType  and New_Availability__c > 0  order by Check_In_Date__c';
}
if(programName != '--None--' && resoertName != null &&  PlazzaName != null && fromDateValue != null && toDateValue != null ){
QueryWhereCondition = 'where Check_In_Date__c >= :fromDateValue and Check_In_Date__c <= :toDateValue and Plaza__c =: PlazzaName and Program__c =: programName and Site_Name__c =:resoertName and Unit_Type__c =:roomType  and New_Availability__c > 0 order by Check_In_Date__c';
}
if(programName == '--None--' && resoertName != null &&  PlazzaName != null && fromDateValue != null && toDateValue != null ){
QueryWhereCondition = 'where Check_In_Date__c >= :fromDateValue and Check_In_Date__c <= :toDateValue and Plaza__c =: PlazzaName and Site_Name__c =:resoertName and Unit_Type__c =:roomType  and New_Availability__c > 0 order by Check_In_Date__c';
if(isAffresult == false){
QueryWhereCondition = 'where Check_In_Date__c >= :fromDateValue and Check_In_Date__c <= :toDateValue and Plaza__c =: PlazzaName and Site_Name__c =:resoertName and Unit_Type__c =:roomType  and New_Availability__c > 0 order by Check_In_Date__c';
}
}*/
        
        if(fromDateValue != null && toDateValue == null){
            QueryWhereCondition = 'where Check_In_Date__c >= :fromDateValue and program__c =:programMKT ';
        }
        if(fromDateValue == null && toDateValue != null){
            QueryWhereCondition = 'where Check_In_Date__c <= :toDateValue and program__c =:programMKT ';
        }
        if(fromDateValue != null && toDateValue != null){
            QueryWhereCondition = 'where Check_In_Date__c >= :fromDateValue and Check_In_Date__c <= :toDateValue and program__c =:programMKT ';
        }
        if(PlazzaName != null && PlazzaName != '--None--'){
            QueryWhereCondition = QueryWhereCondition + ' and Plaza__c =: PlazzaName and program__c =:programMKT ';
        }
        if(resoertName != null && resoertName != '--None--'){
            QueryWhereCondition = QueryWhereCondition + ' and Site_Name__c =: resoertName and program__c =:programMKT ';
        }
        if(roomType != null && roomType != '--None--'){
            QueryWhereCondition = QueryWhereCondition + ' and Unit_Type__c =: roomType and program__c =:programMKT ';
        }
        If(programName != '--None--'){
            QueryWhereCondition = QueryWhereCondition + ' and program__c =:programMKT ';
        }
        QueryWhereCondition = QueryWhereCondition + ' and New_Availability__c > 0 and program__c =:programMKT order by Check_In_Date__c';
        
        system.debug('---find query-'+InventoryQuery+QueryWhereCondition);
        InventoryAvailabilityList = Database.query(InventoryQuery+QueryWhereCondition); 
        system.debug('--InventoryAvailabilityList--'+InventoryAvailabilityList.size());
        return filteredDateRangeList(InventoryAvailabilityList,toDateValue,nights,extraNights); //263 +extraNights
        
    }
    /*  public static List <CustomSelectOption> getselectOptions(string sobjectType, string fieldName,String oppId) {

List<customSelectOption> options = new List<customSelectOption>(); 
Schema.DescribeFieldResult fieldResult =Schema.getGlobalDescribe().get(sobjectType).getDescribe().fields.getMap().get(fieldName).getDescribe();
List<Schema.PicklistEntry> pickListEntryValues = fieldResult.getPicklistValues();

for (Schema.PicklistEntry f: pickListEntryValues) {
options.add(new customSelectOption(f.getLabel(), f.getValue()));
}

return options;
} */
    // Class used for custom Select option feature
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
    public Static boolean AffValidate(String RecordId){
        if(RecordId == 'AllProgram'){
            return true;
        }
        Opportunity oppRecord = [select id ,account.Affiliate_Name__c from Opportunity where Id = :RecordId];
        List<Mayan_Affiliate_List__c> mayanAffList = [select id,Affiliate_Name__c,Membership_Product_Config_Ext_Db__c from Mayan_Affiliate_List__c where Affiliate_Name__c =: oppRecord.account.Affiliate_Name__c];
        system.debug('--oppRecord.account.Affiliate_Name__c--'+oppRecord.account.Affiliate_Name__c);
        if(mayanAffList != null && mayanAffList.size() > 0){
            return true;
        }else{
            return false;
        }
    } 
    
}