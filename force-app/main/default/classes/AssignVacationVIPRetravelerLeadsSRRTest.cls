@isTest
public class AssignVacationVIPRetravelerLeadsSRRTest {
    @isTest
    static void testCFD(){
        String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
        
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String guid = h.SubString(0,8); 
        
        UserRole r = new UserRole(DeveloperName = 'MyCustomRole', Name = 'CEO');
        insert r;
        
        User u = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
            Email = 'dev@nerdsoft.com',
            firstName='Dev',
            lastname='Account',
            Username = 'dev@nerdsoft.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            UserRoleId = r.Id
        );
        
        insert u;
        
        Id leadCFRecTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Carefree_Destinations').getRecordTypeId();
        
        Test.setMock(HttpCalloutMock.class, new AssigningContactInCadenceTestMock());
        
        System.RunAs(u){
            
            List<Lead> leadRecords = new List<Lead>();
            Lead leadrec = new Lead();
            leadrec.Status = 'New';
            leadrec.Email = 'test@test1.com';
            leadrec.LastName = 'test';
            leadrec.Company = 'VVIPR';
            leadrec.LeadSource = 'Vacation VIP Retraveler';
            leadrec.Phone = '1234567891';
            leadrec.RecordTypeId = leadCFRecTypeId;
            
            leadRecords.add(leadrec);
            
            insert leadRecords;            
            
        }
        
        Lead VVIPRLead = [SELECT Id,Owner.Name,Status,RecordTypeId,First_Action_Cadence_Id__c,IsConverted FROM Lead WHERE LeadSource = 'Vacation VIP Retraveler' LIMIT 1];
        System.debug('VVIPRLead = '+VVIPRLead);
        //Test.setCreatedDate(CFDGoogleLead.Id, System.now().addMinutes(-16));
        
        Test.startTest();        
        
        AssignVacationVIPRetravelerLeadsSRR ba= new AssignVacationVIPRetravelerLeadsSRR();
        Id jobid= Database.executeBatch(ba);
        Test.StopTest();
    }
    
}