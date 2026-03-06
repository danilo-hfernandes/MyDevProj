@isTest
public class TimeshareTrigger_Test {
    
    
    @isTest
    static void test() {
        Apex_Trigger_On_Off__c tr = new Apex_Trigger_On_Off__c();
        tr.Name = 'TimeshareTrigger';
        tr.isEnable__c = true;
        insert tr;
        
        Resort__c r = new Resort__c();
        r.name = 'test';
        
        insert r;
        
        Timeshare__c t = new Timeshare__c();
        t.Resort__c = r.id;
        t.Ownership__c = 'Deeded';
        t.Week_Type__c = 'Fixed';
        t.Week__c = '12';
        t.MF_Paid_Until_Month__c = 'June';
        t.MF_Paid_Until_Year__c = '2020';
        t.MF_Amount__c = 123;
        t.Master_Record_Id__c = 'Mitul1234';
        
        insert t;
    }
    @isTest
    static void test2() {
        Apex_Trigger_On_Off__c tr = new Apex_Trigger_On_Off__c();
        tr.Name = 'TimeshareTrigger';
        tr.isEnable__c = true;
        insert tr;
        
        Resort__c r = new Resort__c();
        r.name = 'test';
        
        Resort__c r1 = new Resort__c();
        r1.name = 'test1';
        
        insert r;
        insert r1;
        
        Timeshare__c t = new Timeshare__c();
        t.Resort__c = r.id;
        t.Ownership__c = 'Deeded';
        t.Week_Type__c = 'Fixed';
        t.Week__c = '12';
        t.MF_Paid_Until_Month__c = 'June';
        t.MF_Paid_Until_Year__c = '2020';
        t.MF_Amount__c = 123;
        t.Master_Record_Id__c = 'Mitul1234';
        
        insert t;
        t.Resort__c = r1.id;
        update t;
        delete t;
    }
    
    @isTest
    static void test3() {
        Apex_Trigger_On_Off__c tr = new Apex_Trigger_On_Off__c();
        tr.Name = 'TimeshareTrigger';
        tr.isEnable__c = true;
        insert tr;
        
        Resort__c r = new Resort__c();
        r.name = 'test';
        
        insert r;
        
        Timeshare__c t = new Timeshare__c();
        t.Resort__c = r.id;
        t.Ownership__c = 'Deeded';
        t.Week_Type__c = 'Fixed';
        t.Week__c = '12';
        t.MF_Paid_Until_Month__c = 'June';
        t.MF_Paid_Until_Year__c = '2020';
        t.MF_Amount__c = 123;
        t.Master_Record_Id__c = 'Mitul1234';
        
        insert t;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'test';
        opp.StageName = 'Proposal';
        opp.CloseDate = system.today();
        insert opp;
        
        Product2 p = new Product2(Name='My Product', IsActive = true);
        insert p;
        
        PriceBookEntry stdPriceBookEntry = new PriceBookEntry();
        stdPriceBookEntry.Product2Id = p.Id;
        stdPriceBookEntry.Pricebook2Id = Test.getStandardPricebookId();
        stdPriceBookEntry.UnitPrice = 2000;
        stdPriceBookEntry.IsActive = true;
        insert stdPriceBookEntry;
        
        OpportunityLineItem opplineItem = new OpportunityLineItem();
        opplineItem.Timeshare__c = t.Id;
        opplineItem.OpportunityId = opp.Id;
        opplineItem.PricebookEntryId = stdPriceBookEntry.Id;
        insert opplineItem;
        try{
            delete t;
        }catch(Exception e){
            
        }
        
    }
    
      @isTest
   static void test4() {
       
    
        Opportunity opp = new Opportunity();
        opp.Name = 'test';
        opp.StageName = 'Proposal';
        opp.CloseDate = system.today();
        insert opp;
        
       TimeShareDatatableHandler.getTimeShare(opp.id);
        
        
    }
}