public class AccountTriggerHelper {
    
    public void CreateHSIEnrollment(List<Account> accountRecords){
        list<HSI_Enrollment_Queue__c> hsirecords = new list<HSI_Enrollment_Queue__c>();
        for(Account acc : accountRecords){
            //modified 2022-04-05 adding VI Referral Affiliate Id            //modified 2022-04-18 adding acc.Master_Record_Id__c == null or blank filter
            //modified 2022-07-15 adding Future Stay Affiliate Id            //modified 2022-08-09 adding Public Reservation Inquiry Affiliate Id
            //modified 2022-01-11 removing SMTN Affiliate Id (1002222)            //modified 2022-01-11 adding Premembership Affiliate Id
            //modified 2023-12-28 adding vidanta converter affiliate id            //modified 2024-04-04 adding Advantage Services Affiliate Marketing
            //modified 2025-02-18 adding CLub Global Explorer VW
            //modified 2025-07-22 adding RaiseAway Guest, EngageGood Guest
            //modified 2026-12-06 adding RaiseAway Guest, EngageGood Guest
            //Club Venture Deploy
            if((acc.Master_Record_Id__c == null || acc.Master_Record_Id__c == '') && (acc.Affiliated_Id__c== 1002464 || acc.Affiliated_Id__c == 1002460 || acc.Affiliated_Id__c == 1002436 || acc.Affiliated_Id__c == 1002453 || acc.Affiliated_Id__c == 1002454 || acc.Affiliated_Id__c == 1002455 || acc.Affiliated_Id__c == 1002456 || acc.Affiliated_Id__c == 1002440 || acc.Affiliated_Id__c == 1002433 || acc.Affiliated_Id__c == 1002266 || acc.Affiliated_Id__c == 1002274 || acc.Affiliated_Id__c == 1002256 || acc.Affiliated_Id__c == 1002261 || acc.Affiliated_Id__c == 1002344 || acc.Affiliated_Id__c == 1002241 || acc.Affiliated_Id__c == 1002379 || acc.Affiliated_Id__c == 1002442 || acc.Affiliated_Id__c == 1002421 || acc.Affiliated_Id__c == 1002445 || acc.Affiliated_Id__c == 1002452 || acc.Affiliated_Id__c == 1002458 || acc.Affiliated_Id__c == 1002459 || acc.Affiliated_Id__c == 1002470 || acc.Affiliated_Id__c == 1002471 || acc.Affiliated_Id__c == 1002478 || (acc.Affiliated_Id__c == 1002348 && System.isFuture()))){
                //if((acc.Master_Record_Id__c == null || acc.Master_Record_Id__c == '') && (acc.Affiliated_Id__c == 1002460 || acc.Affiliated_Id__c == 1002436 || acc.Affiliated_Id__c == 1002440 || acc.Affiliated_Id__c == 1002433 || acc.Affiliated_Id__c == 1002266 || acc.Affiliated_Id__c == 1002274 || acc.Affiliated_Id__c == 1002256 || acc.Affiliated_Id__c == 1002261 || acc.Affiliated_Id__c == 1002344 || acc.Affiliated_Id__c == 1002241 || acc.Affiliated_Id__c == 1002379 || acc.Affiliated_Id__c == 1002442 || acc.Affiliated_Id__c == 1002421 || acc.Affiliated_Id__c == 1002445 || acc.Affiliated_Id__c == 1002452 || acc.Affiliated_Id__c == 1002458 || acc.Affiliated_Id__c == 1002459 || (acc.Affiliated_Id__c == 1002348 && System.isFuture()))){
                HSI_Enrollment_Queue__c hsi = New HSI_Enrollment_Queue__c();
                hsi.AccountId__c = acc.Id;
                hsi.City__c = acc.BillingCity;
                hsi.State__c = acc.BillingState;
                hsi.Country__c = acc.BillingCountry;
                hsi.Email__c = acc.Email__c;
                hsi.Zip_Code__c = acc.BillingPostalCode;
                hsi.First_Name__c = acc.First_Name__c;
                hsi.Last_Name__c = acc.Last_Name__c;
                hsi.Primary_Phone__c = acc.Phone;
                hsi.Address__c = acc.BillingStreet;
                if(acc.Affiliated_Id__c == 1002266){
                    if(acc.Affiliate_Name__c != 'Think Direct'){
                        hsi.Created_By__c = 'Carefree Destinations';
                        hsi.Record_Origin__c = 'Carefree Destinations';
                    }else if(acc.Affiliate_Name__c == 'Think Direct'){
                        hsi.Created_By__c = 'Think Direct';
                        hsi.Record_Origin__c = 'Think Direct';
                    }
                }else if(acc.Affiliated_Id__c == 1002274){
                    hsi.Created_By__c = 'SMTN Mexico';
                    hsi.Record_Origin__c = 'SMTN Mexico';
                }
                //modified 2022-04-05 adding VI Referral
                else if(acc.Affiliated_Id__c == 1002261){
                    hsi.Created_By__c = 'VI Referral Form';
                    hsi.Record_Origin__c = 'VI Referral Form';
                }
                //modified 2022-07-15 adding Future Stay
                else if(acc.Affiliated_Id__c == 1002344){
                    hsi.Created_By__c = 'Future Stay';
                    hsi.Record_Origin__c = 'Future Stay';
                }
                //modified 2022-07-15 adding Public Reservation Inquiry
                else if(acc.Affiliated_Id__c == 1002241){
                    hsi.Created_By__c = 'Lead Conversion';
                    hsi.Record_Origin__c = 'Public Reservation Inquiry';
                }
                //modified 2022-11-01 adding VIPP
                else if(acc.Affiliated_Id__c == 1002348)
                {
                    hsi.Created_By__c = 'Vacation VIP';
                    hsi.Record_Origin__c = 'Webform';
                }
                else if(acc.Affiliated_Id__c == 1002379)
                {
                    hsi.Created_By__c = 'SF Enrollment Queue';
                    hsi.Record_Origin__c = 'SF Leads';
                }
                else if(acc.Affiliated_Id__c == 1002256)
                {
                    hsi.Created_By__c = 'Lead Conversion';
                    hsi.Record_Origin__c = 'Internal Source';
                }
                else if(acc.Affiliated_Id__c == 1002421)
                {
                    hsi.Created_By__c = 'Carefree Destinations Affiliate Marketing MX Voucher';
                    hsi.Record_Origin__c = 'Carefree Destinations Affiliate Marketing MX Voucher';
                }
                else if(acc.Affiliated_Id__c == 1002433)
                {
                    hsi.Created_By__c = 'Vidanta Converter';
                    hsi.Record_Origin__c = 'Vidanta Converter';
                }
                else if(acc.Affiliated_Id__c == 1002440)
                {
                    hsi.Created_By__c = 'Advantage Services Affiliate Marketing';
                    hsi.Record_Origin__c = 'Advantage Services Affiliate Marketing';
                }
                else if(acc.Affiliated_Id__c == 1002436)
                {
                    hsi.Created_By__c = 'CoolVacay Plus';
                    hsi.Record_Origin__c = 'CoolVacay Plus';
                }
                else if(acc.Affiliated_Id__c == 1002442)
                {
                    hsi.Created_By__c = 'Advantage Getaway Voucher';
                    hsi.Record_Origin__c = 'Advantage Getaway Voucher';
                }
                else if(acc.Affiliated_Id__c == 1002445)
                {
                    hsi.Created_By__c = 'LuxGive Guest';
                    hsi.Record_Origin__c = 'LuxGive Guest';
                }
                // 1002458
                // 1002459
                else if(acc.Affiliated_Id__c == 1002458)
                {
                    hsi.Created_By__c = 'Club Global Explorer VW - Trial';
                    hsi.Record_Origin__c = 'Club Global Explorer VW - Trial';
                }
                else if(acc.Affiliated_Id__c == 1002459)
                {
                    hsi.Created_By__c = 'Club Global Explorer VW';
                    hsi.Record_Origin__c = 'Club Global Explorer VW';
                }
                else if(acc.Affiliated_Id__c == 1002452)
                {
                    hsi.Created_By__c = 'Inspira Resort Week';
                    hsi.Record_Origin__c = 'Inspira Resort Week';
                }
                // Club Venture Deploy                // 1002453
                else if(acc.Affiliated_Id__c == 1002453)
                {
                    hsi.Created_By__c = 'Club Venture - Guest';
                    hsi.Record_Origin__c = 'Club Venture - Guest';
                }
                // 1002454
                else if(acc.Affiliated_Id__c == 1002454)
                {
                    hsi.Created_By__c = 'Club Venture - Ruby';
                    hsi.Record_Origin__c = 'Club Venture - Ruby';
                }
                // 1002455
                else if(acc.Affiliated_Id__c == 1002455)
                {
                    hsi.Created_By__c = 'Club Venture - Emerald';
                    hsi.Record_Origin__c = 'Club Venture - Emerald';
                }
                // 1002456
                else if(acc.Affiliated_Id__c == 1002456)
                {
                    hsi.Created_By__c = 'Club Venture - Sapphire';
                    hsi.Record_Origin__c = 'Club Venture - Sapphire';
                } 
                
                else if(acc.Affiliated_Id__c == 1002460)
                {
                    hsi.Created_By__c = 'Filetracker';
                    hsi.Record_Origin__c = 'Filetracker';
                } 
                
                else if(acc.Affiliated_Id__c == 1002470)
                {
                    hsi.Created_By__c = 'Raise Away Guest';
                    hsi.Record_Origin__c = 'Raise Away Guest';
                }
                
                else if(acc.Affiliated_Id__c == 1002464)
                {
                    hsi.Created_By__c = 'Raise Away Voucher';
                    hsi.Record_Origin__c = 'Raise Away Voucher';
                }    
                
                else if(acc.Affiliated_Id__c == 1002471)
                {
                    hsi.Created_By__c = 'Engaged Good Guest';
                    hsi.Record_Origin__c = 'Engaged Good Guest';
                }
                else if(acc.Affiliated_Id__c == 1002478)
                {
                    hsi.Created_By__c = 'One Agency Bulk Voucher Sheet';
                    hsi.Record_Origin__c = 'One Agency Bulk Voucher Sheet';
                }
                /*else if(acc.Affiliated_Id__c == 1002469)
                {
                    hsi.Created_By__c = 'Reserve Collection';
                    hsi.Record_Origin__c = 'Reserve Collection';
                }*/
                //modified 2022-12-23 adding SMTN Affiliate Id
                /*else if(acc.Affiliated_Id__c == 1002222)
{
hsi.Created_By__c = 'Lead Conversion';
hsi.Record_Origin__c = 'SMTN';
}*/
                
                hsirecords.add(hsi);
            }
        }
        if(hsirecords.size() > 0 && hsirecords != null){
            try{
                insert hsirecords;
                Set<Id> HSIIdSet = new Set<Id>();
                for(HSI_Enrollment_Queue__c heq : hsirecords){
                    HSIIdSet.add(heq.Id);
                }
                if(HSIIdSet.size() > 0 && HSIIdSet != null){
                    Map<Id,String> accountIdHSIAutoNumberMap = new Map<Id,String>();
                    List<HSI_Enrollment_Queue__c> HSIListUpdate = new List<HSI_Enrollment_Queue__c>();
                    List<HSI_Enrollment_Queue__c> HSIList = [select id,Auto_Id__c,Record_Origin__c,Member_Number__c,AccountId__c from HSI_Enrollment_Queue__c where id IN : HSIIdSet];
                    for(HSI_Enrollment_Queue__c hsMp : HSIList){
                        if(hsMp.Record_Origin__c == 'Carefree Destinations'){
                            accountIdHSIAutoNumberMap.put(hsmp.AccountId__c,'AP-CFD-' +hsmp.Auto_Id__c);
                            hsmp.Member_Number__c = 'AP-CFD-' +hsmp.Auto_Id__c;
                            HSIListUpdate.add(hsmp);
                        }else if(hsMp.Record_Origin__c == 'SMTN Mexico'){
                            accountIdHSIAutoNumberMap.put(hsmp.AccountId__c,'AP-SMTMX-' +hsmp.Auto_Id__c);
                            hsmp.Member_Number__c = 'AP-SMTMX-' +hsmp.Auto_Id__c;
                            HSIListUpdate.add(hsmp);
                        }else if(hsMp.Record_Origin__c == 'Think Direct'){
                            accountIdHSIAutoNumberMap.put(hsmp.AccountId__c,'AP-CFD-' +hsmp.Auto_Id__c); //updated by Amadeu on 09/27/2021 from AP-TD
                            hsmp.Member_Number__c = 'AP-CFD-' +hsmp.Auto_Id__c; //updated by Amadeu on 09/27/2021 from AP-TD
                            HSIListUpdate.add(hsmp);
                        }
                        //modified 2022-04-05 adding VI Referral
                        else if(hsMp.Record_Origin__c == 'VI Referral Form'){
                            accountIdHSIAutoNumberMap.put(hsmp.AccountId__c,'AP-VIR-' +hsmp.Auto_Id__c);
                            hsmp.Member_Number__c = 'AP-VIR-' +hsmp.Auto_Id__c;
                            HSIListUpdate.add(hsmp);
                        }
                        //modified 2022-07-15 adding Future Stay
                        else if(hsMp.Record_Origin__c == 'Future Stay'){
                            accountIdHSIAutoNumberMap.put(hsmp.AccountId__c,'AP-FS-' +hsmp.Auto_Id__c);
                            hsmp.Member_Number__c = 'AP-FS-' +hsmp.Auto_Id__c;
                            HSIListUpdate.add(hsmp);
                        }
                        //modified 2022-07-15 adding Public Reservation Inquiry
                        else if(hsMp.Record_Origin__c == 'Public Reservation Inquiry'){
                            accountIdHSIAutoNumberMap.put(hsmp.AccountId__c,'AP-SMTNC-' +hsmp.Auto_Id__c);
                            hsmp.Member_Number__c = 'AP-SMTNC-' +hsmp.Auto_Id__c;
                            HSIListUpdate.add(hsmp);
                        }
                        //modified 2022-11-01 adding VIPP
                        else if(hsMp.Record_Origin__c == 'Webform'){
                            accountIdHSIAutoNumberMap.put(hsmp.AccountId__c,'AP-VIPP-' +hsmp.Auto_Id__c);
                            hsmp.Member_Number__c = 'AP-VIPP-' +hsmp.Auto_Id__c;
                            HSIListUpdate.add(hsmp);
                        }
                        //modified 2022-01-11 adding Premembership Affiliate Id
                        else if(hsMp.Record_Origin__c == 'SF Leads'){
                            accountIdHSIAutoNumberMap.put(hsmp.AccountId__c,'AP-PREM-' +hsmp.Auto_Id__c);
                            hsmp.Member_Number__c = 'AP-PREM-' +hsmp.Auto_Id__c;
                            HSIListUpdate.add(hsmp);
                        }
                        //modified 2023-03-16 adding Internal Source
                        else if(hsMp.Record_Origin__c == 'Internal Source'){
                            accountIdHSIAutoNumberMap.put(hsmp.AccountId__c,'AP-CFD-' +hsmp.Auto_Id__c);
                            hsmp.Member_Number__c = 'AP-CFD-' +hsmp.Auto_Id__c;
                            HSIListUpdate.add(hsmp);
                        }
                        else if(hsMp.Record_Origin__c == 'Carefree Destinations Affiliate Marketing MX Voucher'){
                            accountIdHSIAutoNumberMap.put(hsmp.AccountId__c,'AP-AMMX-' +hsmp.Auto_Id__c);
                            hsmp.Member_Number__c = 'AP-AMMX-' +hsmp.Auto_Id__c;
                            HSIListUpdate.add(hsmp);
                        }
                        else if(hsMp.Record_Origin__c == 'Vidanta Converter'){
                            accountIdHSIAutoNumberMap.put(hsmp.AccountId__c,'AP-VICO-' +hsmp.Auto_Id__c);
                            hsmp.Member_Number__c = 'AP-VICO-' +hsmp.Auto_Id__c;
                            HSIListUpdate.add(hsmp);
                        }
                        else if(hsMp.Record_Origin__c == 'Advantage Services Affiliate Marketing'){
                            accountIdHSIAutoNumberMap.put(hsmp.AccountId__c,'AP-AMMX-' +hsmp.Auto_Id__c);
                            hsmp.Member_Number__c = 'AP-AMMX-' +hsmp.Auto_Id__c;
                            HSIListUpdate.add(hsmp);
                        }
                        else if(hsMp.Record_Origin__c == 'CoolVacay Plus'){
                            accountIdHSIAutoNumberMap.put(hsmp.AccountId__c,'AP-CVP-' +hsmp.Auto_Id__c);
                            hsmp.Member_Number__c = 'AP-CVP-' +hsmp.Auto_Id__c;
                            HSIListUpdate.add(hsmp);
                        }
                        else if(hsMp.Record_Origin__c == 'Advantage Getaway Voucher'){
                            accountIdHSIAutoNumberMap.put(hsmp.AccountId__c,'AP-ABW-' +hsmp.Auto_Id__c);
                            hsmp.Member_Number__c = 'AP-ABW-' +hsmp.Auto_Id__c;
                            HSIListUpdate.add(hsmp);
                        }                         
                        
                        else if(hsMp.Record_Origin__c == 'Club Global Explorer VW - Trial'){
                            accountIdHSIAutoNumberMap.put(hsmp.AccountId__c,'AP-CGEVWT-' +hsmp.Auto_Id__c);
                            hsmp.Member_Number__c = 'AP-CGEVWT-' +hsmp.Auto_Id__c;
                            HSIListUpdate.add(hsmp);
                        }
                        else if(hsMp.Record_Origin__c == 'Club Global Explorer VW'){
                            accountIdHSIAutoNumberMap.put(hsmp.AccountId__c,'AP-CGEVW-' +hsmp.Auto_Id__c);
                            hsmp.Member_Number__c = 'AP-CGEVW-' +hsmp.Auto_Id__c;
                            HSIListUpdate.add(hsmp);
                        }
                        //Club Venture Deploy
                        else if(hsMp.Record_Origin__c == 'Club Venture - Guest'){
                            accountIdHSIAutoNumberMap.put(hsmp.AccountId__c,'AP-CVC-' +hsmp.Auto_Id__c);
                            hsmp.Member_Number__c = 'AP-CVC-' +hsmp.Auto_Id__c;
                            HSIListUpdate.add(hsmp);
                        }
                        else if(hsMp.Record_Origin__c == 'Club Venture - Ruby'){
                            accountIdHSIAutoNumberMap.put(hsmp.AccountId__c,'AP-CVCR-' +hsmp.Auto_Id__c);
                            hsmp.Member_Number__c = 'AP-CVCR-' +hsmp.Auto_Id__c;
                            HSIListUpdate.add(hsmp);
                        }
                        else if(hsMp.Record_Origin__c == 'Club Venture - Emerald'){
                            accountIdHSIAutoNumberMap.put(hsmp.AccountId__c,'AP-CVCE-' +hsmp.Auto_Id__c);
                            hsmp.Member_Number__c = 'AP-CVCE-' +hsmp.Auto_Id__c;
                            HSIListUpdate.add(hsmp);
                        }
                        else if(hsMp.Record_Origin__c == 'Club Venture - Sapphire'){
                            accountIdHSIAutoNumberMap.put(hsmp.AccountId__c,'AP-CVCS-' +hsmp.Auto_Id__c);
                            hsmp.Member_Number__c = 'AP-CVCS-' +hsmp.Auto_Id__c;
                            HSIListUpdate.add(hsmp);
                        }
                        
                        else if(hsMp.Record_Origin__c == 'LuxGive Guest'){
                            accountIdHSIAutoNumberMap.put(hsmp.AccountId__c,'AP-LGG-' +hsmp.Auto_Id__c);
                            hsmp.Member_Number__c = 'AP-LGG-' +hsmp.Auto_Id__c;
                            HSIListUpdate.add(hsmp);
                        }
                        else if(hsMp.Record_Origin__c == 'Inspira Resort Week'){
                            accountIdHSIAutoNumberMap.put(hsmp.AccountId__c,'AP-IRW-' +hsmp.Auto_Id__c);
                            hsmp.Member_Number__c = 'AP-IRW-' +hsmp.Auto_Id__c;
                            HSIListUpdate.add(hsmp);
                        }
                        else if(hsMp.Record_Origin__c == 'Filetracker'){
                            accountIdHSIAutoNumberMap.put(hsmp.AccountId__c,'AP-FT-' +hsmp.Auto_Id__c);
                            hsmp.Member_Number__c = 'AP-FT-' +hsmp.Auto_Id__c;
                            HSIListUpdate.add(hsmp);
                        }
                        else if(hsMp.Record_Origin__c == 'Raise Away Guest'){
                            accountIdHSIAutoNumberMap.put(hsmp.AccountId__c,'AP-RAG-' +hsmp.Auto_Id__c);
                            hsmp.Member_Number__c = 'AP-RAG-' +hsmp.Auto_Id__c;
                            HSIListUpdate.add(hsmp);
                        }
                        else if(hsMp.Record_Origin__c == 'Raise Away Voucher'){
                            accountIdHSIAutoNumberMap.put(hsmp.AccountId__c,'AP-RAV-' +hsmp.Auto_Id__c);
                            hsmp.Member_Number__c = 'AP-RAV-' +hsmp.Auto_Id__c;
                            HSIListUpdate.add(hsmp);
                        }                            
                        else if(hsMp.Record_Origin__c == 'Engaged Good Guest'){
                            accountIdHSIAutoNumberMap.put(hsmp.AccountId__c,'AP-EGG-' +hsmp.Auto_Id__c);
                            hsmp.Member_Number__c = 'AP-EGG-' +hsmp.Auto_Id__c;
                            HSIListUpdate.add(hsmp);
                        }                            
                        else if(hsMp.Record_Origin__c == 'One Agency Bulk Voucher Sheet'){
                            accountIdHSIAutoNumberMap.put(hsmp.AccountId__c,'AP-OAV-' +hsmp.Auto_Id__c);
                            hsmp.Member_Number__c = 'AP-OAV-' +hsmp.Auto_Id__c;
                            HSIListUpdate.add(hsmp);
                        }
                        /*else if(hsMp.Record_Origin__c == 'Reserve Collection'){
                            accountIdHSIAutoNumberMap.put(hsmp.AccountId__c,'AP-RC-' +hsmp.Auto_Id__c);
                            hsmp.Member_Number__c = 'AP-RC-' +hsmp.Auto_Id__c;
                            HSIListUpdate.add(hsmp);
                        }*/
                        //modified 2022-12-23 adding SMTN Affiliate Id
                        /*else if(hsMp.Record_Origin__c == 'SMTN'){
accountIdHSIAutoNumberMap.put(hsmp.AccountId__c,'AP-SMTN-' +hsmp.Auto_Id__c);
hsmp.Member_Number__c = 'AP-SMTN-' +hsmp.Auto_Id__c;
HSIListUpdate.add(hsmp);
}*/
                    }
                    
                    List<Account> accList = new List<Account>();
                    if(accountIdHSIAutoNumberMap != null){
                        for(Account accMNMapping : accountRecords){
                            if(accountIdHSIAutoNumberMap.containskey(accMNMapping.Id)){
                                Account acc = new Account(id=accMNMapping.Id);
                                acc.Member_Number__c = accountIdHSIAutoNumberMap.get(acc.Id);
                                accList.add(acc);
                            }
                        }
                    }
                    if(accList != null && accList.size() > 0){
                        update accList;
                    }
                    if(HSIListUpdate != null && HSIListUpdate.size() > 0){
                        update HSIListUpdate;
                    }
                    
                }
            }catch(Exception e){
                system.debug('exception= ' +e);
            }
        }
    }
    
