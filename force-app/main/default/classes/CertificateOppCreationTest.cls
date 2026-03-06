@isTest
public class CertificateOppCreationTest {
    
    @isTest
    static void Test1() {
        
        Account acc = new Account(Name = 'Test Account', Affiliated_Id__c = 1235, Member_Number__c = '13523412');
        insert acc;
        Id certificateOppRecType = [Select id from RecordType where sObjectType = 'Opportunity' and developerName ='Voucher' ].id ;
        Opportunity opp1 = new Opportunity (Name='Opp1',StageName='Negotiation',CloseDate=Date.today(), RecordTypeId = certificateOppRecType);
        insert opp1;
        
        VoucherOppCreation.isOpportunityCreated(acc.Id);
     
    }
}