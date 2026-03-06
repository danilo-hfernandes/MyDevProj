global class AnnualDuesCatchUpBatchController implements Database.Batchable<sObject>{
    global Date myDate1;
    global Date myDate2;
    global AnnualDuesCatchUpBatchController(){
        myDate1 = Date.newInstance(2022, 7, 1);
        myDate2 = Date.newInstance(2022, 8, 21);
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'select id,Member_Number__c,Affiliate_Name__c,Preferred_Language__c,Dues_Last_Paid_Until__c,Membership_Annual_Due__c from Account where Membership_Product_Configuration__r.Responsible_Party__c = \'Member\' and Dues_Last_Paid_Until__c >=: myDate1 and  Dues_Last_Paid_Until__c <=: myDate2';
         system.debug(query);
        return Database.getQueryLocator(query); 
    }
    global void execute(Database.BatchableContext BC, List<Account> scope){
        List<Opportunity> lstopp = new List<Opportunity>();
        Map<Id, Decimal> mapAccountIdToAnnualRevenue = new Map<Id, Decimal>();
        String oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Membership Annual Dues').getRecordTypeId();
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
            opp.Annual_Dues_Match_Group__c = 'Annual Dues Catch Up';
            lstopp.add(opp);
        }
        lstopp = GenericMatchGroupAssignmentHandler.assignMatchGroup(lstopp, null);
        //Database.insert(lstopp, false);
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