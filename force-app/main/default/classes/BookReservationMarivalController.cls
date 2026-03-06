public class BookReservationMarivalController {
    @AuraEnabled(cacheable=true)
    public static List<String> getPlazaRecords(String supplier) {
        List<String> plazalist = new List<String>();
        List<AggregateResult> groupedResults = [SELECT Plaza__c FROM Inventory_Management__c WHERE Supplier__c =:supplier group by Plaza__c];
        for (AggregateResult ar : groupedResults)  {
            System.debug('Plaza__c' + ar.get('Plaza__c'));
            String plaza = (String)ar.get('Plaza__c');
			plazalist.add(plaza);
        }
        return plazalist;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Inventory_Management__c> getInventoryRecords(String supplier, String plaza) {
        return [
            SELECT Id, Plaza__c, Resort_Name__c, Unit_Type__c, Site_Name__c, Site_Name_Id__c, Room_Type__c, Room_Type_ID__c, 
            Capacity__c, Size_Upgrade__c, Property_Upgrade__c, Total_Upgrade__c,Property_Address__c, Property_City__c, 
            Property_State__c, Property_Country__c, Property_Zipcode__c, Supplier__c
            FROM Inventory_Management__c
            WHERE Supplier__c =:supplier and Plaza__c =: plaza];
    }
    
    
    @AuraEnabled
    public static void saveOpportunityDetails(String recordId, String inventoryId, String roomType, Date checkIn, Date checkOut, String capacity, Integer adults, Integer children, String supplier, Integer extraNights) { //312
        Opportunity opp = [SELECT Id, Reservation_Status__c, Site_Name__c, Property__c, Destination__c, Rooms__c, Check_in__c, Check_Out__c, Capacity__c, Property_Address__c, Property_City__c, Property_Country__c, Property_State__c, Property_Zipcode__c,Supplier__c, Inventory_Management_Id__c FROM Opportunity WHERE Id = :recordId LIMIT 1];
        
        Inventory_Management__c inv = [SELECT Id, Plaza__c, Resort_Name__c, Unit_Type__c, Site_Name__c, Site_Name_Id__c, Room_Type__c, Room_Type_ID__c, 
                                       Capacity__c, Size_Upgrade__c, Property_Upgrade__c, Total_Upgrade__c,Property_Address__c, Property_City__c, 
                                       Property_State__c, Property_Country__c, Property_Zipcode__c, Supplier__c, Extra_Night__c
                                       FROM Inventory_Management__c WHERE Id = : inventoryId];
        //system.debug('roomType = '+roomType);
        
        opp.Site_Name__c = inv.Site_Name__c;
        opp.Property__c = inv.Resort_Name__c;
        opp.Rooms__c = inv.Unit_Type__c;
        opp.Check_in__c = checkIn;
        opp.Check_Out__c = checkOut ;  // checkOut.addDays(extraNights) ;  //312
        opp.Capacity__c = inv.Capacity__c;        
        opp.Property_Address__c = inv.Property_Address__c;
        opp.Property_City__c = inv.Property_City__c;
        opp.Property_Country__c = inv.Property_Country__c;
        opp.Property_State__c = inv.Property_State__c;
        opp.Property_Zipcode__c = inv.Property_Zipcode__c;
        opp.Room_Type__c = inv.Room_Type__c;
        opp.Inventory_Management_Id__c = inv.id;
        if(inv.Supplier__c == 'Sunset' || inv.Supplier__c == 'Holidays NG'|| inv.Supplier__c == 'The Fives' || inv.Supplier__c == 'Exploria' || inv.Supplier__c == 'Las Palmas' || inv.Supplier__c == 'Sonesta' || inv.Supplier__c == 'Florida Hotel' || inv.Supplier__c == 'Lifestyle' || inv.Supplier__c == 'Westgate' || inv.Supplier__c == 'Holiday Inn'){     //TGR-234,265,345
            opp.Destination__c = inv.Plaza__c;
        }
        
        System.debug('saveOpportunityDetails Check_Out__c'+opp.Check_Out__c);     //312    
        System.debug('saveOpportunityDetails extraNights'+extraNights);           //312  
        
        // Set additional fields based on the site name
        if (inv.Resort_Name__c.contains('Marival Armony')) {
            opp.Destination__c = 'Marival Armony';
            /*opp.Property_Address__c = 'Carretera a Punta de Mita km 8.3, Playa Destiladeras';
opp.Property_City__c = 'Bahia de Banderas';
opp.Property_Country__c = 'Mexico';
opp.Property_State__c = 'Nayarit';
opp.Property_Zipcode__c = '63734';
opp.Room_Type__c = 'Sierra Room';*/      
            
        } else if (inv.Resort_Name__c.contains('Marival Distinct')) {
            opp.Destination__c = 'Marival Distinct';
            /*opp.Property_Address__c = 'Av, Paseo de los Cocoteros Lt 53, Villa 8';
opp.Property_City__c = 'Nuevo Vallarta';
opp.Property_Country__c = 'Mexico';
opp.Property_State__c = 'Nayarit';
opp.Property_Zipcode__c = '63735';
opp.Room_Type__c = '1 BR Residence';*/
        } else if (inv.Resort_Name__c.contains('Marival Emotions')) {
            opp.Destination__c = 'Marival Emotions';
            /* opp.Property_Address__c = 'Paseo de los Cocoteros S/N';
opp.Property_City__c = 'Nuevo Vallarta';
opp.Property_Country__c = 'Mexico';
opp.Property_State__c = 'Nayarit';
opp.Property_Zipcode__c = '63735';
opp.Room_Type__c = 'Club Room';*/
        }
        opp.Adults__c = String.valueOf(adults);
        opp.Children_0_17__c = String.valueOf(children);
        opp.StageName = 'Closed Booked';
        opp.Supplier__c = inv.Supplier__c;
        
        //2024-05-22
        if(opp.Reservation_Status__c == null || opp.Reservation_Status__c == ''){
            opp.Reservation_Status__c = 'Pending';
        }
        update opp;
        
        
        //312
        //create a new "Additional Nights“ Opportunity Product with price = number of Additional Nights * Inventory_Management__c.Extra_Night__c.
        if(extraNights != null ){
            if(extraNights > 0){
                List<PricebookEntry> pricebookList = [select id ,Name,Pricebook2Id ,Product2Id,UnitPrice from PricebookEntry where IsActive= true and Product2.Name = 'Additional Nights'];
                
                OpportunityLineItem oliAddNights = new OpportunityLineItem();
                oliAddNights.OpportunityId = opp.Id;
                oliAddNights.PricebookEntryId=pricebookList[0].Id;
                oliAddNights.Retail_Price__c = inv.Extra_Night__c ; 
                oliAddNights.Quantity = extraNights ; 
                oliAddNights.TotalPrice = extraNights * inv.Extra_Night__c ; 
                
                insert oliAddNights;
            }
        }
        
        
    }
    
    @AuraEnabled
    public static Opportunity checkbookingifExist(String oppId){
        //oppId = '0067g00000G3DPM';
        String message = '';
        Opportunity oppRecord = [select id,Destination__c,Property__c,Rooms__c,Check_in__c,Check_Out__c,Reservation_Status__c,
                                 Inventory_Availability_Id__c,Capacity__c,Supplier__c  from Opportunity where Id =:oppId];
        return oppRecord;
        
    }
    
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
            AND Product2.Product_Type__c = 'Base' //312
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
 
    @AuraEnabled(cacheable=true)
    public static Decimal getExtraNight(String sitename) {
         
        Inventory_Management__c record = [
            SELECT Extra_Night__c
            FROM Inventory_Management__c
            WHERE id = :sitename
            ];

        // Return the Extra_Night__c field value if the record exists
        return record != null ? record.Extra_Night__c : 0;
 
    }
    
    
}