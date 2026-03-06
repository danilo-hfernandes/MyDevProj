public class AnnualDuesSalesEngagementBatchDebug implements Database.Batchable<sObject>, Schedulable{
public void execute(SchedulableContext SC) {
        AnnualDuesSalesEngagementBatchDebug objBatch = new AnnualDuesSalesEngagementBatchDebug(); 
        database.executebatch(objBatch, 1);
    }

    public Database.QueryLocator start(Database.BatchableContext BC){
        Set<Integer> SMTNaffilateIDSet = new Set<Integer>{1002222,1002347,1002343,1002223,1002224,1002327};
            set<Integer> SFXAffilateIdSet = new set<Integer>{1002277,1002276,1002319,1002320};   
                set<Integer> HCAffilateIdSet = new set<Integer>{1002243,1002310,1002311,1002312};
                    set<Integer> CFDAffilateIdSet = new set<Integer>{1002266,1002256};
                    set<Integer> APHSIAffilateIdSet = new set<Integer>{1002222,1002347,1002343,1002223,1002224,1002327,1002243,1002311,1002312,1002310,1002257,1002277,1002276,1002319,1002320,1002336,1002274,1002241,1002409,1002275};
                        set<String> membershipstatus = new set<String>{'Active','FrozenByHSI'};
                            set<String> languagePrefered = new set<String>{'SPA'};
                                boolean CheckMFProtection = true; 
                                //set<String> setOfIds = new set<String>{'0013t00002NJ3HJAA1', '0013t00002KZZZ9AAP','0013t00002FgnZUAAZ','0013t00002PyC8TAAV','0013t00002Qmd63AAB','0013t00002NJ3HJAA1', '0013t00001bIfgpAAC','0013t00001bIfgoAAC', '0013t00002RDqNcAAL'};ID IN : setOfIds and
                                //2023-10-17 - HSIMU2-341 - Annual Dues SPA added - Preferred_Language__c
                                String query = 'SELECT Id,Name,Affiliated_Id__c,Enrollment_Date__c,Preferred_Language__c from Account where (Affiliated_Id__c IN :CFDAffilateIdSet or (Affiliated_Id__c IN :SMTNaffilateIDSet and Preferred_Language__c NOT IN :languagePrefered) or Affiliated_Id__c IN :SFXAffilateIdSet or Affiliated_Id__c IN : HCAffilateIdSet or Affiliated_Id__c NOT IN :APHSIAffilateIdSet) AND Membership_Product_Configuration__r.Responsible_Party__c = \'Member\' AND Membership_Status__c IN :membershipstatus AND (Dues_Last_Paid_Until__c = LAST_MONTH OR Dues_Last_Paid_Until__c = NEXT_MONTH) AND (NOT(MFProtection__c =: CheckMFProtection))';
        system.debug(query);
        return Database.getQueryLocator(query); 
    }
    public void execute(Database.BatchableContext BC, List<Account> scope){
        Set<Decimal> SMTNaffilateIDSet = new Set<Decimal>{1002222,1002347,1002343,1002223,1002224,1002327};
            set<Decimal> SFXAffilateIdSet = new set<Decimal>{1002277,1002276,1002319,1002320};   
                set<Decimal> HCAffilateIdSet = new set<Decimal>{1002243,1002310,1002311,1002312};
                                        set<Decimal> CFDAffilateIdSet = new set<Decimal>{1002266,1002256};
					
                    set<Decimal> APHSIAffilateIdSet = new set<Decimal>{1002222,1002347,1002343,1002223,1002224,1002327,1002243,1002311,1002312,1002310,1002257,1002277,1002276,1002319,1002320,1002336,1002274,1002241,1002409,1002275};
                        set<String> SFXMembershipSubType = new set<String>{'Annual Renew 149','Annual Renew 19','Annual Renew 29', 'Annual Renew 39','Annual Renew 59','Annual Renew 69','Annual Renew 79','Annual Renew 249'};                
        Integer currentMonth = System.today().month();

        //HSIMU2-489 Annual Dues Pre Due did not get added to Sales Cadence
		Integer nextMonthValue;
		Integer lastMonthValue;

		// Calculate next month
		if (currentMonth == 12) {
   		nextMonthValue = 1; // If the current month is December, next month is January of the next year
		} else {
    		nextMonthValue = currentMonth + 1;
		}

		// Calculate last month
		if (currentMonth == 1) {
    	lastMonthValue = 12; // If the current month is January, last month is December of the previous year
		} else {
    		lastMonthValue = currentMonth - 1;
		}

        List<Contact> updateContactList = new List<Contact>();
        set<Id> cadenceContactIds = new set<Id>();
        set<Id> setAccountId = new set<Id>();
        List<Contact> parentContacts = new List<Contact>();
        
        Map<String, set<Id>> MapCadenceNameVsContactIds = new Map<String,set<Id>>();
        for(Account acc : scope){
            if(CFDAffilateIdSet.contains(acc.Affiliated_Id__c) && acc.Enrollment_Date__c<Datetime.newInstanceGmt(2023, 8, 30, 0, 0, 0)){
                system.debug('CFD Affiliates before 30 AUG');
            }
            else{
            setAccountId.add(acc.Id);
            }
        }
          set<String> matchGroupNames = new set<String>{'Annual Dues-Pre Due SMTN','Annual Dues-Pre Due SFX','Annual Dues-Pre Due SFX SPA','Annual Dues-Pre Due Hawaii Collection','Annual Dues-Pre Due Hawaii Collection SPA','Annual Dues-Pre Due Advantage Program/HSI','Annual Dues-Pre Due Advantage Program/HSI SPA','Annual Dues-Past Due SMTN','Annual Dues-Past Due SFX','Annual Dues-Past Due SFX SPA','Annual Dues-Past Due Hawaii Collection','Annual Dues-Past Due Hawaii Collection SPA','Annual Dues-Past Due Advantage Program/HSI','Annual Dues-Past Due Advantage Program/HSI SPA'};
      
        //2023-10-17 - HSIMU2-341 - Annual Dues SPA added - Preferred_Language__c
        
        //addded 2023-12-21
        List<Contact> conlist = [select id,Match_Group_Name__c,Account.name,name,leadassist__Use_Round_Robin__c,Assign_to_Sales_Cadence__c,Cadence_Flag__c,Account.Dues_Last_Paid_Until__c, Account.Affiliated_Id__c, Account.Preferred_Language__c, Account.Membership_SubType__c,ActionCadenceId,ActionCadenceAssigneeId from Contact where AccountId IN : setAccountId AND ActionCadenceId = null AND ActionCadenceAssigneeId = null /*(ActionCadence.Name NOT IN : matchGroupNames)*/];
        if(conlist != null && conlist.size() > 0){
            for (Contact contact : conlist) {
                if (contact.Account.Name != null &&
                    contact.Account.Name.equalsIgnoreCase(contact.Name)) {
                        parentContacts.add(contact);
                    }
            }
            for(Contact objcon : parentContacts){
                //Past Month
                if(objcon.Account.Dues_Last_Paid_Until__c.month() == (lastMonthValue)){
                    //Annual Dues-Past Due SMTN
                    if(SMTNaffilateIDSet.contains(objcon.Account.Affiliated_Id__c)){
                        objcon.Match_Group_Name__c = 'Annual Dues-Past Due SMTN';
                        if(!MapCadenceNameVsContactIds.containsKey('Annual Dues-Past Due SMTN')){
                            MapCadenceNameVsContactIds.put('Annual Dues-Past Due SMTN',new set<Id>{objcon.Id});
                        }
                        else{    
                            MapCadenceNameVsContactIds.get('Annual Dues-Past Due SMTN').add(objcon.Id);
                        }
                    }
                    //2023-10-17 - HSIMU2-341 - Annual Dues SPA added - Preferred_Language__c
                    //Annual Dues-Past Due SFX
                    else if(SFXAffilateIdSet.contains(objcon.Account.Affiliated_Id__c)){
                        if(objcon.Account.Affiliated_Id__c == 1002277 && !SFXMembershipSubType.contains(objcon.Account.Membership_SubType__c)){
                            String matchGroupName1 = 'Annual Dues-Past Due SFX';
                            if(objcon.Account.Preferred_Language__c != '' && objcon.Account.Preferred_Language__c != null)
                            {
                                if(objcon.Account.Preferred_Language__c.startsWithIgnoreCase('SPA'))
                                {
                                    matchGroupName1 = 'Annual Dues-Past Due SFX SPA'; 
                                }
                            }
                            objcon.Match_Group_Name__c = matchGroupName1;
                            if(!MapCadenceNameVsContactIds.containsKey(matchGroupName1)){
                                MapCadenceNameVsContactIds.put(matchGroupName1,new set<Id>{objcon.Id});
                            }
                            else{    
                                MapCadenceNameVsContactIds.get(matchGroupName1).add(objcon.Id);
                            }
                        }
                    }
                    //2023-10-17 - HSIMU2-341 - Annual Dues SPA added - Preferred_Language__c
                    //Annual Dues-Past Due Hawaii Collection
                    else if(HCAffilateIdSet.contains(objcon.Account.Affiliated_Id__c)){
                        String matchGroupName2 = 'Annual Dues-Past Due Hawaii Collection';
                        if(objcon.Account.Preferred_Language__c != '' && objcon.Account.Preferred_Language__c != null)
                        {
                            if(objcon.Account.Preferred_Language__c.startsWithIgnoreCase('SPA'))
                            {
                                matchGroupName2 = 'Annual Dues-Past Due Hawaii Collection SPA'; 
                            }
                        }                        
                        objcon.Match_Group_Name__c = matchGroupName2;
                        if(!MapCadenceNameVsContactIds.containsKey(matchGroupName2)){
                            MapCadenceNameVsContactIds.put(matchGroupName2,new set<Id>{objcon.Id});
                        }
                        else{    
                            MapCadenceNameVsContactIds.get(matchGroupName2).add(objcon.Id);
                        }
                    }
                    //2023-10-17 - HSIMU2-341 - Annual Dues SPA added - Preferred_Language__c
                    //Annual Dues-Past Due Advantage Program/HSI
                    else if(!APHSIAffilateIdSet.contains(objcon.Account.Affiliated_Id__c)){                        
                        String matchGroupName3 = 'Annual Dues-Past Due Advantage Program/HSI';
                        if(objcon.Account.Preferred_Language__c != '' && objcon.Account.Preferred_Language__c != null)
                        {
                            if(objcon.Account.Preferred_Language__c.startsWithIgnoreCase('SPA'))
                            {
                                matchGroupName3 = 'Annual Dues-Past Due Advantage Program/HSI SPA'; 
                            }
                        }      
                        objcon.Match_Group_Name__c = matchGroupName3;
                        if(!MapCadenceNameVsContactIds.containsKey(matchGroupName3)){
                            MapCadenceNameVsContactIds.put(matchGroupName3,new set<Id>{objcon.Id});
                        }
                        else{    
                            MapCadenceNameVsContactIds.get(matchGroupName3).add(objcon.Id);
                        }
                    }
                }                
                //Pre Month
                else if(objcon.Account.Dues_Last_Paid_Until__c.month() == (nextMonthValue)){
                    //Annual Dues-Pre Due SMTN
                    if(SMTNaffilateIDSet.contains(objcon.Account.Affiliated_Id__c)){
                        objcon.Match_Group_Name__c = 'Annual Dues-Pre Due SMTN';
                        if(!MapCadenceNameVsContactIds.containsKey('Annual Dues-Pre Due SMTN')){
                            MapCadenceNameVsContactIds.put('Annual Dues-Pre Due SMTN',new set<Id>{objcon.Id});
                        }
                        else{    
                            MapCadenceNameVsContactIds.get('Annual Dues-Pre Due SMTN').add(objcon.Id);
                        }
                    }
                    //2023-10-17 - HSIMU2-341 - Annual Dues SPA added - Preferred_Language__c
                    //Annual Dues-Pre Due SFX
                    else if(SFXAffilateIdSet.contains(objcon.Account.Affiliated_Id__c)){  
                        if(objcon.Account.Affiliated_Id__c == 1002277 && !SFXMembershipSubType.contains(objcon.Account.Membership_SubType__c)){
                            String matchGroupName4 = 'Annual Dues-Pre Due SFX';
                            if(objcon.Account.Preferred_Language__c != '' && objcon.Account.Preferred_Language__c != null)
                            {
                                if(objcon.Account.Preferred_Language__c.startsWithIgnoreCase('SPA'))
                                {
                                    matchGroupName4 = 'Annual Dues-Pre Due SFX SPA'; 
                                }
                            }      
                            objcon.Match_Group_Name__c = matchGroupName4;
                            if(!MapCadenceNameVsContactIds.containsKey(matchGroupName4)){
                                MapCadenceNameVsContactIds.put(matchGroupName4,new set<Id>{objcon.Id});
                            }
                            else{    
                                MapCadenceNameVsContactIds.get(matchGroupName4).add(objcon.Id);
                            }
                        }
                    }
                    //2023-10-17 - HSIMU2-341 - Annual Dues SPA added - Preferred_Language__c
                    //Annual Dues-Pre Due Hawaii Collection
                    else if(HCAffilateIdSet.contains(objcon.Account.Affiliated_Id__c)){                        
                        String matchGroupName5 = 'Annual Dues-Pre Due Hawaii Collection';
                        if(objcon.Account.Preferred_Language__c != '' && objcon.Account.Preferred_Language__c != null)
                        {
                            if(objcon.Account.Preferred_Language__c.startsWithIgnoreCase('SPA'))
                            {
                                matchGroupName5 = 'Annual Dues-Pre Due Hawaii Collection SPA'; 
                            }
                        }                        
                        objcon.Match_Group_Name__c = matchGroupName5;
                        if(!MapCadenceNameVsContactIds.containsKey(matchGroupName5)){
                            MapCadenceNameVsContactIds.put(matchGroupName5,new set<Id>{objcon.Id});
                        }
                        else{    
                            MapCadenceNameVsContactIds.get(matchGroupName5).add(objcon.Id);
                        }
                    }
                    //2023-10-17 - HSIMU2-341 - Annual Dues SPA added - Preferred_Language__c
                    //Annual Dues-Pre Due Advantage Program/HSI
                    else if(!APHSIAffilateIdSet.contains(objcon.Account.Affiliated_Id__c)){
                        
                        String matchGroupName6 = 'Annual Dues-Pre Due Advantage Program/HSI';
                        if(objcon.Account.Preferred_Language__c != '' && objcon.Account.Preferred_Language__c != null)
                        {
                            if(objcon.Account.Preferred_Language__c.startsWithIgnoreCase('SPA'))
                            {
                                matchGroupName6 = 'Annual Dues-Pre Due Advantage Program/HSI SPA'; 
                            }
                        }                        
                        
                        objcon.Match_Group_Name__c = matchGroupName6;
                        if(!MapCadenceNameVsContactIds.containsKey(matchGroupName6)){
                            MapCadenceNameVsContactIds.put(matchGroupName6,new set<Id>{objcon.Id});
                        }
                        else{    
                            MapCadenceNameVsContactIds.get(matchGroupName6).add(objcon.Id);
                        }
                    }
                }
                //objcon.leadassist__Use_Round_Robin__c = 'TRUE';
                objcon.Assign_to_Sales_Cadence__c=true;
                objcon.Cadence_Flag__c=1;
                
                //addded 2023-12-21
                if(matchGroupNames.contains(objcon.Match_Group_Name__c)){				
                    updateContactList.add(objcon);
                }
                
                
            }
            system.debug('>>updateContactList>'+updateContactList);
            //removeed for testing in the sandbox
            //update updateContactList;
			//added to debug

            String csvHeader = 'id,Match_Group_Name__c,Account.name,name,leadassist__Use_Round_Robin__c,Assign_to_Sales_Cadence__c,Cadence_Flag__c,Account.Dues_Last_Paid_Until__c, Account.Affiliated_Id__c, Account.Preferred_Language__c, Account.Membership_SubType__c,ActionCadenceAssigneeId,ActionCadenceId\n';
            String csvBody = '';

            for (Contact cn : updateContactList) {
                csvBody += cn.Id + ',' + cn.Match_Group_Name__c + ',' + cn.Account.Name + ',' +
                    cn.Name + ',' + cn.leadassist__Use_Round_Robin__c + ',' +
                    cn.Assign_to_Sales_Cadence__c + ',' + cn.Cadence_Flag__c + ',' +
                    cn.Account.Dues_Last_Paid_Until__c + ',' + cn.Account.Affiliated_Id__c + ',' +
                    cn.Account.Preferred_Language__c + ',' + cn.Account.Membership_SubType__c + ',' +
                    cn.ActionCadenceAssigneeId + ',' + cn.ActionCadenceId + '\n';
            }

            // Step 3: Create Email Attachment
            Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
            attachment.setFileName('ContactList.csv');
            attachment.setBody(Blob.valueOf(csvHeader + csvBody));
            
            // Step 4: Create Email Message
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new String[] {'victor.goncalves@nerdsoft.com'});
            email.setSubject('Contact List CSV File');
            email.setPlainTextBody('Please find attached the Contact List in CSV format.');
            email.setFileAttachments(new Messaging.EmailFileAttachment[]{attachment});
            email.setToAddresses(new String[] {'victor.goncalves@nerdsoft.com'});
            email.setSubject('Contact List CSV File');
            email.setPlainTextBody('Please find attached the Contact List in CSV format.');
            email.setFileAttachments(new Messaging.EmailFileAttachment[]{attachment});
            email.setToAddresses(new String[] {'victor.goncalves@nerdsoft.com'});
            email.setSubject('Contact List CSV File');
            email.setPlainTextBody('Please find attached the Contact List in CSV format.');
            email.setFileAttachments(new Messaging.EmailFileAttachment[]{attachment});
            email.setToAddresses(new String[] {'victor.goncalves@nerdsoft.com'});
            email.setSubject('Contact List CSV File');
            email.setPlainTextBody('Please find attached the Contact List in CSV format.');
            email.setFileAttachments(new Messaging.EmailFileAttachment[]{attachment});
            
            // Step 5: Send Email
            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});

            if(!test.isRunningTest()){
                for(String key : MapCadenceNameVsContactIds.keyset()){
                    //removeed for testing in the sandbox
                    //System.enqueueJob(new GenericAssignToSalesCadence(MapCadenceNameVsContactIds.get(key), key)); 
                }
            }
            
        }
    }
    public void finish(Database.BatchableContext BC){
    }    
}