@isTest
public class TimeshareDetailsWithProductTest {
    static testMethod void TimeshareDetailsCtrl_Test(){
        Resort__c r = new Resort__c();
        r.name = 'test';
        insert r;
        
        Timeshare__c Ts = new Timeshare__c();
        Ts.Resort__c = r.Id;
        Ts.Mortgage_Balance__c = 100;
        Ts.Mortgage_Monthly_Payment__c = '5';
        Ts.Master_Record_Id__c = 'Mitul1234';
        insert Ts;
    }
    static testMethod void TimeshareDetailsCtrl_Test01(){
        Resort__c r = new Resort__c();
        r.name = 'test';
        insert r;
        
        Timeshare__c Ts1 = new Timeshare__c();
        Ts1.Resort__c = r.Id;
        Ts1.Mortgage_Balance__c = 100;
        Ts1.Mortgage_Monthly_Payment__c = '5';
        Ts1.Master_Record_Id__c = 'Mitul1234';
        insert Ts1;
        Timeshare__c Ts2 = new Timeshare__c();
        Ts2.Resort__c = r.Id;
        Ts2.Mortgage_Balance__c = 100;
        Ts2.Mortgage_Monthly_Payment__c = '5';
        Ts2.Master_Record_Id__c = 'Mitul1234';
        insert Ts2;
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp';
        opp.Timeshare_1__c = Ts1.Id;
        opp.Timeshare_2__c = Ts1.Id;
        opp.Timeshare_3__c = Ts1.Id;
        opp.Timeshare_4__c = Ts1.Id;
        opp.Timeshare_5__c = Ts1.Id;
        opp.Timeshare_6__c = Ts1.Id;
        opp.Timeshare_7__c = Ts1.Id;
        opp.Timeshare_8__c = Ts1.Id;
        opp.Timeshare_9__c = Ts1.Id;
        opp.Timeshare_10__c = Ts1.Id;
        opp.StageName = 'Prospecting';
        opp.CloseDate = system.Today()-30;
        insert opp;
        
        Id  standardPb = Test.getStandardPricebookId();
        
        Product2 prd1 = new Product2 (Name='Guest Voucher',Description='Test Product Entry 1', isActive = true);
        insert prd1;
        
        
        PricebookEntry pbe1 = new PricebookEntry (Product2ID=prd1.id,Pricebook2ID=standardPb,UnitPrice=50, isActive=true);
        insert pbe1;
        
        OpportunityLineItem lineItem1 = new OpportunityLineItem (OpportunityID=opp.id,PriceBookEntryID=pbe1.id, quantity=4, totalprice=200, retail_price__c = 99, Timeshare__c= Ts1.Id);
        insert lineItem1;
        
        opp.Timeshare_1_OppProd_Id__c = lineItem1.Id;
        opp.Timeshare_2_OppProd_Id__c = lineItem1.Id;
        opp.Timeshare_3_OppProd_Id__c = lineItem1.Id;
        opp.Timeshare_4_OppProd_Id__c = lineItem1.Id;
        opp.Timeshare_5_OppProd_Id__c = lineItem1.Id;
        opp.Timeshare_6_OppProd_Id__c = lineItem1.Id;
        opp.Timeshare_7_OppProd_Id__c = lineItem1.Id;
        opp.Timeshare_8_OppProd_Id__c = lineItem1.Id;
        opp.Timeshare_9_OppProd_Id__c = lineItem1.Id;
        
        update opp;
        
        test.startTest();
        TimeshareDetailsWithProduct.timeshareWrapper tss = new TimeshareDetailsWithProduct.timeshareWrapper();
        TimeshareDetailsWithProduct.productWrapper prd2 = new TimeshareDetailsWithProduct.productWrapper();
        TimeshareDetailsWithProduct TimeShare = new TimeshareDetailsWithProduct();
        TimeshareDetailsWithProduct.timeshareWrapper(opp.Id);
        
        TimeshareDetailsWithProduct.saveSelectedTimeshare(Ts1.Id,opp.Id);
        TimeshareDetailsWithProduct.selectedTimeshare(Ts1.Id); 
        TimeshareDetailsWithProduct.timesharRecordDetails(Ts1.Id);
        TimeshareDetailsWithProduct.updateOpportunity(Ts2.Id, opp.Id);
        system.debug('lineItem1='+lineItem1);
        delete lineItem1;
        system.debug('lineItem1='+lineItem1);
        TimeshareDetailsWithProduct.timesharDelete(Ts2.Id, opp.Id,'1');
        system.debug('after timesharDelete');
        delete opp;  
        test.stopTest(); 
    } 

