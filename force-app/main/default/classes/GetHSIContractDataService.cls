@RestResource(urlMapping='/GetHSIContractDataService/*')
Global class GetHSIContractDataService {
    @HttpPost
    global static ResponseWrapper GetData(string orderId)
    {
        List<Opportunity> op;
        List<OpportunityLineItem> oppLineItems;
        Set<Id> tsIds = new set<Id>();
        Map<Id,String> timeshareIdProductNameMap = new map<Id,String>();
        
        List<Timeshare__c> ts;
        
        ResponseWrapper response = new ResponseWrapper();
        ReturnObject retVal = new ReturnObject(); 
        try{
            op = [Select Id, 
                  X2nd_Owner__c,
                  Membership_Upgrade_Type__c,
                  Down_Deposit__c,
                  Product_Family__c,
                  Amount, 
                  Monthly_Payment__c,
                  Number_of_Products__c,
                  Order_Id__c,
                  Total_Amount_Paid__c, 
                  RecordTypeId, 
                  AccountId,  
                  Number_of_Payments__c, 
                  Payment_Type__c,
                  Total_Amount__c,
                  Total_Equity_Value__c,
                  Net_Amount__c,
                  Credit_Received__c,
                  First_Name1__c,
                  Last_Name1__c,
                  Account.BillingCity,
                  Account.BillingPostalcode,
                  Account.BillingState,
                  Account.BillingStreet,
                  Account.BillingCountry,
                  Account.Name,
                  Account.Mobile__c,
                  Account.Email__c,
                  Account.Phone,
                  Account.Contact_Id__c,
                  Account.Alternate_Phone__c,
                  Account.Name1__c,
                  Contract_Language__c,
                  Account.Contract_Number__c,
                  Account.Member_Number__c,
                  SMTN_Owner_id__c
                  from Opportunity 
                  where Order_Id__c =: orderId LIMIT 1];
            
            System.debug('THIS IS THE OPP ' + op);
            
            if(op.size() < 1){
                throw new MyException('Order Id not found!');
            }    
            
            Boolean default_Contract_Language_SPA = false;
            //oppLineItems = [Select Timeshare__c from OpportunityLineItem where OpportunityId =: op[0].Id ];
            oppLineItems = [Select Timeshare__c,Product_Id__c, Equity_Value__c,Product2.Name, Multiplier__c,Product2.Id, Timeshare__r.Id from OpportunityLineItem where OpportunityId =: op[0].Id and  ((NOT Product2.Name LIKE '%MTRC Retail%') AND (NOT Product2.Name LIKE '%My Travel Rewards Club%') AND (NOT Product2.Name LIKE '%My Holiday Pass%') )]; 
            //System.debug('THIS IS THE OPPLINEITEMS ' + oppLineItems.lenght);
            Map<Id,String> timeshareIdProductId = new Map<Id,String>();
            Map<Id,Decimal> timeshareIdMultiplier = new Map<Id,Decimal>();
            Map<Id,String> timeshareIdProduct2Id = new Map<Id,String>();
            //Map<Id,String> timeshareIdTimeshareId = new Map<Id,String>();
            for(OpportunityLineItem item: oppLineItems){
                if(item.Product2.Name == 'MXN Hawaii Collection Membership Upgrade Platinum' || item.Product2.Name == 'MXN Hawaii Collection Membership Upgrade Gold'
                   || item.Product2.Name == 'MXN SFX Membership Upgrade Diamond Preferred' || item.Product2.Name == 'MXN SFX Collection Membership Upgrade Diamond Premier')
                {
                    default_Contract_Language_SPA = true;
                }
                if(item.Timeshare__c != null){
                    tsIds.add(item.Timeshare__c);
                    timeshareIdProductId.put(item.Timeshare__c,item.Product_Id__c);
                    timeshareIdProductNameMap.put(item.Timeshare__c,item.Product2.Name);
                    timeshareIdMultiplier.put(item.Timeshare__c,item.Multiplier__c);
                    timeshareIdProduct2Id.put(item.Timeshare__c,item.Product2.Id);
            	    System.debug('THIS IS THE TSIDS !!!!!!!!!!!!!! ' + tsIds);
                    
                }
            }
            
            ts = [Select id, 
                  Annual_Allocation__c,
                  Agree_to_pay_later__c, 
                  Bathrooms__c, 
                  Fees_Billing_Period__c,
                  First_Year_Use__c,
                  Include_In_Settlement_Fee__c,
                  MF_Amount__c,
                  MF_Paid_Until_Month__c,
                  MF_Paid_Until_Year__c,
                  Mortgage__c,
                  Mortgage_Balance__c,
                  Mortgage_Monthly_Payment__c,
                  Mortgage_Payments_Behind_Amount__c,
                  Mortgage_Product__c,
                  Name,
                  Notes_Instructions__c,
                  Ownership__c,
                  Past_Due_MF__c,
                  Payments_Current__c,
                  Points_Anniversary_Effective_Date__c,
                  Retail_Price__c,
                  Sales_Price__c, 
                  Season__c,
                  Settlement_Fee_Formula__c,
                  Settlement_Fee__c,
                  Special_Assessment__c,
                  Subtotal__c,
                  Total_Charge__c,
                  Transfer_Fees_c__c,
                  Unit_Number__c,
                  Unit_Size__c,
                  Usage__c,
                  Vendor_Discount__c,
                  View__c,
                  Week__c,
                  Week_Type__c,
                  Wwpt_Product_Cost__c,
                  Equity_Value__c,
                  City__c,
                  State__c,
                  Property_Id_Ext_DB__c,
                  Country__c,
                  Contract__c,
                  SMTN_LT_Property_ID__c,
                  RTU_Year__c,
                  Amount_of_Points__c,
                  Unit_Type__c,
                  Occupancy__c,
                  Listing_type__c,
                  Listing_Price__c,
                  SMTN_Resort_Id__c,
                  Resort__r.Master_Resort_ID__c,
                  Resort__r.SMTN_Resort_Id__c,
                  Master_Record_Id__c,
                  Trade_In_Value__c
                  from Timeshare__c where Id in :tsIds];
            if(!default_Contract_Language_SPA){
                retVal.Opportunity_Contract_Language_c = string.ValueOf(op[0].Contract_Language__c);
            }
            else
            {
                retVal.Opportunity_Contract_Language_c = 'SPA';
            }
            
            String oppName1;
            
            if (String.isBlank(op[0].First_Name1__c)) {
                oppName1 = String.isBlank(op[0].Last_Name1__c) ? '' : op[0].Last_Name1__c;
            } else {
                oppName1 = String.isBlank(op[0].Last_Name1__c) ? op[0].First_Name1__c : op[0].First_Name1__c + ' ' + op[0].Last_Name1__c;
            }
            
            retVal.Opportunity_Down_Deposit_c = string.valueOf(op[0].Down_Deposit__c);
            retVal.Opportunity_Each_Payment_Amount_c = string.valueOf(op[0].Monthly_Payment__c);
            retVal.Opportunity_Number_Of_Products_c = string.valueOf(op[0].Number_of_Products__c);
            retVal.Opportunity_Order_Id_c = string.valueOf(op[0].Order_Id__c);
            retVal.Opportunity_Payment_Type_c = string.valueOf(op[0].Payment_Type__c);
            retVal.Opportunity_Total_Amount_c = string.valueOf(op[0].Total_Amount__c);
            retVal.Opportunity_X2nd_Owner_c = string.valueOf(op[0].X2nd_Owner__c);
            retVal.Opportunity_Number_of_Payments_c = string.valueOf(op[0].Number_of_Payments__c);
            retVal.Opportunity_Total_Equity_Value_c = string.valueOf(op[0].Total_Equity_Value__c);
            retVal.Opportunity_Net_Amount_c = string.valueOf(op[0].Net_Amount__c);
            retVal.Opportunity_Credits_Received_c = string.valueOf(op[0].Credit_Received__c);
            retVal.Opportunity_Membership_Upgrade_Type_c = string.valueOf(op[0].Membership_Upgrade_Type__c);
            retVal.Opportunity_Product_Family_c = string.valueOf(op[0].Product_Family__c);
            retVal.Account_BillingCity = string.valueOf(op[0].Account.BillingCity);
            retVal.Account_BillingPostalcode = string.valueOf(op[0].Account.BillingPostalcode);
            retVal.Account_BillingState = string.valueOf(op[0].Account.BillingState);
            retVal.Account_BillingStreet = string.valueOf(op[0].Account.BillingStreet);
            retVal.Account_BillingCountry = string.valueOf(op[0].Account.BillingCountry);
            retVal.Account_Name = string.valueOf(op[0].Account.Name);
            retVal.Account_PersonEmail = string.valueOf(op[0].Account.Email__c);
            retVal.Account_PersonMobilephone = string.valueOf(op[0].Account.Mobile__c);
            retVal.Account_Phone = string.valueOf(op[0].Account.Phone);
            retVal.Account_Contact_Id =  Integer.valueOf(op[0].Account.Contact_Id__c);
            retVal.Account_AlternativePhone = String.ValueOf(op[0].Account.Alternate_Phone__c);
            retVal.Account_Secondary_Name_c = String.isBlank(oppName1) ? String.valueOf(op[0].Account.Name1__c) : oppName1;
            //retVal.Account_Secondary_Email_c = string.valueOf(op[0].Account.Secondary_Email__c);
            retVal.Account_Contract_Number = String.valueOf(op[0].Account.Contract_Number__c);
            retVal.Account_Member_Number = String.valueOf(op[0].Account.Member_Number__c);
            retVal.SMTN_Owner_id_c = String.valueOf(op[0].SMTN_Owner_id__c);
            for(Timeshare__c item: ts){
                TimeshareObject tmpTs = new TimeshareObject();
                tmpTs.Agree_To_Pay_Later_c = string.valueOf(item.Agree_To_Pay_Later__c);
                tmpTs.Annual_Allocation_c = string.valueOf(item.Annual_Allocation__c);
                tmpTs.Bathrooms_c = string.valueOf(item.Bathrooms__c);
                tmpTs.Contract_c = string.valueOf(item.Contract__c);
                tmpTs.Fees_Billing_Period_c = string.valueOf(item.Fees_Billing_Period__c);
                tmpTs.First_Year_Use_c = string.valueOf(item.First_Year_Use__c);
                tmpTs.Include_In_Settlement_Fee_c = string.valueOf(item.Include_In_Settlement_Fee__c);
                tmpTs.Mf_Amount_c = string.valueOf(item.Mf_Amount__c);
                tmpTs.Mf_Paid_Until_Month_c = string.valueOf(item.MF_Paid_Until_Month__c);
                tmpTs.Mf_Paid_Until_Year_c = string.valueOf(item.MF_Paid_Until_Year__c);
                tmpTs.Mortgage_c = string.valueOf(item.Mortgage__c);
                tmpTs.Mortgage_Balance_c = string.valueOf(item.Mortgage_Balance__c);
                tmpTs.Mortgage_Monthly_Payment_c = string.valueOf(item.Mortgage_Monthly_Payment__c);
                tmpTs.Mortgage_Payments_Behind_Amount_c = string.valueOf(item.Mortgage_Payments_Behind_Amount__c);
                tmpTs.Mortgage_Product_c = string.valueOf(item.Mortgage_Product__c);
                tmpTs.Name = string.valueOf(item.name);
                tmpTs.Notes_Instructions_c = string.valueOf(item.Notes_Instructions__c);
                tmpTs.Ownership_c = string.valueOf(item.Ownership__c);
                tmpTs.Past_Due_Mf_c = string.valueOf(item.Past_Due_Mf__c);
                tmpTs.Payments_Current_c = string.valueOf(item.Payments_Current__c);
                tmpTs.Points_Anniversary_Effective_Date_c = string.valueOf(item.Points_Anniversary_Effective_Date__c);
                tmpTs.Retail_Price_c = string.valueOf(item.Retail_Price__c);
                tmpTs.Sales_Price_c = string.valueOf(item.Sales_Price__c);
                tmpTs.Season_c = string.valueOf(item.Season__c);
                tmpTs.Settlement_Fee_Formula_c = string.valueOf(item.Settlement_Fee_Formula__c);
                tmpTs.Settlement_Fee_c = string.valueOf(item.Settlement_Fee__c);
                tmpTs.Special_Assessment_c = string.valueOf(item.Special_Assessment__c);
                tmpTs.Subtotal_c = string.valueOf(item.Subtotal__c);
                tmpTs.Total_Charge_c = string.valueOf(item.Total_Charge__c);
                tmpTs.Transfer_Fees_c_c = string.valueOf(item.Transfer_Fees_c__c);
                tmpTs.Unit_Number_c = string.valueOf(item.Unit_Number__c);
                tmpTs.Unit_Size_c = string.valueOf(item.Unit_Size__c);
                tmpTs.Usage_c = string.valueOf(item.Usage__c);
                tmpTs.Vendor_Discount_c = string.valueOf(item.Vendor_Discount__c);
                tmpTs.View_c = string.valueOf(item.View__c);
                tmpTs.Week_c = string.valueOf(item.Week__c);
                tmpTs.Week_Type_c = string.valueOf(item.Week_Type__c);
                tmpTs.Wwpt_Product_Cost_c = string.valueOf(item.Wwpt_Product_Cost__c);
                tmpTs.Equity_Value_c = string.valueOf(item.Equity_Value__c);
                tmpTs.City_c = string.valueOf(item.City__c);
                tmpTs.Country_c = string.valueOf(item.Country__c);
                tmpTs.State_c = string.valueOf(item.State__c);            
                tmpTs.Property_Id_Ext_DB_c = string.valueOf(item.Property_Id_Ext_DB__c);
                tmpTs.Product_Name_c = timeshareIdProductNameMap.get(item.Id);
                tmpTs.SMTN_LT_Property_ID_c = string.valueOf(item.SMTN_LT_Property_ID__c);
                tmpTs.RTU_Year_c = string.valueOf(item.RTU_Year__c);
				tmpTs.Amount_of_Points_c = string.valueOf(item.Amount_of_Points__c);
				tmpTs.Unit_Type_c = string.valueOf(item.Unit_Type__c);
                tmpTs.Occupancy_c = string.valueOf(item.Occupancy__c);
                tmpTs.Listing_type_c = string.valueOf(item.Listing_type__c); 
                tmpTs.Listing_Price_c = string.valueOf(item.Listing_Price__c);
                tmpTs.SMTN_Resort_Id_c = string.valueOf(item.SMTN_Resort_Id__c);
                tmpTs.Resort_SMTN_Resort_Id_c = string.valueOf(item.Resort__r.SMTN_Resort_Id__c);
                tmpTs.Master_Record_Id_c = string.valueOf(item.Master_Record_Id__c);
                tmpTs.Trade_In_Value_c = string.valueOf(item.Trade_In_Value__c);
                tmpTs.Resort_Master_Record_Id_c = string.valueOf(item.Resort__r.Master_Resort_ID__c);
                tmpTs.Product_Id_c = timeshareIdProductId.get(item.Id);
                tmpTs.Multiplier_c = string.valueOf(timeshareIdMultiplier.get(item.Id));
                tmpTs.Product2Id_c = string.valueOf(timeshareIdProduct2Id.get(item.Id));
                tmpTs.TimeshareId_c = string.valueOf(item.Id);
                system.debug('--tmpTs---'+tmpTs);
                retVal.Timeshares.add(tmpTs);
            }
            response.status = 'Success';
            response.data = retVal;
            system.debug('--response.data---'+response.data);
        } catch (Exception ex){
            System.debug('Exception occurrred on LineNumber:' + ex.getLineNumber() + ', Message:' + ex.getMessage());
            response.status = 'Error';
            response.errorMessage = 'Message:' + ex.getMessage()  + ' - Exception occurrred on LineNumber: ' + ex.getLineNumber();
        }
        
        
        return response;
    }
    
    
    global class ResponseWrapper
    {
        ReturnObject data;
        webservice String status;
        webservice String errorMessage;
        
    }    
    public class ReturnObject
    {
        Public String Account_BillingCity {Get; Set;}
        Public String Account_BillingPostalcode {Get; Set;}
        Public String Account_BillingState {Get; Set;}
        Public String Account_BillingStreet {Get; Set;}
        Public String Account_BillingCountry {get; set;}
        Public String Account_Name {Get; Set;}
        Public String Account_PersonEmail {Get; Set;}
        Public String Account_PersonMobilephone {Get; Set;}
        Public String Account_Phone {Get; Set;}
        Public String Account_Secondary_Email_c {Get; Set;}
        Public String Account_Secondary_Name_c {Get; Set;}
        Public Integer Account_Contact_Id {Get; Set;}
        public String Account_AlternativePhone {get;set;}
        public String Account_Contract_Number {get;set;}
        public String Account_Member_Number {get;set;}
        public String SMTN_Owner_id_c {get;set;}
        Public String Opportunity_Down_Deposit_c {Get; Set;}
        Public String Opportunity_Each_Payment_Amount_c {Get; Set;}
        Public String Opportunity_Number_Of_Products_c {Get; Set;}
        Public String Opportunity_Number_of_Payments_c {get; set;}
        Public String Opportunity_Order_Id_c {Get; Set;}
        Public String Opportunity_Payment_Type_c {Get; Set;}
        Public String Opportunity_Total_Amount_c {Get; Set;}
        Public String Opportunity_X2nd_Owner_c {Get; Set;}
        Public String Opportunity_Total_Equity_Value_c {Get; Set;}
        Public String Opportunity_Net_Amount_c {get; set;}
        Public String Opportunity_Credits_Received_c {get; set;}
        Public String Opportunity_Product_Family_c {get; set;}
        Public String Opportunity_Membership_Upgrade_Type_c {Get; Set;}
        Public String Opportunity_Contract_Language_c {Get;set;}
        public List<TimeshareObject> Timeshares {get; set;}
        
        public ReturnObject(){
            Timeshares = new List<TimeshareObject>();
        }
    }
    public class TimeshareObject{
        
        Public String Agree_To_Pay_Later_c {Get; Set;}
        Public String Annual_Allocation_c {Get; Set;}
        Public String Bathrooms_c {Get; Set;}
        Public String Contract_c {Get; Set;}
        Public String Fees_Billing_Period_c {Get; Set;}
        Public String First_Year_Use_c {Get; Set;}
        Public String Include_In_Settlement_Fee_c {Get; Set;}
        Public String Mf_Amount_c {Get; Set;}
        Public String Mf_Paid_Until_Month_c {Get; Set;}
        Public String Mf_Paid_Until_Year_c {Get; Set;}
        Public String Mortgage_c {Get; Set;}
        Public String Mortgage_Balance_c {Get; Set;}
        Public String Mortgage_Monthly_Payment_c {Get; Set;}
        Public String Mortgage_Payments_Behind_Amount_c {Get; Set;}
        Public String Mortgage_Product_c  {Get; Set;}
        Public String Name {Get; Set;}
        Public String Notes_Instructions_c {Get; Set;}
        Public String Ownership_c {Get; Set;}
        Public String Past_Due_Mf_c {Get; Set;}
        Public String Payments_Current_c {Get; Set;}
        Public String Points_Anniversary_Effective_Date_c {Get; Set;}
        Public String Retail_Price_c {Get; Set;}
        Public String Sales_Price_c {Get; Set;}
        Public String Season_c {Get; Set;}
        Public String Settlement_Fee_Formula_c {Get; Set;}
        Public String Settlement_Fee_c {get; set;}
        Public String Special_Assessment_c {Get; Set;}
        Public String Subtotal_c {Get; Set;}
        Public String Total_Charge_c {Get; Set;}
        Public String Transfer_Fees_c_c {Get; Set;}
        Public String Unit_Number_c {Get; Set;}
        Public String Unit_Size_c {Get; Set;}
        Public String Usage_c {Get; Set;}
        Public String Vendor_Discount_c {Get; Set;}
        Public String View_c {Get; Set;}
        Public String Week_c {Get; Set;}
        Public String Week_Type_c {Get; Set;}
        Public String Wwpt_Product_Cost_c {Get; Set;}
        Public String Equity_Value_c {get; set;}
        Public String City_c {get; set;}
        Public String Country_c {get; set;}
        Public String State_c {get; set;} 
        Public String Property_Id_Ext_DB_c {get; set;} 
        Public String Product_Name_c {get; set;}  
        Public String SMTN_LT_Property_ID_c {get; set;} 
        Public String Product_Id_c {get; set;} 
        Public String RTU_Year_c {get; set;} 
        Public String Amount_of_Points_c {get; set;} 
        Public String Unit_Type_c {get; set;} 
        Public String Occupancy_c {get; set;} 
        Public String Listing_type_c {get; set;} 
        Public String Listing_Price_c {get; set;} 
        Public String Multiplier_c {get; set;} 
        Public String SMTN_Resort_Id_c {get; set;} 
        Public String Master_Record_Id_c {get; set;} 
        Public String Resort_Master_Record_Id_c {get; set;} 
        Public String Resort_SMTN_Resort_Id_c {get; set;} 
        Public String Product2Id_c {get; set;} 
        Public String TimeshareId_c {get; set;} 
        Public String Trade_In_Value_c {get; set;} 
        
        
        
    }
    
    public class MyException extends Exception {}
}