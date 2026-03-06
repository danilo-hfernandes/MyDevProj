@RestResource(urlMapping='/getVoucherDetails/*')
global class VoucherDetailsService {
    @HttpPost
    global static ResponseWrapper voucherList(){
        RestRequest req = RestContext.request;
        system.debug('>>>>>req>>>>>>'+req);
        RestResponse res = Restcontext.response;
        ResponseWrapper response = new ResponseWrapper();
        response.status = 'SUCCESS'; 
        response.errorMessage = '';
        String voucherType = String.valueOf(req.params.get('voucherType'));
        String masterRecordId = String.valueOf(req.params.get('masterRecordId'));
        system.debug('>>>>>>>>VoucherType>>>>'+voucherType);
        system.debug('>>>>>>>>masterRecordId>>>>'+masterRecordId);
        List<Opportunity> lstOpportunity = [select id,Guest_Name__c,Referred_By__c,Account.Phone,Account_Email_formula__c,Destination__c,Check_in__c,Check_Out__c,Reservation_Status__c,Record_Type_Name__c,Voucher_Number__c,AccountId, (select id from OpportunityLineItems where Product2.Name = 'Guest Voucher') from opportunity where Account.Master_Record_Id__c =: masterRecordId and StageName = 'Closed Won' and ( Record_Type_Name__c='Voucher' or Record_Type_Name__c ='Hawaii Collection Membership' or Record_Type_Name__c = 'SFX Membership' or  Record_Type_Name__c='MTRC Membership Upgrade')];
        system.debug('>>>>>lstOpportunity>>>>'+lstOpportunity);
        
        if(lstOpportunity != null && lstOpportunity.size() > 0){
            if(voucherType == 'MexicoVoucher'){
                List<MexicoVoucherInformation> voucherList = new List<MexicoVoucherInformation>();
                for(Opportunity opp : lstOpportunity){
                    MexicoVoucherInformation voucherObj = new MexicoVoucherInformation();
                    voucherObj.voucherNumber = opp.Voucher_Number__c;
                    voucherObj.voucherStatus = opp.Reservation_Status__c;
                    voucherObj.travelDates = String.valueOf(opp.Check_in__c) +'-'+ String.valueOf(opp.Check_Out__c);
                    voucherObj.destination = opp.Destination__c;
                    voucherList.add(voucherObj);
                }
                response.mexicoVoucherObjList = voucherList;
            }
            else if(voucherType == 'GuestVoucher'){
                List<GuestVoucherInformation> voucherList = new List<GuestVoucherInformation>();
                for(Opportunity opp : lstOpportunity){
                    if(opp.OpportunityLineItems != null && opp.OpportunityLineItems.size() > 0){
                        GuestVoucherInformation voucherObj = new GuestVoucherInformation();
                        voucherObj.voucherNumber = opp.Voucher_Number__c;
                        voucherObj.voucherStatus = opp.Reservation_Status__c;
                        voucherObj.firstName = opp.Guest_Name__c != null && opp.Guest_Name__c.contains(' ')? opp.Guest_Name__c.substringBefore(' '): (opp.Guest_Name__c != null ? opp.Guest_Name__c : '');
                        voucherObj.lastName = opp.Guest_Name__c != null && opp.Guest_Name__c.contains(' ')? opp.Guest_Name__c.substringAfter(' ') : '';
                        voucherObj.email = opp.Account_Email_formula__c;
                        voucherObj.phone = opp.Account.Phone;
                        voucherObj.referredBy = opp.Referred_By__c;
                        voucherList.add(voucherObj);
                    }
                }
                response.guestVoucherObjList = voucherList;
            }
            else if(voucherType == 'CruiseVoucher'){
                List<CruiseVoucherInformation> voucherList = new List<CruiseVoucherInformation>();
                for(Opportunity opp : lstOpportunity){
                    CruiseVoucherInformation voucherObj = new CruiseVoucherInformation();
                    voucherObj.voucherNumber = opp.Voucher_Number__c;
                    voucherObj.voucherStatus = opp.Reservation_Status__c;
                    voucherObj.guestsNumber = 0;
                    voucherList.add(voucherObj);
                }
                response.cruiseVoucherObjList = voucherList;
            }
            
        }
        return  response;
    }
    global class ResponseWrapper{
        webservice String status; 
        webservice String errorMessage;
        webservice List<MexicoVoucherInformation> mexicoVoucherObjList;
        webservice List<GuestVoucherInformation> guestVoucherObjList;
        webservice List<CruiseVoucherInformation> cruiseVoucherObjList;
    }
    global class MexicoVoucherInformation{
        public String voucherNumber{get;set;}
        public String voucherStatus{get;set;}
        public String destination{get;set;}
        public String travelDates{get;set;}    
        
    }
    global class GuestVoucherInformation{
        public String voucherNumber{get;set;}
        public String voucherStatus{get;set;}
        public String firstName{get;set;}
        public String lastName{get;set;}
        public String email{get;set;}
        public String phone{get;set;}
        public String referredBy{get;set;}    
        
    }
    global class CruiseVoucherInformation{
        public String voucherNumber{get;set;}
        public String voucherStatus{get;set;}
        public Integer guestsNumber{get;set;}   
    }
}