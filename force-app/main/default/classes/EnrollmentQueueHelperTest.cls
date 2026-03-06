@isTest
public class EnrollmentQueueHelperTest {
    
    @isTest
    static void Test1() {
        
        Account acc = new Account(Name = 'Test Account', Affiliated_Id__c = 1235, Member_Number__c = '13523412',Email__c = 'abc@test.com');
        insert acc;
        
        HSI_Enrollment_Queue__c hsi = New HSI_Enrollment_Queue__c();
        hsi.Primary_Phone__c = '1234567890';
        hsi.Email__c = 'abc@test.com';
        hsi.Record_Origin__c = 'VI MEX Referral';
        insert hsi;
    }
	@isTest
    static void Test2() {
        
        Account acc = new Account(Name = 'Test Account', Affiliated_Id__c = 1235, Member_Number__c = '13523412',Email__c = 'abwc@test.com',Phone= '1234567890', Affiliate_Name__c = 'Vacation Innovations Referral');
        insert acc;
        
        HSI_Enrollment_Queue__c hsi = New HSI_Enrollment_Queue__c();
        hsi.Primary_Phone__c = '1234567890';
        hsi.Email__c = 'abc@test.com';
        hsi.Record_Origin__c = 'VI MEX Referral';
        insert hsi;
    }
   @isTest
    static void Test3() {
        
        Account acc = new Account(Name = 'Test Account', Affiliated_Id__c = 1235, Member_Number__c = '13523412',Email__c = 'abwc@test.com',Phone= '1234567892', Affiliate_Name__c = 'Vacation Innovations Referral');
        insert acc;
        
        HSI_Enrollment_Queue__c hsi = New HSI_Enrollment_Queue__c();
        hsi.Primary_Phone__c = '1234567890';
        hsi.Email__c = 'abc@test.com';
        hsi.Record_Origin__c = 'VI MEX Referral';
        insert hsi;
    }
    @isTest
    static void hcSelfEnrollmentTest(){       
        HSI_Enrollment_Queue__c hsi = New HSI_Enrollment_Queue__c();
        hsi.Primary_Phone__c = '1234567890';
        hsi.Email__c = 'abc@test.com';
        hsi.Record_Origin__c = 'HC Self Enrollment';
        hsi.First_Name__c = 'First Name';
        hsi.Last_Name__c = 'Last Name';
        hsi.City__c = 'Elmont';
        hsi.Address__c = '1 Meacham Ave';
        hsi.Country__c = 'United States of America';
        hsi.State__c = 'NY';
        hsi.Zip_Code__c = '11003';
        hsi.Alternate_Phone__c = '1234567891';
        hsi.Member_Number__c = '13523412';
        hsi.Preferred_Language__c = 'ENG';
        insert hsi;
    }
    @isTest
    static void Test4() {
        
        Account acc = new Account(Name = 'Test Account', Affiliated_Id__c = 1235, Member_Number__c = '13523412',Email__c = 'abc@test.com');
        insert acc;
        
        HSI_Enrollment_Queue__c hsi = New HSI_Enrollment_Queue__c();
        hsi.Primary_Phone__c = '1234567890';
        hsi.Email__c = 'abc@test.com';
        hsi.Record_Origin__c = 'VI MEX Referral';
        insert hsi;
        EnrollmentQueueHelper.insertAccount(hsi);
    }
    @isTest
    static void insertOpportunityLineItem() {
        
        Account acc = new Account(Name = 'Test Account', Affiliated_Id__c = 1235, Member_Number__c = '13523412',Email__c = 'abc@test.com');
        insert acc;
        
        
        Id VIReferralDateRequest = [Select id from RecordType where sObjectType = 'Opportunity' and Name ='VI Referral Date Request' ].id ;
        Opportunity opp1 = new Opportunity (
            Name='Opp1',StageName='Negotiation',CloseDate=Date.today(),
            Upgrade_Type__c = 'My Travel Rewards Club Silver', AccountId = acc.id, Auto_Created_BU_Opp__c = true, RecordTypeId = VIReferralDateRequest);
        insert opp1;
        List<Opportunity> opplist = new List<Opportunity>();
        opplist.add(opp1);
        
        
        EnrollmentQueueHelper.insertOpportunityLineItem(opplist);
        
    }
}