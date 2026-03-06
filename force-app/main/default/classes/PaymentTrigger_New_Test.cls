@istest
public class PaymentTrigger_New_Test {
    @testSetup static void methodName() {
        Apex_Trigger_On_Off__c cp = new Apex_Trigger_On_Off__c();
        cp.name = 'PaymentTrigger_New';
        cp.isEnable__c = true;
        insert cp; 
        
        Apex_Trigger_On_Off__c cp1 = new Apex_Trigger_On_Off__c();
        cp1.name = 'hawaiiCollectionAPI';
        cp1.isEnable__c = true;
        insert cp1;
        
        
    }
    static testMethod void annualDuePaymentAPItest() {
        Account a = new Account();
        a.First_Name__c = 'first';
        a.Last_Name__c = 'last';
        a.Name = 'test';
        a.Email__c = 'test@gmail.com';
        a.Member_Number__c = 'abc1234ad';
        a.Preferred_Language__c ='ENG';
        insert a;
        
        Contact objcon = new Contact();
        objcon.Email = 'test@gmail.com';
        objcon.LastName = 'test';
        objcon.AccountId = a.Id;
        //objcon.Is_Main_Contact__c = true;
        insert objcon;
        
        Opportunity o = new Opportunity();
        o.AccountId = a.id;
        o.name = 'test opp';
        o.StageName = 'CallDocuSign';
        o.CloseDate = System.today();
        o.Amount = 500;
        o.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Membership_Add_On').getRecordTypeId();
        insert o;
        
        Pricebook2 pb22 = new Pricebook2(Name='Voucher test');
        insert pb22;
        
        Product2 pro2 = new Product2(Name='Annual Dues-Renewal', isActive=true);
        insert pro2;
        
       	Product2 pro3 = new Product2(Name='Hawaii Collection Plus', isActive=true);
        insert pro3;
        
        Product2 pro4 = new Product2(Name='Exit Product for MU Team', isActive=true);
        insert pro4;
        
        PricebookEntry pbe2 =new PricebookEntry(unitprice=1,Product2Id=pro2.Id,Pricebook2Id=Test.getStandardPricebookId(),
                                                isActive=true,UseStandardPrice = false);
        insert pbe2;
        
        PricebookEntry pbe3 =new PricebookEntry(unitprice=1,Product2Id=pro3.Id,Pricebook2Id=Test.getStandardPricebookId(),
                                                isActive=true,UseStandardPrice = false);
        insert pbe3;
        
        PricebookEntry pbe4 =new PricebookEntry(unitprice=1,Product2Id=pro4.Id,Pricebook2Id=Test.getStandardPricebookId(),
                                                isActive=true,UseStandardPrice = false);
        insert pbe4;
        
        OpportunityLineItem OPplineitem2 = new OpportunityLineItem (Quantity=2, OpportunityId=o.Id,UnitPrice=0.01,PriceBookEntryId=pbe2.Id);
        insert OPplineitem2;
        
        OpportunityLineItem OPplineitem3 = new OpportunityLineItem (Quantity=2, OpportunityId=o.Id,UnitPrice=0.01,PriceBookEntryId=pbe3.Id);
        insert OPplineitem3;
        
        OpportunityLineItem OPplineitem4 = new OpportunityLineItem (Quantity=1, OpportunityId=o.Id,UnitPrice=0.01,PriceBookEntryId=pbe4.Id);
        insert OPplineitem4;
        
        List<OpportunityLineItem> opLineList = [select product_Id__c from OpportunityLineItem where id =:OPplineitem2.Id]; 
        
        
        Test.setMock(HttpCalloutMock.class, new MockPaymentAPI());
        
        Payment__c p = new Payment__c();
        p.Name = 'payment';
        p.Opportunity__c = o.id;
        p.Transaction_Type__c = 'Payment';
        p.Payment_Amount__c = 500;
        p.Credit_Card_Number__c = '6011832825897994';
        p.Paid_On__c = System.today();
        p.Payment_Type__c = 'USCA';
        p.CC_Processing_Fee__c = 10.0;
        p.Product_Id__c='PI-0131349';
        p.RecordTypeId = Schema.SObjectType.Payment__c.getRecordTypeInfosByName().get('Membership Annual Dues').getRecordTypeId();
        insert p;
        
        a.Parent_Child_Contact_Id__c = objcon.Id;
        update a;
        Set<Id> oppIds = new Set<Id>();
        oppIds.add(o.Id);
        PaymentTriggerHandler.sendProfitAgilityAgencyMXVoucherContactsToSRRAndCadence(oppIds);
        
    }
    
