@isTest
public class RedemptionControllerTest {
    
    public static testmethod void RedemptionControllerTest(){
        
        List<Account> accList = new List<Account> ();
        Account acc = new Account();
        acc.Name = 'test';
        accList.add(acc);
        insert accList;
        
        case c = new case();
        c.Subject = 'mail';
        c.Status = 'Open';
       // c.Case_Gets_Created__c = true;
        c.Case_Type__c = 'Rebook Cancelled Request';
        c.Priority = 'Medium';
        c.AccountId = acc.Id;
        insert c;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'test';
        opp.AccountId = acc.Id;
        opp.StageName = 'Customer Won';
        opp.Amount = 300;
        opp.CloseDate = date.newInstance(2022,12,12);
        insert opp;
        
        List<Timeshare__c> timeList = new List<Timeshare__c>();
        Timeshare__c tm = new Timeshare__c();
        tm.Name = 'test';
        tm.Timeshare_Owner__c = acc.Id;
        timeList.add(tm);
        insert timeList;
        
        List<Redemption__c> rdmList = new List<Redemption__c>();
        Redemption__c rdm = new Redemption__c();
        rdm.Status__c = '';
        rdm.Usage_Fee__c = 10;
        rdm.Reservation__c = 'yes';
        rdm.Check_In_Date__c = date.newInstance(2022,12,12);
        rdm.Opportunity__c = opp.Id;
        rdm.Property__c = tm.Id;
        rdm.Redemption_Amount__c = 10;
        
        rdmList.add(rdm);
        insert rdmList;
        
        
        RedemptionController  rd = new RedemptionController();
        RedemptionController.casecreation(rdmList[0].Id);
        RedemptionController.RedemptionList('test');
        try{
            RedemptionController.getResults('test','Name',rdm.id,'value');
            RedemptionController.redemptionWrapper('test');
        }
        catch(Exception e){
        }
        RedemptionController.redemptionWrapper rdmwrp = new RedemptionController.redemptionWrapper();
        rdmwrp.RedemptionObj = rdm;
        try{
            RedemptionController.redemptionWrapper.redemptionWrapper(rdm.id);
        }
        catch(Exception e){
        }
        RedemptionController.SelectOptions rdmsel = new RedemptionController.SelectOptions(timeList[0].id,timeList[0].name);
        RedemptionController.SObJectResult rdmsobj  = new RedemptionController.SObJectResult('test',rdm.id);
    }
    public static testmethod void RedemptionControllerTest2(){
        
        List<Account> accList = new List<Account> ();
        Account acc = new Account();
        acc.Name = 'test';
        accList.add(acc);
        insert accList;
        
        case c = new case();
        c.Subject = 'mail';
        c.Status = 'Open';
       // c.Case_Gets_Created__c = true;
        c.Case_Type__c = 'Rebook Cancelled Request';
        c.Priority = 'Medium';
        c.AccountId = acc.Id;
        insert c;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'test';
        opp.AccountId = acc.Id;
        opp.StageName = 'Customer Won';
        opp.Amount = 300;
        opp.CloseDate = date.newInstance(2022,12,12);
        insert opp;
        
        
        Product2 testProduct = new Product2();
        testProduct.Name = 'Back to Vidanta Pass';
        insert testProduct;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry standardPrice = new PricebookEntry(
        Pricebook2Id = pricebookId, Product2Id = testProduct.Id,
        UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        
        Pricebook2 customPB = new Pricebook2(Name='Custom Pricebook', isActive=true);
        insert customPB;
        
        PricebookEntry customPrice = new PricebookEntry(
        Pricebook2Id = customPB.Id, Product2Id = testProduct.Id,
        UnitPrice = 12000, IsActive = true);
        insert customPrice;
        
         OpportunityLineItem testOpportunityProduct = new OpportunityLineItem();
        testOpportunityProduct.OpportunityId = opp.Id;
        testOpportunityProduct.Product2Id = testProduct.Id;
        testOpportunityProduct.Quantity = 1;
        testOpportunityProduct.PricebookEntryId = customPrice.Id;
        
        insert testOpportunityProduct;
        
        
        List<Timeshare__c> timeList = new List<Timeshare__c>();
        Timeshare__c tm = new Timeshare__c();
        tm.Name = 'test';
        tm.Timeshare_Owner__c = acc.Id;
        timeList.add(tm);
        insert timeList;
        
        List<Redemption__c> rdmList = new List<Redemption__c>();
        Redemption__c rdm = new Redemption__c();
        rdm.Status__c = '';
        rdm.Usage_Fee__c = 10;
        rdm.Reservation__c = 'yes';
        rdm.Check_In_Date__c = date.newInstance(2022,12,12);
        rdm.Opportunity__c = opp.Id;
        rdm.Property__c = tm.Id;
        rdmList.add(rdm);
        insert rdmList;
        
        
        
        
        
        Redemption__c rdm2 = new Redemption__c();
        rdm2.Status__c = '';
        rdm2.Usage_Fee__c = 10;
        rdm2.Reservation__c = 'yes';
        rdm2.Check_In_Date__c = date.newInstance(2022,12,12);
        rdm2.Opportunity__c = opp.Id;
        rdm2.Property__c = tm.Id;
        rdm2.Redemption_Amount__c = 10;
        rdm2.Parent_Redemption__c = rdm.id;
        rdm2.Opportunity_Product__c = testOpportunityProduct.Id;
        insert rdm2 ;
        
        String result = RedemptionController.addNewRedemption(rdm2.id);
        System.assertEquals('Success', result);
        Boolean flag = RedemptionController.showProductName(opp.Id);
        Boolean flag1 = RedemptionController.validateProductName(testOpportunityProduct.Id);
        
    }
}