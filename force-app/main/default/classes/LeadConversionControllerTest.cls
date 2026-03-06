@isTest
public class LeadConversionControllerTest {
    @isTest
    static void testAssignLeads() {
        // Create test leads
        Id leadCFRecTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Carefree_Destinations').getRecordTypeId();
         List<Lead> testLeads = new List<Lead>();
        testLeads.add(new Lead(FirstName = 'John', LastName = 'Doe', Company = 'ABC Corp',LeadSource = 'CFD FB', Email = 'test@test1.com', Phone='9874563',RecordTypeId = leadCFRecTypeId,Status='New', Street = 'test', City='test',State='test',Country='test',PostalCode='201'));
        testLeads.add(new Lead(FirstName = 'Jane', LastName = 'Smith', Company = 'XYZ Inc',LeadSource = 'CFD FB', Email = 'test@test21.com', Phone='98745263',RecordTypeId = leadCFRecTypeId,Status='New' ,Street = 'test', City='test',State='test',Country='test',PostalCode='201'));
        insert testLeads;
        List<Lead> testLeads1 = new List<Lead>();
        testLeads1.add(new Lead(FirstName = 'John', LastName = 'Doe', Company = 'ABC Corp',LeadSource = 'CFD FB', Email = 'test@test1.com', Phone='9874563',RecordTypeId = leadCFRecTypeId,Status='New', Street = 'test', City='test',State='test',Country='test',PostalCode='201'));
        testLeads1.add(new Lead(FirstName = 'Jane', LastName = 'Smith', Company = 'XYZ Inc',LeadSource = 'CFD FB', Email = 'test@test21.com', Phone='98745263',RecordTypeId = leadCFRecTypeId,Status='New' ,Street = 'test', City='test',State='test',Country='test',PostalCode='201'));
        insert testLeads1;
        
        // Get the lead IDs
        List<Id> leadIds = new List<Id>();
        for (Lead lead : testLeads1) {
            leadIds.add(lead.Id);
        }
        
        // Call the invocable method
        Test.startTest();
        List<Id> opportunityIds = LeadConversionController.assignLeads(leadIds);
        Test.stopTest();
        
        // Verify the expected behavior
        //System.assertEquals(testLeads.size(), opportunityIds.size());
        
        // Optionally, you can perform additional assertions based on your specific requirements.
        // For example, you could check if the leads were successfully converted to opportunities.
        // You would need to query the converted opportunities and compare their IDs to the opportunityIds list.
        // Remember to query the converted opportunities within the Test.stopTest() block for accurate results.
    }
    
    @isTest
    static void testAssignLeads2() {
        // Create test leads
        Id leadCFRecTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Carefree_Destinations').getRecordTypeId();
         List<Lead> testLeads = new List<Lead>();
        testLeads.add(new Lead(FirstName = 'John', LastName = 'Doe', Company = 'ABC Corp',LeadSource = 'CFD FB', Email = 'test@test1.com', Phone='9874563',RecordTypeId = leadCFRecTypeId,Status='New', Street = 'test', City='test',State='test',Country='test',PostalCode='201',Match_Affiliate_Id__c=1002478));
        testLeads.add(new Lead(FirstName = 'Jane', LastName = 'Smith', Company = 'XYZ Inc',LeadSource = 'CFD FB', Email = 'test@test21.com', Phone='98745263',RecordTypeId = leadCFRecTypeId,Status='New' ,Street = 'test', City='test',State='test',Country='test',PostalCode='201',Match_Affiliate_Id__c=1002478));
        insert testLeads;
        List<Lead> testLeads1 = new List<Lead>();
        testLeads1.add(new Lead(FirstName = 'John', LastName = 'Doe', Company = 'ABC Corp',LeadSource = 'CFD FB', Email = 'test@test1.com', Phone='9874563',RecordTypeId = leadCFRecTypeId,Status='New', Street = 'test', City='test',State='test',Country='test',PostalCode='201', Match_Affiliate_Id__c=1002478));
        testLeads1.add(new Lead(FirstName = 'Jane', LastName = 'Smith', Company = 'XYZ Inc',LeadSource = 'CFD FB', Email = 'test@test21.com', Phone='98745263',RecordTypeId = leadCFRecTypeId,Status='New' ,Street = 'test', City='test',State='test',Country='test',PostalCode='201', Match_Affiliate_Id__c=1002478));
        insert testLeads1;
        
        // Get the lead IDs
        List<Id> leadIds = new List<Id>();
        for (Lead lead : testLeads1) {
            system.debug('Lead.Id='+Lead.Id);
            system.debug('Lead.Affiliate_Id__c='+Lead.Affiliate_Id__c);
            system.debug('Lead.Affiliate_Name__c='+Lead.Affiliate_Name__c);
            system.debug('Lead.CFD_Affiliate_Id__c='+Lead.CFD_Affiliate_Id__c);
			system.debug('Lead.CFD_Affiliate_Name__c='+Lead.CFD_Affiliate_Name__c);
			system.debug('Lead.Match_Affiliate_Id__c='+Lead.Match_Affiliate_Id__c);
			system.debug('Lead.Match_Affiliate_Name__c='+Lead.Match_Affiliate_Name__c);
            leadIds.add(lead.Id);
        }
        
        // Call the invocable method
        Test.startTest();
        List<Id> opportunityIds = LeadConversionController.assignLeads(leadIds);
        Test.stopTest();
        
        // Verify the expected behavior
        //System.assertEquals(testLeads.size(), opportunityIds.size());
        
        // Optionally, you can perform additional assertions based on your specific requirements.
        // For example, you could check if the leads were successfully converted to opportunities.
        // You would need to query the converted opportunities and compare their IDs to the opportunityIds list.
        // Remember to query the converted opportunities within the Test.stopTest() block for accurate results.
    }    
    
    
}