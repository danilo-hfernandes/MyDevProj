public class GenericDuplicatesCheckController {
    public static List<Decimal> HCAffiliates = new List<Decimal>{1002243,1002311,1002312,1002310};//HC Affilates
        public static List<Decimal> listOfAffiliate = new List<Decimal>{1002277, 1002447, 1002449,1002450};//Include the affiliates for which the HC Flag is applicable
            public static List<Decimal> CGEAffiliates = new List<Decimal>{1002447, 1002449,1002450, 1002458, 1002459};//CGE Affilates
                public static List<Decimal> ClubVentureAffiliates = new List<Decimal>{1002453, 1002454,1002456, 1002455};//Club Venture Affilates
                     public static List<Decimal> CFDAffiliates = new List<Decimal>{1002257, 1002266,1002256, 1002258};//CFD Affilates
//Is_CFD_Club_Venture__c
                //Work for single record
                public static boolean GetAccounts(Account acc, Boolean HCFlag){
                    List<Account> lstAccount = new List<Account>();        
                    Map<String,List<Account>> returnMap = new Map<String,List<Account>>(); 
                    if(listOfAffiliate.contains(acc.Affiliated_Id__c)){
                        if(acc.Email__c != null || acc.Formatted_Phone__c != null || acc.Formatted_Alternate_Phone__c != null || acc.Email_2__c != null){
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
                            if(HCFlag){
                                lstAccount= [Select Id,Name,BillingState,BillingCity,Phone,Email__c,Industry,Affiliate_Name__c,Affiliated_Id__c,Owner.Name,Type FROM Account WHERE Id !=: acc.Id AND
                                             ((Formatted_Phone__c IN: accPhones AND Formatted_Phone__c != NULL AND Formatted_Phone__c != '') OR
                                              (Formatted_Alternate_Phone__c IN: accPhones AND Formatted_Alternate_Phone__c != NULL AND Formatted_Alternate_Phone__c != '') OR
                                              (Email__c IN: accEmails AND Email__c != NULL AND Email__c != '') OR
                                              (Email_2__c IN: accEmails AND Email_2__c != NULL AND Email_2__c != '') OR
                                              (Email_2__c LIKE : tempEmail AND Email_2__c != NULL AND Email_2__c != '')) and Affiliated_Id__c IN :HCAffiliates ORDER BY CreatedDate DESC LIMIT 2000];
                            }
                            else{
                                lstAccount= [Select Id,Name,BillingState,BillingCity,Phone,Email__c,Industry,Affiliate_Name__c,Affiliated_Id__c,Owner.Name,Type FROM Account WHERE Id !=: acc.Id AND
                                             ((Formatted_Phone__c IN: accPhones AND Formatted_Phone__c != NULL AND Formatted_Phone__c != '') OR
                                              (Formatted_Alternate_Phone__c IN: accPhones AND Formatted_Alternate_Phone__c != NULL AND Formatted_Alternate_Phone__c != '') OR
                                              (Email__c IN: accEmails AND Email__c != NULL AND Email__c != '') OR
                                              (Email_2__c IN: accEmails AND Email_2__c != NULL AND Email_2__c != '') OR
                                              (Email_2__c LIKE : tempEmail AND Email_2__c != NULL AND Email_2__c != '')) ORDER BY CreatedDate DESC LIMIT 2000];
                                
                            }
                        }
                    }
                    if(lstAccount != null && lstAccount.size() > 0)
                        return false;//duplicates
                    else 
                        return true; //no duplicates
                }
    //Bulkifield Code for HC Duplicate Check
    public static void updateHCFlag(List<Account> accounts, Boolean hcFlag) {
        // Result map to store the boolean result for each account
        Map<Id, Boolean> result = new Map<Id, Boolean>();
        
        // Prepare email and phone sets for bulk query
        Set<String> accEmails = new Set<String>();
        Set<String> accPhones = new Set<String>();
         Set<String> setAccEmails = new Set<String>();
        Set<String> setAccPhones = new Set<String>();
        Set<String> accHCCGEEmails = new Set<String>();
        Set<String> accHCCGEPhones = new Set<String>();
        Set<String> accCFDCVEmails = new Set<String>();
        Set<String> accCFDCVPhones = new Set<String>();
        Map<Id, Account> accountMap = new Map<Id, Account>();
        List<Account> UpdateAccountList = new List<Account>();
        for (Account acc : accounts) {
            if(listOfAffiliate.contains(acc.Affiliated_Id__c) || HCAffiliates.contains(acc.Affiliated_Id__c)){
                accountMap.put(acc.Id, acc);
                if (acc.Email__c != null && acc.Email__c != '') {
                    setAccEmails.add(acc.Email__c);
                    accEmails.add(acc.Email__c);
                }
                if (acc.Email_2__c != null && acc.Email_2__c != '') {
                    setAccEmails.add(acc.Email_2__c);
                    accEmails.add(acc.Email_2__c);
                }
                if (acc.Formatted_Phone__c != null && acc.Formatted_Phone__c != '' && acc.Formatted_Phone__c != 'NULL') {
                    setAccPhones.add(acc.Formatted_Phone__c);
                    accPhones.add(acc.Formatted_Phone__c);
                }
                if (acc.Formatted_Alternate_Phone__c != null && acc.Formatted_Alternate_Phone__c != '' && acc.Formatted_Alternate_Phone__c != 'NULL') {
                    setAccPhones.add(acc.Formatted_Alternate_Phone__c);
                    accPhones.add(acc.Formatted_Alternate_Phone__c);
                }
            }
            if(CGEAffiliates.contains(acc.Affiliated_Id__c) || HCAffiliates.contains(acc.Affiliated_Id__c)){
                accountMap.put(acc.Id, acc);
                if (acc.Email__c != null && acc.Email__c != '') {
                    setAccEmails.add(acc.Email__c);
                    accHCCGEEmails.add(acc.Email__c);
                }
                if (acc.Email_2__c != null && acc.Email_2__c != '') {
                    setAccEmails.add(acc.Email_2__c);
                    accHCCGEEmails.add(acc.Email_2__c);
                }
                if (acc.Formatted_Phone__c != null && acc.Formatted_Phone__c != '' && acc.Formatted_Phone__c != 'NULL') {
                    setAccPhones.add(acc.Formatted_Phone__c);
                    accHCCGEPhones.add(acc.Formatted_Phone__c);
                }
                if (acc.Formatted_Alternate_Phone__c != null && acc.Formatted_Alternate_Phone__c != '' && acc.Formatted_Alternate_Phone__c != 'NULL') {
                    setAccPhones.add(acc.Formatted_Alternate_Phone__c);
                    accHCCGEPhones.add(acc.Formatted_Alternate_Phone__c);
                }
            }
            if(CFDAffiliates.contains(acc.Affiliated_Id__c) || ClubVentureAffiliates.contains(acc.Affiliated_Id__c)){
                accountMap.put(acc.Id, acc);
                if (acc.Email__c != null && acc.Email__c != '') {
                    setAccEmails.add(acc.Email__c);
                    accCFDCVEmails.add(acc.Email__c);
                }
                if (acc.Email_2__c != null && acc.Email_2__c != '') {
                    setAccEmails.add(acc.Email_2__c);
                    accCFDCVEmails.add(acc.Email_2__c);
                }
                if (acc.Formatted_Phone__c != null && acc.Formatted_Phone__c != '' && acc.Formatted_Phone__c != 'NULL') {
                    setAccPhones.add(acc.Formatted_Phone__c);
                    accCFDCVPhones.add(acc.Formatted_Phone__c);
                }
                if (acc.Formatted_Alternate_Phone__c != null && acc.Formatted_Alternate_Phone__c != '' && acc.Formatted_Alternate_Phone__c != 'NULL') {
                    setAccPhones.add(acc.Formatted_Alternate_Phone__c);
                    accCFDCVPhones.add(acc.Formatted_Alternate_Phone__c);
                }
            }
        }
        
        // Generate temporary email for matching
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertToHex(b);
        String tempEmail = h.substring(0, 8) + '-' + h.substring(8, 12) + '-' + h.substring(12, 16) + '-' + h.substring(16, 20) + '-' + h.substring(20) + '@nerdsoft.com';
        
        // Query accounts based on hcFlag
        List<Account> lstAccounts;
        if (hcFlag) {
            lstAccounts = [
                SELECT Id, Name, BillingState, BillingCity, Phone, Email__c, Industry, Affiliate_Name__c, Affiliated_Id__c, Owner.Name, Type, Formatted_Phone__c, Formatted_Alternate_Phone__c, Email_2__c
                FROM Account
                WHERE Id NOT IN :accountMap.keySet()
                AND (
                    (Formatted_Phone__c IN :setAccPhones AND Formatted_Phone__c != NULL AND Formatted_Phone__c != '') OR
                    (Formatted_Alternate_Phone__c IN :setAccPhones AND Formatted_Alternate_Phone__c != NULL AND Formatted_Alternate_Phone__c != '') OR
                    (Email__c IN :setAccEmails AND Email__c != NULL AND Email__c != '') OR
                    (Email_2__c IN :setAccEmails AND Email_2__c != NULL AND Email_2__c != '') OR
                    (Email_2__c LIKE :tempEmail AND Email_2__c != NULL AND Email_2__c != '')
                )
                AND (Affiliated_Id__c IN :HCAffiliates OR Affiliated_Id__c IN :listOfAffiliate OR Affiliated_Id__c IN : CGEAffiliates OR Affiliated_Id__c IN : ClubVentureAffiliates OR Affiliated_Id__c IN : CFDAffiliates)
                ORDER BY CreatedDate DESC
                LIMIT 2000
            ];
        } else {
            lstAccounts = [
                SELECT Id, Name, BillingState, BillingCity, Phone, Email__c, Industry, Affiliate_Name__c, Affiliated_Id__c, Owner.Name, Type, Formatted_Phone__c, Formatted_Alternate_Phone__c, Email_2__c
                FROM Account
                WHERE Id NOT IN :accountMap.keySet()
                AND (
                    (Formatted_Phone__c IN :accPhones AND Formatted_Phone__c != NULL AND Formatted_Phone__c != '') OR
                    (Formatted_Alternate_Phone__c IN :accPhones AND Formatted_Alternate_Phone__c != NULL AND Formatted_Alternate_Phone__c != '') OR
                    (Email__c IN :accEmails AND Email__c != NULL AND Email__c != '') OR
                    (Email_2__c IN :accEmails AND Email_2__c != NULL AND Email_2__c != '') OR
                    (Email_2__c LIKE :tempEmail AND Email_2__c != NULL AND Email_2__c != '')
                )
                ORDER BY CreatedDate DESC
                LIMIT 2000
            ];
        }
        System.debug('>>>>lstAccounts>>>>'+lstAccounts);
        // Group queried accounts by emails and phone numbers
        Map<String, Account> emailMap = new Map<String, Account>();
        Map<String, Account> phoneMap = new Map<String, Account>();
        Map<String, Account> emailHCCGEMap = new Map<String, Account>();
        Map<String, Account> phoneHCCGEMap = new Map<String, Account>();
        Map<String, Account> emailCFDCVMap = new Map<String, Account>();
        Map<String, Account> phoneCFDCVMap = new Map<String, Account>();
        for (Account queriedAccount : lstAccounts) {
            if(listOfAffiliate.contains(queriedAccount.Affiliated_Id__c) || CGEAffiliates.contains(queriedAccount.Affiliated_Id__c)){
                if (listOfAffiliate.contains(queriedAccount.Affiliated_Id__c) && ((queriedAccount.Email__c != null && accEmails.contains(queriedAccount.Email__c)) ||
                    (queriedAccount.Email_2__c != null && accEmails.contains(queriedAccount.Email_2__c)) ||
                    (queriedAccount.Formatted_Phone__c != null && accPhones.contains(queriedAccount.Formatted_Phone__c)) ||
                    (queriedAccount.Formatted_Alternate_Phone__c != null && accPhones.contains(queriedAccount.Formatted_Alternate_Phone__c)))) {
                        queriedAccount.HC_Flag__c = true;
                    }
                if(CGEAffiliates.contains(queriedAccount.Affiliated_Id__c)){
                    if ((queriedAccount.Email__c != null && accHCCGEEmails.contains(queriedAccount.Email__c)) ||
                        (queriedAccount.Email_2__c != null && accHCCGEEmails.contains(queriedAccount.Email_2__c)) ||
                        (queriedAccount.Formatted_Phone__c != null && accHCCGEPhones.contains(queriedAccount.Formatted_Phone__c)) ||
                        (queriedAccount.Formatted_Alternate_Phone__c != null && accHCCGEPhones.contains(queriedAccount.Formatted_Alternate_Phone__c))) {
                            queriedAccount.Is_HC_Club_Global_Member__c = true;
                            
                        }
                    if (queriedAccount.Email__c != null) {
                    	emailHCCGEMap.put(queriedAccount.Email__c, queriedAccount);
                    }
                    if (queriedAccount.Email_2__c != null) {
                        emailHCCGEMap.put(queriedAccount.Email_2__c, queriedAccount);
                    }
                    if (queriedAccount.Formatted_Phone__c != null) {
                        phoneHCCGEMap.put(queriedAccount.Formatted_Phone__c, queriedAccount);
                    }
                    if (queriedAccount.Formatted_Alternate_Phone__c != null) {
                        phoneHCCGEMap.put(queriedAccount.Formatted_Alternate_Phone__c, queriedAccount);
                    }
                }
                UpdateAccountList.add(queriedAccount); // Update Any Existing Record, If that matches on creation of any HC Affiliate account
                // }
            }
            if(HCAffiliates.contains(queriedAccount.Affiliated_Id__c)){
                if (queriedAccount.Email__c != null) {
                    emailMap.put(queriedAccount.Email__c, queriedAccount);
                }
                if (queriedAccount.Email_2__c != null) {
                    emailMap.put(queriedAccount.Email_2__c, queriedAccount);
                }
                if (queriedAccount.Formatted_Phone__c != null) {
                    phoneMap.put(queriedAccount.Formatted_Phone__c, queriedAccount);
                }
                if (queriedAccount.Formatted_Alternate_Phone__c != null) {
                    phoneMap.put(queriedAccount.Formatted_Alternate_Phone__c, queriedAccount);
                }
                if ((queriedAccount.Email__c != null && accHCCGEEmails.contains(queriedAccount.Email__c)) ||
                    (queriedAccount.Email_2__c != null && accHCCGEEmails.contains(queriedAccount.Email_2__c)) ||
                    (queriedAccount.Formatted_Phone__c != null && accHCCGEPhones.contains(queriedAccount.Formatted_Phone__c)) ||
                    (queriedAccount.Formatted_Alternate_Phone__c != null && accHCCGEPhones.contains(queriedAccount.Formatted_Alternate_Phone__c))) {
                        queriedAccount.Is_HC_Club_Global_Member__c = true;
                        UpdateAccountList.add(queriedAccount); // Update Any Existing Record, If that matches on creation of any HC Affiliate account
                    }
            }
            if(CFDAffiliates.contains(queriedAccount.Affiliated_Id__c) || ClubVentureAffiliates.contains(queriedAccount.Affiliated_Id__c)){
                if (queriedAccount.Email__c != null) {
                    emailCFDCVMap.put(queriedAccount.Email__c, queriedAccount);
                }
                if (queriedAccount.Email_2__c != null) {
                    emailCFDCVMap.put(queriedAccount.Email_2__c, queriedAccount);
                }
                if (queriedAccount.Formatted_Phone__c != null) {
                    phoneCFDCVMap.put(queriedAccount.Formatted_Phone__c, queriedAccount);
                }
                if (queriedAccount.Formatted_Alternate_Phone__c != null) {
                    phoneCFDCVMap.put(queriedAccount.Formatted_Alternate_Phone__c, queriedAccount);
                }
                if ((queriedAccount.Email__c != null && accCFDCVEmails.contains(queriedAccount.Email__c)) ||
                    (queriedAccount.Email_2__c != null && accCFDCVEmails.contains(queriedAccount.Email_2__c)) ||
                    (queriedAccount.Formatted_Phone__c != null && accCFDCVPhones.contains(queriedAccount.Formatted_Phone__c)) ||
                    (queriedAccount.Formatted_Alternate_Phone__c != null && accCFDCVPhones.contains(queriedAccount.Formatted_Alternate_Phone__c))) {
                        queriedAccount.Is_CFD_Club_Venture__c = true;
                        UpdateAccountList.add(queriedAccount); // Update Any Existing Record, If that matches on creation of any HC Affiliate account
                    }
            }
            
        }
        // Compare input accounts with queried accounts to determine the result
        for (Account acc : accounts) {
            if ((acc.Email__c != null && emailMap.containsKey(acc.Email__c)) ||
                (acc.Email_2__c != null && emailMap.containsKey(acc.Email_2__c)) ||
                (acc.Formatted_Phone__c != null && phoneMap.containsKey(acc.Formatted_Phone__c)) ||
                (acc.Formatted_Alternate_Phone__c != null && phoneMap.containsKey(acc.Formatted_Alternate_Phone__c))) {
                    if(listOfAffiliate.contains(acc.Affiliated_Id__c))
                        acc.HC_Flag__c = true;
                }
            if ((acc.Email__c != null && emailHCCGEMap.containsKey(acc.Email__c)) ||
                (acc.Email_2__c != null && emailHCCGEMap.containsKey(acc.Email_2__c)) ||
                (acc.Formatted_Phone__c != null && phoneHCCGEMap.containsKey(acc.Formatted_Phone__c)) ||
                (acc.Formatted_Alternate_Phone__c != null && phoneHCCGEMap.containsKey(acc.Formatted_Alternate_Phone__c))) {
                    if(HCAffiliates.contains(acc.Affiliated_Id__c) || CGEAffiliates.contains(acc.Affiliated_Id__c))
                        acc.Is_HC_Club_Global_Member__c = true;
                }
             if ((acc.Email__c != null && emailCFDCVMap.containsKey(acc.Email__c)) ||
                (acc.Email_2__c != null && emailCFDCVMap.containsKey(acc.Email_2__c)) ||
                (acc.Formatted_Phone__c != null && phoneCFDCVMap.containsKey(acc.Formatted_Phone__c)) ||
                (acc.Formatted_Alternate_Phone__c != null && phoneCFDCVMap.containsKey(acc.Formatted_Alternate_Phone__c))) {
                    if(CFDAffiliates.contains(acc.Affiliated_Id__c) || ClubVentureAffiliates.contains(acc.Affiliated_Id__c))
                        acc.Is_CFD_Club_Venture__c = true;
                }
        }
        if(UpdateAccountList != null && UpdateAccountList.size() > 0){
            update UpdateAccountList;
        }
    }  
}