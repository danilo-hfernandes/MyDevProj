@istest
public class PaymentTriggerTest { 
    static testMethod void testGet() {
        
        // ProductDetails classToTest = new ProductDetails();
        
        Apex_Trigger_On_Off__c cp1 = new Apex_Trigger_On_Off__c();
        cp1.name = 'PaymentTrigger';
        cp1.isEnable__c = true;
        insert cp1;
        
        Apex_Trigger_On_Off__c cp = new Apex_Trigger_On_Off__c();
        cp.name = 'PaymentTrigger_Before';
        cp.isEnable__c = true;
        insert cp;
        
        String userid = UserInfo.getUserId();
        Test.setMock(HttpCalloutMock.class, new MockPaymentAPI());
        Account a = new Account();
        a.First_Name__c = 'first';
        a.Last_Name__c = 'last';
        a.Name = 'test';
        a.Member_Number__c = 'abc1234ad';
        insert a;
        
        Opportunity o = new Opportunity();
        o.AccountId = a.id;
        o.name = 'test opp';
        o.StageName = 'CallDocuSign';
        o.CloseDate = System.today();
        o.Amount = 500;
        insert o;
        //Create Product
        
        Pricebook2 pb22 = new Pricebook2(Name='Voucher test');
        insert pb22;
        
        Product2 pro2 = new Product2(Name='Vidanta Rebate $200', isActive=true);
        insert pro2;
        
        PricebookEntry pbe2 =new PricebookEntry(unitprice=1,Product2Id=pro2.Id,Pricebook2Id=Test.getStandardPricebookId(),
                                                isActive=true,UseStandardPrice = false);
        insert pbe2;
        OpportunityLineItem OPplineitem2 = new OpportunityLineItem (Quantity=2, OpportunityId=o.Id,UnitPrice=0.01,PriceBookEntryId=pbe2.Id);
        insert OPplineitem2;
    
    
        List<OpportunityLineItem> opLineList = [select product_Id__c from OpportunityLineItem where id =:OPplineitem2.Id]; 
        system.debug('--opLineList--'+opLineList[0].product_Id__c);
        system.debug('--opLineList--'+OPplineitem2.Product_Id__c);
        Payment__c p = new Payment__c();
        p.Name = 'payment';
        p.Product_Id__c = opLineList[0].product_Id__c;
        p.Opportunity__c = o.id;
        p.Transaction_Type__c = 'Payment';
        p.Payment_Amount__c = 500;
        p.Credit_Card_Number__c = '23431231234';
        p.Paid_On__c = System.today();
        p.Payment_Type__c = 'USCA';
        p.CC_Processing_Fee__c = 10.0;
        insert p; 
    }
    static testMethod void hawaiicollectionTrigger() {
        
        // ProductDetails classToTest = new ProductDetails();
        Apex_Trigger_On_Off__c cp2 = new Apex_Trigger_On_Off__c();
        cp2.name = 'PaymentTrigger';
        cp2.isEnable__c = true;
        insert cp2;
        
        Apex_Trigger_On_Off__c cp = new Apex_Trigger_On_Off__c();
        cp.name = 'PaymentTrigger_Before';
        cp.isEnable__c = true;
        insert cp;
        
        Apex_Trigger_On_Off__c cp1 = new Apex_Trigger_On_Off__c();
        cp1.name = 'hawaiiCollectionAPI';
        cp1.isEnable__c = true;
        insert cp1;
        
        
        String userid = UserInfo.getUserId();
        Test.setMock(HttpCalloutMock.class, new MockPaymentAPI());
        Account a = new Account();
        a.First_Name__c = 'first';
        a.Last_Name__c = 'last';
        a.Name = 'test';
        a.Member_Number__c = 'abc1234ad';
        insert a;
        Id hawaiiCollectionRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Hawaii_Collection_Membership').getRecordTypeId();

        Opportunity o = new Opportunity();
        o.AccountId = a.id;
        o.name = 'test opp';
        o.StageName = 'CallDocuSign';
        o.CloseDate = System.today();
        o.Amount = 500;
        o.RecordTypeId = hawaiiCollectionRecordTypeId;
        insert o;
        //Create Product
        
        Pricebook2 pb22 = new Pricebook2(Name='Voucher test');
        insert pb22;
        
        Product2 pro2 = new Product2(Name='BXCDXXX', isActive=true);
        insert pro2;
        
        PricebookEntry pbe2 =new PricebookEntry(unitprice=1,Product2Id=pro2.Id,Pricebook2Id=Test.getStandardPricebookId(),
                                                isActive=true,UseStandardPrice = false);
        insert pbe2;
        OpportunityLineItem OPplineitem2 = new OpportunityLineItem (Quantity=2, OpportunityId=o.Id,UnitPrice=0.01,PriceBookEntryId=pbe2.Id);
        insert OPplineitem2;
    
    
        List<OpportunityLineItem> opLineList = [select product_Id__c from OpportunityLineItem where id =:OPplineitem2.Id]; 
        system.debug('--opLineList--'+opLineList[0].product_Id__c);
        system.debug('--opLineList--'+OPplineitem2.Product_Id__c);
        Payment__c p = new Payment__c();
        p.Name = 'payment';
        p.Product_Id__c = opLineList[0].product_Id__c;
        p.Opportunity__c = o.id;
        p.Transaction_Type__c = 'Payment';
        p.Payment_Amount__c = 500;
        p.Credit_Card_Number__c = '23431231234';
        p.Paid_On__c = System.today();
        p.Payment_Type__c = 'USCA';
        p.CC_Processing_Fee__c = 10.0;
        insert p; 
    }
    