     static testMethod void annualDuePaymentAPItest1() {
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
        o.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Membership_Add_On').getRecordTypeId();
        insert o;
        
        Pricebook2 pb22 = new Pricebook2(Name='Voucher test');
        insert pb22;
        
        Product2 pro2 = new Product2(Name='Annual Dues-Renewal', isActive=true);
        insert pro2;
        
       	Product2 pro3 = new Product2(Name='Hawaii Collection Plus', isActive=true);
        insert pro3;
        
        PricebookEntry pbe2 =new PricebookEntry(unitprice=1,Product2Id=pro2.Id,Pricebook2Id=Test.getStandardPricebookId(),
                                                isActive=true,UseStandardPrice = false);
        insert pbe2;
        
        PricebookEntry pbe3 =new PricebookEntry(unitprice=1,Product2Id=pro3.Id,Pricebook2Id=Test.getStandardPricebookId(),
                                                isActive=true,UseStandardPrice = false);
        insert pbe3;
        
        OpportunityLineItem OPplineitem2 = new OpportunityLineItem (Quantity=2, OpportunityId=o.Id,TotalPrice=0,PriceBookEntryId=pbe2.Id);
        insert OPplineitem2;
        
        OpportunityLineItem OPplineitem3 = new OpportunityLineItem (Quantity=2, OpportunityId=o.Id,TotalPrice=0,PriceBookEntryId=pbe3.Id);
        insert OPplineitem3;
        
        List<OpportunityLineItem> opLineList = [select product_Id__c from OpportunityLineItem where id =:OPplineitem2.Id]; 
        
        
        Test.setMock(HttpCalloutMock.class, new MockPaymentAPI());
        
        Payment__c p = new Payment__c();
        p.Name = 'payment';
        p.Opportunity__c = o.id;
        p.Transaction_Type__c = 'Payment';
        p.Payment_Amount__c = 500;
        p.Credit_Card_Number__c = '6011832825897994';
        p.Paid_On__c = System.today();
        p.Payment_Type__c = 'USCA';
        p.CC_Processing_Fee__c = 10.0;
        p.Product_Id__c='PI-0131349';
        p.RecordTypeId = Schema.SObjectType.Payment__c.getRecordTypeInfosByName().get('Membership Annual Dues').getRecordTypeId();
        insert p;
        
        
    }
    
