@isTest
public class RedemptionTriggerTest {

     @isTest
    static void RedemptionControllerTest(){
        
        Apex_Trigger_On_Off__c obj = new Apex_Trigger_On_Off__c();
        obj.Name = 'RedemptionTrigger';
        obj.isEnable__c = true;
        insert obj;
        
        List<Account> accList = new List<Account> ();
        Account acc = new Account();
        acc.Name = 'test';
        accList.add(acc);
        insert accList;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'test';
        opp.AccountId = acc.Id;
        opp.StageName = 'Customer Won';
        opp.Amount = 300;
        opp.CloseDate = date.newInstance(2022,12,12);
        insert opp;
        
        List<Timeshare__c> timeList = new List<Timeshare__c>();
        Timeshare__c tm = new Timeshare__c();
        tm.Name = 'test';
        tm.Timeshare_Owner__c = acc.Id;
        timeList.add(tm);
        insert timeList;
        
        List<Redemption__c> rdmList = new List<Redemption__c>();
        Redemption__c rdm = new Redemption__c();
        rdm.Status__c = '';
        rdm.Usage_Fee__c = 10;
        rdm.Request_Date__c = Date.today().addDays(-1);
        rdm.Check_In_Date__c = Date.today().addDays(2);
        rdm.Reservation__c = 'Test Reservation2';
        rdm.Check_In_Date__c = date.newInstance(2022,12,12);
        rdm.Opportunity__c = opp.Id;
        rdm.Property__c = tm.Id;
        rdm.Redemption_Amount__c = 10;
        rdmList.add(rdm);
        insert rdmList;
        
        rdmList = new List<Redemption__c>();
        rdm.Usage_Fee__c = 100;
        rdmList.add(rdm);
        update rdmList;
        
    }

    
     public static testmethod void testRedemptionTrigger2() {
        // Enable the trigger
        Apex_Trigger_On_Off__c triggerSetting = new Apex_Trigger_On_Off__c(
            Name = 'RedemptionTrigger',
            isEnable__c = true
        );
        insert triggerSetting;

        // Create test data
        
         List<Account> accList = new List<Account> ();
        Account acc = new Account();
        acc.Name = 'test';
        accList.add(acc);
        insert accList;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'test';
        opp.AccountId = acc.Id;
        opp.StageName = 'Customer Won';
        opp.Amount = 300;
        opp.CloseDate = date.newInstance(2022,12,12);
        insert opp;
        
        List<Timeshare__c> timeList = new List<Timeshare__c>();
        Timeshare__c tm = new Timeshare__c();
        tm.Name = 'test';
        tm.Timeshare_Owner__c = acc.Id;
        timeList.add(tm);
        insert timeList;
        
        List<Redemption__c> rdmList = new List<Redemption__c>();
        Redemption__c parentRedemption = new Redemption__c();
        parentRedemption.Status__c = '';
        parentRedemption.Usage_Fee__c = 500;
        parentRedemption.Reservation__c = 'Test Reservation';
        parentRedemption.Request_Date__c = Date.today().addDays(-1);
        parentRedemption.Check_In_Date__c = Date.today().addDays(2);
        parentRedemption.Opportunity__c = opp.Id;
        parentRedemption.Property__c = tm.Id;
        parentRedemption.Redemption_Amount__c = 10;
        //rdmList.add(parentRedemption);
        insert parentRedemption;
         
         
        //List<Redemption__c> rdmList = new List<Redemption__c>();
        Redemption__c childRedemption = new Redemption__c();
        childRedemption.Status__c = '';
        childRedemption.Usage_Fee__c = 10;
        childRedemption.Reservation__c = 'yes';
        childRedemption.Check_In_Date__c = date.newInstance(2022,12,12);
        childRedemption.Opportunity__c = opp.Id;
        childRedemption.Property__c = tm.Id;
        childRedemption.Redemption_Amount__c = 10;
        childRedemption.Parent_Redemption__c = parentRedemption.Id;
        //rdmList.add(childRedemption);
        insert childRedemption;
        
        
        
 
        // Verify the expected field value after insert
        childRedemption = [SELECT Redemption_Name__c FROM Redemption__c WHERE Id = :childRedemption.Id];
        //System.assertEquals('Parent Redemption.1', childRedemption.Redemption_Name__c);

        // Update the child record
        
        childRedemption.Usage_Fee__c = 100;
        update childRedemption;

        // Verify the expected field value after update
        childRedemption = [SELECT Redemption_Name__c FROM Redemption__c WHERE Id = :childRedemption.Id];
        //System.assertEquals('Parent Redemption.1', childRedemption.Redemption_Name__c);
    }

    
}