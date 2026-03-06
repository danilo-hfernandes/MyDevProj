@IsTest
public class OpportunityLineItemTriggerHandlerTest {
    
    @testSetup static void setup() {
		/*Apex_Trigger_On_Off__c cp = new Apex_Trigger_On_Off__c();
        cp.name = 'OpportunityLineItemTrigger';
        cp.isEnable__c = true;
        insert cp;*/
        
        Profile p = [select id from Profile where name='Tour Generation'];
        
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String guid = h.SubString(0,8); 
        
        UserRole r = new UserRole(DeveloperName = 'TourGen', Name = 'TourGen');
        insert r;
        
        
        User u = new user(alias = 'test123', email='tourgenagent@nerdsoft.com',
                          emailencodingkey='UTF-8', firstName='Test', lastname='Name', languagelocalekey='en_US',
                          localesidkey='en_IN', profileid = p.Id, country='India',
                          timezonesidkey='Asia/Kolkata', username=guid+'tourgenagent@nerdsoft.com.hsi', Assigned_Contacts__c=4, UserRoleId=r.Id);
        
        insert u;
        
        
    }
    
    @isTest
    public static void blockedCommissionUpdatesByTourGenAgentsAfterPayment() {
        Apex_Trigger_On_Off__c cp = new Apex_Trigger_On_Off__c();
        cp.name = 'OpportunityLineItemTrigger';
        cp.isEnable__c = true;
        insert cp;
        Id standardPbId = Test.getStandardPricebookId();
        
        Product2 prd1 = new Product2 (Name='Test Product Entry 1',Description='Test Product Entry 1', isActive = true);
        insert prd1;
        
        PricebookEntry pbe1 = new PricebookEntry (Product2ID=prd1.id,Pricebook2ID=standardPbId,UnitPrice=50, isActive=true);
        insert pbe1;
        
        
        User u = [SELECT Id,UserRole.Name,Profile.Name FROM User WHERE Email = 'tourgenagent@nerdsoft.com' LIMIT 1];
        
        Test.startTest();
        
        System.RunAs(u){
            
            Account acc = new Account(Name = 'Test Account');
            insert acc;
            
            Opportunity opp1 = new Opportunity (Name='Opp1',StageName='Closed Won',CloseDate=Date.today(),Pricebook2Id = pbe1.Pricebook2Id, Upgrade_Type__c = '', AccountId = acc.id, Auto_Created_BU_Opp__c = true);
            insert opp1;
            
            Product2 product = new Product2 ( Name = 'Hawaii Collection Plus Flyback');
            insert product;
            
            OpportunityLineItem lineItem1 = new OpportunityLineItem (OpportunityID=opp1.id,Product2Id = product.Id,PriceBookEntryID=pbe1.id, quantity=4, totalprice=200, retail_price__c = 99);
            insert lineItem1;
            
            lineItem1 = [SELECT Id,product_Id__c FROM OpportunityLineItem WHERE Id =: lineItem1.Id];
            
            Payment__c p = new Payment__c();
            p.Name = 'payment';
            p.Product_Id__c = lineItem1.product_Id__c;
            p.Opportunity__c = opp1.id;
            p.Transaction_Type__c = 'Payment';
            p.Payment_Amount__c = 500;
            p.Credit_Card_Number__c = '23431231234';
            p.Paid_On__c = System.today();
            p.Payment_Type__c = 'USCA';
            p.CC_Processing_Fee__c = 10.0;
            insert p; 
            
            lineItem1.First_Agent_Percentage_Product__c = 0.1;
            
            String errorMsg = '';
            
            try{
                update lineItem1;
            }
            Catch(Exception e)
            {
                errorMsg = e.getMessage();                
            }
            
            System.assertNotEquals('', errorMsg);
            
        }
        
    }
    
