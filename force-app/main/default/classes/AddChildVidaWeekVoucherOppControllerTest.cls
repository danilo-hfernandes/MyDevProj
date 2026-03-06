@IsTest
public class AddChildVidaWeekVoucherOppControllerTest {
    
    @isTest
    static void Test1() {
        
        Account acc = new Account(Name = 'Test Account', Affiliated_Id__c = 1235, Member_Number__c = '13523412');
        insert acc;
        
        Id mtrcMURecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Membership_Upgrade').getRecordTypeId();
        Opportunity opp2 = new Opportunity (Name='Opp2',StageName='New',CloseDate=Date.today(),AccountId = acc.id, RecordTypeId = mtrcMURecordTypeId);
        insert opp2;

        Payment__c p = new Payment__c();
        p.Name = 'payment';
        p.Opportunity__c = opp2.id;
        p.Transaction_Type__c = 'Payment';
        p.Payment_Amount__c = 500;        
        p.Paid_On__c = System.today();
        p.RecordTypeId = Schema.SObjectType.Payment__c.getRecordTypeInfosByName().get('Membership Annual Dues').getRecordTypeId();
        insert p;        
        
        opp2.StageName = 'Closed Won';
        update opp2;
        
        Id standardPbId = Test.getStandardPricebookId();
        
        Product2 prd1 = new Product2 (Name='Membership Upgrade Vida Week',isActive = true);
        insert prd1;
        
        PricebookEntry pbe1 = new PricebookEntry (Product2ID=prd1.id,Pricebook2ID=standardPbId,UnitPrice=0, isActive=true);
        insert pbe1;
        
        Map<String,String> results = AddChildVidaWeekVoucherOppController.tryToAddChildVidaWeekVoucherOpp(opp2.Id);
        AddChildVidaWeekVoucherOppController.tryToAddChildVidaWeekVoucherOppFuture(opp2.Id); //will fail - existing child opp
        AddChildVidaWeekVoucherOppController.searchAndMoveChildOppToClosedLost(opp2.Id);
        
    }
    
        @isTest
    static void Test2() {
        
        Account acc = new Account(Name = 'Test Account', Affiliated_Id__c = 1235, Member_Number__c = '13523412');
        insert acc;
        
        Id mtrcMURecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Membership_Upgrade').getRecordTypeId();
        Opportunity opp2 = new Opportunity (Name='Opp2',StageName='New',CloseDate=Date.today(),AccountId = acc.id, RecordTypeId = mtrcMURecordTypeId);
        insert opp2;
        
        Id mtrcRetailRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('MTRC_Retail').getRecordTypeId();
        Opportunity opp3 = new Opportunity (Name='Opp3',StageName='New',CloseDate=Date.today(),AccountId = acc.id, RecordTypeId = mtrcRetailRecordTypeId);
        insert opp3;
        
        Payment__c p = new Payment__c();
        p.Name = 'payment';
        p.Opportunity__c = opp2.id;
        p.Transaction_Type__c = 'Payment';
        p.Payment_Amount__c = 500;        
        p.Paid_On__c = System.today();
        p.RecordTypeId = Schema.SObjectType.Payment__c.getRecordTypeInfosByName().get('Membership Annual Dues').getRecordTypeId();
        insert p;  
        
        opp2.StageName = 'Closed Won';
        update opp2;
        
         Payment__c p1 = new Payment__c();
        p1.Name = 'payment';
        p1.Opportunity__c = opp3.id;
        p1.Transaction_Type__c = 'Payment';
        p1.Payment_Amount__c = 500;        
        p1.Paid_On__c = System.today();
        p1.RecordTypeId = Schema.SObjectType.Payment__c.getRecordTypeInfosByName().get('Membership Annual Dues').getRecordTypeId();
        insert p1;  
        
        opp3.StageName = 'Closed Won';
        update opp3;
        
        Id standardPbId = Test.getStandardPricebookId();
        
        Product2 prd1 = new Product2 (Name='Membership Upgrade Vida Week',isActive = true);
        insert prd1;
        
        PricebookEntry pbe1 = new PricebookEntry (Product2ID=prd1.id,Pricebook2ID=standardPbId,UnitPrice=0, isActive=true);
        insert pbe1;
        
        AddChildVidaWeekVoucherOppController.tryToAddChildVidaWeekVoucherOppFuture(opp2.Id); //will run - no existing child opp
        AddChildVidaWeekVoucherOppController.tryToAddChildVidaWeekVoucherOppFuture(opp3.Id); 
        
    }
    
