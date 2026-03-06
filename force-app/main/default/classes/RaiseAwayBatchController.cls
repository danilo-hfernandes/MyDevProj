public class RaiseAwayBatchController implements Database.Batchable<sObject> {
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Id,Name,Email,Phone FROM Lead where LeadSource = \'Raise Away\' and Status = \'New\'';
        return Database.getQueryLocator(query);
    } 
    public void execute(Database.BatchableContext BC, List<Lead> scope){
        list<Id> opportunityIds = new list<Id>();
        set<Id> accountIds = new set<Id>();
        set<Id> product2Ids = new set<Id>();
        List<Contact> updateContactList = new List<Contact>();
        set<Id> cadenceContactIds = new set<Id>();
        map<String, PricebookEntry> mapProductIdvsPBEntry = new map<String, PricebookEntry>();
        List<OpportunityLineItem> oppLineItemList = new List<OpportunityLineItem>();
        List<Database.LeadConvert> massLeadConvert=new List<Database.LeadConvert>();
        for(Lead objlead : scope){
            Database.LeadConvert LeadConvert=new Database.LeadConvert();
            LeadConvert.setLeadId(objlead.Id);
            LeadConvert.setConvertedStatus('Closed Won');
            LeadConvert.setDoNotCreateOpportunity(false);
            massLeadConvert.add(LeadConvert);
        }
        if(!massLeadConvert.isEmpty()){
            //Database.DMLOptions dml = new Database.DMLOptions();
            //dml.DuplicateRuleHeader.AllowSave = true;
            List<Database.LeadConvertResult> lcr=Database.convertLead(massLeadConvert);
            system.debug('lcr:: '+lcr);
            for(Database.LeadConvertResult objConvetedlead : lcr){
                opportunityIds.add(objConvetedlead.getOpportunityId());
                accountIds.add(objConvetedlead.getAccountId());
            }
        }
        System.debug('>>opportunityIds>>>'+opportunityIds);
        System.debug('>>accountIds>>>'+accountIds);
        PriceBook2 pb2Standard = [select Id from Pricebook2 where isStandard=true];
        for(Product2 objproduct : [select Id from Product2 where Name = 'Raise Away-Grand Mayan Grand Mayan Master Room'or Name = 'Vidanta Resort Fee' limit 2]){
            product2Ids.add(objProduct.Id);
        }
        List<PricebookEntry> pbEntry = [select id,Product2Id, Product2.Name from PricebookEntry where Pricebook2Id =: pb2Standard.Id and Product2Id IN: product2Ids limit 2]; 
        
        if(pbEntry != null && pbEntry.size() == 2){
            for(PricebookEntry objpbEntry : pbEntry){
                mapProductIdvsPBEntry.put(objpbEntry.Product2Id, objpbEntry);
            }
        }
        for(Id oppIds : opportunityIds){
            for(String objProductId : mapProductIdvsPBEntry.Keyset()){
                OpportunityLineItem oppLineItem = new OpportunityLineItem();
                opplineItem.opportunityId = oppIds;
                opplineItem.Product2Id = objProductId;
                opplineItem.PricebookEntryId = mapProductIdvsPBEntry.get(objProductId).Id;
                opplineItem.Notes_Instructions__c = 'Product added by Raise Away Automation'; 
                if(mapProductIdvsPBEntry.get(objProductId).Product2.Name == 'Raise Away-Grand Mayan Grand Mayan Master Room'){
                    opplineItem.UnitPrice = 439.50;
                    opplineItem.Retail_Price__c = 439.50;
                }
                oppLineItemList.add(opplineItem);
            }
        }
        if(oppLineItemList != null && oppLineItemList.size() == 2){
            insert oppLineItemList;
        }
        List<Payment__c> paymentList = new List<Payment__c>();
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>(); 
        List<OpportunityLineItem> listOppLineItem = [select id,Product_Id__c, opportunity.Name, opportunityId, opportunity.Account.Name,Opportunity.Account.Email__c,Product2Id from OpportunityLineItem where OpportunityId IN : opportunityIds and Product2.Name = 'Raise Away-Grand Mayan Grand Mayan Master Room'];
        for(OpportunityLineItem objlineItem : listOppLineItem){
            Id recordTypeId = Schema.SObjectType.Payment__c.getRecordTypeInfosByDeveloperName().get('Voucher').getRecordTypeId();
            Payment__c paymentRec = new Payment__c();
            paymentRec.Name = objlineItem.Opportunity.Account.Name;
            paymentRec.Paid_On__c = system.today();
            paymentRec.Payment_Type__c = 'Payment';
            paymentRec.Opportunity__c = objlineItem.OpportunityId;
            paymentRec.Payment_Amount__c = 439.50;
            paymentRec.RecordTypeId = recordTypeId;
            paymentRec.Transaction_Type__c = 'Voucher';
            paymentRec.Product_Id__c = objlineItem.Product_Id__c;
            paymentRec.Opportunity_Product__c = objlineItem.Id;
            paymentRec.Opportunity_Account_Email__c = objlineItem.Opportunity.Account.Email__c;
            paymentRec.Product_Salesforce_Id__c = objlineItem.Product2Id;
            paymentList.add(paymentRec);
        }
        if(paymentList != null && paymentList.size() > 0){
            insert paymentList;
        }
        for(Opportunity objOpp : [select Id,AccountId,Account.Email__c from Opportunity where Id IN : opportunityIds]){
            List<String> emailAddress=new list<string>();
            emailAddress.add(objOpp.Account.Email__c);
            String templateBody;
            Messaging.SingleEmailMessage newEmail; 
            Messaging.SingleEmailMessage mailToBeSent = new Messaging.SingleEmailMessage(); 
            OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'vouchers@myadvantageservices.com'];
            if (owea.size() > 0 ) {
                mailToBeSent.setOrgWideEmailAddressId(owea.get(0).Id); 
            }
            List<EmailTemplate> emailTemplateList = new List<EmailTemplate>();
            emailTemplateList = [SELECT Id, Body,developername, Subject, HtmlValue, Name FROM EmailTemplate WHERE developername = 'RaiseAway_Generic_Grand_Mayan_Master_Room' limit 1];
            if(!emailTemplateList.isEmpty()) {
                newEmail = Messaging.renderStoredEmailTemplate(emailTemplateList[0].Id,objOpp.AccountId,objOpp.Id);
            }
            if(!emailAddress.isEmpty()) {
                if(newEmail != null) {
                    mailToBeSent.setSubject(newEmail.subject);
                    mailToBeSent.setHtmlBody(newEmail.HTMLBody);
                    mailToBeSent.setToAddresses(emailAddress);
                    mailToBeSent.setSaveAsActivity(true);
                    mailToBeSent.setWhatId(objOpp.AccountId);
                    emailList.add(mailToBeSent);
                }
            }
        }
        for(Contact objcon : [select id,leadassist__Use_Round_Robin__c, Assign_to_Sales_Cadence__c,Cadence_Flag__c,Match_Group_Name__c from Contact where AccountId IN : accountIds]){
            //objcon.leadassist__Use_Round_Robin__c = 'TRUE';
            //objcon.Match_Group_Name__c = 'TourGen-LuxGive';
            objcon.Assign_to_Sales_Cadence__c=true;
            objcon.Cadence_Flag__c=1;
            updateContactList.add(objcon);
            cadenceContactIds.add(objcon.Id);
        }
        if(updateContactList != null && updateContactList.size() > 0){
            updateContactList = GenericMatchGroupAssignmentHandler.assignMatchGroup(updateContactList, 'TourGen-LuxGive');
            update updateContactList;
        }
        if(cadenceContactIds != null && cadenceContactIds.size() > 0) {           
            System.enqueueJob(new GenericAssignToSalesCadence(cadenceContactIds, 'TourGen-LuxGive')); 
        }
        if(!emailList.isEmpty()){
            Messaging.sendEmail(emailList);
        }
    }
    public void finish(Database.BatchableContext BC){ 
    }
}