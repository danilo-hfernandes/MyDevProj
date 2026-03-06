public class EnrollmentQueueHelper {
    
    public static Boolean OpportunityInserted = True;
    
    public static void updatePhone(List<HSI_Enrollment_Queue__c> enrollmentQueueList){
        for(HSI_Enrollment_Queue__c rec: enrollmentQueueList){
            if(rec.Primary_Phone__c != null && rec.Primary_Phone__c != ''){
                String phoneString = rec.Primary_Phone__c.replaceAll('\\D','');
                if(phoneString.length()>10){
                    rec.Primary_Phone__c = phoneString.removeStart('1');
                }else{
                    rec.Primary_Phone__c = phoneString;
                }
                
            }
        }
    }
    
    @future
    public static void UpdateEnrollmentRecord(set<id> newrec){
        EnrollmentQueueWrapper wrapClass = new EnrollmentQueueWrapper();
        List<Account> accountRecords = new List<Account>();
        list<HSI_Enrollment_Queue__c> allRecords = New list<HSI_Enrollment_Queue__c>();//added Victor
        list<HSI_Enrollment_Queue__c> newRecords = New list<HSI_Enrollment_Queue__c>();
        list<HSI_Enrollment_Queue__c> newSelfEnrollmentRecords = New list<HSI_Enrollment_Queue__c>();//added Victor
        set<String> phone = new set<String>();
        set<String> email = New set<String>();
        Account accountInserted = New Account();
        List<Account> accountList = New List<Account>();
        List<Account> accountListToCreateContacts = New List<Account>(); //added Victor
        list<Id> enrolid = New List<Id>();
        Map<Id,HSI_Enrollment_Queue__c> AccountIdtoEnrollmentMap = New Map<Id,HSI_Enrollment_Queue__c>();
        
        /* for(HSI_Enrollment_Queue__c hsienrol : newrec){
		enrolid.add(hsienrol.id);
		}*/
        
        allRecords = [Select Id,Primary_Phone__c,Email__c,Member_Number__c,AccountId__c,Processed_On__c,Successful_Processed__c,Error_Message__c,
                      Record_Origin__c,Auto_Id__c,Notify_Admin__c,First_Name__c,Last_Name__c,Address__c,City__c,Country__c,
                      State__c,Zip_Code__c,Alternate_Phone__c,Destination__c,Departure_Date__c,Arrival_Date__c, Paid_Amount__c, Transaction_Id__c, 
                      Authorization_Code__c, Referred_By__c, Property__c,CC_Holder_Name__c,AuthorizeNet_Transaction_Id__c, Resort_Address__c,Resort_City__c,
                      Resort_Country__c,Occupancy__c,Billing_Card_Type__c,Billing_Card_Last_4_Digits__c,RoomType__c,Preferred_Language__c
                      from 
                      HSI_Enrollment_Queue__c where Id IN : newrec AND (Record_Origin__c = 'VI MEX Referral' OR Record_Origin__c = 'RR Flex Date' OR Record_Origin__c = 'HC Self Enrollment')];//modified by DS //modified by Victor added HC Self Enrollment
        
        for(HSI_Enrollment_Queue__c enrol : allRecords){            
            if(enrol.Record_Origin__c == 'VI MEX Referral' || enrol.Record_Origin__c == 'RR Flex Date'){//modified by DS
                newRecords.add(enrol);
                if(enrol.Primary_Phone__c != null){
                    phone.add(enrol.Primary_Phone__c);
                }
                if(enrol.Email__c != null){
                    email.add(enrol.Email__c);
                }                
            }
            else if(enrol.Record_Origin__c == 'HC Self Enrollment')//added Victor
            {
                newSelfEnrollmentRecords.add(enrol);
            }
            
        }
        system.debug('emil== ' + email + ' phone== ' + phone);
        if(phone.size() > 0 && email.size() > 0){
            accountRecords = [Select id,Member_Number__c,Email__c,Phone,Affiliate_Name__c,Name from Account where Email__c IN:email OR Phone IN: phone order by createddate desc limit 1];
        }else if(email.size() > 0){
            accountRecords = [Select id,Member_Number__c,Email__c,Phone,Affiliate_Name__c,Name from Account where Email__c != NULL AND Email__c IN:email order by createddate desc limit 1];
        }else if(phone.size() > 0){
            accountRecords = [Select id,Member_Number__c,Email__c,Phone,Affiliate_Name__c,Name from Account where Phone IN: phone order by createddate desc limit 1];
        }
        system.debug('rec==' + accountRecords);
        
        for(HSI_Enrollment_Queue__c updateenrol : newRecords){
            Boolean accfound = False;
            if(accountRecords.size() > 0 && accountRecords != Null){
                for(Account account: accountRecords){
                    if(((account.Email__c == updateenrol.Email__c) || (account.Phone == updateenrol.Primary_Phone__c))){
                        accfound = true;
                    }
                }
            }
            system.debug('accound' + accfound);
            if(!accfound){
                if(updateenrol.Record_Origin__c == 'VI MEX Referral'){
                    updateenrol.Member_Number__c = 'AP-VIR-' + updateenrol.Auto_Id__c;
                }else if(updateenrol.Record_Origin__c == 'RR Flex Date'){
                    updateenrol.Member_Number__c = 'AP-RRC-' + updateenrol.Auto_Id__c;
                }
                
                accountInserted = insertAccount(updateenrol);
                system.debug('accid== ' + accountInserted);
                updateenrol.AccountId__c = accountInserted.id;
                accountList.add(accountInserted);
                AccountIdtoEnrollmentMap.put(accountInserted.id,updateenrol);
            }
        }
        
        //Added Victor
        //Boolean updateSelfEnrols = false;
        List<HSI_Enrollment_Queue__c> updateHSIEnrollmentList = new List<HSI_Enrollment_Queue__c>();
        
        for(HSI_Enrollment_Queue__c selfEnrol : newSelfEnrollmentRecords){
            if(selfEnrol.Record_Origin__c == 'HC Self Enrollment'){
                selfEnrol.Member_Number__c = 'AP-HIC-' + selfEnrol.Auto_Id__c;
                accountInserted = insertAccount(selfEnrol);
                system.debug('accid== ' + accountInserted);
                selfEnrol.AccountId__c = accountInserted.id;
                accountListToCreateContacts.add(accountInserted);
                updateHSIEnrollmentList.add(selfEnrol);
                //updateSelfEnrols = true;
            }
        }
        
        if(accountListToCreateContacts.size() > 0 && accountListToCreateContacts != null){
            List<Contact> contacts = new List<Contact>();
            for(Account acc : accountListToCreateContacts){
                Contact con = new Contact();
                con.FirstName = acc.First_Name__c;
                con.LastName = acc.Last_Name__c;
                con.Email = acc.Email__c;
                con.Phone = acc.Phone;
                con.MailingCity = acc.BillingCity;
                con.Alternate_Phone__c = acc.Alternate_Phone__c;
                con.Member_Number__c = acc.Member_Number__c;
                con.MailingStreet = acc.BillingStreet;
                con.MailingCountry = acc.BillingCountry;
                con.MailingState = acc.BillingState;
                con.MailingPostalCode = acc.BillingPostalCode;
                con.AccountId = acc.Id;
                contacts.add(con);
            }
            if(contacts.size()>0 && contacts != null)
            {
                insert contacts;
            }
        }
        
        if(updateHSIEnrollmentList != null && updateHSIEnrollmentList.size() > 0){
            update newSelfEnrollmentRecords;
        }
        
        if(accountList.size() > 0 && accountList != null){
            
            wrapClass = insertOpportunity(accountList,AccountIdtoEnrollmentMap);
            List<Opportunity> insertedopplist = wrapClass.oppListWrap;
            if(insertedopplist.size() > 0 && insertedopplist != null && !insertedopplist.isEmpty()){
                insertOpportunityLineItem(insertedopplist);
                insertPayments(insertedopplist,AccountIdtoEnrollmentMap);
            }
        }
        
        
        
        set<Id> oppInsert = New set<Id>();
        LIst<Account> accounts = new List<Account>();
        if(accountRecords.size() > 0 && accountRecords != Null){
            
            for(Account account: accountRecords){
                for(HSI_Enrollment_Queue__c updateenrol : newRecords){
                    
                    if((account.Email__c == updateenrol.Email__c) || (account.Phone == updateenrol.Primary_Phone__c)){
                        if(account.Affiliate_Name__c == 'Vacation Innovations Referral'){
                            updateenrol.Processed_On__c = Date.today();
                            updateenrol.Member_Number__c = account.Member_Number__c;
                            updateenrol.Successful_Processed__c = False;
                            updateenrol.Error_Message__c = 'Invalid duplicate found';
                            updateenrol.Notify_Admin__c = true;
                        }else{
                            updateenrol.Processed_On__c = Date.today();
                            updateenrol.Member_Number__c = account.Member_Number__c;
                            updateenrol.Successful_Processed__c = True;
                            updateenrol.Error_Message__c = '';
                            oppInsert.add(account.Id);
                            accounts.add(account);
                            AccountIdtoEnrollmentMap.put(account.id,updateenrol);
                        }
                    }
                }
            }
            
        }

        wrapClass = insertOpportunity(accounts,AccountIdtoEnrollmentMap); 
        List<Opportunity> insertedopp = wrapClass.oppListWrap;
        Map<Id,HSI_Enrollment_Queue__c> enrollmentQueueWrap = wrapClass.enrollmentQueueWrap;
        
        for(HSI_Enrollment_Queue__c updateenrol : newRecords){
            if(enrollmentQueueWrap != null && enrollmentQueueWrap.containsKey(updateenrol.Id)){
                updateenrol.Failure_Count__c = 4;
                updateenrol.Processed_On__c = Date.today();
                updateenrol.Successful_Processed__c = false;
                updateenrol.Error_Message__c = 'VI Referral already found for this account';
            }
        }
        
        if(insertedopp != null && insertedopp.size() > 0){
            insertOpportunityLineItem(insertedopp);
            insertPayments(insertedopp,AccountIdtoEnrollmentMap);
        }
        update newRecords;
    }
    public static EnrollmentQueueWrapper insertOpportunity(List<Account> accounts,Map<Id,HSI_Enrollment_Queue__c> accenrol){

        EnrollmentQueueWrapper wrap = new EnrollmentQueueWrapper();
        List<Opportunity> oppinsertlist = new List<Opportunity>();
        Set<Id> accIdSet = new Set<Id>();
        Map<Id,Id> accIdWithOppId = new Map<Id,Id>();
        Map<Id,HSI_Enrollment_Queue__c> enrollmentQueueMap = new Map<Id,HSI_Enrollment_Queue__c>();
        Id viReferralRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('VI_Referral_Date_Request').getRecordTypeId();
        
        for(Account acc : accounts){
            if(accenrol.get(acc.Id).Record_Origin__c == 'VI MEX Referral'){
                accIdSet.add(acc.id);
            }
        }
        
        List<Opportunity> lstOpportunity = [SELECT Id, AccountId  FROM Opportunity WHERE AccountId IN: accIdSet and Recordtypeid =: viReferralRecordTypeId];
        
        for(Opportunity opp: lstOpportunity){
            accIdWithOppId.put(opp.AccountId, opp.Id);
        }
        
        for(Account acc : accounts){
            if(!accIdWithOppId.containsKey(acc.Id)){
                String devRecordTypeId = '';//modified by DS
                if(accenrol.get(acc.Id).Record_Origin__c == 'VI MEX Referral'){
                    devRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('VI Referral Date Request').getRecordTypeId();
                }else if(accenrol.get(acc.Id).Record_Origin__c == 'RR Flex Date'){
                    devRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('RR Flex Date').getRecordTypeId();
                }
                
                Opportunity oppinsertrec = New Opportunity();
                if(accenrol.get(acc.Id).Record_Origin__c == 'VI MEX Referral'){
                    oppinsertrec.Name = 'VI Referral - ' + acc.Name;
                }else if(accenrol.get(acc.Id).Record_Origin__c == 'RR Flex Date'){
                    oppinsertrec.Name = 'RR Flex - ' + acc.Name;
                }
                
                oppinsertrec.RecordTypeId = devRecordTypeId;
                oppinsertrec.StageName = 'New';
                oppinsertrec.CloseDate = Date.today() + 60;
                oppinsertrec.AccountId = acc.Id;
                //Below 3 line are commented for ticket B-06777 on 23/7
                //oppinsertrec.Destination__c = accenrol.get(acc.Id).Destination__c;
                //oppinsertrec.Check_in__c = accenrol.get(acc.Id).Arrival_Date__c;
                //oppinsertrec.Check_Out__c = accenrol.get(acc.Id).Departure_Date__c;
                oppinsertrec.Referred_By__c = accenrol.get(acc.Id).Referred_By__c;
                oppinsertrec.Resort_Address__c = accenrol.get(acc.Id).Resort_Address__c;
                oppinsertrec.Resort_City__c = accenrol.get(acc.Id).Resort_City__c;
                oppinsertrec.Resort_Country__c = accenrol.get(acc.Id).Resort_Country__c;
                oppinsertrec.Occupancy__c = accenrol.get(acc.Id).Occupancy__c;
                oppinsertrec.Billing_Card_Type__c = accenrol.get(acc.Id).Billing_Card_Type__c;
                oppinsertrec.Billing_Card_Last_4_Digits__c = accenrol.get(acc.Id).Billing_Card_Last_4_Digits__c;
                oppinsertrec.Transaction_Id__c = accenrol.get(acc.Id).Transaction_Id__c;
                oppinsertrec.Room_Type__c = accenrol.get(acc.Id).RoomType__c;
                
                if(accenrol.get(acc.Id).Record_Origin__c == 'RR Flex Date'){
                    oppinsertrec.Paid_Amount__c = accenrol.get(acc.Id).Paid_Amount__c;
                    oppinsertrec.Transaction_Id__c = accenrol.get(acc.Id).Transaction_Id__c;
                    oppinsertrec.Authorization_Code__c = accenrol.get(acc.Id).Authorization_Code__c;
                    oppinsertrec.Property__c = accenrol.get(acc.Id).Property__c;
                    oppinsertrec.VI_Referral_Comments__c = 'Property: ' + accenrol.get(acc.Id).Property__c + '\n' + 'Destination: ' + accenrol.get(acc.Id).Destination__c + '\n' + 'Arrival Date: ' + String.valueOf(accenrol.get(acc.Id).Arrival_Date__c) + '\n' + 'Departure Date: ' + String.valueOf(accenrol.get(acc.Id).Departure_Date__c);
                }
                
                oppinsertlist.add(oppinsertrec);
            }else{
                HSI_Enrollment_Queue__c enrollmentQueueRecord = accenrol.get(acc.Id);
                enrollmentQueueMap.put(enrollmentQueueRecord.Id,enrollmentQueueRecord);
                /*HSI_Enrollment_Queue__c enrollmentQueueRecord = accenrol.get(acc.Id);
                enrollmentQueueRecord.Failure_Count__c = 4;
                enrollmentQueueRecord.Processed_On__c = Date.today();
                enrollmentQueueRecord.Successful_Processed__c = false;
                enrollmentQueueRecord.Error_Message__c = 'VI Referral already found for this account';
                enrollmentQueueList.add(enrollmentQueueRecord);*/
            }
        }
        try{
            if(oppinsertlist.size()>0 && oppinsertlist != null)
            {
                Insert oppinsertlist;
                system.debug('--oppinsertlist--'+oppinsertlist);
                wrap.oppListWrap = oppinsertlist;
            }
            if(enrollmentQueueMap != null){
                wrap.enrollmentQueueWrap = enrollmentQueueMap;
            }
        }catch(Exception e){
            system.debug('exception ' + e);
            OpportunityInserted = false;
			wrap.oppListWrap = new List<Opportunity>();
            wrap.enrollmentQueueWrap = new Map<Id,HSI_Enrollment_Queue__c>();
        }
        return wrap;
    }
    public static void insertOpportunityLineItem(List<Opportunity> oppinsertlist){
        List<OpportunityLineItem> oppLineItemInsert = new List<OpportunityLineItem>();
        for(Opportunity opp : oppinsertlist){
            String recTypeName = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosById().get(opp.RecordTypeId).getName();
            OpportunityLineItem oppline = new OpportunityLineItem();
            oppline.OpportunityId = opp.id;
            if(recTypeName == 'VI Referral Date Request'){
                oppline.Product2Id = Label.HSIEnrollProductId;
                oppline.PricebookEntryId = Label.HSIEnrollPriceBookEntryId;
                oppline.Retail_Price__c = Decimal.valueOf(Label.VidaVoucherFlexDateRequestProductPrice);
            }else if(recTypeName == 'RR Flex Date'){
                oppline.Product2Id = Label.ResortRentalsFlexDatesProductId;
                oppline.PricebookEntryId = Label.ResortRentalsFlexDatesPriceBookId;
                oppline.Retail_Price__c = opp.Paid_Amount__c;
            }
            
            
            
            oppLineItemInsert.add(oppline);
        }
        if(oppLineItemInsert.size() > 0 && oppLineItemInsert != null){
            try{
                insert oppLineItemInsert;
                system.debug('---oppLineItemInsert'+oppLineItemInsert);
            }catch(Exception e){
                system.debug('exception ' + e);
            }
        }
    }
    public static void insertPayments(List<Opportunity> oppinsertlist,Map<Id,HSI_Enrollment_Queue__c> accenrol){
        List<Payment__c> paymentInsert = New List<Payment__c>();
        Id paymentRecordTypeId = Schema.SObjectType.Payment__c.getRecordTypeInfosByDeveloperName().get('Resort_Rentals_Flex_Dates').getRecordTypeId();
        for(Opportunity opp : oppinsertlist){
            String recTypeName = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosById().get(opp.RecordTypeId).getName();
            Payment__c pay = new Payment__c();
            pay.Opportunity__c = opp.id;
            pay.Name = opp.Name;
            pay.CC_Holder_Name__c = accenrol.get(Opp.AccountId).CC_Holder_Name__c;
            pay.Payment_Amount__c = 0;
            system.debug('--accenrol.get(Opp.AccountId).AuthorizeNet_Transaction_Id__c--'+accenrol.get(Opp.AccountId).AuthorizeNet_Transaction_Id__c);
            pay.RecordTypeId = '0123t000000GB7tAAG';
            if(recTypeName == 'RR Flex Date'){
                pay.Payment_Amount__c = opp.Paid_Amount__c;
                pay.AuthorizeNet_Transaction_Id__c = accenrol.get(Opp.AccountId).AuthorizeNet_Transaction_Id__c;
                pay.Payment_Id__c = opp.Transaction_Id__c;
                pay.Authorization_Code__c = opp.Authorization_Code__c;
                pay.Payment_Date__c = system.today();
                pay.RecordTypeId = paymentRecordTypeId;
                pay.Transaction_Type__c = 'Resort Rentals Flex Dates';
                pay.Payment_Type__c = 'Payment';
                pay.Payment_Method__c = 'CreditCardOnline';
            }
            paymentInsert.add(pay);
        }
        if(paymentInsert.size() > 0 && paymentInsert != null){
            try{
                insert paymentInsert;
                system.debug('---paymentInsert'+paymentInsert);
            }catch(Exception e){
                system.debug('exception ' + e);
            }
        }
    }
    public static Account insertAccount(HSI_Enrollment_Queue__c hsirecord){
        Account acc = new Account();
        acc.Name = hsirecord.First_Name__c + ' ' + hsirecord.Last_Name__c;
        acc.Email__c = hsirecord.Email__c;
        acc.Phone = hsirecord.Primary_Phone__c;
        acc.BillingCity = hsirecord.City__c;
        acc.BillingStreet = hsirecord.Address__c;
        acc.BillingCountry = hsirecord.Country__c;
        acc.BillingState = hsirecord.State__c;
        acc.BillingPostalCode = hsirecord.Zip_Code__c;
        acc.Alternate_Phone__c = hsirecord.Alternate_Phone__c;
        acc.Member_Number__c = hsirecord.Member_Number__c;
        acc.First_Name__c = hsirecord.First_Name__c;
        acc.Last_Name__c = hsirecord.Last_Name__c;
        acc.Preferred_Language__c = hsirecord.Preferred_Language__c;
        //Added Victor
        if(hsirecord.Record_Origin__c == 'HC Self Enrollment')
        {            
            acc.Membership_Status__c = 'Active';
            acc.Affiliate_Name__c = 'Hawaii Collection';
            acc.Affiliated_Id__c = 1002243;
            acc.Enrollment_Fee__c = 0.00;
            acc.Membership_Annual_Due__c = 299;
            acc.Program_Website__c = 'https://members.hawaiicollection.com';
            acc.Host_Domain__c = 'members.hawaiicollection.com';
        }
        insert acc;
        return acc;
    }
    
    public class EnrollmentQueueWrapper {
        public List<Opportunity> oppListWrap {get; set;}
        public Map<Id,HSI_Enrollment_Queue__c> enrollmentQueueWrap {get; set;}
    }
}