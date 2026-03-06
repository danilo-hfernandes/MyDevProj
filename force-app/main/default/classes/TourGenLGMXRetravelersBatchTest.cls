@isTest
public class TourGenLGMXRetravelersBatchTest {
    @testSetup
    public static void setupEnvironment() {
        
        User u2=[SELECT Id,Assigned_Contacts__c FROM User where name ='Dev Account'];
        
        leadassist__MatchGroup__c mG= new leadassist__MatchGroup__c();
        mG.name='TourGen-LG MX Retravelers';
        insert mG;
        
        leadassist__Assignee__c assignee= new leadassist__Assignee__c();
        assignee.leadassist__MatchGroup__c=mG.id;
        assignee.leadassist__User__c=u2.id;
        insert assignee;
        
        Account acc = new Account(Name = 'Test Account32',Affiliated_Id__c = 1002445, Enrollment_Date__c = system.today().addDays(-15), email__c = 'test@gmail.com');
        insert acc;
        
        Contact con = new Contact(LastName = 'Test Contact', AccountId = acc.Id);
		insert con;
        
        Id voucherRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Voucher').getRecordTypeId();
                
        Opportunity opp1 = new Opportunity (Name='test',StageName='New',CloseDate=Date.today(),Check_in__c =null, AccountId = acc.id,Reservation_Status__c=null, RecordTypeId = voucherRecordTypeId, leadassist__Use_Round_Robin__c = 'FALSE',First_Payment_Date__c=Date.newInstance(2022,02,02));
        
        insert opp1;
        
    } 
    @isTest 
    public static void assignOpportunityTest() {
        //Account objacc = [select Id,Name,Preferred_Language__c,Ownerid,Affiliated_Id__c,Email__c,Email_2__c,Formatted_Phone__c,Formatted_Alternate_Phone__c from Account where Name Like 'Test%'];
        //Contact objcon = [select Id,Name from Contact where LastName Like 'Test%'];
        List<Opportunity> OliList = [SELECT Id,AccountId,name,Match_Group_Name__c,ownerid,Reservation_Status__c,Check_in__c,First_Payment_Date__c FROM Opportunity Where Name Like 'test%'];  
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new SFXGoldQueueableMock()); 
        Test.startTest();
        TourGenLGMXRetravelersBatchController ba= new TourGenLGMXRetravelersBatchController();
        Id jobid= Database.executeBatch(ba,5);
        Test.stopTest();       
    }
}