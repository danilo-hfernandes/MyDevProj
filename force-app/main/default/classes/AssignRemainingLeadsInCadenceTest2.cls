@isTest
public class AssignRemainingLeadsInCadenceTest2 {
    
    @isTest
    static void testCFD(){
        
        // Generate a guid for username uniqueness
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String guid = h.SubString(0,8);
        
        // Trigger flags
        Apex_Trigger_On_Off__c cs = new Apex_Trigger_On_Off__c();
        cs.isEnable__c = true;
        cs.Name = 'LeadDupliateTriggerLogic';
        
        Apex_Trigger_On_Off__c cs2 = new Apex_Trigger_On_Off__c();
        cs2.isEnable__c = true;
        cs2.Name = 'LeadSalesCadenceAssignment';
        
        insert cs;
        insert cs2;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator' LIMIT 1];
        
        // Create main user (matches batch query)
        User user = new User(
            alias = 'test123', 
            email='dev@nerdsoft.com', 
            emailencodingkey='UTF-8', 
            firstName='Test', 
            lastName='Name', 
            languagelocalekey='en_US',
            localesidkey='en_IN', 
            profileid = p.Id, 
            country='India',
            timezonesidkey='Asia/Kolkata', 
            username=guid+'zappier@nerdsoft.com', 
            Assigned_Contacts__c=4
        );
        insert user;
        
        User u1 = [SELECT Id FROM User WHERE Email = 'dev@nerdsoft.com' LIMIT 1];
        
        // Another dummy user
        User user2 = new User(
            alias = 'test123', 
            email='test123@noemail.com',
            emailencodingkey='UTF-8', 
            firstName='Test', 
            lastName='Name', 
            languagelocalekey='en_US',
            localesidkey='en_IN', 
            profileid = p.Id, 
            country='India',
            timezonesidkey='Asia/Kolkata', 
            username=guid+'newUserAssigned@nerdsoft.com', 
            Assigned_Contacts__c=4
        );
        insert user2;
        
        User u2 = [SELECT Id FROM User WHERE Email = 'test123@noemail.com' LIMIT 1];
        
        // Lead Record Type
        Id leadCFRecTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName()
                                 .get('Carefree_Destinations')
                                 .getRecordTypeId();
        
        Test.setMock(HttpCalloutMock.class, new AssigningContactInCadenceTestMock());
        
        System.RunAs(u1){
            List<Lead> leadRecords = new List<Lead>();
            
            // Lead to hit ASSIGNED branch
            Lead leadrec = new Lead();
            leadrec.Status = 'New';
            leadrec.Email = 'test@test1.com';
            leadrec.LastName = 'test';
            leadrec.Company = 'test';
            leadrec.LeadSource = 'Vacation VIP - Web'; 
            leadrec.Phone = '1234567891';
            leadrec.RecordTypeId = leadCFRecTypeId;
            leadrec.Sales_Cadence_Assignment_Attempt__c = 1;
            leadrec.leadassist__Use_Round_Robin__c = 'ASSIGNED';
            leadrec.First_Action_Cadence_Id__c = null;
            leadRecords.add(leadrec);
            
            // Another lead to hit ASSIGNED branch
            Lead leadrec2 = new Lead();
            leadrec2.Status = 'New';
            leadrec2.Email = 'test@test2.com';
            leadrec2.LastName = 'test2';
            leadrec2.Company = 'test2';
            leadrec2.LeadSource = 'SMTN Open Survey'; 
            leadrec2.Phone = '1234567892';
            leadrec2.RecordTypeId = leadCFRecTypeId;
            leadrec2.Sales_Cadence_Assignment_Attempt__c = 0;
            leadrec2.leadassist__Use_Round_Robin__c = 'ASSIGNED';
            leadrec2.First_Action_Cadence_Id__c = null;
            leadRecords.add(leadrec2);
            
            // Lead to hit FALSE -> TRUE branch
            Lead leadrec3 = new Lead();
            leadrec3.Status = 'New';
            leadrec3.Email = 'test@test3.com';
            leadrec3.LastName = 'test3';
            leadrec3.Company = 'test3';
            leadrec3.LeadSource = 'GBT - FBLA - RMKT'; 
            leadrec3.Phone = '1234567893';
            leadrec3.RecordTypeId = leadCFRecTypeId;
            leadrec3.Sales_Cadence_Assignment_Attempt__c = 0;
            leadrec3.leadassist__Use_Round_Robin__c = 'FALSE';
            leadrec3.First_Action_Cadence_Id__c = null;            
            leadRecords.add(leadrec3);
            
            insert leadRecords;
            update leadRecords;
        }
        
        // Make FALSE -> TRUE branch trigger by created date
        Lead CFDGoogleLead = [SELECT Id FROM Lead WHERE LeadSource = 'CFD Google Mexico' LIMIT 1];
        Test.setCreatedDate(CFDGoogleLead.Id, System.now().addMinutes(-17));
        
        Test.startTest();        
        AssignRemainingLeadsInCadence ba = new AssignRemainingLeadsInCadence();
        Database.executeBatch(ba, 3);
        Test.StopTest();
    }
    
}