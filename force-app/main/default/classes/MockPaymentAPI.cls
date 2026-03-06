@isTest
Global class MockPaymentAPI implements HTTpCalloutMock {

   global HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        //
        
        //SendToCyberSource.ParamTransaction pt = new SendToCyberSource.ParamTransaction(); 
            
        HttpResponse res = new HttpResponse();
        res.setHeader('content-type','application/json');
        res.setHeader('api-key', 'asfasd2323');
        res.setBody('{"{"TierLevel": "MTRCS","ContractNumber": "401763","AdvantageCreditsAllocated": 0,"FirstName": "Margaret","LastName": "Hollywood","EmailAddress": "margaret.hollywood@ml.com","PhoneNumber": "9737681988","Address": "17 Old Salem Road","City": "West Orange","PostalCode": "07052","StateCode": "NJ","CountryCode": "United States","RenewableYears": 99,"AdvantageWeeksAllocated": 99,"LanguagePreferred": {"Code": "ENG","Name": "ENGLISH"} }');
       
        res.setStatusCode(200);
        return res;
    } 
    
}