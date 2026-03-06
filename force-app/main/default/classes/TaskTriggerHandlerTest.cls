@isTest(seeAllData=true)
public class TaskTriggerHandlerTest {
	@isTest
    static void Test1() {
        Account acc = new Account(Name = 'Test Account', Affiliated_Id__c = 1235, Member_Number__c = '13523412');
        insert acc;
        Id travelOppRecType = [Select id from RecordType where sObjectType = 'Opportunity' and developerName ='Travel' ].id ;
        Opportunity opp1 = new Opportunity (Name='Opp1',StageName='Negotiation',CloseDate=Date.today(), AccountId = acc.id, RecordTypeId = travelOppRecType);
        insert opp1;
        Id devRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Replacement Property Request').getRecordTypeId();
        Id taskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Inventory Replacement Request').getRecordTypeId();
        
        Task taskCreate = new Task(WhatId = opp1.Id,Status = 'New',Priority = 'Normal',Subject = 'Dummy subject' ,ActivityDate = system.today(), RecordTypeId =taskRecordTypeId );
		insert taskCreate;
        Task taskCreate2 = new Task(WhatId = opp1.Id,Status = 'New',Priority = 'Normal',Subject = 'Dummy subject' ,ActivityDate = system.today(), RecordTypeId =devRecordTypeId );
		insert taskCreate2;
        
        taskCreate2.Status = 'Rejected';
        update taskCreate2;
    }
}