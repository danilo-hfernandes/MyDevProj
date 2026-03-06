@isTest
public class TravelOBMemberBatchTest {
     @isTest
    static void testBatchAndSchedulable() {
       
        Test.setMock(HttpCalloutMock.class, new AssignContactInOverflowCadenceTestMock());  
        Test.startTest();
        Membership_Product_Configuration__c objmember = new Membership_Product_Configuration__c();
        objmember.Responsible_Party__c = 'Member';
        objmember.Name = 'Test';
        insert objmember;
         Account testAccount1 = new Account(Enrollment_Date__c = System.today(), Name = 'Test Account 1', Affiliated_Id__c = 1002243, Membership_Status__c=
                                         'Active',Preferred_Language__c = 'ENG', Dues_Last_Paid_Until__c= System.today().addDays(-30), Membership_Product_Configuration__c = objmember.Id);
        insert testAccount1;
        
        Account testAccount2 = new Account(Enrollment_Date__c = System.today(), Name = 'Test Account 1', Affiliated_Id__c = 1002243, Membership_Status__c=
                                         'Active',Preferred_Language__c = 'ENG', Dues_Last_Paid_Until__c= System.today().addDays(-30) , Membership_Product_Configuration__c = objmember.Id);
        insert testAccount2;
        
        Contact testContact1 = new Contact(AccountId = testAccount1.Id, LastName = 'Test Account 1');
        insert testContact1;
        
        testAccount1.Parent_Child_Contact_Id__c = testContact1.id;
        Update testAccount1;
        system.debug('testAccount1'+testAccount1);
        
        Contact testContact2 = new Contact(AccountId = testAccount2.Id, LastName = 'Test Account 1');
        insert testContact2;
        
        testAccount2.Parent_Child_Contact_Id__c = testContact2.id;
        Update testAccount2;
        system.debug('testAccount2'+testAccount1);
        
        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 standardPricebook = new Pricebook2(
            Id = pricebookId,
            IsActive = true
        );
        update standardPricebook;
        
        Id  standardPb = standardPricebook.Id;
        Pricebook2 pbk1 = new Pricebook2 (Name='Test Pricebook Entry 1',Description='Test Pricebook Entry 1', isActive=true);
        insert pbk1;
        
        Product2 prd1 = new Product2 (Name='Vacation VIP Membership Upgrade',Description='Test Product Entry 1', isActive = true);
        insert prd1;
        
        
        PricebookEntry pbe1 = new PricebookEntry (Product2ID=prd1.id,Pricebook2ID=standardPb,UnitPrice=50, isActive=true);
        insert pbe1;
        
        Date oppAssignedDate = date.today().addDays(-30);
        
        Id HawaiiOppRecType = [Select id from RecordType where sObjectType = 'Opportunity' and developerName ='Hawaii_Collection_Membership' ].id ;
        Opportunity opp1 = new Opportunity (Name='Opp1_test',Opp_Assign_Date__c = oppAssignedDate,StageName='New',CloseDate=Date.today(),Pricebook2Id = pbe1.Pricebook2Id, AccountId = testAccount1.id,  RecordTypeId = HawaiiOppRecType);
        insert opp1;

        Opportunity opp2 = new Opportunity (Name='Opp2',Opp_Assign_Date__c = oppAssignedDate,StageName='New',CloseDate=Date.today(),Pricebook2Id = pbe1.Pricebook2Id,  AccountId = testAccount2.id, RecordTypeId = HawaiiOppRecType);
        insert opp2;
        
        Update new List<Opportunity>{new Opportunity(Id = opp1.id,StageName = 'Unable to Reach'),new Opportunity(Id = opp2.Id,StageName = 'Unable to Reach')};
        String accountPreferredLanguage = 'ENG';
        Date oppAssignedDate1 = date.today().addDays(-30);
        String query = 'SELECT Id,Name,accountId,Opp_Assign_Date__c from Opportunity where Account_Affiliate_Id__c = 1002243 AND Record_Type_Name__c = \'Hawaii Collection Membership\' AND (StageName =\'Unable to Reach\' OR StageName = \'Pitched Not Closed\'OR StageName = \'Disconnected Number\'OR StageName = \'Auto Open\') AND Opp_Assign_Date__c < : oppAssignedDate1 AND CreatedBy.name IN (\'Salesforce\', \'Dev Account\') AND Account.Preferred_Language__c =: accountPreferredLanguage';
        system.debug(query);
        List<Opportunity> oppList = Database.query(query); 
        system.debug('oppList'+oppList);
        TravelOBMemberBatchController batchController = new TravelOBMemberBatchController();
        Database.executeBatch(batchController);
        Test.stopTest();
    }

}