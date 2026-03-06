@isTest
public class CaseTriggerHandlerTest {
     @isTest
    static void test1() {
        Apex_Trigger_On_Off__c obj = new Apex_Trigger_On_Off__c();
        obj.Name = 'Case Trigger';
        obj.isEnable__c = true;
        insert obj; 
        
        Account a = new Account();
        a.Name = 'test account';
        a.Member_Number__c = 'SLV-010-8721701';
        
        insert a;
        
        contact ct = new contact();
        ct.AccountId = a.id;
        ct.LastName = 'test account';
        insert ct;
        
        Id advantageWeekRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Advantage_Week_Requests').getRecordTypeId();
        
        Case c = new Case();
        c.Status = 'New';
        c.Member_Number__c = 'SLV-010-8721701';
        c.Form_Source__c = 'Halo Resort Request';
        c.RecordTypeId = advantageWeekRecordTypeId ;
        c.AccountId = a.id;
        
        insert c;
    }

}