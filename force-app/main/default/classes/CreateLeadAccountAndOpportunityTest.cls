@isTest
public class CreateLeadAccountAndOpportunityTest {
    
    @testsetup
    static void dataSetup() {

        User u =[select Id, Alias  from user where profile.name='System Administrator' and IsActive=true limit 1];
       
        Lead newLead = new Lead();
        newLead.FirstName = 'Danilo';
        newLead.LastName = 'test';
        newLead.Email = 'testtt@test.com';
        newLead.Phone = '5556661562';
        newLead.MobilePhone = '5556661562';
        newLead.Marriage_Status__c = 'Married';
        newLead.Name_of_Deceased__c = '';
        newLead.Work_Phone__c = '';
        newLead.Fax = '5556661562';
        newLead.First_Agent__c = u.Id;
        newLead.OwnerId = u.Id; 
        newLead.Vendor__c = 'HSI';
        newLead.Source__c = 'HSI';  
        newLead.LeadSource = 'Advertisement';
        newLead.Company =  'Company Test';
        newLead.Street = '11011  grey eagle dr';
        newLead.City = 'Orlando';
        newLead.State = 'FL';
        newLead.Country = '';
        newLead.PostalCode = '32821';
        newLead.Email_2__c = '';
        newLead.Referral_Notes__c = '';
        newLead.Referral_Agent__c = u.Alias;
        insert newLead;
        
        Account newAcc = new Account();
        newAcc.Name = 'Test Account';
        newAcc.Email__c = newLead.Email;
        newAcc.Email_2__c = newLead.Email;
        newAcc.Phone = newLead.Phone;
        newAcc.Alternate_Phone__c = newLead.Phone;
        newAcc.Alternate_Phone_1__c = newLead.Phone;
        newAcc.Alternate_Phone_2__c = newLead.Phone;
        newAcc.Alternate_Phone_3__c = newLead.Phone;
        newAcc.Mobile__c = newLead.MobilePhone;
        newAcc.Fax = newLead.Fax;
        insert newAcc;
        
        Opportunity o = new Opportunity();
        o.Name = 'Test Opportunity';
        o.AccountId = newAcc.Id;
        o.StageName = 'Prospecting';
        o.CloseDate = system.today() + 1;
        insert o;
        
        Lead newLead1 = new Lead();
        newLead1.FirstName = 'Danilo1';
        newLead1.LastName = 'test1';
        newLead1.Email = 'tessttt@test.com';
        newLead1.Phone = '5556331562';
        newLead1.MobilePhone = '';
        newLead1.Marriage_Status__c = 'Married';
        newLead1.Name_of_Deceased__c = '';
        newLead1.Work_Phone__c = '';
        newLead1.Fax = '';
        newLead1.First_Agent__c = u.Id;
        newLead1.OwnerId = u.Id; 
        newLead1.Vendor__c = 'HSI';
        newLead1.Source__c = 'HSI';  
        newLead1.LeadSource = 'Advertisement';
        newLead1.Company =  'Company Test';
        newLead1.Street = '1101  grey eagle dr';
        newLead1.City = 'Orlando';
        newLead1.State = 'FL';
        newLead1.Country = '';
        newLead1.PostalCode = '32822';
        newLead1.Email_2__c = '';
        newLead1.Referral_Notes__c = '';
        newLead1.Referral_Agent__c = u.Alias;
        insert newLead1;
        
        Lead newLead2 = new Lead();
        newLead2.FirstName = 'Danilo2';
        newLead2.LastName = 'test';
        newLead2.Email = 'refused@test.com';
        newLead2.Phone = '5551562';
        newLead2.MobilePhone = '163';
        newLead2.Marriage_Status__c = 'Married';
        newLead2.Name_of_Deceased__c = '';
        newLead2.Work_Phone__c = '';
        newLead2.Fax = 'd43';
        newLead2.First_Agent__c = u.Id;
        newLead2.OwnerId = u.Id; 
        newLead2.Vendor__c = 'HSI';
        newLead2.Source__c = 'HSI';  
        newLead2.LeadSource = 'Advertisement';
        newLead2.Company =  'Company Test';
        newLead2.Street = '11011  grey eagle dr';
        newLead2.City = 'Orlando';
        newLead2.State = 'FL';
        newLead2.Country = '';
        newLead2.PostalCode = '32821';
        newLead2.Email_2__c = '';
        newLead2.Referral_Notes__c = '';
        newLead2.Referral_Agent__c = u.Alias;
        insert newLead2;
    }
    
