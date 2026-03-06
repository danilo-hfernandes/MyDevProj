@isTest
public class TimeshareTriggerHandlerTest {
    @testSetup static void methodName() {
        Apex_Trigger_On_Off__c tr = new Apex_Trigger_On_Off__c();
        tr.Name = 'TimeshareTrigger';
        tr.isEnable__c = true;
        insert tr;
        
        Affiliated_Id_and_Name__c aa = new Affiliated_Id_and_Name__c();
        aa.Name = 'test classes';
        aa.Affiliated_Id__c = '1002243';
        aa.Affiliate_Name__c = 'Hawaii Collection';
        aa.Opportunity_Record_Type__c = 'Hawaii Collection Membership';
        insert aa;
        
        Account objacc = new Account();
        objacc.Name = 'Test Sample';
        insert objacc;
        
        Timeshare__c objtimeshare = new Timeshare__c();
        objtimeshare.Ownership__c = 'Deeded';
        objtimeshare.Week_Type__c = 'Fixed';
        objtimeshare.Week__c = '12';
        objtimeshare.MF_Paid_Until_Month__c = 'June';
        objtimeshare.MF_Paid_Until_Year__c = '2020';
        objtimeshare.MF_Amount__c = 123;
        objtimeshare.Master_Record_Id__c = 'Mitul1234'; 
        objtimeshare.Timeshare_Owner__c = objacc.Id;
        insert objtimeshare; 
        
        DateTime past45Days = system.now().addDays(-46);
        Test.setCreatedDate(objtimeshare.Id, past45Days); 
        
        Resort__c r = new Resort__c();
        r.name = 'test';
        
        insert r;
        
        Timeshare__c objtimeshare1 = new Timeshare__c();
        objtimeshare1.Ownership__c = 'Deeded';
        objtimeshare1.Week_Type__c = 'Fixed';
        objtimeshare1.resort__c = r.Id; 
        objtimeshare1.Week__c = '12';
        objtimeshare1.MF_Paid_Until_Month__c = 'June';
        objtimeshare1.MF_Paid_Until_Year__c = '2020';
        objtimeshare1.MF_Amount__c = 123;
        objtimeshare1.Master_Record_Id__c = 'Mitul1234'; 
        objtimeshare1.Timeshare_Owner__c = objacc.Id;
        insert objtimeshare1; 
        
        update objtimeshare1;
        
        delete objtimeshare;
       
    }  
    @isTest
    static void test() {
        List<Timeshare__c> objtimesheet = [select id, Timeshare_Owner__c from Timeshare__c limit 1];
        TimeshareTriggerHandler.CreateOpportunityBasedOnDuplicates(objtimesheet);
        TimeshareTriggerHandler.CreateOppoForHCAffiliateReturn(objtimesheet);
        
    }
}