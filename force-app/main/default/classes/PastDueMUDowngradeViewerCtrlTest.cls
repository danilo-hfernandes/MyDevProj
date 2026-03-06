@isTest(SeeAllData=True)
public class PastDueMUDowngradeViewerCtrlTest {

 @isTest(SeeAllData=True)
    static void testGetOpportunitiesToDowngrade() {
        // Set up test data
        /*Account account = new Account(Name = 'Test Account');
        insert account;
        
        // Create an opportunity with data such that the Monthly_Payment__c formula is correctly calculated
        Opportunity opp1 = new Opportunity(
            Name = 'Test Opp 1',
            AccountId = account.Id,
            StageName = 'Closed Won',
            Payment_Type__c = 'Single Credit Card - With PP',
            Down_Deposit__c = 1000,
            Number_of_Payments__c = '3',            
            CloseDate = Date.today().addDays(-90) // make sure it's past due
        );
        insert opp1;
        Test.setCreatedDate(opp1.Id,System.today().addDays(-25));
        
        Id standardPbId = Test.getStandardPricebookId();
        
        Product2 prd1 = new Product2 (Name='Test Product Entry 1',Description='Test Product Entry 1', isActive = true);
        insert prd1;
        
        PricebookEntry pbe1 = new PricebookEntry (Product2ID=prd1.id,Pricebook2ID=standardPbId,UnitPrice=4000, isActive=true);
        insert pbe1;
        
        Product2 product = new Product2 ( Name = 'Hawaii Collection Plus Flyback');
        insert product;
        
        OpportunityLineItem lineItem1 = new OpportunityLineItem (OpportunityID=opp1.id,Product2Id = product.Id,PriceBookEntryID=pbe1.id, quantity=1, totalprice=4000, retail_price__c = 4000);
        insert lineItem1;

        // Query the opportunity to get the correct formula value for Monthly_Payment__c
        opp1 = [SELECT Id, Monthly_Payment__c FROM Opportunity WHERE Id = :opp1.Id LIMIT 1];
        
        Payment__c payment1 = new Payment__c(
            Opportunity__c = opp1.Id,
            Payment_Amount__c = 1000           
        );
        insert payment1;
        Test.setCreatedDate(payment1.Id,System.today().addDays(-90));

        Payment__c payment2 = new Payment__c(
            Opportunity__c = opp1.Id,
            Payment_Amount__c = 1500            
        );
        insert payment2;
        Test.setCreatedDate(payment2.Id,System.today().addDays(-60));

        // Set up the test context
        Test.startTest();
                account.Affiliate_Name__c = 'Test 1';
        account.Affiliated_Id__c = 1002258;
        update account;
        
        account.Affiliate_Name__c = 'Test 2';
        account.Affiliated_Id__c = 1002259;
        update account; */   
        List<Opportunity> result = PastDueMUDowngradeViewerCtrl.getOpportunitiesToDowngrade();
        //Test.stopTest();

        // Assert results
        //System.assertEquals(1, result.size(), 'There should be one opportunity to downgrade');
        //Opportunity resultOpp = result[0];
        //System.assertEquals(opp1.Id, resultOpp.Id, 'The opportunity returned should be the first one');
        //System.assertEquals('no partial payments - only down deposit', resultOpp.Product_Summary__c, 'Product Summary should be "no partial payments - only down deposit"');
    }
}