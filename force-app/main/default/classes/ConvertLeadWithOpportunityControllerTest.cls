@isTest
public class ConvertLeadWithOpportunityControllerTest {
    
    @testSetup static void testRecords(){
        //convert examples
        Id Public_Reservation_Inquiry_Id = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Public_Reservation_Inquiry').getRecordTypeId();            
        Id Carefree_Destinations_Id = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Carefree_Destinations').getRecordTypeId();         
        Id VI_Referral_Id = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('VI_Referral').getRecordTypeId();
        
        Id membershipUpgradeRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Vacation_VIP_Membership_Upgrade').getRecordTypeId();
        Id SMTN_Mexico_Id = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('SMTN_Mexico').getRecordTypeId();            
        Id SMTNOpenLeadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('SMTN_Open_Lead').getRecordTypeId();
        
        
        
        //block example
        Id Future_Stay_Id = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Future_Stay').getRecordTypeId();
        
        Profile p = [select id
                     from
                     Profile
                     where
                     name='Tour Generation'];
        
        User user = new User();
        
        user = new user(alias = 'test123', email='tourgenagent@nerdsoft.com',
                        emailencodingkey='UTF-8', firstName='Test', lastname='Name', languagelocalekey='en_US',
                        localesidkey='en_IN', profileid = p.Id, country='India',
                        timezonesidkey='Asia/Kolkata', username='tourgenagent@nerdsoft.com.hsi');
        insert user;
        
        Id currentuser = user.Id;
        
        List<Lead> leadsToCreate = new List<Lead>();

        /*
        Lead leadrec = new Lead();
        leadrec.LastName = 'test';
        leadrec.Company = 'test';
        leadrec.LeadSource = 'VI Referral';
        leadrec.RecordTypeId = VI_Referral_Id;
        leadrec.Email = 'testLead@viref.com';

        leadrec.Street = 'Test Street 1';
        leadrec.City = 'Test City';
        leadrec.State = 'CA';
        leadrec.Country = 'US';
        leadrec.PostalCode = '1234';
        leadrec.OwnerId = currentuser;
        leadsToCreate.add(leadrec);
		*/
        //OpportunityTrigger_New, line 423 , 14:11:13:000 EXCEPTION_THROWN caused by: System.DmlException: Insert failed. First exception on row 0; first error: FIELD_INTEGRITY_EXCEPTION, field integrity exception: PricebookEntryId, unknown (versions 3.0 and higher must specify pricebook entry id, others must specify product id): [PricebookEntryId, unknown]
        
        Lead leadrec2 = new Lead();
        leadrec2.LastName = 'test2';
        leadrec2.Company = 'test2';
        leadrec2.LeadSource = 'CFD FB';
        leadrec2.RecordTypeId = Carefree_Destinations_Id;
        leadrec2.Email = 'testLead@cfd.com';
        leadrec2.Phone = '1791657826';
        leadrec2.Street = 'Test Street 2';
        leadrec2.City = 'Test City 2';
        leadrec2.State = 'CA';
        leadrec2.Country = 'US';
        leadrec2.PostalCode = '1234';
        leadrec2.OwnerId = currentuser;
        leadrec2.Match_Affiliate_Id__c = 1002261;
        leadsToCreate.add(leadrec2);
        
        Lead leadrec3 = new Lead();
        leadrec3.LastName = 'test3';
        leadrec3.Company = 'test3';
        leadrec3.LeadSource = 'SMTN Buyer Offer';
        leadrec3.RecordTypeId = Public_Reservation_Inquiry_Id;
        leadrec3.Email = 'testLead@SMTNBuyer.com';
        leadrec3.Phone = '1791657827';
        leadrec3.Street = 'Test Street 3';
        leadrec3.City = 'Test City 3';
        leadrec3.State = 'CA';
        leadrec3.Country = 'US';
        leadrec3.PostalCode = '1234';
        leadrec3.OwnerId = currentuser;
        leadsToCreate.add(leadrec3);
        
        Lead leadrec4 = new Lead();
        leadrec4.LastName = 'test4';
        leadrec4.Company = 'test4';
        leadrec4.LeadSource = 'SMTN Rental Offer';
        leadrec4.RecordTypeId = Public_Reservation_Inquiry_Id;
        leadrec4.Email = 'testLead@SMTNRental.com';
        leadrec4.Phone = '1791657828';
        leadrec4.Street = 'Test Street 4';
        leadrec4.City = 'Test City 4';
        leadrec4.State = 'CA';
        leadrec4.Country = 'US';
        leadrec4.PostalCode = '1234';
        leadrec4.OwnerId = currentuser;
        leadsToCreate.add(leadrec4);


        Lead leadrec5 = new Lead();
        leadrec5.LastName = 'test5';
        leadrec5.Company = 'test5';
        leadrec5.LeadSource = 'Inspira Resort Week';
        leadrec5.RecordTypeId = Public_Reservation_Inquiry_Id;
        leadrec5.Email = 'testLead@InspiraResort.com';
        leadrec5.Phone = '179165782821';
        leadrec5.Street = 'Test Street 5';
        leadrec5.City = 'Test City 5';
        leadrec5.State = 'CA';
        leadrec5.Country = 'US';
        leadrec5.PostalCode = '1235';
        leadrec5.OwnerId = currentuser;
        leadsToCreate.add(leadrec5);
/*                    
        Lead leadrec6 = new Lead();
        leadrec6.LastName = 'test6';
        leadrec6.Company = 'test6';
        leadrec6.LeadSource = 'Vacation VIP - Web';
        leadrec6.RecordTypeId = membershipUpgradeRecordTypeId; //check record type Lead x Oppt
        leadrec6.Email = 'testLead@VacationVIPWeb.com';
        leadrec6.Phone = '179165456';
        leadrec6.Street = 'Test Street 6';
        leadrec6.City = 'Test City 6';
        leadrec6.State = 'CA';
        leadrec6.Country = 'US';
        leadrec6.PostalCode = '1236';
        leadrec6.OwnerId = currentuser;
        leadsToCreate.add(leadrec6);
  */                  
                    
        Lead leadrec7 = new Lead();
        leadrec7.LastName = 'test7';
        leadrec7.Company = 'test7';
        leadrec7.LeadSource = 'SMTN Open Lead - 1 year';
        leadrec7.RecordTypeId = SMTNOpenLeadRecordTypeId;
        leadrec7.Email = 'testLead@SMTNOpenLead-1year.com';
        leadrec7.Phone = '17916546';
        leadrec7.Street = 'Test Street 7';
        leadrec7.City = 'Test City 7';
        leadrec7.State = 'CA';
        leadrec7.Country = 'US';
        leadrec7.PostalCode = '1237';
        leadrec7.OwnerId = currentuser;
        leadsToCreate.add(leadrec7);
                    
                    
        insert leadsToCreate;
        
    }
    /*
    @isTest
    static void testVI_Referral() {
        Test.startTest();
        
        Apex_Trigger_On_Off__c obj = new Apex_Trigger_On_Off__c();
        obj.Name = 'OpportunityTrigger_New';
        obj.isEnable__c = true;
        insert obj;
        
        Lead ld = [SELECT Id,RecordTypeId,LeadSource,Email,Phone,Match_Affiliate_Id__c,OwnerId FROM Lead WHERE Email = 'testLead@viref.com'];
        
        Id standardPbId = Test.getStandardPricebookId();
        
        Product2 prd1 = new Product2 (Name='Vida Voucher-Flex Date Request',Description='Vida Voucher-Flex Date Request', isActive = true);
        insert prd1;
        
        PricebookEntry pbe1 = new PricebookEntry (Product2ID=prd1.id,Pricebook2ID=standardPbId,UnitPrice=0, isActive=true);
        insert pbe1;
        
        Map<String,String> convertResults = ConvertLeadWithOpportunityController.tryToConvertLead(ld.Id);
        Test.stopTest();
    }
    */
    @isTest
    static void testCFD() {
        Test.startTest();
        
        Apex_Trigger_On_Off__c obj = new Apex_Trigger_On_Off__c();
        obj.Name = 'OpportunityTrigger_New';
        obj.isEnable__c = true;
        insert obj;
        
        Lead ld = [SELECT Id,RecordTypeId,LeadSource,Email,Phone,Match_Affiliate_Id__c,OwnerId FROM Lead WHERE Email = 'testLead@cfd.com'];
        
        Account a = new Account();
        a.Name = 'TESTeXAbXib';
        a.Phone = '1791657826';
        a.Email__c = 'testLead@cfd.com';
        a.Affiliated_Id__c = 1002261;
        a.Preferred_Language__c = 'ENG';
        insert a;
        
        Contact cont= New Contact();
        cont.LastName = 'testname';
        cont.AffiliatedId__c = 1002261;
        cont.Phone = '1791657826';
        cont.Email = 'testLead@cfd.com';
        cont.AccountId = a.id;
        Insert cont;
        
        Map<String,String> convertResults = ConvertLeadWithOpportunityController.tryToConvertLead(ld.Id);
        Test.stopTest();
    }
    
