public without sharing class ConvertLeadWithOpportunityController {
    
    @AuraEnabled 
    public static Map<String,String> tryToConvertLead(String recordId){
        String returnSuccess = 'true';        
        String returnResults = '';
        Map<String,String> stateAndLog = new Map<String,String>();
        try{
             System.debug('lead to be recordId: '+recordId);
            //allow
            Id Public_Reservation_Inquiry_Id = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Public_Reservation_Inquiry').getRecordTypeId();            
            Id Carefree_Destinations_Id = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Carefree_Destinations').getRecordTypeId();            
            Id SMTN_Mexico_Id = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('SMTN_Mexico').getRecordTypeId();            
            Id VI_Referral_Id = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('VI_Referral').getRecordTypeId();
            Id membershipUpgradeRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Vacation_VIP_Membership_Upgrade').getRecordTypeId();
            Id clubVentureRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Club_Venture_Membership').getRecordTypeId();
            Id SMTNOpenLeadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('SMTN_Open_Lead').getRecordTypeId();
            Id adSalesRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Ad_Sales').getRecordTypeId();
			Id socialAdSalesOppRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Social_Ad_Sales').getRecordTypeId();
             
 			System.debug('SMTNOpenLeadRecordTypeId: '+SMTNOpenLeadRecordTypeId);
			            
            //block
            Id B2B_Record_Type_Id = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('B2B_Record_Type').getRecordTypeId();
            Id Think_Direct_Id = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Think_Direct').getRecordTypeId();
            Id Future_Stay_Id = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Future_Stay').getRecordTypeId();
            
            Lead ld = [SELECT Id,RecordTypeId,LeadSource,Email,Phone,Match_Affiliate_Id__c,OwnerId,Lead_Original_Source__c FROM Lead WHERE Id =: recordId];
            System.debug('ld: '+ld);
            System.debug('lead to be converted: '+ld);
            
            //2025-10-03 - if the lead owner is not a user, update the owner to the current user
            if (ld.OwnerId != null && !String.valueOf(ld.OwnerId).startsWith('005')) {
                ld.OwnerId = UserInfo.getUserId();
                update ld;
            }
            
            if(ld.RecordTypeId == B2B_Record_Type_Id || ld.RecordTypeId == Think_Direct_Id || ld.RecordTypeId == Future_Stay_Id)
            {
                returnSuccess = 'false';
                returnResults = 'Opportunities will not be automatically created for this Lead Record Type, use the default button for conversion.';
            }
            else
            {
                
                List<Account> duplicatedAccounts = new List<Account>();
                if(ld.RecordTypeId == Carefree_Destinations_Id && ld.Lead_Original_Source__c == 'Day Drive' && (ld.LeadSource.startsWithIgnoreCase('CFD FB DD') || ld.LeadSource.startsWithIgnoreCase('TG DD'))){
                    
                    Set<String> emails = new Set<String>();
                    Set<String> phones = new Set<String>();
                    List<Lead> listLead = [select id, Email,Phone,Affiliate_Id__c from Lead where Id =: ld.Id];
                    for (Lead l : listLead) {
                        if (l.Email != null) emails.add(l.Email.toLowerCase());
                        if (l.Email != null) emails.add(l.Email);
                        if (l.Phone != null) phones.add(l.Phone.replaceAll('[^0-9]', ''));
                        if (l.Phone != null) phones.add(l.Phone);
                    }                    
                    duplicatedAccounts = [Select Id,Email__c,Phone,Affiliated_Id__c,Master_Record_Id__c,CreatedDate,SystemModStamp,LastReferencedDate, (SELECT Id,AffiliatedId__c,Phone,Email FROM Contacts where (Email IN :emails OR Phone IN :phones)) FROM Account where (Affiliated_Id__c =: ld.Match_Affiliate_Id__c) AND (Email__c IN :emails OR Phone IN :phones) order by createddate desc];
                    if(duplicatedAccounts != null && duplicatedAccounts.size()>0){
                        returnSuccess = 'false';
                        returnResults = 'Conversion Failed - Duplicated account found - We already have an account '+duplicatedAccounts[0].Id+' with the same phone ('+duplicatedAccounts[0].Phone+') or email ('+duplicatedAccounts[0].Email__c+') under the affiliation Affiliate ID ('+duplicatedAccounts[0].Affiliated_Id__c+')';
                        stateAndLog.put(returnSuccess,returnResults);
                        return stateAndLog;
                    }
                }
                else
                {
                    duplicatedAccounts = [Select Id,Email__c,Phone,Affiliated_Id__c,Master_Record_Id__c,CreatedDate,SystemModStamp,LastReferencedDate, (SELECT Id,AffiliatedId__c,Phone,Email FROM Contacts where (Email =: ld.Email OR Phone =: ld.Phone)) FROM Account where (Affiliated_Id__c =: ld.Match_Affiliate_Id__c) AND (Email__c =: ld.Email OR Phone =: ld.Phone) AND CreatedDate = LAST_N_MONTHS:6 order by createddate desc];                    
                }
                    
                Database.LeadConvert lc = new Database.LeadConvert();
                Database.DMLOptions dml = new Database.DMLOptions();
                dml.DuplicateRuleHeader.AllowSave = true;
                lc.setLeadId(ld.Id);
                lc.setDoNotCreateOpportunity(false);
                
  
                System.debug('duplicatedAccounts'+duplicatedAccounts);
                System.debug('ld.RecordTypeId:'+ld.RecordTypeId);
                System.debug('adSalesRecordTypeId:'+adSalesRecordTypeId);
                System.debug('ld.LeadSource:'+ld.LeadSource);

                if(duplicatedAccounts != null && duplicatedAccounts.size()>0)
                {
                    System.debug('duplicatedAccounts not null');
                    System.debug('duplicatedAccounts[0].Id'+duplicatedAccounts[0].Id);
                    lc.setAccountId(duplicatedAccounts[0].Id);
                    if(duplicatedAccounts[0].Contacts != null && duplicatedAccounts[0].Contacts.size()>0)
                    {
                        System.debug('duplicatedAccounts[0].Contacts'+duplicatedAccounts[0].Contacts);
                        lc.setContactId(duplicatedAccounts[0].Contacts[0].Id);
                    }
                }
                
                if(ld.RecordTypeId == Public_Reservation_Inquiry_Id && ld.LeadSource == 'SMTN Buyer Offer'){                    

                    lc.setConvertedStatus('Closed Won');
                    Database.LeadConvertResult lcResults = Database.convertLead(lc,dml);
                    Id OppId = lcResults.getOpportunityId();
                    /*Opportunity createdOpp = [SELECT Id FROM Opportunity WHERE Id =: OppId LIMIT 1];
createdOpp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Membership_Upgrade').getRecordTypeId();
update createdOpp;*/
                    returnSuccess = String.valueOf(lcResults.isSuccess());
                    returnResults = String.valueOf(lcResults);
                }
                else if(ld.RecordTypeId == Public_Reservation_Inquiry_Id && ld.LeadSource == 'SMTN Rental Offer'){
                    lc.setConvertedStatus('Closed Won');
                    Database.LeadConvertResult lcResults = Database.convertLead(lc,dml);
                    Id OppId = lcResults.getOpportunityId();


                    /*Opportunity createdOpp = [SELECT Id FROM Opportunity WHERE Id =: OppId LIMIT 1];
createdOpp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Travel').getRecordTypeId();
update createdOpp;*/
                    returnSuccess = String.valueOf(lcResults.isSuccess());
                    returnResults = String.valueOf(lcResults);
                }
                /*else if(ld.RecordTypeId == Carefree_Destinations_Id && ld.LeadSource == 'Raise Away' && (ld.Lead_Original_Source__c == 'DR $150' || ld.Lead_Original_Source__c == 'MX $440')){
                    lc.setDoNotCreateOpportunity(false);
                    lc.setConvertedStatus('Closed Won');
                    lc.setOwnerId(UserInfo.getUserId());
                    Database.LeadConvertResult lcResults = Database.convertLead(lc,dml);
                    
                    System.debug('lcResults here == '+JSON.serialize(lcResults));
                    Id OppId = lcResults.getOpportunityId();
                    
                    System.debug('lcResults.getOpportunityId() = '+lcResults.getOpportunityId());
                    System.debug('lcResults.getAccountId() = '+lcResults.getAccountId());
                    
                    if(ld.Lead_Original_Source__c == 'MX $440'){
                        updateOpportunityWithProductAndPayment(OppId,'Raise Away-All Inclusive MX 5-Night $249 Resort Fee');
                    }
                    else if(ld.Lead_Original_Source__c == 'DR $150')
                    {
                        updateOpportunityWithProductAndPayment(OppId,'Raise Away-All Inclusive DR 5-Night $249 Resort Fee');
                    }
                    Id accId = lcResults.getAccountId();
                }*/
                else if(ld.RecordTypeId == Public_Reservation_Inquiry_Id && ld.LeadSource == 'Inspira Resort Week'){
                    lc.setConvertedStatus('Closed Won');
                    Database.LeadConvertResult lcResults = Database.convertLead(lc,dml);
                    Id OppId = lcResults.getOpportunityId();

                    Opportunity opp = new Opportunity();
                    opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Travel').getRecordTypeId();
                    opp.Id = lcResults.getOpportunityId();
                    //opp.CloseDate = date.today().addDays(15);
                    //opp.StageName = 'New';
                    update opp;                    
                    
                    /*Opportunity createdOpp = [SELECT Id FROM Opportunity WHERE Id =: OppId LIMIT 1];
					createdOpp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Travel').getRecordTypeId();
					update createdOpp;*/
                    
                    returnSuccess = String.valueOf(lcResults.isSuccess());
                    returnResults = String.valueOf(lcResults);
                }
                //2025-05-15 - TGR-631 #4 SF - Internal CV - Lead Conversion (Manually) and HSI Enrollment queue
                else if(ld.RecordTypeId == Carefree_Destinations_Id && ld.Lead_Original_Source__c == 'Day Drive' && (ld.LeadSource.startsWithIgnoreCase('CFD FB DD') || ld.LeadSource.startsWithIgnoreCase('TG DD') || ld.LeadSource.startsWithIgnoreCase('OPC-Red Rock'))){
                    lc.setDoNotCreateOpportunity(false);
                    lc.setConvertedStatus('Closed Won');
                    lc.setOwnerId(UserInfo.getUserId());
                    Database.LeadConvertResult lcResults = Database.convertLead(lc,dml);
                    
                    System.debug('lcResults here == '+JSON.serialize(lcResults));
                    Id OppId = lcResults.getOpportunityId();
                    
                    System.debug('lcResults.getOpportunityId() = '+lcResults.getOpportunityId());
                    System.debug('lcResults.getAccountId() = '+lcResults.getAccountId());
                    
                    updateOpportunity(OppId);
                    
                    Id accId = lcResults.getAccountId();
                    
                    //default as Pender from DB - no need to update in sfdc
                    // Update Account
                    /*Account acc = new Account(Id = accId,Membership_Status__c = 'Pender');
                    if(acc.Id != null){
                        update acc;
                    }*/
                    
                    returnSuccess = String.valueOf(lcResults.isSuccess());
                    returnResults = String.valueOf(lcResults);
                }
                else if(ld.RecordTypeId == Carefree_Destinations_Id || ld.RecordTypeId == SMTN_Mexico_Id){
                    lc.setConvertedStatus('Sold Voucher');
                    Database.LeadConvertResult lcResults = Database.convertLead(lc,dml);
                    Id OppId = lcResults.getOpportunityId();


                    /*Opportunity createdOpp = [SELECT Id FROM Opportunity WHERE Id =: OppId LIMIT 1];
createdOpp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Voucher').getRecordTypeId();
update createdOpp;*/
                    returnSuccess = String.valueOf(lcResults.isSuccess());
                    returnResults = String.valueOf(lcResults);
                }
                else if(ld.RecordTypeId == VI_Referral_Id){
                    lc.setConvertedStatus('Sold Voucher');
                    Database.LeadConvertResult lcResults = Database.convertLead(lc,dml);
                    Id OppId = lcResults.getOpportunityId();

                    /*Opportunity createdOpp = [SELECT Id FROM Opportunity WHERE Id =: OppId LIMIT 1];
createdOpp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Voucher').getRecordTypeId();
update createdOpp;*/
                    
                    /*OpportunityLineItem oli = new OpportunityLineItem();
oli.Quantity = 1;
oli.OpportunityId = OppId;
oli.Product2Id = [SELECT Id FROM Product2 WHERE Name = 'Vida Voucher-Flex Date Request' LIMIT 1].Id;
oli.PriceBookEntryID = [SELECT Id FROM PricebookEntry WHERE Name = 'Vida Voucher-Flex Date Request' LIMIT 1].Id;
insert oli;*/
                    
                    returnSuccess = String.valueOf(lcResults.isSuccess());
                    returnResults = String.valueOf(lcResults);
                }
                
                else if(ld.RecordTypeId == membershipUpgradeRecordTypeId && ld.LeadSource == 'Vacation VIP - Web'){

                    lc.setConvertedStatus('Closed Won');
                    Database.LeadConvertResult lcResults = Database.convertLead(lc,dml);
                    Id OppId = lcResults.getOpportunityId();
                    /*Opportunity createdOpp = [SELECT Id FROM Opportunity WHERE Id =: OppId LIMIT 1];
createdOpp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Travel').getRecordTypeId();
update createdOpp;*/
                    returnSuccess = String.valueOf(lcResults.isSuccess());
                    returnResults = String.valueOf(lcResults);
                }
                else if(ld.RecordTypeId == SMTNOpenLeadRecordTypeId && ld.LeadSource == 'SMTN Open Lead - 1 year'){
                    system.debug('--ld.LeadSource-'+ld.LeadSource);
                    lc.setConvertedStatus('Closed Won');
                    lc.setDoNotCreateOpportunity(true);
                    Database.LeadConvertResult lcResults = Database.convertLead(lc,dml);
                    Id OppId = lcResults.getOpportunityId();
                    system.debug('--OppId'+OppId);
                    /*Opportunity createdOpp = [SELECT Id FROM Opportunity WHERE Id =: OppId LIMIT 1];
createdOpp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Travel').getRecordTypeId();
update createdOpp;*/
                    returnSuccess = String.valueOf(lcResults.isSuccess());
                    returnResults = String.valueOf(lcResults);
                
                } 
                else if(ld.RecordTypeId == adSalesRecordTypeId){   // && (ld.LeadSource == 'ARDA' || ld.LeadSource == 'WBAST - FBLA')
                    //SAS-2
                    lc.setConvertedStatus('Closed Won');
                    //lc.setOwnerId(UserInfo.getUserId());	
                    //SAS-67  update the Opportunity Owner to the Lead Owner
                    if (ld.OwnerId != null && String.valueOf(ld.OwnerId).startsWith('005')) {
                        lc.setOwnerId(ld.OwnerId);
                    } else {
                        lc.setOwnerId(UserInfo.getUserId());
                    }
                    Database.LeadConvertResult lcResults = Database.convertLead(lc,dml);
                    Id OppId = lcResults.getOpportunityId();


/*
                    // Force Opportunity owner to current user
                    if (OppId != null) {
                        Opportunity oppOwnerFix = new Opportunity(
                            Id = OppId,
                            OwnerId = UserInfo.getUserId()
                        );
                        update oppOwnerFix;
                    }
*/                    
                    
                    if (oppId != null) {
                        Opportunity opp = new Opportunity(
                            Id = oppId,
                            RecordTypeId = socialAdSalesOppRTId,
                            StageName = 'New'
                        );
                        update opp;
                    }
 
                    Id accId2 = lcResults.getAccountId();
                    if (accId2 != null) {
                        Account accOwnerFix = new Account(
                            Id = accId2,
                            OwnerId = UserInfo.getUserId()
                        );
                        update accOwnerFix;
                    }
/*                    
                    Id conId = lcResults.getContactId();
                    if (conId != null) {
                        Contact conOwnerFix = new Contact(
                            Id = conId,
                            OwnerId = UserInfo.getUserId()
                        );
                        update conOwnerFix;
                    }
*/
                    Id accId = lcResults.getAccountId();
                    
                    //Update Account
                    if(accId != null){
                        
                    	Account acc = [select Id, Member_Number__c, Member_Prefix__c, name , Membership_Status__c from Account where Id = :accId];

                        if (acc.Member_Number__c != null && acc.Member_Number__c.contains('-')) {
                            String[] parts = acc.Member_Number__c.split('-');
                            if (parts.size() > 1) {
                                acc.Member_Prefix__c = parts[1];
                                update acc;
                            }
                        }
                        
                    }
                    
                    returnSuccess = String.valueOf(lcResults.isSuccess());
                    returnResults = String.valueOf(lcResults);
                }
                else {
                    System.debug('else< ');

                }
            }
        }
        Catch(Exception e)
        {
            returnSuccess = 'false';
            returnResults = e.getMessage();
        }
        stateAndLog.put(returnSuccess,returnResults);
        return stateAndLog;
    }
    
    /*public static void convertLeadwithOpp(Id leadId, Id oppRecType, String productName)
{

}*/
    @future
    @AuraEnabled
    public static void updateOpportunity(Id oppId) {
        // Update Opportunity
        Opportunity opp = new Opportunity(
            Id = oppId,
            StageName = 'New',            
            RecordTypeId = Schema.SObjectType.Opportunity
            .getRecordTypeInfosByDeveloperName()
            .get('Club_Venture_Membership')
            .getRecordTypeId()
        );
        
        if (oppId != null) {
            update opp;
        }
    }
    
    /*@future
    @AuraEnabled
    public static void updateOpportunityWithProductAndPayment(Id oppId, String productName){
        // Update Opportunity
        Opportunity opp = new Opportunity(
            Id = oppId,
            StageName = 'New',            
            RecordTypeId = Schema.SObjectType.Opportunity
            .getRecordTypeInfosByDeveloperName()
            .get('Marival')
            .getRecordTypeId()
        );
        
        if (oppId != null) {
            update opp;
            OpportunityLineItem oli = new OpportunityLineItem();
            oli.Quantity = 1;
            oli.OpportunityId = OppId;
            PriceBookEntry pbEntry = [SELECT Id,Product2.Id,UnitPrice FROM PricebookEntry WHERE Name =: productName LIMIT 1];
            oli.Product2Id = pbEntry.Product2.Id;
            oli.PriceBookEntryID = pbEntry.Id;
            insert oli;
            oli = [SELECT Id,product_Id__c,Quantity,OpportunityId,Product2Id,PriceBookEntryID,TotalPrice,Opportunity.Name,Product2.Name,Opportunity.Payment_RecordType_Name__c,Opportunity.Amount,Opportunity.AccountId FROM OpportunityLineItem WHERE Id = : oli.Id];
            Payment__c p = new Payment__c();
            p.Name = 'payment'+String.valueOf(System.Now());
            p.Product_Id__c = oli.product_Id__c;
            p.Opportunity__c = opp.Id;
            p.Transaction_Type__c = 'Payment';
            p.Payment_Amount__c = pbEntry.UnitPrice;
            p.Paid_On__c = System.today();
            p.Payment_Type__c = 'Payment';
            p.RecordTypeId = Schema.SObjectType.Payment__c.getRecordTypeInfosByName().get('Voucher').getRecordTypeId();
            insert p;            
        }
    }*/
 
}