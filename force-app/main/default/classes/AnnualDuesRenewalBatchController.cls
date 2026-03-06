global class AnnualDuesRenewalBatchController implements Database.Batchable<sObject>, Schedulable{
    global Date future15Days;
    global Date past10Days;
    global Date today;
    global AnnualDuesRenewalBatchController(){
        future15Days = Date.today().addDays(15);
        past10Days = Date.today().addDays(-10);
        //today = Date.today();
    }
    global void execute(SchedulableContext SC) {
        AnnualDuesRenewalBatchController objBatch = new AnnualDuesRenewalBatchController(); 
        database.executebatch(objBatch, 1);
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        system.debug('>>>future60Days>>>>'+future15Days);
        system.debug('>>>past10Days>>>>'+past10Days);
        String query = System.Label.Annual_Dues_Renewal_Query+'and (Dues_Last_Paid_Until__c =:future15Days or Dues_Last_Paid_Until__c =:past10Days)'; //and Dues_Last_Paid_Until__c >=:today)
        system.debug(query);
        return Database.getQueryLocator(query); 
    }
    global void execute(Database.BatchableContext BC, List<Account> scope){
        system.debug('>>>>>Scope>>>>>>'+scope.size());
        List<Opportunity> lstopp = new List<Opportunity>();
        //listAffiliateIdsHawaiiCollection added 2023-04-19
        List<Integer> listAffiliateIdsHawaiiCollection = new List<Integer>{1002243,1002311,1002312,1002310};
        List<Integer> listAffiliateIdsSMTN = new List<Integer>{1002222, 1002347, 1002223, 1002224, 1002343, 1002327};
            List<Integer> listAffiliateIds = new List<Integer>{1002222, 1002347, 1002223, 1002224, 1002343, 1002327, 1002277, 1002276, 1002319, 1002320, 1002275};
                Map<Id, Decimal> mapAccountIdToAnnualRevenue = new Map<Id, Decimal>();
        String oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Membership Annual Dues').getRecordTypeId();
        PriceBook2 pb2Standard = [select Id from Pricebook2 where isStandard=true];
        Product2 objProduct = [select id from Product2 where Name = 'Annual Dues-Renewal' limit 1];
        List<PricebookEntry> pbEntry = [select id from PricebookEntry where Pricebook2Id =: pb2Standard.Id and Product2Id =: objProduct.Id limit 1];
        system.debug('>>>scope>>>'+scope);
        for(Account objacc : scope){
            //if(objacc.Opportunities.size() == null || objacc.Opportunities.size() == 0){
                Decimal annualRevenue = objacc.Membership_Annual_Due__c != null ? objacc.Membership_Annual_Due__c : 0;
                mapAccountIdToAnnualRevenue.put(objacc.Id, annualRevenue);
                Opportunity opp = new Opportunity();
                opp.Name = 'Annual Dues';
                opp.StageName = 'New';
                opp.CloseDate = System.today().addDays(15);
                opp.RecordTypeId = oppRecordTypeId;
                opp.AccountId = objacc.Id;
                //opp.leadassist__Use_Round_Robin__c = 'TRUE';
                opp.Pricebook2Id = pb2Standard.Id;
                opp.Member_Number__c = objacc.Member_Number__c;
                opp.Affiliate_Name__c = objacc.Affiliate_Name__c;
                //opp.OwnerId = UserInfo.getUserId();
                if(listAffiliateIdsSMTN.contains(Integer.ValueOf(objacc.Affiliated_Id__c)) && objacc.Dues_Last_Paid_Until__c == future15Days ){//(&& objacc.Dues_Last_Paid_Until__c >= today)
                    opp.Annual_Dues_Match_Group__c = 'SMTN Loyalty 15 Days from Due Date';
                    lstopp.add(opp);
                }
                else if(objacc.Preferred_Language__c == 'ENG'){
                    system.debug('>>>>>>>>objacc.Affiliated_Id__c>>>>>>>>'+Integer.ValueOf(objacc.Affiliated_Id__c));
                    system.debug('>>>>>>>>>!listAffiliateIds.contains(objacc.Affiliated_Id__c)>>>>>>>'+!listAffiliateIds.contains(Integer.ValueOf(objacc.Affiliated_Id__c)));
                    if(!listAffiliateIds.contains(Integer.ValueOf(objacc.Affiliated_Id__c)) && objacc.Dues_Last_Paid_Until__c == future15Days ){//&& objacc.Dues_Last_Paid_Until__c >= today)
                        //listAffiliateIdsHawaiiCollection check added 2023-04-19
                        if(listAffiliateIdsHawaiiCollection.contains(Integer.ValueOf(objacc.Affiliated_Id__c)))
                        {
                            opp.Annual_Dues_Match_Group__c = 'Hawaii Collection 15 Days from Due Date-ENG';
                            lstopp.add(opp);
                        }
                        else
                        {
                            opp.Annual_Dues_Match_Group__c = 'Annual Dues 15 Days from Due Date-ENG';
                            lstopp.add(opp);
                        }
                    }
                    else if(objacc.Dues_Last_Paid_Until__c == past10Days){
                        //listAffiliateIdsHawaiiCollection check added 2023-04-19
                        if(listAffiliateIdsHawaiiCollection.contains(Integer.ValueOf(objacc.Affiliated_Id__c)))
                        {
                            opp.Annual_Dues_Match_Group__c = 'Hawaii Collection 10 Days past Due Date-ENG';
                            lstopp.add(opp);
                        }
                        else
                        {
                            opp.Annual_Dues_Match_Group__c = '10 Days Past Due-ENG';
                            lstopp.add(opp);
                        }
                    }
                }
                else if(objacc.Preferred_Language__c == 'SPA'){
                    if(!listAffiliateIds.contains(Integer.ValueOf(objacc.Affiliated_Id__c)) && objacc.Dues_Last_Paid_Until__c == future15Days ){//&& objacc.Dues_Last_Paid_Until__c >= today)
                        //listAffiliateIdsHawaiiCollection check added 2023-04-19
                        if(listAffiliateIdsHawaiiCollection.contains(Integer.ValueOf(objacc.Affiliated_Id__c)))
                        {
                            opp.Annual_Dues_Match_Group__c = 'Hawaii Collection 15 Days from Due Date-SPA';
                            lstopp.add(opp);
                        }
                        else{
                            opp.Annual_Dues_Match_Group__c = 'Annual Dues 15 Days from Due Date-SPA';
                            lstopp.add(opp);
                        }
                    }
                    else if(objacc.Dues_Last_Paid_Until__c == past10Days){
                        //listAffiliateIdsHawaiiCollection check added 2023-04-19
                        if(listAffiliateIdsHawaiiCollection.contains(Integer.ValueOf(objacc.Affiliated_Id__c)))
                        {
                            opp.Annual_Dues_Match_Group__c = 'Hawaii Collection 10 Days past Due Date-SPA';
                            lstopp.add(opp);
                        }
                        else
                        {
                            opp.Annual_Dues_Match_Group__c = '10 Days Past Due-SPA';
                            lstopp.add(opp);
                        }
                    }
                }
            }
        //}
        //Database.insert(lstopp, false);
        if(lstopp != null && lstopp.size() > 0){
            lstopp = GenericMatchGroupAssignmentHandler.assignMatchGroup(lstopp, null);
            insert lstopp;
            system.debug('>>>>>>>Opportunity List>>>>>'+lstopp);
            set<Id> opportunityIds = new set<Id>();
            for(Opportunity opp : lstopp){
                opportunityIds.add(opp.Id);
            }
            system.debug('>>>>>>>'+opportunityIds);
            Map<Id, Opportunity> mapIdToOpportunity = new Map<ID, Opportunity>([SELECT Id, Name, OwnerId FROM Opportunity where Id IN: opportunityIds]);
            system.debug('>>>>>>>mapIdToOpportunity>>>>>'+mapIdToOpportunity);
            
            PricebookEntry objpbEntry = new PricebookEntry();
            if(pbEntry != null && pbEntry.size() >0){
                objpbEntry = pbEntry[0];
            }
            else{
                objpbEntry.Product2Id = objProduct.Id;
                objpbEntry.Pricebook2Id = pb2Standard.Id;
                objpbEntry.IsActive = true;
                objpbEntry.UnitPrice = 0;
                insert objpbEntry;
            }
            List<OpportunityLineItem> opplineItemList = new List<OpportunityLineItem>();
            List<Task> tasklist = new List<Task>();
            for(Opportunity opp : lstopp){
                OpportunityLineItem opplineItem = new OpportunityLineItem();
                opplineItem.Product2Id = objProduct.Id;
                opplineItem.OpportunityId = opp.Id;
                opplineItem.Retail_Price__c = mapAccountIdToAnnualRevenue.get(opp.AccountId);
                opplineItem.Quantity = 1;
                if(opp.Annual_Dues_Match_Group__c == '10 Days Past Due-ENG' || opp.Annual_Dues_Match_Group__c == '10 Days Past Due-SPA' || opp.Annual_Dues_Match_Group__c == 'Hawaii Collection 10 Days past Due Date-ENG' || opp.Annual_Dues_Match_Group__c == 'Hawaii Collection 10 Days past Due Date-SPA')
                    opplineItem.TotalPrice = mapAccountIdToAnnualRevenue.get(opp.AccountId)* 5;
                else 
                    opplineItem.TotalPrice = mapAccountIdToAnnualRevenue.get(opp.AccountId);
                opplineItem.PricebookEntryId = objpbEntry.Id;
                opplineItemList.add(opplineItem);
                if(opp.Annual_Dues_Match_Group__c == 'SMTN Loyalty 15 Days from Due Date' || opp.Annual_Dues_Match_Group__c == 'Annual Dues 15 Days from Due Date-ENG' || opp.Annual_Dues_Match_Group__c == 'Annual Dues 15 Days from Due Date-SPA' || opp.Annual_Dues_Match_Group__c == 'Hawaii Collection 15 Days from Due Date-ENG' || opp.Annual_Dues_Match_Group__c == 'Hawaii Collection 15 Days from Due Date-SPA'){
                    Task objtask = new Task();
                    objtask.Subject = opp.Annual_Dues_Match_Group__c == 'SMTN Loyalty 15 Days from Due Date'? 'SMTN Loyalty 15 Days from Due Date-Call 1': 'Follow Up';
                    objtask.ActivityDate = System.today();
                    objtask.WhatId = opp.Id;
                    //objtask.WhoId = opp.contactId;
                    objtask.OwnerId = mapIdToOpportunity.get(opp.Id).OwnerId;
                    tasklist.add(objtask);
                }
            }
            insert opplineItemList;
            insert tasklist;
            // Database.insert(opplineItemList, false);
        }
    }
    global void finish(Database.BatchableContext BC){
        
    }
}