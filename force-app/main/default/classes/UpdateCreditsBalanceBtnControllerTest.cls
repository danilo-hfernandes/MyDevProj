@IsTest
public class UpdateCreditsBalanceBtnControllerTest {
    
    static testMethod void Test1() {
        
        Account acc = new Account(Name = 'Test Account', Affiliated_Id__c = 1235, Member_Number__c = '13523412', Membership_Annual_Due__c = 149, First_Name__c ='Test' , Last_Name__c = 'Account');
        insert acc;
        
        Account AccountFromGet = UpdateCreditsBalanceBtnController.getAccountData(acc.Id);
            
        Test.setMock(HttpCalloutMock.class, new ApplyCreditsControllerTest.MockGetMemberCreditsHttpResponseGenerator());
        Test.startTest();
        
        Map<String,String> result = UpdateCreditsBalanceBtnController.updateAccountCredits(acc.Id);
        
        Test.stopTest();
    }

}