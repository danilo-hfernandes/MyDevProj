public class CouponTriggerHandler {
    public static void createAccountOppAndRelatedRecords(set<Id> couponIdSet){
        if(couponIdSet != null && couponIdSet.size() > 0){
            List<Coupon__c> couponList = [select id,Coupon_Code__c,Name__c,Email__c,Phone_Number__c,State__c,Street__c,Zip_Code__c,Country__c,City__c 
                                          from Coupon__c 
                                          where Id IN: couponIdSet];
            if(couponList.size() > 0){
                for(Coupon__c cup : couponList){
                    system.debug('--cup--'+cup);
                    try{
                        // TODO
                        // Coupon code and coupon lookup - Mapping and make as read only
                        
                        Account acc = new Account();
                        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Advantage Program (Inc Holiday Systems)').getRecordTypeId();
                        acc.Name = cup.Name__c;
                        acc.Phone = cup.Phone_Number__c;
                        acc.Email__c = cup.Email__c;
                        acc.BillingStreet = cup.Street__c;
                        acc.BillingCity = cup.City__c;
                        acc.BillingPostalCode = cup.Zip_Code__c;
                        acc.BillingState = cup.State__c;
                        acc.BillingCountry = cup.Country__c;
                        acc.Affiliate_Name__c = 'CFD Bulk Coupon Sales';
                        acc.Affiliated_Id__c = 1002271;
                        insert acc;
                        
                        Contact con = new Contact();
                        con.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Advantage Program (Inc Holiday Systems)').getRecordTypeId();
                        con.LastName = cup.Name__c;
                        con.AffiliatedId__c = 1002271;
                        con.Affiliate_Name__c = 'CFD Bulk Coupon Sales';
                        con.Email = cup.Email__c;
                        con.AccountId = acc.Id;
                        con.Phone = cup.Phone_Number__c;
                        // TODO : Address field mapping
                        insert con;
                        
                        // TODO: Create a contact with same fields as Account along with Affiliate
                        
                        system.debug('---acc'+acc);
                        Opportunity opp = new Opportunity();
                        Opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Bulk Sales Coupon').getRecordTypeId();
                        //TODO: Marked as read only
                        Opp.Coupon__c = cup.Id;
                        opp.Coupon_Code__c = cup.Coupon_Code__c;
                        Opp.Name = acc.Name;
                        opp.AccountId = acc.Id;
                        Opp.CloseDate = system.today();
                        opp.StageName = 'Çlosed Won';
                        insert opp;
                        system.debug('---opp'+opp);
                        // Create Opportunity line item
                        OpportunityLineItem oliStd = new OpportunityLineItem();
                        if(opp.Id != null){
                            List<PricebookEntry> pricebookListStandard = [select id ,Name,Pricebook2Id ,Product2Id,UnitPrice from PricebookEntry where IsActive= true and Product2.Name = 'Bulk Sales Coupon-Vidanta'];
                            oliStd.OpportunityId = opp.Id;
                            oliStd.PricebookEntryId=pricebookListStandard[0].Id;
                            //oliStd.Retail_Price__c = (PaymentInformationObjMap.containsKey('Base_Price__c') ? (Decimal)PaymentInformationObjMap.get('Base_Price__c') : 0) + (PaymentInformationObjMap.containsKey('Total_Upgrades__c') ? (Decimal)PaymentInformationObjMap.get('Total_Upgrades__c') : 0);
                            oliStd.Retail_Price__c = 0;
                            system.debug('-oliStd.Retail_Price__c---'+oliStd.Retail_Price__c);
                            insert oliStd;
                            system.debug('---oliStd'+oliStd);
                        }   
                         String productionId = '';
                        if(oliStd != null){
                            productionId = [select Product_Id__c from OpportunityLineItem where Id =:oliStd.Id].Product_Id__c;
                        }
                        // Create payment
                        Payment__c newPmnt = new Payment__c();
                        newPmnt.RecordTypeId = Schema.SObjectType.Payment__c.getRecordTypeInfosByName().get('Bulk Sales Coupon').getRecordTypeId();
                         newPmnt.Name = acc.Name +''+system.now().format('yyyyMMdd');
                        newPmnt.Payment_Type__c = 'Payment';    
                        newPmnt.Payment_Date__c = system.today();
                        newPmnt.Opportunity__c = opp.Id;
                        newPmnt.Paid_On__c = system.today();
                        newPmnt.Payment_Processed__c = true;
                        newPmnt.Transaction_Type__c = 'Bulk Sales Coupon';
                        newPmnt.Payment_Amount__c = 0;
                        if(productionId != null){
                        	newPmnt.Product_Id__c = productionId;
                        }
                        // TODO : Add product Id based on the product
                        Insert newPmnt;
                        system.debug('---newPmnt'+newPmnt);
                    }Catch(Exception ex){
                        system.debug('----ex----'+ex);
                        Error_Handler__c err = new Error_Handler__c();
                        err.Name = 'Class : CouponTriggerHandler, Method : createAccountOppAndRelatedRecords';
                        err.Error_Message__c = 'Message:' + ex.getMessage()  + ' - Exception occurrred on LineNumber: ' + ex.getLineNumber();
                        insert err;
                    }
                }
            }
        }
    }
    
}