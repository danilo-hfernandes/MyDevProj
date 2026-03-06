public with sharing class AcousticCampaignService {
    private static final String BASE_URL = 'callout:Acoustic_API';
    private static final String XML_ENDPOINT = '/XMLAPI';
    private static Acoustic_Config__mdt cfg = Acoustic_Config__mdt.getInstance('Default');

    //public static Map<String,String> getRecipientIds(List<Account> accounts) {
	public static Map<String, RecipientInfo> getRecipientIds(List<Account> accounts) {
        System.debug('Starting getRecipientIds...');
        //Map<String,String> results = new Map<String,String>();
        Map<String, RecipientInfo> results = new Map<String, RecipientInfo>();
    	String token = AcousticTokenManager.getValidToken();
        if (token == null) return results;

        for (Account acc : accounts) {
	       if (String.isBlank(acc.Email__c)) continue;
            try {
            String xmlBody = 
                '<Envelope><Body><SelectRecipientData>' +
                    '<LIST_ID>' + cfg.List_Id__c + '</LIST_ID>' +
                    '<COLUMN><NAME>AccountID__c</NAME><VALUE>' + acc.Id + '</VALUE></COLUMN>' +
                    '<COLUMN><NAME>Email</NAME><VALUE>' + acc.Email__c + '</VALUE></COLUMN>' +
                '</SelectRecipientData></Body></Envelope>'; 
                
                System.debug('xmlBody: ' + xmlBody);
                System.debug('BASE_URL: ' + BASE_URL);
                System.debug('XML_ENDPOINT: ' + XML_ENDPOINT);
                System.debug('token: ' + token);

                HttpRequest req = new HttpRequest();
                req.setEndpoint(BASE_URL + XML_ENDPOINT);
                req.setMethod('POST');
                req.setHeader('Authorization', 'Bearer ' + token);
                //req.setHeader('Content-Type', 'application/xml');
                //req.setBody(xmlBody);
                req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
                req.setBody('xml=' + EncodingUtil.urlEncode(xmlBody, 'UTF-8'));

                HttpResponse res = new Http().send(req);
                System.debug('res: ' + res);
                System.debug('res.getStatusCode(): ' + res.getStatusCode());
                System.debug('res.getBody(): ' + res.getBody());
                if (res.getStatusCode() == 200 && res.getBody().contains('<SUCCESS>TRUE</SUCCESS>')) {

//                    results.put(acc.Email__c, extractTag(res.getBody(), 'RecipientId'));

                    String recipientId = extractTag(res.getBody(), 'RecipientId');

                    results.put(
                        acc.Email__c,
                        new RecipientInfo(recipientId, acc.Membership_Product_Config_Ext_Db__c)
                    );
                } else {
                    AcousticTokenManager.sendErrorEmail('Recipient Lookup Failed for ' + acc.Email__c, res.getBody());
                }
            } catch (Exception e) {
                AcousticTokenManager.sendErrorEmail('Recipient API Exception', e.getMessage());
            }
        }
        return results;
    }

    //public static void addContactsToProgram(Map<String,String> emailToRecipientId) {
    public static void addContactsToProgram(Map<String, RecipientInfo> emailInfoMap) {

        System.debug('Starting addContactsToProgram...');
        String token = AcousticTokenManager.getValidToken();
        if (token == null) return;

        //for (String email : emailToRecipientId.keySet()) {
        for (String email : emailInfoMap.keySet()) {

            RecipientInfo info = emailInfoMap.get(email);
            
            String programId = getProgramIdForProduct(info.membershipProduct);
            if (programId == null) continue;

            try {
                //String recipientId = emailToRecipientId.get(email);
               // if (recipientId == null) continue;

            String xmlBody =
                '<Envelope><Body><AddContactToProgram>' +
                    '<PROGRAM_ID>' + programId + '</PROGRAM_ID>' +
                    '<CONTACT_ID>' + info.recipientId + '</CONTACT_ID>' +
                '</AddContactToProgram></Body></Envelope>';

                /*
                String xmlBody = '<Envelope><Body><AddContactToProgram>'
                    + '<PROGRAM_ID>' + cfg.Program_Id__c + '</PROGRAM_ID>'
                    + '<CONTACT_ID>' + recipientId + '</CONTACT_ID>'
                    + '</AddContactToProgram></Body></Envelope>';
                */
                
                System.debug('getRecipientIds PROGRAM_ID: '+ cfg.Program_Id__c);
                //System.debug('getRecipientIds CONTACT_ID: '+ recipientId);
        
                HttpRequest req = new HttpRequest();
                req.setEndpoint(BASE_URL + XML_ENDPOINT);
                req.setMethod('POST');
                req.setHeader('Authorization', 'Bearer ' + token);
//                req.setHeader('Content-Type', 'application/xml');
//                req.setBody(xmlBody);
                req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
                req.setBody('xml=' + EncodingUtil.urlEncode(xmlBody, 'UTF-8'));

                HttpResponse res = new Http().send(req);
                System.debug('res: ' + res);
                System.debug('res.getStatusCode(): ' + res.getStatusCode());
                System.debug('res.getBody(): ' + res.getBody());
                if (!(res.getStatusCode() == 200 && res.getBody().contains('<SUCCESS>TRUE</SUCCESS>'))) {
                    AcousticTokenManager.sendErrorEmail('AddToProgram Success for ' + email, res.getBody());
                }
                else
                {//test
                    AcousticTokenManager.sendErrorEmail('AddToProgram Failed for ' + email, res.getBody());
                }
            } catch (Exception e) {
                AcousticTokenManager.sendErrorEmail('AddToProgram Exception', e.getMessage());
            }
        }
    }

    private static String extractTag(String xml, String tag) {
        Pattern p = Pattern.compile('<' + tag + '>(.*?)</' + tag + '>');
        Matcher m = p.matcher(xml);
        return m.find() ? m.group(1) : null;
    }
    
    public class RecipientInfo {
        public String recipientId;
        public String membershipProduct;
        
        public RecipientInfo(String recipientId, String membershipProduct) {
            this.recipientId = recipientId;
            this.membershipProduct = membershipProduct;
        }
    }
    
    private static String getProgramIdForProduct(String productCode) {
        Acoustic_Config__mdt cfg = Acoustic_Config__mdt.getInstance('Default');
        
        if (productCode == 'A1002454') return cfg.Ruby_Program_Id__c;
        if (productCode == 'A1002455') return cfg.Emerald_Program_Id__c;
        if (productCode == 'A1002456') return cfg.Sapphire_Program_Id__c;
        
        return null;
    }

}