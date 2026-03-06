@isTest
public class TimeShareDatatableHandlerTest {
    
    
    @isTest
    static void test1() {
        
        Resort__c r = new Resort__c();
        r.name = 'test';
        insert r;
        
     Timeshare__c Ts2 = new Timeshare__c();
        Ts2.Resort__c = r.Id;
        Ts2.Mortgage_Balance__c = 100;
        Ts2.Mortgage_Monthly_Payment__c = '5';
        Ts2.Master_Record_Id__c = 'Mitul1234';
        insert Ts2;
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp';
       
        opp.StageName = 'Prospecting';
        opp.CloseDate = system.Today()-30;
        insert opp;
        
        test.startTest();
        TimeShareDatatableHandler.addToOpportunity(opp.id,Ts2.Id);
        TimeShareDatatableHandler.getTimeShare(opp.id);
        delete opp;
        test.stopTest();
    }
    
      @isTest
    static void test2() {
        
        Resort__c r = new Resort__c();
        r.name = 'test';
        insert r;
        
     Timeshare__c Ts2 = new Timeshare__c();
        Ts2.Resort__c = r.Id;
        Ts2.Mortgage_Balance__c = 100;
        Ts2.Mortgage_Monthly_Payment__c = '5';
        Ts2.Master_Record_Id__c = 'Mitul1234';
        insert Ts2;
        
        Timeshare__c Ts3 = new Timeshare__c();
        Ts3.Resort__c = r.Id;
        Ts3.Mortgage_Balance__c = 100;
        Ts3.Mortgage_Monthly_Payment__c = '5';
        Ts3.Master_Record_Id__c = 'Mitul1234';
        insert Ts3;
        
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp';
       opp.Timeshare_1__c = Ts2.Id;
        opp.StageName = 'Prospecting';
        opp.CloseDate = system.Today()-30;
        insert opp;
        
        test.startTest();
        TimeShareDatatableHandler.addToOpportunity(opp.id,Ts3.Id);
        TimeShareDatatableHandler.getTimeShare(opp.id);
        delete opp;
        test.stopTest();
    }
    
    
    @isTest
    static void test3() {
        
        Resort__c r = new Resort__c();
        r.name = 'test';
        insert r;
        
     Timeshare__c Ts2 = new Timeshare__c();
        Ts2.Resort__c = r.Id;
        Ts2.Mortgage_Balance__c = 100;
        Ts2.Mortgage_Monthly_Payment__c = '5';
        Ts2.Master_Record_Id__c = 'Mitul1234';
        insert Ts2;
        
        Timeshare__c Ts3 = new Timeshare__c();
        Ts3.Resort__c = r.Id;
        Ts3.Mortgage_Balance__c = 100;
        Ts3.Mortgage_Monthly_Payment__c = '5';
        Ts3.Master_Record_Id__c = 'Mitul1234';
        insert Ts3;
        
        Timeshare__c Ts4 = new Timeshare__c();
        Ts4.Resort__c = r.Id;
        Ts4.Mortgage_Balance__c = 100;
        Ts4.Mortgage_Monthly_Payment__c = '5';
        Ts4.Master_Record_Id__c = 'Mitul1234';
        insert Ts4;
        
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp';
       opp.Timeshare_1__c = Ts2.Id;
        opp.Timeshare_2__c = Ts3.Id;
        opp.StageName = 'Prospecting';
        opp.CloseDate = system.Today()-30;
        insert opp;
        
        test.startTest();
        TimeShareDatatableHandler.addToOpportunity(opp.id,Ts4.Id);
        TimeShareDatatableHandler.getTimeShare(opp.id);
        delete opp;
        test.stopTest();
    }
    
