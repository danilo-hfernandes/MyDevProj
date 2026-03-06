@isTest 
public class DeleteRecordBatchTest 
{
    static testMethod void testMethod1() 
    {
        List<Deleted_Record__c> lstRec= new List<Deleted_Record__c>();
        for(Integer i=0 ;i <200;i++)
        {
            Deleted_Record__c rec = new Deleted_Record__c();
            rec.Created_Date__c = date.today().addDays(-2);
            lstRec.add(rec);
        }
        
        insert lstRec;
        
        Test.startTest();

            DeleteRecordBatch obj = new DeleteRecordBatch();
            DataBase.executeBatch(obj); 
            
        Test.stopTest();
    }
}