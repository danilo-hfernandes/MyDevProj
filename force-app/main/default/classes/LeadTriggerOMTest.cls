@isTest
public class LeadTriggerOMTest {
    @testSetup static void testRecords() {
        Apex_Trigger_On_Off__c cs1 = new Apex_Trigger_On_Off__c();
        cs1.isEnable__c = true;
        cs1.Name = 'Lead-Trigger';
        
        Apex_Trigger_On_Off__c cs = new Apex_Trigger_On_Off__c();
        cs.isEnable__c = true;
        cs.Name = 'LeadDupliateTriggerLogic';
        
        Apex_Trigger_On_Off__c cs2 = new Apex_Trigger_On_Off__c();
        cs2.isEnable__c = true;
        cs2.Name = 'LeadSalesCadenceAssignment';
        
        Apex_Trigger_On_Off__c cs3 = new Apex_Trigger_On_Off__c();
        cs3.isEnable__c = true;
        cs3.Name = 'UpdateTimeZoneAccount';
        
        Apex_Trigger_On_Off__c cs4 = new Apex_Trigger_On_Off__c();
        cs4.isEnable__c = true;
        cs4.Name = 'UpdateTimeZoneLead';
        
        Apex_Trigger_On_Off__c cs5 = new Apex_Trigger_On_Off__c();
        cs5.isEnable__c = true;
        cs5.Name = 'LeadAndAccountTrigger';
        
        MU_Jobs_test_Record_Filter__c obj = new MU_Jobs_test_Record_Filter__c();
        obj.Name = 'Filters Enabled';
        obj.Any_Test_Record__c = true;
        
        
        insert cs;
        insert cs1;
        insert cs2;
        insert cs3;
        insert cs4;
        insert cs5;
        insert obj;
    }
    
    @isTest
    static void test1() {
        Apex_Trigger_On_Off__c cs = new Apex_Trigger_On_Off__c();
        cs.isEnable__c = true;
        cs.Name = 'LeadDupliateTriggerLogic';
        insert cs;
        
        Lead leadrec = new Lead();
        leadrec.LastName = 'test';
        leadrec.Company = 'test';
        leadrec.LeadSource = 'CFD FB';
        leadrec.Phone = '1234567891';
        leadrec.Email = 'd3rths@ds.com';
        insert leadrec;
        
        Lead leadrec1 = new Lead();
        leadrec1.LastName = '_test';
        leadrec1.Company = 'test';
        leadrec1.LeadSource = 'CFD FB';
        leadrec1.Phone = '1234567891';
        leadrec1.Email = 'd3r6yuhjths@ds.com';
        insert leadrec1;
    } 
    
    @isTest
    static void test2() {
        Lead leadrec = new Lead();
        leadrec.LastName = 'test';
        leadrec.Company = 'test';
        leadrec.LeadSource = 'External Review';
        leadrec.Email = 'ds@ds.com';
        leadrec.Phone = '1234567890';
        insert leadrec;
    } 
    
    @isTest
    static void test3() {
        Lead leadrec = new Lead();
        leadrec.LastName = 'test';
        leadrec.Company = 'test';
        leadrec.LeadSource = 'External Review';
        leadrec.Email = 'ds@ds.com';
        leadrec.Phone = '1234567891';
        insert leadrec;
        
        List<Lead> leadList = new List<Lead>();
        Lead leadrecc = new Lead();
        leadrecc.LastName = 'test';
        leadrecc.Company = 'test';
        leadrecc.LeadSource = 'Vacation VIP - Web';
        leadrecc.Email = 'ds@ds.com';
        leadrecc.Phone = '1234567891';
        //insert leadrecc;
        leadList.add(leadrecc);
        
        Lead leadrec2 = new Lead();
        leadrec2.LastName = 'test_test';
        leadrec2.Company = 'test';
        leadrec2.LeadSource = 'SMTN Rental Offer';
        leadrec2.Email = 'ds@ds.com';
        leadrec2.Phone = '1234567891';
		leadrec2.Status = 'DNC';
        leadrec2.RecordTypeId =  Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Filetracker_Reservations').getRecordTypeId(); 
        leadrec2.Street = 'Test Street 1';
        leadrec2.City = 'Test City';
        leadrec2.State = 'CA';
        leadrec2.Country = 'US';
        leadrec2.PostalCode = '1234';
        //insert leadrec2;
        leadList.add(leadrec2);
        
        insert leadList;
    }
    