    static testMethod void SFXGoldMembersAPItest() {
        
        Id sfxRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('SFX_Membership').getRecordTypeId();
        
        Id standardPbId = Test.getStandardPricebookId();
        
        Product2 prd1 = new Product2 (Name='SFX Reinstatement-Diamond',Description='SFX Reinstatement-Diamond', isActive = true);
        insert prd1;
        
        PricebookEntry pbe1 = new PricebookEntry (Product2ID=prd1.id,Pricebook2ID=standardPbId,UnitPrice=50, isActive=true);
        insert pbe1;
        
        Account a = new Account();
        a.First_Name__c = 'first';
        a.Last_Name__c = 'last';
        a.Name = 'test';
        a.Member_Number__c = 'abc1234ad';
        a.Affiliated_Id__c = 1002275;
        insert a;
        
        Opportunity o = new Opportunity();
        o.AccountId = a.id;
        o.name = 'test opp';
        o.StageName = 'CallDocuSign';
        o.CloseDate = System.today();
        o.Amount = 500;
        o.Pricebook2Id = pbe1.Pricebook2Id;
        o.RecordTypeId = sfxRecordTypeId;
        insert o;
        
        system.assert(o.Id != null);        

        OpportunityLineItem OPplineitem2 = new OpportunityLineItem (Quantity=2, OpportunityId=o.Id,UnitPrice=0.01,PriceBookEntryId=pbe1.Id,Product2Id = prd1.Id);
        insert OPplineitem2;
                
        List<OpportunityLineItem> opLineList = [select product_Id__c,Product2.Name,OpportunityId from OpportunityLineItem where id =:OPplineitem2.Id]; 
        system.debug('opLineList from test class= '+opLineList);
        
        
        Test.setMock(HttpCalloutMock.class, new MockPaymentAPI());
        
        test.startTest();
        Payment__c p = new Payment__c();
        p.Name = 'payment';
        p.Opportunity__c = o.id;
        p.Transaction_Type__c = 'Payment';
        p.Payment_Amount__c = 500;
        p.Credit_Card_Number__c = '6011832825897994';
        p.Paid_On__c = System.today();
        p.Payment_Type__c = 'USCA';
        //p.Product_Id__c = 'PI-0132337';
        p.CC_Processing_Fee__c = 10.0;
        p.Product_Id__c = opLineList[0].product_Id__c;
        p.RecordTypeId = Schema.SObjectType.Payment__c.getRecordTypeInfosByName().get('Membership Annual Dues').getRecordTypeId();
        insert p;
        test.stopTest();
    }
    static testMethod void VIPVoucherMembersAPItest() {
        Account a = new Account();
        a.First_Name__c = 'first';
        a.Last_Name__c = 'last';
        a.Name = 'test';
        a.Member_Number__c = 'abc1234ad';
        a.Affiliated_Id__c = 1002336;
        insert a;
        
        Opportunity o = new Opportunity();
        o.AccountId = a.id;
        o.name = 'test opp';
        o.StageName = 'CallDocuSign';
        o.CloseDate = System.today();
        o.Amount = 500;
        o.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Vacation_VIP_Membership_Upgrade').getRecordTypeId();
        insert o;
        
        system.assert(o.Id != null);
        
        Pricebook2 pb22 = new Pricebook2(Name='Voucher test');
        insert pb22;
        
        Product2 pro2 = new Product2(Name='Vacation VIP Membership Upgrade', isActive=true);
        insert pro2;
        
        PricebookEntry pbe2 =new PricebookEntry(unitprice=1,Product2Id=pro2.Id,Pricebook2Id=Test.getStandardPricebookId(),
                                                isActive=true,UseStandardPrice = false);
        insert pbe2;
        OpportunityLineItem OPplineitem2 = new OpportunityLineItem (Quantity=2, OpportunityId=o.Id,UnitPrice=399.0,PriceBookEntryId=pbe2.Id);
        insert OPplineitem2;
        
        
        List<OpportunityLineItem> opLineList = [select product_Id__c from OpportunityLineItem where id =:OPplineitem2.Id]; 
        
        
        Test.setMock(HttpCalloutMock.class, new MockPaymentAPI());
        
        test.startTest();
        Payment__c p = new Payment__c();
        p.Name = 'payment';
        p.Opportunity__c = o.id;
        p.Transaction_Type__c = 'Payment';
        p.Payment_Amount__c = 500;
        p.Credit_Card_Number__c = '6011832825897994';
        p.Paid_On__c = System.today();
        p.Payment_Type__c = 'USCA';
        //p.Product_Id__c = 'PI-0132337';
        p.CC_Processing_Fee__c = 10.0;
        p.Product_Id__c = opLineList[0].product_Id__c;
        p.RecordTypeId = Schema.SObjectType.Payment__c.getRecordTypeInfosByName().get('Membership Annual Dues').getRecordTypeId();
        insert p;
        test.stopTest();
    }
     static testMethod void annualDueWaiverPaymentAPItest() {
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
        o.SFX_Diamond_Member_Enrolled__c = false;
        insert o;
        
        Pricebook2 pb22 = new Pricebook2(Name='Voucher test');
        insert pb22;
        
        Product2 pro2 = new Product2(Name='Annual Dues Voucher Bundle', isActive=true);
        insert pro2;
        
        PricebookEntry pbe2 =new PricebookEntry(unitprice=1,Product2Id=pro2.Id,Pricebook2Id=Test.getStandardPricebookId(),
                                                isActive=true,UseStandardPrice = false);
        insert pbe2;
        OpportunityLineItem OPplineitem2 = new OpportunityLineItem (Quantity=2, OpportunityId=o.Id,UnitPrice=0.01,PriceBookEntryId=pbe2.Id);
        insert OPplineitem2;
        
        
        List<OpportunityLineItem> opLineList = [select product_Id__c from OpportunityLineItem where id =:OPplineitem2.Id]; 
        
        
        Test.setMock(HttpCalloutMock.class, new MockPaymentAPI());
        
        Payment__c p = new Payment__c();
        p.Name = 'payment';
        p.Opportunity__c = o.id;
        p.Transaction_Type__c = 'Payment';
        p.Payment_Amount__c = 500;
        p.Credit_Card_Number__c = '6011832825897994';
        p.Paid_On__c = System.today();
        p.Payment_Type__c = 'USCA';
        p.CC_Processing_Fee__c = 10.0;
        p.Product_Id__c = opLineList[0].Product_Id__c;
        p.RecordTypeId = Schema.SObjectType.Payment__c.getRecordTypeInfosByName().get('Membership Annual Dues').getRecordTypeId();
        insert p;
    }
    static testMethod void testGet() {
        
        // ProductDetails classToTest = new ProductDetails();
        
        Apex_Trigger_On_Off__c cp = new Apex_Trigger_On_Off__c();
        cp.name = 'PaymentTrigger_New';
        cp.isEnable__c = true;
        insert cp;
        
        
        String userid = UserInfo.getUserId();
        Test.setMock(HttpCalloutMock.class, new MockPaymentAPI());
        Account a = new Account();
        a.First_Name__c = 'first';
        a.Last_Name__c = 'last';
        a.Email__c = 'test@gmail.com';
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
        //Create Products
        
		Certificate__c crs = new Certificate__c();
        crs.Certificate_ID__c = '222dre23';
        crs.Coupon_Type__c = 'Cancun Card Add On SPA';
        insert crs;
	    
        Id standardPbId = Test.getStandardPricebookId();
        
        Product2 prd1 = new Product2 (Name='Cancun Cards Add-On SPA',Description='Test Product Entry 1', isActive = true);
        insert prd1;
        
        PricebookEntry pbe1 = new PricebookEntry (Product2ID=prd1.id,Pricebook2ID=standardPbId,UnitPrice=50, isActive=true);
        insert pbe1;
        
        OpportunityLineItem lineItem1 = new OpportunityLineItem (OpportunityID=o.id,PriceBookEntryID=pbe1.id, quantity=4, totalprice=200, retail_price__c = 99);
        insert lineItem1;
        
        Pricebook2 pb22 = new Pricebook2(Name='Voucher test');
        insert pb22;
        
        Product2 pro2 = new Product2(Name='Vidanta Rebate $200', isActive=true);
        insert pro2;
        
        PricebookEntry pbe2 =new PricebookEntry(unitprice=0,Product2Id=pro2.Id,Pricebook2Id=Test.getStandardPricebookId(),
                                                isActive=true,UseStandardPrice = false);
        insert pbe2;
        
        OpportunityLineItem OPplineitem2 = new OpportunityLineItem (Quantity=2, OpportunityId=o.Id,UnitPrice=0,PriceBookEntryId=pbe2.Id);
        
        insert OPplineitem2;
        

        
        
        List<OpportunityLineItem> opLineList = [select product_Id__c from OpportunityLineItem where id =:lineItem1.Id]; 
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
        
        Test.startTest();
        checkRecursive.paymentTrigger = true;
        p.Credit_Card_Number__c = '234312312342';
        update p;
        
        Test.stopTest();   
        
    }
    static testMethod void hawaiicollectionTrigger() {
        
        // ProductDetails classToTest = new ProductDetails();
        
        Apex_Trigger_On_Off__c cp = new Apex_Trigger_On_Off__c();
        cp.name = 'PaymentTrigger_New';
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
        a.Contact_Id__c = 12345;
        a.Hawaii_Collection_Affiliate_Id__c = 12345;
        insert a;
        Id hawaiiCollectionRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Hawaii_Collection_Membership').getRecordTypeId();
        
        Contact objcon = new Contact();
        objcon.FirstName = 'Testing';
        objcon.LastName = 'Testing';
        objcon.Email = 'test@gmail.com';
        objcon.AccountId = a.Id;
        insert objcon;
        
        Opportunity o = new Opportunity();
        o.AccountId = a.id;
        o.name = 'test opp';
        o.StageName = 'CallDocuSign';
        o.CloseDate = System.today();
        o.Amount = 500;
        o.ContactId = objcon.Id;
        o.Enrollment_Fee__c= 52;
        o.Annual_Dues__c =23;
        o.Member_Number__c = 'abc1234ad';
        o.Dues_Last_Paid_Until__c = System.today();
        o.Credit_Received__c = 20;
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
        OpportunityLineItem OPplineitem2 = new OpportunityLineItem (Quantity=2, OpportunityId=o.Id,UnitPrice=0.01,PriceBookEntryId=pbe2.Id, Product2Id= pro2.Id);
        insert OPplineitem2;
        
        
        List<OpportunityLineItem> opLineList = [select product_Id__c, Product2Id from OpportunityLineItem where id =:OPplineitem2.Id]; 
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
        p.Product_Salesforce_Id__c =  opLineList[0].Product2Id;
        insert p;
    }
    
