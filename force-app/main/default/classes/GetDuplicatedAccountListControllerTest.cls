@isTest
public class GetDuplicatedAccountListControllerTest {
    
    @isTest
    static void testLeadWithoutLead_Source_Settings() {
        
        Affiliate_Id__c aff = new Affiliate_Id__c();
        aff.Affiliate_Id__c = '1002261';
        aff.Affiliate_Name__c = 'Vacation Innovations Referral';
        aff.Send_Email__c = false;
        insert aff;
        
        /*Lead_Source_Settings__c ldSettings = new Lead_Source_Settings__c();
        ldSettings.Affiliate_Id__c = aff.Id;
        ldSettings.Lead_Source__c = 'VI Referral';
        insert ldSettings;*/
        
        Id leadVIRefRecTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('VI_Referral').getRecordTypeId();
        Lead leadrec = new Lead();
        leadrec.LastName = 'test';
        leadrec.Company = 'TESTeXAbXib';
        leadrec.LeadSource = 'VI Referral';  //avoid duplication alert, to get in the duplication trigger validation rule
        leadrec.RecordTypeId = leadVIRefRecTypeId;
        leadrec.Email = 'ds1@viref.com';
        leadrec.Phone = '1791657825';
        leadrec.Street = 'Test Street 1';
        leadrec.City = 'Test City';
        leadrec.State = 'CA';
        leadrec.Country = 'US';
        leadrec.PostalCode = '1234';
        leadrec.Match_Affiliate_Id__c = 1002261;  //avoid duplication alert, to get in the duplication trigger validation rule
        insert leadrec;
        
        GetDuplicatedAccountListController.GetAccount(leadrec.Id);
    }
    
    @isTest
    static void testDuplicatedAccountsSearch() {
        
        /*Lead_Source_Settings__c ldSettings = new Lead_Source_Settings__c();
        ldSettings.Affiliate_Id__c = aff.Id;
        ldSettings.Lead_Source__c = 'VI Referral';
        insert ldSettings;*/
        
        Account a = new Account();
        a.Name = 'test account';
        a.Email__c = 'abcTesthtngo@nerdsoft.com';
        a.Affiliated_Id__c = 1002266;
        a.Phone = '14234000167';
        a.Preferred_Language__c = 'ENG';        
        insert a;
        
        Account a1 = new Account();
        a1.Name = 'test account';
        a1.Phone = '1424444167';
        a1.Email_2__c = 'abcTesthtngo@nerdsoft.combcaTesthtngo@nerdsoft.com';
        a1.Affiliated_Id__c = 1002243;
        a1.Preferred_Language__c = 'ENG';
        insert a1;
        
        Account a2 = new Account();
        a2.Name = 'test account';
        a2.Phone = '4234000167';
        a2.Affiliated_Id__c = 9999999;
        a2.Preferred_Language__c = 'ENG';
        insert a2;
        
        Map<String,List<Account>> duplicatedAccountsMap = GetDuplicatedAccountListController.GetAccounts(a.Id);
        List<Account> duplicatedAccounts = duplicatedAccountsMap.get('We found no potential duplicated accounts.');
        System.AssertEquals(2,duplicatedAccounts.size());        
    }

}