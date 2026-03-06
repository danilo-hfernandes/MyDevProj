public class CertificateTriggerHandler {
    
    public static void sendBalanceLowNotification(List<Certificate__c> certificateList){
        set<String> setCouponType = new set<String>();
        for(Certificate__c objcert : certificateList){
            if(objcert.Certificate_Redeemed__c){
                setCouponType.add(objcert.Coupon_Type__c);
            }
        }
        if(certificateList != null && certificateList.size() > 0 && setCouponType != null && setCouponType.size() > 0){
            Map<String , Integer> mapCouponVsCount = new Map<String, Integer>();
            List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>(); 
            AggregateResult[] groupedResults = [SELECT Coupon_Type__c, COUNT(ID) no FROM Certificate__c where Coupon_Type__c IN: setCouponType and Certificate_Redeemed__c = false GROUP BY Coupon_Type__c];
            for (AggregateResult ar : groupedResults)  {
                String couponType = String.ValueOf(ar.get('Coupon_Type__c'));
                Integer count = Integer.valueOf(ar.get('no'));
                mapCouponVsCount.put(couponType,count);
            }
            system.debug('>>>mapCouponVsCount>>'+mapCouponVsCount);
            if(mapCouponVsCount != null){
                for(String couponType : mapCouponVsCount.Keyset()){
                    if(mapCouponVsCount.containsKey(couponType) && mapCouponVsCount.get(couponType) <= 20){
                        Messaging.SingleEmailMessage mailToBeSent = new Messaging.SingleEmailMessage();
                        User sender = [SELECT Id, Email FROM User WHERE Name = 'Salesforce' LIMIT 1];	
                            
                            String[] sendingTo = new String[]{};
                                String message = 'This is to inform you that the number of '+couponType+' has reached '+mapCouponVsCount.get(couponType)+'. Please ensure that the certificates are uploaded at your earliest convenience to avoid any potential issues.';
                        String subject = 'Urgent: '+couponType+' Certificate Upload Required';
                        Boolean runningInASandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
                        if(!runningInASandbox){
                            sendingTo=new String[]{'amadeu.lettieri@nerdsoft.com','diana.maali@nerdsoft.com', 'danilo.fernandes@nerdsoft.com', 'sergio@vacationinnovations.com'};
                                }
                        else{
                            sendingTo = new String[]{'shivani.chauhan@nerdsoft.com', 'danilo.fernandes@nerdsoft.com'};
                                }
                        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'dev@nerdsoft.com'];
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        if ( owea.size() > 0 ) {
                            mailToBeSent.setOrgWideEmailAddressId(owea.get(0).Id);
                        }
                        mailToBeSent.setSubject(subject);
                        mailToBeSent.setToAddresses(sendingTo);                        
                        mailToBeSent.setPlainTextBody(message);
                        emailList.add(mailToBeSent);
                    }
                }
            }
            if(!emailList.isEmpty()){
                Messaging.sendEmail(emailList); 
            } 
        }
    }
}