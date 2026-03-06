@isTest
private class DepositsRecordsTest {
    
    @testSetup
    static void setup() {
        Id fileTrackerRecTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Filetracker_Reservations').getRecordTypeId(); 
        Lead lead1 = new Lead(FileTracker_File_Number__c = '117646',Description = 'Filetracker Link: https://filetracker.nerdsoft.com/Details/FileDetail_General.aspx?fileID=117646, FT Created Date: July 1, 2016 1:51pm EST., Resort Name: Americana Village, Resort Phone: , Grade: F, Usage: 330, Week: 1, Bedrooms: 1, Bathrooms: 1, Points: 24500', RecordTypeId = fileTrackerRecTypeId, FirstName = 'John', LastName = 'Doe', Email = 'test1@email.com', Phone = '1234567890', Company='FileTracker', Status = 'Open', Match_Affiliate_Id__c = 1001,Street = 'Test Street 1',City = 'Test City',State = 'CA',Country = 'US',PostalCode = '1234');
        insert lead1;
        
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;
        
        Timeshare__c ts = new Timeshare__c();
        ts.Name = 'Test Imperial Garden';
        ts.Unit_Size__c = '1 Bedroom';
        ts.Ownership__c = 'A&A';
        ts.Fees_Billing_Period__c = 'Annually';
        ts.Usage__c = 'Annual';
        ts.MF_Amount__c = 12;
        ts.Week_Type__c = 'Fixed';
        ts.Week__c = '12';
        ts.First_Year_Use__c = '12';
        ts.Timeshare_Owner__c = acc.Id;
        insert ts;
        
        Case obj = new Case();
        obj.Status = 'New';
        obj.AccountId = acc.Id;
        obj.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Exchanges_and_Deposits').getRecordTypeId();
        insert obj;
        
        Id  standardPb = Test.getStandardPricebookId();//[select id, name, isActive from Pricebook2 where IsStandard = true limit 1];
        
        Pricebook2 pbk1 = new Pricebook2 (Name='Test Pricebook Entry 1', Description='Test Pricebook Entry 1', isActive=true);
        insert pbk1;
        
        Product2 prd1 = new Product2 (Name='Maintenance Fee Protection', Description='Maintenance Fee Protection', isActive = true);
        insert prd1;
        
        PricebookEntry pbe1 = new PricebookEntry (Product2ID=prd1.id,Pricebook2ID=standardPb,UnitPrice=50, isActive=true);
        insert pbe1;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Opportunity';
        opp.CloseDate = System.today();
        opp.StageName = 'New';
        opp.AccountId = acc.Id;
        insert opp;
        
        OpportunityLineItem opplineItem = new OpportunityLineItem();
        opplineItem.Product2Id = prd1.Id;
		opplineItem.OpportunityId = opp.Id;
        opplineItem.PriceBookEntryID=pbe1.id;
        opplineItem.quantity=4;
        opplineItem.totalprice=200;
        opplineItem.Timeshare__c = ts.Id;
        insert opplineItem;
        
        Resort__c r = new Resort__c();
        r.name = 'Americana Village';
        insert r;
        
        Deposits__c inv = new Deposits__c();
        inv.Deposit_Resort_Name__c = 'Test Imperial Garden Resort';
        inv.Check_in_Date__c = System.today();
        //inv.Unit_Type__c = 'Clothes';
        inv.Unit_Number__c = '123';
        inv.Check_Out__c = System.today();
        inv.Reservation_Number__c = '1234';
        inv.Occupancy__c = 123;
        inv.City__c = 'Noida';
        inv.MFP_Entitlement_Amount_Reservation__c = 1234;
        inv.State__c = 'UP';
        inv.Country__c = 'India';
        inv.Final_BW_Price__c = 123;
        inv.Price__c = 123;
        inv.Max_Price_for_Profit_Agility__c = 123;
        inv.Member_Price__c = 123;
        //inv.Days_to_burn_before_Check_In__c = '0';
        inv.Priority__c = 'High';
        inv.Season__c = 'Pull from BE';
        inv.Lowest_Price_GPR__c = 234;
        inv.Maint_Fees__c = 234;
        inv.Due_Date__c = System.today();
        inv.Case__c = obj.Id;
        inv.Resort_Id__c = r.Id;
        inv.Status__c = 'Draft';
        inv.Profile_Name__c = 'Internal Credits';
        insert inv;
        
		inv.Status__c = 'New';
        inv.Client_Deposit_Payment_Schedule_Profile__c = '';
        inv.Profile_Name__c = 'Internal Credits';
        inv.Payment_Type__c = 'Credits';
        update inv;

        delete inv;
        
    }
    
    @isTest
    static void testFetchInventoryData() {
        Case objcase = [select id from Case limit 1];
        Lead objlead = [select id, FileTracker_File_Number__c from Lead limit 1];
        Timeshare__c objTimeshare = [select id from Timeshare__c limit 1];
        // Test fetchInventoryData() method
        Test.startTest();
        List<Deposits__c> inventoryList = DepositsRecords.fetchInventoryData(objcase.Id);
        Map<String, String> timeshareList = DepositsRecords.timeShareRecords(objcase.Id);
        Boolean mfpFlag = DepositsRecords.getMFPValue(objTimeshare.Id);
        List<Case> caseRecords = new List<Case>();
        Case obj = new Case();
        obj.Status = 'New';
        obj.Exchange_Type__c = 'Maintenance Fee Protection';
        insert obj;
        obj.Ownership_Resort__c = 'Aulani, a Disney Resort and Spa';
        caseRecords.add(obj);
        // Add test data for Case records to be updated
        DepositsRecords.updateCaseData(caseRecords, objTimeshare.Id);
        DepositsRecords.fetchAccountAndCaseDetails(objlead.Id);
        Map<String, String> timeshareList1 = DepositsRecords.timeShareRecords(obj.Id);
        List<Case> listCase = DepositsRecords.getCases(objcase.Id);
        Case cs = DepositsRecords.getParentCaseDetails(objcase.Id);
        String message = DepositsRecords.createLinkedCase(objcase.Id, objcase.Id, 200, objTimeshare.Id, 12);
        // Add more assertions
        Test.stopTest();
    }
}