@isTest
public class TourGenRebookTest {
    
    @testSetup
    public static void setupEnvironment() {
        Account acc = new Account(Name = 'Rebook');
        insert acc;
        
        Contact con=new contact(lastname='test',email='t@g.com',Affiliate_Name__c='test',Parent_Id_Ext_Db__c=null,Assign_to_Sales_Cadence__c=false,Match_Group_Name__c=null,accountid=acc.id);
        insert con;
        
        con.Master_Record_Id__c='test';
        update con;
        
        Id voucherRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Voucher').getRecordTypeId();
        
        Opportunity opp1 = new Opportunity (Name='Rebook',StageName='Closed Won',Match_Group_Name__c='Voucher Email',CloseDate=Date.today(),Check_in__c =null, AccountId = acc.id,Reservation_Status__c=null, RecordTypeId = voucherRecordTypeId,confirmation_number__c=null);
        
        insert opp1;
        
        Reservation_Tracking_Object__c rto=new Reservation_Tracking_Object__c(Reservation_Status__c='Cancel',Opportunity__c=opp1.id);
        insert rto;

        
    } 
    @isTest 
    public static void assignOpportunityTest() {
        // List<Opportunity> OliList = [SELECT Id,AccountId,name,Match_Group_Name__c,ownerid,Reservation_Status__c,Check_in__c,First_Payment_Date__c FROM Opportunity Where Name Like 'test%'];  
        // Set mock callout class     
        //system.debug('71 test='+OliList);
        Test.setMock(HttpCalloutMock.class, new TourGenRebookMock());  
        Test.startTest();
        TourGenRebook ba= new TourGenRebook();
        Id jobid= Database.executeBatch(ba,5);
        Test.stopTest();       
    }
}