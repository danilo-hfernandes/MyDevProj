@isTest
public class TourGenVidaTravelersOneTimeBatchTest {
    @isTest
    public static void setupEnvironment() {
        List<Opportunity> oppList = new List<Opportunity>();
                
        Account acc = new Account();
        acc.Name = 'Test';
        acc.Enrollment_Date__c = System.today() - 80;
        Insert acc;
        
        Contact con = new Contact();
        con.AccountId = acc.Id;
        con.Preferred_Language__c='ENG';
        con.LastName = 'Test';  
        con.AffiliatedId__c = 1002243;
        con.Affiliate_Name__c='test';
        con.Assign_to_Sales_Cadence__c=false;
        con.Membership_Status__c='Active';
        Insert con;
        
        Id voucherRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('VI_Referral_Date_Request').getRecordTypeId();
        Opportunity opp1= new Opportunity();
        opp1.name='test22';
        opp1.accountId=acc.Id;
        opp1.CloseDate=system.today();
        opp1.StageName='Attempting to Contact 2';
        opp1.Arrived__c=true;
        opp1.Check_in__c=System.today().addDays(-60);
        opp1.RecordTypeId=voucherRecordTypeId;
        opp1.Bypass_Cadence__c = false;
        insert opp1;     
        
        oppList.add(opp1);
        
        
        Contact conList = [SELECT id, Master_Record_Id__c FROM Contact WHERE LastName = 'Test' LIMIT 1];  
        
        conList.Master_Record_Id__c='test';
        update conList;
        set<Id> cadenceContactsId = new set<Id>();
        
        cadenceContactsId.add(conList.Id);
        
        // Set mock callout class     
        Test.setMock(HttpCalloutMock.class, new AssignContactInTourGenCadenceTestMock());  
        Test.startTest();
        TourGenVidaTravelersOneTimeBatch ba= new TourGenVidaTravelersOneTimeBatch();
        Database.executeBatch(ba);
        System.enqueueJob(new AssignContactInTourGenVidaQueueable(cadenceContactsId));
        Test.stopTest();
        
    } 
    
    
}