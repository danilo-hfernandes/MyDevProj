@isTest
public class ContactUpdateTrigger_Test {

    @isTest
    static void test1() {
        
          Apex_Trigger_On_Off__c tr = new Apex_Trigger_On_Off__c();
        tr.Name = 'contactTrigger';
        tr.isEnable__c = true;
        insert tr;
        
        Membership_Product_Configuration__c mpc = new Membership_Product_Configuration__c();
        mpc.Name = 'test';
        
        insert mpc;
        
        Contact c = new Contact();
        c.LastName = 'test';
        c.Membership_Product_Configuration__c = mpc.id;
        
        insert c;
        
        update c;
    }
}