    @isTest
    static void testSMTN_Buyer() {
        Test.startTest();
        Lead ld = [SELECT Id,RecordTypeId,LeadSource,Email,Phone,Match_Affiliate_Id__c,OwnerId FROM Lead WHERE Email = 'testLead@SMTNBuyer.com'];
        User us = [SELECT Id FROM User WHERE Username = 'tourgenagent@nerdsoft.com.hsi'];
        ld.OwnerId = us.Id;
        update ld;
        Map<String,String> convertResults = ConvertLeadWithOpportunityController.tryToConvertLead(ld.Id);
        Test.stopTest();
    }
    
    @isTest
    static void testSMTN_Rental() {
        Test.startTest();
        Lead ld = [SELECT Id,RecordTypeId,LeadSource,Email,Phone,Match_Affiliate_Id__c,OwnerId FROM Lead WHERE Email = 'testLead@SMTNRental.com'];
        User us = [SELECT Id FROM User WHERE Username = 'tourgenagent@nerdsoft.com.hsi'];
        ld.OwnerId = us.Id;
        update ld;
        Map<String,String> convertResults = ConvertLeadWithOpportunityController.tryToConvertLead(ld.Id);
        Test.stopTest();
    }
    
    @isTest
    static void testInspiraResort() {
        Test.startTest();
        Lead ld = [SELECT Id,RecordTypeId,LeadSource,Email,Phone,Match_Affiliate_Id__c,OwnerId FROM Lead WHERE Email = 'testLead@InspiraResort.com'];
        User us = [SELECT Id FROM User WHERE Username = 'tourgenagent@nerdsoft.com.hsi'];
        ld.OwnerId = us.Id;
        update ld;
        Map<String,String> convertResults = ConvertLeadWithOpportunityController.tryToConvertLead(ld.Id);
        Test.stopTest();
    }
        
/*    
    @isTest
    static void testVacationVIPWeb() {
        Test.startTest();
        Lead ld = [SELECT Id,RecordTypeId,LeadSource,Email,Phone,Match_Affiliate_Id__c,OwnerId FROM Lead WHERE Email = 'testLead@VacationVIPWeb.com'];
        User us = [SELECT Id FROM User WHERE Username = 'tourgenagent@nerdsoft.com.hsi'];
        ld.OwnerId = us.Id;
        update ld;
        Map<String,String> convertResults = ConvertLeadWithOpportunityController.tryToConvertLead(ld.Id);
        Test.stopTest();
    }
  */      
    
