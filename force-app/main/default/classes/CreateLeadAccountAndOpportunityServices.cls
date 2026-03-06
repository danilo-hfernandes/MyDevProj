@RestResource(urlMapping='/createLeadAccountAndOpportunity/*')
Global class CreateLeadAccountAndOpportunityServices {
    private static final String SUCCESS = 'Success';
    private static final String ERROR = 'Error';
    @Httppost
    global static ResponseWrapper createRecords(){
        ResponseWrapper response = new ResponseWrapper();
        response.status = SUCCESS;
        response.errorMessage = '';
        RestRequest req = RestContext.request;
        try
        {
            Map<String,Object> receivedData = (Map<String,Object>)JSON.deserializeUntyped(req.requestBody.toString());
            String incommingId = receivedData.containsKey('salesForceId') ? String.valueOf(receivedData.get('salesForceId')) : '';
            Lead newLead = new Lead();
            newLead.FirstName = String.valueOf(receivedData.get('FirstName'));
            newLead.LastName = receivedData.containsKey('LastName')? String.valueOf(receivedData.get('LastName')): '';
            newLead.Email = receivedData.containsKey('email')? String.valueOf(receivedData.get('email')): '';
            newLead.Phone = receivedData.containsKey('phone')? String.valueOf(receivedData.get('phone')): '';
            newLead.MobilePhone = receivedData.containsKey('mobile')? String.valueOf(receivedData.get('mobile')): '';
            newLead.Marriage_Status__c = receivedData.containsKey('marriage_Status__c')? String.valueOf(receivedData.get('marriage_Status__c')): '';
            newLead.Name_of_Deceased__c = receivedData.containsKey('name_of_Deceased')? String.valueOf(receivedData.get('name_of_Deceased')): '';
            newLead.Work_Phone__c = receivedData.containsKey('work_Phone__c')? String.valueOf(receivedData.get('work_Phone__c')): '';
            newLead.Fax = receivedData.containsKey('fax')? String.valueOf(receivedData.get('fax')): '';
            newLead.First_Agent__c = String.valueOf(receivedData.get('hsi_agent_id__c')).replace('"','');
            newLead.OwnerId = String.valueOf(receivedData.get('hsi_agent_id__c')).replace('"',''); 
            newLead.Vendor__c = receivedData.containsKey('vendor_c')? String.valueOf(receivedData.get('vendor_c')): '';
            newLead.Source__c = receivedData.containsKey('leadSource')? String.valueOf(receivedData.get('leadSource')): '';  
            newLead.LeadSource = receivedData.containsKey('leadSource')? String.valueOf(receivedData.get('leadSource')): '';
            newLead.Company =  String.valueOf(receivedData.get('FirstName'))+ ' '+ (receivedData.containsKey('LastName')? String.valueOf(receivedData.get('LastName')):'');
            //newLead.Trust_Trustee_s__c = receivedData.containsKey('trustee__c')? String.valueOf(receivedData.get('trustee__c')): '';
            //newLead.SMTN_Products_Information__c = receivedData.containsKey('smtN_Products_Information__c')? String.valueOf(receivedData.get('smtN_Products_Information__c')): '';
            String address = receivedData.containsKey('address__c')? String.valueOf(receivedData.get('address__c')): '';
            address += receivedData.containsKey('address2__c')? (' ' + String.valueOf(receivedData.get('address2__c'))): '';
            newLead.Street = address;
            newLead.City = receivedData.containsKey('city__c')? String.valueOf(receivedData.get('city__c')): '';
            newLead.State = receivedData.containsKey('state__c')? String.valueOf(receivedData.get('state__c')): '';
            newLead.Country = receivedData.containsKey('country__c')? String.valueOf(receivedData.get('country__c')): '';
            newLead.PostalCode = receivedData.containsKey('postalCode')? String.valueOf(receivedData.get('postalCode')): '';
            newLead.Email_2__c = receivedData.containsKey('secondaryEmail__c')? String.valueOf(receivedData.get('secondaryEmail__c')): '';
            newLead.Referral_Notes__c = receivedData.containsKey('Referral_Notes__c')? String.valueOf(receivedData.get('Referral_Notes__c')): '';
            newLead.Referral_Agent__c = receivedData.containsKey('referral_Agent__c')? String.valueOf(receivedData.get('referral_Agent__c')): '';
            newLead.SMTN_Owner_Id__c = receivedData.containsKey('smtn_OwnerId__c')? String.valueOf(receivedData.get('smtn_OwnerId__c')): '';
            newLead.SMTNLeadtracker__c = receivedData.containsKey('smtn_OwnerId__c')? 'https://www.smtnleadtracker.com/Detail/LeadInfo.aspx?OwnerId='+String.valueOf(receivedData.get('smtn_OwnerId__c')): '';
            system.debug('Main class newLead response ---> ' + newLead);
            // Insert Duplicate Test Point
            Lead oldLead = CheckDuplicateLead(newLead, incommingId);
            if (oldLead == null){
                insert newLead;
                system.debug('>>>>>CheckDuplicateLead newLead>>>'+newLead);
                system.debug('>>>>>CheckDuplicateLead newLead.Id>>>'+newLead.Id);
                String resultcheck = ConvertLead(newLead); 
                if(resultcheck != null && resultcheck!= ''){
                    response.status = ERROR;
                    response.errorMessage = 'Agent not found : '+String.valueOf(receivedData.get('referral_Agent__c'))+' - Please contact your manager.';
                }
            } 
            else if( (oldLead != null)) {
                system.debug('>>>>Existing Lead>>>>>>>'+oldLead);
                Account oldAcc = CheckDuplicateAccount(newLead);
                if (oldAcc == null){
                    insert newLead;
                    String resultcheck =  ConvertLead(newLead);
                    if(resultcheck != null && resultcheck!= ''){
                        response.status = ERROR;
                        response.errorMessage = 'Agent not found : '+String.valueOf(receivedData.get('referral_Agent__c'))+' - Please contact your manager.';
                    }
                } else {
                    List<Opportunity> oldOpps = CheckDuplicateOpportunity(oldAcc.Id);
                    if (oldOpps.size() > 0){
                        for(Opportunity item : oldOpps){
                            item.StageName = 'Pitched - Did Not Close/Lost';
                        }
                        update oldOpps; 
                    } 
                    //Id userId;
                    List<user> userList;
                    
                    if(receivedData.containsKey('referral_Agent__c')){
                        String referralAgent = String.valueOf(receivedData.get('referral_Agent__c'));
                        userList = [select Id from User where CommunityNickname =: referralAgent  or Alias =: referralAgent or Id =: referralAgent Limit 1];
                        //userId =  [select Id from User where CommunityNickname =: referralAgent  or Alias =: referralAgent or Id =: referralAgent].Id;
                        system.debug('--userList-'+userList);
                        if(userList.size()>0 && userList != null){
                            Opportunity newOpp = new Opportunity();
                            newOpp.CloseDate = date.today().addMonths(2);
                            newOpp.First_Agent__c = newLead.First_Agent__c;
                            newOpp.Closing_Agent__c = newLead.First_Agent__c;
                            newOpp.OwnerId = newLead.First_Agent__c;
                            newOpp.Accountid = oldAcc.Id;
                            //newOpp.Referral_Notes__c = newLead.Referral_Notes__c;
                            newOpp.Referral_Agent__c = userList[0].Id != null? userList[0].Id: '';
                            newOpp.Tee_Up_Agent__c = userList[0].Id != null? userList[0].Id: '';
                            newOpp.Tee_Up_Date__c = system.now();
                            newOpp.Name = oldAcc.Name;
                            newOpp.StageName = 'Appointment Booked';
                            newOpp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Membership_Upgrade').getRecordTypeId();
                            Insert newOpp; 
                        }else{
                            response.status = ERROR;
                            response.errorMessage = 'Agent not found : '+referralAgent+' - Please contact your manager.';
                        }
                    }                                        
                }
            }
            response.createdLeadId = newLead.Id; 
        }
        catch(Exception ex){
            System.debug('Exception occurrred on LineNumber:' + ex.getLineNumber() + ', Message:' + ex.getMessage());
            response.status = ERROR;
            response.errorMessage = 'Message:' + ex.getMessage()  + ' - Exception occurrred on LineNumber: ' + ex.getLineNumber();
        }
        return response;
    }
    public static Lead ValidateLead(Lead newLead){
        List<String> invalidEmails = new list<String> {'email', 'refused', 'n/a', 'john@robertsonlawassociates.com', 'c', 'no', 'jrjmweldon@q.com', 'Janwalton@q.com', 'outside', 'fake@fake.com'};
            List<String> partialEmails = new list<String> {'test.com', 'sellmytimesharenow', 'email address', 'timeshareresalemarket.com', 'noemail'};    
                List<String> invalidPhones = new list<String> {'999-999-9999', '9999999999', '(', '0', 'wrong number', 'DNC', 'non owner', 'DO NOT CALL', 'SOLD', 'no number', 'CALIFORNIA'};
                    if (string.isNotBlank(newLead.Email) && invalidEmails.contains(newLead.Email.toLowerCase()) ){
                        newLead.Email = '';
                    } else {
                        boolean found = false;
                        for(string t :  partialEmails ){
                            if (newLead.Email.containsIgnoreCase(t) ){
                                newLead.Email = '';
                            }
                        }    
                    }
        if (string.isNotBlank(newLead.Phone) && invalidPhones.contains(newLead.Phone)){
            newLead.Phone = '';
        }
        if (string.isNotBlank(newLead.MobilePhone) && invalidPhones.contains(newLead.MobilePhone)){
            newLead.MobilePhone = '';
        }
        if (string.isNotBlank(newLead.Work_Phone__c) && invalidPhones.contains(newLead.Work_Phone__c)){
            newLead.Work_Phone__c = '';
        }
        if (string.isNotBlank(newLead.Fax) && invalidPhones.contains(newLead.Fax)){
            newLead.Fax = '';
        }
        if(	string.isBlank(newLead.Phone) && string.isBlank(newLead.MobilePhone) && string.isBlank(newLead.Work_Phone__c) && string.isBlank(newLead.Email)  ){
            throw new MyException('Lead can not be submited. Missing a valid email and phone number!');  
        }
        return newLead;  
    }
    public static string ConvertLead(Lead newLead){
        System.debug('>>>>newLead>>>>>'+newLead);
        System.debug('>>>>newLead Id>>>>>'+newLead.Id);
        //Id userId;
        List<user> userList;
        if(newLead.referral_Agent__c != null){
            String referralAgent = newLead.referral_Agent__c;
            userList = [select Id from User where CommunityNickname =: referralAgent  or Alias =: referralAgent or Id =: referralAgent Limit 1];
            //userId =  [select Id from User where CommunityNickname =: referralAgent or Alias =: referralAgent or Id =: referralAgent].Id;
        }
        if(userList.size()>0 && userList != null ){
            Database.LeadConvert lc = new database.LeadConvert();
            lc.setLeadId(newLead.Id);
            lc.setOwnerId(newLead.OwnerId);
            LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true and MasterLabel = 'Closed Won' LIMIT 1];
            lc.setConvertedStatus(convertStatus.MasterLabel);
            if (!test.isRunningTest()){
                Database.LeadConvertResult lcr = Database.convertLead(lc);
                Opportunity opp = new Opportunity();
                opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Membership_Upgrade').getRecordTypeId();
                opp.Id = lcr.getOpportunityId();
                opp.CloseDate = date.today().addMonths(2);
                opp.First_Agent__c = newLead.First_Agent__c;
                opp.Referral_Agent__c = userList[0].Id != null? userList[0].Id: '';
                opp.Closing_Agent__c = newLead.First_Agent__c;
                opp.Tee_Up_Agent__c = userList[0].Id != null? userList[0].Id: '';
                opp.Tee_Up_Date__c = system.now();
                update opp;
                System.assert(lcr.isSuccess());
            }
            return '';
        }else{
            return 'Agent not found : '+newLead.referral_Agent__c+' - Please contact your manager.';
        }
    }
    public static Lead CheckDuplicateLead(Lead newLead, string incommingId){
        Lead existingLead = new Lead();
        if(incommingId != null && incommingId != ''){
            existingLead = [select id, isConverted, FirstName, LastName, Email, Phone, MobilePhone, Marriage_Status__c, Name_of_Deceased__c, Work_Phone__c, Fax, Referral_Agent__c, First_Agent__c, OwnerId, Vendor__c, Source__c, LeadSource, Street, City, State, Country, PostalCode, Email_2__c, Referral_Notes__c, createdDate  from lead where id=:incommingId];
        } 
        else {
            List<string> temP = GetDupeKeys(newLead);
            List<Lead> results = new List<Lead>();
            if (newLead.Email == ''){
                results = [select id, isConverted, FirstName, LastName, Email, Phone, MobilePhone, Marriage_Status__c, Name_of_Deceased__c, Work_Phone__c, Fax, Referral_Agent__c, First_Agent__c, OwnerId, Vendor__c, Source__c, LeadSource, Street, City, State, Country, PostalCode, Email_2__c, Referral_Notes__c, createdDate  from lead where Phone IN :temP OR MobilePhone IN :temP OR Work_Phone__c IN :temP or Fax IN :temP ORDER BY CreatedDate desc];
            } else {
                results = [select id, isConverted, FirstName, LastName, Email, Phone, MobilePhone, Marriage_Status__c, Name_of_Deceased__c, Work_Phone__c, Fax, Referral_Agent__c, First_Agent__c, OwnerId, Vendor__c, Source__c, LeadSource, Street, City, State, Country, PostalCode, Email_2__c, Referral_Notes__c, createdDate  from lead where Email=:newLead.Email OR Phone IN :temP OR MobilePhone IN :temP OR Work_Phone__c IN :temP or Fax IN :temP ORDER BY CreatedDate desc];
            }
            if (results.size() > 0){
                existingLead = results[0];
            } else {
                existingLead = null;
            }
        }         
        return existingLead;
    } 
    public static Account CheckDuplicateAccount(Lead newLead){
        Account existingAccount = new Account();
        List<string> temP = GetDupeKeys(newLead);
        List<Account> results = new List<Account>();
        
        if(newLead.Email == ''){
            results = [Select id, Name from Account where Phone IN :temP OR Alternate_Phone__c IN :temP OR Alternate_Phone_1__c IN :temP or Alternate_Phone_2__c IN :temP or Alternate_Phone_3__c IN : temP or Mobile__c IN : temP or Fax IN :temP ORDER BY CreatedDate desc];
        } else {
            results = [Select id, Name from Account where Email__c=:newLead.Email or Email_2__c =:newLead.Email OR Phone IN :temP OR Alternate_Phone__c IN :temP OR Alternate_Phone_1__c IN :temP or Alternate_Phone_2__c IN :temP or Alternate_Phone_3__c IN : temP or Mobile__c IN : temP or Fax IN :temP ORDER BY CreatedDate desc];
        }
        if (results.size() > 0){
            existingAccount = results[0];
        } else {
            existingAccount = null;
        }
        return existingAccount;
    }
    public static List<Opportunity> CheckDuplicateOpportunity(string accountId){
        List<Opportunity> oppExistingList = [Select Id, StageName, First_Payment_Made__c FROM Opportunity WHERE AccountId =: accountId AND isclosed = false AND First_Payment_Made__c = false];
        return oppExistingList;
    }
    public static List<string> GetDupeKeys (Lead newLead) {
        List<string> temP = new List<string>();
        if(newLead.Phone != null && newLead.Phone != '') temP.add(newLead.Phone);
        if(newLead.MobilePhone != null && newLead.MobilePhone != '') temP.add(newLead.MobilePhone);
        if(newLead.Work_Phone__c != null && newLead.Work_Phone__c != '') temP.add(newLead.Work_Phone__c);
        if(newLead.Fax != null && newLead.Fax != '') temP.add(newLead.Fax);
        return temP;
    }
    global class ResponseWrapper{
        webservice String status;
        webservice String errorMessage;
        webservice String createdLeadId;
    }
    public class MyException extends Exception {}
}