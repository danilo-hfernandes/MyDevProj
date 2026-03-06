@isTest
public class GenericBatchClassToupdateRecordsTest {
    @isTest 
    public static void runTest() {
        Id leadCFRecTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Carefree_Destinations').getRecordTypeId();
        Lead leadrec = new Lead();
        leadrec.Status = 'New';
        leadrec.Email = 'test@test1.com';
        leadrec.LastName = 'test';
        leadrec.Company = 'test';
        leadrec.LeadSource = 'CFD FB';
        leadrec.Phone = '1234567891';
        leadrec.RecordTypeId = leadCFRecTypeId;
        leadrec.HasOptedOutOfEmail = true;
        insert leadrec;
        
        GenericBatchClassToupdateRecords sc = new GenericBatchClassToupdateRecords('Lead');
        string cronExp = '0 0 22 * * ? *';
        string JobId = system.schedule('Records Update Email Opt Out', cronExp, sc);
        database.executebatch(new GenericBatchClassToupdateRecords('Lead'),1);
    }
}