public class HawaiiCollectionOppLineItemFuture {
	@future(callout=true)
     public static void oppLineItemCreation(Id oppId,Id productId,decimal unitprice,string productName){
     Product2 productCruise = [select id,Name from product2 where Name = 'Cruise Certificate Add-On' and isActive = true];
        List<PricebookEntry> pricebookList = [select id ,Product2.Family,Name,Pricebook2Id ,Product2Id,UnitPrice from PricebookEntry where IsActive= true];
       
                Map<Id,PricebookEntry> PriceBookId = new Map<Id,PricebookEntry>();
                Map<Id,String> getProductFamily = new Map<Id,String>();
                system.debug('--pricebookList---'+pricebookList);
                for(PricebookEntry ppe : pricebookList){
                    PriceBookId.put(ppe.Product2Id,ppe);
                }
                List<OpportunityLineItem> oppProductList = new List<OpportunityLineItem>();
                OpportunityLineItem oli = new OpportunityLineItem();
                oli.OpportunityId = oppId;
                PricebookEntry pp = PriceBookId.get(productId);
                oli.PricebookEntryId=pp.Id;
                oli.Retail_Price__c = unitprice; 
                 oppProductList.add(oli);
                OpportunityLineItem oliC = new OpportunityLineItem();
                oliC.OpportunityId = oppId;
                PricebookEntry pp1 = PriceBookId.get(productCruise.Id);
                oliC.PricebookEntryId=pp1.Id;
                oliC.Retail_Price__c = pp1.unitprice; 
                oppProductList.add(oliC);
                OpportunityLineItem oliC2 = new OpportunityLineItem();
                if(productName == 'Hawaii Collection Platinum-Membership Upgrade'){
                    
                    oliC2.OpportunityId = oppId;
                    PricebookEntry pp2 = PriceBookId.get(productCruise.Id);
                    oliC2.PricebookEntryId=pp2.Id;
                    oliC2.Retail_Price__c = pp2.unitprice;
                     
                    oppProductList.add(oliC2);
                }
                    
                    try{
                        insert oppProductList;
                        system.debug('--oppProductList--'+oppProductList);    
                        
                    }catch (Exception ex){
                        ApexPages.Message msg = new ApexPages.Message(Apexpages.Severity.ERROR, ex.getdmlMessage(0) );
                        String errorMessage = string.valueof(msg);
                        system.debug('---e---'+ex+'---line---'+ex.getLineNumber());
                        if(errorMessage.contains('The minimum price for Hawaii Collection')){
                            throw new AuraHandledException('The minimum price for Hawaii Collection Silver is $995 and Hawaii Collection Gold is $1695 and Hawaii Collection Platinum is 3095');    
                        }
                    }
                    system.debug('---create lineite,');
                 
            }
     
}