    static testMethod void deletePayment() {
        
        // ProductDetails classToTest = new ProductDetails();
        
        Apex_Trigger_On_Off__c cp = new Apex_Trigger_On_Off__c();
        cp.name = 'PaymentTrigger_New';
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
        
        Product2 pro2 = new Product2(Name='Annual Dues-Renewal', isActive=true);
        insert pro2;
        
        PricebookEntry pbe2 =new PricebookEntry(unitprice=1,Product2Id=pro2.Id,Pricebook2Id=Test.getStandardPricebookId(),
                                                isActive=true,UseStandardPrice = false);
        insert pbe2;
        OpportunityLineItem OPplineitem2 = new OpportunityLineItem (Quantity=2, OpportunityId=o.Id,UnitPrice=0.01,PriceBookEntryId=pbe2.Id);
        insert OPplineitem2;
        
        Test.setMock(HttpCalloutMock.class, new MockPaymentAPI());
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
        Test.setMock(HttpCalloutMock.class, new MockPaymentAPI());
        delete p;
    }
    
    static testMethod void membershipReinstatementVoucherPaymentAPITest() {
        Account a = new Account();
        a.First_Name__c = 'first';
        a.Last_Name__c = 'last';
        a.Name = 'test';
        a.Member_Number__c = 'abc1234ad';
        insert a;
        
        Opportunity o = new Opportunity();
        o.AccountId = a.id;
        o.name = 'test opp';
        o.StageName = 'New';
        o.CloseDate = System.today();
        o.Amount = 500;
        o.SFX_Diamond_Member_Enrolled__c = false;
        insert o;
        
        Pricebook2 pb22 = new Pricebook2(Name='Voucher test');
        insert pb22;
        
        Product2 pro2 = new Product2(Name='Membership Reinstatement-Voucher Bundle', isActive=true);
        insert pro2;
        
        PricebookEntry pbe2 =new PricebookEntry(unitprice=1,Product2Id=pro2.Id,Pricebook2Id=Test.getStandardPricebookId(),
                                                isActive=true,UseStandardPrice = false);
        insert pbe2;
        OpportunityLineItem OPplineitem2 = new OpportunityLineItem (Quantity=2, OpportunityId=o.Id,UnitPrice=499,PriceBookEntryId=pbe2.Id);
        insert OPplineitem2;
        
        List<OpportunityLineItem> opLineList = [select product_Id__c from OpportunityLineItem where id =:OPplineitem2.Id]; 
        
        Test.setMock(HttpCalloutMock.class, new MockPaymentAPI());
        
        Payment__c p = new Payment__c();
        p.Name = 'payment';
        p.Opportunity__c = o.id;
        p.Transaction_Type__c = 'Payment';
        p.Payment_Amount__c = 499;
        p.Credit_Card_Number__c = '6011832825897994';
        p.Paid_On__c = System.today();
        p.Payment_Type__c = 'USCA';
        p.CC_Processing_Fee__c = 10.0;
        p.Product_Id__c = opLineList[0].Product_Id__c;
        p.RecordTypeId = Schema.SObjectType.Payment__c.getRecordTypeInfosByName().get('Voucher').getRecordTypeId();
        insert p;
    }
    
