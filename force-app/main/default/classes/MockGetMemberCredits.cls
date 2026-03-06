global class MockGetMemberCredits implements HttpCalloutMock 
    {
        global HTTPResponse respond(HTTPRequest req)
        {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            String str = '{"Redeemable":149.00}';
            //str = str + ',"phoneNumber": "1234567890","address": "1252 Some Random Street","city": "Orlando","postalCode": "32555","stateCode": "FL","countryCode": "United States","RenewableYears": 1,"AdvantageWeeksAllocated": 1,"languagePreferred": {"code": "ENG","name": "ENGLISH"}}';
            res.setBody(str);
            res.setStatusCode(200);
            res.setStatus('OK');
            return res;
        }
    }