    @isTest
    static void createRecordsTest()
    {
        Test.startTest();
        
        Account accList = [SELECT Id FROM Account];
        Opportunity oppList = [SELECT Id FROM Opportunity];
        Lead leadList = [SELECT Id,FirstName,LastName,Email,Phone,MobilePhone,Marriage_Status__c,Name_of_Deceased__c,Work_Phone__c,Fax,First_Agent__c,OwnerId,Vendor__c,Source__c,LeadSource,Company,Street,City,State,Country,PostalCode,Email_2__c,Referral_Notes__c,Referral_Agent__c FROM Lead WHERE FirstName = 'Danilo'];
        System.debug('createRecordsTest LeadList Id --> ' + leadList.Id + ' FirstName --> ' + leadList.FirstName);
        Lead leadList1 = [SELECT Id,FirstName,LastName,Email,Phone,MobilePhone,Marriage_Status__c,Name_of_Deceased__c,Work_Phone__c,Fax,First_Agent__c,OwnerId,Vendor__c,Source__c,LeadSource,Company,Street,City,State,Country,PostalCode,Email_2__c,Referral_Notes__c,Referral_Agent__c FROM Lead WHERE FirstName = 'Danilo1'];
        System.debug('createRecordsTest LeadList1 Id --> ' + leadList1.Id + ' FirstName --> ' + leadList1.FirstName);
        Lead leadList2 = [SELECT Id,FirstName,LastName,Email,Phone,MobilePhone,Marriage_Status__c,Name_of_Deceased__c,Work_Phone__c,Fax,First_Agent__c,OwnerId,Vendor__c,Source__c,LeadSource,Company,Street,City,State,Country,PostalCode,Email_2__c,Referral_Notes__c,Referral_Agent__c FROM Lead WHERE FirstName = 'Danilo2'];
        System.debug('createRecordsTest LeadList2 Id --> ' + leadList2.Id + ' FirstName --> ' + leadList2.FirstName);
        
        String JsonMsg = '{"salesForceId": "", "name": "Danilo test", "FirstName": "Danilo", "LastName": "test", "email": "testtt@test.com", "secondaryEmail__c": "", "phone": "5556661562", "mobile": "", "work_Phone__c": "", "fax": "", "address__c": "11011  grey eagle dr", "address2__c": "", "country__c": null, "city__c": "Orlando", "state__c": "FL", "postalCode": "32821", "owner_Id_Ext_DB__c": null, "smtn_OwnerId__c": "1408519", "marriage_Status__c": "Married", "name_of_Deceased": "", "trustee__c": "", "smtN_Products_Information__c": null, "referral_Agent__c": "DAcc", "wwpt_agent__c": "Amadeu Lettieri", "hsi_agent_id__c": "0053t000006rP8l", "vendor_c": "HSI", "leadSource": "HSI", "Referral_Notes__c": "", "crm_origin": "SMTN"}';
        System.debug('JSON serialize --> ' + JsonMsg);
        
        RestRequest req = new RestRequest(); 
   		RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/demourl'; 
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(JsonMsg);
        
        RestContext.request = req;
        RestContext.response= res;
		
       	CreateLeadAccountAndOpportunityServices.createRecords();  
        CreateLeadAccountAndOpportunityServices.CheckDuplicateAccount(leadList);  
        CreateLeadAccountAndOpportunityServices.CheckDuplicateOpportunity(accList.Id);  
        CreateLeadAccountAndOpportunityServices.ValidateLead(leadList2);  
        CreateLeadAccountAndOpportunityServices.CheckDuplicateLead(leadList1, leadList.Id );  
        CreateLeadAccountAndOpportunityServices.ConvertLead(leadList); 
        
        Test.stopTest();
    } 
    