    static testMethod void TimeshareDetailsCtrl_Test02(){
        Resort__c r = new Resort__c();
        r.name = 'test';
        insert r;
        
        Timeshare__c Ts1 = new Timeshare__c();
        Ts1.Resort__c = r.Id;
        Ts1.Mortgage_Balance__c = 100;
        Ts1.Mortgage_Monthly_Payment__c = '5';
        Ts1.Master_Record_Id__c = 'Mitul1234';
        insert Ts1;
        Timeshare__c Ts2 = new Timeshare__c();
        Ts2.Resort__c = r.Id;
        Ts2.Mortgage_Balance__c = 100;
        Ts2.Mortgage_Monthly_Payment__c = '5';
        Ts2.Master_Record_Id__c = 'Mitul1234';
        insert Ts2;
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp';
        opp.Timeshare_1__c = Ts1.Id;
        opp.Timeshare_2__c = Ts1.Id;
        opp.Timeshare_3__c = Ts1.Id;
        opp.Timeshare_4__c = Ts1.Id;
        opp.Timeshare_5__c = Ts1.Id;
        opp.Timeshare_6__c = Ts1.Id;
        opp.Timeshare_7__c = Ts1.Id;
        opp.Timeshare_8__c = Ts1.Id;
        opp.Timeshare_9__c = Ts1.Id;
        opp.Timeshare_10__c = Ts1.Id;
        opp.StageName = 'Prospecting';
        opp.CloseDate = system.Today()-30;
        insert opp;
        
        Id  standardPb = Test.getStandardPricebookId();
        
        Product2 prd1 = new Product2 (Name='Guest Voucher',Description='Test Product Entry 1', isActive = true);
        insert prd1;
        
        
        PricebookEntry pbe1 = new PricebookEntry (Product2ID=prd1.id,Pricebook2ID=standardPb,UnitPrice=50, isActive=true);
        insert pbe1;
        
        OpportunityLineItem lineItem1 = new OpportunityLineItem (OpportunityID=opp.id,PriceBookEntryID=pbe1.id, quantity=4, totalprice=200, retail_price__c = 99, Timeshare__c= Ts1.Id);
        insert lineItem1;
        
        opp.Timeshare_2_OppProd_Id__c = lineItem1.Id;
        update opp;
        
        test.startTest();
        TimeshareDetailsWithProduct.timeshareWrapper tss = new TimeshareDetailsWithProduct.timeshareWrapper();
        TimeshareDetailsWithProduct.productWrapper prd2 = new TimeshareDetailsWithProduct.productWrapper();
        TimeshareDetailsWithProduct TimeShare = new TimeshareDetailsWithProduct();
        TimeshareDetailsWithProduct.timeshareWrapper(opp.Id);
        
        TimeshareDetailsWithProduct.saveSelectedTimeshare(Ts1.Id,opp.Id);
        TimeshareDetailsWithProduct.selectedTimeshare(Ts1.Id); 
        TimeshareDetailsWithProduct.timesharRecordDetails(Ts1.Id);
        TimeshareDetailsWithProduct.updateOpportunity(Ts2.Id, opp.Id);
        system.debug('lineItem1='+lineItem1);
        delete lineItem1;
        system.debug('lineItem1='+lineItem1);
        TimeshareDetailsWithProduct.timesharDelete(Ts2.Id, opp.Id,'2');
        system.debug('after timesharDelete');
        delete opp;  
        test.stopTest(); 
    } 
    
    
    static testMethod void TimeshareDetailsCtrl_Test03(){
        Resort__c r = new Resort__c();
        r.name = 'test';
        insert r;
        
        Timeshare__c Ts1 = new Timeshare__c();
        Ts1.Resort__c = r.Id;
        Ts1.Mortgage_Balance__c = 100;
        Ts1.Mortgage_Monthly_Payment__c = '5';
        Ts1.Master_Record_Id__c = 'Mitul1234';
        insert Ts1;
        Timeshare__c Ts2 = new Timeshare__c();
        Ts2.Resort__c = r.Id;
        Ts2.Mortgage_Balance__c = 100;
        Ts2.Mortgage_Monthly_Payment__c = '5';
        Ts2.Master_Record_Id__c = 'Mitul1234';
        insert Ts2;
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp';
        opp.Timeshare_1__c = Ts1.Id;
        opp.Timeshare_2__c = Ts1.Id;
        opp.Timeshare_3__c = Ts1.Id;
        opp.Timeshare_4__c = Ts1.Id;
        opp.Timeshare_5__c = Ts1.Id;
        opp.Timeshare_6__c = Ts1.Id;
        opp.Timeshare_7__c = Ts1.Id;
        opp.Timeshare_8__c = Ts1.Id;
        opp.Timeshare_9__c = Ts1.Id;
        opp.Timeshare_10__c = Ts1.Id;
        opp.StageName = 'Prospecting';
        opp.CloseDate = system.Today()-30;
        insert opp;
        
        Id  standardPb = Test.getStandardPricebookId();
        
        Product2 prd1 = new Product2 (Name='Guest Voucher',Description='Test Product Entry 1', isActive = true);
        insert prd1;
        
        
        PricebookEntry pbe1 = new PricebookEntry (Product2ID=prd1.id,Pricebook2ID=standardPb,UnitPrice=50, isActive=true);
        insert pbe1;
        
        OpportunityLineItem lineItem1 = new OpportunityLineItem (OpportunityID=opp.id,PriceBookEntryID=pbe1.id, quantity=4, totalprice=200, retail_price__c = 99, Timeshare__c= Ts1.Id);
        insert lineItem1;
        
        opp.Timeshare_3_OppProd_Id__c = lineItem1.Id;
        update opp;
        
        test.startTest();
        TimeshareDetailsWithProduct.timeshareWrapper tss = new TimeshareDetailsWithProduct.timeshareWrapper();
        TimeshareDetailsWithProduct.productWrapper prd2 = new TimeshareDetailsWithProduct.productWrapper();
        TimeshareDetailsWithProduct TimeShare = new TimeshareDetailsWithProduct();
        TimeshareDetailsWithProduct.timeshareWrapper(opp.Id);
        
        TimeshareDetailsWithProduct.saveSelectedTimeshare(Ts1.Id,opp.Id);
        TimeshareDetailsWithProduct.selectedTimeshare(Ts1.Id); 
        TimeshareDetailsWithProduct.timesharRecordDetails(Ts1.Id);
        TimeshareDetailsWithProduct.updateOpportunity(Ts2.Id, opp.Id);
        system.debug('lineItem1='+lineItem1);
        delete lineItem1;
        system.debug('lineItem1='+lineItem1);
        TimeshareDetailsWithProduct.timesharDelete(Ts2.Id, opp.Id,'3');
        system.debug('after timesharDelete');
        delete opp;  
        test.stopTest(); 
    } 
    
    
    static testMethod void TimeshareDetailsCtrl_Test1(){
        Resort__c r = new Resort__c();
        r.name = 'test';
        insert r;
        
        Timeshare__c Ts1 = new Timeshare__c();
        Ts1.Resort__c = r.Id;
        Ts1.Mortgage_Balance__c = 100;
        Ts1.Mortgage_Monthly_Payment__c = '5';
        Ts1.Master_Record_Id__c = 'Mitul1234';
        insert Ts1;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp';
        opp.Timeshare_1__c = Ts1.Id;
        opp.StageName = 'Prospecting';
        opp.CloseDate = system.Today()-30;
        insert opp;
        
        
        test.startTest();
        TimeshareDetailsWithProduct.timeshareWrapper tss = new TimeshareDetailsWithProduct.timeshareWrapper();
        TimeshareDetailsWithProduct.productWrapper prd2 = new TimeshareDetailsWithProduct.productWrapper();
        TimeshareDetailsWithProduct TimeShare = new TimeshareDetailsWithProduct();
        TimeshareDetailsWithProduct.timeshareWrapper(opp.Id);
        
        TimeshareDetailsWithProduct.saveSelectedTimeshare(Ts1.Id,opp.Id);
        TimeshareDetailsWithProduct.selectedTimeshare(Ts1.Id);
        TimeshareDetailsWithProduct.timesharRecordDetails(Ts1.Id);
        TimeshareDetailsWithProduct.updateOpportunity(Ts1.Id, opp.Id);
        TimeshareDetailsWithProduct.timesharDelete(Ts1.Id, opp.Id,'1');
        delete opp;
        test.stopTest();
    }
    static testMethod void TimeshareDetailsCtrl_Test2(){
        test.startTest();	
        Resort__c r = new Resort__c();
        r.name = 'test';
        insert r;
        
        Timeshare__c Ts2 = new Timeshare__c();
        Ts2.Resort__c = r.Id;
        Ts2.Mortgage_Balance__c = 100;
        Ts2.Mortgage_Monthly_Payment__c = '5';
        Ts2.Master_Record_Id__c = 'Mitul1234';
        insert Ts2;
        
        Opportunity opp1 = new Opportunity();
        opp1.Name = 'Test Opp';
        opp1.Timeshare_2__c = Ts2.Id;
        
        
        opp1.StageName = 'Prospecting';
        opp1.CloseDate = system.Today()-30;
        insert opp1;
        
        
        
        TimeshareDetailsWithProduct.timeshareWrapper tss = new TimeshareDetailsWithProduct.timeshareWrapper();
        TimeshareDetailsWithProduct.productWrapper prd2 = new TimeshareDetailsWithProduct.productWrapper();
        TimeshareDetailsWithProduct TimeShare = new TimeshareDetailsWithProduct();
        TimeshareDetailsWithProduct.timeshareWrapper(opp1.Id);
        
        TimeshareDetailsWithProduct.saveSelectedTimeshare(Ts2.Id,opp1.Id);
        TimeshareDetailsWithProduct.selectedTimeshare(Ts2.Id);
        TimeshareDetailsWithProduct.updateOpportunity(Ts2.Id, opp1.Id);
        TimeshareDetailsWithProduct.timesharDelete(Ts2.Id, opp1.Id,'2');
        delete opp1;
        test.stopTest();
        
    }
    static testMethod void TimeshareDetailsCtrl_Test3(){
        test.startTest();
        
        Resort__c r = new Resort__c();
        r.name = 'test';
        insert r;
        
        Timeshare__c Ts3 = new Timeshare__c();
        Ts3.Resort__c = r.Id;
        Ts3.Mortgage_Balance__c = 100;
        Ts3.Mortgage_Monthly_Payment__c = '5';
        Ts3.Master_Record_Id__c = 'Mitul1234';
        insert Ts3;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp';
        opp.Timeshare_3__c = Ts3.Id;
        opp.Timeshare_2__c = null;
        opp.Timeshare_1__c = null;
        opp.StageName = 'Prospecting';
        opp.CloseDate = system.Today()-30;
        insert opp;
        
        
        
        
        TimeshareDetailsWithProduct.timeshareWrapper tss = new TimeshareDetailsWithProduct.timeshareWrapper();
        TimeshareDetailsWithProduct.productWrapper prd2 = new TimeshareDetailsWithProduct.productWrapper();
        TimeshareDetailsWithProduct TimeShare = new TimeshareDetailsWithProduct();
        TimeshareDetailsWithProduct.timeshareWrapper(opp.Id);
        
        TimeshareDetailsWithProduct.saveSelectedTimeshare(Ts3.Id,opp.Id);
        TimeshareDetailsWithProduct.selectedTimeshare(Ts3.Id); 
        TimeshareDetailsWithProduct.updateOpportunity(Ts3.Id, opp.Id);
        TimeshareDetailsWithProduct.timesharDelete(Ts3.Id, opp.Id,'3');
        delete opp;
        test.stopTest();
    }
    static testMethod void TimeshareDetailsCtrl_Test4(){
        test.startTest();
        
        Resort__c r = new Resort__c();
        r.name = 'test';
        insert r;
        
        Timeshare__c Ts4 = new Timeshare__c();
        Ts4.Resort__c = r.Id;
        Ts4.Mortgage_Balance__c = 100;
        Ts4.Mortgage_Monthly_Payment__c = '5';
        Ts4.Master_Record_Id__c = 'Mitul1234';
        insert Ts4;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp';
        opp.Timeshare_4__c = Ts4.Id;
        
        opp.StageName = 'Prospecting';
        opp.CloseDate = system.Today()-30;
        insert opp;
        
        
        TimeshareDetailsWithProduct.timeshareWrapper tss = new TimeshareDetailsWithProduct.timeshareWrapper();
        TimeshareDetailsWithProduct.productWrapper prd2 = new TimeshareDetailsWithProduct.productWrapper();
        TimeshareDetailsWithProduct TimeShare = new TimeshareDetailsWithProduct();
        TimeshareDetailsWithProduct.timeshareWrapper(opp.Id);
        
        TimeshareDetailsWithProduct.saveSelectedTimeshare(Ts4.Id,opp.Id);
        TimeshareDetailsWithProduct.selectedTimeshare(Ts4.Id);
        TimeshareDetailsWithProduct.updateOpportunity(Ts4.Id, opp.Id);
        TimeshareDetailsWithProduct.timesharDelete(Ts4.Id, opp.Id,'4');
        test.stopTest();
    }
    
