@isTest
public class TourGenActNewBatchControllerTest {
   @testSetup
        public static void setupEnvironment() {
            Account acc = new Account(Name = 'Rebook');
            insert acc;
            
            Contact con=new contact(lastname='test',email='t@g.com',Affiliate_Name__c='test',Parent_Id_Ext_Db__c=null,Assign_to_Sales_Cadence__c=false,Match_Group_Name__c=null,accountid=acc.id);
            insert con;
            
            acc.Parent_Child_Contact_Id__c=con.Id;
            update acc;
            
            Id voucherRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Voucher').getRecordTypeId();
            Opportunity opp1 = new Opportunity (Name='Rebook',StageName='Closed Won',Match_Group_Name__c='Voucher Email',CloseDate=Date.today(),Check_in__c =null, AccountId = acc.id,Reservation_Status__c=null, RecordTypeId = voucherRecordTypeId,confirmation_number__c=null);
            insert opp1;
              
        } 
        @isTest 
        public static void assignOpportunityTest() { 
            Test.setMock(HttpCalloutMock.class, new AssignContactInOverflowCadenceTestMock());  
            Test.startTest();
            TourGenActNewBatchController ba= new TourGenActNewBatchController();
            Id jobid= Database.executeBatch(ba,5);
            Test.stopTest();       
        }
    }