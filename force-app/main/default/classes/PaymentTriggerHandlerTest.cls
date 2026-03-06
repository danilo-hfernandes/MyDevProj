@isTest(SeeAllData=True)
public class PaymentTriggerHandlerTest {
    
    static testMethod void DiamondsIntlZeroTest() {
        Account a = new Account();
        a.First_Name__c = 'erhjsdtghfj';
        a.Last_Name__c = 'dfhghgdyh';
        a.Name = 'dfghfdndh';
        a.Email__c = 'hjyarwtyghr@gmail.com';
        a.Member_Number__c = 'rfetgrhtjmdf454';
        a.Preferred_Language__c ='ENG';
        a.Contact_Id__c = 264894467434.0;
        insert a;
        
        Opportunity o = new Opportunity();
        o.AccountId = a.id;
        o.name = 'test opp erhjsdtghfj';
        o.StageName = 'New';
        o.CloseDate = System.today();
        o.Amount = 2;
        o.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Membership_Annual_Dues').getRecordTypeId();
        insert o;

		
        
        Product2 pro2 = [SELECT Id FROM Product2 WHERE Name='Annual Dues-Renewal' LIMIT 1];
        //insert pro2;
        
        Product2 pro3 = [SELECT Id FROM Product2 WHERE Name='Diamonds Intl $250 Add-On' LIMIT 1];
        //insert pro3;
        
        PricebookEntry pbe2 = [SELECT Id FROM PricebookEntry WHERE Product2.Name='Annual Dues-Renewal' LIMIT 1];
        
        PricebookEntry pbe3 =[SELECT Id FROM PricebookEntry WHERE Product2.Name='Diamonds Intl $250 Add-On' LIMIT 1];
        
        OpportunityLineItem OPplineitem2 = new OpportunityLineItem (Quantity=2, OpportunityId=o.Id,UnitPrice=2,PriceBookEntryId=pbe2.Id);
        insert OPplineitem2;
        
        OpportunityLineItem OPplineitem3 = new OpportunityLineItem (Quantity=2, OpportunityId=o.Id,UnitPrice=0,PriceBookEntryId=pbe3.Id);
        insert OPplineitem3;
        
        List<OpportunityLineItem> opLineList = [select product_Id__c from OpportunityLineItem where id =:OPplineitem2.Id]; 
        
        Test.setMock(HttpCalloutMock.class, new MockPaymentAPI());
        
        Test.startTest();
        Payment__c p = new Payment__c();
        p.Name = 'payment';
        p.Opportunity__c = o.id;
        p.Transaction_Type__c = 'Payment';
        p.Payment_Amount__c = 2;        
        p.Paid_On__c = System.today();
        p.Payment_Type__c = 'Payment';
        //p.Product_Id__c=opLineList[0].product_Id__c;
        p.Product_Salesforce_Id__c = pro2.Id;
        p.RecordTypeId = Schema.SObjectType.Payment__c.getRecordTypeInfosByName().get('Membership Annual Dues').getRecordTypeId();
        insert p;  
        Test.stopTest();      
    }
    
    @isTest
        static void testMembershipUpgradeAndHawaiiAPIs() {
            // Use the version of the mock you provided (no-arg constructor, 400 error)
            Test.setMock(HttpCalloutMock.class, new PaymentTriggerMock());
    
            // Setup Data using SeeAllData=True access
            Account acc = [SELECT Id FROM Account WHERE Contact_Id__c != null LIMIT 1];
            Id muRT = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Membership_Add_On').getRecordTypeId();
            
            Opportunity opp = new Opportunity(
                Name = 'MU Coverage Opp', 
                AccountId = acc.Id, 
                StageName = 'Prospecting', 
                CloseDate = System.today(),
                RecordTypeId = muRT
            );
            insert opp;
    
            Payment__c pay = new Payment__c(
                Opportunity__c = opp.Id, 
                Payment_Amount__c = 50, 
                Product_Salesforce_Id__c = '01t3t000006O7LLAA0' // Sample ID to hit string matching logic
            );
            insert pay;
    
            Test.startTest();
            // Covering API blocks and error handling (Lines 1070-1080 and 1244-1280)
            PaymentTriggerHandler.flyBackPaymentCreation(opp.Id, pay.Id);
            PaymentTriggerHandler.hawaiiCollectionApi(new Set<Id>{pay.Id});
            
            // Covering the Catch block by passing malformed JSON
            PaymentTriggerHandler.MembershipUpgradeExitAPI('{"invalid_json":', pay.Id);
            Test.stopTest();
        }
    
        @isTest
        static void testUpdateProductIdMethod() {
            // 1. Tell Salesforce to use the mock for any callouts triggered by this method
            Test.setMock(HttpCalloutMock.class, new PaymentTriggerMock());
        
            // 2. Query existing data (since SeeAllData=True)
            Account acc = [SELECT Id FROM Account LIMIT 1];
            Opportunity opp = new Opportunity(
                Name = 'Product Update Test', 
                AccountId = acc.Id, 
                StageName = 'Prospecting', 
                CloseDate = System.today()
            );
            insert opp;
        
            Payment__c pay = new Payment__c(
                Opportunity__c = opp.Id, 
                Payment_Amount__c = 10,
                Product_Salesforce_Id__c = '01t3t000006O7LLAA0'
            );
            insert pay;
        
            Test.startTest();
            // 3. This method now safely executes callout logic via the Mock
            PaymentTriggerHandler.updateProductId(new Set<String>{opp.Id}, new Set<Id>{pay.Id});
            Test.stopTest();
        }
    }