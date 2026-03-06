@istest
public class ProductPricingAPITest{
    static testMethod void testGet() {
        
       // ProductDetails classToTest = new ProductDetails();
      Account acc = new Account();{
            acc.Name='Test Account';
            insert acc;}
        
        system.debug('acc---'+acc.Id);
        Contact con = new Contact();{
            con.AccountId=acc.Id;
            con.FirstName='Test';
            con.LastName='Second Name';
            insert con;
        }
        system.debug('con---'+con.Id);
        
        Opportunity op = new Opportunity();{
            op.Name='Test Op';
            op.StageName='Closed Won';
            op.CloseDate=system.Today();
            insert op;
        } system.debug('op---'+op);
        
        OpportunityLineItem TestOpp = new OpportunityLineItem();{
            
            Pricebook2 standardPricebook = new Pricebook2(
                Id = Test.getStandardPricebookId(),
                IsActive = true
            );
            update standardPricebook;
            
            system.debug('standardPricebook'+standardPricebook);
            standardPricebook = [SELECT IsStandard FROM Pricebook2 WHERE Id = :standardPricebook.Id];
            Product2 p = new Product2();{
                p.Opportunity__c=op.Id;
                p.Name='Activity';
                p.IsActive=true;
            }
            insert p;
            system.debug('p---'+p);
            PricebookEntry pbe = new PricebookEntry(UnitPrice=10.0, Product2Id=p.Id, Pricebook2Id=standardPricebook.Id, IsActive=true);
            insert pbe;
            system.debug('pbe----'+pbe);
            
            TestOpp.PricebookEntryId=pbe.Id;
            TestOpp.OpportunityId=op.Id;
            TestOpp.Product2Id=p.Id;
            TestOpp.Quantity=2;
            TestOpp.Retail_Price__c=11.0;
            TestOpp.TotalPrice=TestOpp.Quantity*pbe.UnitPrice;
            insert TestOpp;
            system.debug('after insert TestOpp ---'+TestOpp);
            List <OpportunityLineItem>  OppLineItemList = [SELECT Id,Name,OpportunityId,Opportunity.Name,Product2.Name,Product_Id__c,UnitPrice FROM OpportunityLineItem 
                                                           where id =: TestOpp.Id];
            system.debug('OppLineItemList'+OppLineItemList);
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            req.httpMethod = 'Get';
            req.requestURI= 'https://holidaysystems--partial.my.salesforce.com/services/apexrest/ProductDetails/'+OppLineItemList[0].Product_Id__c;
            system.debug('req.requestURI----'+req.requestURI);
            RestContext.request = req;
            RestContext.response= res;
        }
        
        
        ProductDetails.OppLineItemListWrapper.ProductDetailsData();
        ProductDetails.OppLineItemListWrapper wrper = new ProductDetails.OppLineItemListWrapper();
        ProductPricingAPI.ProductPricing();
        
    }
    static testMethod void testGet2() {
        
       // ProductDetails classToTest = new ProductDetails();
      Account acc = new Account();{
            acc.Name='Test Account';
            insert acc;}
        
        system.debug('acc---'+acc.Id);
        Contact con = new Contact();{
            con.AccountId=acc.Id;
            con.FirstName='Test';
            con.LastName='Second Name';
            insert con;
        }
        system.debug('con---'+con.Id);
        
        Opportunity op = new Opportunity();{
            op.Name='Test Op';
            op.StageName='Closed Won';
            op.CloseDate=system.Today();
            insert op;
        } system.debug('op---'+op);
        
        OpportunityLineItem TestOpp = new OpportunityLineItem();{
            
            Pricebook2 standardPricebook = new Pricebook2(
                Id = Test.getStandardPricebookId(),
                IsActive = true
            );
            update standardPricebook;
            
            system.debug('standardPricebook'+standardPricebook);
            standardPricebook = [SELECT IsStandard FROM Pricebook2 WHERE Id = :standardPricebook.Id];
            Product2 p = new Product2();{
                p.Opportunity__c=op.Id;
                p.Name='Activity';
                p.IsActive=true;
            }
            insert p;
            system.debug('p---'+p);
            PricebookEntry pbe = new PricebookEntry(UnitPrice=10.0, Product2Id=p.Id, Pricebook2Id=standardPricebook.Id, IsActive=true);
            insert pbe;
            system.debug('pbe----'+pbe);
            
            TestOpp.PricebookEntryId=pbe.Id;
            TestOpp.OpportunityId=op.Id;
            TestOpp.Product2Id=p.Id;
            TestOpp.Quantity=2;
            TestOpp.Retail_Price__c=11.0;
            TestOpp.TotalPrice=TestOpp.Quantity*pbe.UnitPrice;
            insert TestOpp;
            system.debug('after insert TestOpp ---'+TestOpp);
            List <OpportunityLineItem>  OppLineItemList = [SELECT Id,Name,OpportunityId,Opportunity.Name,Product2.Name,Product_Id__c,UnitPrice FROM OpportunityLineItem 
                                                           where id =: TestOpp.Id];
            system.debug('OppLineItemList'+OppLineItemList);
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            req.httpMethod = 'Get';
            req.requestURI= 'https://holidaysystems--partial.my.salesforce.com/services/apexrest/ProductDetails/'+OppLineItemList[0].Product_Id__c+1;
            system.debug('req.requestURI----'+req.requestURI);
            RestContext.request = req;
            RestContext.response= res;
        }
        
        
        ProductDetails.OppLineItemListWrapper.ProductDetailsData();
        ProductDetails.OppLineItemListWrapper wrper = new ProductDetails.OppLineItemListWrapper(); 
        
    }
    
