@isTest
public class enrollmentQueueTriggerTest {
    
    @isTest
    static void Test1() {
        
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
     @isTest
    static void insertPayments() {
        
        Account acc = new Account(Name = 'Test Account', Affiliated_Id__c = 1235, Member_Number__c = '13523412',Email__c = 'abc@test.com');
        insert acc;
        
        
        Id VIReferralDateRequest = [Select id from RecordType where sObjectType = 'Opportunity' and Name ='RR Flex Date'].id ;
        Opportunity opp1 = new Opportunity (
            	Name='Opp1',StageName='Negotiation',CloseDate=Date.today(),
            AccountId = acc.id, Auto_Created_BU_Opp__c = true, RecordTypeId = VIReferralDateRequest);
        insert opp1;
        
        List<Opportunity> opplist = new List<Opportunity>();
        opplist.add(opp1);
        
         HSI_Enrollment_Queue__c hsi = New HSI_Enrollment_Queue__c();
        hsi.Primary_Phone__c = '1234567890';
        hsi.Email__c = 'abc@test.com';
        hsi.Record_Origin__c = 'VI MEX Referral';
        hsi.CC_Holder_Name__c = 'MM';
        hsi.AccountId__c = acc.Id;
        
        insert hsi;
        Map<Id,HSI_Enrollment_Queue__c> mapofIdHSI = new Map<Id,HSI_Enrollment_Queue__c>();
        mapofIdHSI.put(acc.Id,hsi);
        
         EnrollmentQueueHelper.insertPayments(opplist,mapofIdHSI);
        
    }
         
    
    /*
    @isTest
    static void Test2() {
        
        Account acc = new Account(Name = 'Test Account', Affiliated_Id__c = 1235, Member_Number__c = '13523412',Email__c = 'abc@test.com');
        insert acc;
        
        HSI_Enrollment_Queue__c hsi = New HSI_Enrollment_Queue__c();
        hsi.Primary_Phone__c = '1234567890';
        hsi.Email__c = 'abcddd@test.com';
        hsi.Record_Origin__c = 'VI MEX Referral';
        insert hsi;
    }
    
    @isTest
    static void Test3() {
        
        Account acc = new Account(Name = 'Test Account', Affiliated_Id__c = 1235, Member_Number__c = '13523412',Email__c = 'abc@test.com');
        insert acc;
        
        HSI_Enrollment_Queue__c hsi = New HSI_Enrollment_Queue__c();
        hsi.Primary_Phone__c = '1234567890';
        hsi.Email__c = 'abcddd@test.com';
        hsi.Record_Origin__c = 'RR Flex Date';
        insert hsi;
    }
	*/
}