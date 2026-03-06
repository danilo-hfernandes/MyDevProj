@isTest
public class AnnualDuesBatchControllerTest {
    @testSetup static void methodName() {
        Apex_Trigger_On_Off__c obj = new Apex_Trigger_On_Off__c();
        obj.Name = 'OpportunityTrigger_New';
        obj.isEnable__c = true;
        insert obj;
        
        Apex_Trigger_On_Off__c obj1 = new Apex_Trigger_On_Off__c();
        obj1.Name = 'OppcloseWonErrorFromTrigger';
        obj1.isEnable__c = true;
        insert obj1; 
        
        Membership_Product_Configuration__c objmember = new Membership_Product_Configuration__c();
        objmember.Name = 'Test MPC';
        objmember.Responsible_Party__c = 'Member';
        insert objmember;   
        
        Account objacc = new Account();
        objacc.Name = 'Test Account';
        objacc.First_Name__c = 'Test';
        objacc.Last_Name__c = 'Account';
        objacc.Preferred_Language__c = 'ENG';
        objacc.Dues_Last_Paid_Until__c = System.today().addDays(-10);
        objacc.Membership_Product_Configuration__c = objmember.Id;
        objacc.Member_Number__c = '13523412';
        objacc.Contact_Id__c = 12345;
        insert objacc;
        
        Account objacc1 = new Account();
        objacc1.Name = 'Testv1 Accountv1';
        objacc1.First_Name__c = 'Test';
        objacc1.Last_Name__c = 'Accountv1';
        objacc1.Preferred_Language__c = 'SPA';
        objacc1.Dues_Last_Paid_Until__c = System.today().addDays(-10);
        objacc1.Membership_Product_Configuration__c = objmember.Id;
        objacc1.Member_Number__c = '13523413';
        objacc1.Contact_Id__c = 12346;
        insert objacc1;
        
        /*Account objacc2 = new Account();
objacc2.Affiliated_Id__c = 1002310;
objacc2.Name = 'Testv2 Accountv2';
objacc2.First_Name__c = 'Test';
objacc2.Last_Name__c = 'Accountv2';
objacc2.Preferred_Language__c = 'SPA';
objacc2.Dues_Last_Paid_Until__c = System.today().addDays(-10);
objacc2.Membership_Product_Configuration__c = objmember.Id;
objacc2.Member_Number__c = '13523414';
objacc2.Contact_Id__c = 12347;
insert objacc2;

Account objacc3 = new Account();
objacc3.Affiliated_Id__c = 1002243;
objacc3.Name = 'Testv1 Accountv1';
objacc3.First_Name__c = 'Test';
objacc3.Last_Name__c = 'Accountv1';
objacc3.Preferred_Language__c = 'ENG';
objacc3.Dues_Last_Paid_Until__c = System.today().addDays(-10);
objacc3.Membership_Product_Configuration__c = objmember.Id;
objacc3.Member_Number__c = '13523415';
objacc3.Contact_Id__c = 12348;
insert objacc3;*/
        
        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 standardPricebook = new Pricebook2(
            Id = pricebookId,
            IsActive = true
        );
        update standardPricebook;
        
        Product2 objprod = new Product2();
        objprod.Name = 'Annual Dues-Renewal';
        insert objprod;
    }
    @isTest
    static void Test1() {
        
        AnnualDuesRenewalBatchController objBatch = new AnnualDuesRenewalBatchController(); 
        database.executebatch(objBatch, 2);
        
        /*AnnualDuesBatchController objBatch1 = new AnnualDuesBatchController(); 
		database.executebatch(objBatch1, 2);*/
    }
    
    @isTest
    static void Test2() {
        
        List<Account> accounts = [SELECT Id,Affiliated_Id__c FROM Account WHERE First_Name__c = 'Test'];
        for(Account acc : accounts)
        {
            acc.Affiliated_Id__c = 1002311;
        }
        
        update accounts;
        
        AnnualDuesRenewalBatchController objBatch = new AnnualDuesRenewalBatchController(); 
        database.executebatch(objBatch, 2);
        
        /*AnnualDuesBatchController objBatch1 = new AnnualDuesBatchController(); 
		database.executebatch(objBatch1, 2);*/
    }
    
    @isTest
    static void Test3() {
        
        AnnualDuesBatchController objBatch1 = new AnnualDuesBatchController(); 
        database.executebatch(objBatch1, 2);
    }
    
}