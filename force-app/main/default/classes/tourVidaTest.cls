@isTest
public class tourVidaTest {
    
    @testSetup
    public static void setupEnvironment() {
        
        Apex_Trigger_On_Off__c cs3 = new Apex_Trigger_On_Off__c();
        cs3.isEnable__c = true;
        cs3.Name = 'UpdateTimeZoneAccount';
        insert cs3;
        
        Membership_Product_Configuration__c mpc = New Membership_Product_Configuration__c();
        // mpc=[select id from Membership_Product_Configuration__c where Membership_Product_Config_Ext_Db__c = 'A1000809' limit 1];
        mpc.Name = 'testingmpc';
        mpc.Affiliated_Id__c = '12345';
        mpc.Product_Type__c = 'HSI';
        mpc.Membership_Product_Config_Ext_Db__c = 'A1000809';
        insert mpc;
        
        
        Account acc = new Account();
        acc.Name = 'Test1214';
        acc.Membership_Status__c='Active';
        acc.Enrollment_Date__c = System.today() - 10;
        acc.Membership_Product_Configuration__c=mpc.id;
        Insert acc;
        
        Contact con = new Contact();
        con.AccountId = acc.Id;
        con.Preferred_Language__c='ENG';
        con.LastName = 'Test1214';  
        con.Assign_to_Sales_Cadence__c=false;
        con.Cadence_Flag__c=0;
        con.Assign_to_Sales_Cadence_Name__c='test';
        con.AffiliatedId__c = 1002243;
        
        con.Membership_Status__c='Active';
        
        Insert con;
        
        con.Master_Record_Id__c='test';
        update con;
        
        
        
    } 
    
    @isTest 
    public static void Test1() {
        
        list<contact> conlist=[Select id,name,Membership_Status__c,accountid,Master_Record_Id__c,Assign_to_Sales_Cadence_Name__c,Assign_to_Sales_Cadence__c ,ActionCadenceId,Tour_Vida_Active_SSR_Match_Group__c from contact where name='Test1214'];
        system.debug('test 45='+conlist);
        system.debug('test 45='+conlist[0].Master_Record_Id__c);
        Test.setMock(HttpCalloutMock.class, new tourVidaTestMock());  
        Test.startTest();
        
        tourVida ba= new tourVida();
        Id jobid= Database.executeBatch(ba,20);
        Test.stopTest();
    }
}