    static testMethod void testGetVoucherVidanta() {
        
        // ProductDetails classToTest = new ProductDetails();
        Account acc = new Account();{
            acc.Name='Test Account';
            insert acc;}
        
        system.debug('acc---'+acc.Id);
        Contact con = new Contact();{
            con.AccountId=acc.Id;
            con.FirstName='Test';
            con.LastName='Second Name';
            insert con;
        }
        system.debug('con---'+con.Id);
        
        Opportunity op = new Opportunity();{
            op.Name='Test Op';
            op.StageName='Closed Won';
            op.CloseDate=system.Today();
            insert op;
        } system.debug('op---'+op);
        
        OpportunityLineItem TestOpp = new OpportunityLineItem();{
            
            Pricebook2 standardPricebook = new Pricebook2(
                Id = Test.getStandardPricebookId(),
                IsActive = true
            );
            update standardPricebook;
            
            system.debug('standardPricebook'+standardPricebook);
            standardPricebook = [SELECT IsStandard FROM Pricebook2 WHERE Id = :standardPricebook.Id];
            Product2 p = new Product2();{
                p.Opportunity__c=op.Id;
                p.Name='Voucher-Vidanta';
                p.IsActive=true;
            }
            insert p;
            system.debug('p---'+p);
            PricebookEntry pbe = new PricebookEntry(UnitPrice=99.0, Product2Id=p.Id, Pricebook2Id=standardPricebook.Id, IsActive=true);
            insert pbe;
            system.debug('pbe----'+pbe);
            
            TestOpp.PricebookEntryId=pbe.Id;
            TestOpp.OpportunityId=op.Id;
            TestOpp.Product2Id=p.Id;
            TestOpp.Quantity=2;
            TestOpp.Retail_Price__c=99.0;
            TestOpp.TotalPrice=TestOpp.Quantity*pbe.UnitPrice;
            insert TestOpp;
            system.debug('after insert TestOpp ---'+TestOpp);
            List <OpportunityLineItem>  OppLineItemList = [SELECT Id,Name,OpportunityId,Opportunity.Name,Product2.Name,Product_Id__c,UnitPrice FROM OpportunityLineItem 
                                                           where id =: TestOpp.Id];
            system.debug('OppLineItemList'+OppLineItemList);
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            req.httpMethod = 'Get';
            req.requestURI= 'https://holidaysystems--partial.my.salesforce.com/services/apexrest/ProductDetails/'+p.Id;
            system.debug('req.requestURI----'+req.requestURI);
            RestContext.request = req;
            RestContext.response= res;
        }
        
        
        ProductDetails.OppLineItemListWrapper.ProductDetailsData();
        ProductDetails.OppLineItemListWrapper wrper = new ProductDetails.OppLineItemListWrapper(); 
        ProductPricingAPI.ProductPricing();
    }
}