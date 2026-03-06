@isTest
public class UpdateCaseOwnerBatch_Test {
    static testMethod void eastCoastTest(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Voucher_Sales').getRecordTypeId();
        
        Account acc = new Account();
        acc.Name = 'trest';
        acc.BillingState = 'CT';
        insert acc;
        
        Case rec = new Case();
        rec.Subject = 'test';
        rec.RecordTypeId = recordTypeId;
        rec.OwnerId = Label.EastCoastQueueId;
        rec.AccountId = acc.Id;
        insert rec;
        
        Test.startTest();
        UpdateCaseOwnerBatch ba= new UpdateCaseOwnerBatch();
        Id jobid= Database.executeBatch(ba,5);
        Test.stopTest();
        Case caserec = [select OwnerId from Case where id =: rec.Id];
        system.assertEquals(Label.EastCoastQueueId, caserec.OwnerId);
    }
    
    static testMethod void westCoastTest(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Voucher_Sales').getRecordTypeId();
        
        Account acc = new Account();
        acc.Name = 'trest';
        //acc.BillingState = 'CT';
        insert acc;
        
        Case rec = new Case();
        rec.Subject = 'test';
        rec.RecordTypeId = recordTypeId;
        rec.OwnerId = Label.WestCoastQueueId;
        rec.AccountId = acc.Id;
        insert rec;
        
        Test.startTest();
                 UpdateCaseOwnerBatchScheduler sh1 = new UpdateCaseOwnerBatchScheduler();      
 		String sch = '0 0 23 * * ?';
        system.schedule('Test check', sch, sh1);
        //CloseCaseOBCampaign c = new CloseCaseOBCampaign();
        //Database.executeBatch(c);
        Test.stopTest();
        /*
        UpdateCaseOwnerBatch ba= new UpdateCaseOwnerBatch();
        Id jobid= Database.executeBatch(ba,5);
        Test.stopTest();
        Case caserec = [select OwnerId from Case where id =: rec.Id];
        system.assertEquals(Label.WestCoastQueueId, caserec.OwnerId); */
    }
}