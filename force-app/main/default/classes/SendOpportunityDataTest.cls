@isTest
public class SendOpportunityDataTest {

    @isTest
    public static void sendData(){
        
        
        List<Id> recordIds = new List<Id>();
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        
        Opportunity opp1 = new Opportunity (FBCLID__c = '66fa1d4f-07f0-4e1d-9690-0b07ed745154',Name='Opp1',Amount=100,StageName='Closed Won',CloseDate=Date.today(), Upgrade_Type__c = '', AccountId = acc.id, Auto_Created_BU_Opp__c = true);
        insert opp1;
        recordIds.add(opp1.Id);
        

        test.startTest();
        Test.setMock(HttpCalloutMock.class, new SendOpportunityDataMock());
        SendOpportunityData.sendOppData(recordIds);
        SendOpportunityData.callFutureMethod(recordIds);
        test.stopTest();
        system.assert(opp1.StageName=='Closed Won');
    }
}