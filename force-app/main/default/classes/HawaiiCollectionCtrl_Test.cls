@isTest(SeeallData = true)
public class HawaiiCollectionCtrl_Test {
    @isTest
    public static void AllActiveProduct3(){
        
        Account a = new Account();
        a.Name = 'test account';
        a.Email__c = 'thumarmitulextra@gmail.com';
        insert a;
        
        Id RecordType = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Hawaii_Collection_Membership').getRecordTypeId();
        
        Opportunity o = new Opportunity();
        o.name = 'test opp';
        o.CloseDate = System.today();
        o.AccountId = a.id;
        o.Closed_Lost_Date__c = system.today();
        o.RecordTypeId = RecordType;
        o.StageName = 'In Process';
        insert o;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        Product2 prod = new Product2();
        prod.Name = 'Hawaii Collection Silver-Membership Upgrade';
        prod.IsActive = true;
        prod.Opportunity__c = o.Id;
        insert prod;
        
        //Pricebook2 pb2 = new Pricebook2();
        
        PricebookEntry pbEntry = new PricebookEntry();
        pbEntry.Pricebook2Id = pricebookId;
        pbEntry.Product2Id = prod.Id;
        pbEntry.UnitPrice = 100.00;
        pbEntry.IsActive = true;
        
        insert pbEntry;
        
        
        OpportunityLineItem oli = new OpportunityLineItem();
        oli.OpportunityId = o.Id;
        oli.Quantity = 5;
        oli.PricebookEntryId = pbEntry.Id;
        oli.TotalPrice = pbEntry.UnitPrice;
        
        insert oli;
        
        List<HawaiiCollectionCtrl.productWrapper> productList = new List<HawaiiCollectionCtrl.productWrapper>();
        HawaiiCollectionCtrl.productWrapper product = new HawaiiCollectionCtrl.productWrapper();
        product.selected = true;
        product.unitprice = 30000;
        productList.add(product);
        
        HawaiiCollectionCtrl HawaiiCtrl = new HawaiiCollectionCtrl();
        HawaiiCollectionCtrl.AllActiveProductList();
        HawaiiCollectionCtrl.saveProductLineItem(productList, a.Id, prod.Id);
        
        HawaiiCollectionOppLineItemFuture hcf = new HawaiiCollectionOppLineItemFuture();
        Test.startTest();
        HawaiiCollectionOppLineItemFuture.oppLineItemCreation(o.Id, prod.Id, 10000, prod.Name);
        
        Test.stopTest();
    }
}