global class mockHttpResponseGeneratorAssignCadence implements System.HttpCalloutMock {
    global Boolean errored;
    global String myBody;
    global String status;
    global Integer statusCode;

    global mockHttpResponseGeneratorAssignCadence() {
        // Default successful values
        this.myBody = '{"status":"success"}';
        this.status = 'OK';
        this.statusCode = 200;
    }

    global mockHttpResponseGeneratorAssignCadence(String bodyString) {
        this.myBody = bodyString;
        this.status = 'OK';
        this.statusCode = 200;
    }

    global System.HttpResponse respond(System.HttpRequest req) {
        System.HttpResponse res = new System.HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(this.myBody);
        res.setStatusCode(this.statusCode);
        return res;
    }
}