    @isTest
    static void test4() {
        
        Resort__c r = new Resort__c();
        r.name = 'test';
        insert r;
        
     Timeshare__c Ts2 = new Timeshare__c();
        Ts2.Resort__c = r.Id;
        Ts2.Mortgage_Balance__c = 100;
        Ts2.Mortgage_Monthly_Payment__c = '5';
        Ts2.Master_Record_Id__c = 'Mitul1234';
        insert Ts2;
        
        
        Timeshare__c Ts3 = new Timeshare__c();
        Ts3.Resort__c = r.Id;
        Ts3.Mortgage_Balance__c = 100;
        Ts3.Mortgage_Monthly_Payment__c = '5';
        Ts3.Master_Record_Id__c = 'Mitul1234';
        insert Ts3;
        
        Timeshare__c Ts4 = new Timeshare__c();
        Ts4.Resort__c = r.Id;
        Ts4.Mortgage_Balance__c = 100;
        Ts4.Mortgage_Monthly_Payment__c = '5';
        Ts4.Master_Record_Id__c = 'Mitul1234';
        insert Ts4;
        
        Timeshare__c Ts5 = new Timeshare__c();
        Ts5.Resort__c = r.Id;
        Ts5.Mortgage_Balance__c = 100;
        Ts5.Mortgage_Monthly_Payment__c = '5';
        Ts5.Master_Record_Id__c = 'Mitul1234';
        insert Ts5;
        
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp';
       opp.Timeshare_1__c = Ts2.Id;
        opp.Timeshare_2__c = Ts3.Id;
        opp.Timeshare_3__c = Ts4.Id;
        opp.StageName = 'Prospecting';
        opp.CloseDate = system.Today()-30;
        insert opp;
        
        test.startTest();
        TimeShareDatatableHandler.addToOpportunity(opp.id,Ts5.Id);
        TimeShareDatatableHandler.getTimeShare(opp.id);
        delete opp;
        test.stopTest();
    }
    
    
    @isTest
    static void test5() {
        
        Resort__c r = new Resort__c();
        r.name = 'test';
        insert r;
        
     Timeshare__c Ts2 = new Timeshare__c();
        Ts2.Resort__c = r.Id;
        Ts2.Mortgage_Balance__c = 100;
        Ts2.Mortgage_Monthly_Payment__c = '5';
        Ts2.Master_Record_Id__c = 'Mitul1234';
        insert Ts2;
        
        
        Timeshare__c Ts3 = new Timeshare__c();
        Ts3.Resort__c = r.Id;
        Ts3.Mortgage_Balance__c = 100;
        Ts3.Mortgage_Monthly_Payment__c = '5';
        Ts3.Master_Record_Id__c = 'Mitul1234';
        insert Ts3;
        
        Timeshare__c Ts4 = new Timeshare__c();
        Ts4.Resort__c = r.Id;
        Ts4.Mortgage_Balance__c = 100;
        Ts4.Mortgage_Monthly_Payment__c = '5';
        Ts4.Master_Record_Id__c = 'Mitul1234';
        insert Ts4;
        
        Timeshare__c Ts5 = new Timeshare__c();
        Ts5.Resort__c = r.Id;
        Ts5.Mortgage_Balance__c = 100;
        Ts5.Mortgage_Monthly_Payment__c = '5';
        Ts5.Master_Record_Id__c = 'Mitul1234';
        insert Ts5;
        
        Timeshare__c Ts6 = new Timeshare__c();
        Ts6.Resort__c = r.Id;
        Ts6.Mortgage_Balance__c = 100;
        Ts6.Mortgage_Monthly_Payment__c = '5';
        Ts6.Master_Record_Id__c = 'Mitul1234';
        insert Ts6;
        
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp';
       opp.Timeshare_1__c = Ts2.Id;
        opp.Timeshare_2__c = Ts3.Id;
        opp.Timeshare_3__c = Ts4.Id;
        opp.Timeshare_4__c = Ts5.Id;
        
        opp.StageName = 'Prospecting';
        opp.CloseDate = system.Today()-30;
        insert opp;
        
        test.startTest();
        TimeShareDatatableHandler.addToOpportunity(opp.id,Ts6.Id);
        TimeShareDatatableHandler.getTimeShare(opp.id);
        delete opp;
        test.stopTest();
    }
    
    
      @isTest
    static void test6() {
        
        Resort__c r = new Resort__c();
        r.name = 'test';
        insert r;
        
     Timeshare__c Ts2 = new Timeshare__c();
        Ts2.Resort__c = r.Id;
        Ts2.Mortgage_Balance__c = 100;
        Ts2.Mortgage_Monthly_Payment__c = '5';
        Ts2.Master_Record_Id__c = 'Mitul1234';
        insert Ts2;
        
        
        Timeshare__c Ts3 = new Timeshare__c();
        Ts3.Resort__c = r.Id;
        Ts3.Mortgage_Balance__c = 100;
        Ts3.Mortgage_Monthly_Payment__c = '5';
        Ts3.Master_Record_Id__c = 'Mitul1234';
        insert Ts3;
        
        Timeshare__c Ts4 = new Timeshare__c();
        Ts4.Resort__c = r.Id;
        Ts4.Mortgage_Balance__c = 100;
        Ts4.Mortgage_Monthly_Payment__c = '5';
        Ts4.Master_Record_Id__c = 'Mitul1234';
        insert Ts4;
        
        Timeshare__c Ts5 = new Timeshare__c();
        Ts5.Resort__c = r.Id;
        Ts5.Mortgage_Balance__c = 100;
        Ts5.Mortgage_Monthly_Payment__c = '5';
        Ts5.Master_Record_Id__c = 'Mitul1234';
        insert Ts5;
        
        Timeshare__c Ts6 = new Timeshare__c();
        Ts6.Resort__c = r.Id;
        Ts6.Mortgage_Balance__c = 100;
        Ts6.Mortgage_Monthly_Payment__c = '5';
        Ts6.Master_Record_Id__c = 'Mitul1234';
        insert Ts6;
        
        Timeshare__c Ts7 = new Timeshare__c();
        Ts7.Resort__c = r.Id;
        Ts7.Mortgage_Balance__c = 100;
        Ts7.Mortgage_Monthly_Payment__c = '5';
        Ts7.Master_Record_Id__c = 'Mitul1234';
        insert Ts7;
        
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp';
       opp.Timeshare_1__c = Ts2.Id;
        opp.Timeshare_2__c = Ts3.Id;
        opp.Timeshare_3__c = Ts4.Id;
        opp.Timeshare_4__c = Ts5.Id;
        opp.Timeshare_5__c = Ts6.Id;
        
        opp.StageName = 'Prospecting';
        opp.CloseDate = system.Today()-30;
        insert opp;
        
        test.startTest();
        TimeShareDatatableHandler.addToOpportunity(opp.id,Ts7.Id);
        TimeShareDatatableHandler.getTimeShare(opp.id);
        delete opp;
        test.stopTest();
    }
    
    
    @isTest
    static void test7() {
        
        Resort__c r = new Resort__c();
        r.name = 'test';
        insert r;
        
     Timeshare__c Ts2 = new Timeshare__c();
        Ts2.Resort__c = r.Id;
        Ts2.Mortgage_Balance__c = 100;
        Ts2.Mortgage_Monthly_Payment__c = '5';
        Ts2.Master_Record_Id__c = 'Mitul1234';
        insert Ts2;
        
        
        Timeshare__c Ts3 = new Timeshare__c();
        Ts3.Resort__c = r.Id;
        Ts3.Mortgage_Balance__c = 100;
        Ts3.Mortgage_Monthly_Payment__c = '5';
        Ts3.Master_Record_Id__c = 'Mitul1234';
        insert Ts3;
        
        Timeshare__c Ts4 = new Timeshare__c();
        Ts4.Resort__c = r.Id;
        Ts4.Mortgage_Balance__c = 100;
        Ts4.Mortgage_Monthly_Payment__c = '5';
        Ts4.Master_Record_Id__c = 'Mitul1234';
        insert Ts4;
        
        Timeshare__c Ts5 = new Timeshare__c();
        Ts5.Resort__c = r.Id;
        Ts5.Mortgage_Balance__c = 100;
        Ts5.Mortgage_Monthly_Payment__c = '5';
        Ts5.Master_Record_Id__c = 'Mitul1234';
        insert Ts5;
        
        Timeshare__c Ts6 = new Timeshare__c();
        Ts6.Resort__c = r.Id;
        Ts6.Mortgage_Balance__c = 100;
        Ts6.Mortgage_Monthly_Payment__c = '5';
        Ts6.Master_Record_Id__c = 'Mitul1234';
        insert Ts6;
        
        Timeshare__c Ts7 = new Timeshare__c();
        Ts7.Resort__c = r.Id;
        Ts7.Mortgage_Balance__c = 100;
        Ts7.Mortgage_Monthly_Payment__c = '5';
        Ts7.Master_Record_Id__c = 'Mitul1234';
        insert Ts7;
        
        Timeshare__c Ts8 = new Timeshare__c();
        Ts8.Resort__c = r.Id;
        Ts8.Mortgage_Balance__c = 100;
        Ts8.Mortgage_Monthly_Payment__c = '5';
        Ts8.Master_Record_Id__c = 'Mitul1234';
        insert Ts8;
        
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp';
       opp.Timeshare_1__c = Ts2.Id;
        opp.Timeshare_2__c = Ts3.Id;
        opp.Timeshare_3__c = Ts4.Id;
        opp.Timeshare_4__c = Ts5.Id;
        opp.Timeshare_5__c = Ts6.Id;
        opp.Timeshare_6__c = Ts7.Id;
        
        opp.StageName = 'Prospecting';
        opp.CloseDate = system.Today()-30;
        insert opp;
        
        test.startTest();
        TimeShareDatatableHandler.addToOpportunity(opp.id,Ts8.Id);
        TimeShareDatatableHandler.getTimeShare(opp.id);
        delete opp;
        test.stopTest();
    }
    
    
     @isTest
    static void test8() {
        
        Resort__c r = new Resort__c();
        r.name = 'test';
        insert r;
        
     Timeshare__c Ts2 = new Timeshare__c();
        Ts2.Resort__c = r.Id;
        Ts2.Mortgage_Balance__c = 100;
        Ts2.Mortgage_Monthly_Payment__c = '5';
        Ts2.Master_Record_Id__c = 'Mitul1234';
        insert Ts2;
        
        
        Timeshare__c Ts3 = new Timeshare__c();
        Ts3.Resort__c = r.Id;
        Ts3.Mortgage_Balance__c = 100;
        Ts3.Mortgage_Monthly_Payment__c = '5';
        Ts3.Master_Record_Id__c = 'Mitul1234';
        insert Ts3;
        
        Timeshare__c Ts4 = new Timeshare__c();
        Ts4.Resort__c = r.Id;
        Ts4.Mortgage_Balance__c = 100;
        Ts4.Mortgage_Monthly_Payment__c = '5';
        Ts4.Master_Record_Id__c = 'Mitul1234';
        insert Ts4;
        
        Timeshare__c Ts5 = new Timeshare__c();
        Ts5.Resort__c = r.Id;
        Ts5.Mortgage_Balance__c = 100;
        Ts5.Mortgage_Monthly_Payment__c = '5';
        Ts5.Master_Record_Id__c = 'Mitul1234';
        insert Ts5;
        
        Timeshare__c Ts6 = new Timeshare__c();
        Ts6.Resort__c = r.Id;
        Ts6.Mortgage_Balance__c = 100;
        Ts6.Mortgage_Monthly_Payment__c = '5';
        Ts6.Master_Record_Id__c = 'Mitul1234';
        insert Ts6;
        
        Timeshare__c Ts7 = new Timeshare__c();
        Ts7.Resort__c = r.Id;
        Ts7.Mortgage_Balance__c = 100;
        Ts7.Mortgage_Monthly_Payment__c = '5';
        Ts7.Master_Record_Id__c = 'Mitul1234';
        insert Ts7;
        
        Timeshare__c Ts8 = new Timeshare__c();
        Ts8.Resort__c = r.Id;
        Ts8.Mortgage_Balance__c = 100;
        Ts8.Mortgage_Monthly_Payment__c = '5';
        Ts8.Master_Record_Id__c = 'Mitul1234';
        insert Ts8;
        
        Timeshare__c Ts9 = new Timeshare__c();
        Ts9.Resort__c = r.Id;
        Ts9.Mortgage_Balance__c = 100;
        Ts9.Mortgage_Monthly_Payment__c = '5';
        Ts9.Master_Record_Id__c = 'Mitul1234';
        insert Ts9;
        
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp';
       opp.Timeshare_1__c = Ts2.Id;
        opp.Timeshare_2__c = Ts3.Id;
        opp.Timeshare_3__c = Ts4.Id;
        opp.Timeshare_4__c = Ts5.Id;
        opp.Timeshare_5__c = Ts6.Id;
        opp.Timeshare_6__c = Ts7.Id;
        opp.Timeshare_7__c = Ts8.Id;
        
        opp.StageName = 'Prospecting';
        opp.CloseDate = system.Today()-30;
        insert opp;
        
        test.startTest();
        TimeShareDatatableHandler.addToOpportunity(opp.id,Ts9.Id);
        TimeShareDatatableHandler.getTimeShare(opp.id);
        delete opp;
        test.stopTest();
    }
}