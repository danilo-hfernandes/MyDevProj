public class GetDuplicatedAccountListController {
    //used in the lead record page    
    @AuraEnabled
    public static Map<String,List<Account>> GetAccount(String leadId)
    {
        List<Account> lstAccount = new List<Account>();
        List<Lead_Source_Settings__c> ldSourceSettings = new List<Lead_Source_Settings__c>();
        Map<String,List<Account>> returnMap = new Map<String,List<Account>>();
        String ldSourceIssue = '';
        if(leadId != null && leadId != ''){            
            Lead ld = [SELECT Id,Email,Phone,Match_Affiliate_Id__c,LeadSource FROM Lead WHERE Id =: leadId];
            if(ld.LeadSource != null)
            {                
                ldSourceSettings = [SELECT Id,Lead_Source__c,Affiliate_Id__r.Affiliate_Id__c FROM Lead_Source_Settings__c WHERE Affiliate_Id__c != NULL AND Lead_Source__c =: ld.LeadSource];
                if(ldSourceSettings == null || ldSourceSettings.size() == 0)
                {
                    ldSourceIssue = 'error';
                }
            }
            /*if((ld.Email != null || ld.Phone != null) && ld.Match_Affiliate_Id__c != null){
			System.debug('ld : '+ld);
			lstAccount=[Select Id,Name,BillingState,BillingCity,Phone,Email__c,Industry,Affiliate_Name__c,Affiliated_Id__c,Owner.Name,Type FROM Account WHERE (Phone =: ld.Phone OR Email__c =: ld.Email) AND (Phone != NULL OR Email__c != NULL) AND Affiliated_Id__c =: ld.Match_Affiliate_Id__c];
			}*/
        }
        returnMap.put(ldSourceIssue,lstAccount);
        return returnMap;
    }
    //used in the account record page
    @AuraEnabled
    public static Map<String,List<Account>> GetAccounts(String accountId)
    {
        //System.debug('IN > GetAccounts');
        //System.debug('accountId > '+accountId);
        List<Account> lstAccount = new List<Account>();        
        Map<String,List<Account>> returnMap = new Map<String,List<Account>>();
        String accSearchIssue = 'We found no potential duplicated accounts.';
        try{
            if(accountId != null && accountId != ''){
                Account acc = [SELECT Id,Name,Phone,Formatted_Phone__c,Email__c,Formatted_Alternate_Phone__c,Email_2__c,Affiliate_Name__c,Affiliated_Id__c,Owner.Name FROM Account WHERE Id =: accountId];
                
                if(acc.Email__c != null || acc.Formatted_Phone__c != null || acc.Formatted_Alternate_Phone__c != null || acc.Email_2__c != null){
                    
                    //System.debug('FIELDS ! = NULL checked ');
                    List<String> accEmails = new List<String>();
                    List<String> accPhones = new List<String>();
                    Blob b = Crypto.GenerateAESKey(128);
                    String h = EncodingUtil.ConvertTohex(b);
                    String tempEmail = h.SubString(0,8)+ '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20)+'@nerdsoft.com';
                    if(acc.Email__c != null && acc.Email__c != '')
                    {
                        tempEmail = '%'+acc.Email__c+'%';
                        accEmails.add(acc.Email__c);
                    }
                    if(acc.Email_2__c != null && acc.Email_2__c != '')
                    {
                        accEmails.add(acc.Email_2__c);
                    }
                    if(acc.Formatted_Phone__c != null && acc.Formatted_Phone__c != '' && acc.Formatted_Phone__c != 'NULL')
                    {
                        accPhones.add(acc.Formatted_Phone__c);
                    }
                    if(acc.Formatted_Alternate_Phone__c != null && acc.Formatted_Alternate_Phone__c != '' && acc.Formatted_Alternate_Phone__c != 'NULL')
                    {
                        accPhones.add(acc.Formatted_Alternate_Phone__c);
                    }
                    /*lstAccount= [Select Id,Name,BillingState,BillingCity,Phone,Email__c,Industry,Affiliate_Name__c,Affiliated_Id__c,Owner.Name,Type FROM Account WHERE Id !=: acc.Id AND
					((Formatted_Phone__c =: acc.Formatted_Phone__c AND Formatted_Phone__c != NULL) OR
					(Formatted_Phone__c =: acc.Formatted_Alternate_Phone__c AND Formatted_Phone__c != NULL) OR
					(Formatted_Alternate_Phone__c =: acc.Formatted_Phone__c AND Formatted_Phone__c != NULL) OR
					(Formatted_Alternate_Phone__c =: acc.Formatted_Alternate_Phone__c AND Formatted_Alternate_Phone__c != NULL) OR
					(Email__c =: acc.Email__c AND Email__c != NULL) OR
					(Email_2__c LIKE : tempEmail AND Email_2__c != NULL) OR
					(Email_2__c =: acc.Email_2__c AND Email_2__c != NULL)) ORDER BY CreatedDate DESC];*/
                    
                    lstAccount= [Select Id,Name,BillingState,BillingCity,Phone,Email__c,Industry,Affiliate_Name__c,Affiliated_Id__c,Owner.Name,Type FROM Account WHERE Id !=: acc.Id AND
                                 ((Formatted_Phone__c IN: accPhones AND Formatted_Phone__c != NULL AND Formatted_Phone__c != '') OR
                                  (Formatted_Alternate_Phone__c IN: accPhones AND Formatted_Alternate_Phone__c != NULL AND Formatted_Alternate_Phone__c != '') OR
                                  (Email__c IN: accEmails AND Email__c != NULL AND Email__c != '') OR
                                  (Email_2__c IN: accEmails AND Email_2__c != NULL AND Email_2__c != '') OR
                                  (Email_2__c LIKE : tempEmail AND Email_2__c != NULL AND Email_2__c != '')) ORDER BY CreatedDate DESC LIMIT 2000];
                    
                    //System.debug('lstAccount : '+lstAccount);
                }
            }
            //(1002243,1002311,1002312,1002310,1002240) - HC Affiliates
            //(1002277,1002276,1002319,1002320,1002275) - SFX Affiliates
            List<Decimal> HCandSFXAffiliates = new List<Decimal>{1002243,1002311,1002312,1002310,1002240,1002277,1002276,1002319,1002320,1002275};
                List<Account> lstAccountOrdered = new List<Account>();
            if(lstAccount != null && lstAccount.size()>0)
            {
                List<Account> lstAccountFirst = new List<Account>();
                List<Account> lstAccountLast = new List<Account>();
                for(Account acc1 : lstAccount)
                {
                    if(HCandSFXAffiliates.contains(acc1.Affiliated_Id__c))
                    {
                        lstAccountFirst.add(acc1);
                    }
                    else
                    {
                        lstAccountLast.add(acc1);
                    }
                }
                if(lstAccountFirst != null && lstAccountFirst.size()>0)
                {
                    lstAccountOrdered.addAll(lstAccountFirst);
                }
                if(lstAccountLast != null && lstAccountLast.size()>0)
                {
                    lstAccountOrdered.addAll(lstAccountLast);
                }
            }
        }
        Catch(Exception e)
        {
            accSearchIssue = e.getMessage();
        }
        returnMap.put(accSearchIssue,lstAccount);
        return returnMap;
    }
}