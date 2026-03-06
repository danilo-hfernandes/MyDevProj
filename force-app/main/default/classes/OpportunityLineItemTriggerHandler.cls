public without sharing class OpportunityLineItemTriggerHandler {
    private static final OpportunityLineItemTriggerHandler instance = new OpportunityLineItemTriggerHandler();
    
    /** 
Private constructor to prevent the creation of instances of this class.
*/
    private OpportunityLineItemTriggerHandler() {
    }
    
    /**
* @description Method responsible for providing the instance of this class.
* @return AccountTriggerHandler instance.
*/
    public static OpportunityLineItemTriggerHandler getInstance() {
        return instance;
    }
    /**
* Method to handle trigger before update operations. 
*/
    public void beforeInsert(){
        validateMinimumPrice();
        blockGiftProductCreationBasedOnParentQuantitySold();
        limitMUAddOnProductsQuantity();
    }
    
    public void beforeUpdate() {
        validateMinimumPrice();
        blockCommissionUpdatesByTourGenAgentsAfterPayment();
        blockGiftProductCreationBasedOnParentQuantitySold();
    }
    public void afterInsert(){
        system.debug('After Insert');
        createRedemptionRecord();
        addComplimentaryProduct();
        //MSR-288 
        //system.debug('before createLuxuryExcursion');
        //createLuxuryExcursion();
    }
    public void beforeDelete(){
        system.debug('before Delete');
        deleteRedemptionRecord();
        //MSR-288 
        //deleteLuxuryExcursion();
    }
    public void afterDelete(){
        //2024-01-10 HSIMU2-514
        cleanFlybackBackgroundFields();
    } 
    
    public void afterUpdate(){
        
//        //2025-10-07 TGR-859
//        system.debug('afterUpdate() calls insertNote()');
//        insertNote();
    } 
    
    //2024-12-02
    public static void validateMinimumPrice() {
        List<OpportunityLineItem> lineItems = (List<OpportunityLineItem>)Trigger.New;
        // Gather all Product2 IDs from the OpportunityLineItems
        Set<Id> productIds = new Set<Id>();
        
        for (OpportunityLineItem lineItem : lineItems) {
            if (Trigger.isInsert && lineItem.Product2Id != null) {
                productIds.add(lineItem.Product2Id);
            }
            if(Trigger.isUpdate){
                OpportunityLineItem oldOli = (OpportunityLineItem)Trigger.oldMap.get(lineItem.Id); 
                if(lineItem.Retail_Price__c != oldOli.Retail_Price__c){
                    productIds.add(lineItem.Product2Id);
                }
            }
        }
        if(productIds != null && productIds.size() > 0){
            // Query the metadata for products and their minimum prices
            Map<Id, Product_Minimum_Price__mdt> productMetadataMap = new Map<Id, Product_Minimum_Price__mdt>();
            for (Product_Minimum_Price__mdt metadata : [
                SELECT MasterLabel, ProductId__c, Minimum_Price__c FROM Product_Minimum_Price__mdt 
                WHERE ProductId__c IN :productIds]) {
                    productMetadataMap.put(metadata.ProductId__c, metadata);
                }
            
            // Validate each line item's price
            for (OpportunityLineItem lineItem : lineItems) {
                if (lineItem.Product2Id != null) {
                    Id productId = lineItem.Product2Id;
                    if (productMetadataMap.containsKey(productId)) {
                        Product_Minimum_Price__mdt metadata = productMetadataMap.get(productId);
                        if (lineItem.Retail_Price__c < metadata.Minimum_Price__c) {
                            lineItem.addError('The minimum price for '+metadata.MasterLabel+' is $' + metadata.Minimum_Price__c.format());
                        }
                    }
                }
            }
        }
    }
    
    //2024-01-10 HSIMU2-514
    public void cleanFlybackBackgroundFields(){
        
        Map<Id,String> oppProductsToCheck = new Map<Id,String>();        
        List<Opportunity> oppsToUpadte = new List<Opportunity>();
        for(OpportunityLineItem oli:(List<OpportunityLineItem>)Trigger.Old){
            if(oli.Name.endsWith('Vidanta Fly Back'))
            {
                oppProductsToCheck.put(oli.OpportunityId,'Vidanta Fly Back');
            }
        }
        if(oppProductsToCheck.size()>0 && oppProductsToCheck != null && !oppProductsToCheck.isEmpty())
        { 
            List<Opportunity> oppsToCheck = new List<Opportunity>();
            oppsToCheck = [SELECT Id,(SELECT Id FROM OpportunityLineItems WHERE Product2.Name = 'Vidanta Fly Back') FROM Opportunity WHERE Id IN : oppProductsToCheck.keySet()];
            //System.debug('oppsToCheck[0].OpportunityLineItems = '+oppsToCheck[0].OpportunityLineItems);
            for(Opportunity o : oppsToCheck)
            {
                /*System.debug('oppsToCheck.OpportunityLineItems = '+o.OpportunityLineItems);
System.debug('o.OpportunityLineItems.size() = '+o.OpportunityLineItems.size());*/
                if(o.OpportunityLineItems == null || o.OpportunityLineItems.size() == 0)
                {
                    o.Fly_Back_Product_Added__c = false;
                    o.Check_Opp_Send_Fly_Back_Email__c = null;
                    oppsToUpadte.add(o);
                }
            }
        }
        if(oppsToUpadte != null && oppsToUpadte.size()>0)
        {
            update oppsToUpadte;
        }
        
    }
    
    public void blockCommissionUpdatesByTourGenAgentsAfterPayment(){
        
        Boolean hasAdminPermission = FeatureManagement.checkPermission('IsSystemAdmin');        
        
        if(!hasAdminPermission){
            String errorMsg = 'This product already has a payment, you cannot make direct or indirect changes to commissions.';
            Id currentUserId = UserInfo.getUserId();
            Id vouRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Voucher').getRecordTypeId();                            
            Id flexRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Flex_Stays_Product_Voucher').getRecordTypeId();
            Id viRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('VI_Referral_Date_Request').getRecordTypeId();            
            Map<String,OpportunityLineItem> oliList = new Map<String,OpportunityLineItem>();
            List<User> userList = [SELECT Id,UserRole.Name,Profile.Name FROM User WHERE Id =: currentUserId AND UserRoleId != null AND ProfileId != null AND UserRole.Name != NULL and Profile.Name != NULL];
            if(userList != null && userList.size()>0){
                User u = userList[0];
                if(u.Profile.Name != 'System Administrator' && u.Profile.Name != 'Tour Generation Manager' && (u.UserRole.Name.contains('TourGen') || 	u.UserRole.Name.contains('Tour Gen'))){                    
                    for(OpportunityLineItem oli:(List<OpportunityLineItem>)Trigger.New){
                        OpportunityLineItem oldOli = (OpportunityLineItem)Trigger.oldMap.get(oli.Id);
                        if(oli.First_Agent_Commission_Amount_Product__c != oldOli.First_Agent_Commission_Amount_Product__c ||
                           oli.Second_Agent_Commission_Amount_Product__c != oldOli.Second_Agent_Commission_Amount_Product__c ||
                           oli.First_Agent_Percentage_Product__c != oldOli.First_Agent_Percentage_Product__c ||
                           oli.Second_Agent_Percentage_Product__c != oldOli.Second_Agent_Percentage_Product__c ||
                           oli.First_Agent_Product__c != oldOli.First_Agent_Product__c ||
                           oli.Second_Agent_Product__c != oldOli.Second_Agent_Product__c){
                               if(oli.Product_Id__c != null && oli.Product_Id__c != ''){
                                   oliList.put(oli.Product_Id__c,oli);
                               }
                           }
                    }
                    
                    if(oliList != null && oliList.size()>0)
                    {
                        List<Payment__c> payList = [SELECT Id,Product_Id__c FROM Payment__c WHERE Product_Id__c IN : oliList.keySet()];
                        
                        if(payList != null && payList.size()>0){
                            List<String> paymentProductIds = new List<String>();
                            for(Payment__c pay : payList)
                            {
                                paymentProductIds.add(pay.Product_Id__c);
                            }
                            for(String s : oliList.keySet())
                            {
                                if(paymentProductIds.contains(s))
                                {                               
                                    oliList.get(s).addError(errorMsg);
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    public void deleteRedemptionRecord(){ 
        Set<Id> oppProductIdSet = new Set<Id>();
        for(OpportunityLineItem oli:(List<OpportunityLineItem>)Trigger.old){
            oppProductIdSet.add(oli.Id);
        }
        List<Redemption__c> redDeleteList = [select id from Redemption__c where Opportunity_Product__c IN : oppProductIdSet];
        try{
            delete redDeleteList;
        }catch(Exception e){ 
            system.debug('--e--'+e);
        }
    }
    
    public void createRedemptionRecord(){
        List<Redemption__c> lstRedemption = new List<Redemption__c>();
        set<Id> setProductId = new set<Id>();
        for(Product2 objProduct : [select id from Product2 where Name = 'Vidanta Flyback-2 Additional Members TC' or Name = 'FlyBack MX' or Name = 'Hawaii Collection Plus Flyback' or Name = 'Vidanta Fly Back' or Name = 'Hawaii Collection Plus Flyback Extension' or Name = 'Hawaii Collection Plus TC' or Name = 'Back to Vidanta Pass TC' limit 7]){
            setProductId.add(objProduct.Id);
        }
        List<OpportunityLineItem> oppLineItem = [select id,OpportunityId,Product2.Name,Product2Id,Opportunity.StageName from OpportunityLineItem where ID In : trigger.newmap.keyset()];
        for(OpportunityLineItem oli:oppLineItem){
            system.debug('>>>>>>oli.Product2.Name>>>>>>'+oli.Product2.Name);
            system.debug('oli.Opportunity.StageName==='+oli.Opportunity.StageName);
            /*if(oli.Product2.Name == 'Reserve Usage Fee Relief Rewards'){
                Redemption__c objRedem = new Redemption__c();
                objRedem.Opportunity__c = oli.OpportunityId; 
                objRedem.Redemption_Type__c = 'Cash';
                objRedem.Opportunity_Product__c = oli.Id;
                system.debug('objRedem.Opportunity_Product__c'+objRedem.Opportunity_Product__c);
                lstRedemption.add(objRedem);
            }*/
            if(oli.Product2.Name == 'Back to Vidanta Pass TC'){ //oli.Opportunity.StageName == 'Closed Won' && 
                Redemption__c objRedem = new Redemption__c();
                objRedem.Opportunity__c = oli.OpportunityId; 
                objRedem.Redemption_Type__c = 'Credits';
                objRedem.Opportunity_Product__c = oli.Id;
                system.debug('objRedem.Opportunity_Product__c'+objRedem.Opportunity_Product__c);
                lstRedemption.add(objRedem);
            }
            else if((oli.Opportunity.StageName == 'Closed Won' && setProductId.contains(oli.Product2Id)) || oli.Product2.Name== 'FlyBack MX' || oli.Product2.Name == 'Hawaii Collection Plus TC' || oli.Product2.Name == 'Vidanta Flyback-2 Additional Members TC'){
                integer i=0;
                while(i<5){
                    Redemption__c objRedem = new Redemption__c();
                    objRedem.Opportunity__c = oli.OpportunityId; 
                    //objRedem.Status__c = 'Reservation Pending';
                    if(oli.Product2.Name== 'FlyBack MX' || oli.Product2.Name == 'Hawaii Collection Plus TC' || oli.Product2.Name == 'Vidanta Flyback-2 Additional Members TC'){
                        objRedem.Redemption_Type__c = 'Credits';
                    }
                    else{
                        objRedem.Redemption_Type__c = 'Cash';
                    }
                    objRedem.Opportunity_Product__c = oli.Id;
                    system.debug('objRedem.Opportunity_Product__c'+objRedem.Opportunity_Product__c);
                    lstRedemption.add(objRedem);
                    i++;
                }
            }
//            else if(oli.Opportunity.StageName == 'Closed Won' && ( oli.Product2.Name== 'Vida Flyback Rebate TC' || oli.Product2.Name == 'Vida Flyback TC' || oli.Product2.Name == 'Airfare Credit TC') ){
//		        system.debug('>>>create Redemption Vida Flyback Rebate TC...>>>>>>');
//                //&& setProductId.contains(oli.Product2Id)
//                integer i=0;
//                while(i<5){
//                    Redemption__c objRedem = new Redemption__c();
//                    objRedem.Opportunity__c = oli.OpportunityId; 
//                    //objRedem.Status__c = 'Reservation Pending';
//                    objRedem.Redemption_Amount__c = 1000;
//                    objRedem.Redemption_Type__c = 'Credits';
//                    objRedem.Opportunity_Product__c = oli.Id;
//                    system.debug('objRedem.Opportunity_Product__c'+objRedem.Opportunity_Product__c);
//                    lstRedemption.add(objRedem);
//                    i++;
//                }
//            }
        }
        system.debug('>>>>>>lstRedemption>>>>>>'+lstRedemption);
        if(lstRedemption != null && lstRedemption.size() > 0){
            insert lstRedemption;
        }
    }
    

    
    /*Ticket No. HSIMU2-564
Date Added -16-Jan-2024 
Developer - Shivani Chauhan*/
    public void addComplimentaryProduct(){
        List<OpportunityLineItem> oppLineItemNew = [select id,OpportunityId,Product2.Name,Product2Id,Opportunity.StageName from OpportunityLineItem where ID In : trigger.newmap.keyset() and Product2.Name = 'LuxGive-Auctioneer Grand Luxxe Two Bedroom Suite'];
        if(oppLineItemNew != null && oppLineItemNew.size() > 0){
            PriceBook2 pb2Standard = [select Id from Pricebook2 where isStandard=true];
            Product2 objProduct = [select id from Product2 where Name = 'Complimentary Transportation with Champagne' limit 1];
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
            
            List<OpportunityLineItem> opplineItemList = new List<OpportunityLineItem>();
            for(OpportunityLineItem oli : oppLineItemNew){
                if(oli.Product2.Name == 'LuxGive-Auctioneer Grand Luxxe Two Bedroom Suite'){
                    OpportunityLineItem opplineItem = new OpportunityLineItem();
                    opplineItem.OpportunityId = oli.OpportunityId;
                    opplineItem.Product2Id = objProduct.Id;
                    opplineItem.Retail_Price__c = 0;
                    opplineItem.Quantity = 1;
                    opplineItem.TotalPrice = 0;
                    opplineItem.PricebookEntryId = objpbEntry.Id;
                    opplineItemList.add(opplineItem);
                }
            }
            if(opplineItemList != null && opplineItemList.size() > 0){
                insert opplineItemList;
            }
        }
    }    
    public void blockGiftProductCreationBasedOnParentQuantitySold(){
        List<OpportunityLineItem> olisToCheck = new List<OpportunityLineItem>();
        Map<Id,Id> oliGiftAndParent = new Map<Id,Id>();
        Map<Id,Decimal> oliGiftNewQuantity = new Map<Id,Decimal>();
        
        for(OpportunityLineItem oli:(List<OpportunityLineItem>)Trigger.New){
            OpportunityLineItem oldOli = new OpportunityLineItem();
            if(Trigger.isUpdate)
            {
                oldOli = (OpportunityLineItem)Trigger.oldMap.get(oli.Id); 
            }
            else
            {
                oldOli = oli;
            }
            
            if((oli.Group_MX_Voucher_Product__c != null && Trigger.isInsert) || (Trigger.isUpdate && (oli.Group_MX_Voucher_Product__c != oldOli.Group_MX_Voucher_Product__c || oli.Quantity != oldOli.Quantity)))
            {                
                oliGiftAndParent.put(oli.Id,oli.Group_MX_Voucher_Product__c);                
                if(oliGiftNewQuantity.get(oli.Group_MX_Voucher_Product__c) != null){
                    Decimal currentQtt = oliGiftNewQuantity.get(oli.Group_MX_Voucher_Product__c);
                    currentQtt = currentQtt+oli.Quantity;
                    oliGiftNewQuantity.put(oli.Group_MX_Voucher_Product__c,currentQtt);
                }
                else
                {
                    oliGiftNewQuantity.put(oli.Group_MX_Voucher_Product__c,oli.Quantity);
                }                
                olisToCheck.add(oli);
            }
        }
        /*System.debug('oliGiftNewQuantity = '+oliGiftNewQuantity);
System.debug('oliGiftAndParent = '+oliGiftAndParent);
System.debug('olisToCheck = '+olisToCheck);*/
        
        if(oliGiftAndParent.size() > 0 && oliGiftAndParent != null)
        {
            List<OpportunityLineItem> oliParents = [SELECT Id,Quantity,(SELECT Id,Quantity FROM Group_MX_Recipient_Vouchers__r) FROM OpportunityLineItem WHERE Id IN : oliGiftAndParent.values()];
            
            Map<Id,Decimal> currentParentQuantity = new Map<Id,Decimal>();
            Map<Id,Decimal> currentGiftsQuantity = new Map<Id,Decimal>();
            
            for(OpportunityLineItem parent : oliParents)
            {
                currentParentQuantity.put(parent.Id,parent.Quantity);
                if(parent.Group_MX_Recipient_Vouchers__r != null)
                {
                    Decimal sumAux = 0;
                    for(OpportunityLineItem giftOli : parent.Group_MX_Recipient_Vouchers__r)
                    {
                        sumAux = sumAux+giftOli.Quantity;
                    }
                    currentGiftsQuantity.put(parent.Id,sumAux);
                }
                else
                {
                    currentGiftsQuantity.put(parent.Id,0);
                }
            }
            
            /*System.debug('currentParentQuantity = '+currentParentQuantity);
System.debug('currentGiftsQuantity = '+currentGiftsQuantity);*/
            
            for(OpportunityLineItem gift : olisToCheck){
                
                /*System.debug('oliGiftNewQuantity.get(gift.Group_MX_Voucher_Product__c) = '+oliGiftNewQuantity.get(gift.Group_MX_Voucher_Product__c));
System.debug('currentParentQuantity.get(gift.Group_MX_Voucher_Product__c) = '+currentParentQuantity.get(gift.Group_MX_Voucher_Product__c));
System.debug('currentGiftsQuantity.get(gift.Group_MX_Voucher_Product__c) = '+currentGiftsQuantity.get(gift.Group_MX_Voucher_Product__c));*/
                
                if(oliGiftNewQuantity.get(gift.Group_MX_Voucher_Product__c) != null && currentParentQuantity.get(gift.Group_MX_Voucher_Product__c) != null && currentGiftsQuantity.get(gift.Group_MX_Voucher_Product__c) != null)
                {
                    if((oliGiftNewQuantity.get(gift.Group_MX_Voucher_Product__c) + currentGiftsQuantity.get(gift.Group_MX_Voucher_Product__c)) > currentParentQuantity.get(gift.Group_MX_Voucher_Product__c))
                    {
                        gift.Group_MX_Voucher_Product__c.addError('Gift products (Group MX Recipient Voucher) quantity exceeding the sold parent product (Group MX Voucher) quantity');
                    }
                }
            }            
        }
    }
    
    //added 2023-07-06 - HSIMU2-117
    public void limitMUAddOnProductsQuantity(){
        //System.debug('limitMUAddOnProductsQuantity entered !');
        //Boolean hasAdminPermission = FeatureManagement.checkPermission('IsSystemAdmin');
        Id currentUserId = UserInfo.getUserId();
        Set<Id> oppIds = new Set<Id>();
        Set<Id> oppwithExitProductIds = new Set<Id>();
        List<OpportunityLineItem> olisToCheck = new List<OpportunityLineItem>();
        List<OpportunityLineItem> olisToCheckMUConflict = new List<OpportunityLineItem>();
        Map<String,Decimal> existingOlisQuantity = new Map<String,Decimal>();
        List<OpportunityLineItem> olisToAddError = new List<OpportunityLineItem>();
        List<OpportunityLineItem> olisToAddErrorMUConflict = new List<OpportunityLineItem>();
        List<String> productsWithLimit = new List<String>{'Cruise Certificate Add-On','Guest Cruise Certificate Add-On','MGM Certificate Add-On','Vidanta Fly Back','Vidanta Flyback-2 Additional Members','Hawaii Collection Plus Flyback Extension'};
            
            //added 2023-09-04 Block MU Products and Exit product created in the same opp
            List<String> muConflictProducts = new List<String>{'Exit Product for MU Team','Hawaii Collection Gold-Membership Upgrade','Hawaii Collection Platinum-Membership Upgrade','Hawaii Collection Silver-Membership Upgrade','MXN SFX Collection Membership Upgrade Diamond Premier','MXN SFX Membership Upgrade Diamond Preferred','SFX Diamond Plus-Membership Upgrade','SFX Diamond Preferred-Membership Upgrade','SFX Diamond Premier-Membership Upgrade','SFX Diamond-Membership Upgrade Vida Owner 1000','SFX Diamond-Membership Upgrade Vida Owner 3000','SFX Diamond-Membership Upgrade Vida Owner 5000','SFX Reinstatement-Diamond'};
                List<String> muProducts = new List<String>{'Hawaii Collection Gold-Membership Upgrade','Hawaii Collection Platinum-Membership Upgrade','Hawaii Collection Silver-Membership Upgrade','MXN SFX Collection Membership Upgrade Diamond Premier','MXN SFX Membership Upgrade Diamond Preferred','SFX Diamond Plus-Membership Upgrade','SFX Diamond Preferred-Membership Upgrade','SFX Diamond Premier-Membership Upgrade','SFX Diamond-Membership Upgrade Vida Owner 1000','SFX Diamond-Membership Upgrade Vida Owner 3000','SFX Diamond-Membership Upgrade Vida Owner 5000','SFX Reinstatement-Diamond'};
                    Map<String,Decimal> exitQtt = new Map<String,Decimal>();
        Map<String,Decimal> muQtt = new Map<String,Decimal>();
        
        //if(!hasAdminPermission){
        //List<User> userList = [SELECT Id,UserRole.Name,Profile.Name FROM User WHERE Id =: currentUserId AND UserRoleId != null AND ProfileId != null AND UserRole.Name != NULL and Profile.Name != NULL];
        //if(userList != null && userList.size()>0){
        //User u = userList[0];
        //if(u.Profile.Name != 'System Administrator'){                        
        for(OpportunityLineItem oli:(List<OpportunityLineItem>)Trigger.New){
            if(oli.Opportunity_Record_Type_Developer_Name__c == 'Hawaii_Collection_Membership' || oli.Opportunity_Record_Type_Developer_Name__c == 'SFX_Membership' || oli.Opportunity_Record_Type_Developer_Name__c == 'Membership_Upgrade'){
                if(oli.Price_Book_Entry_Name__c != null && oli.Price_Book_Entry_Name__c != ''){
                    if(productsWithLimit.contains(oli.Price_Book_Entry_Name__c) && oli.Quantity > 1){
                        olisToAddError.add(oli);
                    }
                    else if(productsWithLimit.contains(oli.Price_Book_Entry_Name__c) && oli.Quantity == 1){
                        oppIds.add(oli.OpportunityId);
                        olisToCheck.add(oli);
                    }                        
                }
            }
            if(muConflictProducts.contains(oli.Price_Book_Entry_Name__c)){
                oppwithExitProductIds.add(oli.OpportunityId);
                olisToCheckMUConflict.add(oli);
                if(oli.Price_Book_Entry_Name__c == 'Exit Product for MU Team')
                {
                    exitQtt.put(oli.OpportunityId,1);
                }
                else
                {
                    muQtt.put(oli.OpportunityId,1);
                }
            }
        }
        
        //System.debug('olisToAddError = '+olisToAddError);
        //System.debug('olisToCheck = '+olisToCheck);
        
        if(oppIds != null && !oppIds.isEmpty())
        {
            List<OpportunityLineItem> existingOlis = [SELECT Id,OpportunityId,Product2.Name,Quantity FROM OpportunityLineItem WHERE Product2.Name IN : productsWithLimit AND OpportunityId IN : oppIds];
            for(OpportunityLineItem oppLineItem : existingOlis){
                if(existingOlisQuantity.get(oppLineItem.OpportunityId+''+oppLineItem.Product2.Name) == null)
                {
                    existingOlisQuantity.put(oppLineItem.OpportunityId+''+oppLineItem.Product2.Name,oppLineItem.Quantity);
                }
                else if(existingOlisQuantity.get(oppLineItem.OpportunityId+''+oppLineItem.Product2.Name) != null)
                {
                    Decimal newQtt = existingOlisQuantity.get(oppLineItem.OpportunityId+''+oppLineItem.Product2.Name);
                    newQtt = newQtt+oppLineItem.Quantity;
                    existingOlisQuantity.put(oppLineItem.OpportunityId+''+oppLineItem.Product2.Name,newQtt);
                }
            }
            
            //System.debug('existingOlisQuantity = '+existingOlisQuantity);
            
            for(OpportunityLineItem oppLine : olisToCheck)
            {
                if(existingOlisQuantity.get(oppLine.OpportunityId+''+oppLine.Price_Book_Entry_Name__c) != null)
                {
                    if(existingOlisQuantity.get(oppLine.OpportunityId+''+oppLine.Price_Book_Entry_Name__c) >= 1)
                    {
                        olisToAddError.add(oppLine);
                    }
                }
            }
            
            //System.debug('olisToAddError = '+olisToAddError);                                            
        }
        if(oppwithExitProductIds != null && !oppwithExitProductIds.isEmpty())
        {
            List<OpportunityLineItem> existingOlis = [SELECT Id,OpportunityId,Product2.Name,Quantity FROM OpportunityLineItem WHERE Product2.Name IN : muConflictProducts AND OpportunityId IN : oppwithExitProductIds];
            for(OpportunityLineItem oppLineItem : existingOlis){
                if(oppLineItem.Product2.Name == 'Exit Product for MU Team')
                {
                    if(exitQtt.get(oppLineItem.OpportunityId) != null)
                    {
                        Decimal exitProductQtt = exitQtt.get(oppLineItem.OpportunityId);
                        exitProductQtt = exitProductQtt + 1;
                        exitQtt.put(oppLineItem.OpportunityId,exitProductQtt);
                    }
                    else
                    {
                        exitQtt.put(oppLineItem.OpportunityId,1);
                    }
                }
                else
                {
                    if(muQtt.get(oppLineItem.OpportunityId) != null)
                    {
                        Decimal muProductQtt = muQtt.get(oppLineItem.OpportunityId);
                        muProductQtt = muProductQtt + 1;
                        muQtt.put(oppLineItem.OpportunityId,muProductQtt);
                    }
                    else
                    {
                        muQtt.put(oppLineItem.OpportunityId,1);
                    }
                }
            }
            //System.debug('existingOlisQuantity = '+existingOlisQuantity);
            
            for(OpportunityLineItem oppLine : olisToCheckMUConflict)
            {
                if(exitQtt.get(oppLine.OpportunityId) != null && muQtt.get(oppLine.OpportunityId) != null)
                {
                    olisToAddErrorMUConflict.add(oppLine);
                }
            }
            //System.debug('olisToAddError = '+olisToAddError);                                            
        }
        if(olisToAddError != null && olisToAddError.size()>0)
        {
            for(OpportunityLineItem oliWithError : olisToAddError)
            {
                oliWithError.Quantity.addError('The following Add-On Products should be limited to a Quantity of 1 : '+productsWithLimit);
            }
        }
        /*Boolean hasAdminPermission = FeatureManagement.checkPermission('IsSystemAdmin');        
if(!hasAdminPermission){*/
        
        if(olisToAddErrorMUConflict != null && olisToAddErrorMUConflict.size()>0)
        {
            for(OpportunityLineItem oliWithError2 : olisToAddErrorMUConflict)
            {
                oliWithError2.addError('It\'s not possible to have SFX or Hawaii Collection Membership Upgrade products with the product "Exit Product for MU Team" in the same opportunity.');
            }
        }
        /*}}}}*/
    }

    //TGR-859
    // Create ContentNote attached to the record
    private static void insertNote() {
        system.debug('starting insertNote()');
        List<ContentNote> notesToInsert = new List<ContentNote>();
        List<ContentDocumentLink> linksToInsert = new List<ContentDocumentLink>();
        
        for (OpportunityLineItem oli : (List<OpportunityLineItem>) Trigger.new) {
            OpportunityLineItem oldOli = (OpportunityLineItem) Trigger.oldMap.get(oli.Id);
            
            // Check if File_Fee__c changed
            if (oli.File_Fee__c != oldOli.File_Fee__c) {
                String oldValue = String.valueOf(oldOli.File_Fee__c);
                String newValue = String.valueOf(oli.File_Fee__c);
                String userName = UserInfo.getName();
                
                // Create ContentNote
                ContentNote note = new ContentNote();
                note.Title = 'File Fee Updated';
                note.Content = Blob.valueOf(
                    'The File_Fee__c field was updated on ' +
                    String.valueOf(Datetime.now().format('yyyy-MM-dd HH:mm:ss z')) + 
                    '\n  Old Value: ' + oldValue + 
                    '\n  New Value: ' + newValue + 
                    '\n  User: ' + userName
                );
                notesToInsert.add(note);
            }
        }
        
        if (!notesToInsert.isEmpty()) {
            insert notesToInsert;
            
            // Link each note to its parent Opportunity
            Integer index = 0;
            for (OpportunityLineItem oli : (List<OpportunityLineItem>) Trigger.new) {
                OpportunityLineItem oldOli = (OpportunityLineItem) Trigger.oldMap.get(oli.Id);
                
                if (oli.File_Fee__c != oldOli.File_Fee__c) {
                    ContentDocumentLink link = new ContentDocumentLink();
                    link.ContentDocumentId = notesToInsert[index].Id;
                    link.LinkedEntityId = oli.OpportunityId;
                    link.ShareType = 'V'; // Viewer
                    link.Visibility = 'AllUsers';
                    linksToInsert.add(link);
                    index++;
                }
            }
            
            insert linksToInsert;
        }
    }
    

	//MSR-288    
/*
     public void createLuxuryExcursion(){
        List<Luxury_Excursion__c> lstLuxExc = new List<Luxury_Excursion__c>();
        set<Id> setProductId = new set<Id>();
        for(Product2 objProduct : [select id from Product2 where Name = 'Luxury Excursion Bundle' or Name = 'Luxury Excursion-Yacht' or Name = 'Luxury Excursion' limit 7]){
            setProductId.add(objProduct.Id);
        }
        List<OpportunityLineItem> oppLineItem = [select id,OpportunityId,Product2.Name,Product2Id,Opportunity.StageName from OpportunityLineItem where ID In : trigger.newmap.keyset()];
        for(OpportunityLineItem oli:oppLineItem){
            system.debug('>>>>>>oli.Product2.Name>>>>>>'+oli.Product2.Name);
            system.debug('oli.Opportunity.StageName==='+oli.Opportunity.StageName);
            if( oli.Product2.Name == 'Luxury Excursion Bundle'){  //oli.Opportunity.StageName == 'Closed Won' &&
                Luxury_Excursion__c objLuxExc = new Luxury_Excursion__c();
                objLuxExc.Opportunity__c = oli.OpportunityId; 
                objLuxExc.Opportunity_Product__c = oli.Id;
                system.debug('objLuxExc.Opportunity_Product__c'+objLuxExc.Opportunity_Product__c);
                lstLuxExc.add(objLuxExc);

                Luxury_Excursion__c objLuxExc1 = new Luxury_Excursion__c();
                objLuxExc1.Opportunity__c = oli.OpportunityId; 
                objLuxExc1.Opportunity_Product__c = oli.Id;
                system.debug('objLuxExc1.Opportunity_Product__c'+objLuxExc1.Opportunity_Product__c);
                lstLuxExc.add(objLuxExc1);

                Luxury_Excursion__c objLuxExc2 = new Luxury_Excursion__c();
                objLuxExc2.Opportunity__c = oli.OpportunityId; 
                objLuxExc2.Opportunity_Product__c = oli.Id;
                system.debug('objLuxExc2.Opportunity_Product__c'+objLuxExc2.Opportunity_Product__c);
                lstLuxExc.add(objLuxExc2);
            }
            else if(oli.Product2.Name == 'Luxury Excursion-Yacht'){ 
                Luxury_Excursion__c objLuxExc = new Luxury_Excursion__c();
                objLuxExc.Opportunity__c = oli.OpportunityId; 
                objLuxExc.Opportunity_Product__c = oli.Id;
                system.debug('objLuxExc.Opportunity_Product__c'+objLuxExc.Opportunity_Product__c);
                lstLuxExc.add(objLuxExc);
            }
            else if(oli.Product2.Name == 'Luxury Excursion'){ 
                Luxury_Excursion__c objLuxExc = new Luxury_Excursion__c();
                objLuxExc.Opportunity__c = oli.OpportunityId; 
                objLuxExc.Opportunity_Product__c = oli.Id;
                system.debug('objLuxExc.Opportunity_Product__c'+objLuxExc.Opportunity_Product__c);
                lstLuxExc.add(objLuxExc);
            }
            
        }
        system.debug('>>>>>>lstLuxExc>>>>>>'+lstLuxExc);
        if(lstLuxExc != null && lstLuxExc.size() > 0){
            insert lstLuxExc;
        }
    }
*/

    
    //MSR-288    
/*
     public void deleteLuxuryExcursion(){ 
        Set<Id> oppProductIdSet = new Set<Id>();
        for(OpportunityLineItem oli:(List<OpportunityLineItem>)Trigger.old){
            oppProductIdSet.add(oli.Id);
        }
        List<Luxury_Excursion__c> lstLuxExc = [select id from Luxury_Excursion__c where Opportunity_Product__c IN : oppProductIdSet];
        try{
            delete lstLuxExc;
        }catch(Exception e){ 
            system.debug('--e--'+e);
        }
    }
*/
    
}