@isTest
public class leadTriggerOMHandlerTest {
    @isTest
    static void testCFD(){
        String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String guid = h.SubString(0,8);
        Set<Id> ldId = new  Set<Id>();
        Apex_Trigger_On_Off__c cs = new Apex_Trigger_On_Off__c();
        cs.isEnable__c = true;
        cs.Name = 'LeadDupliateTriggerLogic';
        
        Apex_Trigger_On_Off__c cs2 = new Apex_Trigger_On_Off__c();
        cs2.isEnable__c = true;
        cs2.Name = 'LeadSalesCadenceAssignment';
        
        insert cs;
        insert cs2;
        
        Profile p = [select id
                     from
                     Profile
                     where
                     name='System Administrator'];
        
        User user = new User();
        
        if(baseUrl.contains('holidaysystems.my.salesforce.com')){
            user = new user(alias = 'test123', email='zappier@nerdsoft.com',
                            emailencodingkey='UTF-8', firstName='Test', lastname='Name', languagelocalekey='en_US',
                            localesidkey='en_IN', profileid = p.Id, country='India',
                            timezonesidkey='Asia/Kolkata', username=guid+'zappier@nerdsoft.com.hsi', Assigned_Contacts__c=4);
        }
        else{
            user = new user(alias = 'test123', email='zappier@nerdsoft.com',
                            emailencodingkey='UTF-8', firstName='Test', lastname='Name', languagelocalekey='en_US',
                            localesidkey='en_IN', profileid = p.Id, country='India',
                            timezonesidkey='Asia/Kolkata', username=guid+'zappier@nerdsoft.com.hsi.full', Assigned_Contacts__c=4);
        }
        insert user;
        
        User u1 = [SELECT Id FROM User WHERE Email = 'zappier@nerdsoft.com' LIMIT 1];
        
        User user2 = new user(alias = 'test123', email='test123@noemail.com',
                              emailencodingkey='UTF-8', firstName='Test', lastname='Name', languagelocalekey='en_US',
                              localesidkey='en_IN', profileid = p.Id, country='India',
                              timezonesidkey='Asia/Kolkata', username=guid+'newUserAssigned@nerdsoft.com.hsi', Assigned_Contacts__c=4);
        insert user2;
        
        User u2 = [SELECT Id FROM User WHERE Email = 'test123@noemail.com' LIMIT 1];
        
        Id leadCFRecTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Carefree_Destinations').getRecordTypeId();
        
        Test.setMock(HttpCalloutMock.class, new AssigningContactInCadenceTestMock());
        Test.startTest();
        
        System.RunAs(u1){
            List<Lead> leadRecords = new List<Lead>();
            Lead leadrec = new Lead();
            leadrec.Status = 'New';
            leadrec.Email = 'test@test1.com';
            leadrec.LastName = 'test';
            leadrec.Company = 'test';
            leadrec.LeadSource = 'CFD FB';
            leadrec.Phone = '1234567891';
            leadrec.RecordTypeId = leadCFRecTypeId;
            leadrec.Marketing_Email_opt_out__c = false;
            leadRecords.add(leadrec);
            
            Lead leadrec2 = new Lead();
            leadrec2.Status = 'New';
            leadrec2.Email = 'test@test2.com';
            leadrec2.LastName = 'test2';
            leadrec2.Company = 'test2';
            leadrec2.LeadSource = 'CFD FB Mexico';
            leadrec2.Phone = '1234567892';
            leadrec2.RecordTypeId = leadCFRecTypeId;
            leadrec2.Marketing_Email_opt_out__c = false;
            leadRecords.add(leadrec2);
            
            insert leadRecords;
            for(Lead ld : leadRecords){
                ldId.add(ld.Id);
            }
            leadTriggerOMHandler ltm = new leadTriggerOMHandler(ldId);
            System.enqueueJob(ltm);
            Test.StopTest();
        }
    }
    