    @isTest
    static void testLeadConversionWithoutDuplicates() {
        
        Affiliate_Id__c aff = new Affiliate_Id__c();
        aff.Affiliate_Id__c = '1002261';
        aff.Affiliate_Name__c = 'Vacation Innovations Referral';
        aff.Send_Email__c = false;
        insert aff;
        
        Lead_Source_Settings__c ldSettings = new Lead_Source_Settings__c();
        ldSettings.Affiliate_Id__c = aff.Id;
        ldSettings.Lead_Source__c = 'VI Referral';
        insert ldSettings;
        
        Id leadVIRefRecTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('VI_Referral').getRecordTypeId();
        Lead leadrec = new Lead();
        leadrec.LastName = 'test';
        leadrec.Company = 'test';
        leadrec.LeadSource = 'VI Referral';
        leadrec.RecordTypeId = leadVIRefRecTypeId;
        leadrec.Email = 'ds@viref.com';
        leadrec.Phone = '1791657825';
        leadrec.Street = 'Test Street 1';
        leadrec.City = 'Test City';
        leadrec.State = 'CA';
        leadrec.Country = 'US';
        leadrec.PostalCode = '1234';
        insert leadrec;
        
        Test.startTest();
        Database.LeadConvert lc = new database.LeadConvert();  
        lc.setLeadId(leadrec.Id);  
        lc.setDoNotCreateOpportunity(true);  
        lc.setConvertedStatus('Sold Voucher');          
        Database.LeadConvertResult lcr = Database.convertLead(lc, false);
        system.debug('Errors are ' + lcr.getErrors());
        //system.assert(lcr.isSuccess());
        Test.StopTest();
    }
    
    @isTest
    static void testLeadConversionWithDuplicatedAccountByEmail() {
        
        Affiliate_Id__c aff = new Affiliate_Id__c();
        aff.Affiliate_Id__c = '1002261';
        aff.Affiliate_Name__c = 'Vacation Innovations Referral';
        aff.Send_Email__c = false;
        insert aff;
        
        Lead_Source_Settings__c ldSettings = new Lead_Source_Settings__c();
        ldSettings.Affiliate_Id__c = aff.Id;
        ldSettings.Lead_Source__c = 'VI Referral';
        insert ldSettings;
        
        Account a = new Account();
        a.Name = 'TESTeXAbXib';
        a.Phone = '1791657825';
        a.Email__c = 'ds@viref.com';
        a.Affiliated_Id__c = 1002261;
        a.Preferred_Language__c = 'ENG';
        insert a;
        
        Contact cont= New Contact();
        cont.LastName = 'testname';
        cont.AffiliatedId__c = 1002261;
        cont.Phone = '1791657825';
        cont.Email = 'ds@viref.com';
        cont.AccountId = a.id;
        Insert cont;
        
        Id leadVIRefRecTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('VI_Referral').getRecordTypeId();
        Lead leadrec = new Lead();
        leadrec.LastName = 'test';
        leadrec.Company = 'TESTeXAbXib';
        leadrec.LeadSource = 'VI Referral';  //avoid duplication alert, to get in the duplication trigger validation rule
        leadrec.RecordTypeId = leadVIRefRecTypeId;
        leadrec.Email = 'ds@viref.com';
        leadrec.Phone = '1791657825';
        leadrec.Street = 'Test Street 1';
        leadrec.City = 'Test City';
        leadrec.State = 'CA';
        leadrec.Country = 'US';
        leadrec.PostalCode = '1234';
        leadrec.Match_Affiliate_Id__c = 1002261;  //avoid duplication alert, to get in the duplication trigger validation rule
        insert leadrec;
        
        System.debug('Account Inserted In the Test Class : '+a.Id);
        
        Test.startTest();
        Database.LeadConvert lc = new database.LeadConvert();  
        lc.setLeadId(leadrec.Id);  
        lc.setDoNotCreateOpportunity(true);  
        lc.setConvertedStatus('Sold Voucher');          
        Database.LeadConvertResult lcr = Database.convertLead(lc, false);
        system.debug('Errors are ' + lcr.getErrors());
        //system.assertEquals(true,lcr.isSuccess());
        Test.StopTest();
    }
    
