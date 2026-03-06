@isTest
Global class ConvertCFDLeadWithProductAndPaymentMock implements HTTpCalloutMock{
    
    global HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        //
        
        //SendToCyberSource.ParamTransaction pt = new SendToCyberSource.ParamTransaction(); 
        
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        res.setBody('{"status": "Success", "errorMessage": null, "data": {"Product_Name": "MX Voucher", "Product_Info": "OpportunityLineItem:{Id=00k53000004I6CwAAK, Product_Id__c=PI-0032346, Quantity=1.00, OpportunityId=00653000004q9zDAAQ, Product2Id=01t530000017azIAAQ, PricebookEntryId=01u53000003IZ0FAAW, TotalPrice=0.00}", "Product_Id": "PI-0032346", "Opportunity_Payment_Record_Type": null, "Opportunity_Name": "Karol Clopp", "Opportunity_Id": "00653000004q9zDAAQ", "leadConversionResults": "Database.LeadConvertResult[getAccountId=0015300000FCCzPAAX;getContactId=0035300000AT9ZgAAL;getErrors=();getLeadId=00Q53000002qLGAEA2;getOpportunityId=00653000004q9zDAAQ;getRelatedPersonAccountId=null;isSuccess=true;]", "Lead_Form_External_Id": null, "Account_Id": "0015300000FCCzPAAX"} }');
        res.setStatusCode(200);
        return res;
    } 
    
}