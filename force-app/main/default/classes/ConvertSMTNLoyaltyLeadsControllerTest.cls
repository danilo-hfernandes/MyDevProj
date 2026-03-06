@isTest
public class ConvertSMTNLoyaltyLeadsControllerTest {
  @isTest
    static void testRecords(){
      Id smtnOpenLeadId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('SMTN_Open_Lead').getRecordTypeId();
      
      Lead leadrec = new Lead();
        leadrec.LastName = 'test';
        leadrec.Company = 'test';
        leadrec.LeadSource = 'SMTN Open Lead - 1 year';
        leadrec.RecordTypeId = smtnOpenLeadId;
        leadrec.Email = 'testLead@viref.com';
        leadrec.Phone = '1791657825';
        leadrec.Street = 'Test Street 1';
        leadrec.City = 'Test City';
        leadrec.State = 'CA';
        leadrec.Country = 'US';
        leadrec.PostalCode = '1234';
      
      insert leadrec;
  }
}