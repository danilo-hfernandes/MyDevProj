@isTest
public class GenericBatchToUpdateAccountTest {
    @isTest 
    public static void runTest() {       
        Lead leadrec = new Lead();
        leadrec.LastName = 'test';
        leadrec.Company = 'test';
        leadrec.LeadSource = 'CFD FB';
        leadrec.Phone = '1234567891';
        leadrec.Email = 'd3rths@ds.com';
        leadrec.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Carefree_Destinations').getRecordTypeId();
        insert leadrec;
        
        database.executebatch(new GenericBatchToUpdateAccount(),1);
    }
   /* public static void runTest() {
        Timeshare_Owner_Flag__c cs3 = new Timeshare_Owner_Flag__c();
        cs3.Timeshare_Owner__c = 'Yes';
        cs3.Name = 'A1002421';
        insert cs3;
        
        Membership_Product_Configuration__c obj = new Membership_Product_Configuration__c();
        obj.Affiliated_Id__c = 'A1002421';
        obj.Membership_Product_Config_Ext_Db__c = 'A1002421';
        insert obj;
        
        Account a = new Account();
        a.Name = 'test account';
        a.Affiliated_Id__c = 1002266;
        a.Preferred_Language__c = 'ENG';
        a.Master_Record_Id__c = 'test';
        a.First_Name__c = 'test';
        a.Last_Name__c = 'test';
        a.Membership_Product_Configuration__c = obj.Id;
        insert a;
        
        System.debug('>>>>'+a.MembershipProductConfigId_Formula__c);
        
        database.executebatch(new GenericBatchToUpdateAccount(),1);
    }*/
}