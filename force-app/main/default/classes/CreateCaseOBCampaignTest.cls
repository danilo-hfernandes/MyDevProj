@isTest
public class CreateCaseOBCampaignTest {
    static testmethod void test() {
        Id oppRecordTypeId = [Select id from RecordType where sObjectType = 'Opportunity' and developerName ='Voucher' ].id ;
       
        Account a = new Account();
        a.Name = 'test account';
        a.Member_Number__c = '5655656';
        
        
        
        insert a;
        
        Opportunity o = new Opportunity();
        o.name = 'test opp';
        o.CloseDate = System.today().addDays(-20);
        o.AccountId = a.id;
        o.Opportunity_Closed_Date__c = DateTime.now() - 1;
        o.RecordTypeId = oppRecordTypeId;
        o.StageName = 'Closed Won';
        
        insert o;
        
        
        Test.startTest();
        CreateCaseOBCampaign c = new CreateCaseOBCampaign();
        Database.executeBatch(c);
        Test.stopTest();
        
        
    }
}