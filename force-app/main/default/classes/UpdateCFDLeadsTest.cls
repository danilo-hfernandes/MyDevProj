@isTest
public class UpdateCFDLeadsTest {
    
     @testSetup
    public static  void setupEnvironment() {
        
         Lead leadrec = new Lead();
        leadrec.LastName = 'test';
        leadrec.Company = 'test';
        leadrec.LeadSource = 'Vacation VIP - Web';
        leadrec.RecordTypeId='0123t000000dXngAAE';
        leadrec.Email = 'ds@ds.com';
        leadrec.Phone = '1234567890';
        leadrec.Is_Duplicate__c=false;
        insert leadrec;
        
           
    }
    
    @isTest 
    public static void assignOwnersTest() {
        Lead leadrec = new Lead();
        leadrec.LastName = 'test';
        leadrec.Company = 'test';
        leadrec.LeadSource = 'Vacation VIP - Web';
        leadrec.RecordTypeId='0123t000000dXngAAE';
        leadrec.Email = 'ds@ds.com';
        leadrec.Phone = '1234567890';
        leadrec.Is_Duplicate__c=false;
        insert leadrec;
        Test.startTest();
        UpdateCFDLeads ba= new UpdateCFDLeads();
        Id jobid= Database.executeBatch(ba,20);
        Test.stopTest(); 
    }

}