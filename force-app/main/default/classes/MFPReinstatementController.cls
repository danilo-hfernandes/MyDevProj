public class MFPReinstatementController {
    
    @AuraEnabled
    public static String validateAccount(String accId){
        String message ='';
        DateTime past90Days = system.now().addDays(-90); 
        List<Account> listAcc = [select id,Dues_Last_Paid_Until__c from Account where Id = :accId limit 1];
        if(listAcc != null && listAcc.size() > 0){
            if(listAcc[0].Dues_Last_Paid_Until__c > past90Days){
                String Id = MFPReinstatementController.createOpportunity(accId);
                if(Id != null){
                    message = 'Successful';
                }
            }
            else {
                message = 'Cannot renew an MFP Membership for being inactive for more than 90 days';
            }
        }
        return message;
    }
    public static String createOpportunity(String accId){
        Id recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Membership_Annual_Dues').getRecordTypeId();
        PriceBook2 pb2Standard = [select Id from Pricebook2 where isStandard=true];
        List<Product2> objProduct = [select id,Name from Product2 where Name = 'MFP Reinstatement' or Name = 'Annual Dues-Renewal' limit 2];
        List<PricebookEntry> pbEntry = [select id,Product2Id from PricebookEntry where Pricebook2Id =: pb2Standard.Id and (Product2.Name = 'MFP Reinstatement' or Product2.Name = 'Annual Dues-Renewal') limit 2];
        Account objacc = [select id,Membership_Annual_Due__c,MFP_Opportunity__c from Account where Id = : accId limit 1];
        Map<String, String> mapProductvsPriceBookEntry = new Map<String, String>();
        Opportunity opp = new Opportunity();
        opp.Name = 'Membership_Annual_Dues';
        opp.StageName = 'New';
        opp.CloseDate = System.Today();
        opp.RecordTypeId = recordTypeId;
        opp.AccountId = accId;
        opp.Pricebook2Id = pb2Standard.Id;
        insert opp;

        for(PricebookEntry objpb : pbEntry){
            mapProductvsPriceBookEntry.put(objpb.Product2Id, objpb.Id);
        }
        List<OpportunityLineItem> lineItemList = new List<OpportunityLineItem>();
        for(Product2 objProd : objProduct){
            OpportunityLineItem opplineItem = new OpportunityLineItem();
            opplineItem.opportunityId = opp.Id;
            opplineItem.Product2Id = objProd.Id;
            opplineItem.PricebookEntryId = mapProductvsPriceBookEntry.get(objProd.Id);
            opplineItem.Quantity = 1;
            if(objProd.Name == 'Annual Dues-Renewal'){
                opplineItem.Retail_Price__c = objacc.Membership_Annual_Due__c;
            }
            lineItemList.add(opplineItem);
        }
        if(lineItemList != null && lineItemList.size() > 0){
            insert lineItemList;
        }
        //Account objacc = new Account();
        //objacc.Id = accId;
        //objacc.MFP_Reinstatement_Timestamp__c = System.now();
        objacc.MFP_Opportunity__c	= opp.Id;
        update objacc;

        return opp.Id;
    }
}