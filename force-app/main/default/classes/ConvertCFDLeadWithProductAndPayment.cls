@RestResource(urlMapping='/ConvertCFDLeadWithProductAndPayment/*')
Global class ConvertCFDLeadWithProductAndPayment {
    
    @HttpPost
    global static ResponseWrapper GetData(requestJson reqJson)
    {
        RestRequest req = RestContext.request;
        ResponseWrapper response = new ResponseWrapper();
        responseParams param = new responseParams();
        try{
            response.status = 'Success';            
            System.debug('reqJson.Lead_Form_External_Id : '+reqJson);
            if(reqJson != null)
            {
                if(reqJson.Lead_Form_External_Id != null && reqJson.Lead_Form_External_Id != '')
                {
                    param.Lead_Form_External_Id = reqJson.Lead_Form_External_Id;
                    
                    Lead leadToConvert = [SELECT Id,Lead_Form_External_Id__c,IsConverted,ConvertedAccountId,ConvertedOpportunityId,ConvertedContactId,FirstName,LastName,Phone,Email,RecordTypeId,LeadSource,Match_Affiliate_Id__c FROM Lead WHERE Lead_Form_External_Id__c =: reqJson.Lead_Form_External_Id LIMIT 1];
                    List<Account> duplicatedAccounts = new List<Account>();
                    duplicatedAccounts = [Select Id,Email__c,Phone,Affiliated_Id__c,Master_Record_Id__c,CreatedDate,SystemModStamp,LastReferencedDate, (SELECT Id,AffiliatedId__c,Phone,Email FROM Contacts where (Email =: leadToConvert.Email OR Phone =: leadToConvert.Phone)) FROM Account where (Affiliated_Id__c =: leadToConvert.Match_Affiliate_Id__c) AND (Email__c =: leadToConvert.Email OR Phone =: leadToConvert.Phone) order by createddate desc];
                                        
                    System.debug('leadToConvert : '+leadToConvert);
                    System.debug('duplicatedAccounts : '+duplicatedAccounts);
                    
                    List<Account> duplicatedAccountsWithContacts = new List<Account>();
                    
                    param.Lead_FirstName = leadToConvert.FirstName;
                    param.Lead_LastName = leadToConvert.LastName;
                    param.Lead_Phone = leadToConvert.Phone;
                    param.Lead_Email = leadToConvert.Email;
                    param.Lead_RecordTypeId = leadToConvert.RecordTypeId;
                    param.Lead_LeadSource = leadToConvert.LeadSource;
                    param.Lead_Id = leadToConvert.Id;
                    
                    /*leadToConvert.Street = reqJson.Lead_Street;
					leadToConvert.City = reqJson.Lead_City;
					leadToConvert.PostalCode = reqJson.Lead_Postal_Code;
					leadToConvert.State = reqJson.Lead_State;
					leadToConvert.Country = reqJson.Lead_Country;                    
					update leadToConvert;*/
                    
                    OpportunityLineItem oli = new OpportunityLineItem();
                    
                    if(!leadToConvert.IsConverted && leadToConvert.ConvertedAccountId == null && leadToConvert.ConvertedContactId == null && leadToConvert.ConvertedOpportunityId == null){
                        Database.LeadConvert lc = new Database.LeadConvert();
                        Database.DMLOptions dml = new Database.DMLOptions();
                        dml.DuplicateRuleHeader.AllowSave = true;
                        lc.setLeadId(leadToConvert.Id);
                        lc.setDoNotCreateOpportunity(false);                    
                        //LeadStatus convertStatus = [SELECT Id, MasterLabel, IsConverted FROM LeadStatus WHERE IsConverted=true limit 1];
                        lc.setConvertedStatus('Sold Voucher');
                        if(duplicatedAccounts != null && duplicatedAccounts.size()>0)
                        {
                            for(Account dupAcc : duplicatedAccounts)
                            {
                                if(dupAcc.Contacts != null && dupAcc.Contacts.size()>0)
                                {
                                    duplicatedAccountsWithContacts.add(dupAcc);
                                }
                            }
                            if(duplicatedAccountsWithContacts != null && duplicatedAccountsWithContacts.size()>0)
                            {
                                duplicatedAccounts = duplicatedAccountsWithContacts;
                            }
                            System.debug('duplicatedAccounts not null');
                            System.debug('duplicatedAccounts[0].Id'+duplicatedAccounts[0].Id);
                            lc.setAccountId(duplicatedAccounts[0].Id);                            
                            if(duplicatedAccounts[0].Contacts != null && duplicatedAccounts[0].Contacts.size()>0)
                            {
                                System.debug('duplicatedAccounts[0].Contacts'+duplicatedAccounts[0].Contacts);
                                lc.setContactId(duplicatedAccounts[0].Contacts[0].Id);
                            }
                        }
                        Database.LeadConvertResult lcResults = Database.convertLead(lc,dml);
                        System.debug('lcResults :'+lcResults);
                        param.leadConversionResults = String.valueOf(lcResults);
                        
                        if(lcResults.isSuccess()){
                            
                            Id AccId = lcResults.getAccountId();
                            
                            Account createdAcc = [SELECT Id,RecordTypeId,RecordType.DeveloperName,Membership_Product_Configuration__c FROM Account WHERE Id =: AccId LIMIT 1];
                            
                            if(createdAcc.Membership_Product_Configuration__c == null)
                            {
                                String leadAf = String.valueOf(leadToConvert.Match_Affiliate_Id__c);                                
                                System.debug('leadAf : '+leadAf);
                                createdAcc.Membership_Product_Configuration__c = [Select Id,Affiliated_Id__c from Membership_Product_Configuration__c where Affiliated_Id__c =: leadAf LIMIT 1].Id;
                                update createdAcc;
                                System.debug('createdAcc.Membership_Product_Configuration__c : '+createdAcc.Membership_Product_Configuration__c);
                            }
                            
                            Id OppId = lcResults.getOpportunityId();
                            
                            List<PriceBookEntry> pbEntryList = [SELECT Id,Product2.Id,Name FROM PricebookEntry WHERE Name = 'CFD Mexico Voucher' OR Name = 'Cruise Certificate Add-On'];
                            Map<String,PriceBookEntry> pbEntryMap = new Map<String,PriceBookEntry>();
                            for(PriceBookEntry pricebook : pbEntryList)
                            {
                                pbEntryMap.put(pricebook.Name,pricebook);
                            }
                            
                            Opportunity createdOpp = [SELECT Id,RecordTypeId,RecordType.DeveloperName,Membership_Product_Configuration__c,MX_Voucher_Product_Added__c,Product_Name__c,Account.Email__c,Converted_Lead_Email__c FROM Opportunity WHERE Id =: OppId LIMIT 1];
                            Boolean updateCreatedOpp = false;
                            if(createdOpp.RecordType.DeveloperName != 'Voucher'){
                                createdOpp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Voucher').getRecordTypeId();
                                updateCreatedOpp = true;
                            }
                            if(createdOpp.Membership_Product_Configuration__c == null)
                            {
                                String leadAff = String.valueOf(leadToConvert.Match_Affiliate_Id__c);                                
                                System.debug('leadAff : '+leadAff);                                
                                createdOpp.Membership_Product_Configuration__c = [Select Id,Affiliated_Id__c from Membership_Product_Configuration__c where Affiliated_Id__c =: leadAff LIMIT 1].Id;
                                updateCreatedOpp = true;
                                System.debug('createdOpp.Membership_Product_Configuration__c : '+createdOpp.Membership_Product_Configuration__c);
                            }
                            if(createdOpp.MX_Voucher_Product_Added__c == false)
                            {
                                createdOpp.MX_Voucher_Product_Added__c = true;
                                updateCreatedOpp = true;
                                System.debug('createdOpp.MX_Voucher_Product_Added__c : '+createdOpp.MX_Voucher_Product_Added__c);
                            }
                            if(createdOpp.Product_Name__c == '' || createdOpp.Product_Name__c == null)
                            {
                                createdOpp.Product_Name__c = 'CFD Mexico Voucher';
                                updateCreatedOpp = true;
                                System.debug('createdOpp.Product_Name__c = set to = CFD Mexico Voucher');
                            }                            
                            if(createdOpp.Account.Email__c != '' || createdOpp.Account.Email__c != null)
                            {
                                createdOpp.Account_Email__c = createdOpp.Account.Email__c;
                                updateCreatedOpp = true;
                                System.debug('createdOpp.Account_Email__c = createdOpp.Converted_Lead_Email__c');
                            }                            
                            if(createdOpp.Converted_Lead_Email__c != '' || createdOpp.Converted_Lead_Email__c != null)
                            {
                                createdOpp.Account_Email__c = createdOpp.Converted_Lead_Email__c;
                                updateCreatedOpp = true;
                                System.debug('createdOpp.Account_Email__c = createdOpp.Converted_Lead_Email__c');
                            }                            
                            
                            if(updateCreatedOpp)
                            {
                                update createdOpp;
                            }
                            
                            List<OpportunityLineItem> olisToInsert = new List<OpportunityLineItem>();
                            oli.Quantity = 1;
                            oli.OpportunityId = OppId;
                            PriceBookEntry pbEntry = pbEntryMap.get('CFD Mexico Voucher');
                            //[SELECT Id,Product2.Id FROM PricebookEntry WHERE Name = 'CFD Mexico Voucher' LIMIT 1];
                            oli.Product2Id = pbEntry.Product2.Id;
                            oli.PriceBookEntryID = pbEntry.Id;
                            //insert oli;
                            olisToInsert.add(oli);
                            /*createdOpp.MX_Voucher_Product_Added__c = true;
                            update createdOpp;*/
                            
                            if(reqJson.Add_Cruise == 'true')
                            {
                                OpportunityLineItem oli2 = new OpportunityLineItem();
                                oli2.Quantity = 1;
                                oli2.OpportunityId = OppId;
                                PriceBookEntry pbEntry2 = pbEntryMap.get('Cruise Certificate Add-On');
                                //[SELECT Id,Product2.Id FROM PricebookEntry WHERE Name = 'Cruise Certificate Add-On' LIMIT 1];
                                oli2.Product2Id = pbEntry2.Product2.Id;
                                oli2.PriceBookEntryID = pbEntry2.Id;
                                //insert oli2;
                                olisToInsert.add(oli2);
                            }
                            
                            insert olisToInsert;
                            
                            oli = [SELECT Id,product_Id__c,Quantity,OpportunityId,Product2Id,PriceBookEntryID,TotalPrice,Opportunity.Name,Product2.Name,Opportunity.Payment_RecordType_Name__c,Opportunity.Amount,Opportunity.AccountId FROM OpportunityLineItem WHERE Id =: oli.Id];
                            param.Account_Id = oli.Opportunity.AccountId;
                            param.Opportunity_Id = oli.OpportunityId;
                            param.Product_Id = oli.product_Id__c;
                            param.Product_Name = oli.Product2.Name;
                            param.Opportunity_Name = oli.Opportunity.Name;
                            param.Product2_Id = oli.Product2Id;
                            param.OpportunityLineItemQuantity = String.valueOf(oli.Quantity);
                            param.OpportunityLineItemTotalPrice = String.valueOf(oli.TotalPrice);
                            //param.Payment_Id = p.Id;
                            //param.Payment_Info = String.valueOf(p);
                            param.Product_Info = String.valueOf(oli);
                        }
                        else
                        {
                            if(lcResults.getErrors() != null && lcResults.getErrors().size() > 0)
                            {
                                String convertErrorLog = String.valueOf(lcResults.getErrors());
                                System.debug('Lead convertErrorLog : '+convertErrorLog);
                                if(((convertErrorLog.contains('with this Email') || convertErrorLog.contains('with this Phone')) && convertErrorLog.contains('already exists')) || convertErrorLog.contains('This lead was already converted'))
                                {
                                    response.status = 'Sucess';
                                    response.errorMessage = 'Message: ' + 'The Lead is converting, please wait.';
                                }
                                else if(convertErrorLog.contains('Only one Voucher is allowed per Account per month')){
                                    response.status = 'Error';
                                    response.errorMessage = 'Only one Voucher is allowed per Account per month';
                                }
                                else{
                                    response.status = 'Error';
                                    response.errorMessage = 'Message: ' + lcResults.getErrors();
                                }
                            }
                        }
                    }
                    else
                    {
                        response.errorMessage = 'The Lead is already converted';
                        Id OppId = leadToConvert.ConvertedOpportunityId;
                        oli = [SELECT Id,product_Id__c,Quantity,OpportunityId,Product2Id,PriceBookEntryID,TotalPrice,Opportunity.Name,Product2.Name,Opportunity.Payment_RecordType_Name__c,Opportunity.Amount,Opportunity.AccountId FROM OpportunityLineItem WHERE Product2.Name != 'Cruise Certificate Add-On' AND OpportunityId =: leadToConvert.ConvertedOpportunityId LIMIT 1];
                        param.Account_Id = oli.Opportunity.AccountId;
                        param.Opportunity_Id = oli.OpportunityId;
                        param.Product_Id = oli.product_Id__c;
                        param.Product_Name = oli.Product2.Name;
                        param.Opportunity_Name = oli.Opportunity.Name;
                        param.Product2_Id = oli.Product2Id;
                        param.OpportunityLineItemQuantity = String.valueOf(oli.Quantity);
                        param.OpportunityLineItemTotalPrice = String.valueOf(oli.TotalPrice);
                        //param.Payment_Id = p.Id;
                        //param.Payment_Info = String.valueOf(p);
                        param.Product_Info = String.valueOf(oli);
                    }
                    
                    /*Payment__c p = new Payment__c();
					p.Name = 'payment'+String.valueOf(System.Now());
					p.Product_Id__c = oli.product_Id__c;
					p.Opportunity__c = OppId;
					p.Transaction_Type__c = 'Payment';
					p.Payment_Amount__c = 0;
					p.Credit_Card_Number__c = '23431231234';
					p.Paid_On__c = System.today();
					p.Payment_Type__c = 'Payment';
					insert p;*/                    
                }
                else
                {
                    response.status = 'Error';
                    response.errorMessage = 'Message:' + ' Invalid Lead_Form_External_Id';
                }
                response.data = param;
            }
            else
            {
                response.status = 'Error';
                response.errorMessage = 'Message:' + ' Invalid Lead_Form_External_Id';
            }
            
        }
        catch(Exception ex)
        {
            response.status = 'Error';
            response.errorMessage = 'Message:' + ex.getMessage()  + ' - Exception occurrred on LineNumber: ' + ex.getLineNumber();
        }
        System.debug('response example : '+response);
        return response;
    }
    
    global class ResponseWrapper
    {
        responseParams data;
        webservice String status;
        webservice String errorMessage;
    }
    
    public class responseParams
    {
        String Lead_Form_External_Id;
        String Lead_FirstName;
        String Lead_LastName;
        String Lead_Phone;
        String Lead_Email;
        String Lead_RecordTypeId;
        String Lead_LeadSource;
        String Lead_Id;
        String Account_Id;
        String Opportunity_Id;
        String Product_Id;
        String Product2_Id;
        //String Payment_Id;
        //String Payment_Info;
        String Product_Info;
        String leadConversionResults;
        String Product_Name;
        String OpportunityLineItemQuantity;
        String OpportunityLineItemTotalPrice;
        String Opportunity_Name;
    }
    
    global class requestJson{
        global string Lead_Form_External_Id;
        global string Add_Cruise;
    }
}