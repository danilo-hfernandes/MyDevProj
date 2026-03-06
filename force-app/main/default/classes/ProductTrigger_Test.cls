@isTest
public class ProductTrigger_Test {

    @isTest
    static void test1() {
        Apex_Trigger_On_Off__c cm = new Apex_Trigger_On_Off__c();
        cm.Name = 'ProductTrigger';
        cm.isEnable__c = true;
        insert cm;
        
        Account acc = new Account();
        acc.Name = 'test account';
        insert acc;
        
        Product2 p = new Product2();
        p.Name = 'My Travel Rewards Club Gold';
        p.isActive = true;
        insert p;

        
        id pricebookId = Test.getStandardPricebookId();
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = p.Id, UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        
        Pricebook2 pb = new Pricebook2();
        pb.isActive = true;
        pb.Name = 'Standard Pricebook';
        insert pb;
        
        Opportunity opp = new Opportunity();
        opp.AccountId = acc.id;
        opp.StageName = 'Pitched - Follow Up*';
        opp.CloseDate = System.today();
        opp.Name = 'test opp';
        opp.Pricebook2Id = Test.getStandardPricebookId();
        
        insert opp;
        
        List<PricebookEntry> pbe = [select id, name from PriceBookEntry where Pricebook2id =: pb.id and Product2Id =: p.id];
        List<OpportunityLineItem> oppList = new List<OpportunityLineItem>();
        
        OpportunityLineItem oppline = new OpportunityLineItem();
        oppline.OpportunityId = opp.Id;
        oppline.UnitPrice = 7500;
        oppline.Product2Id = p.id;
        oppline.PricebookEntryId = standardPrice.id;
        oppline.Quantity = 1;
          oppline.Retail_Price__c = 20;
        
        insert oppline;
        
        insert oppList;
        delete oppline;
    }
    
    @isTest
    static void test2() {
         Apex_Trigger_On_Off__c cm = new Apex_Trigger_On_Off__c();
        cm.Name = 'ProductTrigger';
        cm.isEnable__c = true;
        insert cm;
        Profile profileRec = [SELECT Id FROM Profile WHERE Name='Membership Upgrade Manager']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = profileRec.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='st'+Integer.valueof((Math.random() * 100))+'@vi.com');
        
        System.runAs(u) {
            
            Account acc = new Account();
            acc.Name = 'test account';
            insert acc;
            
            Product2 p = new Product2();
            p.Name = 'My Travel Rewards Club Gold';
            p.isActive = true;
            insert p;
            
            
            id pricebookId = Test.getStandardPricebookId();
            PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = p.Id, UnitPrice = 10000, IsActive = true);
            insert standardPrice;
            
            Pricebook2 pb = new Pricebook2();
            pb.isActive = true;
            pb.Name = 'Standard Pricebook';
            insert pb;
            
            Opportunity opp = new Opportunity();
            opp.AccountId = acc.id;
            opp.StageName = 'Pitched - Follow Up*';
            opp.CloseDate = System.today();
            opp.Name = 'test opp';
            opp.Pricebook2Id = Test.getStandardPricebookId();
            insert opp;
            
            Payment__c paymentRec = new Payment__c();
            paymentRec.Name = 'temp';
            paymentRec.Opportunity__c = opp.Id;
            insert paymentRec;
            
            List<PricebookEntry> pbe = [select id, name from PriceBookEntry where Pricebook2id =: pb.id and Product2Id =: p.id];
            List<OpportunityLineItem> oppList = new List<OpportunityLineItem>();
            
            OpportunityLineItem oppline = new OpportunityLineItem();
            oppline.OpportunityId = opp.Id;
            oppline.UnitPrice = 7500;
            oppline.Product2Id = p.id;
            oppline.PricebookEntryId = standardPrice.id;
            oppline.Quantity = 1;
            oppline.Retail_Price__c = 20;
            
            insert oppline;
            
            insert oppList;
            
            try{
            	delete oppline;    
            }catch(Exception E){
                
            }
            
        }
        
    }
    
    @isTest
    static void test3() {
         Apex_Trigger_On_Off__c cm = new Apex_Trigger_On_Off__c();
        cm.Name = 'ProductTrigger';
        cm.isEnable__c = true;
        insert cm;
        Account acc = new Account();
        acc.Name = 'test account';
        insert acc;
        
        Product2 p = new Product2();
        p.Name = 'Voucher-Flex Stays 4/3';
        p.isActive = true;
        insert p;

        
        id pricebookId = Test.getStandardPricebookId();
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = p.Id, UnitPrice = 299, IsActive = true);
        insert standardPrice;
        
        Pricebook2 pb = new Pricebook2();
        pb.isActive = true;
        pb.Name = 'Standard Pricebook';
        insert pb;
        
        Opportunity opp = new Opportunity();
        opp.AccountId = acc.id;
        opp.StageName = 'Pitched - Follow Up*';
        opp.CloseDate = System.today();
        opp.Name = 'test opp';
        opp.Pricebook2Id = Test.getStandardPricebookId();
        
        insert opp;
        
        List<PricebookEntry> pbe = [select id, name from PriceBookEntry where Pricebook2id =: pb.id and Product2Id =: p.id];
        List<OpportunityLineItem> oppList = new List<OpportunityLineItem>();
        
        OpportunityLineItem oppline = new OpportunityLineItem();
        oppline.OpportunityId = opp.Id;
        oppline.UnitPrice = 299;
        oppline.Product2Id = p.id;
        oppline.PricebookEntryId = standardPrice.id;
        oppline.Quantity = 1;
          oppline.Retail_Price__c = 299;
        
        insert oppline;
        
        insert oppList;
        
        Cruise_Certificates__c crs = new Cruise_Certificates__c();
        crs.Certificate_ID__c = '232dre';
        crs.Company__c = 'testcom';
        insert crs;
      
        
        oppline.Certificate_ID__c = '232dre';
        
        update oppline;
    }
    
    
}