    static testMethod void TimeshareDetailsCtrl_Test5(){
        test.startTest();
        
        Resort__c r = new Resort__c();
        r.name = 'test';
        insert r;
        
        Timeshare__c Ts5 = new Timeshare__c();
        Ts5.Resort__c = r.Id;
        Ts5.Mortgage_Balance__c = 100;
        Ts5.Mortgage_Monthly_Payment__c = '5';
        Ts5.Master_Record_Id__c = 'Mitul1234';
        insert Ts5;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp';
        opp.Timeshare_5__c = Ts5.Id;
        
        opp.StageName = 'Prospecting';
        opp.CloseDate = system.Today()-30;
        insert opp;
        
        
        TimeshareDetailsWithProduct.timeshareWrapper tss = new TimeshareDetailsWithProduct.timeshareWrapper();
        TimeshareDetailsWithProduct.productWrapper prd2 = new TimeshareDetailsWithProduct.productWrapper();
        TimeshareDetailsWithProduct TimeShare = new TimeshareDetailsWithProduct();
        TimeshareDetailsWithProduct.timeshareWrapper(opp.Id);
        
        TimeshareDetailsWithProduct.saveSelectedTimeshare(Ts5.Id,opp.Id);
        TimeshareDetailsWithProduct.selectedTimeshare(Ts5.Id);
        TimeshareDetailsWithProduct.updateOpportunity(Ts5.Id, opp.Id);
        TimeshareDetailsWithProduct.timesharDelete(Ts5.Id, opp.Id,'5');
        test.stopTest();
    }
    static testMethod void TimeshareDetailsCtrl_Test6(){
        test.startTest();
        
        Resort__c r = new Resort__c();
        r.name = 'test';
        insert r;
        
        Timeshare__c Ts6 = new Timeshare__c();
        Ts6.Resort__c = r.Id;
        Ts6.Mortgage_Balance__c = 100;
        Ts6.Mortgage_Monthly_Payment__c = '5';
        Ts6.Master_Record_Id__c = 'Mitul1234';
        insert Ts6;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp';
        opp.Timeshare_6__c = Ts6.Id;
        opp.StageName = 'Prospecting';
        opp.CloseDate = system.Today()-30;
        insert opp;
        
        
        TimeshareDetailsWithProduct.timeshareWrapper tss = new TimeshareDetailsWithProduct.timeshareWrapper();
        TimeshareDetailsWithProduct.productWrapper prd2 = new TimeshareDetailsWithProduct.productWrapper();
        TimeshareDetailsWithProduct TimeShare = new TimeshareDetailsWithProduct();
        TimeshareDetailsWithProduct.timeshareWrapper(opp.Id);
        
        TimeshareDetailsWithProduct.saveSelectedTimeshare(Ts6.Id,opp.Id);
        TimeshareDetailsWithProduct.selectedTimeshare(Ts6.Id);
        TimeshareDetailsWithProduct.updateOpportunity(Ts6.Id, opp.Id);
        TimeshareDetailsWithProduct.timesharDelete(Ts6.Id, opp.Id,'6');
        test.stopTest();
    }
    static testMethod void TimeshareDetailsCtrl_Test7(){
        test.startTest();
        
        Resort__c r = new Resort__c();
        r.name = 'test';
        insert r;
        
        Timeshare__c Ts7 = new Timeshare__c();
        Ts7.Resort__c = r.Id;
        Ts7.Mortgage_Balance__c = 100;
        Ts7.Mortgage_Monthly_Payment__c = '5';
        Ts7.Master_Record_Id__c = 'Mitul1234';
        insert Ts7;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp';
        opp.Timeshare_7__c = Ts7.Id;
        
        opp.StageName = 'Prospecting';
        opp.CloseDate = system.Today()-30;
        insert opp;
        
        
        TimeshareDetailsWithProduct.timeshareWrapper tss = new TimeshareDetailsWithProduct.timeshareWrapper();
        TimeshareDetailsWithProduct.productWrapper prd2 = new TimeshareDetailsWithProduct.productWrapper();
        TimeshareDetailsWithProduct TimeShare = new TimeshareDetailsWithProduct();
        TimeshareDetailsWithProduct.timeshareWrapper(opp.Id);
        
        TimeshareDetailsWithProduct.saveSelectedTimeshare(Ts7.Id,opp.Id);
        TimeshareDetailsWithProduct.selectedTimeshare(Ts7.Id);
        TimeshareDetailsWithProduct.updateOpportunity(Ts7.Id, opp.Id);
        TimeshareDetailsWithProduct.timesharDelete(Ts7.Id, opp.Id,'7');
        test.stopTest();
    }
    static testMethod void TimeshareDetailsCtrl_Test8(){
        Resort__c r = new Resort__c();
        r.name = 'test';
        insert r;
        
        Timeshare__c Ts8 = new Timeshare__c();
        Ts8.Resort__c = r.Id;
        Ts8.Mortgage_Balance__c = 100;
        Ts8.Mortgage_Monthly_Payment__c = '5';
        Ts8.Master_Record_Id__c = 'Mitul1234';
        insert Ts8;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp';
        opp.Timeshare_8__c = Ts8.Id;
        
        opp.StageName = 'Prospecting';
        opp.CloseDate = system.Today()-30;
        insert opp;
        
        test.startTest();
        TimeshareDetailsWithProduct.timeshareWrapper tss = new TimeshareDetailsWithProduct.timeshareWrapper();
        TimeshareDetailsWithProduct.productWrapper prd2 = new TimeshareDetailsWithProduct.productWrapper();
        TimeshareDetailsWithProduct TimeShare = new TimeshareDetailsWithProduct();
        TimeshareDetailsWithProduct.timeshareWrapper(opp.Id);
        
        TimeshareDetailsWithProduct.saveSelectedTimeshare(Ts8.Id,opp.Id);
        TimeshareDetailsWithProduct.selectedTimeshare(Ts8.Id);
        TimeshareDetailsWithProduct.updateOpportunity(Ts8.Id, opp.Id);
        TimeshareDetailsWithProduct.timesharDelete(Ts8.Id, opp.Id,'8');
        test.stopTest();
    }
    static testMethod void TimeshareDetailsCtrl_Test9(){
        Resort__c r = new Resort__c();
        r.name = 'test';
        insert r;
        
        Timeshare__c Ts9 = new Timeshare__c();
        Ts9.Resort__c = r.Id;
        Ts9.Mortgage_Balance__c = 100;
        Ts9.Mortgage_Monthly_Payment__c = '5';
        Ts9.Master_Record_Id__c = 'Mitul1234';
        insert Ts9;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp';
        opp.Timeshare_9__c = Ts9.Id;
        
        opp.StageName = 'Prospecting';
        opp.CloseDate = system.Today()-30;
        insert opp;
        
        test.startTest();
        TimeshareDetailsWithProduct.timeshareWrapper tss = new TimeshareDetailsWithProduct.timeshareWrapper();
        TimeshareDetailsWithProduct.productWrapper prd2 = new TimeshareDetailsWithProduct.productWrapper();
        TimeshareDetailsWithProduct TimeShare = new TimeshareDetailsWithProduct();
        TimeshareDetailsWithProduct.timeshareWrapper(opp.Id);
        
        TimeshareDetailsWithProduct.saveSelectedTimeshare(Ts9.Id,opp.Id);
        TimeshareDetailsWithProduct.selectedTimeshare(Ts9.Id);
        TimeshareDetailsWithProduct.updateOpportunity(Ts9.Id, opp.Id);
        TimeshareDetailsWithProduct.timesharDelete(Ts9.Id, opp.Id,'9');
        test.stopTest();
    }
    
    static testMethod void TimeshareDetailsCtrl_Test10(){
        Resort__c r = new Resort__c();
        r.name = 'test';
        insert r;
        
        Timeshare__c Ts10 = new Timeshare__c();
        Ts10.Resort__c = r.Id;
        Ts10.Mortgage_Balance__c = 100;
        Ts10.Mortgage_Monthly_Payment__c = '5';
        Ts10.Master_Record_Id__c = 'Mitul1234';
        insert Ts10;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp';
        opp.Timeshare_10__c = Ts10.Id;
        
        opp.StageName = 'Prospecting';
        opp.CloseDate = system.Today()-30;
        insert opp;
        
        test.startTest();
        TimeshareDetailsWithProduct.timeshareWrapper tss = new TimeshareDetailsWithProduct.timeshareWrapper();
        TimeshareDetailsWithProduct.productWrapper prd2 = new TimeshareDetailsWithProduct.productWrapper();
        TimeshareDetailsWithProduct TimeShare = new TimeshareDetailsWithProduct();
        TimeshareDetailsWithProduct.timeshareWrapper(opp.Id);
        
        TimeshareDetailsWithProduct.saveSelectedTimeshare(Ts10.Id,opp.Id);
        TimeshareDetailsWithProduct.selectedTimeshare(Ts10.Id);
        TimeshareDetailsWithProduct.updateOpportunity(Ts10.Id, opp.Id);
        TimeshareDetailsWithProduct.timesharDelete(Ts10.Id, opp.Id,'10');
        test.stopTest();
    }
    
