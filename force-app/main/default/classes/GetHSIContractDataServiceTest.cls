@isTest
public class GetHSIContractDataServiceTest {
     @isTest
    static void Test1() {
        
        Account a = new account();
        a.Name = 'Mitul';
        a.Last_Name__c = 'test';
        a.BillingCity = 'olympia';
        a.BillingPostalcode = '98502';
        a.BillingState = 'wa';
        a.BillingStreet = 'test dr';
        a.Email__c = 'test@test.com';
        a.Phone = '1234569874';
        a.Contact_Id__c = 123456789;
        insert a;
 		
        Resort__c r = new Resort__c();
        r.name = 'test';
        insert r;
        
        List<Timeshare__c> tsList = new List<Timeshare__c>();
        
        Timeshare__c tsC = new Timeshare__c();
        tsc.Name = 'tst ts';
        tsC.Resort__c = r.Id;
        tsC.Mortgage_Monthly_Payment__c = '0';
        tsC.Master_Record_Id__c = 'Mitul1234';
        tsList.add(tsc);
        insert tsList;
        
        Opportunity retVal = new Opportunity();
        
        retVal.Down_Deposit__c = 50;
        retVal.AccountId = a.id;
        retVal.Name = 'test opp';
        retVal.CloseDate = system.today();
        retVal.StageName = 'Process of Closing*'; 
        retVal.Payment_Type__c = 'Single Credit Card - With PP';
        retVal.X2nd_Owner__c = null;
        retVal.Number_of_payments__c = '4';
        retval.Timeshare_1__c = tsList[0].id;
       
        List<Opportunity> oppList = new List<Opportunity>();
        oppList.add(retVal);
        insert oppList;
        
        List<Opportunity> orderid = [SELECT id, Order_Id__c from Opportunity WHERE id = :oppList[0].id LIMIT 1];
        Product2 p = new Product2();
        p.Name = 'WWPT Short Sale';
        p.isActive = true;
        insert p;
        
        id pricebookId = Test.getStandardPricebookId();
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = p.Id, UnitPrice = 10000, IsActive = true);
		insert standardPrice;
        Pricebook2 pb = new Pricebook2();
        pb.isActive = true;
        pb.Name = 'Standard Pricebook';
        insert pb;
        
        OpportunityLineItem opLI = new OpportunityLineItem();
        opLi.OpportunityId = orderid[0].Id;
        opli.Product2Id = p.id;
        opli.PricebookEntryId = standardPrice.id;
        opli.Retail_Price__c = 20;
        opli.Timeshare__c = tsList[0].id;
        insert opLI;

        GetHSIContractDataService.GetData(orderid[0].order_Id__c);
        GetHSIContractDataService.ReturnObject ro = new GetHSIContractDataService.ReturnObject();
         GetHSIContractDataService.TimeshareObject ts = new GetHSIContractDataService.TimeshareObject();
        
        ts.name = 'test';
        ts.Agree_To_Pay_Later_c = 'Yes';
        ts.Annual_Allocation_c = '234';
        ts.Bathrooms_c = '3 Bathrooms';
        ts.Contract_c = '2345';
        ts.Fees_Billing_Period_c ='Annually';
        ts.First_Year_Use_c = '9090';
        ts.Include_In_Settlement_Fee_c = 'No';
        ts.Mf_Amount_c = '789';
        ts.Mf_Paid_Until_Month_c = 'March';
        ts.Mf_Paid_Until_Year_c = '8989';
        ts.Mortgage_Balance_c = '0';
        ts.Mortgage_Monthly_Payment_c = '789';
        ts.Notes_Instructions_c = 'test';
        ts.Ownership_c = 'test';
        ts.Past_Due_Mf_c = 'test';
        ts.Payments_Current_c = 'test';
        ts.Points_Anniversary_Effective_Date_c = 'test';
        ts.Retail_Price_c = 'test';
        ts.Sales_Price_c = 'test';
        ts.Season_c = 'test';
        ts.Settlement_Fee_Formula_c = 'test';
        ts.Special_Assessment_c = 'test';
        ts.Subtotal_c = 'test';
        ts.Total_Charge_c = 'test';
        ts.Transfer_Fees_c_c = 'test';
        ts.Unit_Number_c = 'test';
        ts.Unit_Size_c = 'test';
        ts.Usage_c = 'test';
        ts.Vendor_Discount_c = 'test';
        ts.View_c ='test';
        ts.Week_c = 'test';
        ts.Week_Type_c = 'test';
        ts.Wwpt_Product_Cost_c = 'test';
        ts.Settlement_Fee_c = '10.00';
    }
}