    @isTest
    static void testSMTNOpenLeadyear() {
        Test.startTest();
        Lead ld = [SELECT Id,RecordTypeId,LeadSource,Email,Phone,Match_Affiliate_Id__c,OwnerId FROM Lead WHERE Email = 'testLead@SMTNOpenLead-1year.com'];
        User us = [SELECT Id FROM User WHERE Username = 'tourgenagent@nerdsoft.com.hsi'];
        ld.OwnerId = us.Id;
        update ld;
        Map<String,String> convertResults = ConvertLeadWithOpportunityController.tryToConvertLead(ld.Id);
        Test.stopTest();
    }
        
   
    
    @isTest
    static void testFail1(){
        Test.startTest();
        Lead ld = [SELECT Id,RecordTypeId,LeadSource,Email,Phone,Match_Affiliate_Id__c,OwnerId FROM Lead WHERE Email = 'testLead@SMTNBuyer.com'];        
        Map<String,String> convertResults = ConvertLeadWithOpportunityController.tryToConvertLead(ld.Id);
        Test.stopTest();
    }
    
    @isTest
    static void testFail2(){
        Test.startTest();
        Lead ld = [SELECT Id,RecordTypeId,LeadSource,Email,Phone,Match_Affiliate_Id__c,OwnerId FROM Lead WHERE Email = 'testLead@SMTNBuyer.com'];
        Id Future_Stay_Id = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Future_Stay').getRecordTypeId();
        ld.RecordTypeId = Future_Stay_Id;
        update ld;
        Map<String,String> convertResults = ConvertLeadWithOpportunityController.tryToConvertLead(ld.Id);
        Test.stopTest();
    }
    