    //method for check for HC flag
    /*public static void hcFlagCheck(list<Account> accList){
list<String> phoneList=new list<String>();
list<String> emailList=new list<String>();
list<String> duplicatePhoneList=new list<String>();
list<String> duplicateEmailList=new list<String>();
list<Integer> affiliatedIds=new list<Integer>{1002243,1002310,1002311, 1002312, 1002324, 1002328};
for(Account acc: accList){
if(acc.Affiliated_Id__c==1002277){
phoneList.add(acc.Phone);
emailList.add(acc.email__c);
}
}

list<Account> duplicateAccounts=[Select id,phone,email__c from account where (phone IN: phoneList OR email__c IN: emailList) AND (Affiliated_id__c IN: affiliatedIds)];

if(duplicateAccounts.size()>0){

for(Account acc: duplicateAccounts){
duplicatePhoneList.add(acc.Phone);
duplicateEmailList.add(acc.email__c);
}

for(Account acc: accList){
system.debug('124-='+acc);

if(duplicatePhoneList.contains(acc.Phone) || duplicateEmailList.contains(acc.Email__c)){
system.debug('127='+acc);
acc.HC_Flag__c=true;
}

}
}

}*/
    
    
    // method to create SFX Opportunity
    public static void sfxOpportunity(list<Account> accList){
        
        //String sfxId=[select id from recordtype where name='SFX Membership'].id;
        list<Opportunity> sfxOpportunity=new list<opportunity>();
        for(Account acc: accList){
            if(acc.Affiliated_Id__c==1002277){
                system.debug('144='+acc);
                Opportunity opp= new Opportunity();
                opp.name=acc.name;
                opp.stagename='New';
                opp.AccountId=acc.id;
                opp.CloseDate=system.today();
                opp.RecordTypeId=Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('SFX_Membership').getRecordTypeId();
                sfxOpportunity.add(opp);
            }
        }
        system.debug('153='+sfxOpportunity.size());
        if(sfxOpportunity.size()>0){
            insert sfxOpportunity;
        }
    }
    