    @isTest
    static void Test3() {
        
        Account acc = new Account(Name = 'Test Account', Affiliated_Id__c = 1235, Member_Number__c = '13523412');
        insert acc;
        
        Id mtrcAnnualDuesRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Membership_Annual_Dues').getRecordTypeId();
        Opportunity opp2 = new Opportunity (Name='Opp2',StageName='New',CloseDate=Date.today(),AccountId = acc.id, RecordTypeId = mtrcAnnualDuesRecordTypeId);
        insert opp2;
        
        Id standardPbId = Test.getStandardPricebookId();
        
        Product2 prd1 = new Product2 (Name='Voucher-Vidanta Complimentary',isActive = true);
        insert prd1;
        
        PricebookEntry pbe1 = new PricebookEntry (Product2ID=prd1.id,Pricebook2ID=standardPbId,UnitPrice=0, isActive=true);
        insert pbe1;
        
        Product2 prd2 = new Product2 (Name='Annual Dues Voucher Bundle',isActive = true);
        insert prd2;
        
        PricebookEntry pbe2 = new PricebookEntry (Product2ID=prd2.id,Pricebook2ID=standardPbId,UnitPrice=0, isActive=true);
        insert pbe2;

        OpportunityLineItem lineItem1 = new OpportunityLineItem (OpportunityID=opp2.id,PriceBookEntryID=pbe2.id, quantity=1, totalprice=5000, retail_price__c = 5000);
        insert lineItem1;
        
        Payment__c p = new Payment__c();
        p.Name = 'payment';
        p.Opportunity__c = opp2.id;
        p.Transaction_Type__c = 'Payment';
        p.Payment_Amount__c = 500;        
        p.Paid_On__c = System.today();        
        p.RecordTypeId = Schema.SObjectType.Payment__c.getRecordTypeInfosByName().get('Membership Annual Dues').getRecordTypeId();
        insert p;  
        
        opp2.StageName = 'Closed Won';
        update opp2;
                
        AddChildVidaWeekVoucherOppController.tryToAddChildVidantaComplimentaryVoucherOppFuture(opp2.Id);
        AddChildVidaWeekVoucherOppController.tryToAddChildVidantaComplimentaryVoucherOppFuture(opp2.Id); //will fail - existing child opp
        
    }

