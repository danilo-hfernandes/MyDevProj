@RestResource(urlMapping='/GetHSICheckoutByOrderIdService/*')
Global class GetHSICheckoutByOrderIdService {
    
    @HttpPost
    global static ResponseWrapper GetData(string orderId)
    {
        System.debug('@@OrderId = ' + orderId);
        ResponseWrapper response = new ResponseWrapper();
        
        List<Opportunity> op;
        List<Account> ac;
        ParamTransaction  param = new ParamTransaction();
        
        try{
            
            op = [Select Id, Amount, Total_Amount_Paid__c, RecordTypeId, Total_Amount__c,AccountId, Monthly_Payment__c, Number_of_Payments__c, Down_Deposit__c, Payment_Type__c, Credit_Received__c, Net_Amount__c, RecordType.DeveloperName, (SELECT Id,Product__c,Product2.Description,Product_Id__c,Product2.ProductCode,Product2.Weeks_Number__c,Product2.Name,Product2.Id,Product2.Family,Quantity,UnitPrice,Product2.Upgrade_Product__c, Timeshare__r.VIDA_File_Fee_Amount__c, Timeshare__r.Id, Product2.Product_Type__c /*Timeshare__r.Usage_Fee__c*/ FROM OpportunityLineItems WHERE Product2Id != null) from Opportunity where Order_Id__c =:orderId LIMIT 1];
            ac = [Select Name,Id,Last_Name__c,Email__c,First_Name__c,Affiliated_Id__c,Affiliate_Name__c from Account Where Id =: op[0].AccountId LIMIT 1];
            if(op.size() < 1){
                throw new MyException ('Order Id not found.');
            }
            
            param.OpportunityId = op[0].Id;
            param.RecurringNumberOfPayments = op[0].Number_of_Payments__c;
            param.RecurringAmount = op[0].Monthly_Payment__c;
            param.DownPayment = op[0].Down_Deposit__c;
            param.Amount = op[0].Total_Amount__c;
            param.Total_Amount_Paid = op[0].Total_Amount_Paid__c;
            param.RecurringFrequency = 'monthly';
            param.PaymentType = op[0].Payment_Type__c;
            param.Credit_Received_c = op[0].Credit_Received__c;
            param.Net_Amount_c = op[0].Net_Amount__c;
            
            if(ac[0].First_Name__c == null || ac[0].Last_Name__c == '') {
                if(ac[0].Last_Name__c != null){
                    List<string> temp = ac[0].Last_Name__c.split(' ', 2);
                    param.FirstName = temp[0];
                    param.LastName = temp[1];
                }
                param.AccountEmail = ac[0].Email__c;
            } else {
                param.FirstName = ac[0].First_Name__c;
                param.LastName = ac[0].Last_Name__c;
                param.AccountEmail = ac[0].Email__c;
                param.AffiliateName = ac[0].Affiliate_Name__c;
                param.AffiliateId = ac[0].Affiliated_Id__c;
            } 
            
            param.RecordType = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosById().get(op[0].RecordTypeId).getName();
            
            List<OppProduct> oppProducts = new List<OppProduct>();
            if(op[0].OpportunityLineItems != null)
            {
                List<OpportunityLineItem> olis = new List<OpportunityLineItem>();
                olis = op[0].OpportunityLineItems;
                if(olis != null && olis.size() > 0)
                {
                    
                    for(OpportunityLineItem oli : olis){
                        oppProduct oppProd1 = new oppProduct();
                        oppProd1.ProductNameDesc = oli.Product2.Name+'('+oli.Product2.Description+')';
                        oppProd1.Product2Name = oli.Product2.Name;
                        oppProd1.Product2Id = oli.Product2.Id;
                        oppProd1.Quantity = oli.Quantity;
                        oppProd1.Product2ProductType = oli.Product2.Product_Type__c;
                        
                             
                        //Ticket Maint-902 - Back to Vidanta pass will remove =10% in contract and keep in SF
                        if (oli.Product2.Name == 'Back to Vidanta Pass' || oli.Product2.Name == 'Back to Vidanta Pass TC') {
                            // Calculate the new price with 2 decimal places
                            Decimal unitPrice = oli.UnitPrice / 1.1;
                            oppProd1.Price = unitPrice.setScale(2);
                            System.debug('Unit Price Back to Vidanta : '+unitprice);
                        } 
                        
                        //RC-162 - Reserve Collection MU - The Vida Reserve Week Rebate -show the original price of Vida Usage Fee amount (from timeshare) instead of the Usage Fee x Multiplier. 
                        
                        else if (oli.Product2.Name == 'HC Vida Collection Weeks Usage Fee TC Rebate' || oli.Product2.Name == 'Vida Reserve Week Rebate' || oli.Product2.Name == 'Usage Fee Relief' ) {
                            // Usage Fee price from timeshare instead of total product amount
                            //Decimal unitPrice = oli.Timeshare__r.Usage_Fee__c;

                            /*if (oli.Timeshare__r == null || oli.Timeshare__r.VIDA_File_Fee_Amount__c == null) {
                                throw new AuraHandledException('Missing Timeshare data for OLI Id: ' + oli.Id);
                            }*/
                            Decimal unitPrice1 = oli.Timeshare__r.VIDA_File_Fee_Amount__c;
                            oppProd1.Price = unitPrice1.setScale(2);
                        } 
                        
                        else {
                            // Use the original unit price with 2 decimal places
                            oppProd1.Price = oli.UnitPrice.setScale(2);
                        }

                        oppProd1.TimeshareId = oli.Timeshare__r.Id;
                        oppProd1.WeeksNumber = oli.Product2.Weeks_Number__c;     
                        oppProd1.UpgrProduct = oli.Product2.Upgrade_Product__c;
                        //if used for testing - should be removed after test completed
                        if(op[0].Id != '0064z00002BBtPCAA1'){
                            oppProd1.ProductId = oli.Product_Id__c;
                        }
                        oppProducts.add(oppProd1);
                    }
                }
            }
            if(oppProducts.size()>0){
                param.oppProductList = oppProducts;
            }
            else
            {
                param.oppProductList = null;
            }
            response.data = param;
        }catch (Exception ex){
            System.debug('Exception occurrred on LineNumber:' + ex.getLineNumber() + ', Message:' + ex.getMessage());
            response.status = 'Error';
            response.errorMessage = 'Message:' + ex.getMessage()  + ' - Exception occurrred on LineNumber: ' + ex.getLineNumber();
        }
        response.status = 'Success';
        System.debug('response example : '+response);
        return response;
    }
    global class ResponseWrapper
    {
        ParamTransaction data;
        webservice String status;
        webservice String errorMessage;       
    }
    
    public class ParamTransaction
    {
        public string OpportunityId {get; set;}
        public string RecordType {get; set;}
        public decimal Amount {get; set;}
        public string FirstName { get; set; }
        public string LastName { get; set; }
        public string AffiliateName { get; set; }
        public Decimal AffiliateId { get; set; }
        public decimal RecurringAmount { get; set; }
        public decimal DownPayment {get; set;}
        public string RecurringFrequency { get; set; }
        public string RecurringNumberOfPayments { get; set; }
        public string PaymentType {get; set;}
        public string EnvelopiId    {get; set;}
        public decimal Total_Amount_Paid {get; set;}
        public decimal Credit_Received_c {get; set;}
        public decimal Net_Amount_c {get; set;}
        public string AccountEmail {get; set;}
        public list<OppProduct> oppProductList {get; set;}
        public ParamTransaction(){}
        
    }
    
    public class oppProduct
    {
        public string ProductNameDesc {get; set;}
        public Decimal Quantity {get; set;}
        public Decimal Price {get; set;}
        public boolean UpgrProduct { get; set; }
        public Decimal WeeksNumber{get;set;}
        public String ProductId {get;set;}
        public oppProduct(){}
        public string Product2Name {get; set;}
        public string Product2Id {get; set;}
        public string TimeshareId {get; set;}
        public string Product2ProductType {get; set;}
        
    }
    public class MyException extends Exception {}
}