    // method to create MTRC Upgrade Opportunity
    
    public static void MTRCMUOpportunity(list<Account> accList){
        list<Opportunity> mtrcOpportunity=new list<opportunity>();
        for(Account acc: accList){
            if(acc.Affiliated_Id__c==1002379 && acc.AccountSource == 'SMTN Open Lead - 1 year'){
                //system.debug('144='+acc);
                Opportunity opp= new Opportunity();
                opp.name=acc.name;
                opp.stagename='New';
                opp.AccountId=acc.id;
                opp.CloseDate=system.today();
                opp.RecordTypeId=Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('MTRC_Retail').getRecordTypeId();
                mtrcOpportunity.add(opp);
            }
        }
        //system.debug('153='+mtrcOpportunity.size());
        if(mtrcOpportunity.size()>0){
            insert mtrcOpportunity;
        }
    }
    
    // method to create vida Book With Us Opportunity
    public static void vidaBookWithUsOpp(list<Account> accList){
        list<Opportunity> vidaBookOpportunity=new list<opportunity>();
        for(Account acc: accList){
            if(acc.Affiliated_Id__c == 1002418 && acc.AccountSource == 'TRM Book With Us'){
                system.debug('144='+acc);
                Opportunity opp= new Opportunity(); 
                opp.name=acc.name;
                opp.stagename='New';
                opp.AccountId=acc.id;
                opp.CloseDate=system.today();
                opp.RecordTypeId=Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Vida_Book_With_Us').getRecordTypeId();
                vidaBookOpportunity.add(opp);
            }
        }
        system.debug('153='+vidaBookOpportunity.size());
        if(vidaBookOpportunity!= null && vidaBookOpportunity.size()>0){
            insert vidaBookOpportunity;
            PriceBook2 pb2Standard = [select Id from Pricebook2 where isStandard=true];
            Product2 objProduct = [select id from Product2 where Name = 'Book With Us' limit 1];
            List<PricebookEntry> pbEntry = new List<PricebookEntry>();
            if(pb2Standard != null && objProduct != null)
                pbEntry = [select id from PricebookEntry where Pricebook2Id =: pb2Standard.Id and Product2Id =: objProduct.Id limit 1];
            PricebookEntry objpbEntry = new PricebookEntry();
            if(pbEntry != null && pbEntry.size() >0){
                objpbEntry = pbEntry[0];
            }
            else{
                objpbEntry.Product2Id = objProduct.Id;
                objpbEntry.Pricebook2Id = pb2Standard.Id;
                objpbEntry.IsActive = true;
                objpbEntry.UnitPrice = 0;
                insert objpbEntry;
            }
            List<OpportunityLineItem> opplineItemList = new List<OpportunityLineItem>();
            for(Opportunity opp : vidaBookOpportunity){
                OpportunityLineItem opplineItem = new OpportunityLineItem();
                opplineItem.Product2Id = objProduct.Id;
                opplineItem.OpportunityId = opp.Id;
                opplineItem.Quantity = 1;
                opplineItem.TotalPrice = 0;
                opplineItem.PricebookEntryId = objpbEntry.Id;
                opplineItemList.add(opplineItem);
            }
            if(opplineItemList != null && opplineItemList.size() > 0){
                insert opplineItemList; 
            }
        }
    }
    
