global class CreateFlightConfirmationCaseBatch implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        Id voucherRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Voucher').getRecordTypeId();
        Id referralDateRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('VI_Referral_Date_Request').getRecordTypeId();
        Id profitAgilityRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Profit_Agility_Voucher').getRecordTypeId();// ticket PA2-79 
        Id BulkSalesCouponRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Bulk_Sales_Coupon').getRecordTypeId();
        Id marivalRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Marival').getRecordTypeId(); // ticket HSIMU2-984
        Id hookedVoucherRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Hooked_Voucher').getRecordTypeId(); //TGR-234 
        
        String todayDate = string.valueOf(system.today());
        String todayPlus180 = string.valueOf(system.today().addDays(90));//08/02/2023 Updated from 60 to 90 // Updated on 17/7/2023 from 90 days to 60 days 
        
        //TGR-265  //Added: ( ... OR Supplier__c = \'Exploria\' and Las Palmas )  
        String query = 'SELECT Id, Supplier__c, AccountId, VI_Referral_Comments__c, RecordType.Name,RecordType.DeveloperName, Account.Name, Flight_Confirmation_Case_Created__c,Check_in__c,Member_Number__c, Affiliated_Id__c , LeadSource, Account.affiliated_Id__c, Account.Accountsource, LeadSource_Formula__c FROM Opportunity WHERE (RecordTypeId =\''+String.escapeSingleQuotes(marivalRecordTypeId)+'\' OR RecordTypeId =\''+String.escapeSingleQuotes(voucherRecordTypeId)+'\' OR RecordTypeId =\''+String.escapeSingleQuotes(referralDateRecordTypeId)+'\' OR RecordTypeId =\''+String.escapeSingleQuotes(BulkSalesCouponRecordTypeId)+'\' OR RecordTypeId =\''+String.escapeSingleQuotes(profitAgilityRecordTypeId)+'\' OR (RecordTypeId =\''+String.escapeSingleQuotes(hookedVoucherRecordTypeId)+'\' AND (Supplier__c = \'Holidays NG\' OR Supplier__c = \'Exploria\'  OR Supplier__c = \'Las Palmas\' OR Supplier__c = \'Sonesta\' OR Supplier__c = \'Florida Hotel\' OR Supplier__c = \'Lifestyle\' OR Supplier__c = \'Westgate\' OR Supplier__c = \'Holiday Inn\' ))) AND Arrival_Airport__c = NULL AND Flight_Number__c = NULL AND Arrival_Date__c = NULL AND Check_in__c >= '+todayDate+'  AND Check_in__c <= '+todayPlus180+'  AND (First_Payment_Made__c = true OR First_Payment_Date__c != null) AND (StageName = \'Closed Won\' OR StageName = \'Closed Won-Deposit\' OR StageName = \'Closed Booked\' ) AND  Flight_Confirmation_Case_Created__c != true AND Reservation_Status__c =  \'Confirmed\' AND Transportation__c !=  \'Not Required-Driving\' ';
        
        //test
        //query = 'SELECT Id, Supplier__c, AccountId, VI_Referral_Comments__c, RecordType.Name,RecordType.DeveloperName, Account.Name, Flight_Confirmation_Case_Created__c,Check_in__c,Member_Number__c, Affiliated_Id__c , LeadSource, Account.affiliated_Id__c, Account.Accountsource, LeadSource_Formula__c FROM Opportunity WHERE (RecordTypeId =\''+String.escapeSingleQuotes(marivalRecordTypeId)+'\' OR RecordTypeId =\''+String.escapeSingleQuotes(voucherRecordTypeId)+'\' OR RecordTypeId =\''+String.escapeSingleQuotes(referralDateRecordTypeId)+'\' OR RecordTypeId =\''+String.escapeSingleQuotes(BulkSalesCouponRecordTypeId)+'\' OR RecordTypeId =\''+String.escapeSingleQuotes(profitAgilityRecordTypeId)+'\' OR (RecordTypeId =\''+String.escapeSingleQuotes(hookedVoucherRecordTypeId)+'\' AND (Supplier__c = \'Holidays NG\' OR Supplier__c = \'Exploria\'  OR Supplier__c = \'Las Palmas\' OR Supplier__c = \'Sonesta\' OR Supplier__c = \'Florida Hotel\' OR Supplier__c = \'Lifestyle\' OR Supplier__c = \'Westgate\' OR Supplier__c = \'Holiday Inn\' ))) AND Arrival_Airport__c = NULL AND Flight_Number__c = NULL AND Arrival_Date__c = NULL AND Check_in__c >= '+todayDate+'  AND Check_in__c <= '+todayPlus180+'  AND (First_Payment_Made__c = true OR First_Payment_Date__c != null) AND (StageName = \'Closed Won\' OR StageName = \'Closed Won-Deposit\' OR StageName = \'Closed Booked\' ) AND  Flight_Confirmation_Case_Created__c != true AND Reservation_Status__c =  \'Confirmed\' AND Transportation__c !=  \'Not Required-Driving\' AND Id = \'006O100000OvRk1IAF\' ';
        
        //TGR-234  //Added: OR (RecordTypeId =\''+String.escapeSingleQuotes(hookedVoucherRecordTypeId)+'\' AND Supplier__c = \'Holidays NG\' )
        //String query = 'SELECT Id, Supplier__c, AccountId, VI_Referral_Comments__c, RecordType.Name,RecordType.DeveloperName, Account.Name, Flight_Confirmation_Case_Created__c,Check_in__c,Member_Number__c FROM Opportunity WHERE (RecordTypeId =\''+String.escapeSingleQuotes(marivalRecordTypeId)+'\' OR RecordTypeId =\''+String.escapeSingleQuotes(voucherRecordTypeId)+'\' OR RecordTypeId =\''+String.escapeSingleQuotes(referralDateRecordTypeId)+'\' OR RecordTypeId =\''+String.escapeSingleQuotes(BulkSalesCouponRecordTypeId)+'\' OR RecordTypeId =\''+String.escapeSingleQuotes(profitAgilityRecordTypeId)+'\' OR (RecordTypeId =\''+String.escapeSingleQuotes(hookedVoucherRecordTypeId)+'\' AND Supplier__c = \'Holidays NG\' )) AND Arrival_Airport__c = NULL AND Flight_Number__c = NULL AND Arrival_Date__c = NULL AND Check_in__c >= '+todayDate+'  AND Check_in__c <= '+todayPlus180+'  AND (First_Payment_Made__c = true OR First_Payment_Date__c != null) AND (StageName = \'Closed Won\' OR StageName = \'Closed Won-Deposit\' OR StageName = \'Closed Booked\' ) AND  Flight_Confirmation_Case_Created__c != true AND Reservation_Status__c =  \'Confirmed\' AND Transportation__c !=  \'Not Required-Driving\' ';
        //ticket PA2-79 
        //String query = 'SELECT Id, Supplier__c, AccountId, VI_Referral_Comments__c, RecordType.Name,RecordType.DeveloperName, Account.Name, Flight_Confirmation_Case_Created__c,Check_in__c,Member_Number__c FROM Opportunity WHERE (RecordTypeId =\''+String.escapeSingleQuotes(marivalRecordTypeId)+'\' OR RecordTypeId =\''+String.escapeSingleQuotes(voucherRecordTypeId)+'\' OR RecordTypeId =\''+String.escapeSingleQuotes(referralDateRecordTypeId)+'\' OR RecordTypeId =\''+String.escapeSingleQuotes(BulkSalesCouponRecordTypeId)+'\'  OR RecordTypeId =\''+String.escapeSingleQuotes(profitAgilityRecordTypeId)+'\') AND Arrival_Airport__c = NULL AND Flight_Number__c = NULL AND Arrival_Date__c = NULL AND Check_in__c >= '+todayDate+'  AND Check_in__c <= '+todayPlus180+'  AND (First_Payment_Made__c = true OR First_Payment_Date__c != null) AND (StageName = \'Closed Won\' OR StageName = \'Closed Won-Deposit\' OR StageName = \'Closed Booked\' ) AND  Flight_Confirmation_Case_Created__c != true AND Reservation_Status__c =  \'Confirmed\' AND Transportation__c !=  \'Not Required-Driving\' ';
        //String query = 'SELECT Id, AccountId, VI_Referral_Comments__c, RecordType.Name,RecordType.DeveloperName, Account.Name, Flight_Confirmation_Case_Created__c,Check_in__c, Member_Number__c FROM Opportunity WHERE (RecordTypeId =\''+String.escapeSingleQuotes(voucherRecordTypeId)+'\' OR RecordTypeId =\''+String.escapeSingleQuotes(referralDateRecordTypeId)+'\' OR RecordTypeId =\''+String.escapeSingleQuotes(BulkSalesCouponRecordTypeId)+'\') AND Arrival_Airport__c = NULL AND Flight_Number__c = NULL AND Arrival_Date__c = NULL AND Check_in__c >= ' + todayDate + ' AND Check_in__c <= ' + todayPlus180 + ' AND (First_Payment_Made__c = true OR First_Payment_Date__c != null) AND (StageName = \'Closed Won\' OR StageName = \'Closed Won-Deposit\' OR StageName = \'Closed Booked\' ) AND Flight_Confirmation_Case_Created__c != true AND Reservation_Status__c = \'Confirmed\' AND Transportation__c != \'Not Required-Driving\' ';
        
        
        system.debug('---query--'+query);
        return Database.getQueryLocator(query);
        
    }
    
    global void execute(Database.BatchableContext BC, List<Opportunity> oppList) {
        try{
            set<Id> setOppIds = new set<Id>();
            map<Id, Id> mapOppIdToContactId = new map<Id, Id>(); 
            set<Id> setAccountIds = new set<Id>();
            set<Id> setContactIds = new set<Id>();
            map<Id, Id> mapAccIdToContactId = new map<Id, Id>(); 
            List<Contact> contactsUpdateToAssignCadence = new List<Contact>();
            Map<String, String> mapContactIDsToAssignCadence = new Map<String, String>();
            Map<String, set<Id>> MapCadenceNameVsContactIds = new Map<String,set<Id>>();
            Set<ID> contactsToAssignCadence30Days = New Set<ID>();
            Set<ID> contactsToAssignCadence30DaysMarival = New Set<ID>();
            Set<ID> contactsToAssignCadence31Days = New Set<ID>();
            Set<ID> contactsToAssignCadence31DaysMarival = New Set<ID>();
            List<String> listOfSalesCadenceNames= new List<String>{'TourGen-Arrival 30 Days','TourGen-Arrival', 'TourGen-Arrival Marival 30 Day', 'TourGen-Arrival Marival', 'TourGen-Arrival Monster 30 Day', 'TourGen-Arrival Monster'};
                for(Opportunity opp: oppList){
                    if(opp.Member_Number__c == '142519-support@monsterrg.com' && opp.RecordType.DeveloperName == 'Profit_Agility_Voucher'){
                        setOppIds.add(opp.Id);
                    }
                    else if(opp.RecordType.DeveloperName != 'Profit_Agility_Voucher'){
                        setAccountIds.add(opp.AccountId);
                    }
                }
            if(setOppIds != null && setOppIds.size()> 0){
                for(Contact objcon : [select id,Opportunity__c from Contact where Opportunity__c IN :setOppIds]){
                    mapOppIdToContactId.put(objcon.Opportunity__c , objcon.Id);
                }
            }
            if(setAccountIds != null && setAccountIds.size() > 0){
                for(Contact objcon : [select id,accountId, account.Name,Name from Contact where AccountId IN :setAccountIds]){
                    if(objcon.account.Name != null && objcon.Name.equalsIgnoreCase(objcon.account.Name))
                        mapAccIdToContactId.put(objcon.accountId , objcon.Id);
                }
            }
            //map<String,List<Id>> mapCadenceNameVstargetIds = new map<String,List<Id>>();
            //mapCadenceNameVstargetIds = GetAssignedTargetDetails.getMultipleCadenceNamewithTargetList(listOfSalesCadenceNames,setContactIds);
            
            Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Flight_Confirmation').getRecordTypeId();
            List<Case> caseList = new List<Case>();
            List<Opportunity> oppListToUpdate = new List<Opportunity>();
            system.debug('---oppList-'+oppList.size());
            for(Opportunity opp: oppList){
                system.debug('-opp---'+opp);
                Case caseRec = new Case();
                caseRec.Member_Number__c = opp.Member_Number__c;
                caseRec.AccountId = opp.AccountId;
                caseRec.Description = opp.VI_Referral_Comments__c;
                caseRec.Opportunity_Link__c = Label.BaseUrl + opp.Id;
                caseRec.Status = 'New';
                caseRec.RecordTypeId = caseRecordTypeId;
                if(opp.RecordType.DeveloperName == 'Marival' && opp.Supplier__c   == 'Marival')
                {
                    caseRec.Subtype__c = 'Marival';
                }
                else if(opp.RecordType.DeveloperName == 'Marival' && opp.Supplier__c == 'Sunset')
                {
                    caseRec.Subtype__c = 'Sunset';
                }
                else if(opp.RecordType.DeveloperName == 'Marival' && opp.Supplier__c == 'The Fives')//TGR-255
                {
                    caseRec.Subtype__c = 'The Fives';
                }
                else if(opp.Supplier__c == 'Las Palmas')//TGR-346
                {
                    caseRec.Subtype__c = 'Las Palmas';
                }
                else if(opp.RecordType.DeveloperName == 'Hooked_Voucher' && opp.Supplier__c == 'Holidays NG') //TGR-234
                {
                    caseRec.Subtype__c = 'Holidays NG';
                }
                else if(opp.RecordType.DeveloperName == 'Hooked_Voucher' && opp.Supplier__c == 'Exploria') //TGR-265
                {
                    caseRec.Subtype__c = 'Exploria';
                }
                else if(opp.RecordType.DeveloperName == 'Hooked_Voucher' && opp.Supplier__c == 'Sonesta') //TGR-265
                {
                    caseRec.Subtype__c = 'Sonesta';
                }
                else if(opp.RecordType.DeveloperName == 'Hooked_Voucher' && opp.Supplier__c == 'Florida Hotel') //CVC-70
                {
                    caseRec.Subtype__c = 'Florida Hotel';
                }
                //Westgate
                else if(opp.RecordType.DeveloperName == 'Hooked_Voucher' && opp.Supplier__c == 'Westgate')
                {
                    caseRec.Subtype__c = 'Westgate';
                }
                //Lifestyle
                else if(opp.RecordType.DeveloperName == 'Marival' && opp.Supplier__c == 'Lifestyle'){
                    caseRec.Subtype__c = 'Lifestyle';
                }
                //Holiday Inn
                else if(opp.RecordType.DeveloperName == 'Hooked_Voucher' && opp.Supplier__c == 'Holiday Inn'){
                    caseRec.Subtype__c = 'Holiday Inn';
                }
                else
                {
                    caseRec.Subtype__c = 'Vidanta';
                }
                //ticket PA2-79 if(opp.RecordType.DeveloperName == 'Profit_Agility_Voucher' || opp.RecordType.DeveloperName == 'Bulk_Sales_Coupon'){
                if (opp.RecordType.DeveloperName == 'Bulk_Sales_Coupon') {
                    caseRec.OwnerId = Label.PA_FlightConfirmationQueueId; 
                }else{
                    caseRec.OwnerId = Label.FlightConfirmationQueueId;    
                }
                system.debug('opp.Account--'+opp.AccountId);
                caseRec.Subject = 'Flight Confirmation - ' + opp.Account.Name;
                caseRec.Arrival_Date__c = opp.Check_in__c;
                if(opp.Member_Number__c == '142519-support@monsterrg.com' && mapOppIdToContactId.containsKey(opp.Id) && opp.RecordType.DeveloperName == 'Profit_Agility_Voucher'){
                    caseRec.ContactId = mapOppIdToContactId.get(opp.Id);
                    Id conId = mapOppIdToContactId.get(opp.Id);
                    if(opp.Check_in__c <=System.today()+30){
                        // if(mapCadenceNameVstargetIds.containsKey('TourGen-Arrival Monster 30 Day') && !mapCadenceNameVstargetIds.get('TourGen-Arrival Monster 30 Day').contains(conId)){
                        mapContactIDsToAssignCadence.put(mapOppIdToContactId.get(opp.Id), 'TourGen-Arrival Monster 30 Day');
                        if(!MapCadenceNameVsContactIds.containsKey('TourGen-Arrival Monster 30 Day')){
                            MapCadenceNameVsContactIds.put('TourGen-Arrival Monster 30 Day',new set<Id>{mapOppIdToContactId.get(opp.Id)});
                        }
                        else{    
                            MapCadenceNameVsContactIds.get('TourGen-Arrival Monster 30 Day').add(mapOppIdToContactId.get(opp.Id));
                        }
                        // }
                    }
                    //31 days or more
                    else  if(opp.Check_in__c > System.today()+30){
                        //if(mapCadenceNameVstargetIds.containsKey('TourGen-Arrival Monster') && !mapCadenceNameVstargetIds.get('TourGen-Arrival Monster').contains(conId)){
                        mapContactIDsToAssignCadence.put(mapOppIdToContactId.get(opp.Id), 'TourGen-Arrival Monster');
                        if(!MapCadenceNameVsContactIds.containsKey('TourGen-Arrival Monster')){
                            MapCadenceNameVsContactIds.put('TourGen-Arrival Monster',new set<Id>{mapOppIdToContactId.get(opp.Id)});
                        }
                        else{    
                            MapCadenceNameVsContactIds.get('TourGen-Arrival Monster').add(mapOppIdToContactId.get(opp.Id));
                        }
                        //}
                    }
                    
                }                
                //TGR-234, 265 added: " && !(opp.RecordType.DeveloperName == 'Hooked_Voucher' && (opp.Supplier__c == 'Holidays NG' || opp.Supplier__c == 'Exploria' || opp.Supplier__c == 'Las Palmas')"
                else if(opp.RecordType.DeveloperName != 'Marival' && opp.Supplier__c != 'Marival' && opp.RecordType.DeveloperName != 'Profit_Agility_Voucher' && mapAccIdToContactId.containsKey(opp.AccountId) && !(opp.RecordType.DeveloperName == 'Hooked_Voucher' && (opp.Supplier__c == 'Holidays NG' || opp.Supplier__c == 'Exploria' || opp.Supplier__c == 'Las Palmas' || opp.Supplier__c == 'Sonesta' || opp.Supplier__c == 'Florida Hotel' || opp.Supplier__c == 'Westgate'  || opp.Supplier__c == 'Holiday Inn' )) ){
                    
                    caseRec.ContactId = mapAccIdToContactId.get(opp.AccountId);
                    Id conId = mapAccIdToContactId.get(opp.AccountId);
                    if(opp.Check_in__c <=System.today()+30){
                        //if(mapCadenceNameVstargetIds.containsKey('30 days or less') && !mapCadenceNameVstargetIds.get('30 days or less').contains(conId)){
                        mapContactIDsToAssignCadence.put(mapAccIdToContactId.get(opp.AccountId), '30 days or less');
                        contactsToAssignCadence30Days.add(mapAccIdToContactId.get(opp.AccountId));
                        //}
                    }
                    //31 days or more
                    else  if(opp.Check_in__c > System.today()+30){
                        //if(mapCadenceNameVstargetIds.containsKey('31 days or less') && !mapCadenceNameVstargetIds.get('31 days or less').contains(conId)){
                        mapContactIDsToAssignCadence.put(mapAccIdToContactId.get(opp.AccountId), '31 days or more');
                        contactsToAssignCadence31Days.add(mapAccIdToContactId.get(opp.AccountId));
                        //}
                    }
                }
                //2024-06-24 HSIMU2-1026 Marival Phase 5-Marival Sales Cadence
                else if((opp.RecordType.DeveloperName == 'Marival' && opp.Supplier__c == 'Marival') && mapAccIdToContactId.containsKey(opp.AccountId)){
                    caseRec.ContactId = mapAccIdToContactId.get(opp.AccountId);
                    Id conId = mapAccIdToContactId.get(opp.AccountId);
                    if(opp.Check_in__c <=System.today()+30){
                        //if(mapCadenceNameVstargetIds.containsKey('TourGen-Arrival Marival 30 Day') && !mapCadenceNameVstargetIds.get('TourGen-Arrival Marival 30 Day').contains(conId)){
                        mapContactIDsToAssignCadence.put(mapAccIdToContactId.get(opp.AccountId), 'TourGen-Arrival Marival 30 Day');
                        contactsToAssignCadence30DaysMarival.add(mapAccIdToContactId.get(opp.AccountId));
                        //}
                    }
                    //31 days or more
                    else  if(opp.Check_in__c > System.today()+30){
                        //if(mapCadenceNameVstargetIds.containsKey('TourGen-Arrival Marival') && !mapCadenceNameVstargetIds.get('TourGen-Arrival Marival').contains(conId)){
                        mapContactIDsToAssignCadence.put(mapAccIdToContactId.get(opp.AccountId), 'TourGen-Arrival Marival');
                        contactsToAssignCadence31DaysMarival.add(mapAccIdToContactId.get(opp.AccountId));
                        //}
                    }
                }
                //Case assignment to Match Group
                else if((opp.RecordType.DeveloperName == 'Marival' && opp.Supplier__c == 'Sunset')){
                    caseRec.ContactId = mapAccIdToContactId.get(opp.AccountId);
                    if(opp.Check_in__c <=System.today()+30){
                        caseRec.leadassist__Use_Round_Robin__c = 'True';
                        caseRec.Match_Group_Name__c = 'TourGen-Arrival Sunset 30 Days';
                    }
                    //31 days or more
                    else  if(opp.Check_in__c > System.today()+30){
                        caseRec.leadassist__Use_Round_Robin__c = 'True';
                        caseRec.Match_Group_Name__c = 'TourGen-Arrival Sunset';
                    }
                }
                //Case assignment to Match Group TGR-346 - Las Palmas
                else if(opp.Supplier__c == 'Las Palmas'){
                    System.debug('--- Found Las Palmas Opportunity ---');
                    System.debug('Opportunity ID: ' + opp.Id);
                    System.debug('Account Name: ' + opp.Account.Name);
                    System.debug('Check-in Date: ' + opp.Check_in__c);
                    System.debug('Supplier: ' + opp.Supplier__c);
                    System.debug('Record Type: ' + opp.RecordType.DeveloperName);
                    caseRec.ContactId = mapAccIdToContactId.get(opp.AccountId);
                    if(opp.Check_in__c <=System.today()+30){
                        caseRec.leadassist__Use_Round_Robin__c = 'True';
                        caseRec.Match_Group_Name__c = 'TourGen-Arrival Las Palmas 30 Days';
                    }
                    //31 days or more
                    else  if(opp.Check_in__c > System.today()+30){
                        caseRec.leadassist__Use_Round_Robin__c = 'True';
                        caseRec.Match_Group_Name__c = 'TourGen-Arrival Las Palmas';
                    }
                }
                //Case assignment to Match Group TGR-255
                else if((opp.RecordType.DeveloperName == 'Marival' && opp.Supplier__c == 'The Fives')){
                    caseRec.ContactId = mapAccIdToContactId.get(opp.AccountId);
                    if(opp.Check_in__c <=System.today()+30){
                        caseRec.leadassist__Use_Round_Robin__c = 'True';
                        caseRec.Match_Group_Name__c = 'TourGen-Arrival The Fives 30 days';
                    }
                    //31 days or more
                    else  if(opp.Check_in__c > System.today()+30){
                        caseRec.leadassist__Use_Round_Robin__c = 'True';
                        caseRec.Match_Group_Name__c = 'TourGen-Arrival The Fives';
                    }
                }                 
                //Case assignment to Match Group - TGR-234
                else if((opp.RecordType.DeveloperName == 'Hooked_Voucher' && opp.Supplier__c == 'Holidays NG')){
                    caseRec.ContactId = mapAccIdToContactId.get(opp.AccountId);
                    if(opp.Check_in__c <=System.today()+30){
                        caseRec.leadassist__Use_Round_Robin__c = 'True';
                        caseRec.Match_Group_Name__c = 'TourGen-Arrival Holidays NG 30 days';
                    }
                    //31 days or more
                    else  if(opp.Check_in__c > System.today()+30){
                        caseRec.leadassist__Use_Round_Robin__c = 'True';
                        caseRec.Match_Group_Name__c = 'TourGen-Arrival Holidays NG';
                    }
                }                
                //Case assignment to Match Group - TGR-265
                else if((opp.RecordType.DeveloperName == 'Hooked_Voucher' && opp.Supplier__c == 'Exploria')){
                    caseRec.ContactId = mapAccIdToContactId.get(opp.AccountId);
                    if(opp.Check_in__c <=System.today()+30){
                        caseRec.leadassist__Use_Round_Robin__c = 'True';
                        caseRec.Match_Group_Name__c = 'TourGen-Arrival Exploria 30 days';
                    }
                    //31 days or more
                    else  if(opp.Check_in__c > System.today()+30){
                        caseRec.leadassist__Use_Round_Robin__c = 'True';
                        caseRec.Match_Group_Name__c = 'TourGen-Arrival Exploria';
                    }
                }                
                //Case assignment to Match Group - RIWP-2
                else if((opp.RecordType.DeveloperName == 'Travel' && opp.Supplier__c == '')){
                    caseRec.ContactId = mapAccIdToContactId.get(opp.AccountId);
                    caseRec.leadassist__Use_Round_Robin__c = 'True';
                    caseRec.Match_Group_Name__c = 'Travel Sales-Inspira Resort Weeks';
                }  
                //Case assignment to Match Group - CVC-67
                else if((opp.RecordType.DeveloperName == 'Hooked_Voucher' && opp.Supplier__c == 'Sonesta')){
                    caseRec.ContactId = mapAccIdToContactId.get(opp.AccountId);
                    if(opp.Check_in__c <=System.today()+30){
                        caseRec.leadassist__Use_Round_Robin__c = 'True';
                        caseRec.Match_Group_Name__c = 'TourGen-Arrival Sonesta 30 days';
                    }
                    //31 days or more
                    else  if(opp.Check_in__c > System.today()+30){
                        caseRec.leadassist__Use_Round_Robin__c = 'True';
                        caseRec.Match_Group_Name__c = 'TourGen-Arrival Sonesta';
                    }
                }
                //Case assignment to Match Group - CVC-70
                else if(( opp.RecordType.DeveloperName == 'Hooked_Voucher' && opp.Supplier__c == 'Florida Hotel' && !opp.LeadSource_Formula__c.contains('Gunn Marketing/CCR'))){
                    System.debug('--- Found Florida Hotel Opportunity ---');
                    System.debug('Opportunity ID: ' + opp.Id);
                    System.debug('Lead Source Formula: ' + opp.LeadSource_Formula__c);
                    System.debug('Opp Lead Source: ' + opp.LeadSource);
                    System.debug('Account Name: ' + opp.Account.AccountSource);
                    System.debug('Opp Affiliate id: ' + opp.Affiliated_Id__c);
                    System.debug('Account Affiliate: ' + opp.Account.Affiliated_Id__c);
                    System.debug('Check-in Date: ' + opp.Check_in__c);
                    System.debug('Supplier: ' + opp.Supplier__c);
                    System.debug('Record Type: ' + opp.RecordType.DeveloperName);
                    caseRec.ContactId = mapAccIdToContactId.get(opp.AccountId);
                    if(opp.Check_in__c <=System.today()+30){
                        caseRec.leadassist__Use_Round_Robin__c = 'True';
                        caseRec.Match_Group_Name__c = 'TourGen-Arrival Florida Hotel 30 days';
                    }
                    //31 days or more
                    else  if(opp.Check_in__c > System.today()+30){
                        caseRec.leadassist__Use_Round_Robin__c = 'True';
                        caseRec.Match_Group_Name__c = 'TourGen-Arrival Florida Hotel';
                    }
                }
                else if((opp.RecordType.DeveloperName == 'Marival' && opp.Supplier__c == 'Lifestyle')){
                    caseRec.ContactId = mapAccIdToContactId.get(opp.AccountId);
                    if(opp.Check_in__c <=System.today()+30){
                        caseRec.leadassist__Use_Round_Robin__c = 'True';
                        caseRec.Match_Group_Name__c = 'TourGen-Arrival Lifestyle30 days';
                    }
                    //31 days or more
                    else  if(opp.Check_in__c > System.today()+30){
                        caseRec.leadassist__Use_Round_Robin__c = 'True';
                        caseRec.Match_Group_Name__c = 'TourGen-Arrival Lifestyle';
                    }
                }
                else if((opp.RecordType.DeveloperName == 'Hooked_Voucher' && opp.Supplier__c == 'Westgate')){
                    caseRec.ContactId = mapAccIdToContactId.get(opp.AccountId);
                    if(opp.Check_in__c <=System.today()+30){
                        caseRec.leadassist__Use_Round_Robin__c = 'True';
                        caseRec.Match_Group_Name__c = 'TourGen-Arrival Westgate 30 days';
                    }
                    //31 days or more
                    else  if(opp.Check_in__c > System.today()+30){
                        caseRec.leadassist__Use_Round_Robin__c = 'True';
                        caseRec.Match_Group_Name__c = 'TourGen-Arrival Westgate';
                    }
                }
                else if((opp.RecordType.DeveloperName == 'Hooked_Voucher' && opp.Supplier__c == 'Holiday Inn')){
                    caseRec.ContactId = mapAccIdToContactId.get(opp.AccountId);
                    if(opp.Check_in__c <=System.today()+30){
                        caseRec.leadassist__Use_Round_Robin__c = 'True';
                        caseRec.Match_Group_Name__c = 'TourGen-Arrival Holiday Inn Drive by IHG 30 days';
                    }
                    //31 days or more
                    else  if(opp.Check_in__c > System.today()+30){
                        caseRec.leadassist__Use_Round_Robin__c = 'True';
                        caseRec.Match_Group_Name__c = 'TourGen-Arrival Holiday Inn';
                    }
                }
                
                
                caseList.add(caseRec);
                opp.Flight_Confirmation_Case_Created__c = true;
                oppListToUpdate.add(opp);
            }
            if(mapContactIDsToAssignCadence != null && mapContactIDsToAssignCadence.size() > 0){
                List<Contact> conList = [select id,leadassist__Use_Round_Robin__c,Match_Group_Name__c from Contact where Id IN : mapContactIDsToAssignCadence.Keyset()];
                for(contact con:conList){
                    con.leadassist__Use_Round_Robin__c='True';
                    con.Assign_to_Sales_Cadence__c = true;
                    con.Cadence_Flag__c = 1;
                    con.Match_Group_Name__c = mapContactIDsToAssignCadence.get(con.Id);
                    contactsUpdateToAssignCadence.add(con);
                }
            }            
            if(contactsUpdateToAssignCadence.size() > 0 && contactsUpdateToAssignCadence.size() != null){
                update contactsUpdateToAssignCadence;
            }  
            insert caseList;
            update oppListToUpdate;
            //2024-06-24 HSIMU2-1026 Marival Phase 5-Marival Sales Cadence
            if(!test.isRunningTest()){
                for(String key : MapCadenceNameVsContactIds.keyset()){
                    System.enqueueJob(new GenericAssignToSalesCadence(MapCadenceNameVsContactIds.get(key), key)); 
                }
                if(contactsToAssignCadence30Days.size()>0 && contactsToAssignCadence30Days != null){
                    System.enqueueJob(new GenericAssignToSalesCadence(contactsToAssignCadence30Days, 'TourGen-Arrival 30 Days'));
                }
                if(contactsToAssignCadence31Days.size()>0 && contactsToAssignCadence31Days != null){
                    System.enqueueJob(new GenericAssignToSalesCadence(contactsToAssignCadence31Days, 'TourGen-Arrival'));
                }
                if(contactsToAssignCadence30DaysMarival.size()>0 && contactsToAssignCadence30DaysMarival != null){
                    System.enqueueJob(new GenericAssignToSalesCadence(contactsToAssignCadence30DaysMarival, 'TourGen-Arrival Marival 30 Day'));
                }
                if(contactsToAssignCadence31DaysMarival.size()>0 && contactsToAssignCadence31DaysMarival != null){
                    System.enqueueJob(new GenericAssignToSalesCadence(contactsToAssignCadence31DaysMarival, 'TourGen-Arrival Marival'));
                }
                //System.enqueueJob(new CreateFlightConfirmationCaseQueueable(caseList));
            } 
        }   
        catch(Exception e){
            System.debug('>>>>>');
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        // execute any post-processing operations like sending email
    }
}