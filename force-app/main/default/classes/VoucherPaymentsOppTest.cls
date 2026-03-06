@isTest
public class VoucherPaymentsOppTest {
    
    @testSetup
    public static void setupEnvironment() {
        
        User u2=[SELECT Id,Assigned_Contacts__c FROM User where name ='Salesforce'];
        
        Id pricebookId = Test.getStandardPricebookId();
        Id opprecordtypeid = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Voucher').getRecordTypeId();
        
        Account acc = new Account(Name = 'Test Account32');
        insert acc;
        
        Contact con=new contact(lastname='test',email='t@g.com',Assign_to_Sales_Cadence__c=false,Match_Group_Name__c=null,accountid=acc.id);
        insert con;
        
        con.Master_Record_Id__c='test';
        update con;
        
        //Create your product
        Product2 prod = new Product2(
            Name = 'Vacation VIP 5/4-$149',
            ProductCode = 'Pro-X',
            isActive = true
        );
        insert prod;
        
        //Create your pricebook entry
        PricebookEntry pbEntry = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = prod.Id,
            UnitPrice = 100.00,
            IsActive = true
        );
        insert pbEntry;
        
        Opportunity opp1 = new Opportunity (Name='test',StageName='New',Check_in__c=null,CloseDate=Date.today(),Pricebook2Id = pbEntry.Pricebook2Id, AccountId = acc.id,Reservation_Status__c=null, RecordTypeId = opprecordtypeid,Voucher_Expiration_Date__c=system.today());
        
        insert opp1;
        
        //create your opportunity line item.  This assumes you already have an opportunity created, called opp
        OpportunityLineItem oli = new OpportunityLineItem(
            
            OpportunityId = opp1.Id,
            PricebookEntryId = pbEntry.Id        );
        insert oli;
        
    } 
    @isTest 
    public static void assignOpportunityTest() {
        List<Opportunitylineitem> OliList = [SELECT Quantity, UnitPrice, TotalPrice,Opportunity.leadassist__Use_Round_Robin__c, Product2.name,Opportunity.name,Opportunity.Vacation_Match_Group__c,Opportunity.id,Opportunity.Voucher_Expiration_Date__c,Opportunity.Recordtypeid FROM OpportunityLineItem  where (Product2.name='Vacation VIP 8/7 $499' OR Product2.name='Vacation VIP 8/7- $99 Down-$499') AND Opportunity.Record_Type_Name__c='Voucher' AND Opportunity.Record_Type_Name__c='FALSE'AND Name Like 'Test%'];  
        // Set mock callout class     
        system.debug('71 test='+OliList);
        Test.setMock(HttpCalloutMock.class, new VoucherPaymentsOppTestMock());  
        Test.startTest();
        VoucherPaymentsOpp ba= new VoucherPaymentsOpp();
        Id jobid= Database.executeBatch(ba,5);
        Test.stopTest();       
    }
}