    //added 2023-07-04 - HSIMU2-103 - method to create membership Upgrade Vida Week Opps
    public static void membershipUpgradeVidaWeekOpp(list<Account> accList){
        
        System.debug('membershipUpgradeVidaWeekOpp entered');
        list<Opportunity> membershipUpgradeVidaWeekOpps = new list<opportunity>();        
        list<OpportunityLineItem> membershipUpgradeVidaWeekOlis = new list<OpportunityLineItem>(); 
        list<OpportunityLineItem> membershipUpgradeVidaWeekOlisInserted = new list<OpportunityLineItem>();
        list<Payment__c> oliPayments = new list<Payment__c>();
        List<Integer> affiliateIds = new List<Integer>{1002247};//{1002265,1002225,1002226,1002227,1002247};// HSIMU2-417 / SCO-15
            List<String> errorLog = new List<String>();
        
        Set<Id> membershipUpgradeVidaWeekOlisIds = new Set<Id>();
        
        System.debug('membershipUpgradeVidaWeekOpp accList = '+accList);
        
        for(Account acc: accList){
            
            System.debug('membershipUpgradeVidaWeekOpp acc.Affiliated_Id__c = '+acc.Affiliated_Id__c);            
            System.debug('membershipUpgradeVidaWeekOpp acc.Created_By_Username__c = '+acc.Created_By_Username__c);
            System.debug('membershipUpgradeVidaWeekOpp acc.CreatedById = '+acc.CreatedById);
            
            if(acc.Affiliated_Id__c != null && acc.Affiliated_Id__c > 0){
                System.debug('membershipUpgradeVidaWeekOpp Integer.valueOf(acc.Affiliated_Id__c) = '+Integer.valueOf(acc.Affiliated_Id__c));
                if(affiliateIds.contains(Integer.valueOf(acc.Affiliated_Id__c)) && (acc.Created_By_Username__c.contains('dev@nerdsoft.com.hsi.full') || acc.CreatedById == '0053t000006rZcSAAU')){
                    Id oppMTRCMembership_UpgradeRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Voucher').getRecordTypeId();                
                    Opportunity opp= new Opportunity(); 
                    opp.name=acc.name;
                    opp.AccountId=acc.id;                
                    opp.RecordTypeId=oppMTRCMembership_UpgradeRecordTypeId;
                    opp.stagename='New';
                    opp.CloseDate=system.today();
                    opp.Vidanta_Voucher_Email_Sent__c = true;
                    opp.Voucher_18_Months_Email_Sent__c = true;
                    opp.Vidanta_SFX_Voucher_Email_Sent__c = true;
                    membershipUpgradeVidaWeekOpps.add(opp);                
                }
            }            
        }
        
        System.debug('membershipUpgradeVidaWeekOpp membershipUpgradeVidaWeekOpps = '+membershipUpgradeVidaWeekOpps);
        
        if(membershipUpgradeVidaWeekOpps!= null && membershipUpgradeVidaWeekOpps.size()>0){
            try{
                insert membershipUpgradeVidaWeekOpps;
            }
            Catch(Exception e)
            {
                String oppListJson = JSON.serialize(membershipUpgradeVidaWeekOpps);
                errorLog.add('insert membershipUpgradeVidaWeekOpps ['+oppListJson+'] Error : '+e.getMessage()+'/;/');
            }
            Id pbeId = [SELECT Id, Name, Product2Id, Product2.Id, Product2.Name FROM PriceBookEntry WHERE Product2.Name = 'Membership Upgrade Vida Week' LIMIT 1].Id;            
            for(Opportunity opp : membershipUpgradeVidaWeekOpps){
                OpportunityLineItem oli = new OpportunityLineItem();
                oli.Quantity = 1;
                oli.OpportunityId = opp.Id;
                oli.PriceBookEntryID = pbeId;
                membershipUpgradeVidaWeekOlis.add(oli);
            }            
        }
        
        System.debug('membershipUpgradeVidaWeekOpp membershipUpgradeVidaWeekOlis = '+membershipUpgradeVidaWeekOlis);
        
        if(membershipUpgradeVidaWeekOlis != null && membershipUpgradeVidaWeekOlis.size() > 0){
            try{
                insert membershipUpgradeVidaWeekOlis;
            }
            Catch(Exception e)
            {
                String oliListJson = JSON.serialize(membershipUpgradeVidaWeekOlis);
                errorLog.add('insert membershipUpgradeVidaWeekOlis ['+oliListJson+'] Error : '+e.getMessage()+'/;/');
            }
            for(OpportunityLineItem oppLineItem : membershipUpgradeVidaWeekOlis)
            {
                membershipUpgradeVidaWeekOlisIds.add(oppLineItem.Id);
            }
        }
        
        System.debug('membershipUpgradeVidaWeekOpp membershipUpgradeVidaWeekOlisIds = '+membershipUpgradeVidaWeekOlisIds);
        
        if(membershipUpgradeVidaWeekOlisIds != null && membershipUpgradeVidaWeekOlisIds.size() > 0){
            membershipUpgradeVidaWeekOlisInserted = [SELECT Id, Product_ID__c, Product2.Id, Opportunity.AccountId, OpportunityId FROM OpportunityLineItem WHERE Id IN : membershipUpgradeVidaWeekOlisIds];
            for(OpportunityLineItem lineItem : membershipUpgradeVidaWeekOlisInserted)
            {                
                Payment__c objpayment = new Payment__c();
                objpayment.Paid_On__c = system.today();
                objpayment.Opportunity__c = lineItem.OpportunityId;
                objpayment.Payment_Type__c = 'Payment';
                objpayment.Payment_Amount__c = 0;
                objpayment.RecordTypeId = Schema.SObjectType.Payment__c.getRecordTypeInfosByDeveloperName().get('Voucher').getRecordTypeId();
                objpayment.Account__c = lineItem.Opportunity.AccountId;
                objpayment.Product_Id__c = lineItem.Product_ID__c;
                objpayment.Product_Salesforce_Id__c = lineItem.Product2.Id;                
                oliPayments.add(objpayment);
            }
        }
        
        System.debug('membershipUpgradeVidaWeekOpp oliPayments = '+oliPayments);
        
        if(oliPayments != null && oliPayments.size() > 0){
            try{
                insert oliPayments;
            }
            Catch(Exception e)
            {
                System.debug('ERROR! ' + e);
                String payListJson = JSON.serialize(oliPayments);
                errorLog.add('insert oliPayments ['+payListJson+'] Error : '+e.getMessage()+'/;/');
            }
        }
        
        if(errorLog.size()>0 && errorLog != null)
        {
            try {
                Boolean runningInASandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
                if(!runningInASandbox){
                    String message = String.valueOf(errorLog);
                    system.debug('--message-'+message);
                    Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
                    String[] sendingTo = new String[]{'victor.goncalves@nerdsoft.com','amadeu.lettieri@nerdsoft.com'};
                        semail.setToAddresses(sendingTo);
                    semail.setSubject('AccountTriggerHelper membershipUpgradeVidaWeekOpp is failed');
                    semail.setPlainTextBody(message);
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] {semail}); 
                }
            } 
            catch( System.Exception e){
                System.debug('ERROR: '+ e);
            }
        }
    }
    
    //Added 26 March 2024, HSIMU2-824
    public static void updateTimeshareOwnerFlag(List<Account> accList,String type){
        set<String> membershipConfigIds = new set<String>();
        map<String,String> mapMemberConfigIdvsFlag = new map<String, String>();
        List<Account> listAcc = new List<Account>();
        set<Id> setAccountIds = new set<Id>();
        for(Account objacc : accList){
            if(objacc.MembershipProductConfigId_Formula__c != null){
                membershipConfigIds.add(objacc.MembershipProductConfigId_Formula__c);
            }
        }
        if(membershipConfigIds != null && membershipConfigIds.size() > 0){
            List<Timeshare_Owner_Flag__c>  listTimeshareOwnerFlag = [select id, Name, Timeshare_Owner__c from Timeshare_Owner_Flag__c where Name IN: membershipConfigIds];
            if(listTimeshareOwnerFlag.size() > 0){
                for(Timeshare_Owner_Flag__c objtimeshare : listTimeshareOwnerFlag){
                    mapMemberConfigIdvsFlag.put(objtimeshare.Name, objtimeshare.Timeshare_Owner__c);
                }
                system.debug('>>>mapMemberConfigIdvsFlag>>>'+mapMemberConfigIdvsFlag);
                for(Account objacc : accList){
                    if(objacc.MembershipProductConfigId_Formula__c != null && mapMemberConfigIdvsFlag != null && mapMemberConfigIdvsFlag.containsKey(objacc.MembershipProductConfigId_Formula__c) && objacc.Timeshare_Owner__c != mapMemberConfigIdvsFlag.get(objacc.MembershipProductConfigId_Formula__c)){
                        Account acc = new Account();
                        acc.Id = objacc.Id;
                        acc.Timeshare_Owner__c = mapMemberConfigIdvsFlag.get(objacc.MembershipProductConfigId_Formula__c);
                        listAcc.add(acc);
                    }
                }
            }
            if(listAcc != null && listAcc.size() > 0){
                update listAcc;
            }
        }
    }
    //2024-04-29 [ACI-7] Sync real time email between Account and Primary Contact
    @future(callout=true)
    public static void syncEmail(Map<Id,String> emailKeyPair, String ObjectName){
        //sync from main contact to parent account
        if(ObjectName == 'Account')
        {
            List<Account> accountsToCheck = [SELECT Id,Email__c,Email_2__c,Parent_Child_Contact_Id__c FROM Account WHERE Parent_Child_Contact_Id__c != NULL AND Id IN : emailKeyPair.keySet()];
            List<Account> accountsToUpdate = new List<Account>();
            if(accountsToCheck != null && accountsToCheck.size()>0)
            {
                for(Account a : accountsToCheck)
                {
                    if(a.Email_2__c != null){
                        if(!a.Email_2__c.contains(a.Email__c))
                        {
                            String aux1 = a.Email_2__c+' ; '+a.Email__c;
                            if(aux1.length() <= 255)
                            {
                                a.Email_2__c = aux1;
                            }
                        }
                    }
                    if(a.Email_2__c == null || a.Email_2__c == ''){                        
                        a.Email_2__c = a.Email__c;                        
                    }
                    if(emailKeyPair.get(a.Id) != a.Email__c)
                    {
                        a.Email__c = emailKeyPair.get(a.Id);
                        accountsToUpdate.add(a);
                    }                    
                }
            }
            if(accountsToUpdate != null && accountsToUpdate.size()>0)
            {
                update accountsToUpdate;
            }
        }
        //sync from parent account to main contact
        else if(ObjectName == 'Contact')
        {
            List<Contact> contactsToCheck = [SELECT Id,Email,Email_2__c FROM Contact WHERE Is_Main_Contact__c = true AND Id IN : emailKeyPair.keySet()];
            List<Contact> contactsToUpdate = new List<Contact>();
            if(contactsToCheck != null && contactsToCheck.size()>0)
            {
                for(Contact c : contactsToCheck)
                {
                    if(c.Email_2__c != null){
                        if(!c.Email_2__c.contains(c.Email))
                        {
                            String aux3 = c.Email_2__c+' ; '+c.Email;
                            if(aux3.length() <= 255)
                            {
                                c.Email_2__c = aux3;
                            }
                        }
                    }
                    if(c.Email_2__c == null || c.Email_2__c == ''){                        
                        c.Email_2__c = c.Email;
                    }
                    if(emailKeyPair.get(c.Id) != c.Email)
                    {
                        c.Email = emailKeyPair.get(c.Id);
                        contactsToUpdate.add(c);
                    }
                }
            }
            if(contactsToUpdate != null && contactsToUpdate.size()>0)
            {
                update contactsToUpdate;
            }
        }
    }
    @future(callout= true)
    public static void syncNameAccountANDContact(Map<Id, String> mapIdVsFirstName,Map<Id, String> mapIdVsLastName, String ObjectName){
        //sync from Parent Account to Main Contact
        if(ObjectName == 'Account')
        {
            List<Contact> contactsToCheck = [SELECT Id,FirstName,LastName,AccountId FROM Contact WHERE Is_Main_Contact__c = true AND AccountId IN : mapIdVsFirstName.Keyset()];
            List<Contact> contactToUpdate = new List<Contact>();
            if(contactsToCheck != null && contactsToCheck.size()>0){
                for(Contact objcon : contactsToCheck){
                    objcon.FirstName = mapIdVsFirstName.get(objcon.AccountId);
                    objcon.LastName = mapIdVsLastName.get(objcon.AccountId);
                    contactToUpdate.add(objcon);
                }
            }
            if(contactToUpdate != null && contactToUpdate.size()>0)
            {
                update contactToUpdate;
            }
        }
        //sync from Main Contact To Parent Account
        else if(ObjectName == 'Contact')
        {
            List<Account> accountsToCheck = [SELECT Id,First_Name__c,Last_Name__c,Parent_Child_Contact_Id__c FROM Account WHERE Parent_Child_Contact_Id__c != NULL AND Id IN :  mapIdVsFirstName.Keyset()];
            List<Account> accountsToUpdate = new List<Account>();
            if(accountsToCheck != null && accountsToCheck.size()>0){
                for(Account objacc : accountsToCheck){
                    objacc.First_Name__c = mapIdVsFirstName.get(objacc.Id);
                    objacc.Last_Name__c = mapIdVsLastName.get(objacc.Id);
                    accountsToUpdate.add(objacc);
                }
            }
            if(accountsToUpdate != null && accountsToUpdate.size()>0){
                update accountsToUpdate;
            }
        }
    }
    
    //2025-08-05 [MAINT-2426] Sync real time Do Not Call between Account and Primary Contact
    public static void syncDNC(Map<Id, Boolean> DNCKeyPair, String ObjectName){
        //sync from Parent Account to Main Contact
        if(ObjectName == 'Account')
        {
            List<Contact> contactsToCheck = [SELECT Id,DoNotCall,AccountId FROM Contact WHERE Is_Main_Contact__c = true AND AccountId IN : DNCKeyPair.Keyset()];
            List<Contact> contactToUpdate = new List<Contact>();
            if(contactsToCheck != null && contactsToCheck.size()>0){
                for(Contact objcon : contactsToCheck){
                    objcon.DoNotCall = DNCKeyPair.get(objcon.AccountId);
                    contactToUpdate.add(objcon);
                }
            }
            if(contactToUpdate != null && contactToUpdate.size()>0)
            {
                update contactToUpdate;
            }
        }
        //sync from Main Contact To Parent Account
        else if(ObjectName == 'Contact')
        {
            List<Account> accountsToCheck = [SELECT Id,Do_Not_Call__c,Parent_Child_Contact_Id__c FROM Account WHERE Parent_Child_Contact_Id__c != NULL AND Id IN :  DNCKeyPair.Keyset()];
            List<Account> accountsToUpdate = new List<Account>();
            if(accountsToCheck != null && accountsToCheck.size()>0){
                for(Account objacc : accountsToCheck){
                    objacc.Do_Not_Call__c = DNCKeyPair.get(objacc.Id);
                    accountsToUpdate.add(objacc);
                }
            }
            if(accountsToUpdate != null && accountsToUpdate.size()>0){
                update accountsToUpdate;
            }
        }
    }
    
    
    @future(callout=true)
    public static void sfxMemberTransfer(Set<Id> sfxMembersAccIds){
        List<Opportunity> openedSFXOpps = [SELECT Id,StageName FROM Opportunity WHERE IsWon = false AND IsClosed = false AND RecordType.DeveloperName = 'SFX_Membership' AND StageName != 'Auto Open' AND AccountId IN : sfxMembersAccIds];
        List<Opportunity> oppsToMoveToAutoOpen = new List<Opportunity>();
        
        if(openedSFXOpps.size() > 0 && openedSFXOpps != null)
        {
            for(Opportunity o : openedSFXOpps)
            {
                o.stagename = 'Auto Open';
                oppsToMoveToAutoOpen.add(o);
            }
        }
        if(oppsToMoveToAutoOpen.size()>0 && oppsToMoveToAutoOpen != null)
        {
            update oppsToMoveToAutoOpen;   
        }
    }
    public static void syncEmailToOpportunity(Set<Id> accIds){
        List<Opportunity> oppList = [SELECT Id,Account_Email__c, account.Email__c FROM Opportunity WHERE AccountId IN : accIds];
        List<Opportunity> oppListToUpdate = new List<Opportunity>();
        
        if(oppList.size() > 0 && oppList != null)
        {
            for(Opportunity opp : oppList)
            {
                opp.Account_Email__c = opp.account.Email__c;
                oppListToUpdate.add(opp);
            }
        }
        if(oppListToUpdate.size()>0 && oppListToUpdate != null)
        {
            update oppListToUpdate;   
        }
    }
}