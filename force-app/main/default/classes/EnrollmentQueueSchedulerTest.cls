@isTest
public class EnrollmentQueueSchedulerTest {
    
    @isTest
    static void Test1() {
        
        Account acc = new Account(Name = 'Test Account', Affiliated_Id__c = 1235, Member_Number__c = '13523412',Email__c = 'abc@test.com');
        insert acc;
        
        HSI_Enrollment_Queue__c hsi = New HSI_Enrollment_Queue__c();
        hsi.Primary_Phone__c = '1234567890';
        hsi.Email__c = 'abc@test.com';
        hsi.Record_Origin__c = 'VI MEX Referral';
        hsi.Created_By__c = 'SMTN Mexico';
        hsi.Failure_Count__c = 4;
        
        insert hsi;
        
        
        String CRON_EXP = '0 6 * * * ?';
        Test.startTest();

		String jobId = System.schedule('Update Contacts',  CRON_EXP, new EnrollmentQueueScheduler());
		CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        EnrollmentQueueScheduler eq = new EnrollmentQueueScheduler();
        eq.callhsiEnrollupdate();
		System.assertEquals(CRON_EXP, ct.CronExpression);
		System.assertEquals(0, ct.TimesTriggered);
		
		Test.stopTest();
    }
    
    @isTest
    static void Test2() {
        
        Account acc = new Account(Name = 'Test Account', Affiliated_Id__c = 1235, Member_Number__c = '13523412',Email__c = 'abc@test.com');
        insert acc;
        
        HSI_Enrollment_Queue__c hsi = New HSI_Enrollment_Queue__c();
        hsi.Primary_Phone__c = '1234567890';
        hsi.Email__c = 'abc@test.com';
        hsi.Record_Origin__c = 'VI MEX Referral';
        hsi.Failure_Count__c = 4;
        insert hsi;
        
        
        String CRON_EXP = '0 6 * * * ?';
        Test.startTest();

		String jobId = System.schedule('Update Contacts1',  CRON_EXP, new EnrollmentQueueScheduler());
		CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
		System.assertEquals(CRON_EXP, ct.CronExpression);
		System.assertEquals(0, ct.TimesTriggered);
		
		Test.stopTest();
    }

}