    static testMethod void CFDMembersiteAPITest() {

        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String guid = h.SubString(0,8);

        Account a = new Account();
        a.Affiliated_Id__c = 1002256;
        a.First_Name__c = 'first';
        a.Last_Name__c = 'last';
        a.Name = 'test';
        a.Member_Number__c = 'abc1234ad';
		a.Master_Record_Id__c = guid;
        insert a;
        
        Opportunity o = new Opportunity();
        o.AccountId = a.id;
        o.name = 'test opp';
        o.StageName = 'New';
        o.CloseDate = System.today();
        o.Amount = 500;
        o.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Travel').getRecordTypeId();
        insert o;
        
        Pricebook2 pb22 = new Pricebook2(Name='Hotel');
        insert pb22;
        
        Product2 pro2 = new Product2(Name='Hotel', isActive=true);
        insert pro2;
        
        PricebookEntry pbe2 =new PricebookEntry(unitprice=1,Product2Id=pro2.Id,Pricebook2Id=Test.getStandardPricebookId(),
                                                isActive=true,UseStandardPrice = false);
        insert pbe2;
        
        OpportunityLineItem OPplineitem2 = new OpportunityLineItem (Quantity=2, OpportunityId=o.Id,UnitPrice=1,PriceBookEntryId=pbe2.Id);
        insert OPplineitem2;
        
        List<OpportunityLineItem> opLineList = [select product_Id__c from OpportunityLineItem where id =:OPplineitem2.Id]; 
        
        Test.setMock(HttpCalloutMock.class, new MockPaymentAPI());
        
        Payment__c p = new Payment__c();
        p.Name = 'payment';
        p.Opportunity__c = o.id;
        p.Transaction_Type__c = 'Payment';
        p.Payment_Amount__c = 1;
        p.Credit_Card_Number__c = '6011832825897994';
        p.Paid_On__c = System.today();        
        p.Product_Id__c = opLineList[0].Product_Id__c;
        p.RecordTypeId = Schema.SObjectType.Payment__c.getRecordTypeInfosByName().get('Travel').getRecordTypeId();
        insert p;
    }
    static testMethod void earnCreditAPITest() {

        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String guid = h.SubString(0,8);

        Account a = new Account();
        a.Affiliated_Id__c = 1002256;
        a.First_Name__c = 'first';
        a.Last_Name__c = 'last';
        a.Name = 'test';
        a.Member_Number__c = 'abc1234ad';
		a.Master_Record_Id__c = guid;
        insert a;
        
        Opportunity o = new Opportunity();
        o.AccountId = a.id;
        o.name = 'test opp';
        o.StageName = 'New';
        o.CloseDate = System.today();
        o.Amount = 500;
        o.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Travel').getRecordTypeId();
        insert o;
        
        Pricebook2 pb22 = new Pricebook2(Name='Travel Credits');
        insert pb22;
        
        Product2 pro2 = new Product2(Name='Travel Credits', isActive=true);
        insert pro2;
        
        PricebookEntry pbe2 =new PricebookEntry(unitprice=1,Product2Id=pro2.Id,Pricebook2Id=Test.getStandardPricebookId(),
                                                isActive=true,UseStandardPrice = false);
        insert pbe2;
        
        OpportunityLineItem OPplineitem2 = new OpportunityLineItem (Quantity=2, OpportunityId=o.Id,UnitPrice=1,PriceBookEntryId=pbe2.Id);
        insert OPplineitem2;
        
        List<OpportunityLineItem> opLineList = [select product_Id__c from OpportunityLineItem where id =:OPplineitem2.Id]; 
        
        Test.setMock(HttpCalloutMock.class, new MockPaymentAPI());
        
        Payment__c p = new Payment__c();
        p.Name = 'payment';
        p.Opportunity__c = o.id;
        p.Transaction_Type__c = 'Payment';
        p.Payment_Amount__c = 1;
        p.Credit_Card_Number__c = '6011832825897994';
        p.Paid_On__c = System.today();        
        p.Product_Id__c = opLineList[0].Product_Id__c;
        p.RecordTypeId = Schema.SObjectType.Payment__c.getRecordTypeInfosByName().get('Travel').getRecordTypeId();
        insert p;
    }


