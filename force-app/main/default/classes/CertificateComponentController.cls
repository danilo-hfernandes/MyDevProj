public with sharing class CertificateComponentController {
    @AuraEnabled
    public static List<Certificate__c> validateCertificateId(String certificateId){
        try {
            List<Certificate__c> listCertificate = [select Id, Certificate_ID__c,Certificate_Redeemed__c,Expiration_Date__c from Certificate__c where Certificate_ID__c =: certificateId];
            if(listCertificate != null && listCertificate.size() > 0){
                return listCertificate;
            }
            else 
                return null;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static String createOpportunity(String accountId, String productType, String certificateSFId){
        try {
            String productName='';
            Id recordTypeId;
            Certificate__c objcertificate = [select id, Coupon_Type__c,Certificate_Redeemed__c,Certificate_ID__c from Certificate__c where Id = : certificateSFId limit 1];
            system.debug('>>>objcertificate>>>'+objcertificate);
            system.debug('>>>objcertificate.Coupon_Type__c>>>'+objcertificate.Coupon_Type__c);
            if(objcertificate != null){
				if(objcertificate.Coupon_Type__c == 'Hawaii Collection Plus Extension Certificates'){
                	productName = 'Hawaii Collection Plus TC';//'Hawaii Collection Plus Flyback';//'Hawaii Collection Plus Flyback Extension';
                    recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Membership_Add_On').getRecordTypeId();
                }
                else if(objcertificate.Coupon_Type__c == 'Hawaii Collection Plus Certificates'){
                    productName = 'Hawaii Collection Plus TC';//'Hawaii Collection Plus Flyback';
                    recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Membership_Add_On').getRecordTypeId();
                }
                else if(objcertificate.Coupon_Type__c == 'HC MX National SPA' || objcertificate.Coupon_Type__c == 'CG MX National SPA' || objcertificate.Coupon_Type__c == 'CG'){
                    productName = 'Advantage Getaway Voucher';
                    recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Travel').getRecordTypeId();
                }
                //TGR-470
                else if(objcertificate.Coupon_Type__c == 'HCP RW Cert' ){
                    productName = 'Hawaii Collection Plus RW Cert';
            		recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Membership_Add_On').getRecordTypeId();  
                }
                //2025-10-10 RC122
                else if(objcertificate.Coupon_Type__c == 'Usage Fee Relief' ){
                    productName = 'Usage Fee Relief';
                    recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Membership_Add_On').getRecordTypeId();
                }
            }
            system.debug('>>>productName>>>>'+productName);
            PriceBook2 pb2Standard = [select Id from Pricebook2 where isStandard=true];
            Product2 objProduct = [select id from Product2 where Name =: productName limit 1];
            List<PricebookEntry> pbEntry = [select id from PricebookEntry where Pricebook2Id =: pb2Standard.Id and Product2Id =: objProduct.Id limit 1];

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
            List<Account> lstAcc = [select id,Name, Email__c,Preferred_Language__c from Account where Id = : accountId];
            List<Opportunity> lstOpp = [select id,AccountId, Account.Email__c,OwnerId from Opportunity where RecordTypeId =: recordTypeId and AccountId =: accountId and (StageName != 'Closed Won' and IsClosed = false) order by createdDate Desc limit 1];
            System.debug('>>>>objpbEntry>>>'+objpbEntry);
            Opportunity opp = new Opportunity();

            if(objcertificate.Coupon_Type__c == 'HCP RW Cert' ){ //TGR-470 
                if(lstOpp != null && lstOpp.size() != 0 ){ 
                    Opportunity opp2 = new Opportunity();
					opp2 = lstOpp[0];
                    List<OpportunityLineItem> opplineItemlst = [select id from OpportunityLineItem where OpportunityId =: opp2.Id and Product2.Name =: productName limit 1];
                    if(opplineItemlst != null && opplineItemlst.size() > 0){
                        return 'You have already redeemed a Certificate for this Product';
                    }
                    else{
                        opp.Name = 'Membership Add-On';
                        opp.StageName = 'New';
                        opp.CloseDate = System.Today();
                        opp.RecordTypeId = recordTypeId;
                        opp.AccountId = accountId;
                        opp.Pricebook2Id = pb2Standard.Id;
                        insert opp;
                    }

                }
                else{
                        opp.Name = 'Membership Add-On';
                        opp.StageName = 'New';
                        opp.CloseDate = System.Today();
                        opp.RecordTypeId = recordTypeId;
                        opp.AccountId = accountId;
                        opp.Pricebook2Id = pb2Standard.Id;
                        insert opp;
                }

            }
            else{
                if(lstOpp != null && lstOpp.size() != 0 ){ //470     && objcertificate.Coupon_Type__c != 'HCP RW Cert'
                    opp = lstOpp[0];
                    List<OpportunityLineItem> opplineItemlst = [select id from OpportunityLineItem where OpportunityId =: opp.Id and Product2.Name =: productName limit 1];
                    if(opplineItemlst != null && opplineItemlst.size() > 0){
                        return 'You have already redeemed a Certificate for this Product';
                    }
                }
                else{
                    opp.Name = 'Membership Add-On';
                    opp.StageName = 'New';
                    opp.CloseDate = System.Today();
                    opp.RecordTypeId = recordTypeId;
                    opp.AccountId = accountId;
                    opp.Pricebook2Id = pb2Standard.Id;
                    insert opp;
                    System.debug('>>>>created new opp>>>'+opp);
                }
            }

            System.debug('>>>>opp>>>'+opp);
            
            //Create OpportunityLineItem
            OpportunityLineItem opplineItem = new OpportunityLineItem();
            opplineItem.opportunityId = opp.Id;
            opplineItem.Product2Id = objProduct.Id;
            opplineItem.PricebookEntryId = objpbEntry.Id;
            opplineItem.Quantity = 1;
            opplineItem.Certificate_Product__c = objcertificate.Id;
            opplineItem.Certificate_ID__c = objcertificate.Certificate_ID__c;
            insert opplineItem;
			
            if(productName == 'Advantage Getaway Voucher'){
                OpportunityLineItem oppline = [select id,Product_Id__c from OpportunityLineItem where Id =: opplineItem.Id];
                Id payRecordTypeId = Schema.SObjectType.Payment__c.getRecordTypeInfosByDeveloperName().get('Travel').getRecordTypeId();
                Payment__c paymentRec = new Payment__c();
                paymentRec.Name =lstAcc[0].Name;
                paymentRec.Paid_On__c = system.today();
                paymentRec.Payment_Type__c = 'Payment';
                paymentRec.Opportunity__c = opp.Id;
                paymentRec.Payment_Amount__c = 0;
                paymentRec.RecordTypeId = payRecordTypeId;
                //paymentRec.Transaction_Type__c = 'Travel';
                paymentRec.Product_Id__c = oppline.Product_Id__c;
                paymentRec.Opportunity_Product__c = oppline.Id;
                paymentRec.Opportunity_Account_Email__c = lstAcc[0].email__c;

                insert paymentRec;

                opp.StageName = 'Closed Booked';
                update opp;
                list<Task> tasklist = new list<Task>();
                List<OrgWideEmailAddress> orgList = new List<OrgWideEmailAddress>();
                orgList = [select Id from OrgWideEmailAddress where Address = 'certificates@myadvantageservices.com'];
                List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>(); 
                List<EmailTemplate> emailTemplateList = new List<EmailTemplate>();
                if( lstAcc[0].Preferred_Language__c == 'SPA'){
                    emailTemplateList = [SELECT Id, Body,developername, Subject, HtmlValue, Name
                                 FROM EmailTemplate
                                 WHERE developername = 'Advantage_Getaway_Voucher_SPA'];
                }
                else{
                emailTemplateList = [SELECT Id, Body,developername, Subject, HtmlValue, Name
                                 FROM EmailTemplate
                                 WHERE developername = 'Advantage_Getaway_Voucher'];
                }
                List<String> emailAddress=new list<string>();
                emailAddress.add(lstAcc[0].email__c);
                string whoid=opp.Id;
                string whatid=opp.AccountId;
                String templateBody;
                Messaging.SingleEmailMessage newEmail; 
                Messaging.SingleEmailMessage mailToBeSent = new Messaging.SingleEmailMessage(); 
                if(!emailTemplateList.isEmpty()) {
                    newEmail = Messaging.renderStoredEmailTemplate(emailTemplateList[0].id,whoId,whatId);
                }
                if(!emailAddress.isEmpty()) {
                    if(newEmail != null) {
                        if ( orgList.size() > 0 ) {
                            mailToBeSent.setOrgWideEmailAddressId(orgList[0].Id);
                        }
                        mailToBeSent.setSubject(newEmail.subject);
                        mailToBeSent.setHtmlBody(newEmail.HTMLBody);
                        mailToBeSent.setToAddresses(emailAddress);
                        emailList.add(mailToBeSent);
                    }
                }
                if(!emailList.isEmpty()){
                    system.debug('>>>>Send email');
                    Messaging.sendEmail(emailList);
                    Task objtask = new Task();
                    objtask.Subject = 'Email Sent - Advantage Getaway Voucher';
                    objtask.ActivityDate = System.today();
                    objtask.WhatId = opp.Id;
                    objtask.Status = 'Completed';
                    objtask.OwnerId = UserInfo.getUserId();
                    tasklist.add(objtask);
                    if(tasklist != null && tasklist.size() > 0){
                        insert tasklist; 
                    }
                }
                integer i=0;
                List<Redemption__c> lstRedemption = new List<Redemption__c>();
                while(i<5){
                    Redemption__c objRedem = new Redemption__c();
                    objRedem.Opportunity__c = opp.Id;
                    //objRedem.Status__c = 'Reservation Pending';
                    objRedem.Opportunity_Product__c = opplineItem.Id;
                    
                    lstRedemption.add(objRedem);
                    i++;
                }
                if(lstRedemption != null && lstRedemption.size() > 0){
                    insert lstRedemption;
                }
            }
            else if(productName == 'Hawaii Collection Plus RW Cert'){  //TGR-470
                OpportunityLineItem oppline = [select id,Product_Id__c from OpportunityLineItem where Id =: opplineItem.Id];
                Id payRecordTypeId = Schema.SObjectType.Payment__c.getRecordTypeInfosByDeveloperName().get('Voucher').getRecordTypeId();  //<<<
                Payment__c paymentRec = new Payment__c();
                paymentRec.Name =lstAcc[0].Name;
                paymentRec.Paid_On__c = system.today();
                paymentRec.Payment_Type__c = 'Payment';
                paymentRec.Opportunity__c = opp.Id;
                paymentRec.Payment_Amount__c = 0;
                paymentRec.RecordTypeId = payRecordTypeId;
                paymentRec.Product_Id__c = oppline.Product_Id__c;
                paymentRec.Opportunity_Product__c = oppline.Id;
                paymentRec.Opportunity_Account_Email__c = lstAcc[0].email__c;
                paymentRec.Transaction_Type__c = 'Payment';
                
                insert paymentRec;

                opp.StageName = 'Closed Booked';
                update opp;

            }
            
                
            //Update Certificate Record 
            objCertificate.Certificate_Redeemed__c = true;
            update objCertificate;

            if(opp != null && opplineItem != null){
                return 'Success';
            }
            else {
                return 'Error';
            }
        } catch (Exception e) {
            //throw new AuraHandledException(e.getMessage());
            
            System.debug('>>> ERROR MESSAGE: ' + e.getMessage());
            System.debug('>>> ERROR STACKTRACE: ' + e.getStackTraceString());
            throw new AuraHandledException('An error occurred: ' + e.getMessage());
            
        }
    }
}