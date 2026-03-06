@isTest
public class VoucherEmailActivationTest {
    
    @testSetup
    public static void setupEnvironment() {
        
        Account acc = new Account(Name = 'Test Account32', Marketing_Email_opt_out__c = false);
        insert acc;
        
        Contact con=new contact(lastname='test',email='t@g.com',Affiliate_Name__c='test',Assign_to_Sales_Cadence__c=false,Match_Group_Name__c=null,accountid=acc.id);
        insert con;
        
        con.Master_Record_Id__c='test';
        update con;
        
        Id voucherRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Voucher').getRecordTypeId();
        
        Opportunity opp1 = new Opportunity (Name='test',StageName='Closed Won',Match_Group_Name__c='Voucher Email',CloseDate=Date.today(),Check_in__c =null, AccountId = acc.id,Reservation_Status__c=null, RecordTypeId = voucherRecordTypeId,First_Payment_Date__c=Date.newInstance(2024,01,02),Bypass_Cadence__c = false);
        
        insert opp1;
     } 
    @isTest 
    public static void assignOpportunityTest() {
        List<Opportunity> OliList = [SELECT Id,AccountId,name,Match_Group_Name__c,ownerid,Reservation_Status__c,Check_in__c,First_Payment_Date__c FROM Opportunity Where Name Like 'test%'];  
        // Set mock callout class     
        system.debug('71 test='+OliList);
        Test.setMock(HttpCalloutMock.class, new VoucherEmailActivationMock());  
        Test.startTest();
        VoucherEmailActivation ba= new VoucherEmailActivation();
        Id jobid= Database.executeBatch(ba,5);
        Test.stopTest();       
    }
}