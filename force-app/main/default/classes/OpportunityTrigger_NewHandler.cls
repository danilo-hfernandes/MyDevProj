public class OpportunityTrigger_NewHandler {  
//HSIMU2-882 Not cancelling - already implemented in OpportunityTriggerHandler.createReservationTrackingRecord
/*@future(callout = true) 
    public static void cleanReservationFields(Set<Id> oppsToClean){
        List<Reservation_Tracking_Object__c> reservationsToCheck = new List<Reservation_Tracking_Object__c>();
        Map<Id,Reservation_Tracking_Object__c> reservationsToIterate = new Map<Id,Reservation_Tracking_Object__c>();
        List<Reservation_Tracking_Object__c> reservationsToCancel = new List<Reservation_Tracking_Object__c>();
        List<Opportunity> oppsToCancel = new List<Opportunity>();
        
        reservationsToCheck = [SELECT Id,Reservation_Status__c,Opportunity__c,Confirmation_Number__c,Opportunity__r.Confirmation_Number__c FROM Reservation_Tracking_Object__c WHERE Opportunity__c IN : oppsToClean ORDER BY CreatedDate ASC];
        
        for(Reservation_Tracking_Object__c resTO : reservationsToCheck)
        {
            reservationsToIterate.put(resTO.Opportunity__c,resTO);
        }
        
        if(reservationsToIterate != null && reservationsToIterate.size()>0){        
            for(Id resTOId : reservationsToIterate.keySet())
            {
                if(reservationsToIterate.get(resTOId).Confirmation_Number__c != null && reservationsToIterate.get(resTOId).Opportunity__r.Confirmation_Number__c != null)
                {
                    if(reservationsToIterate.get(resTOId).Confirmation_Number__c == reservationsToIterate.get(resTOId).Opportunity__r.Confirmation_Number__c && reservationsToIterate.get(resTOId).Reservation_Status__c != 'Canceled')
                    {
                        reservationsToCancel.add(reservationsToIterate.get(resTOId));
                    }
                }
            }
        }
              
        if(reservationsToCancel != null && reservationsToCancel.size()>0){            
            for(Reservation_Tracking_Object__c res : reservationsToCancel)
            {
                res.Confirmation_Number__c = 'Canceled';
            }
            update reservationsToCancel;
        }
        
        for(Id opportunityId: oppsToClean)
        {
            Opportunity opp = new Opportunity();
            opp.Confirmation_Number__c = '';
            opp.Confirmed_Date__c = null;   
            oppsToCancel.add(opp);
        }

        update oppsToCancel;        
    }*/
    public static void handleGiftChanges(Map<Id, Opportunity> oppMap, Map<Id, Set<String>> oppIdToAddedGifts) {
        // Step 1: Get Club Venture Record Type Id
        Id clubVentureRecordTypeId = Schema.SObjectType.Opportunity
            .getRecordTypeInfosByDeveloperName()
            .get('Club_Venture_Membership')
            .getRecordTypeId();
        
        // Step 2: Filter only qualified opportunities
        Map<Id, Set<String>> qualifiedOpps = new Map<Id, Set<String>>();
        for (Id oppId : oppIdToAddedGifts.keySet()) {
            Opportunity opp = oppMap.get(oppId);
            if (opp.RecordTypeId == clubVentureRecordTypeId) {
                qualifiedOpps.put(oppId, oppIdToAddedGifts.get(oppId));
            }
        }
        
        if (qualifiedOpps.isEmpty()) return;
        
        // Step 3: Collect all added gift names
        Set<String> allGiftNames = new Set<String>();
        for (Set<String> gifts : qualifiedOpps.values()) {
            allGiftNames.addAll(gifts);
        }
        
        // Step 4: Query PricebookEntries for the added gifts
        Map<String, PricebookEntry> nameToPBE = new Map<String, PricebookEntry>();
        for (PricebookEntry pbe : [
            SELECT Id, Product2Id, Product2.Name
            FROM PricebookEntry
            WHERE Product2.Name IN :allGiftNames
            AND IsActive = true
        ]) {
            nameToPBE.put(pbe.Product2.Name, pbe);
        }
        
        // Step 5: Query existing OLIs to prevent duplicates
        Set<Id> oppIds = qualifiedOpps.keySet();
        Map<Id, Set<Id>> oppToExistingProductIds = new Map<Id, Set<Id>>();
        for (OpportunityLineItem oli : [
            SELECT OpportunityId, PricebookEntry.Product2Id
            FROM OpportunityLineItem
            WHERE OpportunityId IN :oppIds
        ]) {
            if (!oppToExistingProductIds.containsKey(oli.OpportunityId)) {
                oppToExistingProductIds.put(oli.OpportunityId, new Set<Id>());
            }
            oppToExistingProductIds.get(oli.OpportunityId).add(oli.PricebookEntry.Product2Id);
        }
        
        // Step 6: Create new OLIs
        List<OpportunityLineItem> oliToInsert = new List<OpportunityLineItem>();
        for (Id oppId : qualifiedOpps.keySet()) {
            Set<String> addedGifts = qualifiedOpps.get(oppId);
            Set<Id> existingProdIds = oppToExistingProductIds.get(oppId);
            
            for (String gift : addedGifts) {
                PricebookEntry pbe = nameToPBE.get(gift);
                if (pbe == null) continue;
                
                if (existingProdIds != null && existingProdIds.contains(pbe.Product2Id)) continue;
                
                OpportunityLineItem oli = new OpportunityLineItem(
                    OpportunityId = oppId,
                    PricebookEntryId = pbe.Id,
                    Quantity = 1,
                    TotalPrice = 0,
                    Retail_Price__c = 0
                );
                oliToInsert.add(oli);
            }
        }
        
        if (!oliToInsert.isEmpty()) {
            insert oliToInsert;
        }
    }
    @future(callout = true) 
    public static void sendSalesCadenceRequest(Set<Id> ContactId,string salesCadenceName) {
        system.debug('18 future');
        String sfdcURL = URL.getSalesforceBaseUrl().toExternalForm();  
        String actionsRestURL = sfdcURL + '/services/data/v45.0/actions';
        String assignTargetRESTUrl = actionsRestURL + '/standard/assignTargetToSalesCadence';
        map<String,List<Id>> mapCadenceNameVstargetIds = new map<String,List<Id>>();
        List<String> listOfSalesCadenceNames= new List<String>();
        if(ContactId != null && ContactId.size() > 0){
            List<Contact> contactList = [select id,Assign_to_Sales_Cadence_Name__c,LeadSource from Contact where Id In : ContactId AND Parent_Id_Ext_Db__c = null and Marketing_Email_opt_out__c = false];
            for(Contact con : contactList){
                if(salesCadenceName == null || salesCadenceName == ''){
                    listOfSalesCadenceNames.add(con.Assign_to_Sales_Cadence_Name__c);
                }
                else {
                    listOfSalesCadenceNames.add(salesCadenceName);
                }
            }
            mapCadenceNameVstargetIds = GetAssignedTargetDetails.getMultipleCadenceNamewithTargetList(listOfSalesCadenceNames,ContactId);
            for(Contact con : contactList){
                if(mapCadenceNameVstargetIds.containsKey(con.Assign_to_Sales_Cadence_Name__c) && !mapCadenceNameVstargetIds.get(con.Assign_to_Sales_Cadence_Name__c).contains(con.Id)){
                    if(salesCadenceName == null || salesCadenceName == ''){
                        salesCadenceName = con.Assign_to_Sales_Cadence_Name__c;
                    }
                    HttpRequest httpReq = new HttpRequest();
                    httpReq.setMethod('POST');
                    httpReq.setHeader('Authorization', 'OAuth ' + UserInfo.getSessionId());
                    httpReq.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
                    httpReq.setEndpoint(assignTargetRESTUrl);
                    httpReq.setHeader('Content-Type', 'application/json');
                    httpReq.setBody('{"inputs" : [{"salesCadenceNameOrId" : "' + salesCadenceName + '", "targetId" : "' + con.Id + '"}]}');
                
                    String response = '';
                    try {
                        Http http = new Http();
                        HttpResponse httpResponse = http.send(httpReq);
                        if (httpResponse.getStatusCode() == 200) {
                            system.debug('36 future');
                            response = JSON.serializePretty(JSON.deserializeUntyped(httpResponse.getBody()));
                        } else {
                            System.debug('http response: ' + httpResponse.getBody());
                            throw new CalloutException(httpResponse.getBody());
                        }
                    } catch (System.Exception e) {
                        System.debug('ERROR! ' + e);
                        throw e;
                    }
                }
            }
        }
    }
    
    public static void MFAmmountUpdate(set<Id> oppIdSet){
        List<OpportunityLineItem> oppLineItemList =  [select Id,MF_Transaction_New__c,Product2Id,OpportunityId,Product2.Name,Timeshare__r.MF_Amount__c from OpportunityLineItem where OpportunityId In : oppIdSet and Product2.Name = 'Maintenance Fee Protection' and Timeshare__c != null];
        List<OpportunityLineItem> updateLineItem = new List<OpportunityLineItem>();
        if(oppLineItemList != null && oppLineItemList.size() > 0){
            for(OpportunityLineItem oppLine : oppLineItemList){
                oppLine.MF_Transaction_New__c = oppLine.Timeshare__r.MF_Amount__c;
                updateLineItem.add(oppLine);
            }
            if(updateLineItem != null && updateLineItem.size() > 0){
                update updateLineItem;
            }
        }
    }
    public static void createRedemptionRecord(set<Id> oppIdSet){
        Boolean sendEmail = false;
        set<Id> setOppId = new set<Id>();
        system.debug('oppIdSet=== '+oppIdSet);
        List<Redemption__c> lstRedemption = new List<Redemption__c>();
        set<Id> setProductId = new set<Id>();
        Map<Id,Id> oppPorudctId = new Map<Id,Id>();
        List<Redemption__c> redemCheck = [select id,Opportunity__c,Opportunity_Product__c from Redemption__c where Opportunity__c IN : oppIdSet];
        for(Redemption__c rp : redemCheck){
            oppPorudctId.put(rp.Opportunity_Product__c,rp.Opportunity_Product__c);
        }
        for(OpportunityLineItem oli: [select Id,Product2Id,OpportunityId,Product2.Name, Opportunity.Record_Type_Name__c from OpportunityLineItem where OpportunityId In : oppIdSet]){
            system.debug('>>>>>>oli.Product2.Name>>>>>>'+oli.Product2.Name);
            if(oli.Product2.Name == 'Hawaii Collection Plus Flyback' || oli.Product2.Name == 'Vidanta Fly Back' || oli.Product2.Name == 'Hawaii Collection Plus Flyback Extension' ){
                if(oppPorudctId != null && !oppPorudctId.containsKey(oli.Id)){
                    integer i=0;
                    while(i<5){
                        Redemption__c objRedem = new Redemption__c();
                        objRedem.Opportunity__c = oli.OpportunityId; 
                        objRedem.Redemption_Type__c = 'Cash';
                        //objRedem.Status__c = 'Reservation Pending';
                        objRedem.Opportunity_Product__c = oli.Id;
                        system.debug('objRedem.Opportunity_Product__c'+objRedem.Opportunity_Product__c);
                        lstRedemption.add(objRedem);
                        i++;
                    }
                }
            }
            if(oli.Product2.Name == 'Back to Vidanta Pass' && oli.Opportunity.Record_Type_Name__c == 'Hawaii Collection Membership'){
                if(oppPorudctId == null || (oppPorudctId != null && !oppPorudctId.containsKey(oli.Id))){
                    Redemption__c objRedem = new Redemption__c();
                    objRedem.Opportunity__c = oli.OpportunityId; 
                    objRedem.Opportunity_Product__c = oli.Id;
                    objRedem.Redemption_Type__c = 'Cash';
                    lstRedemption.add(objRedem);
                    sendEmail = true;
                    setOppId.add(oli.OpportunityId);
                }
            }
            if(oli.Product2.Name == 'Usage Fee Relief'){
                if(oppPorudctId == null || (oppPorudctId != null && !oppPorudctId.containsKey(oli.Id))){
                    Redemption__c objRedem = new Redemption__c();
                    objRedem.Opportunity__c = oli.OpportunityId; 
                    objRedem.Opportunity_Product__c = oli.Id;
                    objRedem.Redemption_Type__c = 'Cash';
                    lstRedemption.add(objRedem);
                    /*sendEmail = true;
                    setOppId.add(oli.OpportunityId);*/
                }
            }
        }
        if(sendEmail && setOppId != null && setOppId.size() > 0){
            List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>(); 
            List<EmailTemplate> emailTemplateList = new List<EmailTemplate>();
            emailTemplateList = [SELECT Id, Body,developername, Subject, HtmlValue, Name FROM EmailTemplate WHERE developername = 'Back_to_Vidanta_Pass'];
            for(Opportunity opp : [select id,AccountId,Account.email__c from Opportunity where Id IN :setOppId]){
                string whoId=opp.Id;
                string whatId=opp.AccountId;
                List<String> emailAddress=new list<string>();
                emailAddress.add(opp.Account.email__c);
                String templateBody;
                Messaging.SingleEmailMessage newEmail; 
                Messaging.SingleEmailMessage mailToBeSent = new Messaging.SingleEmailMessage(); 
                OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'welcome@hawaiicollection.com'];
                if ( owea.size() > 0 ) {
                    mailToBeSent.setOrgWideEmailAddressId(owea.get(0).Id); 
                }
                if(!emailTemplateList.isEmpty()) {
                    newEmail = Messaging.renderStoredEmailTemplate(emailTemplateList[0].id,whoId,whatId);
                }
                
                if(!emailAddress.isEmpty()) {
                    if(newEmail != null) {
                        mailToBeSent.setSubject(newEmail.subject);
                        mailToBeSent.setHtmlBody(newEmail.HTMLBody);
                        mailToBeSent.setToAddresses(emailAddress);
                        mailToBeSent.setSaveAsActivity(true);
                        mailToBeSent.setWhatId(whoId);
                        emailList.add(mailToBeSent);
                    }
                }
            }
            if(!emailList.isEmpty()){
                Messaging.sendEmail(emailList);
            }
        }
        system.debug('>>>>>>lstRedemption>>>>>>'+lstRedemption);
        system.debug('>>>>>>lstRedemption Number>>>>>>'+lstRedemption.size());
        if(lstRedemption != null && lstRedemption.size() > 0){
            insert lstRedemption;
        }
    }
    
    public void createRedemptionRecordFlyback(Map<Id, Opportunity> oldOppMap, Map<Id, Opportunity> newOppMap) {
        system.debug('--enter createRedemptionRecordFlyback --');
        List<Redemption__c> lstRedemption = new List<Redemption__c>();
        
        // Query the related OpportunityLineItems
        List<OpportunityLineItem> oppLineItems = [
            SELECT Id, OpportunityId, Product2.Name, Product2Id, Opportunity.StageName
            FROM OpportunityLineItem
            WHERE OpportunityId IN :newOppMap.keySet()
        ];
        
        for (OpportunityLineItem oli : oppLineItems) {
            Opportunity newOpp = newOppMap.get(oli.OpportunityId);
            Opportunity oldOpp = oldOppMap.get(oli.OpportunityId);
            
            //Check if StageName changed to 'Closed Won'
            Boolean stageChangedToClosedWon = (newOpp.StageName == 'Closed Won' && oldOpp.StageName != 'Closed Won');
            
            if (
                stageChangedToClosedWon &&
                (oli.Product2.Name == 'Vida Flyback Rebate TC' ||
                 oli.Product2.Name == 'Vida Flyback Guest TC' ||
                 oli.Product2.Name == 'Airfare Credit TC')
            ) {
                System.debug('>>> Creating Redemption Vida Flyback Rebate TC...');
                
                for (Integer i = 0; i < 5; i++) {
                    Redemption__c objRedem = new Redemption__c();
                    objRedem.Opportunity__c = oli.OpportunityId;
                    objRedem.Redemption_Amount__c = 1000;
                    objRedem.Redemption_Type__c = 'Credits';
                    objRedem.Opportunity_Product__c = oli.Id;
                    lstRedemption.add(objRedem);
                }
            }
        }
        
        if (!lstRedemption.isEmpty()) {
            insert lstRedemption;
        }
    }
    
    @future(callout = true) 
    public static void sendOppToVVIPEZCheckout(Set<Id> oppIds){
        List<Opportunity> opps = [SELECT Id,Name,Account.First_Name__c,Account.Last_Name__c,Account.email__c,Account.Phone,Order_Id__c,Prospect_Id__c FROM Opportunity where id IN: oppIds];
        if(opps != null && opps.size()>0)
        {
            Boolean runningInASandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
            String endpoint = '';
            if(runningInASandbox){
                endpoint = 'https://api-stage.sfxresorts.com/funnel/ezcheckout';
            }
            else{
                endpoint = 'https://api.sfxresorts.com/funnel/ezcheckout';
            }
            
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(endpoint);
            request.setMethod('POST');            
            request.setHeader('content-type', 'application/json');
            
            for(Opportunity opp : opps){
                String jsonBody = '{"funnel": "xx-yy-zz", "prospect_id":"'+opp.Prospect_Id__c+'", "third_party_id":"'+opp.Order_Id__c+'", "guest":{"firstname": "'+opp.Account.First_Name__c+'", "lastname": "'+opp.Account.Last_Name__c+'", "phone": "'+opp.Account.Phone+'", "email": "'+opp.Account.email__c+'"} }';
                request.setBody(jsonBody);                
                String response = '';
                try {                    
                    //request.setHeader('Authorization', 'Bearer '+gToken);
                    system.debug('--sendOppToVVIPEZCheckout request--'+request);
                    HttpResponse httpResponse = http.send(request);
                    system.debug('--httpResponse--'+httpResponse);
                    if(httpResponse.getStatusCode() != 200 && httpResponse.getStatus() != 'OK'){
                        response = JSON.serializePretty( JSON.deserializeUntyped(httpResponse.getBody()) );
                        Map<String,Object> receivedData = (Map<String,Object>)JSON.deserializeUntyped(response);
                        String message = String.valueOf(receivedData.get('message'));
                        system.debug('--message-'+message);
                        Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
                        String[] sendingTo = new String[]{};
                            if(!runningInASandbox){
                                sendingTo=new String[]{'amadeu.lettieri@nerdsoft.com','diana.maali@nerdsoft.com', UserInfo.getUserEmail()};
                                    semail.setSubject('https://api.sfxresorts.com/funnel/ezcheckout API is failed');
                            }
                        else
                        {
                            sendingTo = new String[]{'victor.goncalves@nerdsoft.com',UserInfo.getUserEmail()};
                                semail.setSubject('https://api.sfxresorts.com/funnel/ezcheckout API is failed');
                        }
                        semail.setToAddresses(sendingTo);                        
                        semail.setPlainTextBody('Message : '+message+ 'Request : '+jsonBody);
                        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {semail}); 
                    }
                } catch( System.Exception e) {
                    System.debug('ERROR: '+ e);
                }
            }
        }
    }
    
    public static void hawaaiEmailOverflow(list<Opportunity> newOpp){
        
        system.debug('37='+newOpp);
        Integer AffilatedId =  Integer.valueof(Label.Affiliated_Id);
        String stageName='New';
        String UseRoundRobin='FALSE';
        ID ownerId= [SELECT Id FROM User where name='Dev Account' LIMIT 1].id;
        String recordTypeName='Hawaii Collection Membership';
        list<Opportunity> hawaaiOpp= new list<Opportunity>();
        list<Id> hawaaiOppId= new list<Id>();
        
        for(Opportunity opp:newOpp){
            
            
            if(opp.Account_Affiliate_Id__c==AffilatedId && opp.Record_Type_Name__c==recordTypeName && opp.OwnerId==ownerId && opp.Automated_Hawaii_Opportunity__c==true && opp.leadassist__Use_Round_Robin__c==UseRoundRobin && opp.StageName==stageName){
                
                hawaaiOppId.add(opp.id);
            }
        }
        
        system.debug('54='+hawaaiOppId.size());
        
        hawaaiOpp=[SELECT Id,Name,AccountId,Account.First_Name__c,Account.email__c,ownerid,Account.TRM_Owner_Flag__c,Account.Preferred_Language__c,Automated_Hawaii_Opportunity__c,Membership_Upgrade_Group__c from opportunity where id IN: hawaaiOppId];
        
        
        list<String> oppAccountId=new list<String>();
        list<Account> oppAccountList= new list<Account>();
        map<String,list<String>> accountWithTimeShareMap =new map<String,list<String>>();
        list<Opportunity> upgradeGroupSPAList= new list<Opportunity>();
        List<OrgWideEmailAddress> orgList = new List<OrgWideEmailAddress>();  
        
        list<Opportunity> upgradeGroupTRMList= new list<Opportunity>();
        list<Opportunity> upgradeGroupGradeAList= new list<Opportunity>();
        list<Opportunity> upgradeGroupGradeBList= new list<Opportunity>();
        list<Opportunity> upgradeGroupGradeCList= new list<Opportunity>();
        list<Opportunity> upgradeGroupList= new list<Opportunity>();
        list<Opportunity> upgradeGroupGradeABList= new list<Opportunity>();
        
        list<String> gradeAList=new list<String>{'The Estates East Cape','The Estates Puerto Vallarta','Grand Luxxe Nuevo Vallarta'};
            list<String> gradeBList=new list<String>{'Imperial Gardens Nuevo Vallarta','Deluxxe at the Grand Mayan Nuevo Vallarta'};
                list<String> gradeCList=new list<String>{'Kingdom Of The Sun III','Imperial Jungle Aqua'};
                    list<String> gradeABList=new  list<String>{'The Estates East Cape','The Estates Puerto Vallarta','Grand Luxxe Nuevo Vallarta','Imperial Gardens Nuevo Vallarta','Deluxxe at the Grand Mayan Nuevo Vallarta'};
                        //Fetching Opportunitu Account Ids 
                        for(Opportunity opp:hawaaiOpp){
                            oppAccountId.add(opp.AccountId);
                        }
        System.debug('31='+oppAccountId);
        
        oppAccountList=[Select id,name,(select id,name from Timeshares__r) from account where id IN: oppAccountId];
        
        System.debug('35='+oppAccountList);
        // Creating map of AccountId with their timeShare unit_type__c
        for(Account acc: OppAccountList){
            
            if(acc.Timeshares__r.size()!=0){
                for(Timeshare__c tm: acc.Timeshares__r ){
                    
                    if(!accountWithTimeShareMap.keyset().contains(acc.id)){
                        accountWithTimeShareMap.put(acc.id,new List<String>());
                    }
                    accountWithTimeShareMap.get(acc.id).add(tm.name);
                }
            }
        }
        
        System.debug('48='+accountWithTimeShareMap);
        
        for(Opportunity opp: hawaaiOpp){
            
            System.debug('52='+opp);
            Boolean gradeA=false;
            Boolean gradeB=false;
            Boolean gradeC=false;
            Boolean gradeAB=false;
            
            // Determining if opp is in gradeA, gradeB or gradeC
            if(accountWithTimeShareMap.get(opp.accountId)!=null){
                for(String unitType: accountWithTimeShareMap.get(opp.accountId)){
                    
                    
                    if(gradeAList.contains(unitType)){
                        
                        gradeA=true;
                        gradeAB=true;
                        break;
                    }
                    else if(gradeBList.contains(unitType)){
                        gradeB=true;
                        gradeAB=true;
                    }
                    else if(gradeCList.contains(unitType)){
                        gradeC=true;
                    }
                    
                }
            }
            System.debug('74='+gradeA+'-'+gradeB+'-'+gradeC+'-'+gradeAB);
            
            // Filtering out the opp in different list accodring to the criteria
            if(opp.Account.TRM_Owner_Flag__c=='Yes'){
                
                upgradeGroupTRMList.add(opp);
            }
            else if(opp.Account.TRM_Owner_Flag__c=='No' || opp.Account.TRM_Owner_Flag__c==null){
                
                if(opp.Account.Preferred_Language__c=='SPA'  && gradeAB==false){
                    
                    
                    upgradeGroupSPAList.add(opp);
                }
                
                else if(opp.Account.Preferred_Language__c=='ENG' && gradeA==true && gradeB==false && gradeC==false  ){
                    
                    
                    upgradeGroupGradeAList.add(opp);
                    
                }
                
                else if(opp.Account.Preferred_Language__c=='ENG' && gradeB==true && gradeA==false && gradeC==false ){
                    
                    
                    upgradeGroupGradeBList.add(opp);
                    
                }
                
                else if(opp.Account.Preferred_Language__c=='ENG' && gradeC==true && gradeB==false && gradeA==false ){
                    
                    
                    upgradeGroupGradeCList.add(opp);
                    
                }
                else if(opp.Account.Preferred_Language__c=='SPA' && gradeAB==false){
                    
                    
                    upgradeGroupSPAList.add(opp);
                    
                }
                else if(opp.Account.Preferred_Language__c=='ENG' && gradeC==false && gradeB==false && gradeA==false ){
                    
                    
                    upgradeGroupList.add(opp);
                    
                }
            }
        }
        
        list<String> bCCAddress=new list<String>();
        bccAddress.add('manager@membersadvantageprogram.com');
        bccAddress.add('product@holidaysystems.com');
        
        orgList = [select Id from OrgWideEmailAddress where Address = 'welcome@hawaiicollection.com'];
        
        if(upgradeGroupSPAList.size()!=0){
            System.debug('130='+upgradeGroupSPAList);
            List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>(); 
            List<EmailTemplate> emailTemplateList = new List<EmailTemplate>();
            emailTemplateList = [SELECT Id, Body,developername, Subject, HtmlValue, Name
                                 FROM EmailTemplate
                                 WHERE developername = 'Hawaii_Collection_Welcome_Email_SPA'];
            
            for(Opportunity opp:upgradeGroupSPAList){
                
                system.debug('172='+opp.account.First_name__c);
                string whoid=opp.Id;
                string whatid=opp.AccountId;
                List<String> emailAddress=new list<string>();
                emailAddress.add(opp.Account.email__c);
                
                
                String templateBody;
                Messaging.SingleEmailMessage newEmail; 
                Messaging.SingleEmailMessage mailToBeSent = new Messaging.SingleEmailMessage(); 
                
                
                if(!emailTemplateList.isEmpty()) {
                    newEmail = Messaging.renderStoredEmailTemplate(emailTemplateList[0].id,whoId,whatId);
                }
                
                if(!emailAddress.isEmpty()) {
                    if(newEmail != null) {
                        if ( orgList.size() > 0 ) {
                            mailToBeSent.setOrgWideEmailAddressId(orgList[0].Id);
                        }
                        mailToBeSent.setSubject(newEmail.subject);
                        mailToBeSent.setHtmlBody(newEmail.HTMLBody);
                        mailToBeSent.setToAddresses(emailAddress);
                        mailToBeSent.setBccAddresses(bCCAddress);
                        emailList.add(mailToBeSent);
                    }
                    
                }
            }
            if(!emailList.isEmpty()){
                system.debug('271'+emailList.size());
                Messaging.sendEmail(emailList);
                
            }
        }
        
        // Updating TRM opp list and sending emails
        if(upgradeGroupTRMList.size()!=0){
            System.debug('130='+upgradeGroupTRMList);
            
            List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>(); 
            List<EmailTemplate> emailTemplateList = new List<EmailTemplate>();
            emailTemplateList = [SELECT Id, Body,developername, Subject, HtmlValue, Name
                                 FROM EmailTemplate
                                 WHERE developername = 'Hawaii_Collection_Welcome_Email'];
            
            
            for(Opportunity opp:upgradeGroupTRMList){
                
                system.debug('172='+opp.account.First_name__c);
                string whoid=opp.Id;
                string whatid=opp.AccountId;
                List<String> emailAddress=new list<string>();
                emailAddress.add(opp.Account.email__c);
                
                String templateBody;
                Messaging.SingleEmailMessage newEmail; 
                Messaging.SingleEmailMessage mailToBeSent = new Messaging.SingleEmailMessage(); 
                
                
                if(!emailTemplateList.isEmpty()) {
                    newEmail = Messaging.renderStoredEmailTemplate(emailTemplateList[0].id,whoId,whatId);
                }
                
                if(!emailAddress.isEmpty()) {
                    if(newEmail != null) {
                        
                        if ( orgList.size() > 0 ) {
                            system.debug('258');
                            mailToBeSent.setOrgWideEmailAddressId(orgList[0].Id);
                        }
                        mailToBeSent.setSubject(newEmail.subject);
                        mailToBeSent.setHtmlBody(newEmail.HTMLBody);
                        mailToBeSent.setToAddresses(emailAddress);
                        mailToBeSent.setBccAddresses(bCCAddress);
                        emailList.add(mailToBeSent);
                    }
                    
                }
            }
            if(!emailList.isEmpty()){
                system.debug('271'+emailList.size());
                Messaging.sendEmail(emailList);
                
            }
            
        }
        
        
        // Updating GradeA opp list and sending emails
        if(upgradeGroupGradeAList.size()!=0){
            
            System.debug('162='+upgradeGroupGradeAList);
            List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>(); 
            List<EmailTemplate> emailTemplateList = new List<EmailTemplate>();
            emailTemplateList = [SELECT Id, Body,developername, Subject, HtmlValue, Name
                                 FROM EmailTemplate
                                 WHERE developername = 'Hawaii_Collection_Welcome_Email'];
            
            for(Opportunity opp:upgradeGroupGradeAList){
                
                system.debug('172='+opp.account.First_name__c);
                string whoid=opp.Id;
                string whatid=opp.AccountId;
                List<String> emailAddress=new list<string>();
                emailAddress.add(opp.Account.email__c);
                
                String templateBody;
                Messaging.SingleEmailMessage newEmail; 
                Messaging.SingleEmailMessage mailToBeSent = new Messaging.SingleEmailMessage(); 
                
                
                if(!emailTemplateList.isEmpty()) {
                    newEmail = Messaging.renderStoredEmailTemplate(emailTemplateList[0].id,whoId,whatId);
                }
                
                if(!emailAddress.isEmpty()) {
                    if(newEmail != null) {
                        if ( orgList.size() > 0 ) {
                            mailToBeSent.setOrgWideEmailAddressId(orgList[0].Id);
                        }
                        mailToBeSent.setSubject(newEmail.subject);
                        mailToBeSent.setHtmlBody(newEmail.HTMLBody);
                        mailToBeSent.setBccAddresses(bCCAddress);
                        mailToBeSent.setToAddresses(emailAddress);
                        emailList.add(mailToBeSent);
                    }
                    
                }
            }
            if(!emailList.isEmpty()){
                system.debug('271'+emailList.size());
                Messaging.sendEmail(emailList);
                
            }
        }
        
        // Updating GradeB opp list and sending emails
        if(upgradeGroupGradeBList.size()!=0){
            
            System.debug('195='+upgradeGroupGradeBList);
            List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>(); 
            List<EmailTemplate> emailTemplateList = new List<EmailTemplate>();
            emailTemplateList = [SELECT Id, Body,developername, Subject, HtmlValue, Name
                                 FROM EmailTemplate
                                 WHERE developername = 'Hawaii_Collection_Welcome_Email'];
            for(Opportunity opp:upgradeGroupGradeBList){
                
                system.debug('172='+opp.account.First_name__c);
                string whoid=opp.Id;
                string whatid=opp.AccountId;
                List<String> emailAddress=new list<string>();
                emailAddress.add(opp.Account.email__c);
                
                String templateBody;
                Messaging.SingleEmailMessage newEmail; 
                Messaging.SingleEmailMessage mailToBeSent = new Messaging.SingleEmailMessage(); 
                
                
                if(!emailTemplateList.isEmpty()) {
                    newEmail = Messaging.renderStoredEmailTemplate(emailTemplateList[0].id,whoId,whatId);
                }
                
                if(!emailAddress.isEmpty()) {
                    if(newEmail != null) {
                        if ( orgList.size() > 0 ) {
                            mailToBeSent.setOrgWideEmailAddressId(orgList[0].Id);
                        }
                        mailToBeSent.setSubject(newEmail.subject);
                        mailToBeSent.setHtmlBody(newEmail.HTMLBody);
                        mailToBeSent.setToAddresses(emailAddress);
                        mailToBeSent.setBccAddresses(bCCAddress);
                        emailList.add(mailToBeSent);
                    }
                    if(!emailList.isEmpty()){
                        Messaging.sendEmail(emailList); 
                    }
                }
            }
            if(!emailList.isEmpty()){
                system.debug('271'+emailList.size());
                Messaging.sendEmail(emailList);
                
            }
        }
        
        
        // Updating GradeC opp list and sending emails
        if(upgradeGroupGradeCList.size()!=0){
            
            System.debug('195='+upgradeGroupGradeCList);
            List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>(); 
            List<EmailTemplate> emailTemplateList = new List<EmailTemplate>();
            emailTemplateList = [SELECT Id, Body,developername, Subject, HtmlValue, Name
                                 FROM EmailTemplate
                                 WHERE developername = 'Hawaii_Collection_Welcome_Email'];
            for(Opportunity opp:upgradeGroupGradeCList){
                
                system.debug('172='+opp.account.First_name__c);
                string whoid=opp.Id;
                string whatid=opp.AccountId;
                List<String> emailAddress=new list<string>();
                emailAddress.add(opp.Account.email__c);
                
                String templateBody;
                Messaging.SingleEmailMessage newEmail; 
                Messaging.SingleEmailMessage mailToBeSent = new Messaging.SingleEmailMessage(); 
                
                
                if(!emailTemplateList.isEmpty()) {
                    newEmail = Messaging.renderStoredEmailTemplate(emailTemplateList[0].id,whoId,whatId);
                }
                
                if(!emailAddress.isEmpty()) {
                    if(newEmail != null) {
                        if ( orgList.size() > 0 ) {
                            mailToBeSent.setOrgWideEmailAddressId(orgList[0].Id);
                        }
                        mailToBeSent.setSubject(newEmail.subject);
                        mailToBeSent.setHtmlBody(newEmail.HTMLBody);
                        mailToBeSent.setToAddresses(emailAddress);
                        mailToBeSent.setBccAddresses(bCCAddress);
                        emailList.add(mailToBeSent);
                    }
                    if(!emailList.isEmpty()){
                        Messaging.sendEmail(emailList); 
                    }
                }
            }   
            if(!emailList.isEmpty()){
                system.debug('271'+emailList.size());
                Messaging.sendEmail(emailList);
                
            }
        }
        
        
        // Updating upgradeGroupList opp list and sending emails
        if(upgradeGroupList.size()!=0){
            
            System.debug('262='+upgradeGroupList);
            List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>(); 
            List<EmailTemplate> emailTemplateList = new List<EmailTemplate>();
            emailTemplateList = [SELECT Id, Body,developername, Subject, HtmlValue, Name
                                 FROM EmailTemplate
                                 WHERE developername = 'Hawaii_Collection_Welcome_Email'];
            for(Opportunity opp:upgradeGroupList){
                
                system.debug('172='+opp.account.First_name__c);
                string whoid=opp.Id;
                string whatid=opp.AccountId;
                List<String> emailAddress=new list<string>();
                emailAddress.add(opp.Account.email__c);
                
                String templateBody;
                Messaging.SingleEmailMessage newEmail; 
                Messaging.SingleEmailMessage mailToBeSent = new Messaging.SingleEmailMessage(); 
                
                
                if(!emailTemplateList.isEmpty()) {
                    newEmail = Messaging.renderStoredEmailTemplate(emailTemplateList[0].id,whoId,whatId);
                }
                
                if(!emailAddress.isEmpty()) {
                    if(newEmail != null) {
                        if ( orgList.size() > 0 ) {
                            mailToBeSent.setOrgWideEmailAddressId(orgList[0].Id);
                        }
                        mailToBeSent.setSubject(newEmail.subject);
                        mailToBeSent.setHtmlBody(newEmail.HTMLBody);
                        mailToBeSent.setToAddresses(emailAddress);
                        mailToBeSent.setBccAddresses(bCCAddress);
                        emailList.add(mailToBeSent);
                    }
                    
                }
            }
            
            if(!emailList.isEmpty()){
                system.debug('271'+emailList.size());
                Messaging.sendEmail(emailList);
                
            }
        }
    }
   
    //2023-09-12 - PA-31 - ProfitAgility Agency MX Vouchers - SF
    @future(callout = true) 
    public static void cleanUsedProfitAgilityAgencyMXVoucherCode (Set<Id> accIds){
    
        List<Account> accountsToUpdate = new List<Account>();
		for(Id accId : accIds)
        {
            Account acc = new Account(Id=accId);
			acc.ProfitAgility_Agency_MX_Voucher_Code__c = '';
            accountsToUpdate.add(acc);
        }
        update accountsToUpdate;
    }
    
}