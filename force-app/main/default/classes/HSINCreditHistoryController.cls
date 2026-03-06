public class HSINCreditHistoryController {
    @AuraEnabled(cacheable=true)
    public static List<CreditTransactionDetailDTO> getHistoryData(String contactId) {
        List<CreditTransactionDetailDTO> listCreditTranDetail = new List<CreditTransactionDetailDTO>();
        Boolean runningInASandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
        String endpoint = '';
        if (runningInASandbox) {
            endpoint = 'https://webapihsicorev2-qa.azurewebsites.net/api/Account/GetCreditsHistory?contactId=' + contactId;
        } else {
            endpoint = 'https://webapihsicorev2.azurewebsites.net/api/Account/GetCreditsHistory?contactId=' + contactId;
        }

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod('GET');
        request.setHeader('content-type', 'application/json');
        system.debug('--request--' + request);
        String response = '';

        try {  
            HttpResponse httpResponse = http.send(request);
            system.debug('--httpResponse--' + httpResponse);
            
            if (httpResponse.getStatusCode() != 200 && httpResponse.getStatus() != 'OK') {
                response = JSON.serializePretty(JSON.deserializeUntyped(httpResponse.getBody()));
                Map<String, Object> receivedData = (Map<String, Object>) JSON.deserializeUntyped(response);
                String message = String.valueOf(receivedData.get('message'));
                system.debug('--message-' + message);
            } else {
                response = JSON.serializePretty(JSON.deserializeUntyped(httpResponse.getBody()));
                Map<String, Object> receiveddata = (Map<String, Object>) JSON.deserializeUntyped(response);
                system.debug('--receiveddata-' + receiveddata);
                List<Object> listcreditTrans = (List<Object>) receiveddata.get('Data');  
                system.debug('listcreditTrans' + listcreditTrans);
                for (Object obj : listcreditTrans) {
                    List<CreditTransactionDTO> listCreditTransaction = new List<CreditTransactionDTO>();
                    Map<String, Object> mapcredits = (Map<String, Object>) obj;
                    system.debug('>>>>>' + mapcredits);
                    Integer creditStatusType = (Integer) mapcredits.get('CreditTransactionStatusType');
                    List<Object> objlist = (List<Object>) mapcredits.get('CreditTransactions');
                    Decimal totalCredits = 0.0;

                    for (Object creditslistObj : objlist) {
                        Map<String, Object> creditsObj = (Map<String, Object>) creditslistObj;
                        CreditTransactionDTO objCreditTransaction = new CreditTransactionDTO();
                        objCreditTransaction.TransactionDate = (String) creditsObj.get('TransactionDate');
                        objCreditTransaction.TransactionType = (String) creditsObj.get('TransactionType');
                        objCreditTransaction.TransactionDescription = (String) creditsObj.get('TransactionDescription');
                        objCreditTransaction.ReservationNumber = (String) creditsObj.get('ReservationNumber');
                        objCreditTransaction.CreditReferenceNumber = (String) creditsObj.get('CreditReferenceNumber');
                        objCreditTransaction.CreditValue = (decimal) creditsObj.get('CreditValue');
                        objCreditTransaction.DonationValue = (decimal) creditsObj.get('DonationValue');
                        totalCredits += (decimal) creditsObj.get('CreditValue');
                        listCreditTransaction.add(objCreditTransaction);
                    }
                    
                    CreditTransactionDetailDTO objCreditTranDetail = new CreditTransactionDetailDTO();
                    
                    if (creditStatusType == 2) {
                        objCreditTranDetail.CreditTransactionStatusType = 'Earned';
                        objCreditTranDetail.totalEarnedCredits = totalEarnedCredits; 
                        objCreditTranDetail.CreditTransactionsEarned = listCreditTransaction;
                    } else if (creditStatusType == 3) {
                        objCreditTranDetail.CreditTransactionStatusType = 'Redeemed';
                        objCreditTranDetail.totalRedeemedCredits = totalRedeemedCredits;
                        objCreditTranDetail.CreditTransactionsRedeemed = listCreditTransaction;
                    } else if (creditStatusType == 5) {
                        objCreditTranDetail.CreditTransactionStatusType = 'Retracted'; 
                        objCreditTranDetail.totalRetractedCredits = totalRetractedCredits;
                        objCreditTranDetail.CreditTransactionsRetracted = listCreditTransaction;
                    } else if (creditStatusType == 1) {
                        objCreditTranDetail.CreditTransactionStatusType = 'Pending';
                        objCreditTranDetail.totalPendingCredits = totalPendingCredits;
                        objCreditTranDetail.CreditTransactionsPending = listCreditTransaction;
                    }
                    objCreditTranDetail.IsDonationInfoAvailable = (Boolean) mapcredits.get('IsDonationInfoAvailable');
                    objCreditTranDetail.DisplayMemberCredit = (Boolean) mapcredits.get('DisplayMemberCredit');
                    listCreditTranDetail.add(objCreditTranDetail);
                }
                system.debug('>>listCreditTranDetail>>' + listCreditTranDetail);
            }
        } catch (System.Exception e) {
            System.debug('ERROR: ' + e);
        }
        return listCreditTranDetail;  
    }
    
	@AuraEnabled(cacheable=true)
    public static Map<String, Decimal> getMemberCredits(String memberNumber) {
        Map<String, Decimal> creditsMap = new Map<String, Decimal>();
        Boolean runningInASandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
        String endpoint = '';

        if (runningInASandbox) {
            endpoint = 'https://webapihsicorev2-qa.azurewebsites.net/api/GetAdvantageCredits/GetMemberCredits/' + memberNumber;
        } else {
            endpoint = 'https://webapihsicorev2.azurewebsites.net/api/GetAdvantageCredits/GetMemberCredits/' + memberNumber;
        }

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod('GET');
        request.setHeader('content-type', 'application/json');
        system.debug('--getMemberCredits.Request--' + request);
        system.debug('--getMemberCredits.memberNumber--' + memberNumber);
        String response = '';

        try {  
            HttpResponse httpResponse = http.send(request);
            system.debug('--getMemberCredits.HttpResponse--' + httpResponse);

            if (httpResponse.getStatusCode() != 200 && httpResponse.getStatus() != 'OK') {
                response = JSON.serializePretty(JSON.deserializeUntyped(httpResponse.getBody()));
                Map<String, Object> receivedData = (Map<String, Object>) JSON.deserializeUntyped(response);
                String message = String.valueOf(receivedData.get('message'));
                system.debug('--getMemberCredits.Message-' + message);
            } else {
                response = httpResponse.getBody();
                system.debug('--getMemberCredits.Response--' + response);
                
                Map<String, Object> receivedData = (Map<String, Object>) JSON.deserializeUntyped(response);
            
            	creditsMap.put('totalEarnedCredits', Decimal.valueOf(String.valueOf(receivedData.get('Earned'))));
            	creditsMap.put('totalRedeemedCredits', Decimal.valueOf(String.valueOf(receivedData.get('Redeemed'))));
            	creditsMap.put('totalRedeemableCredits', Decimal.valueOf(String.valueOf(receivedData.get('Redeemable'))));
            	creditsMap.put('totalPendingCredits', Decimal.valueOf(String.valueOf(receivedData.get('Pending'))));
            
            	system.debug('getMemberCredits.totalEarnedCredits: ' + creditsMap.get('totalEarnedCredits'));
            	system.debug('getMemberCredits.totalRedeemedCredits: ' + creditsMap.get('totalRedeemedCredits'));
            	system.debug('getMemberCredits.totalRedeemableCredits: ' + creditsMap.get('totalRedeemableCredits'));
            	system.debug('getMemberCredits.totalPendingCredits: ' + creditsMap.get('totalPendingCredits'));
            }
        } catch (System.Exception e) {
            System.debug('ERROR: ' + e);
        }
        return creditsMap;
    }
    

    private static Decimal totalEarnedCredits = 0;
    private static Decimal totalRedeemedCredits = 0;
    private static Decimal totalRedeemableCredits = 0;
    private static Decimal totalPendingCredits = 0;
    private static Decimal totalRetractedCredits = 0;

    public class CreditTransactionDetailDTO {
        @AuraEnabled
        public String CreditTransactionStatusType { get; set; }
        @AuraEnabled
        public Boolean IsDonationInfoAvailable { get; set; }
        @AuraEnabled
        public Boolean DisplayMemberCredit { get; set; }
        @AuraEnabled
        public List<CreditTransactionDTO> CreditTransactionsPending { get; set; }
        @AuraEnabled
        public List<CreditTransactionDTO> CreditTransactionsRedeemable { get; set; }
        @AuraEnabled
        public List<CreditTransactionDTO> CreditTransactionsRedeemed { get; set; }
        @AuraEnabled
        public List<CreditTransactionDTO> CreditTransactionsRetracted { get; set; }
        @AuraEnabled
        public List<CreditTransactionDTO> CreditTransactionsEarned { get; set; }
        @AuraEnabled
        public decimal totalPendingCredits { get; set; }
        @AuraEnabled
        public decimal totalRedeemableCredits { get; set; }
        @AuraEnabled
        public decimal totalRedeemedCredits { get; set; }
        @AuraEnabled
        public decimal totalRetractedCredits { get; set; }
        @AuraEnabled
        public decimal totalEarnedCredits { get; set; }
    }

    public class CreditTransactionDTO {
        @AuraEnabled
        public String TransactionDate { get; set; }
        @AuraEnabled
        public string TransactionType { get; set; }
        @AuraEnabled
        public string TransactionDescription { get; set; }
        @AuraEnabled
        public string ReservationNumber { get; set; }
        @AuraEnabled
        public string CreditReferenceNumber { get; set; }
        @AuraEnabled
        public decimal CreditValue { get; set; }
        @AuraEnabled
        public decimal DonationValue { get; set; }
    }
}