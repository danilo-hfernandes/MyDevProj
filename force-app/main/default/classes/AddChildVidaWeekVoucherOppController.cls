public class AddChildVidaWeekVoucherOppController {
    
    
    @AuraEnabled 
    public static Map<String,String> tryToAddChildVidaWeekVoucherOpp(String recordId){
        String returnState = 'sucess';
        String returnErroMsg = '';
        Map<String,String> stateAndLog = new Map<String,String>();
        
        try{
            Opportunity parentOpp = [SELECT Id,AccountId,Account.Name,RecordType.DeveloperName,isWon,isClosed,Payments_Count__c FROM Opportunity WHERE Id =: recordId LIMIT 1];
            Id oppMTRCMembership_UpgradeRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Voucher').getRecordTypeId();
            //List<Opportunity> existingChildOpps = [SELECT Id,AccountId,Account.Name,Parent_Opportunity__c,isWon,isClosed,Payments_Count__c FROM Opportunity WHERE Parent_Opportunity__c =: parentOpp.Id and RecordTypeId =: oppMTRCMembership_UpgradeRecordTypeId];
            //MTRC_Retail added 2023-03-06
            if(parentOpp.isWon && parentOpp.Payments_Count__c > 0 && parentOpp.isClosed && (parentOpp.RecordType.DeveloperName == 'MTRC_Retail' || parentOpp.RecordType.DeveloperName == 'Membership_Upgrade' || parentOpp.RecordType.DeveloperName == 'Hawaii_Collection_Membership' || parentOpp.RecordType.DeveloperName == 'SFX_Membership'))
            {
                system.debug('tryToAddChildVidaWeekVoucherOpp rectype and stage checked');
                //if(existingChildOpps == null || existingChildOpps.size() == 0){
                    system.debug('tryToAddChildVidaWeekVoucherOpp existingChildOpps checked');
                    Opportunity opp = new Opportunity();
                    opp.AccountId = parentOpp.AccountId;
                    opp.Name = parentOpp.Account.Name;
                    opp.RecordTypeId = oppMTRCMembership_UpgradeRecordTypeId;
                    opp.StageName = 'New';
                    opp.CloseDate = system.Today();
                    opp.Parent_Opportunity__c = parentOpp.Id;
                    opp.ParentOpportunity__c = parentOpp.Id;
                    opp.Vidanta_Voucher_Email_Sent__c = true;
                    opp.Voucher_18_Months_Email_Sent__c = true;
                    opp.Vidanta_SFX_Voucher_Email_Sent__c = true;
                    insert opp;
                    
                    OpportunityLineItem oli = new OpportunityLineItem();
                    oli.Quantity = 1;
                    oli.OpportunityId = opp.Id;
                    oli.PriceBookEntryID = [SELECT Id, Name, Product2Id, Product2.Id, Product2.Name FROM PriceBookEntry WHERE Product2.Name = 'Membership Upgrade Vida Week' LIMIT 1].Id;
                    insert oli;
                    
                    oli = [SELECT Id, Product_ID__c, Product2.Id FROM OpportunityLineItem WHERE Id =: oli.Id LIMIT 1];
                    
                    Payment__c objpayment = new Payment__c();
                    objpayment.Paid_On__c = system.today();
                    objpayment.Opportunity__c = opp.Id;
                    objpayment.Payment_Type__c = 'Payment';
                    objpayment.Payment_Amount__c = 0;
                    objpayment.RecordTypeId = Schema.SObjectType.Payment__c.getRecordTypeInfosByDeveloperName().get('Voucher').getRecordTypeId();
                    objpayment.Account__c = opp.AccountId;
                    objpayment.Product_Id__c = oli.Product_ID__c;
                    objpayment.Product_Salesforce_Id__c = oli.Product2.Id;
                    insert objpayment;
                    
                    /*opp.StageName = 'Closed Won';
update opp;*/
                /*}
                else
                {
                    returnState = 'error';
                    returnErroMsg = 'This opportunity already have a Membership Upgrade Vida Week child opportunity associated!';
                    system.debug('This opportunity already have a Membership Upgrade Vida Week child opportunity associated!');
                }*/
            }
            else
            {
                returnState = 'error';
                returnErroMsg = 'This opportunity does not meet the requirements, the Record Type should be SFX, Hawaii Collection, MTRC Retail or MTRC Membership Upgrade and the Stage should be Closed Won with at least 1 payment';
                system.debug('This opportunity does not meet the requirements, the Record Type should be SFX, Hawaii Collection, MTRC Retail or MTRC Membership Upgrade and the Stage should be Closed Won with at least 1 payment');
            }
        }
        Catch(Exception e)
        {
            returnState = 'error';
            returnErroMsg = e.getMessage();
            System.debug('ERROR - Child Voucher Opp not inserted, error log : '+e.getMessage());
        }
        stateAndLog.put(returnState,returnErroMsg);
        return stateAndLog;
    }
    
    @Future
    public static void tryToAddChildVidaWeekVoucherOppFuture(String recordId){
        String returnState = 'sucess';
        String returnErroMsg = '';
        Map<String,String> stateAndLog = new Map<String,String>();        
        
        Opportunity parentOpp = [SELECT Id,AccountId,Account.Name,RecordType.DeveloperName,isWon,isClosed,Payments_Count__c,(SELECT Id,Product2.Name FROM OpportunityLineItems) FROM Opportunity WHERE Id =: recordId LIMIT 1];
        
        String marivalProduct = '';
        
        for(OpportunityLineItem parentoli : parentOpp.OpportunityLineItems)
        {
            if(parentoli.Product2.Name == 'Marival MU-Add On')
            {
                marivalProduct = 'Marival MU-Add On';
            }
            else if(parentoli.Product2.Name == 'Marival MU MX-Add On')
            {
                marivalProduct = 'Marival MU MX-Add On';
            }
        }        
        //MTRC_Retail added 2023-03-06
        //Marival filter added 2024-03-21
        if(parentOpp.isWon && parentOpp.Payments_Count__c > 0 && parentOpp.isClosed && marivalProduct == '' && (parentOpp.RecordType.DeveloperName == 'MTRC_Retail' || parentOpp.RecordType.DeveloperName == 'Membership_Upgrade'))
        {
            Id oppMTRCMembership_UpgradeRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Voucher').getRecordTypeId();
           // List<Opportunity> existingChildOpps = [SELECT Id,AccountId,Account.Name,Parent_Opportunity__c,isWon,isClosed,Payments_Count__c FROM Opportunity WHERE Parent_Opportunity__c =: parentOpp.Id and recordTypeId =: oppMTRCMembership_UpgradeRecordTypeId];
           // if(existingChildOpps == null || existingChildOpps.size() == 0){
               Opportunity opp = new Opportunity();
                opp.AccountId = parentOpp.AccountId;
                opp.Name = parentOpp.Account.Name;
                opp.RecordTypeId = oppMTRCMembership_UpgradeRecordTypeId;
                opp.StageName = 'New';
                opp.CloseDate = system.Today();
                opp.Parent_Opportunity__c = parentOpp.Id;
                opp.ParentOpportunity__c = parentOpp.Id;
                opp.Vidanta_Voucher_Email_Sent__c = true;
                opp.Voucher_18_Months_Email_Sent__c = true;
                opp.Vidanta_SFX_Voucher_Email_Sent__c = true;
                insert opp;
                
                OpportunityLineItem oli = new OpportunityLineItem();
                oli.Quantity = 1;
                oli.OpportunityId = opp.Id;
                oli.PriceBookEntryID = [SELECT Id, Name, Product2Id, Product2.Id, Product2.Name FROM PriceBookEntry WHERE Product2.Name = 'Membership Upgrade Vida Week' LIMIT 1].Id;
                insert oli;
                
                oli = [SELECT Id, Product_ID__c, Product2.Id FROM OpportunityLineItem WHERE Id =: oli.Id LIMIT 1];
                
                Payment__c objpayment = new Payment__c();
                objpayment.Paid_On__c = system.today();
                objpayment.Opportunity__c = opp.Id;
                objpayment.Payment_Type__c = 'Payment';
                objpayment.Payment_Amount__c = 0;
                objpayment.RecordTypeId = Schema.SObjectType.Payment__c.getRecordTypeInfosByDeveloperName().get('Voucher').getRecordTypeId();
                objpayment.Account__c = opp.AccountId;
                objpayment.Product_Id__c = oli.Product_ID__c;
                objpayment.Product_Salesforce_Id__c = oli.Product2.Id;
                insert objpayment;
                
                /*opp.StageName = 'Closed Won';
update opp;*/
           /* }
            else
            {
                returnState = 'error';
                returnErroMsg = 'This opportunity already have a Membership Upgrade Vida Week child opportunity associated!';
            }*/
        }
        else
        {
            returnState = 'error';
            returnErroMsg = 'This opportunity does not meet the requirements, the Record Type should be MTRC Membership Upgrade and the Stage should be Closed Won with at least 1 payment';
        }
        
        //Marival added 2024-03-21
        // Added "Membership Add-On" 2024-09-25 TGR-215
        if(marivalProduct != '' && parentOpp.isWon && parentOpp.Payments_Count__c > 0 && parentOpp.isClosed && (parentOpp.RecordType.DeveloperName == 'SFX_Membership' || parentOpp.RecordType.DeveloperName == 'Hawaii_Collection_Membership' || parentOpp.RecordType.DeveloperName == 'MTRC_Retail' || parentOpp.RecordType.DeveloperName == 'Membership_Upgrade' || parentOpp.RecordType.DeveloperName == 'Membership_Add_On'))
        {
            Id oppMarivalRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Marival').getRecordTypeId();
            //List<Opportunity> marivalExistingChildOpps = [SELECT Id,AccountId,Account.Name,Parent_Opportunity__c,isWon,isClosed,Payments_Count__c FROM Opportunity WHERE Parent_Opportunity__c =: parentOpp.Id and RecordTypeId =: oppMarivalRecordTypeId ];
            //if(marivalExistingChildOpps == null || marivalExistingChildOpps.size() == 0){
                
                Opportunity opp = new Opportunity();
                opp.AccountId = parentOpp.AccountId;
                opp.Name = parentOpp.Account.Name;
                opp.RecordTypeId = oppMarivalRecordTypeId;
                opp.StageName = 'New';
                opp.CloseDate = system.Today();
                opp.Parent_Opportunity__c = parentOpp.Id;
                opp.ParentOpportunity__c = parentOpp.Id;
                /* is not Voucher recType
* opp.Vidanta_Voucher_Email_Sent__c = true;
opp.Voucher_18_Months_Email_Sent__c = true;
opp.Vidanta_SFX_Voucher_Email_Sent__c = true;*/
                insert opp;
                
                Set<Id> olisCreated = new Set<Id>();
                if(marivalProduct == 'Marival MU-Add On')
                {
                    
                    // 2024-09-26 TGR-215 'Marival Booking Fee' Opt Line Item not added if Membership_Add_On
                    List<PriceBookEntry> pbEntries;
                    If(parentOpp.RecordType.DeveloperName == 'Membership_Add_On') 
                    {
                        pbEntries = [SELECT Id, Name, Product2Id, Product2.Id, Product2.Name FROM PriceBookEntry WHERE Product2.Name = 'Marival Armony-4 Nights (2A) Studio' OR Product2.Name = 'Marival Resort Fee'];
                    }
                    else
                    {
                        pbEntries = [SELECT Id, Name, Product2Id, Product2.Id, Product2.Name FROM PriceBookEntry WHERE Product2.Name = 'Marival Armony-4 Nights (2A) Studio' OR Product2.Name = 'Marival Booking Fee' OR Product2.Name = 'Marival Resort Fee'];
                    }
                    List<OpportunityLineItem> olisToCreate = new List<OpportunityLineItem>();
                    for(PriceBookEntry pbEntry : pbEntries)
                    {
                        OpportunityLineItem oli = new OpportunityLineItem();
                        oli.Quantity = 1;
                        oli.OpportunityId = opp.Id;
                        oli.PriceBookEntryID = pbEntry.Id;
                        if(pbEntry.Product2.Name == 'Marival Armony-4 Nights (2A) Studio')
                        {
                            oli.Retail_Price__c = 0;
                            oli.UnitPrice = 0;
                        }
                        // Added 'Marival Resort Fee' 2024-09-25 TGR-215
                        else if(pbEntry.Product2.Name == 'Marival Resort Fee' && parentOpp.RecordType.DeveloperName == 'Membership_Add_On')
                        {
                            oli.Retail_Price__c = 299;
                            oli.UnitPrice = 299;
                        } 
                        olisToCreate.add(oli);
                    }                        
                    insert olisToCreate;
                    for(OpportunityLineItem oliCreated : olisToCreate)
                    {
                        olisCreated.add(oliCreated.Id);
                    }
                }
                else if(marivalProduct == 'Marival MU MX-Add On')
                {
                    
                    // 2024-09-26 TGR-215 'Marival Booking Fee' Opt Line Item not added if Membership_Add_On
                    List<PriceBookEntry> pbEntries2;
                    If(parentOpp.RecordType.DeveloperName == 'Membership_Add_On') 
                    {
                        pbEntries2 = [SELECT Id, Name, Product2Id, Product2.Id, Product2.Name FROM PriceBookEntry WHERE Product2.Name = 'Marival Armony MX National-3 Nights (2A) Studio' OR Product2.Name = 'Marival Resort Fee'];
                    }
                    else
                    {
                        pbEntries2 = [SELECT Id, Name, Product2Id, Product2.Id, Product2.Name FROM PriceBookEntry WHERE Product2.Name = 'Marival Armony MX National-3 Nights (2A) Studio' OR Product2.Name = 'Marival Booking Fee' OR Product2.Name = 'Marival Resort Fee'];
                    }
                    
                    List<OpportunityLineItem> olisToCreate2 = new List<OpportunityLineItem>();
                    
                    for(PriceBookEntry pbEntry : pbEntries2)
                    {
                        OpportunityLineItem oli = new OpportunityLineItem();
                        oli.Quantity = 1;
                        oli.OpportunityId = opp.Id;
                        oli.PriceBookEntryID = pbEntry.Id;
                        if(pbEntry.Product2.Name == 'Marival Armony MX National-3 Nights (2A) Studio')
                        {
                            oli.Retail_Price__c = 0;
                            oli.UnitPrice = 0;
                        }   
                        // Added 'Marival Resort Fee' 2024-09-25 TGR-215
                        else if(pbEntry.Product2.Name == 'Marival Resort Fee' && parentOpp.RecordType.DeveloperName == 'Membership_Add_On')
                        {
                            oli.Retail_Price__c = 299;
                            oli.UnitPrice = 299;
                        }
                        olisToCreate2.add(oli);
                    }                        
                    insert olisToCreate2;
                    for(OpportunityLineItem oliCreated : olisToCreate2)
                    {
                        olisCreated.add(oliCreated.Id);
                    }
                }
                
                OpportunityLineItem oli = [SELECT Id, Product_ID__c, Product2.Id FROM OpportunityLineItem WHERE Id IN : olisCreated AND (Product2.Name = 'Marival Armony-4 Nights (2A) Studio' OR Product2.Name = 'Marival Armony MX National-3 Nights (2A) Studio') LIMIT 1];
                
                Payment__c objpayment = new Payment__c();
                objpayment.Paid_On__c = system.today();
                objpayment.Opportunity__c = opp.Id;
                objpayment.Payment_Type__c = 'Payment';
                objpayment.Payment_Amount__c = 0;
                objpayment.RecordTypeId = Schema.SObjectType.Payment__c.getRecordTypeInfosByDeveloperName().get('Voucher').getRecordTypeId();
                objpayment.Account__c = opp.AccountId;
                objpayment.Product_Id__c = oli.Product_ID__c;
                objpayment.Product_Salesforce_Id__c = oli.Product2.Id;
                insert objpayment;
                
           /* }
            else
            {
                returnState = 'error';
                returnErroMsg = 'This opportunity already have a Marival child opportunity associated!';
            }*/
        }
        else
        {
            returnState = 'error';
            returnErroMsg = 'This opportunity does not meet the requirements to create the child opp.';
        }
        
        stateAndLog.put(returnState,returnErroMsg);
        //return stateAndLog;
    }
    
    @Future
    public static void tryToAddChildVidantaComplimentaryVoucherOppFuture(String recordId){
        String returnState = 'sucess';
        String returnErroMsg = '';
        Map<String,String> stateAndLog = new Map<String,String>();        
        
        Opportunity parentOpp = [SELECT Id,AccountId,Account.Name,RecordType.DeveloperName,isWon,isClosed,Payments_Count__c,(SELECT Id,Product2.Name FROM OpportunityLineItems) FROM Opportunity WHERE Id =: recordId LIMIT 1];
        
        //Boolean hasAnnualDueVoucherBundleproduct = false;
        Boolean hasAnnualDuesFlexStayVoucherBundleProduct = false;
        
        for(OpportunityLineItem parentoli : parentOpp.OpportunityLineItems)
        {
            /*if(parentoli.Product2.Name == 'Annual Dues Voucher Bundle')
{
hasAnnualDueVoucherBundleproduct = true;
}
else*/
            if(parentoli.Product2.Name == 'Annual Dues FlexStay Voucher Bundle')
            {
                hasAnnualDuesFlexStayVoucherBundleProduct = true;
            }
        }
        
        System.debug('parentOpp.OpportunityLineItems = '+parentOpp.OpportunityLineItems);
        System.debug('hasAnnualDuesFlexStayVoucherBundleProduct = '+hasAnnualDuesFlexStayVoucherBundleProduct);
        
        if(hasAnnualDuesFlexStayVoucherBundleProduct){//hasAnnualDueVoucherBundleproduct || 
            Id oppFlex_Stays_Product_VoucherRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Flex_Stays_Product_Voucher').getRecordTypeId();
            //List<Opportunity> existingChildOpps = [SELECT Id,AccountId,Account.Name,Parent_Opportunity__c,isWon,isClosed,Payments_Count__c FROM Opportunity WHERE Parent_Opportunity__c =: parentOpp.Id and RecordTypeID =: oppFlex_Stays_Product_VoucherRecordTypeId];
            
            if(parentOpp.isWon && parentOpp.Payments_Count__c > 0 && parentOpp.isClosed && parentOpp.RecordType.DeveloperName == 'Membership_Annual_Dues')
            {
                //if(existingChildOpps == null || existingChildOpps.size() == 0){
                    
                    Id oppVoucherRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Voucher').getRecordTypeId();
                    
                    Opportunity opp = new Opportunity();
                    opp.AccountId = parentOpp.AccountId;
                    opp.Name = parentOpp.Account.Name;
                    
                    opp.StageName = 'New';
                    opp.CloseDate = system.Today();
                    opp.Parent_Opportunity__c = parentOpp.Id;
                    opp.ParentOpportunity__c = parentOpp.Id;
                    /*if(hasAnnualDueVoucherBundleproduct){
opp.RecordTypeId = oppVoucherRecordTypeId;
opp.Vidanta_Voucher_Email_Sent__c = true;
opp.Voucher_18_Months_Email_Sent__c = true;
opp.Vidanta_SFX_Voucher_Email_Sent__c = true;
}
else*/
                    if(hasAnnualDuesFlexStayVoucherBundleProduct)
                    {
                        opp.RecordTypeId = oppFlex_Stays_Product_VoucherRecordTypeId;
                        //Trigger the Flex Stays Voucher Confirmation 8/7 New email
                        opp.Flex_Stays_Nights__c = 7;
                    }
                    insert opp;
                    
                    OpportunityLineItem oli = new OpportunityLineItem();
                    oli.Quantity = 1;
                    oli.OpportunityId = opp.Id;
                    /*if(hasAnnualDueVoucherBundleproduct){
oli.PriceBookEntryID = [SELECT Id, Name, Product2Id, Product2.Id, Product2.Name FROM PriceBookEntry WHERE Product2.Name = 'Voucher-Vidanta Complimentary' LIMIT 1].Id;
}
else*/
                    if(hasAnnualDuesFlexStayVoucherBundleProduct)
                    {
                        oli.PriceBookEntryID = [SELECT Id, Name, Product2Id, Product2.Id, Product2.Name FROM PriceBookEntry WHERE Product2.Name = 'FlexStay-Add On' LIMIT 1].Id;
                    }
                    insert oli;
                    
                    oli = [SELECT Id, Product_ID__c, Product2.Id FROM OpportunityLineItem WHERE Id =: oli.Id LIMIT 1];
                    
                    Payment__c objpayment = new Payment__c();
                    objpayment.Paid_On__c = system.today();
                    objpayment.Opportunity__c = opp.Id;
                    objpayment.Payment_Type__c = 'Payment';
                    objpayment.Payment_Amount__c = 0;
                    objpayment.RecordTypeId = Schema.SObjectType.Payment__c.getRecordTypeInfosByDeveloperName().get('Voucher').getRecordTypeId();
                    objpayment.Account__c = opp.AccountId;
                    objpayment.Product_Id__c = oli.Product_ID__c;
                    objpayment.Product_Salesforce_Id__c = oli.Product2.Id;
                    insert objpayment;
                    
                    /*opp.StageName = 'Closed Won';
update opp;*/
               /* }
                else
                {
                    returnState = 'error';
                    returnErroMsg = 'This opportunity already have a child opportunity associated!';
                }*/
            }
            else
            {
                returnState = 'error';
                returnErroMsg = 'This opportunity does not meet the requirements, the Record Type should be Membership Annual Dues and the Stage should be Closed Won with at least 1 payment';
            }        
        }
        else
        {
            returnState = 'error';
            returnErroMsg = 'This opportunity does not have the Annual Dues Voucher Bundle or Annual Dues FlexStay Voucher Bundle product added';
        }
        stateAndLog.put(returnState,returnErroMsg);
        //return stateAndLog;
    }
    
    @Future 
    public static void searchAndMoveChildOppToClosedLost(String recordId){        
        String returnState = 'sucess';
        String returnErroMsg = '';
        Map<String,String> stateAndLog = new Map<String,String>();
        
        Opportunity parentOpp = [SELECT Id,AccountId,Account.Name,RecordType.DeveloperName,isWon,isClosed,Payments_Count__c FROM Opportunity WHERE Id =: recordId LIMIT 1];
        
        List<Opportunity> existingChildOpps = [SELECT Id,AccountId,Account.Name,Parent_Opportunity__c,isWon,isClosed,StageName,Payments_Count__c FROM Opportunity WHERE Parent_Opportunity__c =: parentOpp.Id AND (IsClosed = false OR IsWon = true)];
        
        if(existingChildOpps != null && existingChildOpps.size() > 0){
            
            for(Opportunity child : existingChildOpps)
            {
                child.StageName = 'Closed Lost';
            }
            update existingChildOpps;            
        }        
        else
        {
            returnState = 'error';
            returnErroMsg = 'No child opp associated!';
        }        
    }
    
}