    @isTest
    static void testVI(){
        
        String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
        
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String guid = h.SubString(0,8);
        
        Apex_Trigger_On_Off__c cs = new Apex_Trigger_On_Off__c();
        cs.isEnable__c = true;
        cs.Name = 'LeadDupliateTriggerLogic';
        
        Apex_Trigger_On_Off__c cs2 = new Apex_Trigger_On_Off__c();
        cs2.isEnable__c = true;
        cs2.Name = 'LeadSalesCadenceAssignment';
        
        insert cs;
        insert cs2;
        
        Profile p = [select id
                     from
                     Profile
                     where
                     name='System Administrator'];
        
        User user = new User();
        
        if(baseUrl.contains('holidaysystems.my.salesforce.com')){
            user = new user(alias = 'test123', email='zappier@nerdsoft.com',
                            emailencodingkey='UTF-8', firstName='Test', lastname='Name', languagelocalekey='en_US',
                            localesidkey='en_IN', profileid = p.Id, country='India',
                            timezonesidkey='Asia/Kolkata', username=guid+'zappier@nerdsoft.com.hsi', Assigned_Contacts__c=4);
        }
        else{
            user = new user(alias = 'test123', email='zappier@nerdsoft.com',
                            emailencodingkey='UTF-8', firstName='Test', lastname='Name', languagelocalekey='en_US',
                            localesidkey='en_IN', profileid = p.Id, country='India',
                            timezonesidkey='Asia/Kolkata', username=guid+'zappier@nerdsoft.com.hsi.full', Assigned_Contacts__c=4);
        }
        insert user;
        
        User u1 = [SELECT Id FROM User WHERE Email = 'zappier@nerdsoft.com' LIMIT 1];
        
        User user2 = new user(alias = 'test123', email='test123@noemail.com',
                              emailencodingkey='UTF-8', firstName='Test', lastname='Name', languagelocalekey='en_US',
                              localesidkey='en_IN', profileid = p.Id, country='India',
                              timezonesidkey='Asia/Kolkata', username=guid+'newUserAssigned@nerdsoft.com.hsi', Assigned_Contacts__c=4);
        insert user2;
        
        User u2 = [SELECT Id FROM User WHERE Email = 'test123@noemail.com' LIMIT 1];
        
        Id leadCFRecTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('VI_Referral').getRecordTypeId();
        Id leadRecTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('SMTN_Mexico').getRecordTypeId();        
        
        Test.setMock(HttpCalloutMock.class, new AssigningContactInCadenceTestMock());
        Set<Id> ldId = new  Set<Id>();
        Test.startTest();
        
        System.RunAs(u1){
            List<Lead> leadRecords = new List<Lead>();
            Lead leadrec = new Lead();
            leadrec.Status = 'New';
            leadrec.Email = 'test@test1.com';
            leadrec.LastName = 'test';
            leadrec.Company = 'test';
            leadrec.LeadSource = 'VI Referral';
            leadrec.Phone = '1234567891';
            leadrec.RecordTypeId = leadCFRecTypeId;
            leadrec.Marketing_Email_opt_out__c = false;
            leadRecords.add(leadrec);
            
            Lead leadrec2 = new Lead();
            leadrec2.Status = 'New';
            leadrec2.Email = 'test2@test2.com';
            leadrec2.LastName = 'test2';
            leadrec2.Company = 'test2';
            leadrec2.LeadSource = 'VVIP Westgate Orlando';
            leadrec2.Phone = '1234567892';
            leadrec2.RecordTypeId = leadCFRecTypeId;
            leadrec2.Marketing_Email_opt_out__c = false;
            leadRecords.add(leadrec2);
            
            Lead leadrec3 = new Lead();
            leadrec3.Status = 'New';
            leadrec3.Email = 'test3@test3.com';
            leadrec3.LastName = 'test3';
            leadrec3.Company = 'test3';
            leadrec3.LeadSource = 'VVIP Westgate Las Vegas';
            leadrec3.Phone = '1234567889';
            leadrec3.RecordTypeId = leadCFRecTypeId;
            leadrec3.Marketing_Email_opt_out__c = false;
            leadRecords.add(leadrec3);
            
            Lead leadrec4 = new Lead();
            leadrec4.Status = 'New';
            leadrec4.Email = 'test4@test4.com';
            leadrec4.LastName = 'test4';
            leadrec4.Company = 'test4';
            leadrec4.LeadSource = 'SMTN Open Survey';
            leadrec4.Phone = '1234567888';
            leadrec4.RecordTypeId = leadCFRecTypeId;
            leadrec4.Marketing_Email_opt_out__c = false;
            leadRecords.add(leadrec4);
            
            Lead leadrec5 = new Lead();
            leadrec5.Status = 'New';
            leadrec5.Email = 'test5@test5.com';
            leadrec5.LastName = 'test5';
            leadrec5.Company = 'test5';
            leadrec5.LeadSource = 'VIN Open Survey';
            leadrec5.Phone = '1234567887';
            leadrec5.RecordTypeId = leadCFRecTypeId;
            leadrec5.Marketing_Email_opt_out__c = false;
            leadRecords.add(leadrec5);
            
            Lead leadrec6 = new Lead();
            leadrec6.Status = 'New';
            leadrec6.Email = 'test6@test6.com';
            leadrec6.LastName = 'test6';
            leadrec6.Company = 'test6';
            leadrec6.LeadSource = 'Vacation VIP - Web';
            leadrec6.Phone = '1234567886';
            leadrec6.RecordTypeId = leadCFRecTypeId;
            leadrec6.Marketing_Email_opt_out__c = false;
            leadRecords.add(leadrec6);
            
            lead l=new lead();
            l.Status = 'New';
            l.Email = 'test@test1.com';
            l.LastName = 'test';
            l.Company = 'test';
            l.LeadSource = 'SMTN MX Voucher';
            l.is_duplicate__C=false;
            l.recordtypeid=leadRecTypeId;
            l.Phone = '1234567891';
            l.Marketing_Email_opt_out__c = false;
            insert l;
            
            l.SMTN_match_group__c='TRUE';
            update l;
            
            insert leadRecords;
            for(Lead ld : leadRecords){
                ldId.add(ld.Id);
            }
        }
        leadTriggerOMHandler ltm = new leadTriggerOMHandler(ldId);
        System.enqueueJob(ltm);
        Test.StopTest();
    }
    @isTest
    static void testFail(){
        
        String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
        
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String guid = h.SubString(0,8);
        
        Apex_Trigger_On_Off__c cs = new Apex_Trigger_On_Off__c();
        cs.isEnable__c = true;
        cs.Name = 'LeadDupliateTriggerLogic';
        
        Apex_Trigger_On_Off__c cs2 = new Apex_Trigger_On_Off__c();
        cs2.isEnable__c = true;
        cs2.Name = 'LeadSalesCadenceAssignment';
        
        insert cs;
        insert cs2;
        
        Profile p = [select id
                     from
                     Profile
                     where
                     name='System Administrator'];
        
        User user = new User();
        
        if(baseUrl.contains('holidaysystems.my.salesforce.com')){
            user = new user(alias = 'test123', email='zappier@nerdsoft.com',
                            emailencodingkey='UTF-8', firstName='Test', lastname='Name', languagelocalekey='en_US',
                            localesidkey='en_IN', profileid = p.Id, country='India',
                            timezonesidkey='Asia/Kolkata', username=guid+'zappier@nerdsoft.com.hsi', Assigned_Contacts__c=4);
        }
        else{
            user = new user(alias = 'test123', email='zappier@nerdsoft.com',
                            emailencodingkey='UTF-8', firstName='Test', lastname='Name', languagelocalekey='en_US',
                            localesidkey='en_IN', profileid = p.Id, country='India',
                            timezonesidkey='Asia/Kolkata', username=guid+'zappier@nerdsoft.com.hsi.full', Assigned_Contacts__c=4);
        }
        insert user;
        
        User u1 = [SELECT Id FROM User WHERE Email = 'zappier@nerdsoft.com' LIMIT 1];
        
        User user2 = new user(alias = 'test123', email='test123@noemail.com',
                              emailencodingkey='UTF-8', firstName='Test', lastname='Name', languagelocalekey='en_US',
                              localesidkey='en_IN', profileid = p.Id, country='India',
                              timezonesidkey='Asia/Kolkata', username=guid+'newUserAssigned@nerdsoft.com.hsi', Assigned_Contacts__c=4);
        insert user2;
        
        User u2 = [SELECT Id FROM User WHERE Email = 'test123@noemail.com' LIMIT 1];
        
        Id leadCFRecTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('VI_Referral').getRecordTypeId();
        Id leadRecTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('SMTN_Mexico').getRecordTypeId();        
        
        Test.setMock(HttpCalloutMock.class, new AssigningLeadInCadenceFailTestMock());
        Set<Id> ldId = new  Set<Id>();
        Test.startTest();
        
        System.RunAs(u1){
            List<Lead> leadRecords = new List<Lead>();
            Lead leadrec = new Lead();
            leadrec.Status = 'New';
            leadrec.Email = 'test@test1.com';
            leadrec.LastName = 'test';
            leadrec.Company = 'test';
            leadrec.LeadSource = 'VI Referral';
            leadrec.Phone = '1234567891';
            leadrec.RecordTypeId = leadCFRecTypeId;
            leadrec.Marketing_Email_opt_out__c = false;
            leadRecords.add(leadrec);
            
            Lead leadrec2 = new Lead();
            leadrec2.Status = 'New';
            leadrec2.Email = 'test2@test2.com';
            leadrec2.LastName = 'test2';
            leadrec2.Company = 'test2';
            leadrec2.LeadSource = 'VVIP Westgate Orlando';
            leadrec2.Phone = '1234567892';
            leadrec2.RecordTypeId = leadCFRecTypeId;
            leadrec2.Marketing_Email_opt_out__c = false;
            leadRecords.add(leadrec2);
            
            lead l=new lead();
            l.Status = 'New';
            l.Email = 'test@test1.com';
            l.LastName = 'test';
            l.Company = 'test';
            l.LeadSource = 'SMTN MX Voucher';
            l.is_duplicate__C=false;
            l.recordtypeid=leadRecTypeId;
            l.Phone = '1234567891';
            l.Marketing_Email_opt_out__c = false;
            insert l;
            
            l.SMTN_match_group__c='TRUE';
            update l;
            
            insert leadRecords;
            
            for(Lead ld : leadRecords){
                ldId.add(ld.Id);
            }
        }
        leadTriggerOMHandler ltm = new leadTriggerOMHandler(ldId);
        System.enqueueJob(ltm);
        Test.StopTest();
    }
}