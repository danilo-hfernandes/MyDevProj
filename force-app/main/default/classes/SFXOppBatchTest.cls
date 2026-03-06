@isTest
public class SFXOppBatchTest {
    
    @testSetup
    public static void setupEnvironment() {
        Apex_Trigger_On_Off__c cs3 = new Apex_Trigger_On_Off__c();
        cs3.isEnable__c = true;
        cs3.Name = 'UpdateTimeZoneAccount';
        insert cs3;
        User u2=[SELECT Id,Assigned_Contacts__c FROM User where name ='Salesforce'];
        
        Apex_Trigger_On_Off__c cs5 = new Apex_Trigger_On_Off__c();
        cs5.isEnable__c = true;
        cs5.Name = 'LeadAndAccountTrigger';
        insert cs5;
        
        Id sfxRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('SFX Membership').getRecordTypeId();


        //75 line  First If condition
        Account acc = new Account();
        acc.Name = 'Test';
        acc.Email__c='test1@gmail.com';
        acc.TRM_Owner_Flag__c='No';
        acc.Affiliated_Id__c = 1002277;    
        acc.HC_Flag__c=False;
        acc.ownerid=u2.id;
        acc.Preferred_Language__c='ENG';
        acc.Enrollment_Date__c = System.today() - 10;
        Insert acc;
        
        Opportunity opp= new Opportunity();
        opp.name='Test';
        opp.StageName='New';
        opp.SFX_Welcome_Email__c=FALSE;
        opp.ownerid=u2.id;
        opp.RecordTypeId=sfxRecordTypeId;
        opp.CloseDate=system.today();
        opp.AccountId=acc.id;
        insert opp;
        
        //79 line else
        Account acc1 = new Account();
        acc1.Name = 'Test101';
        acc1.TRM_Owner_Flag__c='No';
        acc1.Affiliated_Id__c = 1002277;    
        acc1.ownerid=u2.id;
        acc1.HC_Flag__c=False;
        acc1.Email__c='test2@gmail.com';
        acc1.Enrollment_Date__c = System.today() - 15;
        acc1.Preferred_Language__c = 'ENG';
        Insert acc1;
        
        Opportunity opp1= new Opportunity();
        opp1.name='Test101';
        opp1.StageName='New';
        opp1.SFX_Welcome_Email__c=TRUE;
        opp1.ownerid=u2.id;
        opp1.RecordTypeId=sfxRecordTypeId;
        opp1.CloseDate=system.today();
        opp1.AccountId=acc1.id;
        insert opp1;
        
        //85 line else
        Account acc2 = new Account();
        acc2.Name = 'Test2';
        acc2.Email__c='test12@gmail.com';
        acc2.TRM_Owner_Flag__c='No';
        acc2.Affiliated_Id__c = 1002277;    
        acc2.HC_Flag__c=False;
        acc2.ownerid=u2.id;
        acc2.Preferred_Language__c='SPA';
        acc2.Original_Source__c = 'vidanta';
        acc2.Enrollment_Date__c = System.today() - 10;
        Insert acc2;
        
        Opportunity opp2= new Opportunity();
        opp2.name='Test2';
        opp2.StageName='New';
        opp2.SFX_Welcome_Email__c=FALSE;
        opp2.ownerid=u2.id;
        opp2.RecordTypeId=sfxRecordTypeId;
        opp2.CloseDate=system.today();
        opp2.AccountId=acc2.id;
        insert opp2;
        
        //89
        Account acc3 = new Account();
        acc3.Name = 'Test103';
        acc3.Email__c='test4@gmail.com';
        acc3.Affiliated_Id__c = 1002277;
        acc3.ownerid=u2.id;
        acc3.HC_Flag__c= FALSE;
        acc3.Original_Source__c = 'vidanta';
        acc3.Enrollment_Date__c = System.today() - 20;
        acc3.Preferred_Language__c='SPA';
        Insert acc3;
        
       /* Contact con = new Contact();
        con.AccountId = acc3.Id;
        con.LastName = 'Test';  
        con.Assign_to_Sales_Cadence__c=false;
        Insert con;
        
        con.Master_Record_Id__c='TEST';
        update con;*/
        
        Opportunity opp3= new Opportunity();
        opp3.name='Test103';
        opp3.StageName='New';
        opp3.SFX_Welcome_Email__c=TRUE;
        opp3.ownerid=u2.id;
        opp3.RecordTypeId=sfxRecordTypeId;
        opp3.CloseDate=system.today();
        opp3.AccountId=acc3.id;
        insert opp3;
        
        //97 line else
        Account acc4 = new Account();
        acc4.Name = 'Test22104';
        acc4.TRM_Owner_Flag__c='Yes';
        acc4.Affiliated_Id__c = 1002277;    
        acc4.ownerid=u2.id;
        acc4.HC_Flag__c=False;
        acc4.Email__c='test222@gmail.com';
        acc4.Preferred_Language__c='ENG';
        acc4.Enrollment_Date__c = System.today() - 10;
        Insert acc4;
        
        Opportunity opp4= new Opportunity();
        opp4.name='Test101';
        opp4.StageName='New';
        opp4.SFX_Welcome_Email__c=FALSE;
        opp4.ownerid=u2.id;
        opp4.RecordTypeId=sfxRecordTypeId;
        opp4.CloseDate=system.today();
        opp4.AccountId=acc4.id;
        insert opp4;
        
        //96 line else
        Account acc5 = new Account();
        acc5.Name = 'Test10ww1';
        acc5.TRM_Owner_Flag__c='YES';
        acc5.Affiliated_Id__c = 1002277;    
        acc5.ownerid=u2.id;
        acc5.HC_Flag__c=False;
        acc5.Email__c='teswwt2@gmail.com';
        acc5.Enrollment_Date__c = System.today() - 15;
        acc5.Returning_Vidanta_Costumer__c = System.today().addDays(-45);
        Insert acc5;
        
        Opportunity opp5= new Opportunity();
        opp5.name='Test101';
        opp5.StageName='New';
        opp5.SFX_Welcome_Email__c=TRUE;
        opp5.ownerid=u2.id;
        opp5.RecordTypeId=sfxRecordTypeId;
        opp5.CloseDate=system.today();
        opp5.AccountId=acc5.id;
        
        insert opp5;
        
        //109 line else
        Account acc6 = new Account();
        acc6.Name = 'Test22104';
        acc6.TRM_Owner_Flag__c='No';
        acc6.Affiliated_Id__c = 1002277;    
        acc6.ownerid=u2.id;
        acc6.HC_Flag__c=True;
        acc6.Email__c='test2225@gmail.com';
        acc6.Preferred_Language__c='SPA';
        acc6.Enrollment_Date__c = System.today() - 21;
        acc6.Returning_Vidanta_Costumer__c = System.today().addDays(-45);
        Insert acc6;
        
        Opportunity opp6= new Opportunity();
        opp6.name='Test101';
        opp6.StageName='In Process';
        opp6.SFX_Welcome_Email__c=TRUE;
        opp6.ownerid=u2.id;
        opp6.RecordTypeId=sfxRecordTypeId;
        opp6.CloseDate=system.today();
        opp6.AccountId=acc6.id;
        insert opp6;
        
        
        Account acc7 = new Account();
        acc7.Name = 'Test103';
        acc7.Email__c='test44@gmail.com';
        acc7.Affiliated_Id__c = 1002277;
        acc7.ownerid=u2.id;
        acc7.Original_Source__c = 'Test';
        acc7.Enrollment_Date__c = System.today() - 15;
        acc7.Preferred_Language__c='ENG';
        Insert acc7;
        
        Contact con1 = new Contact();
        con1.AccountId = acc7.Id;
        con1.LastName = 'Test';  
        con1.Assign_to_Sales_Cadence__c=false;
        Insert con1;
        
        con1.Master_Record_Id__c='TEST1';
        update con1;
        
        Opportunity opp7= new Opportunity();
        opp7.name='Test103';
        opp7.StageName='New';
        opp7.SFX_Welcome_Email__c=TRUE;
        opp7.ownerid=u2.id;
        opp7.RecordTypeId=sfxRecordTypeId;
        opp7.CloseDate=system.today();
        opp7.AccountId=acc7.id;
        insert opp7;
        
        //104 line else
        Account acc8 = new Account();
        acc8.Name = 'Test22104';
        acc8.TRM_Owner_Flag__c='No';
        acc8.Affiliated_Id__c = 1002277;    
        acc8.ownerid=UserInfo.getUserId();
        acc8.HC_Flag__c=True;
        acc8.Email__c='test2226@gmail.com';
        acc8.Preferred_Language__c='SPA';
        acc8.Enrollment_Date__c = System.today() - 31;
        Insert acc8;
        
        Contact con2 = new Contact();
        con2.AccountId = acc8.Id;
        con2.LastName = 'Test';  
        con2.Assign_to_Sales_Cadence__c=false;
        Insert con2;
        
        con2.Master_Record_Id__c='TEST2';
        update con2;
        
        Opportunity opp8= new Opportunity();
        opp8.name='Test101';
        opp8.StageName='Attempting to Contact 1';
        opp8.SFX_Welcome_Email__c=TRUE;
        opp8.ownerid= UserInfo.getUserId();
        opp8.RecordTypeId=sfxRecordTypeId;
        opp8.CloseDate=system.today();
        opp8.AccountId=acc8.id;
        insert opp8;
        
        Account acc9 = new Account();
        acc9.Name = 'Test12072024';
        acc9.Affiliated_Id__c = 1002277;    
        acc9.ownerid=u2.id;
        acc9.HC_Flag__c=True;
        acc9.Email__c='test12072024@gmail.com';
        acc9.Preferred_Language__c='SPA';
        acc9.Enrollment_Date__c = System.today() - 20;
        acc9.Original_Source__c = 'Test';
        Insert acc9;
        
        Opportunity opp9= new Opportunity();
        opp9.name='Test12072024';
        opp9.StageName='New';
        opp9.SFX_Welcome_Email__c=FALSE;
        opp9.ownerid=u2.id;
        opp9.RecordTypeId=sfxRecordTypeId;
        opp9.CloseDate=system.today();
        opp9.AccountId=acc9.id;
        insert opp9;
        
    } 
    @isTest 
    public static void assignOwnersTest() { 
        List<Opportunity> OppList = [SELECT Id,Name,Stagename,ownerId,Accountid,Account.HC_Flag__c,Account.Enrollment_Date__c,Account.TRM_Owner_Flag__c from opportunity WHERE Name Like 'Test%'];  
        // Set mock callout class     
        Test.setMock(HttpCalloutMock.class, new SFXOppBatchTestMock());  
        Test.startTest();
        SFXOppBatch ba= new SFXOppBatch();
        Id jobid= Database.executeBatch(ba,10);
        Test.stopTest();       
    } 
        
}