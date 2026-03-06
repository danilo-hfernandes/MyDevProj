@isTest
public class ClubGlobalExplorerVWOppAssignmentTest {
    @testSetup
    public static void setupEnvironment() {
        
        User u2=[SELECT Id,Assigned_Contacts__c FROM User where name ='Integration Systems'];
        
        Account acc = new Account(Name = 'Test Account32',Affiliated_Id__c = 1002459, Enrollment_Date__c = system.today().addDays(-15), email__c = 'test@gmail.com');
        insert acc;
        
        Id voucherRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Club_Global_Explorer').getRecordTypeId();
        User u3=[SELECT Id,Assigned_Contacts__c FROM User where name ='Dev Account'];
                
        Opportunity opp1 = new Opportunity (Name='test', LeadSource = 'Puerto Magico-Carnival',StageName='New', Ownerid = u3.id, CloseDate=Date.today(),Check_in__c =null, AccountId = acc.id,Reservation_Status__c=null, RecordTypeId = voucherRecordTypeId,First_Payment_Date__c=Date.newInstance(2022,02,02));
        
        insert opp1;
                
    } 
    @isTest 
    public static void assignOpportunityTest() {
        Account objacc = [select Id,Name,Preferred_Language__c,Ownerid,Affiliated_Id__c,Email__c,Email_2__c,Formatted_Phone__c,Formatted_Alternate_Phone__c from Account where Name Like 'Test%'];
        List<Opportunity> OliList = [SELECT Id,AccountId,name,Match_Group_Name__c,ownerid,Reservation_Status__c,Check_in__c,First_Payment_Date__c FROM Opportunity Where Name Like 'test%'];  
        // Set mock callout class     
        system.debug('71 test='+OliList);Test.startTest();
         ClubGlobalExplorerVWOppCreation ba1= new ClubGlobalExplorerVWOppCreation();
        Id jobid1= Database.executeBatch(ba1,5);
        ClubGlobalExplorerVWOppAssignment ba= new ClubGlobalExplorerVWOppAssignment();
        Id jobid= Database.executeBatch(ba,5);
        Test.stopTest();       
    }
    
}