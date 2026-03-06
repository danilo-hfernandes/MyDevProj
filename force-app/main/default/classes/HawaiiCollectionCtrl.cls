public class HawaiiCollectionCtrl {
    
    public class productWrapper {
        @AuraEnabled public product2 prd { get; set; }
        @AuraEnabled public Boolean selected { get; set; }
        @AuraEnabled public decimal unitprice{get;set;}
    }
    
    @AuraEnabled 
    public static List<productWrapper> AllActiveProductList(){  
        List<productWrapper> productListObj = new List<productWrapper>();
        List<PricebookEntry> pricebookList = new List<PricebookEntry>();
        pricebookList = [select id ,Name,Pricebook2Id ,Product2Id,UnitPrice from PricebookEntry where IsActive= true ];
        Map<Id,Decimal> listpriceMap = new Map<Id,Decimal>();
        for(PricebookEntry ppe : pricebookList){
            listpriceMap.put(ppe.Product2Id,ppe.UnitPrice);
        }
        List<Product2> productList = [select id,Name,Description from product2 where Name LIKE '%Hawaii Collection%' and isActive = true order by Order_for_MTRC_View__c asc];
        for(Product2 pro : productList){
            productWrapper wrp = new productWrapper();
            if(listpriceMap.containskey(pro.id)){
                wrp.unitprice = listpriceMap.get(pro.Id);
            }
            wrp.prd = pro;
            wrp.selected = false;
            productListObj.add(wrp);
            system.debug('productListObj'+productListObj);
        }
        return productListObj;
    }
    
    @AuraEnabled
    public static string saveProductLineItem(List<productWrapper> proWrapperlist,Id AccId,Id productId){
        
        system.debug('--productId--'+productId);
        
        
        Id hawaiiCollectionRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Hawaii_Collection_Membership').getRecordTypeId();
        Opportunity opp = new Opportunity();
        opp.Name = AccId;
        opp.AccountId = AccId;
        opp.CloseDate = System.today()+1;
        opp.StageName = 'New';
        opp.RecordTypeId = hawaiiCollectionRecordTypeId;
        
        insert opp;
        for(productWrapper wrp : proWrapperlist){
            if(wrp.selected){
                Account acc = [select id,Email__c from Account where Id =: AccId limit 1];
                if(acc.Email__c == null){
                    throw new AuraHandledException('Account does not have email address, Please fill the email address first'); 
                }
                //IF((Product2.Name == '' &&   UnitPrice < 995) || (Product2.Name == '' &&  UnitPrice < 1495 )|| (Product2.Name == '' &&  UnitPrice < ),true,false)
                //ApexPages.Message msg = new ApexPages.Message(Apexpages.Severity.ERROR, ex.getdmlMessage(0) );    
                if(wrp.prd.Name == 'Hawaii Collection Silver-Membership Upgrade' && wrp.unitprice < 995){
					throw new AuraHandledException('The minimum price for Hawaii Collection Silver is $995');                        
                }else if(wrp.prd.Name == 'Hawaii Collection Gold-Membership Upgrade' && wrp.unitprice < 1495){
					throw new AuraHandledException('The minimum price for Hawaii Collection Gold is $1495');                        
                }else if(wrp.prd.Name == 'Hawaii Collection Platinum-Membership Upgrade' && wrp.unitprice < 2795){
					throw new AuraHandledException('The minimum price for Hawaii Collection Platinum is 2795');                        
                }else{
                 system.debug('---unitprice--'+wrp.unitprice);
                    system.debug('---wrp.prd.Name---'+wrp.prd.Name);
        			HawaiiCollectionOppLineItemFuture.oppLineItemCreation(opp.Id,productId, wrp.unitprice, wrp.prd.Name);
                }
            }
        }
        /*
        Product2 productCruise = [select id,Name from product2 where Name = 'Cruise Certificate Add-On' and isActive = true];
        List<PricebookEntry> pricebookList = [select id ,Product2.Family,Name,Pricebook2Id ,Product2Id,UnitPrice from PricebookEntry where IsActive= true];
        for(productWrapper wrp : proWrapperlist){
            if(wrp.selected){
                Map<Id,PricebookEntry> PriceBookId = new Map<Id,PricebookEntry>();
                Map<Id,String> getProductFamily = new Map<Id,String>();
                system.debug('--pricebookList---'+pricebookList);
                for(PricebookEntry ppe : pricebookList){
                    PriceBookId.put(ppe.Product2Id,ppe);
                }
                List<OpportunityLineItem> oppProductList = new List<OpportunityLineItem>();
                OpportunityLineItem oli = new OpportunityLineItem();
                oli.OpportunityId = opp.Id;
                PricebookEntry pp = PriceBookId.get(productId);
                oli.PricebookEntryId=pp.Id;
                oli.Retail_Price__c = wrp.unitprice; 
                 system.debug('---wrp---'+wrp.prd.Name);
                oppProductList.add(oli);
                OpportunityLineItem oliC = new OpportunityLineItem();
                oliC.OpportunityId = opp.Id;
                PricebookEntry pp1 = PriceBookId.get(productCruise.Id);
                oliC.PricebookEntryId=pp1.Id;
                oliC.Retail_Price__c = pp1.unitprice; 
                oppProductList.add(oliC);
                OpportunityLineItem oliC2 = new OpportunityLineItem();
                if(wrp.prd.Name == 'Hawaii Collection Platinum-Membership Upgrade'){
                    
                    oliC2.OpportunityId = opp.Id;
                    PricebookEntry pp2 = PriceBookId.get(productCruise.Id);
                    oliC2.PricebookEntryId=pp2.Id;
                    oliC2.Retail_Price__c = pp2.unitprice;
                     
                    oppProductList.add(oliC2);
                }
                    
                    try{
                    	system.debug('--oli--'+oli);    
                        system.debug('--oliC--'+oliC);    
                        system.debug('--oliC2--'+oliC2);    
                        //insert oli;
                        //insert oliC;
                        //insert oliC2;
                        insert oppProductList;
                        system.debug('--oli--'+oli);    
                        system.debug('--oliC--'+oliC);    
                        system.debug('--oliC2--'+oliC2);    
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
                    break;
                }
            }*/
            return 'true';
        }
    }