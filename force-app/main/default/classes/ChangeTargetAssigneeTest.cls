@isTest(SeeAllData=true)
public class ChangeTargetAssigneeTest {
    @isTest 
    public static void assignOwnersTest() {
        List<Contact> conList = [Select id,Same_Name_as_Account_Name__c, Master_Record_Id__c, Assign_to_Sales_Cadence__c,Account.Enrollment_Date__c,Account.Membership_Status__c,Account.Affiliated_Id__c,SMTN_Loyalty_Campaign_SSR_Match_Group__c  From Contact WHERE ownerid='0053t000009j8Z3AAI' and actioncadenceid='77C3t000000XwNgEAK'];  
        // Set mock callout class     
        Test.setMock(HttpCalloutMock.class, new ChangeTargetAssigneeTestMock());  
        Test.startTest();
        ChangeTargetAssignee ba= new ChangeTargetAssignee();
        Id jobid= Database.executeBatch(ba,20);
        Test.stopTest();        
    }
}