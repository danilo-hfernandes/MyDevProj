@isTest
Global class HSINCreditHistoryMockAPI implements HTTpCalloutMock {

   global HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        //SendToCyberSource.ParamTransaction pt = new SendToCyberSource.ParamTransaction(); 
            
        HttpResponse res = new HttpResponse();
        res.setHeader('content-type','application/json');
        res.setHeader('api-key', 'asfasd2323');
        res.setBody('{"Data"=({"CreditTransactionStatusType"=2, "CreditTransactions"=({"CreditReferenceNumber"=117228, "CreditValue"=12000.0000, "DonationValue"=0.0, "ReservationNumber"="N/A", "TransactionDate"="2022-03-11T11:17:49.607", "TransactionDescription"=null, "TransactionType"="Hotel"}), DisplayMemberCredit=false, "IsDonationInfoAvailable"=false})}');
       
        res.setStatusCode(200);
        return res;
    } 
    
}