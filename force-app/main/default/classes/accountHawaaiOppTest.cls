@isTest
public class accountHawaaiOppTest {
    
    @testSetup
    public static void setupEnvironment() {
        
        list<Account> acclist= new lisT<Account>();
        
        for(Integer i=0;i<250;i++){
            
            Account acc = new Account();
            acc.Name = 'Name';
            acc.Phone='123456789'+ i;
            acc.Affiliated_Id__c =1002243;
            acc.Enrollment_Date__c = System.today();
            acc.Membership_Status__c='Active';
            acclist.add(acc);
            
        }
        insert acclist;
        
         MU_Jobs_test_Record_Filter__c obj = new MU_Jobs_test_Record_Filter__c();
        obj.Name = 'Filters Enabled';
        obj.Hawaii_Collection__c = true;
        insert obj;
        
        
    } 
    @isTest 
    public static void assignOwnersTest() {
        List<Account> accList = [Select id,name,phone From Account WHERE Name Like 'Name%'];
        
       
        
        // Set mock callout class     
        
        Test.startTest();
        
        accountHawaaiOpp ba= new accountHawaaiOpp();
        Id jobid= Database.executeBatch(ba,250);
        Test.stopTest();       
    }
    
    
}