    static testMethod void TimeshareDetailsCtrl_Test11(){
        Resort__c r = new Resort__c();
        r.name = 'test';
        insert r;
        
        Timeshare__c Ts = new Timeshare__c();
        Ts.Resort__c = r.Id;
        Ts.Mortgage_Balance__c = 100;
        Ts.Mortgage_Monthly_Payment__c = '5';
        Ts.Master_Record_Id__c = 'Mitul1234';
        
        insert Ts;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp';
        opp.Timeshare_1__c = Ts.Id;
        
        opp.StageName = 'Prospecting';
        opp.CloseDate = system.Today()-30;
        insert opp;
        
        // without timeshare details
        Opportunity opp1 = new Opportunity();
        opp1.Name = 'Test Opp';
        
        opp1.StageName = 'Prospecting';
        opp1.CloseDate = system.Today()+3;
        insert opp1;
        
        TimeshareDetailsWithProduct.timeshareWrapper tss = new TimeshareDetailsWithProduct.timeshareWrapper();
        TimeshareDetailsWithProduct.productWrapper prd2 = new TimeshareDetailsWithProduct.productWrapper();
        
        prd2.selected = true;
        prd2.unitprice = 7000;
        prd2.ReasontoSellPickselectedValue = 'OTHER';
        
        TimeshareDetailsWithProduct.productWrapper prd3 = new TimeshareDetailsWithProduct.productWrapper();
        
        prd3.selected = true;
        prd3.unitprice = 7000;
        prd3.ReasontoSellPickselectedValue = 'OTHER';
        prd3.vendorDiscount = 0;
        List<TimeshareDetailsWithProduct.productWrapper> prdList = new List<TimeshareDetailsWithProduct.productWrapper>();
        prdList.add(prd2); 
        List<TimeshareDetailsWithProduct.productWrapper> prdList1 = new List<TimeshareDetailsWithProduct.productWrapper>();
        prdList1.add(prd3);  
        
        
        Pricebook2 pb = new Pricebook2(Name = 'Standard Price Book', Description = 'Price Book Products', IsActive = true );
        insert pb;
        Product2 prod = new Product2(Name = 'WWPT Product', IsActive = true);
        insert prod;
        Product2 prod2 = new Product2(Name = 'Premier Travel Pass', IsActive = true);
        insert prod2;
        Product2 prod3 = new Product2(Name = 'My Travel Rewards Club', IsActive = true);
        insert prod3;
        Product2 prod4 = new Product2(Name = 'Equity Product', IsActive = true);
        insert prod4;
        Product2 prod5 = new Product2(Name = 'Maintenance Fee Protection', IsActive = true);
        insert prod5;
        Product2 prod6 = new Product2(Name = 'Sapphire Usage Match', IsActive = true);
        insert prod6;
        
        PricebookEntry pbe=new PricebookEntry(unitprice=7500,Product2Id=prod2.Id, Pricebook2Id=Test.getStandardPricebookId(), IsActive= true); 
        insert pbe; 
        PricebookEntry pbe2=new PricebookEntry(unitprice=7500,Product2Id=prod.Id, Pricebook2Id=Test.getStandardPricebookId(), IsActive= true); 
        insert pbe2;
        PricebookEntry pbe3=new PricebookEntry(unitprice=7500,Product2Id=prod3.Id, Pricebook2Id=Test.getStandardPricebookId(), IsActive= true); 
        insert pbe3;
        PricebookEntry pbe4=new PricebookEntry(unitprice=7500,Product2Id=prod4.Id, Pricebook2Id=Test.getStandardPricebookId(), IsActive= true); 
        insert pbe4;
        PricebookEntry pbe5=new PricebookEntry(unitprice=100,Product2Id=prod5.Id, Pricebook2Id=Test.getStandardPricebookId(), IsActive= true); 
        insert pbe5;
        PricebookEntry pbe6 = new PricebookEntry(unitprice=100,Product2Id=prod6.Id, Pricebook2Id=Test.getStandardPricebookId(), IsActive= true); 
        insert pbe6;
        
        TimeshareDetailsWithProduct.saveProductLineItem(prdList,opp.Id,Ts.Id, prod.Id,'1');
        TimeshareDetailsWithProduct.saveProductLineItem(prdList1,opp.Id,Ts.Id, prod4.Id,'1');
        TimeshareDetailsWithProduct.saveProductLineItemMTRC(prdList,opp.Id, prod.Id);
        TimeshareDetailsWithProduct.AllActiveProductList(opp.Id, Ts.Id);
        //TimeshareDetailsWithProduct.AllActivePTPProductList();
        TimeshareDetailsWithProduct.AllActiveMTRCProductList();
    }
    
    
    @isTest
	static void testSaveProductLineItem() {
        Test.startTest();
        
        // Step 1: Create Resort
        Resort__c r = new Resort__c(Name = 'Test Resort');
        insert r;
        
        // Step 2: Create Timeshare Records
        Timeshare__c ts1 = new Timeshare__c(
            Resort__c = r.Id, 
            Mortgage_Balance__c = 100, 
            Mortgage_Monthly_Payment__c = '5',
            Master_Record_Id__c = 'TestMaster123',
            MF_Amount__c = 10
        );
        insert ts1;
        
        // Step 3: Create an Opportunity
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = System.today() - 30,
            Timeshare_1__c = ts1.Id
        );
        insert opp;
        
        // Step 4: Create a Product and PricebookEntry
        Id standardPb = Test.getStandardPricebookId();
        Product2 product = new Product2(Name = 'Maintenance Fee Protection', IsActive = true);
        insert product;
        
        PricebookEntry pbe = new PricebookEntry(
            Product2Id = product.Id, 
            Pricebook2Id = standardPb, 
            UnitPrice = 50, 
            IsActive = true
        );
        insert pbe;
        
        // Step 5: Create a Sample Wrapper List for Invoking Method
        TimeshareDetailsWithProduct.productWrapper productWrapper = new TimeshareDetailsWithProduct.productWrapper();
        productWrapper.prd = product;
        productWrapper.selected = true;
        productWrapper.unitprice = 50;
        productWrapper.productMFMultiplier = 2;
        
        List<TimeshareDetailsWithProduct.productWrapper> wrapperList = new List<TimeshareDetailsWithProduct.productWrapper>{ productWrapper };
            
            // Step 6: Call the Method
            system.debug('wrapperList'+wrapperList);
            system.debug('opp.Id'+opp.Id);
            system.debug('ts1.Id'+ts1.Id);
            system.debug('product.Id'+product.Id);
            String result = TimeshareDetailsWithProduct.saveProductLineItem(wrapperList, opp.Id, ts1.Id, product.Id,'1');
        
        Test.stopTest();
        
        // Assert that the method executed successfully
        System.assertEquals('true', result, 'The method should return "true" if execution is successful.');
        