    @isTest
    static void allowedCommissionUpdatesByTourGenAgentsAfterPayment() {
        Apex_Trigger_On_Off__c cp = new Apex_Trigger_On_Off__c();
        cp.name = 'OpportunityLineItemTrigger';
        cp.isEnable__c = true;
        insert cp;
        Id standardPbId = Test.getStandardPricebookId();
        
        Product2 prd1 = new Product2 (Name='Hawaii Collection Plus Flyback',Description='Test Product Entry 1', isActive = true);
        insert prd1;
        
        PricebookEntry pbe1 = new PricebookEntry (Product2ID=prd1.id,Pricebook2ID=standardPbId,UnitPrice=50, isActive=true);
        insert pbe1;
        
        Test.startTest();
        
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        
        Opportunity opp1 = new Opportunity (Name='Opp1',StageName='Closed Won',CloseDate=Date.today(),Pricebook2Id = pbe1.Pricebook2Id, Upgrade_Type__c = '', AccountId = acc.id, Auto_Created_BU_Opp__c = true,RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Hawaii_Collection_Membership').getRecordTypeId());
        insert opp1;
        
        OpportunityLineItem lineItem1 = new OpportunityLineItem (OpportunityID=opp1.id,PriceBookEntryID=pbe1.id, quantity=4, totalprice=200, retail_price__c = 99);
        insert lineItem1;
        
        lineItem1.First_Agent_Percentage_Product__c = 0.1;
        
        String errorMsg = '';
        
        try{
            update lineItem1;
        }
        Catch(Exception e)
        {
            errorMsg = e.getMessage();                
        }
        
        System.assertEquals('', errorMsg);
        
        Test.stopTest();
        
    }
    
    @isTest
    static void testBlockGiftProductCreationBasedOnParentQuantitySold() {
        Apex_Trigger_On_Off__c cp = new Apex_Trigger_On_Off__c();
        cp.name = 'OpportunityLineItemTrigger';
        cp.isEnable__c = true;
        insert cp;
        
        Id standardPbId = Test.getStandardPricebookId();
        
        Product2 parentProduct = new Product2 (Name='Group MX Voucher',Description='Group MX Voucher', isActive = true);
        insert parentProduct;
        
        PricebookEntry pbe1 = new PricebookEntry (Product2ID=parentProduct.id,Pricebook2ID=standardPbId,UnitPrice=499, isActive=true);
        insert pbe1;
        
        Product2 giftProduct = new Product2 (Name='Group Recipient MX Voucher',Description='Group Recipient MX Voucher', isActive = true);
        insert giftProduct;
        
        PricebookEntry pbe2 = new PricebookEntry (Product2ID=giftProduct.id,Pricebook2ID=standardPbId,UnitPrice=0, isActive=true);
        insert pbe2;
        
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        
        Opportunity opp = new Opportunity (Name='Opp1',StageName='Closed Won',CloseDate=Date.today(),Pricebook2Id = pbe1.Pricebook2Id,AccountId = acc.id);
        insert opp;
        
        Opportunity opp2 = new Opportunity (Name='Opp2',StageName='New',CloseDate=Date.today(),Pricebook2Id = pbe2.Pricebook2Id,AccountId = acc.id);
        insert opp2;
        
        OpportunityLineItem parentOli = new OpportunityLineItem(
            OpportunityId = opp.Id,
            Product2Id = parentProduct.Id,
            Quantity = 10
        );
        insert parentOli;
        
        //success
        Test.startTest();
        
        OpportunityLineItem giftOli = new OpportunityLineItem(
            OpportunityId = opp2.Id,
            Product2Id = giftProduct.Id,
            Group_MX_Voucher_Product__c = parentOli.Id,
            Quantity = 5
        );
        insert giftOli;
                
        //fail
        
        List<OpportunityLineItem> gifts = new List<OpportunityLineItem>();
        try{
            OpportunityLineItem giftOli2 = new OpportunityLineItem(
                OpportunityId = opp2.Id,
                Product2Id = giftProduct.Id,
                Group_MX_Voucher_Product__c = parentOli.Id,
                Quantity = 4
            );
            gifts.add(giftOli2);
            OpportunityLineItem giftOli3 = new OpportunityLineItem(
                OpportunityId = opp2.Id,
                Product2Id = giftProduct.Id,
                Group_MX_Voucher_Product__c = parentOli.Id,
                Quantity = 2
            );
            gifts.add(giftOli3);
            insert gifts;
        }
        Catch(Exception e)
        {
            //system.debug('e message = '+e.getMessage());
            //Insert failed. First exception on row 0; first error: FIELD_CUSTOM_VALIDATION_EXCEPTION, Gift products (Group MX Recipient Voucher) quantity exceeding the sold parent product (Group MX Voucher) quantity: [Group_MX_Voucher_Product__c]
        }
        
        Test.stopTest();
              
    }
    
    @isTest
    static void limitMUAddOnProductsQuantityTest() {
        Apex_Trigger_On_Off__c cp = new Apex_Trigger_On_Off__c();
        cp.name = 'OpportunityLineItemTrigger';
        cp.isEnable__c = true;
        insert cp;
        Id standardPbId = Test.getStandardPricebookId();
        
        Product2 prd1 = new Product2 (Name='Hawaii Collection Plus Flyback Extension',Description='Test Product Entry 1', isActive = true);
        insert prd1;
        
        PricebookEntry pbe1 = new PricebookEntry (Product2ID=prd1.id,Pricebook2ID=standardPbId,UnitPrice=50, isActive=true);
        insert pbe1;
        
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        
        Opportunity opp1 = new Opportunity (Name='Opp1',StageName='New',CloseDate=Date.today(),Pricebook2Id = pbe1.Pricebook2Id, Upgrade_Type__c = '', AccountId = acc.id, Auto_Created_BU_Opp__c = true,RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Hawaii_Collection_Membership').getRecordTypeId());
        insert opp1;
        
        OpportunityLineItem lineItem1 = new OpportunityLineItem (Price_Book_Entry_Name__c='Hawaii Collection Plus Flyback Extension',OpportunityID=opp1.id,PriceBookEntryID=pbe1.id, quantity=1, totalprice=2000, retail_price__c = 2000);
        OpportunityLineItem lineItem2 = new OpportunityLineItem (Price_Book_Entry_Name__c='Hawaii Collection Plus Flyback Extension',OpportunityID=opp1.id,PriceBookEntryID=pbe1.id, quantity=1, totalprice=2000, retail_price__c = 2000);
        OpportunityLineItem lineItem3 = new OpportunityLineItem (Price_Book_Entry_Name__c='Hawaii Collection Plus Flyback Extension',OpportunityID=opp1.id,PriceBookEntryID=pbe1.id, quantity=2, totalprice=2000, retail_price__c = 2000);
        
        insert lineItem1;
        
        String errorMsg = '';
        
        Test.startTest();
        try{
            insert lineItem2;
        }
        Catch(Exception e)
        {
            errorMsg = ''+ errorMsg + e.getMessage();
        }
        
        try{
            insert lineItem3;
        }
        Catch(Exception e)
        {
            errorMsg = ''+ errorMsg + e.getMessage();
        }
        
        System.debug('limitMUAddOnProductsQuantityTest errorMsg = '+errorMsg);
        
        Test.stopTest();
        
    }

    @isTest
    static void limitExitProductConflictMUTest() {
        Apex_Trigger_On_Off__c cp = new Apex_Trigger_On_Off__c();
        cp.name = 'OpportunityLineItemTrigger';
        cp.isEnable__c = true;
        insert cp;
        Id standardPbId = Test.getStandardPricebookId();
        
        Product2 prd1 = new Product2 (Name='Hawaii Collection Gold-Membership Upgrade',Description='Test Product Entry 1', isActive = true);
        insert prd1;

        Product2 prd2 = new Product2 (Name='Exit Product for MU Team',Description='Test Product Entry 2', isActive = true);
        insert prd2;
        
        PricebookEntry pbe1 = new PricebookEntry (Product2ID=prd1.id,Pricebook2ID=standardPbId,UnitPrice=2995, isActive=true);
        insert pbe1;

        PricebookEntry pbe2 = new PricebookEntry (Product2ID=prd2.id,Pricebook2ID=standardPbId,UnitPrice=399, isActive=true);
        insert pbe2;
        
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        
        Opportunity opp1 = new Opportunity (Name='Opp1',StageName='New',CloseDate=Date.today(),Pricebook2Id = pbe1.Pricebook2Id, Upgrade_Type__c = '', AccountId = acc.id, Auto_Created_BU_Opp__c = true,RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Hawaii_Collection_Membership').getRecordTypeId());
        insert opp1;
        
        OpportunityLineItem lineItem1 = new OpportunityLineItem (Price_Book_Entry_Name__c='Hawaii Collection Gold-Membership Upgrade',OpportunityID=opp1.id,PriceBookEntryID=pbe1.id, quantity=1, totalprice=2995, retail_price__c = 2995);
        
        insert lineItem1;
        
        OpportunityLineItem lineItem2 = new OpportunityLineItem (Price_Book_Entry_Name__c='Exit Product for MU Team',OpportunityID=opp1.id,PriceBookEntryID=pbe2.id, quantity=1, totalprice=399, retail_price__c = 399);
        
        String errorMsg = '';
        
        Test.startTest();
        try{
            insert lineItem2;
        }
        Catch(Exception e)
        {
            errorMsg = ''+ errorMsg + e.getMessage();
        }
        
        System.debug('MUConflict with Exit Product errorMsg = '+errorMsg);
        
        Test.stopTest();
        
    }

    @isTest
    static void cleanFlybackBackgroundFieldsTest() {
        Apex_Trigger_On_Off__c cp = new Apex_Trigger_On_Off__c();
        cp.name = 'OpportunityLineItemTrigger';
        cp.isEnable__c = true;
        insert cp;
        Id standardPbId = Test.getStandardPricebookId();
        
        Product2 prd1 = new Product2 (Name='Vidanta Fly Back',Description='Vidanta Fly Back', isActive = true);
        insert prd1;
        
        PricebookEntry pbe1 = new PricebookEntry (Product2ID=prd1.id,Pricebook2ID=standardPbId,UnitPrice=2995, isActive=true);
        insert pbe1;
        
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        
        Opportunity opp1 = new Opportunity (Name='Opp1',StageName='New',CloseDate=Date.today(),Pricebook2Id = pbe1.Pricebook2Id, Upgrade_Type__c = '', AccountId = acc.id, Auto_Created_BU_Opp__c = true,RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Hawaii_Collection_Membership').getRecordTypeId());
        insert opp1;
        
        OpportunityLineItem lineItem1 = new OpportunityLineItem (Price_Book_Entry_Name__c='Hawaii Collection Gold-Membership Upgrade',OpportunityID=opp1.id,PriceBookEntryID=pbe1.id, quantity=1, totalprice=2995, retail_price__c = 2995);
        
        insert lineItem1;
        
        Test.startTest();
        try{
            delete lineItem1;
        }
        Catch(Exception e)
        {
            System.debug(e.getMessage());
        }        
        
        Test.stopTest();        
    }
    
    
}