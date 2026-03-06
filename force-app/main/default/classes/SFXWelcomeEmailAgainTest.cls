@isTest
public class SFXWelcomeEmailAgainTest {
    
    @testSetup
    public static void setupEnvironment() {
        Apex_Trigger_On_Off__c cs3 = new Apex_Trigger_On_Off__c();
        cs3.isEnable__c = true;
        cs3.Name = 'UpdateTimeZoneAccount';
        insert cs3;
        User u2=[SELECT Id,Assigned_Contacts__c FROM User where name ='Dev Account'];
        
        Apex_Trigger_On_Off__c cs5 = new Apex_Trigger_On_Off__c();
        cs5.isEnable__c = true;
        cs5.Name = 'LeadAndAccountTrigger';
        insert cs5;
        Id sfxRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('SFX Membership').getRecordTypeId();
        
        
        Account acc = new Account();
        acc.Name = 'Danilo_test Fernandes_test';
        acc.Email__c='test1@gmail.com';
        acc.TRM_Owner_Flag__c='No';
        acc.Affiliated_Id__c = 1002277;    
        acc.HC_Flag__c=False;
        acc.ownerid=u2.id;
        acc.Preferred_Language__c='SPA';
        acc.Enrollment_Date__c = System.today() - 10;
        Insert acc;
        
        Opportunity opp= new Opportunity();
        opp.name='Danilo_test Fernandes_test';
        opp.StageName='New';
        opp.SFX_Welcome_Email__c=FALSE;
        opp.ownerid=u2.id;
        opp.RecordTypeId=sfxRecordTypeId;
        opp.CloseDate=system.today();
        opp.AccountId=acc.id;
        insert opp;
        
        Test.setCreatedDate(opp.Id, Date.today().addDays(-44));
        
        system.debug('testopp='+opp.createddate);
    } 
    @isTest 
    public static void assignOwnersTest() { 
        Test.startTest();
        SFXWelcomeEmailAgain ba= new SFXWelcomeEmailAgain();
        Id jobid= Database.executeBatch(ba,10);
        Test.stopTest();       
    } 
    
}