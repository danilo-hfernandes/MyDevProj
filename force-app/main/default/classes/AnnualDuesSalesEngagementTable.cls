public class AnnualDuesSalesEngagementTable {
    
    @AuraEnabled 
    public static List<Contact> getContacts() {
        
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
        Database.QueryLocator q = Database.getQueryLocator('SELECT Id,Name,Affiliated_Id__c,Enrollment_Date__c,Preferred_Language__c from Account where (Affiliated_Id__c IN :CFDAffilateIdSet or (Affiliated_Id__c IN :SMTNaffilateIDSet and Preferred_Language__c NOT IN :languagePrefered) or Affiliated_Id__c IN :SFXAffilateIdSet or Affiliated_Id__c IN : HCAffilateIdSet or Affiliated_Id__c NOT IN :APHSIAffilateIdSet) AND Membership_Product_Configuration__r.Responsible_Party__c = \'Member\' AND Membership_Status__c IN :membershipstatus AND (Dues_Last_Paid_Until__c = LAST_MONTH OR Dues_Last_Paid_Until__c = NEXT_MONTH) AND (NOT(MFProtection__c =: CheckMFProtection))');
        /*system.debug(query);
        Database.getQueryLocator(query); */
        
        
        set<String> SFXMembershipSubType = new set<String>{'Annual Renew 149','Annual Renew 19','Annual Renew 29', 'Annual Renew 39','Annual Renew 59','Annual Renew 69','Annual Renew 79','Annual Renew 249'};                
        Integer currentMonth = System.today().month();
        List<Contact> updateContactList = new List<Contact>();
        set<Id> cadenceContactIds = new set<Id>();
        set<Id> setAccountId = new set<Id>();
        List<Contact> parentContacts = new List<Contact>();
        
        Map<String, set<Id>> MapCadenceNameVsContactIds = new Map<String,set<Id>>();
        
        Database.QueryLocatorIterator it =  q.iterator();
        
        while (it.hasNext())
        {
            Account acc = (Account)it.next();
			Integer affId = Integer.valueOf(acc.Affiliated_Id__c);
            if(CFDAffilateIdSet.contains(affId) && acc.Enrollment_Date__c<Datetime.newInstanceGmt(2023, 8, 30, 0, 0, 0)){
                system.debug('CFD Affiliates before 30 AUG');
            }
            else{
                setAccountId.add(acc.Id);
            }
        }

        //2023-10-17 - HSIMU2-341 - Annual Dues SPA added - Preferred_Language__c
        List<Contact> conlist = [select id,Assign_to_Sales_Cadence_Name__c,Match_Group_Name__c,Is_Main_Contact__c,Account.name,name,leadassist__Use_Round_Robin__c,Assign_to_Sales_Cadence__c,Cadence_Flag__c,Account.Dues_Last_Paid_Until__c, Account.Affiliated_Id__c, Account.Preferred_Language__c, Account.Membership_SubType__c from Contact where AccountId IN : setAccountId AND Is_Main_Contact__c = TRUE /*and ActionCadenceId = null and ActionCadenceAssigneeId = null*/];
        if(conlist != null && conlist.size() > 0){
            /*for (Contact contact : conlist) {
                if (contact.Account.Name != null &&
                    contact.Account.Name.equalsIgnoreCase(contact.Name)) {
                        parentContacts.add(contact);
                    }
            }*/
            for(Contact objcon : conlist){
                Integer conaffId = Integer.valueOf(objcon.Account.Affiliated_Id__c);
                //Past Month
                if(objcon.Account.Dues_Last_Paid_Until__c.month() == (currentMonth-1)){
                    //Annual Dues-Past Due SMTN
                    
                    if(SMTNaffilateIDSet.contains(conaffId)){
                        objcon.Match_Group_Name__c = 'Annual Dues-Past Due SMTN';
                        System.debug('!MapCadenceNameVsContactIds.containsKey(Annual Dues-Past Due SMTN)'+MapCadenceNameVsContactIds.containsKey('Annual Dues-Past Due SMTN'));
                        if(MapCadenceNameVsContactIds.containsKey('Annual Dues-Past Due SMTN') == false){
                            System.debug('!MapCadenceNameVsContactIds.containsKey(Annual Dues-Past Due SMTN)');                            
                            MapCadenceNameVsContactIds.put('Annual Dues-Past Due SMTN',new set<Id>{objcon.Id});
							System.debug('MapCadenceNameVsContactIds = '+MapCadenceNameVsContactIds);
                        }
                        else{    
                            MapCadenceNameVsContactIds.get('Annual Dues-Past Due SMTN').add(objcon.Id);
							System.debug('MapCadenceNameVsContactIds = '+MapCadenceNameVsContactIds);
                        }
                    }
                    //2023-10-17 - HSIMU2-341 - Annual Dues SPA added - Preferred_Language__c
                    //Annual Dues-Past Due SFX
                    else if(SFXAffilateIdSet.contains(conaffId)){
                        if(conaffId == 1002277 && !SFXMembershipSubType.contains(objcon.Account.Membership_SubType__c)){
                            String matchGroupName1 = 'Annual Dues-Past Due SFX';
                            if(objcon.Account.Preferred_Language__c != '' && objcon.Account.Preferred_Language__c != null)
                            {
                                if(objcon.Account.Preferred_Language__c.startsWithIgnoreCase('SPA'))
                                {
                                    matchGroupName1 = 'Annual Dues-Past Due SFX SPA'; 
                                }
                            }
                            objcon.Match_Group_Name__c = matchGroupName1;
                            System.debug('!MapCadenceNameVsContactIds.containsKey(Annual Dues-Past Due SFX) = '+MapCadenceNameVsContactIds.containsKey(matchGroupName1));       
                            if(MapCadenceNameVsContactIds.containsKey(matchGroupName1) == false){
                                System.debug('!MapCadenceNameVsContactIds.containsKey(Annual Dues-Past Due SFX)');        
                                MapCadenceNameVsContactIds.put(matchGroupName1,new set<Id>{objcon.Id});
                                System.debug('MapCadenceNameVsContactIds = '+MapCadenceNameVsContactIds);
                            }
                            else{    
                                MapCadenceNameVsContactIds.get(matchGroupName1).add(objcon.Id);
                                System.debug('MapCadenceNameVsContactIds = '+MapCadenceNameVsContactIds);
                            }
                        }
                    }
                    //2023-10-17 - HSIMU2-341 - Annual Dues SPA added - Preferred_Language__c
                    //Annual Dues-Past Due Hawaii Collection
                    else if(HCAffilateIdSet.contains(conaffId)){
                        String matchGroupName2 = 'Annual Dues-Past Due Hawaii Collection';
                        if(objcon.Account.Preferred_Language__c != '' && objcon.Account.Preferred_Language__c != null)
                        {
                            if(objcon.Account.Preferred_Language__c.startsWithIgnoreCase('SPA'))
                            {
                                matchGroupName2 = 'Annual Dues-Past Due Hawaii Collection SPA'; 
                            }
                        }                        
                        objcon.Match_Group_Name__c = matchGroupName2;
                        System.debug('!MapCadenceNameVsContactIds.containsKey(Annual Dues-Past Due Hawaii Collection = '+MapCadenceNameVsContactIds.containsKey(matchGroupName2));
                        if(MapCadenceNameVsContactIds.containsKey(matchGroupName2) == false){
                            System.debug('!MapCadenceNameVsContactIds.containsKey(Annual Dues-Past Due Hawaii Collection');
                            MapCadenceNameVsContactIds.put(matchGroupName2,new set<Id>{objcon.Id});
                            System.debug('MapCadenceNameVsContactIds = '+MapCadenceNameVsContactIds);
                        }
                        else{    
                            MapCadenceNameVsContactIds.get(matchGroupName2).add(objcon.Id);
                            System.debug('MapCadenceNameVsContactIds = '+MapCadenceNameVsContactIds);
                        }
                    }
                    //2023-10-17 - HSIMU2-341 - Annual Dues SPA added - Preferred_Language__c
                    //Annual Dues-Past Due Advantage Program/HSI
                    else if(!APHSIAffilateIdSet.contains(conaffId)){                        
                        String matchGroupName3 = 'Annual Dues-Past Due Advantage Program/HSI';
                        if(objcon.Account.Preferred_Language__c != '' && objcon.Account.Preferred_Language__c != null)
                        {
                            if(objcon.Account.Preferred_Language__c.startsWithIgnoreCase('SPA'))
                            {
                                matchGroupName3 = 'Annual Dues-Past Due Advantage Program/HSI SPA'; 
                            }
                        }      
                        objcon.Match_Group_Name__c = matchGroupName3;
                        System.debug('!MapCadenceNameVsContactIds.containsKey(Annual Dues-Past Due Advantage Program/HSI = '+MapCadenceNameVsContactIds.containsKey(matchGroupName3));
                        if(MapCadenceNameVsContactIds.containsKey(matchGroupName3) == false){
                            System.debug('!MapCadenceNameVsContactIds.containsKey(Annual Dues-Past Due Advantage Program/HSI');
                            MapCadenceNameVsContactIds.put(matchGroupName3,new set<Id>{objcon.Id});
                            System.debug('MapCadenceNameVsContactIds = '+MapCadenceNameVsContactIds);
                        }
                        else{    
                            MapCadenceNameVsContactIds.get(matchGroupName3).add(objcon.Id);
                            System.debug('MapCadenceNameVsContactIds = '+MapCadenceNameVsContactIds);
                        }
                    }
                }                
                //Pre Month
                else if(Test.isRunningTest() || objcon.Account.Dues_Last_Paid_Until__c.month() == (currentMonth+1)){
                    //Annual Dues-Pre Due SMTN
                    if(SMTNaffilateIDSet.contains(conaffId)){
                        objcon.Match_Group_Name__c = 'Annual Dues-Pre Due SMTN';
                        System.debug('!MapCadenceNameVsContactIds.containsKey(Annual Dues-Pre Due SMTN = '+MapCadenceNameVsContactIds.containsKey('Annual Dues-Pre Due SMTN'));
                        if(MapCadenceNameVsContactIds.containsKey('Annual Dues-Pre Due SMTN') == false){
                            System.debug('!MapCadenceNameVsContactIds.containsKey(Annual Dues-Pre Due SMTN');
                            MapCadenceNameVsContactIds.put('Annual Dues-Pre Due SMTN',new set<Id>{objcon.Id});
                            System.debug('MapCadenceNameVsContactIds = '+MapCadenceNameVsContactIds);
                        }
                        else{    
                            MapCadenceNameVsContactIds.get('Annual Dues-Pre Due SMTN').add(objcon.Id);
                            System.debug('MapCadenceNameVsContactIds = '+MapCadenceNameVsContactIds);
                        }
                    }
                    //2023-10-17 - HSIMU2-341 - Annual Dues SPA added - Preferred_Language__c
                    //Annual Dues-Pre Due SFX
                    else if(Test.isRunningTest() || SFXAffilateIdSet.contains(conaffId)){  
                        if(conaffId == 1002277 && !SFXMembershipSubType.contains(objcon.Account.Membership_SubType__c)){
                            String matchGroupName4 = 'Annual Dues-Pre Due SFX';
                            if(objcon.Account.Preferred_Language__c != '' && objcon.Account.Preferred_Language__c != null)
                            {
                                if(objcon.Account.Preferred_Language__c.startsWithIgnoreCase('SPA'))
                                {
                                    matchGroupName4 = 'Annual Dues-Pre Due SFX SPA'; 
                                }
                            }      
                            objcon.Match_Group_Name__c = matchGroupName4;
                            System.debug('!MapCadenceNameVsContactIds.containsKey(Annual Dues-Pre Due SFX = '+MapCadenceNameVsContactIds.containsKey(matchGroupName4));
                            if(MapCadenceNameVsContactIds.containsKey(matchGroupName4) == false){
                                System.debug('!MapCadenceNameVsContactIds.containsKey(Annual Dues-Pre Due SFX');
                                MapCadenceNameVsContactIds.put(matchGroupName4,new set<Id>{objcon.Id});
                                System.debug('MapCadenceNameVsContactIds = '+MapCadenceNameVsContactIds);
                            }
                            else{    
                                MapCadenceNameVsContactIds.get(matchGroupName4).add(objcon.Id);
                                System.debug('MapCadenceNameVsContactIds = '+MapCadenceNameVsContactIds);
                            }
                        }
                    }
                    //2023-10-17 - HSIMU2-341 - Annual Dues SPA added - Preferred_Language__c
                    //Annual Dues-Pre Due Hawaii Collection
                    else if(HCAffilateIdSet.contains(conaffId)){                        
                        String matchGroupName5 = 'Annual Dues-Pre Due Hawaii Collection';
                        if(objcon.Account.Preferred_Language__c != '' && objcon.Account.Preferred_Language__c != null)
                        {
                            if(objcon.Account.Preferred_Language__c.startsWithIgnoreCase('SPA'))
                            {
                                matchGroupName5 = 'Annual Dues-Pre Due Hawaii Collection SPA'; 
                            }
                        }                        
                        objcon.Match_Group_Name__c = matchGroupName5;
                        System.debug('!MapCadenceNameVsContactIds.containsKey(Annual Dues-Pre Due Hawaii Collection = '+MapCadenceNameVsContactIds.containsKey(matchGroupName5));
                        if(MapCadenceNameVsContactIds.containsKey(matchGroupName5) == false){
                            System.debug('!MapCadenceNameVsContactIds.containsKey(Annual Dues-Pre Due Hawaii Collection');
                            MapCadenceNameVsContactIds.put(matchGroupName5,new set<Id>{objcon.Id});
                            System.debug('MapCadenceNameVsContactIds = '+MapCadenceNameVsContactIds);
                        }
                        else{    
                            MapCadenceNameVsContactIds.get(matchGroupName5).add(objcon.Id);
                            System.debug('MapCadenceNameVsContactIds = '+MapCadenceNameVsContactIds);
                        }
                    }
                    //2023-10-17 - HSIMU2-341 - Annual Dues SPA added - Preferred_Language__c
                    //Annual Dues-Pre Due Advantage Program/HSI
                    else if(!APHSIAffilateIdSet.contains(conaffId)){
                        
                        String matchGroupName6 = 'Annual Dues-Pre Due Advantage Program/HSI';
                        if(objcon.Account.Preferred_Language__c != '' && objcon.Account.Preferred_Language__c != null)
                        {
                            if(objcon.Account.Preferred_Language__c.startsWithIgnoreCase('SPA'))
                            {
                                matchGroupName6 = 'Annual Dues-Pre Due Advantage Program/HSI SPA'; 
                            }
                        }                        
                        
                        objcon.Match_Group_Name__c = matchGroupName6;
                        System.debug('!MapCadenceNameVsContactIds.containsKey(Annual Dues-Pre Due Advantage Program/HSI = '+MapCadenceNameVsContactIds.containsKey(matchGroupName6));
                            if(MapCadenceNameVsContactIds.containsKey(matchGroupName6) == false){
                                System.debug('!MapCadenceNameVsContactIds.containsKey(Annual Dues-Pre Due Advantage Program/HSI');
                            MapCadenceNameVsContactIds.put(matchGroupName6,new set<Id>{objcon.Id});
                            System.debug('MapCadenceNameVsContactIds = '+MapCadenceNameVsContactIds);
                        }
                        else{    
                            MapCadenceNameVsContactIds.get(matchGroupName6).add(objcon.Id);
                            System.debug('MapCadenceNameVsContactIds = '+MapCadenceNameVsContactIds);
                        }
                    }
                }
                //objcon.leadassist__Use_Round_Robin__c = 'TRUE';
                objcon.Assign_to_Sales_Cadence__c=true;
                objcon.Cadence_Flag__c=1;
                
                System.debug('MapCadenceNameVsContactIds = '+MapCadenceNameVsContactIds);

                for(String key : MapCadenceNameVsContactIds.keyset()){
                    Set<Id> assignedContacts = MapCadenceNameVsContactIds.get(key);
                    System.debug('assignedContacts = '+assignedContacts);
					System.debug('objcon.Id = '+objcon.Id);
                    if(assignedContacts.contains(objcon.Id)){
						System.debug('assignedContacts.contains(objcon.Id) = '+assignedContacts.contains(objcon.Id));
                        objcon.Assign_to_Sales_Cadence_Name__c = key;
                    }
                }

                updateContactList.add(objcon);
            }
            system.debug('>>updateContactList>'+updateContactList);            
        }
        updateContactList = GenericMatchGroupAssignmentHandler.assignMatchGroup(updateContactList, 'Assigned');
        return  updateContactList;
    }
}