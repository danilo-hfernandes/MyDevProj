public class PaymentTriggerHandler {
    //HSIMU2-628 2024-01-26 Product_Salesforce_Id__c populated first
    public static void updateProductIdBasedOnSFProduct2Id(Set<Id> oppsIds, List<Payment__c> payList)
    {
        List<OpportunityLineItem> opplineList = new List<OpportunityLineItem>();
        opplineList = [select id,Product_Id__c,Product2Id,Product2.Name,Certificate_ID__c from OpportunityLineItem where OpportunityId IN : oppsIds];
        Map<Id,String> mapOfPSIdandProductId = new Map<Id,String>();
        Map<Id,Id> mapOfProductIdandOppLineItemId = new Map<Id,Id>();
        for(OpportunityLineItem oppLin : opplineList){                    
            mapOfProductIdandOppLineItemId.put(oppLin.Product2Id,oppLin.id);
            mapOfPSIdandProductId.put(oppLin.Product2Id,oppLin.Product_Id__c);                   
        }
        if(mapOfPSIdandProductId != null && mapOfPSIdandProductId.size() > 0){
            for(Payment__c py : payList){
                if(Trigger.isBefore && py.Product_Salesforce_Id__c != null && py.Product_Id__c == null && py.Product_Salesforce_Id__c == '01t3t000006O7LLAA0')
                {                    
                    py.Product_Id__c = mapOfPSIdandProductId.get(py.Product_Salesforce_Id__c);
                    py.Opportunity_Product__c = mapOfProductIdandOppLineItemId.get(py.Product_Salesforce_Id__c);
                    py.Product_Salesforce_Id__c = null;
                }
            }            
        }
    }
    public static void updateProductId(Set<String> oppIdSetNew,Set<Id> paymentid)
    {
        system.debug('----oppIdSetNew'+oppIdSetNew);
        system.debug('----paymentid'+paymentid);
        List<Payment__c> pay = new List<payment__c>();
        Map<String, String> mapProductNamevsCouponName = new Map<String, String>();
        //Add Product Name with there Coupon Name used in Certificate Object
        mapProductNamevsCouponName.put('Cancun Cards Add-On SPA', 'Cancun Card Add On SPA');
        mapProductNamevsCouponName.put('Cancun Cards Add-On', 'Cancun Card Add On');
        mapProductNamevsCouponName.put('Diamonds Intl $250 Add-On', 'Diamonds Intl $250');
        mapProductNamevsCouponName.put('Diamonds Intl $500 Add-On', 'Diamonds Intl $500');
        if(oppIdSetNew != null && oppIdSetNew.size() > 0){
            pay = [Select Id,Product_Id__c,Product_Salesforce_Id__c from Payment__c where Id IN:paymentid];
            system.debug('----pay'+pay);
            if(pay != null && pay.size() > 0){
                List<OpportunityLineItem> opplineItemsList = new List<OpportunityLineItem>();
                List<OpportunityLineItem> updateOpplineItemsList = new List<OpportunityLineItem>();
                List<OpportunityLineItem> opplineList = New List<OpportunityLineItem>();
                opplineList = [select id,Product_Id__c,Product2Id,Product2.Name,Certificate_ID__c from OpportunityLineItem where OpportunityId IN : oppIdSetNew];
                Map<String,Id> mapOfProductIdandPSId = new Map<String,Id>();
                Map<String,Id> mapOfProductIdandOppLineItemId = new Map<String,Id>();
                for(OpportunityLineItem oppLin : opplineList){
                    mapOfProductIdandPSId.put(oppLin.Product_Id__c,oppLin.Product2Id);
                    mapOfProductIdandOppLineItemId.put(oppLin.Product_Id__c,oppLin.id);
                    if(mapProductNamevsCouponName != null && mapProductNamevsCouponName.containsKey(oppLin.Product2.Name) && oppLin.Certificate_ID__c == null){
                        opplineItemsList.add(oppLin);
                    }
                }
                if(mapOfProductIdandPSId != null && mapOfProductIdandPSId.size() > 0){
                    for(Payment__c py : pay){
                        if(py.Product_Id__c != null && py.Product_Salesforce_Id__c == null){
                            if(mapOfProductIdandPSId.containsKey(py.Product_Id__c)){
                                system.debug('py.Product_Id__c'+py.Product_Id__c);
                                py.Product_Salesforce_Id__c = mapOfProductIdandPSId.get(py.Product_Id__c);
                                py.Opportunity_Product__c = mapOfProductIdandOppLineItemId.get(py.Product_Id__c);
                            }
                        }
                    }
                    update pay;
                }
                Map<String, List<Certificate__c>> mapCouponTypeVsList = new Map<String, List<Certificate__c>>();
                if(opplineItemsList != null && opplineItemsList.size() > 0){
                    List<Certificate__c> listCertificates = [select id,Certificate_ID__c,Coupon_Type__c from Certificate__c where Coupon_Type__c IN: mapProductNamevsCouponName.values() and Certificate_Redeemed__c = false Order by Certificate_ID__c ASC];
                    if(listCertificates != null && listCertificates.size() > 0){
                        for(Certificate__c objcert : listCertificates){
                            if(!mapCouponTypeVsList.containsKey(objcert.Coupon_Type__c)){
                                mapCouponTypeVsList.put(objcert.Coupon_Type__c,new List<Certificate__c>());
                            }
                            mapCouponTypeVsList.get(objcert.Coupon_Type__c).add(objcert);
                            
                        }
                        for(OpportunityLineItem opplineItem : opplineItemsList){
                            String couponName = mapProductNamevsCouponName.get(opplineItem.Product2.Name);
                            if(mapCouponTypeVsList != null && mapCouponTypeVsList.containsKey(couponName)){
                                opplineItem.Certificate_ID__c = mapCouponTypeVsList.get(couponName)[0].Certificate_ID__c;
                                updateOpplineItemsList.add(opplineItem);
                                mapCouponTypeVsList.get(couponName).remove(0); 
                            }
                        }
                    }
                }
                if(updateOpplineItemsList != null && updateOpplineItemsList.size() > 0){
                    update updateOpplineItemsList;
                }
                Set<String> oppIdSet = new Set<String>();
                List<OpportunityLineItem> oppLineItemList = new List<OpportunityLineItem>();
                List<Payment__c> paymentList = new List<Payment__c>();
                
                Map<Id, Payment__c> objMap = new Map<Id, Payment__c>([
                    SELECT Id, Product_Salesforce_Id__c, Product_Salesforce_Id__r.Name, Opportunity__c,Product_Id__c  
                    FROM Payment__c
                    WHERE (Id IN : paymentid OR Opportunity__c IN : oppIdSetNew)
                    AND Product_Salesforce_Id__c != null 
                    //AND Product_Salesforce_Id__r.Name = 'Voucher-Vidanta'
                ]);
                
                //2022-12-22 logic addded to avoid create duplicated $0 payments for Cruise Certificate Add-On and Vidanta Rebate $200 OpportunityLineItems
                Map<String,Payment__c> paymentsAssociatedToOppLineItems = new Map<String,Payment__c>();
                //2023-09-06 logic addded to post $0 for additional products if there's a Exit Product for MU Team receving 1 payment
                Map<String,Payment__c> paymentsAssociatedToExitProduct = new Map<String,Payment__c>();
                
                for(Payment__c rec: objMap.values()){
                    //add just the triggered payments
                    if(paymentid.contains(rec.Id)){
                        oppIdSet.add(rec.Opportunity__c);
                        if(rec.Product_Salesforce_Id__r.Name == 'Exit Product for MU Team'){
                            paymentsAssociatedToExitProduct.put(rec.Opportunity__c,rec);
                        }
                    }
                    //add all payments related to the opp
                    paymentsAssociatedToOppLineItems.put(rec.Opportunity__c+rec.Product_Id__c,rec);
                    System.debug('paymentsAssociatedToExitProduct = '+paymentsAssociatedToExitProduct);
                }
                system.debug('oppIdSet--0'+oppIdSet);
                system.debug('paymentsAssociatedToOppLineItems'+paymentsAssociatedToOppLineItems);
                List<String> listProductNames = new List<String>{'Usage Fee Relief','Cancun Cards Add-On','Cancun Cards Add-On SPA','Diamonds Intl $250 Add-On', 'Diamonds Intl $500 Add-On','Disney Passes','Universal Passes','Epic Passes','Luxury Excursion Bundle for Two-MX'};
                    oppLineItemList = [Select id,OpportunityId,Opportunity.AccountId,Opportunity.Account.Name,Product_Id__c,Opportunity.Account.Email__c,Product2.Name,UnitPrice,Opportunity.RecordType.DeveloperName
                                       from OpportunityLineItem 
                                       where OpportunityId IN: oppIdSet 
                                       and Product2Id != null and 
                                       ((UnitPrice = 0 and
                                         (Product2.Name = 'Vallarta Airport Transportation-GRP One Way Premium Transportation 1-5 Pax' and Opportunity.RecordType.DeveloperName = 'Marival')) or
                                        (UnitPrice = 0 and
                                         (Product2.Name = 'Vidanta Rebate $200' OR Product2.Name = 'Cruise Certificate Add-On')) or
                                        (Product2.Name = 'Guest Voucher' OR Product2.Name = 'Cruise Certificate Add-On' or Product2.Name IN :listProductNames)
                                       )];
                system.debug('oppLineItemList'+oppLineItemList);
                for(OpportunityLineItem rec : oppLineItemList){
                    system.debug('rec.OpportunityId+rec.Product_Id__c = '+rec.OpportunityId+rec.Product_Id__c);
                    system.debug('paymentsAssociatedToOppLineItems.get(rec.OpportunityId+rec.Product_Id__c) = '+paymentsAssociatedToOppLineItems.get(rec.OpportunityId+rec.Product_Id__c));
                    system.debug('paymentsAssociatedToOppLineItems.get(rec.OpportunityId+rec.Product_Id__c) = '+paymentsAssociatedToOppLineItems.get(rec.OpportunityId+rec.Product_Id__c));
                    
                    if((rec.Product2.Name == 'Luxury Excursion Bundle for Two-MX') || (( rec.Product2.Name == 'Vidanta Rebate $200' || rec.Product2.Name == 'Cruise Certificate Add-On' || listProductNames.contains(rec.Product2.Name) || (rec.Opportunity.RecordType.DeveloperName == 'Marival' && rec.Product2.Name == 'Vallarta Airport Transportation-GRP One Way Premium Transportation 1-5 Pax')) && rec.UnitPrice == 0 && paymentsAssociatedToOppLineItems.get(rec.OpportunityId+rec.Product_Id__c) == null) || 
                       ((rec.Product2.Name == 'Guest Voucher' || rec.Product2.Name == 'Cruise Certificate Add-On') && paymentsAssociatedToExitProduct.get(rec.OpportunityId) != null && paymentsAssociatedToOppLineItems.get(rec.OpportunityId+rec.Product_Id__c) == null)){
                           Id recordTypeId = Schema.SObjectType.Payment__c.getRecordTypeInfosByDeveloperName().get('Voucher').getRecordTypeId();
                           Payment__c paymentRec = new Payment__c();
                           paymentRec.Name = rec.Opportunity.Account.Name;
                           paymentRec.Paid_On__c = system.today();
                           paymentRec.Payment_Type__c = 'Payment';
                           paymentRec.Opportunity__c = rec.OpportunityId;
                           paymentRec.Payment_Amount__c = 0;
                           paymentRec.RecordTypeId = recordTypeId;
                           paymentRec.Transaction_Type__c = 'Voucher';
                           paymentRec.Product_Id__c = rec.Product_Id__c;
                           paymentRec.Opportunity_Product__c = rec.Id;
                           
                           //added 2022-09-16
                           paymentRec.Opportunity_Account_Email__c = rec.Opportunity.Account.Email__c;
                           if(paymentRec.Product_Id__c != null && paymentRec.Product_Salesforce_Id__c == null){
                               if(mapOfProductIdandPSId.containsKey(paymentRec.Product_Id__c)){
                                   paymentRec.Product_Salesforce_Id__c = mapOfProductIdandPSId.get(paymentRec.Product_Id__c);
                               }
                           }
                           paymentRec.Rebate_Payment__c = true;
                           paymentList.add(paymentRec);
                       }
                }
                
                system.debug('paymentList $0 = '+paymentList);
                if(!paymentList.isEmpty()){
                    insert paymentList;
                }
            }
        }
    }
    
    public static void flyBackPaymentCreation(Id OpportunityId, Id paymentId){
        system.debug('>>>>>>>'+OpportunityId);
        Boolean hasExitProduct = false;
        Boolean runningInASandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
        Account objacc = new Account();
        List<Opportunity> op = [select Account.Name,Account.Preferred_Language__c,OwnerId, Owner.Email,Owner.Name,StageName,RecordType.DeveloperName,AccountId,Account.Member_Anniversary_Date__c, RecordTypeId, Total_Amount__c, Account.Email__c from Opportunity Where Id=: OpportunityId and StageName != 'Closed Won' and RecordType.DeveloperName = 'Membership_Add_On' Limit 1];
        List<Payment__c> insertPaymentList = new List<Payment__c>();
        Map<String,String> exitProductId = new Map<String,String>();
        if(op != null && op.size() > 0){
            system.debug('>>>>>>>'+op);
            List<OpportunityLineItem> opplineItemlst = [select id,Product2.Name,TotalPrice, Product_ID__c,Product2Id from OpportunityLineItem where OpportunityId =: op[0].Id and (TotalPrice = 0 or Product2.Name = 'Exit Product for MU Team')];
            if(opplineItemlst != null && opplineItemlst.size() > 0){
                //Exit Product for MU Team
                
                for(OpportunityLineItem opplineitem : opplineItemlst){
                    if(opplineitem.Product2.Name == 'Exit Product for MU Team')
                        hasExitProduct = true;
                    exitProductId.put(opplineitem.Product_ID__c,'Exit Product for MU Team');
                }
                Integer paymentSize =0;
                Boolean Flag = false;
                Boolean apiCalled = false;
                Decimal totalPaymentAmount = 0;
                set<String> setProductIds = new set<String>();
                map<String,String> mapOfCreatePayments = new map<String,String>();
                map<String,Id> mapOfProdIdToOppLineItemId = new map<String,Id>();
                List<Payment__c> listPayment = [select id,Product_ID__c,Payment_Amount__c,Opportunity__r.Account.Member_Number__c,Product_Salesforce_Id__r.Name,Opportunity__r.Account.Dues_Last_Paid_Until__c from Payment__c where Opportunity__c =: op[0].Id order by Payment_Amount__c ASC];
                for(Payment__c objPayment : listPayment){
                    if(objPayment.Payment_Amount__c != null){
                        totalPaymentAmount += objPayment.Payment_Amount__c;
                    }
                    else{
                        paymentSize++;
                    }
                    system.debug('!apiCalled = '+!apiCalled);
                    system.debug('hasExitProduct = '+hasExitProduct);
                    system.debug('paymentId == objPayment.Id = '+paymentId+'='+objPayment.Id);
                    system.debug('objPayment.Product_Salesforce_Id__r.Name = '+objPayment.Product_Salesforce_Id__r.Name);
                    system.debug('objpayment.Opportunity__r.Account.Member_Number__c = '+objpayment.Opportunity__r.Account.Member_Number__c);
                    
                    if(!apiCalled && hasExitProduct && paymentId == objPayment.Id && exitProductId.get(objPayment.Product_ID__c) == 'Exit Product for MU Team' && objpayment.Opportunity__r.Account.Member_Number__c != null){
                        hasExitProduct = true;
                        
                        //replaced by HSIMU2-199 api/user/MembershipUpgradeExitSF api call
                        /*objacc.Id = op[0].AccountId;
objacc.Dues_Last_Paid_Until__c = op[0].Account.Member_Anniversary_Date__c != null ? op[0].Account.Member_Anniversary_Date__c.addYears(2): objacc.Dues_Last_Paid_Until__c;*/
                        
                        //MembershipUpgradeExitAPI('{"MemberNumber":"'+objpayment.Opportunity__r.Account.Member_Number__c+'","DuesLastPaidUntil":"'+String.valueOf(System.now().addYears(2)).replace(' ','T')+'Z"}',objPayment.Id);
                        //HSIMU2-1018 - 2024-05-30 calculate DLPU+2 years
                        MembershipUpgradeExitAPI('{"MemberNumber":"'+objpayment.Opportunity__r.Account.Member_Number__c+'","DuesLastPaidUntil":"'+String.valueOf(objpayment.Opportunity__r.Account.Dues_Last_Paid_Until__c.addYears(2)).replace(' ','T').substringBeforeLast('T')+'"',objPayment.Id);
                        
                        apiCalled = true;
                        
                    }
                    else{
                        hasExitProduct = false;
                    }
                }
                system.debug('paymentSize >>>>>'+paymentSize);
                system.debug('opplineItemlst.size()'+opplineItemlst.size());
                system.debug('op[0].StageName'+op[0].StageName);
                system.debug('op[0].Total_Amount__c'+op[0].Total_Amount__c);
                system.debug('totalPaymentAmount'+totalPaymentAmount);
                
                if(paymentSize >= opplineItemlst.size() && op[0].StageName != 'Closed Won' && op[0].Total_Amount__c == totalPaymentAmount){
                    op[0].StageName = 'Closed Won';
                    system.debug('op[0].StageName'+op[0].StageName);
                }
                else if(paymentSize != opplineItemlst.size() && op[0].Total_Amount__c == totalPaymentAmount){
                    for(Payment__c objPayment : listPayment){
                        if(objPayment.Product_ID__c != null)
                            setProductIds.add(objPayment.Product_ID__c);
                    }
                    for(OpportunityLineItem opplineitem : opplineItemlst){
                        system.debug('setProductIds>>>'+setProductIds);
                        if(!setProductIds.contains(opplineitem.Product_ID__c)){
                            system.debug('opplineitem.Product_ID__c>>>'+opplineitem.Product_ID__c);
                            //2023-05-10 It needs to post the $0 payment and flip the stage to Closed Won for the new "MTRC Vida MFP Add On with Credits" product
                            if(opplineitem.Product2.Name == 'MTRC Vida MFP Add On with Credits' || opplineitem.Product2.Name == 'Maintenance Fee Protection' || opplineitem.Product2.Name == 'Hawaii Collection Plus Flyback Extension' || opplineitem.Product2.Name == 'Hawaii Collection Plus Flyback' || opplineitem.Product2.Name == 'Select Access Resort Week Certificate Add-On' || opplineitem.Product2.Name == 'Guest Cruise Certificate Add-On'){ 
                                mapOfCreatePayments.put(opplineitem.Product_ID__c,opplineitem.Product2Id);
                                mapOfProdIdToOppLineItemId.put(opplineitem.Product_ID__c,opplineitem.Id);
                            }
                        }
                        //2023-05-10 It needs to post the $0 payment and flip the stage to Closed Won for the new "MTRC Vida MFP Add On with Credits" product
                        else if(op[0].StageName != 'Closed Won' && (opplineitem.Product2.Name == 'Exit Product for MU Team' || opplineitem.Product2.Name == 'MTRC Vida MFP Add On with Credits' || opplineitem.Product2.Name == 'Hawaii Collection Plus Flyback' )){//|| opplineitem.Product2.Name == 'Marival MU-Add On'
                            op[0].StageName = 'Closed Won';
                        }
                    }
                    system.debug('>>>mapOfCreatePayments>>>'+mapOfCreatePayments);
                    system.debug('>>>mapOfCreatePayments>>>'+flag);
                    if(!flag){
                        for(String str : mapOfCreatePayments.keyset()){
                            op[0].StageName = 'Closed Won';
                            Payment__c objpayment = new Payment__c();
                            objpayment.Paid_On__c = system.today();
                            objpayment.Opportunity__c = op[0].Id;
                            objpayment.Payment_Type__c = 'Payment';
                            objpayment.Payment_Amount__c = 0;
                            objpayment.RecordTypeId = Schema.SObjectType.Payment__c.getRecordTypeInfosByDeveloperName().get('Membership_Upgrade').getRecordTypeId();
                            objpayment.Account__c = op[0].AccountId;
                            objpayment.Product_Id__c = str;
                            objpayment.Product_Salesforce_Id__c = mapOfCreatePayments.get(str);
                            objpayment.Opportunity_Product__c = mapOfProdIdToOppLineItemId.get(str);
                            
                            insertPaymentList.add(objpayment);
                        }
                    }
                    
                }
                if(hasExitProduct){
                    OrgWideEmailAddress owea = new OrgWideEmailAddress();
                    owea = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE DisplayName='service@advantageprogram.net'];
                    List<Contact> objcon = [select id from Contact where AccountId = : op[0].AccountId limit 1];
                    List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
                    EmailTemplate emailTemp = new EmailTemplate();
                    if(op[0].Account.Preferred_Language__c == 'ENG' || op[0].Account.Preferred_Language__c == '')
                        emailTemp = [Select id, Subject, Body From EmailTemplate Where DeveloperName = 'Membership_Upgrade_Exit'];
                    else if(op[0].Account.Preferred_Language__c == 'SPA')
                        emailTemp = [Select id, Subject, Body From EmailTemplate Where DeveloperName = 'Membership_Upgrade_Exit_SPA'];
                    if(objcon != null && objcon.size() > 0){
                        System.debug('>>emailTemp>>'+emailTemp);
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        mail.setTemplateId(emailTemp.Id);
                        mail.setTargetObjectId(objcon[0].Id);
                        mail.setWhatId(paymentId);
                        mail.setOrgWideEmailAddressId(owea.Id);
                        //mail.setReplyTo(op[0].Owner.Email);
                        //mail.setSenderDisplayName(op[0].Owner.Name);
                        mail.toAddresses = new String[] {op[0].Account.Email__c};
                            emailList.add(mail);
                        system.debug('>>emailList>'+emailList);
                        if(!emailList.isEmpty() && !runningInASandbox){
                            Messaging.sendEmail(emailList);
                        }  
                    }
                    //replaced by HSIMU2-199 api/user/MembershipUpgradeExitSF api call
                    /*update objacc;*/
                }
            }
            
            update op[0]; 
            system.debug('>>>>>>insertPaymentList>>>>>>>>>'+insertPaymentList);
            if(insertPaymentList != null && insertPaymentList.size() > 0){
                insert insertPaymentList;
            }
            
        }
    }
    
    @future(callout=true)
    public static void MembershipUpgradeExitAPI(String sendJSON, Id pyId){
        
        //String gToken = DataSyncToSQL.GetToken();
        //system.debug('--gToken--'+gToken);
        Boolean runningInASandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
        String endpoint = '';
        if(runningInASandbox){
            //endpoint = 'http://hsiannualduespaymentapi-staging.azurewebsites.net/api/annualduespayment/insertpaymentwaiver';
            //endpoint = 'https://banana.advantageprogram.com/api/membership-upgrade-simple';
            endpoint = 'https://webapihsicorev2-qa.azurewebsites.net/api/user/MembershipUpgradeExitSF';
        }
        else{
            //endpoint = 'http://hsiannualduespaymentapi.azurewebsites.net/api/annualduespayment/insertpaymentwaiver';
            endpoint = 'https://webapihsicorev2.azurewebsites.net/api/user/MembershipUpgradeExitSF';
        }
        
        //String requestBody = '{"MemberNumber":"'+objpayment.Opportunity__r.Account.Member_Number__c+'","DuesLastPaidUntil":"'+System.today().addYears(2)+'"}';
        String requestBody = sendJSON;
        system.debug('---requestBody---'+requestBody);
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod('POST');
        request.setBody(requestBody);
        request.setHeader('content-type', 'application/json'); 
        //request.setHeader('Authorization', 'Bearer '+gToken);
        request.setTimeout(60000);
        system.debug('--request--'+request);
        String response = '';
        try {  
            HttpResponse httpResponse = http.send(request);
            system.debug('--httpResponse--'+httpResponse);
            if(httpResponse.getStatusCode() != 200 && httpResponse.getStatus() != 'OK'){
                response = JSON.serializePretty( JSON.deserializeUntyped(httpResponse.getBody()) );
                Map<String,Object> receivedData = (Map<String,Object>)JSON.deserializeUntyped(response);
                String message = String.valueOf(receivedData.get('message'));
                system.debug('--message-'+message);
                Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
                String[] sendingTo = new String[]{'daniel.oliveira@nerdsoft.com','victor.goncalves@nerdsoft.com'};
                    //String[] sendingTo = new String[]{'thumarmitul@gmail.com'};
                    semail.setToAddresses(sendingTo); 
                semail.setSubject('MembershipUpgradeExitAPI is failed'); 
                semail.setPlainTextBody('Message : '+message+ 'Request : '+requestBody+ ' Payment : '+pyId);
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] {semail}); 
            }
        } catch( System.Exception e) {
            System.debug('ERROR: '+ e);
        }
        
    }
    
    @future(callout=true)
    public static void hawaiiCollectionApi(Set<Id> paymentId){
        List<Payment__c> paymentList = new List<Payment__c>();
        system.debug('--paymentId--'+paymentId);
        Id hawaiiCollectionRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Hawaii_Collection_Membership').getRecordTypeId();
        paymentList = [Select Id, 
                       Opportunity__r.ContactId, 
                       Opportunity__r.Account_Affiliate_Id__c,
                       Opportunity__r.Enrollment_Fee__c,
                       Opportunity__r.Annual_Dues__c,
                       Opportunity__r.Member_Number__c,
                       Opportunity__r.Dues_Last_Paid_Until__c,
                       Opportunity__r.Account.Contact_Id__c,
                       Opportunity__r.AccountId,
                       Opportunity__r.Account.Hawaii_Collection_Affiliate_Id__c,
                       Opportunity__r.Credit_Received__c
                       from Payment__c 
                       where Opportunity__r.RecordTypeId =: hawaiiCollectionRecordTypeId
                       and Id IN: paymentId];//might have to add more values here to pick only posted payments
        system.debug('--paymentList--'+paymentList);
        if(paymentList != null && paymentList.size() > 0){
            system.debug('--paymentList--'+paymentList);
            for(Payment__c paymentRec: paymentList){
                system.debug('--paymentRec.paymentRec.Opportunity__r.Account_Affiliate_Id__c---'+paymentRec.Opportunity__r.Account_Affiliate_Id__c);
                system.debug('-paymentRec.Opportunity__r.Account.Hawaii_Collection_Affiliate_Id__c---'+paymentRec.Opportunity__r.Account.Hawaii_Collection_Affiliate_Id__c);
                
                if(paymentRec.Opportunity__r.Account_Affiliate_Id__c != paymentRec.Opportunity__r.Account.Hawaii_Collection_Affiliate_Id__c){
                    requestdataWrapper req = New requestdataWrapper();
                    req.contactId = Integer.valueof(paymentRec.Opportunity__r.Account.Contact_Id__c);
                    req.affiliateId = Integer.valueof(paymentRec.Opportunity__r.Account_Affiliate_Id__c);
                    //req.enrollmentTermYears = 1;
                    req.enrollmentFee = paymentRec.Opportunity__r.Enrollment_Fee__c;
                    //req.annualDues = paymentRec.Opportunity__r.Annual_Dues__c;
                    req.memberNumber = paymentRec.Opportunity__r.Member_Number__c;
                    req.duesLastPaidUntil = String.valueOf(system.today().addYears(1));
                    req.Credits = paymentRec.Opportunity__r.Credit_Received__c;
                    req.CreditTypeId = 5;
                    String body = JSON.serialize(req);
                    system.debug('--body--'+body);
                    HttpRequest httpRequest = new HttpRequest();  
                    httpRequest.setMethod('POST');
                    httpRequest.setHeader('Content-Type', 'application/json');
                    httpRequest.setEndpoint('https://api.advantageprogram.com/api/membership-upgrade');                    
                    
                    httpRequest.setBody(body);
                    
                    String response = '';
                    try {  
                        Http http = new Http();
                        HttpResponse httpResponse = http.send(httpRequest);
                        system.debug('--httpResponse--'+httpResponse);
                        if(httpResponse.getStatusCode() == 500 || httpResponse.getStatusCode() == 400){
                            response = JSON.serializePretty( JSON.deserializeUntyped(httpResponse.getBody()) );
                            
                            Map<String,Object> receivedData = (Map<String,Object>)JSON.deserializeUntyped(response);
                            String message = String.valueOf(receivedData.get('Message'));
                            system.debug('--message-'+message);
                            Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
                            String[] sendingTo = new String[]{'amadeu.lettieri@nerdsoft.com','netdev@nerdsoft.com','mitul.thumar@nerdsoft.com','diana.maali@nerdsoft.com'}; 
                                //String[] sendingTo = new String[]{'thumarmitul@gmail.com','mitul.thumar@nerdsoft.com'}; 
                                
                                semail.setToAddresses(sendingTo); 
                            semail.setSubject('Hawaii Collection Membership API is failed'); 
                            semail.setPlainTextBody('Message : '+message+ 'Request : '+body);
                            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {semail}); 
                        }else{
                            Account acc = [select id,Hawaii_Collection_Affiliate_Id__c from Account where Id =: paymentRec.Opportunity__r.AccountId];
                            acc.Hawaii_Collection_Affiliate_Id__c = paymentRec.Opportunity__r.Account_Affiliate_Id__c;
                            update acc;
                        }
                        
                        
                    } catch( System.Exception e) {
                        
                        System.debug('ERROR: '+ e);
                    }
                    System.debug(' ** response ** : ' + response );
                }
            }
        }
    }
    public class requestdataWrapper{
        public Integer contactId;
        public Integer affiliateId;
        //public Integer enrollmentTermYears;
        public Double enrollmentFee;
        //public Double annualDues;
        public Double Credits;
        public Integer CreditTypeId;
        public String memberNumber;
        public String duesLastPaidUntil;
    }
    
    //Annual Due Payment API
    @future(callout = true)
    public static void membershipReinstatementVoucherPaymentAPI(set<Id> paymentIds){
        set<Id> setOpportunityIds = new set<Id>();
        set<Id> setOpportunityOwnerIds = new set<Id>();
        Map<String,String> membReinstatementVoucherPayment = new Map<String,String>();
        Map<String, Integer> mapOpportunityToNumberOfYears = new Map<String, Integer>();
        Map<String, String> mapOpportunityPaymentWithCredits = new Map<String, String>();
        List<Payment__c> listPayment = [select id, Opportunity__c,Paid_On__c, Opportunity__r.Account.Contact_Id__c,Opportunity__r.Account.Member_Number__c, opportunity__r.Member_Number__c,opportunity__r.OwnerId, Payment_Amount__c, Payment_Date__c, Credit_Card_Number__c, Credit_Used__c, Authorization_Code__c, AuthorizeNet_Transaction_Id__c,Payment_Type__c,Payment_Method__c,Notes__c from Payment__c where Id IN: paymentIds];
        for(Payment__c objPayment : listPayment){
            setOpportunityIds.add(objPayment.Opportunity__c);
            setOpportunityOwnerIds.add(objPayment.opportunity__r.ownerid);            
        }
        List<OpportunityLineItem> objLineItems = new List<OpportunityLineItem>();
        
        objLineItems = [select id,OpportunityId, Quantity, Product_Id__c from OpportunityLineItem where OpportunityId IN: setOpportunityIds and Product2.Name = 'Membership Reinstatement-Voucher Bundle'];
        
        for(OpportunityLineItem objLineItem : objLineItems){
            membReinstatementVoucherPayment.put(objLineItem.OpportunityId, objLineItem.Product_Id__c);
        }
        if(objLineItems != null && objLineItems.size()>0 && !membReinstatementVoucherPayment.isEmpty() ){            
            Map<Id,User>  ownerMap = new Map<Id,User>([SELECT Id, Name FROM User WHERE Id IN :setOpportunityOwnerIds]);
            String gToken = DataSyncToSQL.GetToken();
            system.debug('--gToken--'+gToken);
            Boolean runningInASandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
            String endpoint = '';
            if(runningInASandbox){
                endpoint = 'https://hsiannualduespaymentapi-qa.azurewebsites.net/api/annualduespayment/insertpayment';
            }
            else{
                endpoint = 'https://hsiannualduespaymentapi.azurewebsites.net/api/annualduespayment/insertpayment';
            }
            //System.debug('membershipReinstatementVoucherPaymentAPI listPayment = '+listPayment);
            for(Payment__c objPayment : listPayment){
                //if(mapOpportunityToNumberOfYears.containsKey(objPayment.Opportunity__c)){
                AnnualDuePaymentDTO annualDuePaymentObj = new AnnualDuePaymentDTO();
                annualDuePaymentObj.ContactId = Integer.valueOf(objPayment.Opportunity__r.Account.Contact_Id__c);
                annualDuePaymentObj.MemberNumber = objPayment.opportunity__r.Member_Number__c != null ? objPayment.opportunity__r.Member_Number__c : objPayment.Opportunity__r.Account.Member_Number__c;
                annualDuePaymentObj.PaymentDate = String.valueOf(objPayment.Paid_On__c);
                annualDuePaymentObj.AmountPaid = objPayment.Payment_Amount__c;
                //annualDuePaymentObj.NumberOfYears = mapOpportunityToNumberOfYears.containsKey(objPayment.Opportunity__c)? mapOpportunityToNumberOfYears.get(objPayment.Opportunity__c): 0;
                annualDuePaymentObj.NumberOfYears = 1;
                //annualDuePaymentObj.CreditsUsed = objPayment.Credit_Used__c == null ? 0 : objPayment.Credit_Used__c;
                annualDuePaymentObj.CreditsUsed = 0;
                annualDuePaymentObj.CCLast4 = (objPayment.Credit_Card_Number__c != null && objPayment.Credit_Card_Number__c != '') ?String.valueOf(objPayment.Credit_Card_Number__c).right(4) : ''; 
                annualDuePaymentObj.AuthorizationCode = objPayment.Authorization_Code__c;
                annualDuePaymentObj.AuthorizeNetTransactionId = objPayment.AuthorizeNet_Transaction_Id__c;
                annualDuePaymentObj.SFOpportunityId = objPayment.Opportunity__c;
                system.debug('membershipReinstatementVoucherPaymentAPI owner name='+ownerMap.get(objPayment.opportunity__r.OwnerId).Name);
                annualDuePaymentObj.SFOpportunityOwnerName = ownerMap.get(objPayment.opportunity__r.OwnerId).Name;
                annualDuePaymentObj.SFPaymentId = objPayment.Id;
                //annualDuePaymentObj.SFCreditPaymentId = mapOpportunityPaymentWithCredits.containsKey(objPayment.Opportunity__c) ? mapOpportunityPaymentWithCredits.get(objPayment.Opportunity__c): '';
                annualDuePaymentObj.SFCreditPaymentId = '';
                
                String requestBody =JSON.serialize(annualDuePaymentObj);
                system.debug('--- membershipReinstatementVoucherPaymentAPI requestBody---'+requestBody);
                Http http = new Http();
                HttpRequest request = new HttpRequest();
                request.setEndpoint(endpoint);
                request.setMethod('POST');
                request.setBody(requestBody);
                request.setHeader('content-type', 'application/json'); 
                request.setHeader('Authorization', 'Bearer '+gToken);
                system.debug('--membershipReinstatementVoucherPaymentAPI request--'+request);
                String response = '';
                try {  
                    HttpResponse httpResponse = http.send(request);
                    system.debug('--httpResponse--'+httpResponse);
                    if(httpResponse.getStatusCode() != 200 && httpResponse.getStatus() != 'OK'){
                        response = JSON.serializePretty( JSON.deserializeUntyped(httpResponse.getBody()) );
                        Map<String,Object> receivedData = (Map<String,Object>)JSON.deserializeUntyped(response);
                        String message = String.valueOf(receivedData.get('message'));
                        system.debug('--membershipReinstatementVoucherPaymentAPI message-'+message);
                        Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
                        String[] sendingTo = new String[]{'amadeu.lettieri@nerdsoft.com','diana.maali@nerdsoft.com', UserInfo.getUserEmail()};
                            semail.setToAddresses(sendingTo); 
                        semail.setSubject('membershipReinstatementVoucher Payment API API is failed'); 
                        semail.setPlainTextBody('Message : '+message+ 'Request : '+requestBody);
                        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {semail}); 
                    }
                } catch( System.Exception e) {
                    System.debug('ERROR: '+ e);
                }
                //}
            }
        }
    }
    
    //Annual Due Payment API
    @future(callout = true)
    public static void annualDuePaymentAPI(set<Id> paymentIds){
        set<Id> setOpportunityIds = new set<Id>();
        set<Id> setOpportunityOwnerIds = new set<Id>();
        Map<String, Integer> mapOpportunityToNumberOfYears = new Map<String, Integer>();
        Map<String, String> mapOpportunityPaymentWithCredits = new Map<String, String>();
        List<Payment__c> listPayment = [select id, Opportunity__c,Paid_On__c, Opportunity__r.Account.MFP_Opportunity__c,Opportunity__r.Account.Contact_Id__c,Opportunity__r.Account.Member_Number__c, opportunity__r.Member_Number__c,opportunity__r.OwnerId, Payment_Amount__c, Payment_Date__c, Credit_Card_Number__c, Credit_Used__c, Authorization_Code__c, AuthorizeNet_Transaction_Id__c,Payment_Type__c,Payment_Method__c,Notes__c from Payment__c where (Opportunity__r.Membership_AnnualDues_GiftProduct__c = '' OR Opportunity__r.Membership_AnnualDues_GiftProduct__c = NULL) AND Id IN: paymentIds];
        for(Payment__c objPayment : listPayment){
            if(objPayment.Notes__c != 'Annual Dues Payment With Advantage Credits created by salesforce - partially paid by credits' && (objPayment.Opportunity__r.Account.MFP_Opportunity__c == null || (objPayment.Opportunity__r.Account.MFP_Opportunity__c != null && objPayment.Opportunity__r.Account.MFP_Opportunity__c != objPayment.Opportunity__c))){
                setOpportunityIds.add(objPayment.Opportunity__c);
                setOpportunityOwnerIds.add(objPayment.opportunity__r.ownerid);
            }
        }
        
        Map<Id,User>  ownerMap = new Map<Id,User>([SELECT Id, Name FROM User WHERE Id IN :setOpportunityOwnerIds]);
        //2023-04-28 updated to include Annual Dues Exit product logic
        for(OpportunityLineItem objLintItem : [select id,OpportunityId, Quantity,Product2.Name,Product2Id, (SELECT Id,Notes__c FROM Payments__r) from OpportunityLineItem where OpportunityId IN: setOpportunityIds and (Product2.Name = 'Annual Dues-Renewal' OR Product2.Name = 'Annual Dues Exit') limit 1]){
            //for(OpportunityLineItem objLintItem : [select id,OpportunityId, Quantity, (SELECT Id,Notes__c FROM Payments__r) from OpportunityLineItem where OpportunityId IN: setOpportunityIds and Product2.Name = 'Annual Dues-Renewal' limit 1]){
            
            if(objLintItem.Product2.Name == 'Annual Dues Exit'){
                mapOpportunityToNumberOfYears.put(objLintItem.OpportunityId,2);
            }
            else{
                mapOpportunityToNumberOfYears.put(objLintItem.OpportunityId, Integer.ValueOf(objLintItem.Quantity));
            }
            
            if(objLintItem.Payments__r != null && objLintItem.Payments__r.size()>0)
            {
                for(Payment__c p : objLintItem.Payments__r)
                {
                    if(p.Notes__c == 'Annual Dues Payment With Advantage Credits created by salesforce - partially paid by credits' || p.Notes__c == 'Annual Dues Payment With Advantage Credits created by salesforce - full paid by credits'){
                        mapOpportunityPaymentWithCredits.put(objLintItem.OpportunityId,p.Id);
                    }
                }
            }
        }
        String gToken = DataSyncToSQL.GetToken();
        system.debug('--gToken--'+gToken);
        Boolean runningInASandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
        String endpoint = '';
        if(runningInASandbox){
            endpoint = 'https://hsiannualduespaymentapi-qa.azurewebsites.net/api/annualduespayment/insertpayment';
        }
        else{
            endpoint = 'https://hsiannualduespaymentapi.azurewebsites.net/api/annualduespayment/insertpayment';
        }
        for(Payment__c objPayment : listPayment){
            if(mapOpportunityToNumberOfYears.containsKey(objPayment.Opportunity__c)){
                AnnualDuePaymentDTO annualDuePaymentObj = new AnnualDuePaymentDTO();
                annualDuePaymentObj.ContactId = Integer.valueOf(objPayment.Opportunity__r.Account.Contact_Id__c);
                annualDuePaymentObj.MemberNumber = objPayment.opportunity__r.Member_Number__c != null ? objPayment.opportunity__r.Member_Number__c : objPayment.Opportunity__r.Account.Member_Number__c;
                annualDuePaymentObj.PaymentDate = String.valueOf(objPayment.Paid_On__c);
                annualDuePaymentObj.AmountPaid = objPayment.Payment_Amount__c;
                annualDuePaymentObj.NumberOfYears = mapOpportunityToNumberOfYears.containsKey(objPayment.Opportunity__c)? mapOpportunityToNumberOfYears.get(objPayment.Opportunity__c): 0;
                annualDuePaymentObj.CreditsUsed = objPayment.Credit_Used__c == null ? 0 : objPayment.Credit_Used__c;
                annualDuePaymentObj.CCLast4 = (objPayment.Credit_Card_Number__c != null && objPayment.Credit_Card_Number__c != '') ?String.valueOf(objPayment.Credit_Card_Number__c).right(4) : ''; 
                annualDuePaymentObj.AuthorizationCode = objPayment.Authorization_Code__c;
                annualDuePaymentObj.AuthorizeNetTransactionId = objPayment.AuthorizeNet_Transaction_Id__c;
                annualDuePaymentObj.SFOpportunityId = objPayment.Opportunity__c;
                system.debug('294='+ownerMap.get(objPayment.opportunity__r.OwnerId).Name);
                annualDuePaymentObj.SFOpportunityOwnerName = ownerMap.get(objPayment.opportunity__r.OwnerId).Name;
                annualDuePaymentObj.SFPaymentId = objPayment.Id;
                annualDuePaymentObj.SFCreditPaymentId = mapOpportunityPaymentWithCredits.containsKey(objPayment.Opportunity__c) ? mapOpportunityPaymentWithCredits.get(objPayment.Opportunity__c): '';
                
                String requestBody =JSON.serialize(annualDuePaymentObj);
                system.debug('---requestBody---'+requestBody);
                Http http = new Http();
                HttpRequest request = new HttpRequest();
                request.setEndpoint(endpoint);
                request.setMethod('POST');
                request.setBody(requestBody);
                request.setHeader('content-type', 'application/json'); 
                request.setHeader('Authorization', 'Bearer '+gToken);
                system.debug('--request--'+request);
                String response = '';
                try {  
                    HttpResponse httpResponse = http.send(request);
                    system.debug('--httpResponse--'+httpResponse);
                    if(httpResponse.getStatusCode() != 200 && httpResponse.getStatus() != 'OK'){
                        response = JSON.serializePretty( JSON.deserializeUntyped(httpResponse.getBody()) );
                        Map<String,Object> receivedData = (Map<String,Object>)JSON.deserializeUntyped(response);
                        String message = String.valueOf(receivedData.get('message'));
                        system.debug('--message-'+message);
                        Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
                        String[] sendingTo = new String[]{'amadeu.lettieri@nerdsoft.com','diana.maali@nerdsoft.com', UserInfo.getUserEmail()};
                            semail.setToAddresses(sendingTo); 
                        semail.setSubject('Annual Dues Payment API is failed'); 
                        semail.setPlainTextBody('Message : '+message+ 'Request : '+requestBody);
                        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {semail}); 
                    }
                } catch( System.Exception e) {
                    System.debug('ERROR: '+ e);
                }
            }
        }
    }
    
    public class AnnualDuePaymentDTO
    {
        public integer ContactId {get;set;}
        public string MemberNumber {get;set;}
        public string PaymentDate {get;set;}
        public decimal AmountPaid {get;set;}
        public integer NumberOfYears {get;set;}
        public decimal CreditsUsed {get;set;}
        public string CCLast4 {get;set;}
        public string AuthorizationCode{get;set;}
        public string AuthorizeNetTransactionId{get;set;}
        public String SFOpportunityId{get;set;}
        public String SFOpportunityOwnerName{get;set;}
        public String SFPaymentId{get;set;}
        public String SFCreditPaymentId{get;set;}
    }
    
    //Annual Due Payment Waiver API
    @future(callout = true)
    public static void annualDuePaymentWaiverAPI(set<Id> paymentIds){
        set<Id> setOpportunityIds = new set<Id>();
        set<Id> setOpportunityOwnerIds = new set<Id>();
        Map<String, Integer> mapOpportunityToNumberOfYears = new Map<String, Integer>();
        Map<String, String> mapOpportunityPaymentWithCredits = new Map<String, String>();
        Map<String, String> mapAnnualDueWaiverPayment = new Map<String, String>();    
        Map<String, OpportunityLineItem> mapAnnualDueProduct = new Map<String, OpportunityLineItem>();
        List<Payment__c> listPayment = [select id, Opportunity__c,Paid_On__c,Opportunity__r.Account.MFP_Opportunity__c, Opportunity__r.Account.Contact_Id__c,Opportunity__r.Account.Member_Number__c, opportunity__r.Member_Number__c,opportunity__r.OwnerId, Payment_Amount__c, Payment_Date__c, Credit_Card_Number__c, Credit_Used__c, Authorization_Code__c, AuthorizeNet_Transaction_Id__c,Payment_Type__c,Payment_Method__c,Notes__c,Product_Id__c from Payment__c where (Opportunity__r.Membership_AnnualDues_GiftProduct__c = '' OR Opportunity__r.Membership_AnnualDues_GiftProduct__c = NULL) AND Id IN: paymentIds];
        for(Payment__c objPayment : listPayment){
            if(objPayment.Notes__c != 'Annual Dues Payment With Advantage Credits created by salesforce - partially paid by credits' && (objPayment.Opportunity__r.Account.MFP_Opportunity__c == null || (objPayment.Opportunity__r.Account.MFP_Opportunity__c != null && objPayment.Opportunity__r.Account.MFP_Opportunity__c != objPayment.Opportunity__c))){
                setOpportunityIds.add(objPayment.Opportunity__c);
                setOpportunityOwnerIds.add(objPayment.opportunity__r.ownerid);               
            }
        }
        Map<Id,User>  ownerMap = new Map<Id,User>([SELECT Id, Name FROM User WHERE Id IN :setOpportunityOwnerIds]);
        
        for(OpportunityLineItem objLineItem : [select id,OpportunityId, Quantity, Product_Id__c,Balance_to_Pay__c, (SELECT Id,Notes__c FROM Payments__r) from OpportunityLineItem where OpportunityId IN: setOpportunityIds and Product2.Name = 'Annual Dues Voucher Bundle' limit 1]){
            mapAnnualDueWaiverPayment.put(objLineItem.OpportunityId, objLineItem.Product_Id__c);
            mapOpportunityToNumberOfYears.put(objLineItem.OpportunityId, Integer.ValueOf(objLineItem.Quantity));
            mapAnnualDueProduct.put(objLineItem.OpportunityId,objLineItem);
            if(objLineItem.Payments__r != null && objLineItem.Payments__r.size()>0)
            {
                for(Payment__c p : objLineItem.Payments__r)
                {
                    if(p.Notes__c == 'Annual Dues Payment With Advantage Credits created by salesforce - partially paid by credits' || p.Notes__c == 'Annual Dues Payment With Advantage Credits created by salesforce - full paid by credits'){
                        mapOpportunityPaymentWithCredits.put(objLineItem.OpportunityId,p.Id);
                    }
                }
            }
        }
        if(mapAnnualDueWaiverPayment != null){
            String gToken = DataSyncToSQL.GetToken();
            system.debug('--gToken--'+gToken);
            Boolean runningInASandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
            String endpoint = '';
            String requestBody = '';
            for(Payment__c objPayment : listPayment){
                if(mapAnnualDueWaiverPayment.containsKey(objPayment.Opportunity__c) && mapAnnualDueWaiverPayment.get(objPayment.Opportunity__c) !=  null && mapAnnualDueWaiverPayment.get(objPayment.Opportunity__c) == objPayment.Product_Id__c){
                    
                    AnnualDuePaymentWaiverDTO annualDuePaymentWaiverObj = new AnnualDuePaymentWaiverDTO();
                    AnnualDuePaymentDTO annualDuePaymentObj = new AnnualDuePaymentDTO();
                    
                    annualDuePaymentWaiverObj.ContactId = Integer.valueOf(objPayment.Opportunity__r.Account.Contact_Id__c);
                    annualDuePaymentWaiverObj.MemberNumber = objPayment.opportunity__r.Member_Number__c != null ? objPayment.opportunity__r.Member_Number__c : objPayment.Opportunity__r.Account.Member_Number__c;
                    annualDuePaymentWaiverObj.PaymentDate = String.valueOf(objPayment.Paid_On__c);
                    annualDuePaymentWaiverObj.SFOpportunityId = objPayment.Opportunity__c;
                    annualDuePaymentWaiverObj.SFOpportunityOwnerName = ownerMap.get(objPayment.opportunity__r.OwnerId).Name;
                    annualDuePaymentWaiverObj.SFPaymentId = objPayment.Id;
                    annualDuePaymentWaiverObj.AmountPaid = objPayment.Payment_Amount__c;
                    annualDuePaymentWaiverObj.AuthorizationCode = objPayment.Authorization_Code__c;
                    annualDuePaymentWaiverObj.AuthorizeNetTransactionId = objPayment.AuthorizeNet_Transaction_Id__c;
                    annualDuePaymentWaiverObj.CCLast4 = (objPayment.Credit_Card_Number__c != null && objPayment.Credit_Card_Number__c != '') ?String.valueOf(objPayment.Credit_Card_Number__c).right(4) : '';
                    
                    annualDuePaymentObj.ContactId = Integer.valueOf(objPayment.Opportunity__r.Account.Contact_Id__c);
                    annualDuePaymentObj.MemberNumber = objPayment.opportunity__r.Member_Number__c != null ? objPayment.opportunity__r.Member_Number__c : objPayment.Opportunity__r.Account.Member_Number__c;
                    annualDuePaymentObj.PaymentDate = String.valueOf(objPayment.Paid_On__c);
                    annualDuePaymentObj.AmountPaid = objPayment.Payment_Amount__c;
                    annualDuePaymentObj.NumberOfYears = mapOpportunityToNumberOfYears.containsKey(objPayment.Opportunity__c)? mapOpportunityToNumberOfYears.get(objPayment.Opportunity__c): 0;
                    annualDuePaymentObj.CreditsUsed = objPayment.Credit_Used__c == null ? 0 : objPayment.Credit_Used__c;
                    annualDuePaymentObj.CCLast4 = (objPayment.Credit_Card_Number__c != null && objPayment.Credit_Card_Number__c != '') ?String.valueOf(objPayment.Credit_Card_Number__c).right(4) : ''; 
                    annualDuePaymentObj.AuthorizationCode = objPayment.Authorization_Code__c;
                    annualDuePaymentObj.AuthorizeNetTransactionId = objPayment.AuthorizeNet_Transaction_Id__c;
                    annualDuePaymentObj.SFOpportunityId = objPayment.Opportunity__c;                    
                    annualDuePaymentObj.SFOpportunityOwnerName = ownerMap.get(objPayment.opportunity__r.OwnerId).Name;
                    annualDuePaymentObj.SFPaymentId = objPayment.Id;
                    annualDuePaymentObj.SFCreditPaymentId = mapOpportunityPaymentWithCredits.containsKey(objPayment.Opportunity__c) ? mapOpportunityPaymentWithCredits.get(objPayment.Opportunity__c): '';
                    
                    if(runningInASandbox && (mapAnnualDueProduct.get(objPayment.Opportunity__c).Balance_to_Pay__c == 0 || mapAnnualDueProduct.get(objPayment.Opportunity__c).Balance_to_Pay__c == null) && (objPayment.Credit_Used__c == 0 || objPayment.Credit_Used__c == null)){
                        endpoint = 'https://hsiannualduespaymentapi-qa.azurewebsites.net/api/annualduespayment/insertpaymentwaiver';
                        requestBody =JSON.serialize(annualDuePaymentWaiverObj);
                        system.debug('sandbox api without credits triggered');
                    }
                    else if(runningInASandbox && ((mapAnnualDueProduct.get(objPayment.Opportunity__c).Balance_to_Pay__c != 0 && mapAnnualDueProduct.get(objPayment.Opportunity__c).Balance_to_Pay__c != null) || (objPayment.Credit_Used__c != 0 || objPayment.Credit_Used__c != null))){
                        endpoint = 'https://hsiannualduespaymentapi-qa.azurewebsites.net/api/annualduespayment/insertpayment';
                        requestBody =JSON.serialize(annualDuePaymentObj);
                        system.debug('sandbox api with credits triggered');
                    }
                    if(!runningInASandbox && (mapAnnualDueProduct.get(objPayment.Opportunity__c).Balance_to_Pay__c == 0 || mapAnnualDueProduct.get(objPayment.Opportunity__c).Balance_to_Pay__c == null) && (objPayment.Credit_Used__c == 0 || objPayment.Credit_Used__c == null)){
                        endpoint = 'https://hsiannualduespaymentapi.azurewebsites.net/api/annualduespayment/insertpaymentwaiver';
                        requestBody =JSON.serialize(annualDuePaymentWaiverObj);
                        system.debug('prod api without credits triggered');
                    }
                    else if(!runningInASandbox && ((mapAnnualDueProduct.get(objPayment.Opportunity__c).Balance_to_Pay__c != 0 && mapAnnualDueProduct.get(objPayment.Opportunity__c).Balance_to_Pay__c != null) || (objPayment.Credit_Used__c != 0 && objPayment.Credit_Used__c != null))){
                        endpoint = 'https://hsiannualduespaymentapi.azurewebsites.net/api/annualduespayment/insertpayment';
                        requestBody =JSON.serialize(annualDuePaymentObj);
                        system.debug('prod api with credits triggered');
                    }
                    
                    system.debug('---requestBody---'+requestBody);
                    Http http = new Http();
                    HttpRequest request = new HttpRequest();
                    request.setEndpoint(endpoint);
                    request.setMethod('POST');
                    request.setBody(requestBody);
                    request.setHeader('content-type', 'application/json'); 
                    request.setHeader('Authorization', 'Bearer '+gToken);
                    system.debug('--request--'+request);
                    String response = '';
                    try {  
                        HttpResponse httpResponse = http.send(request);
                        system.debug('--httpResponse--'+httpResponse);
                        if(httpResponse.getStatusCode() != 200 && httpResponse.getStatus() != 'OK'){
                            response = JSON.serializePretty( JSON.deserializeUntyped(httpResponse.getBody()) );
                            Map<String,Object> receivedData = (Map<String,Object>)JSON.deserializeUntyped(response);
                            String message = String.valueOf(receivedData.get('message'));
                            system.debug('--message-'+message);
                            Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
                            String[] sendingTo = new String[]{'amadeu.lettieri@nerdsoft.com','diana.maali@nerdsoft.com', UserInfo.getUserEmail()};
                                semail.setToAddresses(sendingTo); 
                            semail.setSubject('Annual Dues '+endpoint+' API is failed - new name = Annual Dues Voucher Bundle');
                            semail.setPlainTextBody('Message : '+message+ 'Request : '+requestBody);
                            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {semail}); 
                        }
                    } catch( System.Exception e) {
                        System.debug('ERROR: '+ e);
                    }
                }
            }
        }
    }
    
    public class AnnualDuePaymentWaiverDTO
    {
        public integer ContactId {get;set;}
        public string MemberNumber {get;set;}
        public string PaymentDate {get;set;}
        public string SFOpportunityId{get;set;}
        public string SFOpportunityOwnerName{get;set;}      
        public String SFPaymentId{get;set;}
        public decimal AmountPaid {get;set;}
        public string AuthorizationCode{get;set;}
        public string AuthorizeNetTransactionId{get;set;}
        public string CCLast4 {get;set;}
        
    }
    
    //SFX Gold Members API
    @future(callout = true)
    public static void SFXGoldMembersAPI(set<Id> paymentIds){
        system.debug('--SFXGoldMembersAPI---');
        set<Id> setOpportunityIds = new set<Id>();
        Map<String, String> mapSFXGoldMemberPayment = new Map<String, String>();
        List<Payment__c> listPayment = [select id, Opportunity__c,Paid_On__c,Product_Id__c,Opportunity__r.Account_Affiliate_Id__c, Opportunity__r.Credit_Received__c,Opportunity__r.Dues_Last_Paid_Until__c,Opportunity__r.Enrollment_Fee__c,Opportunity__r.Account.Affiliated_Id__c,Opportunity__r.Account.Contact_Id__c,Opportunity__r.Account.Member_Number__c, opportunity__r.Member_Number__c, Payment_Date__c from Payment__c where Id IN: paymentIds and opportunity__r.SFX_Diamond_Member_Enrolled__c != true];
        system.debug('--listPayment--'+listPayment);
        if(listPayment != null && listPayment.size() > 0){
            for(Payment__c objPayment : listPayment){
                if(objPayment.Opportunity__r.Account_Affiliate_Id__c == 1002275)
                    setOpportunityIds.add(objPayment.Opportunity__c);
            }
            system.debug('--setOpportunityIds--'+setOpportunityIds);
            if(setOpportunityIds != null && setOpportunityIds.size() > 0){
                for(OpportunityLineItem objLineItem : [select id,OpportunityId, Quantity, Product_Id__c from OpportunityLineItem where OpportunityId IN: setOpportunityIds and Product2.Name = 'SFX Reinstatement-Diamond' limit 1]){
                    mapSFXGoldMemberPayment.put(objLineItem.OpportunityId, objLineItem.Product_Id__c);
                }
                if(mapSFXGoldMemberPayment != null){
                    String gToken = DataSyncToSQL.GetToken();
                    system.debug('--gToken--'+gToken);
                    Boolean runningInASandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
                    String endpoint = '';
                    if(runningInASandbox){
                        //endpoint = 'http://hsiannualduespaymentapi-staging.azurewebsites.net/api/annualduespayment/insertpaymentwaiver';
                        endpoint = 'https://banana.advantageprogram.com/api/membership-upgrade-simple';
                    }
                    else{
                        //endpoint = 'http://hsiannualduespaymentapi.azurewebsites.net/api/annualduespayment/insertpaymentwaiver';
                        endpoint = 'https://api.advantageprogram.com/api/membership-upgrade-simple';
                        
                        
                    }
                    List<Payment__c> updatelistPayment = new List<Payment__c>();
                    for(Payment__c objPayment : listPayment){
                        system.debug('----objPayment-'+objPayment);
                        if(mapSFXGoldMemberPayment.containsKey(objPayment.Opportunity__c) && mapSFXGoldMemberPayment.get(objPayment.Opportunity__c) !=  null && mapSFXGoldMemberPayment.get(objPayment.Opportunity__c) == objPayment.Product_Id__c){
                            SFXGoldMembersAPIWrp annualDuePaymentObj = new SFXGoldMembersAPIWrp();
                            annualDuePaymentObj.ContactId = Integer.valueOf(objPayment.Opportunity__r.Account.Contact_Id__c);
                            //annualDuePaymentObj.AffiliateId = Integer.valueOf(objPayment.Opportunity__r.Account.Affiliated_Id__c);
                            annualDuePaymentObj.AffiliateId =1002277;
                            
                            
                            String requestBody =JSON.serialize(annualDuePaymentObj);
                            system.debug('---requestBody---'+requestBody);
                            Http http = new Http();
                            HttpRequest request = new HttpRequest();
                            request.setEndpoint(endpoint);
                            request.setMethod('POST');
                            request.setBody(requestBody);
                            request.setHeader('content-type', 'application/json'); 
                            request.setHeader('Authorization', 'Bearer '+gToken);
                            system.debug('--request--'+request);
                            String response = '';
                            try {  
                                HttpResponse httpResponse = http.send(request);
                                system.debug('--httpResponse--'+httpResponse);
                                if(httpResponse.getStatusCode() != 200 && httpResponse.getStatus() != 'OK'){
                                    response = JSON.serializePretty( JSON.deserializeUntyped(httpResponse.getBody()) );
                                    Map<String,Object> receivedData = (Map<String,Object>)JSON.deserializeUntyped(response);
                                    String message = String.valueOf(receivedData.get('message'));
                                    system.debug('--message-'+message);
                                    Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
                                    String[] sendingTo = new String[]{'amadeu.lettieri@nerdsoft.com','diana.maali@nerdsoft.com','Mitul.Thumar@nerdsoft.com', UserInfo.getUserEmail()};
                                        //String[] sendingTo = new String[]{'thumarmitul@gmail.com'};
                                        semail.setToAddresses(sendingTo); 
                                    semail.setSubject('SFX Diamond Members API is failed'); 
                                    semail.setPlainTextBody('Message : '+message+ 'Request : '+requestBody);
                                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] {semail}); 
                                }else{
                                    objPayment.SFX_Diamond_Member_Enrolled__c = true;
                                    updatelistPayment.add(objPayment);
                                }
                            } catch( System.Exception e) {
                                System.debug('ERROR: '+ e);
                            }
                        }
                    }
                    try{
                        update updatelistPayment;
                        system.debug('--updatelistPayment--'+updatelistPayment);
                    }catch(Exception e){
                        system.debug('--e---'+e);
                    }
                }
            }
        }
    }
    
    // This api is for CFD Membersite
    //2023-08-15 - Update DLPU + 1 Year for CFD Membersite
    //2023-08-24 - Filter added to exclude accounts not enrolled (master record id = null), opps created from CFD Mexico Voucher leads converted (CFD Checkout) and Affiliate Marketing (Lead Source = Offsite MX Voucher)                       
    @future(callout = true)
    public static void CFDMembersiteAPI(set<Id> paymentIds){
        system.debug('--CFDMembersiteAPI---');
        set<Id> setOpportunityIds = new set<Id>();
        Map<Id,Payment__c> singlePaymentPerOpp = new Map<Id,Payment__c>();
        Map<Id,Boolean> oppCreatedByCFDCheckout = new Map<Id,Boolean>();
        
        List<Payment__c> listPayment = [select id, Opportunity__c,Paid_On__c,Product_Id__c,Opportunity__r.Account_Affiliate_Id__c, Opportunity__r.Credit_Received__c,Opportunity__r.Dues_Last_Paid_Until__c,Opportunity__r.Enrollment_Fee__c,Opportunity__r.Account.Affiliated_Id__c,Opportunity__r.Account.Contact_Id__c,Opportunity__r.Account.Member_Number__c, opportunity__r.Member_Number__c, Payment_Date__c,opportunity__r.Payments_Count__c from Payment__c where Id IN: paymentIds and opportunity__r.Payments_Count__c = 1 ORDER BY CreatedDate DESC];
        
        /*system.debug('--listPayment CFDMembersiteAPI--'+listPayment);
system.debug('--listPayment CFDMembersiteAPI opportunity__r.Payments_Count__c = '+listPayment[0].opportunity__r.Payments_Count__c);*/
        
        if(listPayment != null && listPayment.size() > 0){  
            for(Payment__c py : listPayment){
                singlePaymentPerOpp.put(py.Opportunity__c,py);
                oppCreatedByCFDCheckout.put(py.Opportunity__c,false);
                setOpportunityIds.add(py.Opportunity__c);
            }
            
            listPayment = singlePaymentPerOpp.values();
            
            //2023-08-24 - Filter added to exclude accounts not enrolled (master record id = null), opps created from CFD Mexico Voucher leads converted (CFD Checkout) and Affiliate Marketing (Lead Source = Offsite MX Voucher)
            List<OpportunityLineItem> opplineItemlst = [select id,Product2.Name,TotalPrice,Product_ID__c,Product2Id,OpportunityId from OpportunityLineItem where OpportunityId IN : setOpportunityIds AND (Opportunity.Account.Master_Record_Id__c = null OR Product2.Name = 'CFD Mexico Voucher' OR Opportunity.LeadSource = 'Offsite MX Voucher')];
            
            if(opplineItemlst != null && opplineItemlst.size() > 0){
                for(OpportunityLineItem oli : opplineItemlst)
                {
                    oppCreatedByCFDCheckout.put(oli.OpportunityId,true);
                }
            }
            
            List<Payment__c> listPaymentFiltered = new List<Payment__c>();
            
            for(Payment__c paym : listPayment)
            {
                if(!oppCreatedByCFDCheckout.get(paym.Opportunity__c))
                {
                    listPaymentFiltered.add(paym);
                }
            }
            
            listPayment = listPaymentFiltered;
            
            system.debug('--listPayment CFDMembersiteAPI--'+listPayment);
            
            if(listPayment != null && listPayment.size() > 0){              
                
                //String gToken = DataSyncToSQL.GetToken();
                //system.debug('--gToken--'+gToken);
                Boolean runningInASandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
                String endpoint = '';
                if(runningInASandbox){
                    //endpoint = 'http://hsiannualduespaymentapi-staging.azurewebsites.net/api/annualduespayment/insertpaymentwaiver';
                    endpoint = 'https://webapihsicorev2-qa.azurewebsites.net/api/user/UpdateContactData';
                }
                else{
                    //endpoint = 'http://hsiannualduespaymentapi.azurewebsites.net/api/annualduespayment/insertpaymentwaiver';
                    endpoint = 'https://webapihsicorev2.azurewebsites.net/api/user/UpdateContactData';                
                }
                
                for(Payment__c p : listPayment){
                    Payment__c objPayment = p;
                    system.debug('----objPayment-'+objPayment);            
                    
                    String requestBody = '{"MemberNumber":"'+(objPayment.opportunity__r.Member_Number__c != null ? objPayment.opportunity__r.Member_Number__c : objPayment.Opportunity__r.Account.Member_Number__c)+'","NumberOfYearsDLPU":1}';
                    
                    system.debug('---requestBody---'+requestBody);
                    Http http = new Http();
                    HttpRequest request = new HttpRequest();
                    request.setEndpoint(endpoint);
                    request.setMethod('POST');
                    request.setBody(requestBody);
                    request.setHeader('content-type', 'application/json'); 
                    //request.setHeader('Authorization', 'Bearer '+gToken);
                    system.debug('--request--'+request);
                    String response = '';
                    try {
                        HttpResponse httpResponse = http.send(request);
                        system.debug('--httpResponse--'+httpResponse);
                        if(httpResponse.getStatusCode() != 200 && httpResponse.getStatus() != 'OK'){
                            response = JSON.serializePretty( JSON.deserializeUntyped(httpResponse.getBody()) );
                            Map<String,Object> receivedData = (Map<String,Object>)JSON.deserializeUntyped(response);
                            String message = String.valueOf(receivedData.get('message'));
                            system.debug('--message-'+message);
                            Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
                            String[] sendingTo = new String[]{};
                                if(!UserInfo.getUserEmail().containsIgnoreCase('zappier')){
                                    sendingTo = new String[]{'victor.goncalves@nerdsoft.com','daniel.oliveira@nerdsoft.com',UserInfo.getUserEmail()};                            
                                        }
                            else
                            {
                                sendingTo = new String[]{'victor.goncalves@nerdsoft.com','daniel.oliveira@nerdsoft.com'};             
                                    }
                            semail.setToAddresses(sendingTo);
                            semail.setSubject('CFDMembersiteAPI is failed'); 
                            semail.setPlainTextBody('Message : '+message+ 'Request : '+requestBody);
                            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {semail}); 
                        }
                    } catch( System.Exception e) {
                        System.debug('ERROR: '+ e);
                    }                            
                }
            }
        }
    }
    
    //Vacation VIP Voucher Upgrade Members API
    @future(callout = true)
    public static void VacationVIPVoucherUpgrade(set<Id> paymentIds){
        system.debug('--VacationVIPVoucherUpgrade---');
        set<Id> setOpportunityIds = new set<Id>();
        Map<String, String> mapVIPVUpPayment = new Map<String, String>();
        List<Payment__c> listPayment = [select id, Opportunity__c,Opportunity__r.Account.Master_Record_Id__c,Opportunity__r.AccountId,opportunity__r.Vacation_VIP_Voucher_Upgrade__c,Paid_On__c,Product_Id__c,Opportunity__r.Account_Affiliate_Id__c, Opportunity__r.Credit_Received__c,Opportunity__r.Dues_Last_Paid_Until__c,Opportunity__r.Enrollment_Fee__c,Opportunity__r.Account.Affiliated_Id__c,Opportunity__r.Account.Contact_Id__c,Opportunity__r.Account.Member_Number__c, opportunity__r.Member_Number__c, Payment_Date__c from Payment__c where Id IN: paymentIds and opportunity__r.Vacation_VIP_Voucher_Upgrade__c != true];
        List<Account> accList = new List<Account>();
        Set<Id> accIds = new Set<Id>();
        system.debug('--listPayment--'+listPayment);
        if(listPayment != null && listPayment.size() > 0){
            for(Payment__c objPayment : listPayment){
                system.debug('-objPayment.Opportunity__r.Account_Affiliate_Id__c-'+objPayment.Opportunity__r.Account_Affiliate_Id__c);
                if(objPayment.Opportunity__r.Account_Affiliate_Id__c == 1002336){
                    setOpportunityIds.add(objPayment.Opportunity__c);
                }
                else if(objPayment.Opportunity__r.Account_Affiliate_Id__c == 1002348 && (objPayment.Opportunity__r.Account.Master_Record_Id__c == null || objPayment.Opportunity__r.Account.Master_Record_Id__c == ''))
                {
                    accIds.add(objPayment.Opportunity__r.AccountId);
                }
            }
            system.debug('--setOpportunityIds--'+setOpportunityIds);
            if(setOpportunityIds != null && setOpportunityIds.size() > 0){
                for(OpportunityLineItem objLineItem : [select id,OpportunityId, Quantity, Product_Id__c from OpportunityLineItem where OpportunityId IN: setOpportunityIds and (Product2.Name = 'Vacation VIP Membership Upgrade'  or Product2.Name = 'Flex Stays Vacation VIP Membership Upgrade 8/7' or Product2.Name = 'Flex Stays Vacation VIP Membership Upgrade 4/3') limit 1]){
                    mapVIPVUpPayment.put(objLineItem.OpportunityId, objLineItem.Product_Id__c);
                }
                if(mapVIPVUpPayment != null){
                    String gToken = DataSyncToSQL.GetToken();
                    system.debug('--gToken--'+gToken);
                    Boolean runningInASandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
                    String endpoint = '';
                    if(runningInASandbox){
                        //endpoint = 'http://hsiannualduespaymentapi-staging.azurewebsites.net/api/annualduespayment/insertpaymentwaiver';
                        //endpoint = 'https://banana.advantageprogram.com/api/membership-upgrade-simple';
                        endpoint = ' https://webapihsicorev2-qa.azurewebsites.net/api/membership-upgrade-simple';
                    }
                    else{
                        //endpoint = 'http://hsiannualduespaymentapi.azurewebsites.net/api/annualduespayment/insertpaymentwaiver';
                        endpoint = 'https://api.advantageprogram.com/api/membership-upgrade-simple';
                        
                        
                    }
                    List<Payment__c> updatelistPayment = new List<Payment__c>();
                    for(Payment__c objPayment : listPayment){
                        system.debug('----objPayment-'+objPayment);
                        if(mapVIPVUpPayment.containsKey(objPayment.Opportunity__c) && mapVIPVUpPayment.get(objPayment.Opportunity__c) !=  null && mapVIPVUpPayment.get(objPayment.Opportunity__c) == objPayment.Product_Id__c){
                            SFXGoldMembersAPIWrp annualDuePaymentObj = new SFXGoldMembersAPIWrp();
                            annualDuePaymentObj.ContactId = Integer.valueOf(objPayment.Opportunity__r.Account.Contact_Id__c);
                            //annualDuePaymentObj.AffiliateId = Integer.valueOf(objPayment.Opportunity__r.Account.Affiliated_Id__c);
                            annualDuePaymentObj.AffiliateId =1002348;
                            
                            String requestBody =JSON.serialize(annualDuePaymentObj);
                            system.debug('---requestBody---'+requestBody);
                            Http http = new Http();
                            HttpRequest request = new HttpRequest();
                            request.setEndpoint(endpoint);
                            request.setMethod('POST');
                            request.setBody(requestBody);
                            request.setHeader('content-type', 'application/json'); 
                            request.setHeader('Authorization', 'Bearer '+gToken);
                            request.setTimeout(60000);
                            system.debug('--request--'+request);
                            String response = '';
                            try {  
                                HttpResponse httpResponse = http.send(request);
                                system.debug('--httpResponse--'+httpResponse);
                                if(httpResponse.getStatusCode() != 200 && httpResponse.getStatus() != 'OK'){
                                    response = JSON.serializePretty( JSON.deserializeUntyped(httpResponse.getBody()) );
                                    Map<String,Object> receivedData = (Map<String,Object>)JSON.deserializeUntyped(response);
                                    String message = String.valueOf(receivedData.get('message'));
                                    system.debug('--message-'+message);
                                    Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
                                    String[] sendingTo = new String[]{'amadeu.lettieri@nerdsoft.com','diana.maali@nerdsoft.com','Mitul.Thumar@nerdsoft.com', UserInfo.getUserEmail()};
                                        //String[] sendingTo = new String[]{'thumarmitul@gmail.com'};
                                        semail.setToAddresses(sendingTo); 
                                    semail.setSubject('Vacation VIP Membership Upgrade API is failed'); 
                                    semail.setPlainTextBody('Message : '+message+ 'Request : '+requestBody+ ' Acccount :' +URL.getSalesforceBaseUrl().toExternalForm() + '/'+objPayment.Opportunity__r.AccountId+ ' Opportunity :'+URL.getSalesforceBaseUrl().toExternalForm() +'/'+objPayment.Opportunity__c);
                                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] {semail}); 
                                }else{
                                    objPayment.Vacation_VIP_Voucher_Upgrade__c = true;
                                    updatelistPayment.add(objPayment);
                                }
                            } catch( System.Exception e) {
                                System.debug('ERROR: '+ e);
                            }
                        }
                    }
                    try{
                        update updatelistPayment;
                        system.debug('--updatelistPayment--'+updatelistPayment);
                    }catch(Exception e){
                        system.debug('--e---'+e);
                    }
                }
            }
            system.debug('accIds : '+accIds);
            if(accIds.size()>0 && accIds != null)
            {
                accList = [SELECT Id,Master_Record_Id__c,Affiliated_Id__c,Affiliate_Name__c,BillingCity,BillingState,BillingCountry,Email__c,BillingPostalCode,First_Name__c,Last_Name__c,Phone,BillingStreet,(SELECT Id FROM HSI_Enrollment_Queues__r) FROM Account WHERE Id IN : accIds AND (Master_Record_Id__c = NULL OR Master_Record_Id__c = '')];
                List<Account> finalAccList = new List<Account>();
                for(Account accCheck : accList)
                {
                    if(!(accCheck.HSI_Enrollment_Queues__r != null && accCheck.HSI_Enrollment_Queues__r.size()>0))
                    {
                        finalAccList.add(accCheck);
                    }
                }
                if(finalAccList.size()>0 && finalAccList != null){
                    AccountTriggerHelper acchelp = new AccountTriggerHelper();
                    acchelp.CreateHSIEnrollment(accList);
                }
            }
        }
    }
    
    //Annual Due Deleted Payment API
    @future(callout = true)
    public static void annualDuesDeletedPaymentAPI(set<Id> paymentIds){
        set<Id> setOpportunityIds = new set<Id>();
        set<Id> setOpportunityOwnerIds = new set<Id>();
        Map<String, Integer> mapOpportunityToNumberOfYears = new Map<String, Integer>();
        List<Payment__c> listPayment = [select id, Opportunity__c,Paid_On__c, Opportunity__r.Account.Contact_Id__c,Opportunity__r.Account.Member_Number__c, opportunity__r.Member_Number__c,opportunity__r.OwnerId, Payment_Amount__c, Payment_Date__c, Credit_Card_Number__c, Credit_Used__c, Authorization_Code__c, AuthorizeNet_Transaction_Id__c,Payment_Type__c,Payment_Method__c,Notes__c from Payment__c where Id IN: paymentIds AND IsDeleted = true ALL ROWS];
        system.debug('listPayment deleted = '+listPayment);
        
        Boolean runningInASandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
        String endpoint = '';
        if(runningInASandbox){
            endpoint = 'https://hsiannualduespaymentapi-qa.azurewebsites.net/api/annualduespayment/deletepayment';
        }
        else{            
            endpoint = 'https://hsiannualduespaymentapi.azurewebsites.net/api/annualduespayment/deletepayment';
        }        
        
        if(listPayment.size()>0 && listPayment != null){
            String gToken = DataSyncToSQL.GetToken();
            system.debug('--gToken--'+gToken);
            for(Payment__c objPayment : listPayment){
                //String requestBody = JSON.serialize(annualDuePaymentObj);
                String requestBody = '{"MemberNumber":"'+(objPayment.opportunity__r.Member_Number__c != null ? objPayment.opportunity__r.Member_Number__c : objPayment.Opportunity__r.Account.Member_Number__c)+'","contactid":"'+(Integer.valueOf(objPayment.Opportunity__r.Account.Contact_Id__c))+'","SFPaymentId":"'+objPayment.Id+'"}';
                system.debug('---requestBody---'+requestBody);
                Http http = new Http();
                HttpRequest request = new HttpRequest();
                request.setEndpoint(endpoint);
                request.setMethod('POST');
                request.setBody(requestBody);
                request.setHeader('content-type', 'application/json');
                request.setHeader('Authorization', 'Bearer '+gToken);
                system.debug('--request--'+request);
                String response = '';
                try {  
                    HttpResponse httpResponse = http.send(request);
                    system.debug('--httpResponse--'+httpResponse);
                    if(httpResponse.getStatusCode() != 200 && httpResponse.getStatus() != 'OK'){
                        response = JSON.serializePretty( JSON.deserializeUntyped(httpResponse.getBody()) );
                        Map<String,Object> receivedData = (Map<String,Object>)JSON.deserializeUntyped(response);
                        String message = String.valueOf(receivedData.get('message'));
                        system.debug('--message-'+message);
                        Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
                        String[] sendingTo = new String[]{'victor.goncalves@nerdsoft.com','daniel.oliveira@nerdsoft.com', UserInfo.getUserEmail()};
                            semail.setToAddresses(sendingTo);
                        semail.setSubject('annualDues Delete Payment API is failed');
                        semail.setPlainTextBody('Message : '+message+ 'Request : '+requestBody);
                        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {semail}); 
                    }
                } catch( System.Exception e) {
                    System.debug('ERROR: '+ e);
                }            
            }
        }
    }
    public class SFXGoldMembersAPIWrp
    {
        public integer ContactId {get;set;}
        public integer AffiliateId {get;set;}
    }
    //Earned Credits
    @future(callout = true)
    public static void updateMemberCreditAPI(set<Id> paymentIds){
        List<Payment__c> listPayment = [select id, Opportunity__c,Paid_On__c,CreatedBy.Name,LastModifiedBy.Name,Opportunity_Product__r.Travel_Apply_Credits__c,Opportunity__r.Account.Member_Number__c, opportunity__r.Member_Number__c,opportunity__r.OwnerId, Payment_Amount__c, Payment_Date__c, Credit_Card_Number__c, Credit_Used__c, Authorization_Code__c, AuthorizeNet_Transaction_Id__c,Payment_Type__c,Payment_Method__c,Notes__c from Payment__c where Id IN: paymentIds and Product_Name__c = 'Travel Credits'];
        system.debug('listPayment deleted = '+listPayment);
        
        Boolean runningInASandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
        String endpoint = '';
        if(runningInASandbox){
            endpoint = 'https://webapihsicorev2-qa.azurewebsites.net/api/GetAdvantageCredits/EarnCreditsContacts';
        }
        else{            
            endpoint = 'https://webapihsicorev2.azurewebsites.net/api/GetAdvantageCredits/EarnCreditsContacts';
        }        
        
        if(listPayment.size()>0 && listPayment != null){
            String gToken = DataSyncToSQL.GetToken();
            system.debug('--gToken--'+gToken);
            for(Payment__c objPayment : listPayment){
                TransactionWrapper objwrapper = new TransactionWrapper();
                objwrapper.MemberNumber = objPayment.Opportunity__r.Account.Member_Number__c;
                objwrapper.CreditEarned = (objPayment.Opportunity_Product__r.Travel_Apply_Credits__c != null && objPayment.Opportunity_Product__r.Travel_Apply_Credits__c != 0) ? objPayment.Opportunity_Product__r.Travel_Apply_Credits__c : 0;
                objwrapper.TransactionDescription = 'Travel Credits from Salesforce OppId:'+objPayment.Opportunity__c;
                objwrapper.CreatedBy = objPayment.CreatedBy.Name;
                objwrapper.SFOpportunityId = objPayment.Opportunity__c;
                objwrapper.SFPaymentId =objPayment.Id;
                objwrapper.ModifiedBy = objPayment.LastModifiedBy.Name;
                objwrapper.TransactionTypeId ='78';
                String requestBody =JSON.serialize(objwrapper);
                Http http = new Http();
                HttpRequest request = new HttpRequest();
                request.setEndpoint(endpoint);
                request.setMethod('POST');
                request.setBody(requestBody);
                request.setHeader('content-type', 'application/json');
                request.setHeader('Authorization', 'Bearer '+gToken);
                system.debug('--request--'+request);
                String response = '';
                try {  
                    HttpResponse httpResponse = http.send(request);
                    system.debug('--httpResponse--'+httpResponse);
                    if(httpResponse.getStatusCode() != 201 && httpResponse.getStatus() != 'Created'){
                        response = JSON.serializePretty( JSON.deserializeUntyped(httpResponse.getBody()) );
                        Map<String,Object> receivedData = (Map<String,Object>)JSON.deserializeUntyped(response);
                        String message = String.valueOf(receivedData.get('message'));
                        system.debug('--message-'+message);
                        Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
                        String[] sendingTo = new String[]{'shivani.chauhan@nerdsoft.com', 'danilo.fernandes@nerdsoft.com','daniel.oliveira@nerdsoft.com','cicero.schoeps@nerdsoft.com'};//UserInfo.getUserEmail()};
                            semail.setToAddresses(sendingTo);
                        semail.setSubject('Earned Credit API is failed');
                        semail.setPlainTextBody('Message : '+message+ 'Request : '+requestBody);
                        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {semail}); 
                    }
                } catch( System.Exception e) {
                    System.debug('ERROR: '+ e);
                }            

                //TGR-833
                insertNote(objPayment.Id,requestBody,response);
                
            }
        }
    }

    //TGR-833
    // Create ContentNote attached to the record
    private static void insertNote(Id recordId,String requestBody,String response) {
        try {
            // Create the ContentNote
            ContentNote note = new ContentNote();
            note.Title = 'Update Member Credit API';
            note.Content = Blob.valueOf(
                'requestBody: ' + requestBody + 
                ' response: ' + response + 
                ' Request sent on ' +
                String.valueOf(Datetime.now().format('yyyy-MM-dd HH:mm:ss z'))
            );
            insert note;
    
            // Link the ContentNote to the parent record
            ContentDocumentLink link = new ContentDocumentLink();
            link.ContentDocumentId = note.Id;
            link.LinkedEntityId = recordId;
            link.ShareType = 'V'; // Viewer
            link.Visibility = 'AllUsers';
            insert link;
    
            System.debug('ContentNote created and linked successfully for record ' + recordId);
        } catch (Exception e) {
            System.debug('Error inserting ContentNote: ' + e.getMessage());
        }
    } 
    
    public class TransactionWrapper {
        // Declare the variables as per the provided parameters
        public String MemberNumber { get; set; }
        public Decimal CreditEarned { get; set; }
        public String TransactionDescription { get; set; }
        public String CreatedBy { get; set; }
        public String SFOpportunityId { get; set; }
        public String SFPaymentId { get; set; }
        public String ModifiedBy { get; set; }
        public String TransactionTypeId { get; set; }
        
        // Constructor to initialize the wrapper with values
        public TransactionWrapper(){
        }
    }
    //2023-09-12 - PA-31 - ProfitAgility Agency MX Vouchers - SF    
    public static void sendProfitAgilityAgencyMXVoucherContactsToSRRAndCadence(set<Id> oppIds){
        List<Contact> mainRelatedContacts = [SELECT Id FROM Contact WHERE Is_Main_Contact__c = TRUE AND AccountId IN (SELECT AccountId FROM Opportunity WHERE Id IN : oppIds)];
        if(mainRelatedContacts != null && mainRelatedContacts.size()>0)
        {

            for(Contact con : mainRelatedContacts)

            {

                con.Match_Group_Name__c = 'TourGen-ProfitAgility Agency';

                con.leadassist__Use_Round_Robin__c = 'TRUE';

            }
            update mainRelatedContacts;
        } 
    }
}