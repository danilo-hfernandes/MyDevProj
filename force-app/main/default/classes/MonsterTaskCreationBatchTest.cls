@isTest
public class MonsterTaskCreationBatchTest {
    
    @testSetup
    public static void setupEnvironment() {
        
        Account acc = new Account();
        acc.Name = 'Test';
        acc.Email__c='test1@gmail.com';
        acc.TRM_Owner_Flag__c='No';
        acc.Affiliated_Id__c = 1002277;  
        acc.HC_Flag__c=False;
        acc.Preferred_Language__c='SPA';
        acc.Enrollment_Date__c = System.today() - 10;
        acc.Member_Number__c = '142519-support@monsterrg.com';
        Insert acc;
        
        Id paRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Profit_Agility_Voucher').getRecordTypeId();
        
        Opportunity opp= new Opportunity();
        opp.name='Test';
        opp.Traveler_Name__c = 'Test';
        opp.StageName='Closed Won';
        opp.SFX_Welcome_Email__c=FALSE;        
        opp.RecordTypeId=paRecordTypeId;
        opp.CloseDate=system.today();
        opp.AccountId=acc.id;
        opp.Property__c = 'Mayan Palace';
        opp.Check_in__c = System.today().addDays(35);
        opp.Rooms__c = '1BR';
        insert opp;

        Contact con=new contact(opportunity__c=opp.Id,lastname='test',email='t@g.com',Affiliate_Name__c='test',Assign_to_Sales_Cadence__c=false,Match_Group_Name__c=null,accountid=acc.id);
        insert con;
        
        Opportunity opp2= new Opportunity();
        opp2.name='Test';
        opp2.Traveler_Name__c = 'Test';
        opp2.StageName='Closed Won';
        opp2.SFX_Welcome_Email__c=FALSE;        
        opp2.RecordTypeId=paRecordTypeId;
        opp2.CloseDate=system.today();
        opp2.AccountId=acc.id;
        opp2.Property__c = 'Mayan Palace';
        opp2.Check_in__c = System.today().addDays(45);
        opp2.Rooms__c = '1BR';
        insert opp2;
        
        Contact con2=new contact(opportunity__c=opp2.Id,lastname='test',email='t@g.com',Affiliate_Name__c='test',Assign_to_Sales_Cadence__c=false,Match_Group_Name__c=null,accountid=acc.id);
        insert con2;
        
        Opportunity opp3= new Opportunity();
        opp3.name='Test';
        opp3.Traveler_Name__c = 'Test';
        opp3.StageName='Closed Won';
        opp3.SFX_Welcome_Email__c=FALSE;        
        opp3.RecordTypeId=paRecordTypeId;
        opp3.CloseDate=system.today();
        opp3.AccountId=acc.id;
        opp3.Property__c = 'Mayan Palace';
        opp3.Check_in__c = System.today().addDays(60);
        opp3.Rooms__c = '1BR';
        insert opp3;

        Contact con3=new contact(opportunity__c=opp3.Id,lastname='test',email='t@g.com',Affiliate_Name__c='test',Assign_to_Sales_Cadence__c=false,Match_Group_Name__c=null,accountid=acc.id);
        insert con3;
        
        Opportunity opp4= new Opportunity();
        opp4.name='Test';
        opp4.Traveler_Name__c = 'Test';
        opp4.StageName='Closed Won';
        opp4.SFX_Welcome_Email__c=FALSE;        
        opp4.RecordTypeId=paRecordTypeId;
        opp4.CloseDate=system.today();
        opp4.AccountId=acc.id;
        opp4.Property__c = 'Mayan Palace';
        opp4.Check_in__c = System.today().addDays(90);
        opp4.Rooms__c = '1BR';
        insert opp4;
        
        Contact con4=new contact(opportunity__c=opp4.Id,lastname='test',email='t@g.com',Affiliate_Name__c='test',Assign_to_Sales_Cadence__c=false,Match_Group_Name__c=null,accountid=acc.id);
        insert con4;

    }
    
    @isTest 
    public static void assignOwnersTest() { 
        List<Opportunity> OppList = [SELECT Id,Name,Stagename,ownerId,Accountid,Account.HC_Flag__c,Account.Enrollment_Date__c,Account.TRM_Owner_Flag__c,(SELECT Id FROM Contacts__r) from opportunity WHERE Name Like 'Test%'];
        Test.setMock(HttpCalloutMock.class, new VoucherEmailActivationMock());        
        Test.startTest();
        MonsterTaskCreationBatch ba= new MonsterTaskCreationBatch();
        Id jobid= Database.executeBatch(ba,10);
        Test.stopTest();       
    } 
    
}