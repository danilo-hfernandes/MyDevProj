@isTest
public class PaymentTriggerConsolidatedTest {

    @testSetup 
    static void setupData() {
        // 1. Setup All Trigger Control Flags
        List<Apex_Trigger_On_Off__c> settings = new List<Apex_Trigger_On_Off__c>{
            new Apex_Trigger_On_Off__c(Name = 'PaymentTrigger', isEnable__c = true),
            new Apex_Trigger_On_Off__c(Name = 'PaymentTrigger_Before', isEnable__c = true),
            new Apex_Trigger_On_Off__c(Name = 'PaymentTrigger_New', isEnable__c = true),
            new Apex_Trigger_On_Off__c(Name = 'hawaiiCollectionAPI', isEnable__c = true)
        };
        insert settings;

        // 2. Base Account & Contact
        Account acc = new Account(
            Name = 'Central Test Account',
            First_Name__c = 'Test',
            Last_Name__c = 'User',
            Email__c = 'test@example.com',
            Member_Number__c = 'MEM12345',
            Preferred_Language__c = 'ENG',
            Contact_Id__c = 12345,
            Hawaii_Collection_Affiliate_Id__c = 12345,
            Affiliated_Id__c = 1002275 // Required for SFX Reinstatement-Diamond Validation
        );
        insert acc;

        Contact con = new Contact(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'test@example.com',
            AccountId = acc.Id
        );
        insert con;

        // 3. Products required for different branch logic
        List<Product2> products = new List<Product2>{
            new Product2(Name = 'Annual Dues-Renewal', IsActive = true),
            new Product2(Name = 'Hawaii Collection Plus', IsActive = true),
            new Product2(Name = 'SFX Reinstatement-Diamond', IsActive = true),
            new Product2(Name = 'BXCDXXX', IsActive = true),
            new Product2(Name = 'Vacation VIP Membership Upgrade', IsActive = true),
            new Product2(Name = 'Diamonds Intl $250 Add-On', IsActive = true)
        };
        insert products;

        // 4. Pricebook Entries
        Id stdPbId = Test.getStandardPricebookId();
        List<PricebookEntry> pbes = new List<PricebookEntry>();
        for(Product2 p : products) {
            pbes.add(new PricebookEntry(Pricebook2Id = stdPbId, Product2Id = p.Id, UnitPrice = 100, IsActive = true));
        }
        insert pbes;
    }

    @isTest
    static void testAnnualDuesAndVoucherFlow() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Opportunity opp = createOpp(acc.Id, 'Membership_Annual_Dues');
        
        PricebookEntry pbe = [SELECT Id, Product2Id FROM PricebookEntry WHERE Product2.Name = 'Annual Dues-Renewal' LIMIT 1];
        insert new OpportunityLineItem(OpportunityId = opp.Id, PricebookEntryId = pbe.Id, Quantity = 1, UnitPrice = 100);

        Test.setMock(HttpCalloutMock.class, new MockPaymentAPI());
        
        Test.startTest();
        Payment__c p = new Payment__c(
            Name = 'Dues Payment',
            Opportunity__c = opp.Id,
            Payment_Amount__c = 100,
            Transaction_Type__c = 'Payment',
            Paid_On__c = System.today(),
            Payment_Type__c = 'USCA',
            Product_Salesforce_Id__c = pbe.Product2Id,
            RecordTypeId = Schema.SObjectType.Payment__c.getRecordTypeInfosByName().get('Membership Annual Dues').getRecordTypeId()
        );
        insert p;

        checkRecursive.paymentTrigger = true;
        p.Payment_Amount__c = 150;
        update p;
        Test.stopTest();

        System.assertNotEquals(null, p.Id);
    }

    @isTest
    static void testHawaiiCollectionFlow() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Opportunity opp = createOpp(acc.Id, 'Hawaii_Collection_Membership');
        opp.Dues_Last_Paid_Until__c = System.today();
        update opp;
        
        // Added Product2Id to query to fix SObjectException
        PricebookEntry pbe = [SELECT Id, Product2Id FROM PricebookEntry WHERE Product2.Name = 'BXCDXXX' LIMIT 1];
        insert new OpportunityLineItem(OpportunityId = opp.Id, PricebookEntryId = pbe.Id, Quantity = 1, UnitPrice = 50);

        Test.setMock(HttpCalloutMock.class, new MockPaymentAPI());

        Test.startTest();
        Payment__c p = new Payment__c(
            Opportunity__c = opp.Id,
            Payment_Amount__c = 50,
            Transaction_Type__c = 'Payment',
            Paid_On__c = System.today(),
            Product_Salesforce_Id__c = pbe.Product2Id
        );
        insert p;
        Test.stopTest();
    }

    @isTest
    static void testSFXAndVIPFlow() {
        // Validation Fix: Using an account with Affiliated_Id__c = 1002275
        Account acc = [SELECT Id FROM Account WHERE Affiliated_Id__c = 1002275 LIMIT 1];
        Opportunity opp = createOpp(acc.Id, 'SFX_Membership');
        
        PricebookEntry pbe = [SELECT Id, Product2Id FROM PricebookEntry WHERE Product2.Name = 'SFX Reinstatement-Diamond' LIMIT 1];
        insert new OpportunityLineItem(OpportunityId = opp.Id, PricebookEntryId = pbe.Id, Quantity = 1, UnitPrice = 50);

        Test.setMock(HttpCalloutMock.class, new MockPaymentAPI());

        Test.startTest();
        Payment__c p = new Payment__c(
            Opportunity__c = opp.Id,
            Payment_Amount__c = 50,
            Transaction_Type__c = 'Payment',
            Paid_On__c = System.today(),
            Product_Salesforce_Id__c = pbe.Product2Id
        );
        insert p;
        Test.stopTest();
    }

    @isTest
    static void testDeleteFlow() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Opportunity opp = createOpp(acc.Id, 'Membership_Annual_Dues');
        opp.Inventory_Source__c = 'VIN Fullfillment';
        update opp;

        Payment__c p = new Payment__c(Opportunity__c = opp.Id, Payment_Amount__c = 10, Paid_On__c = System.today());
        insert p;

        Test.setMock(HttpCalloutMock.class, new MockPaymentAPI());
        
        Test.startTest();
        delete p;
        Test.stopTest();
        
        System.assertEquals(0, [SELECT count() FROM Payment__c WHERE Id = :p.Id]);
    }

    private static Opportunity createOpp(Id accId, String recordTypeDevName) {
        Id rtId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(recordTypeDevName).getRecordTypeId();
        Opportunity opp = new Opportunity(
            Name = 'Test Opp ' + recordTypeDevName,
            AccountId = accId,
            StageName = 'CallDocuSign',
            CloseDate = System.today(),
            RecordTypeId = rtId
        );
        insert opp;
        return opp;
    }
}