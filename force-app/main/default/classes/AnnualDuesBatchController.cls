global class AnnualDuesBatchController implements Database.Batchable<sObject>, Schedulable{
    //global Date future60Days;
    global Date past10Days;
    global AnnualDuesBatchController(){
        //future60Days = Date.today().addDays(60);
        past10Days = Date.today().addDays(-10);
    }
    global void execute(SchedulableContext SC) {
        AnnualDuesBatchController objBatch = new AnnualDuesBatchController(); 
        database.executebatch(objBatch, 1);
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        //system.debug('>>>future60Days>>>>'+future60Days);
        system.debug('>>>past10Days>>>>'+past10Days);
       String query = System.Label.Annual_Dues_Query +'and Dues_Last_Paid_Until__c =:past10Days';//(Dues_Last_Paid_Until__c =:future60Days or)
       system.debug(query);
       return Database.getQueryLocator(query); 
    }
    global void execute(Database.BatchableContext BC, List<Account> scope){
        List<Opportunity> lstopp = new List<Opportunity>();
        Map<Id, Decimal> mapAccountIdToAnnualRevenue = new Map<Id, Decimal>();
        String oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Membership Annual Dues').getRecordTypeId();
        //listAffiliateIdsHawaiiCollection added 2023-04-19
        List<Integer> listAffiliateIdsHawaiiCollection = new List<Integer>{1002243,1002311,1002312,1002310};
        PriceBook2 pb2Standard = [select Id from Pricebook2 where isStandard=true];
        Product2 objProduct = [select id from Product2 where Name = 'Annual Dues-Renewal' limit 1];
        List<PricebookEntry> pbEntry = [select id from PricebookEntry where Pricebook2Id =: pb2Standard.Id and Product2Id =: objProduct.Id limit 1];
        system.debug('>>>scope>>>'+scope);
        for(Account objacc : scope){
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
            if(objacc.Preferred_Language__c == 'ENG'){
                /*if(objacc.Dues_Last_Paid_Until__c == future60Days){
                    opp.Annual_Dues_Match_Group__c = '60 Days to Past Due-ENG';
                }
                else */
                if(objacc.Dues_Last_Paid_Until__c == past10Days){
                    //listAffiliateIdsHawaiiCollection check added 2023-04-19
                    if(listAffiliateIdsHawaiiCollection.contains(Integer.ValueOf(objacc.Affiliated_Id__c)))
                    {
                        opp.Annual_Dues_Match_Group__c = 'Hawaii Collection 10 Days past Due Date-ENG';                        
                    }
                    else
                    {
                        opp.Annual_Dues_Match_Group__c = '10 Days Past Due-ENG';                        
                    }
                    //opp.Annual_Dues_Match_Group__c = '10 Days Past Due-ENG';
                }
            }
            else if(objacc.Preferred_Language__c == 'SPA'){
               /*if(objacc.Dues_Last_Paid_Until__c == future60Days){
                    opp.Annual_Dues_Match_Group__c = '60 Days to Past Due-SPA';
                }
                else*/
                if(objacc.Dues_Last_Paid_Until__c == past10Days){
                    //listAffiliateIdsHawaiiCollection check added 2023-04-19
                    if(listAffiliateIdsHawaiiCollection.contains(Integer.ValueOf(objacc.Affiliated_Id__c)))
                    {
                        opp.Annual_Dues_Match_Group__c = 'Hawaii Collection 10 Days past Due Date-SPA';
                    }
                    else
                    {
                        opp.Annual_Dues_Match_Group__c = '10 Days Past Due-SPA';
                    }
                    //opp.Annual_Dues_Match_Group__c = '10 Days Past Due-SPA';
                }
            }
            lstopp.add(opp);
        }
        //Database.insert(lstopp, false);
        lstopp = GenericMatchGroupAssignmentHandler.assignMatchGroup(lstopp, null);
        insert lstopp;
        system.debug('>>>>>>>Opportunity List>>>>>'+lstopp);
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
        for(Opportunity opp : lstopp){
            OpportunityLineItem opplineItem = new OpportunityLineItem();
            opplineItem.Product2Id = objProduct.Id;
            opplineItem.OpportunityId = opp.Id;
            opplineItem.Retail_Price__c = mapAccountIdToAnnualRevenue.get(opp.AccountId);
            opplineItem.Quantity = 1;
            opplineItem.TotalPrice = mapAccountIdToAnnualRevenue.get(opp.AccountId) * 5;
            opplineItem.PricebookEntryId = objpbEntry.Id;
            opplineItemList.add(opplineItem);
        }
        insert opplineItemList;
       // Database.insert(opplineItemList, false);
    }
    global void finish(Database.BatchableContext BC){

    }
}