    static testMethod void muExitProductAPITest() {

        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String guid = h.SubString(0,8);

        Account a = new Account();
        a.Affiliated_Id__c = 1002256;
        a.First_Name__c = 'first';
        a.Last_Name__c = 'last';
        a.Name = 'test';
        a.Member_Number__c = 'abc1234ad';
		a.Master_Record_Id__c = guid;
        a.Dues_Last_Paid_Until__c = System.today();
        insert a;
        
        Opportunity o = new Opportunity();
        o.AccountId = a.id;
        o.name = 'test opp';
        o.StageName = 'New';
        o.CloseDate = System.today();
        o.Amount = 1394;
        o.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Membership Add-On').getRecordTypeId();        
        insert o;
        
        Pricebook2 pb22 = new Pricebook2(Name='Exit Product for MU Team');
        insert pb22;
        
        Product2 pro2 = new Product2(Name='Exit Product for MU Team', isActive=true);
        insert pro2;
        
        PricebookEntry pbe2 =new PricebookEntry(unitprice=399,Product2Id=pro2.Id,Pricebook2Id=Test.getStandardPricebookId(),
                                                isActive=true,UseStandardPrice = false);
        insert pbe2;
        
        OpportunityLineItem OPplineitem2 = new OpportunityLineItem (Quantity=1, OpportunityId=o.Id,UnitPrice=1,PriceBookEntryId=pbe2.Id);
        insert OPplineitem2;
        
        
        Pricebook2 pb23 = new Pricebook2(Name='Guest Voucher');
        insert pb23;
        
        Product2 pro3 = new Product2(Name='Guest Voucher', isActive=true);
        insert pro3;
        
        PricebookEntry pbe3 =new PricebookEntry(unitprice=995,Product2Id=pro3.Id,Pricebook2Id=Test.getStandardPricebookId(),
                                                isActive=true,UseStandardPrice = false);
        insert pbe3;
        
        OpportunityLineItem OPplineitem3 = new OpportunityLineItem (Quantity=1, OpportunityId=o.Id,UnitPrice=995,PriceBookEntryId=pbe3.Id);
        insert OPplineitem3;
        
        
        List<OpportunityLineItem> opLineList = [select product_Id__c from OpportunityLineItem where id =:OPplineitem2.Id]; 
        
        Test.setMock(HttpCalloutMock.class, new MockPaymentAPIFailed());
        
        Payment__c p = new Payment__c();
        p.Name = 'payment';
        p.Opportunity__c = o.id;
        p.Transaction_Type__c = 'Payment';
        p.Payment_Amount__c = 1394;
        p.Credit_Card_Number__c = '6011832825897994';
        p.Paid_On__c = System.today();        
        p.Product_Id__c = opLineList[0].Product_Id__c;
        p.RecordTypeId = Schema.SObjectType.Payment__c.getRecordTypeInfosByName().get('Voucher').getRecordTypeId();
        insert p;
    }
    
}