    static testMethod void deletePayment() {
        
        // ProductDetails classToTest = new ProductDetails();
        Apex_Trigger_On_Off__c cp1 = new Apex_Trigger_On_Off__c();
        cp1.name = 'PaymentTrigger';
        cp1.isEnable__c = true;
        insert cp1;
        
        Apex_Trigger_On_Off__c cp = new Apex_Trigger_On_Off__c();
        cp.name = 'PaymentTrigger_Before';
        cp.isEnable__c = true;
        insert cp;
        
        String userid = UserInfo.getUserId();
        Test.setMock(HttpCalloutMock.class, new MockPaymentAPI());
        Account a = new Account();
        a.First_Name__c = 'first';
        a.Last_Name__c = 'last';
        a.Name = 'test';
        a.Member_Number__c = 'abc1234ad';
        insert a;
        
        Opportunity o = new Opportunity();
        o.AccountId = a.id;
        o.name = 'test opp';
        o.StageName = 'CallDocuSign';
        o.CloseDate = System.today();
        o.Amount = 500;
        o.Inventory_Source__c = 'VIN Fullfillment';
        insert o;
        //Create Product
        
        Pricebook2 pb22 = new Pricebook2(Name='Voucher test');
        insert pb22;
        
        Product2 pro2 = new Product2(Name='Vidanta Rebate $200', isActive=true);
        insert pro2;
        
        PricebookEntry pbe2 =new PricebookEntry(unitprice=1,Product2Id=pro2.Id,Pricebook2Id=Test.getStandardPricebookId(),
                                                isActive=true,UseStandardPrice = false);
        insert pbe2;
        OpportunityLineItem OPplineitem2 = new OpportunityLineItem (Quantity=2, OpportunityId=o.Id,UnitPrice=0.01,PriceBookEntryId=pbe2.Id);
        insert OPplineitem2;
    
    
        List<OpportunityLineItem> opLineList = [select product_Id__c from OpportunityLineItem where id =:OPplineitem2.Id]; 
        system.debug('--opLineList--'+opLineList[0].product_Id__c);
        system.debug('--opLineList--'+OPplineitem2.Product_Id__c);
        Payment__c p = new Payment__c();
        p.Name = 'payment';
        p.Product_Id__c = opLineList[0].product_Id__c;
        p.Opportunity__c = o.id;
        p.Transaction_Type__c = 'Payment';
        p.Payment_Amount__c = 500;
        p.Credit_Card_Number__c = '23431231234';
        p.Paid_On__c = System.today();
        p.Payment_Type__c = 'USCA';
        p.CC_Processing_Fee__c = 10.0;
        insert p; 
        delete p;
    }
}