    @isTest
    static void createRecordsTest2()
    {
        Test.startTest();
        
        Account accList = [SELECT Id FROM Account];
        Opportunity oppList = [SELECT Id FROM Opportunity];
        Lead leadList = [SELECT Id,FirstName,LastName,Email,Phone,MobilePhone,Marriage_Status__c,Name_of_Deceased__c,Work_Phone__c,Fax,First_Agent__c,OwnerId,Vendor__c,Source__c,LeadSource,Company,Street,City,State,Country,PostalCode,Email_2__c,Referral_Notes__c,Referral_Agent__c FROM Lead WHERE FirstName = 'Danilo'];
        System.debug('createRecordsTest LeadList Id --> ' + leadList.Id + ' FirstName --> ' + leadList.FirstName);
        Lead leadList1 = [SELECT Id,FirstName,LastName,Email,Phone,MobilePhone,Marriage_Status__c,Name_of_Deceased__c,Work_Phone__c,Fax,First_Agent__c,OwnerId,Vendor__c,Source__c,LeadSource,Company,Street,City,State,Country,PostalCode,Email_2__c,Referral_Notes__c,Referral_Agent__c FROM Lead WHERE FirstName = 'Danilo1'];
        System.debug('createRecordsTest LeadList1 Id --> ' + leadList1.Id + ' FirstName --> ' + leadList1.FirstName);
        Lead leadList2 = [SELECT Id,FirstName,LastName,Email,Phone,MobilePhone,Marriage_Status__c,Name_of_Deceased__c,Work_Phone__c,Fax,First_Agent__c,OwnerId,Vendor__c,Source__c,LeadSource,Company,Street,City,State,Country,PostalCode,Email_2__c,Referral_Notes__c,Referral_Agent__c FROM Lead WHERE FirstName = 'Danilo2'];
        leadList2.Email = 'jrjmweldon@q.com';
        leadList2.MobilePhone = '9999999999';
        leadList2.Work_Phone__c = '9999999999';
        leadList2.Fax = '9999999999';
        update leadList2;
        System.debug('createRecordsTest LeadList2 Id --> ' + leadList2.Id + ' FirstName --> ' + leadList2.FirstName);
        
        String JsonMsg = '{"salesForceId": "", "name": "Danilo test", "FirstName": "Danilo", "LastName": "test", "email": "testtt@test.com", "secondaryEmail__c": "", "phone": "5556661562", "mobile": "", "work_Phone__c": "", "fax": "", "address__c": "11011  grey eagle dr", "address2__c": "", "country__c": null, "city__c": "Orlando", "state__c": "FL", "postalCode": "32821", "owner_Id_Ext_DB__c": null, "smtn_OwnerId__c": "1408519", "marriage_Status__c": "Married", "name_of_Deceased": "", "trustee__c": "", "smtN_Products_Information__c": null, "referral_Agent__c": "", "wwpt_agent__c": "Amadeu Lettieri", "hsi_agent_id__c": "0053t000006rP8l", "vendor_c": "HSI", "leadSource": "HSI", "Referral_Notes__c": "", "crm_origin": "SMTN"}';
        System.debug('JSON serialize --> ' + JsonMsg);
        
        RestRequest req = new RestRequest(); 
   		RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/demourl'; 
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(JsonMsg);
        
        RestContext.request = req;
        RestContext.response= res;
		
       	CreateLeadAccountAndOpportunityServices.createRecords();  
        CreateLeadAccountAndOpportunityServices.CheckDuplicateAccount(leadList);  
        CreateLeadAccountAndOpportunityServices.CheckDuplicateOpportunity(accList.Id);  
        CreateLeadAccountAndOpportunityServices.ValidateLead(leadList2);  
        CreateLeadAccountAndOpportunityServices.CheckDuplicateLead(leadList1, leadList.Id );  
        CreateLeadAccountAndOpportunityServices.ConvertLead(leadList); 
        
        Test.stopTest();
    }
}