        // Verify that the Opportunity Line Item was inserted
        List<OpportunityLineItem> oliList = [
            SELECT Id, PricebookEntryId, OpportunityId 
            FROM OpportunityLineItem 
            WHERE OpportunityId = :opp.Id
        ];
        System.assertEquals(1, oliList.size(), 'Expected one OpportunityLineItem to be inserted.');
    }

    @isTest
    static void testSaveProductLineItemMTRC() {
        Test.startTest();

        // Step 1: Create Test Data
        Resort__c r = new Resort__c(Name = 'Test Resort');
        insert r;

        Opportunity opp = new Opportunity(
            Name = 'Test MTRC Opportunity',
            StageName = 'Prospecting',
            CloseDate = System.today() - 30
        );
        insert opp;

        Id standardPb = Test.getStandardPricebookId();
        Product2 product = new Product2(Name = 'MTRC Vida MFP Add On with Credits', IsActive = true);
        insert product;

        PricebookEntry pbe = new PricebookEntry(
            Product2Id = product.Id, 
            Pricebook2Id = standardPb, 
            UnitPrice = 50, 
            IsActive = true
        );
        insert pbe;

        // Step 2: Prepare Wrapper List
        TimeshareDetailsWithProduct.productWrapper productWrapper = new TimeshareDetailsWithProduct.productWrapper();
        productWrapper.prd = product;
        productWrapper.selected = true;
        productWrapper.unitprice = 100;
		productWrapper.ReasontoSellPickselectedValue = 'OTHER';
        
        List<TimeshareDetailsWithProduct.productWrapper> wrapperList = new List<TimeshareDetailsWithProduct.productWrapper>{ productWrapper };
        wrapperList.add(productWrapper);  
        
        // Step 3: Call the Method
        String result = TimeshareDetailsWithProduct.saveProductLineItemMTRC(wrapperList, opp.Id, product.Id);

        Test.stopTest();

        // Assert the method returned success
        System.assertEquals('true', result, 'The method should return "true" if execution is successful.');

        // Verify the Timeshare record was inserted
        List<Timeshare__c> timeshareList = [SELECT Id FROM Timeshare__c WHERE Master_Record_Id__c = 'null'];
        System.assert(timeshareList.size() > 0, 'A new Timeshare record should have been created.');


        
    }
    
    
    
    
 
        @isTest
	static void testSaveProductLineItem2() {
        Test.startTest();
        
        // Step 1: Create Resort
        Resort__c r = new Resort__c(Name = 'Test Resort');
        insert r;
        
        // Step 2: Create Timeshare Records
        Timeshare__c ts1 = new Timeshare__c(
            Resort__c = r.Id, 
            Mortgage_Balance__c = 100, 
            Mortgage_Monthly_Payment__c = '5',
            Master_Record_Id__c = 'TestMaster123',
            MF_Amount__c = 10,
            VIDA_File_Fee_Amount__c = 1
        );
        insert ts1;
        
        // Step 3: Create an Opportunity
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = System.today() - 30,
            Timeshare_2__c = ts1.Id
        );
        insert opp;
        
        // Step 4: Create a Product and PricebookEntry
        Id standardPb = Test.getStandardPricebookId();
        Product2 product = new Product2(Name = 'Maintenance Fee Protection', IsActive = true);
        insert product;
        
        PricebookEntry pbe = new PricebookEntry(
            Product2Id = product.Id, 
            Pricebook2Id = standardPb, 
            UnitPrice = 50, 
            IsActive = true
        );
        insert pbe;
        
        // Step 5: Create a Sample Wrapper List for Invoking Method
        TimeshareDetailsWithProduct.productWrapper productWrapper = new TimeshareDetailsWithProduct.productWrapper();
        productWrapper.prd = product;
        productWrapper.selected = true;
        productWrapper.unitprice = 50;
        productWrapper.productMFMultiplier = 2;
        
        List<TimeshareDetailsWithProduct.productWrapper> wrapperList = new List<TimeshareDetailsWithProduct.productWrapper>{ productWrapper };
            
            // Step 6: Call the Method
            system.debug('wrapperList'+wrapperList);
            system.debug('opp.Id'+opp.Id);
            system.debug('ts1.Id'+ts1.Id);
            system.debug('product.Id'+product.Id);
            String result = TimeshareDetailsWithProduct.saveProductLineItem(wrapperList, opp.Id, ts1.Id, product.Id,'2');
        
        Test.stopTest();
        
        // Assert that the method executed successfully
        System.assertEquals('true', result, 'The method should return "true" if execution is successful.');
        
        // Verify that the Opportunity Line Item was inserted
        List<OpportunityLineItem> oliList = [
            SELECT Id, PricebookEntryId, OpportunityId 
            FROM OpportunityLineItem 
            WHERE OpportunityId = :opp.Id
        ];
        System.assertEquals(1, oliList.size(), 'Expected one OpportunityLineItem to be inserted.');

        opp.Timeshare_2_OppProd_Id__c = oliList[0].Id;
        update opp;
        delete oliList;
        TimeshareDetailsWithProduct.timesharDelete(Ts1.Id, opp.Id,'2');
        
    }
    
    
    
        @isTest
	static void testSaveProductLineItem3() {
        Test.startTest();
        
        // Step 1: Create Resort
        Resort__c r = new Resort__c(Name = 'Test Resort');
        insert r;
        
        // Step 2: Create Timeshare Records
        Timeshare__c ts1 = new Timeshare__c(
            Resort__c = r.Id, 
            Mortgage_Balance__c = 100, 
            Mortgage_Monthly_Payment__c = '5',
            Master_Record_Id__c = 'TestMaster123',
            MF_Amount__c = 10
        );
        insert ts1;
        
        // Step 3: Create an Opportunity
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = System.today() - 30,
            Timeshare_3__c = ts1.Id
        );
        insert opp;
        
        // Step 4: Create a Product and PricebookEntry
        Id standardPb = Test.getStandardPricebookId();
        Product2 product = new Product2(Name = 'Maintenance Fee Protection', IsActive = true);
        insert product;
        
        PricebookEntry pbe = new PricebookEntry(
            Product2Id = product.Id, 
            Pricebook2Id = standardPb, 
            UnitPrice = 50, 
            IsActive = true
        );
        insert pbe;
        
        // Step 5: Create a Sample Wrapper List for Invoking Method
        TimeshareDetailsWithProduct.productWrapper productWrapper = new TimeshareDetailsWithProduct.productWrapper();
        productWrapper.prd = product;
        productWrapper.selected = true;
        productWrapper.unitprice = 50;
        productWrapper.productMFMultiplier = 2;
        
        List<TimeshareDetailsWithProduct.productWrapper> wrapperList = new List<TimeshareDetailsWithProduct.productWrapper>{ productWrapper };
            
            // Step 6: Call the Method
            system.debug('wrapperList'+wrapperList);
            system.debug('opp.Id'+opp.Id);
            system.debug('ts1.Id'+ts1.Id);
            system.debug('product.Id'+product.Id);
            String result = TimeshareDetailsWithProduct.saveProductLineItem(wrapperList, opp.Id, ts1.Id, product.Id,'3');
        
        Test.stopTest();
        
        // Assert that the method executed successfully
        System.assertEquals('true', result, 'The method should return "true" if execution is successful.');
        
        // Verify that the Opportunity Line Item was inserted
        List<OpportunityLineItem> oliList = [
            SELECT Id, PricebookEntryId, OpportunityId 
            FROM OpportunityLineItem 
            WHERE OpportunityId = :opp.Id
        ];
        System.assertEquals(1, oliList.size(), 'Expected one OpportunityLineItem to be inserted.');


        opp.Timeshare_3_OppProd_Id__c = oliList[0].Id;
        update opp;
        
        delete oliList;
        TimeshareDetailsWithProduct.timesharDelete(Ts1.Id, opp.Id,'3');
        
    }
    
    
    
        @isTest
	static void testSaveProductLineItem4() {
        Test.startTest();
        
        // Step 1: Create Resort
        Resort__c r = new Resort__c(Name = 'Test Resort');
        insert r;
        
        // Step 2: Create Timeshare Records
        Timeshare__c ts1 = new Timeshare__c(
            Resort__c = r.Id, 
            Mortgage_Balance__c = 100, 
            Mortgage_Monthly_Payment__c = '5',
            Master_Record_Id__c = 'TestMaster123',
            MF_Amount__c = 10
        );
        insert ts1;
        
        // Step 3: Create an Opportunity
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = System.today() - 30,
            Timeshare_4__c = ts1.Id
        );
        insert opp;
        
        // Step 4: Create a Product and PricebookEntry
        Id standardPb = Test.getStandardPricebookId();
        Product2 product = new Product2(Name = 'Maintenance Fee Protection', IsActive = true);
        insert product;
        
        PricebookEntry pbe = new PricebookEntry(
            Product2Id = product.Id, 
            Pricebook2Id = standardPb, 
            UnitPrice = 50, 
            IsActive = true
        );
        insert pbe;
        
        // Step 5: Create a Sample Wrapper List for Invoking Method
        TimeshareDetailsWithProduct.productWrapper productWrapper = new TimeshareDetailsWithProduct.productWrapper();
        productWrapper.prd = product;
        productWrapper.selected = true;
        productWrapper.unitprice = 50;
        productWrapper.productMFMultiplier = 2;
        
        List<TimeshareDetailsWithProduct.productWrapper> wrapperList = new List<TimeshareDetailsWithProduct.productWrapper>{ productWrapper };
            
            // Step 6: Call the Method
            system.debug('wrapperList'+wrapperList);
            system.debug('opp.Id'+opp.Id);
            system.debug('ts1.Id'+ts1.Id);
            system.debug('product.Id'+product.Id);
            String result = TimeshareDetailsWithProduct.saveProductLineItem(wrapperList, opp.Id, ts1.Id, product.Id,'4');
        
        Test.stopTest();
        
        // Assert that the method executed successfully
        System.assertEquals('true', result, 'The method should return "true" if execution is successful.');
        
        // Verify that the Opportunity Line Item was inserted
        List<OpportunityLineItem> oliList = [
            SELECT Id, PricebookEntryId, OpportunityId 
            FROM OpportunityLineItem 
            WHERE OpportunityId = :opp.Id
        ];
        System.assertEquals(1, oliList.size(), 'Expected one OpportunityLineItem to be inserted.');

        opp.Timeshare_4_OppProd_Id__c = oliList[0].Id;
        update opp;

        delete oliList;
        
        TimeshareDetailsWithProduct.timesharDelete(Ts1.Id, opp.Id,'4');
        
    }
    
    
    
        @isTest
	static void testSaveProductLineItem5() {
        Test.startTest();
        
        // Step 1: Create Resort
        Resort__c r = new Resort__c(Name = 'Test Resort');
        insert r;
        
        // Step 2: Create Timeshare Records
        Timeshare__c ts1 = new Timeshare__c(
            Resort__c = r.Id, 
            Mortgage_Balance__c = 100, 
            Mortgage_Monthly_Payment__c = '5',
            Master_Record_Id__c = 'TestMaster123',
            MF_Amount__c = 10
        );
        insert ts1;
        
        // Step 3: Create an Opportunity
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = System.today() - 30,
            Timeshare_5__c = ts1.Id
        );
        insert opp;
        
        // Step 4: Create a Product and PricebookEntry
        Id standardPb = Test.getStandardPricebookId();
        Product2 product = new Product2(Name = 'Maintenance Fee Protection', IsActive = true);
        insert product;
        
        PricebookEntry pbe = new PricebookEntry(
            Product2Id = product.Id, 
            Pricebook2Id = standardPb, 
            UnitPrice = 50, 
            IsActive = true
        );
        insert pbe;
        
        // Step 5: Create a Sample Wrapper List for Invoking Method
        TimeshareDetailsWithProduct.productWrapper productWrapper = new TimeshareDetailsWithProduct.productWrapper();
        productWrapper.prd = product;
        productWrapper.selected = true;
        productWrapper.unitprice = 50;
        productWrapper.productMFMultiplier = 2;
        
        List<TimeshareDetailsWithProduct.productWrapper> wrapperList = new List<TimeshareDetailsWithProduct.productWrapper>{ productWrapper };
            
            // Step 6: Call the Method
            system.debug('wrapperList'+wrapperList);
            system.debug('opp.Id'+opp.Id);
            system.debug('ts1.Id'+ts1.Id);
            system.debug('product.Id'+product.Id);
            String result = TimeshareDetailsWithProduct.saveProductLineItem(wrapperList, opp.Id, ts1.Id, product.Id,'5');
        
        Test.stopTest();
        
        // Assert that the method executed successfully
        System.assertEquals('true', result, 'The method should return "true" if execution is successful.');
        
        // Verify that the Opportunity Line Item was inserted
        List<OpportunityLineItem> oliList = [
            SELECT Id, PricebookEntryId, OpportunityId 
            FROM OpportunityLineItem 
            WHERE OpportunityId = :opp.Id
        ];
        System.assertEquals(1, oliList.size(), 'Expected one OpportunityLineItem to be inserted.');

        opp.Timeshare_5_OppProd_Id__c = oliList[0].Id;
        update opp;
        
        delete oliList;
        TimeshareDetailsWithProduct.timesharDelete(Ts1.Id, opp.Id,'5');

    }
    
    
    
        @isTest
	static void testSaveProductLineItem6() {
        Test.startTest();
        
        // Step 1: Create Resort
        Resort__c r = new Resort__c(Name = 'Test Resort');
        insert r;
        
        // Step 2: Create Timeshare Records
        Timeshare__c ts1 = new Timeshare__c(
            Resort__c = r.Id, 
            Mortgage_Balance__c = 100, 
            Mortgage_Monthly_Payment__c = '5',
            Master_Record_Id__c = 'TestMaster123',
            MF_Amount__c = 10
        );
        insert ts1;
        
        // Step 3: Create an Opportunity
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = System.today() - 30,
            Timeshare_6__c = ts1.Id
        );
        insert opp;
        
        // Step 4: Create a Product and PricebookEntry
        Id standardPb = Test.getStandardPricebookId();
        Product2 product = new Product2(Name = 'Maintenance Fee Protection', IsActive = true);
        insert product;
        
        PricebookEntry pbe = new PricebookEntry(
            Product2Id = product.Id, 
            Pricebook2Id = standardPb, 
            UnitPrice = 50, 
            IsActive = true
        );
        insert pbe;
        
        // Step 5: Create a Sample Wrapper List for Invoking Method
        TimeshareDetailsWithProduct.productWrapper productWrapper = new TimeshareDetailsWithProduct.productWrapper();
        productWrapper.prd = product;
        productWrapper.selected = true;
        productWrapper.unitprice = 50;
        productWrapper.productMFMultiplier = 2;
        
        List<TimeshareDetailsWithProduct.productWrapper> wrapperList = new List<TimeshareDetailsWithProduct.productWrapper>{ productWrapper };
            
            // Step 6: Call the Method
            system.debug('wrapperList'+wrapperList);
            system.debug('opp.Id'+opp.Id);
            system.debug('ts1.Id'+ts1.Id);
            system.debug('product.Id'+product.Id);
            String result = TimeshareDetailsWithProduct.saveProductLineItem(wrapperList, opp.Id, ts1.Id, product.Id,'6');
        
        Test.stopTest();
        
        // Assert that the method executed successfully
        System.assertEquals('true', result, 'The method should return "true" if execution is successful.');
        
        // Verify that the Opportunity Line Item was inserted
        List<OpportunityLineItem> oliList = [
            SELECT Id, PricebookEntryId, OpportunityId 
            FROM OpportunityLineItem 
            WHERE OpportunityId = :opp.Id
        ];
        System.assertEquals(1, oliList.size(), 'Expected one OpportunityLineItem to be inserted.');
        
        opp.Timeshare_6_OppProd_Id__c = oliList[0].Id;
        update opp;
        
        delete oliList;
        TimeshareDetailsWithProduct.timesharDelete(Ts1.Id, opp.Id,'6');
        
        
    }
    
    
    
        @isTest
	static void testSaveProductLineItem7() {
        Test.startTest();
        
        // Step 1: Create Resort
        Resort__c r = new Resort__c(Name = 'Test Resort');
        insert r;
        
        // Step 2: Create Timeshare Records
        Timeshare__c ts1 = new Timeshare__c(
            Resort__c = r.Id, 
            Mortgage_Balance__c = 100, 
            Mortgage_Monthly_Payment__c = '5',
            Master_Record_Id__c = 'TestMaster123',
            MF_Amount__c = 10
        );
        insert ts1;
        
        // Step 3: Create an Opportunity
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = System.today() - 30,
            Timeshare_7__c = ts1.Id
        );
        insert opp;
        
        // Step 4: Create a Product and PricebookEntry
        Id standardPb = Test.getStandardPricebookId();
        Product2 product = new Product2(Name = 'Maintenance Fee Protection', IsActive = true);
        insert product;
        
        PricebookEntry pbe = new PricebookEntry(
            Product2Id = product.Id, 
            Pricebook2Id = standardPb, 
            UnitPrice = 50, 
            IsActive = true
        );
        insert pbe;
        
        // Step 5: Create a Sample Wrapper List for Invoking Method
        TimeshareDetailsWithProduct.productWrapper productWrapper = new TimeshareDetailsWithProduct.productWrapper();
        productWrapper.prd = product;
        productWrapper.selected = true;
        productWrapper.unitprice = 50;
        productWrapper.productMFMultiplier = 2;
        
        List<TimeshareDetailsWithProduct.productWrapper> wrapperList = new List<TimeshareDetailsWithProduct.productWrapper>{ productWrapper };
            
            // Step 6: Call the Method
            system.debug('wrapperList'+wrapperList);
            system.debug('opp.Id'+opp.Id);
            system.debug('ts1.Id'+ts1.Id);
            system.debug('product.Id'+product.Id);
            String result = TimeshareDetailsWithProduct.saveProductLineItem(wrapperList, opp.Id, ts1.Id, product.Id,'7');
        
        Test.stopTest();
        
        // Assert that the method executed successfully
        System.assertEquals('true', result, 'The method should return "true" if execution is successful.');
        
        // Verify that the Opportunity Line Item was inserted
        List<OpportunityLineItem> oliList = [
            SELECT Id, PricebookEntryId, OpportunityId 
            FROM OpportunityLineItem 
            WHERE OpportunityId = :opp.Id
        ];
        System.assertEquals(1, oliList.size(), 'Expected one OpportunityLineItem to be inserted.');
        
        opp.Timeshare_7_OppProd_Id__c = oliList[0].Id;
        update opp;
        
        delete oliList;
        TimeshareDetailsWithProduct.timesharDelete(Ts1.Id, opp.Id,'7');
        

    }
    
    
    
    
        @isTest
	static void testSaveProductLineItem8() {
        Test.startTest();
        
        // Step 1: Create Resort
        Resort__c r = new Resort__c(Name = 'Test Resort');
        insert r;
        
        // Step 2: Create Timeshare Records
        Timeshare__c ts1 = new Timeshare__c(
            Resort__c = r.Id, 
            Mortgage_Balance__c = 100, 
            Mortgage_Monthly_Payment__c = '5',
            Master_Record_Id__c = 'TestMaster123',
            MF_Amount__c = 10
        );
        insert ts1;
        
        // Step 3: Create an Opportunity
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = System.today() - 30,
            Timeshare_8__c = ts1.Id
        );
        insert opp;
        
        // Step 4: Create a Product and PricebookEntry
        Id standardPb = Test.getStandardPricebookId();
        Product2 product = new Product2(Name = 'Maintenance Fee Protection', IsActive = true);
        insert product;
        
        PricebookEntry pbe = new PricebookEntry(
            Product2Id = product.Id, 
            Pricebook2Id = standardPb, 
            UnitPrice = 50, 
            IsActive = true
        );
        insert pbe;
        
        // Step 5: Create a Sample Wrapper List for Invoking Method
        TimeshareDetailsWithProduct.productWrapper productWrapper = new TimeshareDetailsWithProduct.productWrapper();
        productWrapper.prd = product;
        productWrapper.selected = true;
        productWrapper.unitprice = 50;
        productWrapper.productMFMultiplier = 2;
        
        List<TimeshareDetailsWithProduct.productWrapper> wrapperList = new List<TimeshareDetailsWithProduct.productWrapper>{ productWrapper };
            
            // Step 6: Call the Method
            system.debug('wrapperList'+wrapperList);
            system.debug('opp.Id'+opp.Id);
            system.debug('ts1.Id'+ts1.Id);
            system.debug('product.Id'+product.Id);
            String result = TimeshareDetailsWithProduct.saveProductLineItem(wrapperList, opp.Id, ts1.Id, product.Id,'8');
        
        Test.stopTest();
        
        // Assert that the method executed successfully
        System.assertEquals('true', result, 'The method should return "true" if execution is successful.');
        
        // Verify that the Opportunity Line Item was inserted
        List<OpportunityLineItem> oliList = [
            SELECT Id, PricebookEntryId, OpportunityId 
            FROM OpportunityLineItem 
            WHERE OpportunityId = :opp.Id
        ];
        System.assertEquals(1, oliList.size(), 'Expected one OpportunityLineItem to be inserted.');
    
        opp.Timeshare_8_OppProd_Id__c = oliList[0].Id;
        update opp;
        
        delete oliList;
        TimeshareDetailsWithProduct.timesharDelete(Ts1.Id, opp.Id,'8');
        
	}
    
    
    
        @isTest
	static void testSaveProductLineItem9() {
        Test.startTest();
        
        // Step 1: Create Resort
        Resort__c r = new Resort__c(Name = 'Test Resort');
        insert r;
        
        // Step 2: Create Timeshare Records
        Timeshare__c ts1 = new Timeshare__c(
            Resort__c = r.Id, 
            Mortgage_Balance__c = 100, 
            Mortgage_Monthly_Payment__c = '5',
            Master_Record_Id__c = 'TestMaster123',
            MF_Amount__c = 10
        );
        insert ts1;
        
        // Step 3: Create an Opportunity
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = System.today() - 30,
            Timeshare_9__c = ts1.Id
        );
        insert opp;
        
        // Step 4: Create a Product and PricebookEntry
        Id standardPb = Test.getStandardPricebookId();
        Product2 product = new Product2(Name = 'Maintenance Fee Protection', IsActive = true);
        insert product;
        
        PricebookEntry pbe = new PricebookEntry(
            Product2Id = product.Id, 
            Pricebook2Id = standardPb, 
            UnitPrice = 50, 
            IsActive = true
        );
        insert pbe;
        
        // Step 5: Create a Sample Wrapper List for Invoking Method
        TimeshareDetailsWithProduct.productWrapper productWrapper = new TimeshareDetailsWithProduct.productWrapper();
        productWrapper.prd = product;
        productWrapper.selected = true;
        productWrapper.unitprice = 50;
        productWrapper.productMFMultiplier = 2;
        
        List<TimeshareDetailsWithProduct.productWrapper> wrapperList = new List<TimeshareDetailsWithProduct.productWrapper>{ productWrapper };
            
            // Step 6: Call the Method
            system.debug('wrapperList'+wrapperList);
            system.debug('opp.Id'+opp.Id);
            system.debug('ts1.Id'+ts1.Id);
            system.debug('product.Id'+product.Id);
            String result = TimeshareDetailsWithProduct.saveProductLineItem(wrapperList, opp.Id, ts1.Id, product.Id,'9');
        
        Test.stopTest();
        
        // Assert that the method executed successfully
        System.assertEquals('true', result, 'The method should return "true" if execution is successful.');
        
        // Verify that the Opportunity Line Item was inserted
        List<OpportunityLineItem> oliList = [
            SELECT Id, PricebookEntryId, OpportunityId 
            FROM OpportunityLineItem 
            WHERE OpportunityId = :opp.Id
        ];
        System.assertEquals(1, oliList.size(), 'Expected one OpportunityLineItem to be inserted.');
        
        opp.Timeshare_9_OppProd_Id__c = oliList[0].Id;
        update opp;
        
        delete oliList;
        TimeshareDetailsWithProduct.timesharDelete(Ts1.Id, opp.Id,'9');
        
    }
    
    
    
        @isTest
	static void testSaveProductLineItem10() { 
        Test.startTest();
        
        // Step 1: Create Resort
        Resort__c r = new Resort__c(Name = 'Test Resort');
        insert r;
        
        // Step 2: Create Timeshare Records
        Timeshare__c ts1 = new Timeshare__c(
            Resort__c = r.Id, 
            Mortgage_Balance__c = 100, 
            Mortgage_Monthly_Payment__c = '5',
            Master_Record_Id__c = 'TestMaster123',
            MF_Amount__c = 10
        );
        insert ts1;
        
        // Step 3: Create an Opportunity
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = System.today() - 30,
            Timeshare_10__c = ts1.Id
        );
        insert opp;
        
        // Step 4: Create a Product and PricebookEntry
        Id standardPb = Test.getStandardPricebookId();
        Product2 product = new Product2(Name = 'Maintenance Fee Protection', IsActive = true);
        insert product;
        
        PricebookEntry pbe = new PricebookEntry(
            Product2Id = product.Id, 
            Pricebook2Id = standardPb, 
            UnitPrice = 50, 
            IsActive = true
        );
        insert pbe;
        
        // Step 5: Create a Sample Wrapper List for Invoking Method
        TimeshareDetailsWithProduct.productWrapper productWrapper = new TimeshareDetailsWithProduct.productWrapper();
        productWrapper.prd = product;
        productWrapper.selected = true;
        productWrapper.unitprice = 50;
        productWrapper.productMFMultiplier = 2;
        
        List<TimeshareDetailsWithProduct.productWrapper> wrapperList = new List<TimeshareDetailsWithProduct.productWrapper>{ productWrapper };
            
            // Step 6: Call the Method
            system.debug('wrapperList'+wrapperList);
            system.debug('opp.Id'+opp.Id);
            system.debug('ts1.Id'+ts1.Id);
            system.debug('product.Id'+product.Id);
            String result = TimeshareDetailsWithProduct.saveProductLineItem(wrapperList, opp.Id, ts1.Id, product.Id,'10');
        
        Test.stopTest();
        
        // Assert that the method executed successfully
        System.assertEquals('true', result, 'The method should return "true" if execution is successful.');
        
        // Verify that the Opportunity Line Item was inserted
        List<OpportunityLineItem> oliList = [
            SELECT Id, PricebookEntryId, OpportunityId 
            FROM OpportunityLineItem 
            WHERE OpportunityId = :opp.Id
        ];
        System.assertEquals(1, oliList.size(), 'Expected one OpportunityLineItem to be inserted.');
        
        opp.Timeshare_10_OppProd_Id__c = oliList[0].Id;
        update opp;
        
        delete oliList;
        TimeshareDetailsWithProduct.timesharDelete(Ts1.Id, opp.Id,'10');
        
    }
    
    
 
  //      List<Product2> productList = [select id,Name,ProductCode,Description,Family from product2 where ID IN:activeProductId];
    static testMethod void TimeshareDetailsCtrl_Test12(){
 
        Id OppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Social_Ad_Sales').getRecordTypeId();
        
        Resort__c r = new Resort__c();
        r.name = 'test';
        insert r;
        
        Timeshare__c Ts = new Timeshare__c();
        Ts.Resort__c = r.Id;
        Ts.Mortgage_Balance__c = 100;
        Ts.Mortgage_Monthly_Payment__c = '5';
        Ts.Master_Record_Id__c = 'Mitul1234';
        
        insert Ts;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp';
        opp.Timeshare_1__c = Ts.Id;
        
        opp.StageName = 'Prospecting';
        opp.CloseDate = system.Today()-30;
 		opp.RecordTypeId = OppRecordTypeId;
        insert opp;
        
        // without timeshare details
        Opportunity opp1 = new Opportunity();
        opp1.Name = 'Test Opp';
        
        opp1.StageName = 'Prospecting';
        opp1.CloseDate = system.Today()+3;
        insert opp1;
        
        TimeshareDetailsWithProduct.timeshareWrapper tss = new TimeshareDetailsWithProduct.timeshareWrapper();
        TimeshareDetailsWithProduct.productWrapper prd2 = new TimeshareDetailsWithProduct.productWrapper();
        
        prd2.selected = true;
        prd2.unitprice = 7000;
        prd2.ReasontoSellPickselectedValue = 'OTHER';
        
        TimeshareDetailsWithProduct.productWrapper prd3 = new TimeshareDetailsWithProduct.productWrapper();
        
        prd3.selected = true;
        prd3.unitprice = 7000;
        prd3.ReasontoSellPickselectedValue = 'OTHER';
        prd3.vendorDiscount = 0;
        List<TimeshareDetailsWithProduct.productWrapper> prdList = new List<TimeshareDetailsWithProduct.productWrapper>();
        prdList.add(prd2); 
        List<TimeshareDetailsWithProduct.productWrapper> prdList1 = new List<TimeshareDetailsWithProduct.productWrapper>();
        prdList1.add(prd3);  
        
        
        Pricebook2 pb = new Pricebook2(Name = 'Standard Price Book', Description = 'Price Book Products', IsActive = true );
        insert pb;
        Product2 prod = new Product2(Name = 'WWPT Product', IsActive = true);
        insert prod;
        Product2 prod2 = new Product2(Name = 'Premier Travel Pass', IsActive = true);
        insert prod2;
        Product2 prod3 = new Product2(Name = 'My Travel Rewards Club', IsActive = true);
        insert prod3;
        Product2 prod4 = new Product2(Name = 'Equity Product', IsActive = true);
        insert prod4;
        Product2 prod5 = new Product2(Name = 'Maintenance Fee Protection', IsActive = true);
        insert prod5;
        
        PricebookEntry pbe=new PricebookEntry(unitprice=7500,Product2Id=prod2.Id, Pricebook2Id=Test.getStandardPricebookId(), IsActive= true); 
        insert pbe; 
        PricebookEntry pbe2=new PricebookEntry(unitprice=7500,Product2Id=prod.Id, Pricebook2Id=Test.getStandardPricebookId(), IsActive= true); 
        insert pbe2;
        PricebookEntry pbe3=new PricebookEntry(unitprice=7500,Product2Id=prod3.Id, Pricebook2Id=Test.getStandardPricebookId(), IsActive= true); 
        insert pbe3;
        PricebookEntry pbe4=new PricebookEntry(unitprice=7500,Product2Id=prod4.Id, Pricebook2Id=Test.getStandardPricebookId(), IsActive= true); 
        insert pbe4;
        PricebookEntry pbe5=new PricebookEntry(unitprice=100,Product2Id=prod5.Id, Pricebook2Id=Test.getStandardPricebookId(), IsActive= true); 
        insert pbe5;
        
        TimeshareDetailsWithProduct.saveProductLineItem(prdList,opp.Id,Ts.Id, prod.Id,'1');
        TimeshareDetailsWithProduct.saveProductLineItem(prdList1,opp.Id,Ts.Id, prod4.Id,'1');
        TimeshareDetailsWithProduct.saveProductLineItemMTRC(prdList,opp.Id, prod.Id);
        TimeshareDetailsWithProduct.AllActiveProductList(opp.Id, Ts.Id);
        //TimeshareDetailsWithProduct.AllActivePTPProductList();
        TimeshareDetailsWithProduct.AllActiveMTRCProductList();
    }

    
    @isTest
    static void testProductOrderAndMultiplierLogic() {
        
        Test.startTest();
        
        //
        // 1. Setup: Create basic objects
        //
        Id standardPb = Test.getStandardPricebookId();
        
        // Record Type: Social Ad Sales
        Id sasRtId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName()
            .get('Social_Ad_Sales').getRecordTypeId();
        
        Resort__c r = new Resort__c(Name = 'Test Resort');
        insert r;
        
        Timeshare__c ts = new Timeshare__c(
            Resort__c = r.Id,
            Mortgage_Balance__c = 100,
            Mortgage_Monthly_Payment__c = '5',
            Master_Record_Id__c = 'MFPMULT'
        );
        insert ts;
        
        Opportunity opp = new Opportunity(
            Name = 'Test MF Multiplier Opp',
            StageName = 'Prospecting',
            CloseDate = System.today(),
            RecordTypeId = sasRtId,
            Timeshare_1__c = ts.Id
        );
        insert opp;
        
        //
        // 2. Create the exact products that the comparator & MFP logic uses
        //
/*
        List<String> prodNames = new List<String>{
            '$1498 Resale Subscription - ( NO Title Fee Credit ) Balance Paid by Seller at Closing',
                '$1998 Resale Subscription - Title Fee Credit/Balance Paid by Seller at Closing',
                'Maintenance Fee Protection - Travel Cash',
                'SMTN Complimentary Ad - Without Closing Credit',
                'Maintenance Fee Protection'
};
*/
        //SAS-55
        List<String> prodNames = new List<String>{
            'CV Sapphire',
                'Trade In Property',
                'Trade In Property With Mortgage'
                /*,
                '$1998 Resale Subscription - Title Fee Credit/Balance Paid by Seller at Closing',
                'Maintenance Fee Protection - Travel Cash'
                */
                };
                    
        List<Product2> products = new List<Product2>();
        for (String pn : prodNames) {
            products.add(new Product2(Name = pn, IsActive = true));
        }
        insert products;
        
        // Add the PricebookEntries
        List<PricebookEntry> pbes = new List<PricebookEntry>();
        for (Product2 p : products) {
            pbes.add(new PricebookEntry(
                Product2Id = p.Id,
                Pricebook2Id = standardPb,
                UnitPrice = 100,
                IsActive = true
            ));
        }
        insert pbes;
        
        //
        // 3. Call the method under test
        //
        List<TimeshareDetailsWithProduct.productWrapper> outList =
            TimeshareDetailsWithProduct.AllActiveProductList(opp.Id, ts.Id);
        
        System.assert(outList.size() == 3, 'Expected 2 products back');
        
        //
        // 4. Validate the SORT ORDER (Comparator)
        //
        System.assertEquals(
            'CV Sapphire',
            outList[0].prd.Name
        );
        System.assertEquals(
            'Trade In Property',
            outList[1].prd.Name
        );
/*        
        System.assertEquals(
            '$1998 Resale Subscription - Title Fee Credit/Balance Paid by Seller at Closing',
            outList[2].prd.Name
        );
        System.assertEquals(
            'Maintenance Fee Protection - Travel Cash',
            outList[3].prd.Name
        );
  */      
/*
          System.assertEquals(
            'Maintenance Fee Protection',
            outList[4].prd.Name
        );
   */     
        //
        // 5. Validate the MFP MULTIPLIER LOGIC
        //
        
        // → Travel Cash case (SAS → multiplier = 1.5)
        //TimeshareDetailsWithProduct.productWrapper travelCash =
        //    outList[3];
        //System.assertEquals(1.5, travelCash.productMFMultiplier);
        
/*        
        // → Maintenance Fee Protection (SAS → multiplier = 2)
        TimeshareDetailsWithProduct.productWrapper mfp =
            outList[4];
        System.assertEquals(2, mfp.productMFMultiplier);
  */      
        // → One of the Resale Subscriptions (SAS → ELSE → null)
        TimeshareDetailsWithProduct.productWrapper resale =
            outList[0];
        System.assertEquals(null, resale.productMFMultiplier);
        
        Test.stopTest();
    }

    
    //                else if(getProductName.get(productId) == 'Trade In Property' && timeshareList.size()>0 && timeshareList != null)
        @isTest
	static void testSaveProductLineItem13() { 
        Test.startTest();
        
        // Step 1: Create Resort
        Resort__c r = new Resort__c(Name = 'Test Resort');
        insert r;
        
        // Step 2: Create Timeshare Records
        Timeshare__c ts1 = new Timeshare__c(
            Resort__c = r.Id, 
            Mortgage_Balance__c = 100, 
            Mortgage_Monthly_Payment__c = '5',
            Master_Record_Id__c = 'TestMaster123',
            MF_Amount__c = 10,
            Trade_In_Value__c = 10
        );
        insert ts1;

        // Step : Create an Account
        Account acc = new Account(Name = 'Test Account32',Affiliated_Id__c = 1002469, Enrollment_Date__c = system.today().addDays(-15), email__c = 'test@gmail.com',Preferred_Language__c = 'ENG');
        insert acc;
        
        // Step 3: Create an Opportunity
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = System.today() - 30,
            Timeshare_10__c = ts1.Id,
            Accountid = acc.Id
        );
        insert opp;
        
        // Step 4: Create a Product and PricebookEntry
        Id standardPb = Test.getStandardPricebookId();
        Product2 product = new Product2(Name = 'Trade In Property', IsActive = true);
        insert product;
        
        PricebookEntry pbe = new PricebookEntry(
            Product2Id = product.Id, 
            Pricebook2Id = standardPb, 
            UnitPrice = 50, 
            IsActive = true
        );
        insert pbe;
        
        // Step 5: Create a Sample Wrapper List for Invoking Method
        TimeshareDetailsWithProduct.productWrapper productWrapper = new TimeshareDetailsWithProduct.productWrapper();
        productWrapper.prd = product;
        productWrapper.selected = true;
        productWrapper.unitprice = 50;
        productWrapper.productMFMultiplier = 2;
        
        List<TimeshareDetailsWithProduct.productWrapper> wrapperList = new List<TimeshareDetailsWithProduct.productWrapper>{ productWrapper };
            
            // Step 6: Call the Method
            system.debug('wrapperList'+wrapperList);
            system.debug('opp.Id'+opp.Id);
            system.debug('ts1.Id'+ts1.Id);
            system.debug('product.Id'+product.Id);
            String result = TimeshareDetailsWithProduct.saveProductLineItem(wrapperList, opp.Id, ts1.Id, product.Id,'10');
        
        Test.stopTest();
        
        // Assert that the method executed successfully
        System.assertEquals('true', result, 'The method should return "true" if execution is successful.');

        /*
        // Verify that the Opportunity Line Item was inserted
        List<OpportunityLineItem> oliList = [
            SELECT Id, PricebookEntryId, OpportunityId 
            FROM OpportunityLineItem 
            WHERE OpportunityId = :opp.Id
        ];
        System.assertEquals(1, oliList.size(), 'Expected one OpportunityLineItem to be inserted.');

        opp.Timeshare_10_OppProd_Id__c = oliList[0].Id;
        update opp;
        
        delete oliList;
        TimeshareDetailsWithProduct.timesharDelete(Ts1.Id, opp.Id,'10');
        */
        
    }
    
    @isTest
    static void testSaveProductLineItemSapphireUsageMatch() {
        Test.startTest();
        
        // Step 1: Create Resort
        Resort__c r = new Resort__c(Name = 'Test Resort');
        insert r;
        
        // Step 2: Create Timeshare Records
        Timeshare__c ts1 = new Timeshare__c(
            Resort__c = r.Id, 
            Mortgage_Balance__c = 100, 
            Mortgage_Monthly_Payment__c = '5',
            Master_Record_Id__c = 'TestMaster123',
            MF_Amount__c = 10,
    		VIDA_File_Fee_Amount__c = 100
        );
        insert ts1;
        
        Id membershipAddonId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Membership_Add_On').getRecordTypeId();
        
        // Step 3: Create an Opportunity
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'New',
            CloseDate = System.today() - 30,
            Timeshare_1__c = ts1.Id,
            recordtypeid = membershipAddonId
        );
        insert opp;
        
        // Step 4: Create a Product and PricebookEntry
        Id standardPb = Test.getStandardPricebookId();
        Product2 product = new Product2(Name = 'Sapphire Usage Match', IsActive = true);
        insert product;
        
        PricebookEntry pbe = new PricebookEntry(
            Product2Id = product.Id, 
            Pricebook2Id = standardPb, 
            UnitPrice = 50, 
            IsActive = true
        );
        insert pbe;
        
        // Step 5: Create a Sample Wrapper List for Invoking Method
        TimeshareDetailsWithProduct.productWrapper productWrapper = new TimeshareDetailsWithProduct.productWrapper();
        productWrapper.prd = product;
        productWrapper.selected = true;
        productWrapper.unitprice = 50;
        productWrapper.productMFMultiplier = 2;
        
        List<TimeshareDetailsWithProduct.productWrapper> wrapperList = new List<TimeshareDetailsWithProduct.productWrapper>{ productWrapper };
            
            // Step 6: Call the Method
            system.debug('wrapperList'+wrapperList);
        system.debug('opp.Id'+opp.Id);
        system.debug('ts1.Id'+ts1.Id);
        system.debug('product.Id'+product.Id);
        String result = TimeshareDetailsWithProduct.saveProductLineItem(wrapperList, opp.Id, ts1.Id, product.Id,'1');
        
        Test.stopTest();
        
        // Assert that the method executed successfully
        System.assertEquals('true', result, 'The method should return "true" if execution is successful.');
        
        // Verify that the Opportunity Line Item was inserted
        List<OpportunityLineItem> oliList = [
            SELECT Id, PricebookEntryId, OpportunityId 
            FROM OpportunityLineItem 
            WHERE OpportunityId = :opp.Id
        ];
        System.assertEquals(1, oliList.size(), 'Expected one OpportunityLineItem to be inserted.');
    }
    
}