    @isTest
    static void Test4() {
        
        Account acc = new Account(Name = 'Test Account', Affiliated_Id__c = 1235, Member_Number__c = '13523412');
        insert acc;
        
        Id mtrcAnnualDuesRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Membership_Annual_Dues').getRecordTypeId();
        Opportunity opp2 = new Opportunity (Name='Opp2',StageName='New',CloseDate=Date.today(),AccountId = acc.id, RecordTypeId = mtrcAnnualDuesRecordTypeId);
        insert opp2;
        
        Id standardPbId = Test.getStandardPricebookId();
        
        Product2 prd1 = new Product2 (Name='FlexStay-Add On',isActive = true);
        insert prd1;
        
        PricebookEntry pbe1 = new PricebookEntry (Product2ID=prd1.id,Pricebook2ID=standardPbId,UnitPrice=0, isActive=true);
        insert pbe1;
        
        Product2 prd2 = new Product2 (Name='Annual Dues FlexStay Voucher Bundle',isActive = true);
        insert prd2;
        
        PricebookEntry pbe2 = new PricebookEntry (Product2ID=prd2.id,Pricebook2ID=standardPbId,UnitPrice=0, isActive=true);
        insert pbe2;
        
        OpportunityLineItem lineItem1 = new OpportunityLineItem (OpportunityID=opp2.id,PriceBookEntryID=pbe2.id, quantity=1, totalprice=5000, retail_price__c = 5000);
        insert lineItem1;
        
        Payment__c p = new Payment__c();
        p.Name = 'payment';
        p.Opportunity__c = opp2.id;
        p.Transaction_Type__c = 'Payment';
        p.Payment_Amount__c = 500;        
        p.Paid_On__c = System.today();        
        p.RecordTypeId = Schema.SObjectType.Payment__c.getRecordTypeInfosByName().get('Membership Annual Dues').getRecordTypeId();
        insert p;  
        
        opp2.StageName = 'Closed Won';
        update opp2;
        
        AddChildVidaWeekVoucherOppController.tryToAddChildVidantaComplimentaryVoucherOppFuture(opp2.Id);
        AddChildVidaWeekVoucherOppController.tryToAddChildVidantaComplimentaryVoucherOppFuture(opp2.Id); //will fail - existing child opp
        
    }

    @isTest
    static void Test5() {
        
        Account acc = new Account(Name = 'Test Account', Affiliated_Id__c = 1235, Member_Number__c = '13523412', Email__c = 'victor_20240402@gmail.com');
        insert acc;
        
        Id mtrcMURecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Membership_Upgrade').getRecordTypeId();
        Opportunity opp2 = new Opportunity (Account_Email__c = 'victor_20240402@gmail.com', Name='Opp2',StageName='New',CloseDate=Date.today(),AccountId = acc.id, RecordTypeId = mtrcMURecordTypeId);
        insert opp2;  

        Id standardPbId = Test.getStandardPricebookId();
                      
        Product2 prd2 = new Product2 (Name='Marival MU-Add On',isActive = true);
        insert prd2;
        
        PricebookEntry pbe2 = new PricebookEntry (Product2ID=prd2.id,Pricebook2ID=standardPbId,UnitPrice=1000, isActive=true);
        insert pbe2;
        
        OpportunityLineItem lineItem1 = new OpportunityLineItem (OpportunityID=opp2.id,PriceBookEntryID=pbe2.id, quantity=1, totalprice=1000, retail_price__c = 1000);
        insert lineItem1;
                
        Payment__c p = new Payment__c();
        p.Name = 'payment';
        p.Opportunity__c = opp2.id;
        p.Transaction_Type__c = 'Payment';
        p.Payment_Amount__c = 1000;        
        p.Paid_On__c = System.today();
        p.RecordTypeId = Schema.SObjectType.Payment__c.getRecordTypeInfosByName().get('Membership Annual Dues').getRecordTypeId();
        insert p;  
        
        opp2.StageName = 'Closed Won';
        update opp2;
        
        Product2 prd1 = new Product2 (Name='Marival Armony-4 Nights (2A) Studio',isActive = true);
        insert prd1;
        
        PricebookEntry pbe1 = new PricebookEntry (Product2ID=prd1.id,Pricebook2ID=standardPbId,UnitPrice=0, isActive=true);
        insert pbe1;

        Product2 prd3 = new Product2 (Name='Marival Booking Fee',isActive = true);
        insert prd3;
        
        PricebookEntry pbe3 = new PricebookEntry (Product2ID=prd3.id,Pricebook2ID=standardPbId,UnitPrice=99, isActive=true);
        insert pbe3;

        Product2 prd4 = new Product2 (Name='Marival Resort Fee',isActive = true);
        insert prd4;
        
        PricebookEntry pbe4 = new PricebookEntry (Product2ID=prd4.id,Pricebook2ID=standardPbId,UnitPrice=199, isActive=true);
        insert pbe4;
        
        AddChildVidaWeekVoucherOppController.tryToAddChildVidaWeekVoucherOppFuture(opp2.Id); //will run - no existing child opp
        
    }

}