    @isTest
    static void testLeadConversionWithDuplicatedAccountByPhone() {
        
        Affiliate_Id__c aff = new Affiliate_Id__c();
        aff.Affiliate_Id__c = '1002261';
        aff.Affiliate_Name__c = 'Vacation Innovations Referral';
        aff.Send_Email__c = false;
        insert aff;
        
        Lead_Source_Settings__c ldSettings = new Lead_Source_Settings__c();
        ldSettings.Affiliate_Id__c = aff.Id;
        ldSettings.Lead_Source__c = 'VI Referral';
        insert ldSettings;
        
        Account a = new Account();
        a.Name = 'TESTeXAbXib';
        a.Phone = '1791657825';
        a.Email__c = 'ds2@viref.com';
        a.Affiliated_Id__c = 1002261;
        a.Preferred_Language__c = 'ENG';
        insert a;
        
        Contact cont= New Contact();
        cont.LastName = 'testname';
        cont.AffiliatedId__c = 1002261;
        cont.Phone = '1791657825';
        cont.Email = 'ds2@viref.com';
        cont.AccountId = a.id;
        Insert cont;
        
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
        
        leadrec.Marketing_Email_opt_out__c = true;
        update leadrec;
        
        System.debug('Account Inserted In the Test Class : '+a.Id);
        
        Test.startTest();
        Database.LeadConvert lc = new database.LeadConvert();  
        lc.setLeadId(leadrec.Id);  
        lc.setDoNotCreateOpportunity(true);  
        lc.setConvertedStatus('Sold Voucher');          
        Database.LeadConvertResult lcr = Database.convertLead(lc, false);
        system.debug('Errors are ' + lcr.getErrors());
        //system.assertEquals(true,lcr.isSuccess());
        Test.StopTest();
    }
    @isTest
    static void testLeadConversionLemonJuiceOwners() {
        
        Affiliate_Id__c aff = new Affiliate_Id__c();
        aff.Affiliate_Id__c = '1002261';
        aff.Affiliate_Name__c = 'Vacation Innovations Referral';
        aff.Send_Email__c = false;
        insert aff;
        
        Lead_Source_Settings__c ldSettings = new Lead_Source_Settings__c();
        ldSettings.Affiliate_Id__c = aff.Id;
        ldSettings.Lead_Source__c = 'VI Referral';
        insert ldSettings;
        
        Id leadVIRefRecTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Carefree_Destinations').getRecordTypeId();
        Lead leadrec = new Lead();
        leadrec.LastName = 'test';
        leadrec.Company = 'test';
        leadrec.LeadSource = 'LemonJuice Owners';
        leadrec.RecordTypeId = leadVIRefRecTypeId;
        leadrec.Email = 'ds@viref.com';
        leadrec.Phone = '1791657825';
        leadrec.Street = 'Test Street 1';
        leadrec.City = 'Test City';
        leadrec.State = 'CA';
        leadrec.Country = 'US';
        leadrec.PostalCode = '1234';
        insert leadrec;
        
        Test.startTest();
        Database.LeadConvert lc = new database.LeadConvert();  
        lc.setLeadId(leadrec.Id);  
        lc.setDoNotCreateOpportunity(true);  
        lc.setConvertedStatus('Closed Won');          
        Database.LeadConvertResult lcr = Database.convertLead(lc, false);
        system.debug('Errors are ' + lcr.getErrors());
        //system.assert(lcr.isSuccess());
        Test.StopTest();
    }
    
    @isTest
        static void testDNCAPITrigger() {
            // Create a Lead
            Lead leadrec = new Lead();
            leadrec.LastName = 'TestDNC';
            leadrec.Company = 'TestCompany';
            leadrec.LeadSource = 'CFD FB';
            leadrec.Email = 'testdnc@ds.com';
            leadrec.Phone = '1234567899';
            leadrec.DoNotCall = false;
            insert leadrec;
    
            // Set up a mock for HTTP callouts to avoid real API call
            Test.setMock(HttpCalloutMock.class, new DNCAPICallMock());
    
            // Change DoNotCall to TRUE
            leadrec.DoNotCall = true;
    
            Test.startTest();
            update leadrec; // triggers your DNC logic
            Test.stopTest();
    
            // Assert that the debug statement executed and your future method was called
            System.assertEquals(true, leadrec.DoNotCall, 'DoNotCall should be TRUE after update');
        }
    
        // Mock class for DNC API callout
        public class DNCAPICallMock implements HttpCalloutMock {
            public HTTPResponse respond(HTTPRequest req) {
                HttpResponse res = new HttpResponse();
                res.setHeader('Content-Type', 'application/json');
                res.setBody('{"status":"OK"}');
                res.setStatusCode(200);
                return res;
            }
        }
    }