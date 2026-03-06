@isTest
public class LuxGiveOpenVoucherReengagementTest {

    @testSetup
    public static void setupEnvironment() {
        
        Account acc = new Account(Name = 'Test Account32',LuxGive_Order_Id__c = '12345Test', Affiliated_Id__c = 1002432);
        insert acc;
        
        Contact con=new contact(lastname='test',email='t@g.com',Affiliate_Name__c='LuxGive Voucher',Assign_to_Sales_Cadence__c=false,Match_Group_Name__c=null,accountid=acc.id);
        insert con;
        
        acc.Parent_Child_Contact_Id__c = con.Id;
        
        update acc;
        
        con.Master_Record_Id__c='test';
        update con;
        
        Id voucherRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Voucher').getRecordTypeId();
                
        Opportunity opp1 = new Opportunity (Name='test',StageName='Closed Won',Match_Group_Name__c='Voucher Email',CloseDate =Date.today().addDays(-60),Check_in__c =null, AccountId = acc.id,Reservation_Status__c=null, RecordTypeId = voucherRecordTypeId, First_Payment_Date__c=Date.newInstance(2022,02,02));
        
        insert opp1;
        
    } 
    @isTest 
    public static void assignOpportunityTest() {
        List<Opportunity> OliList = [SELECT Id,AccountId,name,Match_Group_Name__c,ownerid,Reservation_Status__c,Check_in__c,First_Payment_Date__c,Opportunity_Closed_Date__c FROM Opportunity Where Name Like 'test%'];  
        // Set mock callout class     
        system.debug('71 test='+OliList);
        //Test.setMock(HttpCalloutMock.class, new VoucherEmailActivationMock());  
        Test.startTest();
        LuxGiveOpenVoucherReengagementBatch ba= new LuxGiveOpenVoucherReengagementBatch();
        Id jobid= Database.executeBatch(ba,5);
        Test.stopTest();       
    }
}