public with sharing class AcousticTokenManager {

    private static final String CACHE_KEY = 'AcousticToken';
    private static final String CACHE_EXP_KEY = 'AcousticTokenExp';

    public static String getValidToken() {
        // 1. Try cache first
        String cachedToken = (String)Cache.Org.get(CACHE_KEY);
        DateTime exp = (DateTime)Cache.Org.get(CACHE_EXP_KEY);

        if (cachedToken != null && exp != null && exp > System.now()) {
            return cachedToken;
        }

        // 2. Otherwise refresh token via callout
        Acoustic_Config__mdt cfg = Acoustic_Config__mdt.getInstance('Default');

        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Acoustic_API/oauth/token');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');

        String body = 
            'grant_type=refresh_token'
            + '&client_id=' + cfg.Client_Id__c
            + '&client_secret=' + cfg.Client_Secret__c
            + '&refresh_token=' + cfg.Refresh_Token__c;

        req.setBody(body);
        HttpResponse res = new Http().send(req);

        if (res.getStatusCode() == 200) {
            Map<String,Object> json = (Map<String,Object>) JSON.deserializeUntyped(res.getBody());
            String newToken = (String) json.get('access_token');
            Integer expiresIn = (Integer) json.get('expires_in');

            // 3. Write into Platform Cache (NO DML)
            Cache.Org.put(CACHE_KEY, newToken, expiresIn);
            Cache.Org.put(CACHE_EXP_KEY, System.now().addSeconds(expiresIn - 60), expiresIn);

            return newToken;
        }

        sendErrorEmail('Token refresh failed', res.getBody());
        return null;
    }

    public static void sendErrorEmail(String subject, String body) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new List<String>{'cicero.schoeps@nerdsoft.com'});
        mail.setSubject('[Salesforce] Acoustic Integration Error: ' + subject);
        mail.setPlainTextBody(body);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
    }
}