    @isTest
    static void testFail3(){        
        Test.startTest();       
        Map<String,String> convertResults = ConvertLeadWithOpportunityController.tryToConvertLead(null);
        Test.stopTest();
    }
    @isTest
    static void testDayDrive(){        
  Test.startTest();
        Lead ld = [SELECT Id,RecordTypeId,LeadSource,Email,Phone,Match_Affiliate_Id__c,OwnerId FROM Lead WHERE Email = 'testLead@SMTNBuyer.com'];
        Id Future_Stay_Id = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Carefree_Destinations').getRecordTypeId();
        ld.RecordTypeId = Future_Stay_Id;
		ld.Lead_Original_Source__c = 'Day Drive';
        ld.LeadSource = 'CFD FB DD-Cruise';
        ld.OwnerId = UserInfo.getUserId();
        update ld;
        Map<String,String> convertResults = ConvertLeadWithOpportunityController.tryToConvertLead(ld.Id);
        Test.stopTest();
    }    
    
    @isTest
    static void testRaiseAway(){        
        Test.startTest();
        
        Id standardPbId = Test.getStandardPricebookId();
        
        Product2 prd1 = new Product2 (Name='Raise Away-All Inclusive MX 5-Night $249 Resort Fee', Description='Test Product Entry 1', isActive = true);
        insert prd1;
        
        PricebookEntry pbe1 = new PricebookEntry (Product2ID=prd1.id,Pricebook2ID=standardPbId,UnitPrice=50, isActive=true);
        insert pbe1;
        
        Lead ld = [SELECT Id,RecordTypeId,LeadSource,Email,Phone,Match_Affiliate_Id__c,OwnerId FROM Lead WHERE Email = 'testLead@SMTNBuyer.com'];
        Id cfdId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Carefree_Destinations').getRecordTypeId();
        ld.RecordTypeId = cfdId;
        ld.LeadSource = 'Raise Away';
        ld.Lead_Original_Source__c = 'MX $440';
        ld.OwnerId = UserInfo.getUserId();
        update ld;
        Map<String,String> convertResults = ConvertLeadWithOpportunityController.tryToConvertLead(ld.Id);
        Test.stopTest();
    }   
  
    
    @isTest
    static void testAdSales(){        
 
        Id Ad_Sales_RC_Id = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Ad_Sales').getRecordTypeId();         
        List<Lead> leadsToCreate = new List<Lead>();
       
        Lead leadrec2 = new Lead();
        leadrec2.LastName = 'test2';
        leadrec2.Company = 'test2';
        leadrec2.LeadSource = 'ARDA';
        leadrec2.RecordTypeId = Ad_Sales_RC_Id;
        leadrec2.Email = 'testLead281125@cfd.com';
        leadrec2.Phone = '1791657826281125';
        leadrec2.Street = 'Test Street 2';
        leadrec2.City = 'Test City 2';
        leadrec2.State = 'CA';
        leadrec2.Country = 'US';
        leadrec2.PostalCode = '1234';
        leadrec2.Match_Affiliate_Id__c = 1002454;
        leadrec2.OwnerId = UserInfo.getUserId();

        insert leadrec2;
       
        Test.startTest();

        Map<String,String> convertResults = ConvertLeadWithOpportunityController.tryToConvertLead(leadrec2.Id);
        Test.stopTest();
    }    
    
    
    @isTest
    static void testReferral(){        
 
        Id VI_Referral_Id = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('VI_Referral').getRecordTypeId();
        List<Lead> leadsToCreate = new List<Lead>();
       
        Lead leadrec2 = new Lead();
        leadrec2.LastName = 'test2';
        leadrec2.Company = 'test2';
        //leadrec2.LeadSource = 'ARDA';
        leadrec2.RecordTypeId = VI_Referral_Id;
        leadrec2.Email = 'testLead281125@cfd.com';
        leadrec2.Phone = '1791657826281125';
        leadrec2.Street = 'Test Street 2';
        leadrec2.City = 'Test City 2';
        leadrec2.State = 'CA';
        leadrec2.Country = 'US';
        leadrec2.PostalCode = '1234';
        //leadrec2.Match_Affiliate_Id__c = 1002454;
        leadrec2.OwnerId = UserInfo.getUserId();

        insert leadrec2;
       
        Test.startTest();

        Map<String,String> convertResults = ConvertLeadWithOpportunityController.tryToConvertLead(leadrec2.Id);
        Test.stopTest();
    }    
    
    
    
    
    
    
}