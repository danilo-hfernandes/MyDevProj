@isTest
public class contactTriggerHandlerTest {
	
   @isTest
    static void contactInsertAffliate(){
        Apex_Trigger_On_Off__c cs3 = new Apex_Trigger_On_Off__c();
        cs3.isEnable__c = true;
        cs3.Name = 'Contact-Trigger';
        insert cs3;
        
        Account acc = New Account();
        acc.Name = 'acctest';
        Insert acc;
        
        Membership_Product_Configuration__c mpc = New Membership_Product_Configuration__c();
        mpc.Name = 'testingmpc';
        mpc.Affiliated_Id__c = '12345';
        mpc.Product_Type__c = 'HSI';
        mpc.HSI_Product_Id__c = '2548';
        
        Insert mpc;
        
        Membership_Product_Configuration__c mpc1 = New Membership_Product_Configuration__c();
        mpc1.Name = 'testingmpc';
        mpc1.Subscriber_Id__c = '12345';
        mpc1.Product_Type__c = 'HSI';
        mpc1.HSI_Product_Id__c = '1111';
        
        Insert mpc1;
        
        Membership_Product_Configuration__c mpc2 = New Membership_Product_Configuration__c();
        mpc2.Name = 'testingmpc2';
        mpc2.Sales_Room_Id__c = '12345';
        mpc2.Product_Type__c = 'HSI';
        mpc2.HSI_Product_Id__c = '2222';
        
        Insert mpc2;
        
        List<Contact> conList = new List<Contact>();
        Contact cont= New Contact();
        cont.FirstName='test';
        cont.LastName = 'testname';
        cont.AffiliatedId__c = 12345;
        cont.AccountId = acc.id;
		cont.Sales_Room_Id__c = '2222';
        cont.Subscriber_Id__c = '12345';
        conList.add(cont);
        insert conList;
        
        contactTriggerHandler.updateMembershipProdconfig(conList);
    }
    
}