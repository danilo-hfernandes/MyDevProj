@isTest
public class CloseCaseOBCampaignTest {
	static testmethod void test() {
        Id oppRecordTypeId = [Select id from RecordType where sObjectType = 'Opportunity' and developerName ='Voucher' ].id ;
       
        Account a = new Account();
        a.Name = 'test account';
        a.Member_Number__c = '5655656';
        insert a;
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Activation').getRecordTypeId();
        Case cs = New Case();
        cs.AccountId = a.Id;
        cs.RecordTypeId = recordTypeId;
        cs.Status = 'New';
        insert cs;
        
        Opportunity o = new Opportunity();
        o.name = 'test opp';
        o.CloseDate = System.today();
        o.AccountId = a.id;
        o.Opportunity_Closed_Date__c = DateTime.now() - 1;
        o.RecordTypeId = oppRecordTypeId;
        o.StageName = 'Closed Won';
        o.OB_Campaign_Case_Credated__c = True;
        o.Reservation_Status__c = 'Pending';
        
        insert o;
        
        
        Test.startTest();
        CloseCaseOBCampaign c = new CloseCaseOBCampaign();
        Database.executeBatch(c);
        Test.stopTest();
        
        
    }
}