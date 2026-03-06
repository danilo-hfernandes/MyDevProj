@isTest(seeAllData=false)
public class OpportunityTrigger_New_Test {
    
    @testSetup static void methodName() {
        Apex_Trigger_On_Off__c obj = new Apex_Trigger_On_Off__c();
        obj.Name = 'OpportunityTrigger_New';
        obj.isEnable__c = true;
        insert obj;
        
        Apex_Trigger_On_Off__c obj1 = new Apex_Trigger_On_Off__c();
        obj1.Name = 'OppcloseWonErrorFromTrigger';
        obj1.isEnable__c = true;
        insert obj1;
        
        MU_Jobs_test_Record_Filter__c obj2 = new MU_Jobs_test_Record_Filter__c();
        obj2.Name = 'Filters Enabled';
        obj2.Any_Test_Record__c = true;
        insert obj2;
    }
    
    @isTest
    static void Test1() {
        Account acc = new Account(Name = 'Test Account', Affiliated_Id__c = 1002421, Member_Number__c = '13523412', Contact_Id__c = 5420.0);
        insert acc;
        
        Contact con = new Contact();
        con.FirstName = 'Test';
        con.LastName = 'Account';
        con.AccountId = acc.Id;
        con.Affiliate_Name__c='test';
        con.Member_Number__c = '13523413';
        insert con; 
        
        Case c = new Case();
        c.status = 'New';
        c.Type = 'Membership Upgrade';
        
        insert c;
        
        
        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 standardPricebook = new Pricebook2(
            Id = pricebookId,
            IsActive = true
        );
        update standardPricebook;
        Id  standardPb = standardPricebook.Id;
        Pricebook2 pbk1 = new Pricebook2 (Name='Test Pricebook Entry 1',Description='Test Pricebook Entry 1', isActive=true);
        insert pbk1;
        
        Product2 prd1 = new Product2 (Name='Vacation VIP Membership Upgrade',Description='Test Product Entry 1', isActive = true);
        insert prd1;
        
        
        PricebookEntry pbe1 = new PricebookEntry (Product2ID=prd1.id,Pricebook2ID=standardPb,UnitPrice=399, isActive=true);
        insert pbe1;
        
        Id travelOppRecType = [Select id from RecordType where sObjectType = 'Opportunity' and developerName ='Travel' ].id ;
        Opportunity opp1 = new Opportunity (Name='Opp1_test',StageName='Negotiation',RC_Duplicate__c= true,CloseDate=Date.today(),Pricebook2Id = pbe1.Pricebook2Id, Upgrade_Type__c = 'Hawaii Collection Silver-Membership Upgrade', AccountId = acc.id, Auto_Created_BU_Opp__c = true, RecordTypeId = travelOppRecType, Match_Group_Name__c= 'Travel Sales-Web Form Inquiry');
        insert opp1;
        
        Id voucherRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('VI_Referral_Date_Request').getRecordTypeId();
        Opportunity opp2 = new Opportunity (Name='Opp2',StageName='New',Reservation_Status__c= 'Pending', CloseDate=Date.today(),First_Payment_Date__c = system.today().addDays(2),Pricebook2Id = pbe1.Pricebook2Id, Upgrade_Type__c = 'Hawaii Collection Gold-Membership Upgrade', AccountId = acc.id, Auto_Created_BU_Opp__c = true, RecordTypeId = voucherRecordTypeId);
        insert opp2;
        
        opp2.StageName = 'Closed Won';
        opp2.Check_in_Flex__c  = system.today();
        opp2.Cruise_Certificate_Status__c = 'Booked'; 
        update opp2;
        
        Id membershipAnnualDuesId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Membership_Annual_Dues').getRecordTypeId();
        Opportunity opp5 = new Opportunity (Name='Opp2',StageName='New', Opportunity_Record_Type_Id_From_Lead__c='Membership_Upgrade', LeadSource = 'Vacation VIP - Web', CloseDate=Date.today(),First_Payment_Date__c = system.today().addDays(2),Pricebook2Id = pbe1.Pricebook2Id, AccountId = acc.id, RecordTypeId = membershipAnnualDuesId);
        insert opp5;
        
        //0123t000000GB7ZAAW
        /* Id recordTypeId = Label.Opp_Membership_Enrollment_Fee_Id;

Opportunity opp3 = new Opportunity (Name='Opp2',StageName='New',Reservation_Status__c= 'Pending', CloseDate=Date.today(),First_Payment_Date__c = system.today().addDays(2),Pricebook2Id = pbe1.Pricebook2Id, Upgrade_Type__c = 'Hawaii Collection Gold-Membership Upgrade', AccountId = acc.id, Auto_Created_BU_Opp__c = true, RecordTypeId = recordTypeId);
insert opp3;*/
        
        OpportunityLineItem lineItem1 = new OpportunityLineItem (OpportunityID=opp1.id,PriceBookEntryID=pbe1.id, quantity=4, totalprice=200, retail_price__c = 99);
        //insert lineItem1;
        
        update opp1;
        
        //2024-01-03 - HSIMU2-520 Ghost Travel Opportunities
        //map from account
        Test.startTest();
        Opportunity opp3 = new Opportunity (Name='Travel Sales Opp',StageName='New',CloseDate=Date.today(),Member_Number__c = '13523412', RecordTypeId = travelOppRecType);
        insert opp3;
        
        //map from contact
        Opportunity opp4 = new Opportunity (Name='Travel Sales Opp',StageName='New',CloseDate=Date.today(),Member_Number__c = '13523413', RecordTypeId = travelOppRecType);
        insert opp4;
        
        
        Test.stopTest();
    }
     @isTest
    static void Test1a() {
        Account acc = new Account(Name = 'Test Account', Affiliated_Id__c = 1002421, Member_Number__c = '13523412', Contact_Id__c = 5420.0);
        insert acc;
        
        Contact con = new Contact();
        con.FirstName = 'Test';
        con.LastName = 'Account';
        con.AccountId = acc.Id;
        con.Affiliate_Name__c='test';
        con.Member_Number__c = '13523413';
        insert con;         
        
        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 standardPricebook = new Pricebook2(
            Id = pricebookId,
            IsActive = true
        );
        update standardPricebook;
        Id  standardPb = standardPricebook.Id;
        Pricebook2 pbk1 = new Pricebook2 (Name='Test Pricebook Entry 1',Description='Test Pricebook Entry 1', isActive=true);
        insert pbk1;
        
        Product2 prd1 = new Product2 (Name='Vida Voucher-Flex Date Request',Description='Test Product Entry 1', isActive = true);
        insert prd1;
        
        
        PricebookEntry pbe1 = new PricebookEntry (Product2ID=prd1.id,Pricebook2ID=standardPb,UnitPrice=399, isActive=true);
        insert pbe1;
        
        Product2 prd2 = new Product2 (Name='Westgate Orlando 4 Day/3 Night',Description='Test Product Entry 1', isActive = true);
        insert prd2;
        
        
        PricebookEntry pbe2 = new PricebookEntry (Product2ID=prd2.id,Pricebook2ID=standardPb,UnitPrice=399, isActive=true);
        insert pbe2;
        
        Id membershipAnnualDuesId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Membership_Annual_Dues').getRecordTypeId();
        Opportunity opp1 = new Opportunity (Name='Opp1',StageName='New', Opportunity_Record_Type_Id_From_Lead__c='Membership_Upgrade', LeadSource = 'VI Referral', CloseDate=Date.today(),First_Payment_Date__c = system.today().addDays(2),Pricebook2Id = pbe1.Pricebook2Id, AccountId = acc.id, RecordTypeId = membershipAnnualDuesId);
        insert opp1;
        
        Opportunity opp2 = new Opportunity (Name='Opp2',StageName='New', Opportunity_Record_Type_Id_From_Lead__c='Membership_Upgrade', LeadSource = 'VVIP Westgate Orlando', Qualified_Offer__c='Westgate Orlando',CloseDate=Date.today(),First_Payment_Date__c = system.today().addDays(2),Pricebook2Id = pbe2.Pricebook2Id, AccountId = acc.id, RecordTypeId = membershipAnnualDuesId);
        insert opp2;
        
    }
    
    @isTest
    static void Test2() {
        Account acc = new Account(Name = 'Test Account', Affiliated_Id__c = 1002465);
        insert acc;
        
        //Pricebook2  standardPb = [select id, name, isActive from Pricebook2 where IsStandard = true limit 1];
        Id  standardPb = Test.getStandardPricebookId();
        Pricebook2 pbk1 = new Pricebook2 (Name='Test Pricebook Entry 1',Description='Test Pricebook Entry 1', isActive=true);
        insert pbk1;
        
        Product2 prd1 = new Product2 (Name='Test Product Entry 1',Description='Test Product Entry 1', isActive = true);
        insert prd1;
        
        
        PricebookEntry pbe1 = new PricebookEntry (Product2ID=prd1.id,Pricebook2ID=standardPb,UnitPrice=50, isActive=true);
        insert pbe1;
        
        Opportunity opp1 = new Opportunity (Name='Opp1',StageName='Negotiation',Opp_Original_Source__c = 'Marival Affiliate Marketing',Opportunity_Record_Type_Id_From_Lead__c='Membership_Upgrade',CloseDate=Date.today(),Pricebook2Id = pbe1.Pricebook2Id, Upgrade_Type__c = 'Hawaii Collection Gold-Membership Upgrade', AccountId = acc.id, Auto_Created_BU_Opp__c = true);
        insert opp1;
        
        
        OpportunityLineItem lineItem1 = new OpportunityLineItem (OpportunityID=opp1.id,PriceBookEntryID=pbe1.id, quantity=4, totalprice=200, retail_price__c = 99);
        insert lineItem1;
        
        update opp1;
    }
    
    @isTest
    static void Test2a() {
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        
        //Pricebook2  standardPb = [select id, name, isActive from Pricebook2 where IsStandard = true limit 1];
        Id  standardPb = Test.getStandardPricebookId();
        Pricebook2 pbk1 = new Pricebook2 (Name='Test Pricebook Entry 1',Description='Test Pricebook Entry 1', isActive=true);
        insert pbk1;
        
        Product2 prd1 = new Product2 (Name='Test Product Entry 1',Description='Test Product Entry 1', isActive = true);
        insert prd1;
        
        
        PricebookEntry pbe1 = new PricebookEntry (Product2ID=prd1.id,Pricebook2ID=standardPb,UnitPrice=50, isActive=true);
        insert pbe1;
        
        Id voucherSalesRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Travel').getRecordTypeId();
        
        Opportunity opp1 = new Opportunity (Name='Opp1',StageName='Duplicate',Member_Number__c='test',CloseDate=Date.today(),Pricebook2Id = pbe1.Pricebook2Id, Upgrade_Type__c = 'Hawaii Collection Gold-Membership Upgrade', AccountId = null, Auto_Created_BU_Opp__c = true,recordtypeid=voucherSalesRecordTypeId);
        insert opp1;
        
        opp1.StageName = 'Closed Won';
        opp1.RecordTypeId = voucherSalesRecordTypeId;
        
        Id membershipAddonId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Membership_Add_On').getRecordTypeId();
        Opportunity opp2 = new Opportunity (Check_in__c=system.today(),Name='Opp2',StageName='Negotiation',CloseDate=Date.today(),Pricebook2Id = pbe1.Pricebook2Id,Enrollment_Fee__c = 99, AccountId = acc.id, RecordTypeId = membershipAddonId);
        insert opp2;
        
        
        OpportunityLineItem lineItem1 = new OpportunityLineItem (OpportunityID=opp1.id,PriceBookEntryID=pbe1.id, quantity=4, totalprice=200, retail_price__c = 99);
        insert lineItem1;
        
        Inventory_Management__c invt = new Inventory_Management__c();
        insert invt;
        
        Inventory_Availability__c inav = new Inventory_Availability__c();
        inav.Inventory_Management__c= invt.Id;
        inav.Resort_Name__c='testabc';
        inav.Check_In_Date__c=system.today();
        inav.New_Availability__c=1;
        inav.Plaza__c='VALLARTA';
        inav.Program__c='MTK';
        insert inav;
        
        opp1.Inventory_Availability_Id__c=inav.id;
        update opp1;
        OpportunityTriggerHandler.updateOppInfutue(opp1.Id, inav.Id);
    }
    
    @isTest
    static void Test3() {
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        
        //Pricebook2  standardPb = [select id, name, isActive from Pricebook2 where IsStandard = true limit 1];
        Id  standardPb = Test.getStandardPricebookId();
        Pricebook2 pbk1 = new Pricebook2 (Name='Test Pricebook Entry 1',Description='Test Pricebook Entry 1', isActive=true);
        insert pbk1;
        
        Product2 prd1 = new Product2 (Name='Test Product Entry 1',Description='Test Product Entry 1', isActive = true);
        insert prd1;
        
        
        PricebookEntry pbe1 = new PricebookEntry (Product2ID=prd1.id,Pricebook2ID=standardPb,UnitPrice=50, isActive=true);
        insert pbe1;
        
        Opportunity opp1 = new Opportunity (Check_in__c=system.today(),Name='Opp1',StageName='Negotiation',CloseDate=Date.today(),Pricebook2Id = pbe1.Pricebook2Id,Enrollment_Fee__c = 99, AccountId = acc.id, RecordTypeId = System.Label.Opp_Membership_Enrollment_Fee_Id);
        insert opp1;
        
        
        OpportunityLineItem lineItem1 = new OpportunityLineItem (OpportunityID=opp1.id,PriceBookEntryID=pbe1.id, quantity=4, totalprice=200, retail_price__c = 99);
        insert lineItem1;
        opp1.Check_in__c = system.today().adddays(20);
        opp1.Reservation_Status__c = 'Cancel';
        update opp1;
    }
    
    @isTest
    static void Test4() {
        Test.startTest();
        Account acc = new Account(Name = 'Test Account', Affiliated_Id__c = 1002421,Member_Number__c='Af-09-987', Contact_Id__c=0875533);
        insert acc;
        
        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 standardPricebook = new Pricebook2(
            Id = pricebookId,
            IsActive = true
        );
        update standardPricebook;
        Id  standardPb = standardPricebook.Id;
        Pricebook2 pbk1 = new Pricebook2 (Name='Test Pricebook Entry 1',Description='Test Pricebook Entry 1', isActive=true);
        insert pbk1;
        
        Product2 prd1 = new Product2 (Name='Affiliate Marketing MX Voucher',Description='Test Product Entry 1', isActive = true);
        insert prd1;
        
        
        PricebookEntry pbe1 = new PricebookEntry (Product2ID=prd1.id,Pricebook2ID=standardPb,UnitPrice=399, isActive=true);
        insert pbe1;
        
        Id vouchRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Voucher').getRecordTypeId();
        Opportunity opp2 = new Opportunity (Name='Opp2',StageName='New', CloseDate=Date.today(),Pricebook2Id =pbe1.Pricebook2Id, AccountId = acc.id, RecordTypeId = vouchRecordTypeId);
        insert opp2;
        
        Opportunity opp1 = new Opportunity (Name='Opp1',StageName='Negotiation',CloseDate=Date.today(),Pricebook2Id = pbe1.Pricebook2Id,Annual_Dues__c = 99, AccountId = acc.id, RecordTypeId = System.Label.Opp_Membership_Annual_Dues);
        insert opp1;
        
        OpportunityLineItem lineItem1 = new OpportunityLineItem (OpportunityID=opp1.id,PriceBookEntryID=pbe1.id, quantity=4, totalprice=200, retail_price__c = 99);
        insert lineItem1;
        
        update opp1;
        Test.stopTest();
    }
    
    @isTest
    static void Test5() {
        
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        
        //Pricebook2  standardPb = [select id, name, isActive from Pricebook2 where IsStandard = true limit 1];
        Id  standardPb = Test.getStandardPricebookId();
        Pricebook2 pbk1 = new Pricebook2 (Name='Test Pricebook Entry 1',Description='Test Pricebook Entry 1', isActive=true);
        insert pbk1;
        
        Product2 prd1 = new Product2 (Name='Test Product Entry 1',Description='Test Product Entry 1', isActive = true);
        insert prd1;
        
        
        PricebookEntry pbe1 = new PricebookEntry (Product2ID=prd1.id,Pricebook2ID=standardPb,UnitPrice=50, isActive=true);
        insert pbe1;
        
        Opportunity opp1 = new Opportunity (Name='Opp1',StageName='Negotiation',CloseDate=Date.today(),Pricebook2Id = pbe1.Pricebook2Id, Upgrade_Type__c = 'Hawaii Collection Platinum-Membership Upgrade', AccountId = acc.id, Auto_Created_BU_Opp__c = true);
        insert opp1;
        
        
        OpportunityLineItem lineItem1 = new OpportunityLineItem (OpportunityID=opp1.id,PriceBookEntryID=pbe1.id, quantity=4, totalprice=200, retail_price__c = 99);
        insert lineItem1;
    }
    
    @isTest
    static void Test6() {
        
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        
        //Pricebook2  standardPb = [select id, name, isActive from Pricebook2 where IsStandard = true limit 1];
        Id  standardPb = Test.getStandardPricebookId();
        Pricebook2 pbk1 = new Pricebook2 (Name='Test Pricebook Entry 1',Description='Test Pricebook Entry 1', isActive=true);
        insert pbk1;
        
        Product2 prd1 = new Product2 (Name='Test Product Entry 1',Description='Test Product Entry 1', isActive = true);
        insert prd1;
        
        
        PricebookEntry pbe1 = new PricebookEntry (Product2ID=prd1.id,Pricebook2ID=standardPb,UnitPrice=50, isActive=true);
        insert pbe1;
        
        Id voucherRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Voucher').getRecordTypeId();
        
        Opportunity opp1 = new Opportunity (Name='Opp1',RecordTypeId=voucherRecordTypeId, First_Payment_Made__c= true,StageName='New',CloseDate=Date.today(),Pricebook2Id = pbe1.Pricebook2Id, Upgrade_Type__c = 'SFX Diamond Plus-Membership Upgrade', AccountId = acc.id, Auto_Created_BU_Opp__c = true);
        insert opp1;
        
        
        OpportunityLineItem lineItem1 = new OpportunityLineItem (OpportunityID=opp1.id,PriceBookEntryID=pbe1.id, quantity=4, totalprice=200, retail_price__c = 99);
        insert lineItem1;
        
        opp1.StageName = 'Closed Won';
        update opp1;
        
        delete opp1;
    }
    @isTest
    static void Test7() {
        Account acc = new Account(Name = 'Test Account32');
        insert acc;
        
        Id opprecordtypeid = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Membership_Upgrade').getRecordTypeId();
        
        Opportunity opp1 = new Opportunity (Name='Opp1',
                                            StageName='Closed Won',
                                            CloseDate=Date.today(),
                                            Upgrade_Type__c = 'SFX Diamond Preferred-Membership Upgrade', 
                                            AccountId = acc.id, 
                                            RecordTypeId = opprecordtypeid);
        insert opp1;
        Test.startTest();
        Product2 p = new Product2();
        p.Name = 'Equity Value';
        p.isActive = true;
        insert p;
        
        id pricebookId = Test.getStandardPricebookId();
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = p.Id, UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        
        OpportunityLineItem lineItem1 = new OpportunityLineItem();
        lineItem1.OpportunityId = opp1.Id;
        lineItem1.UnitPrice = 7500;
        lineItem1.Product2Id = p.id;
        lineItem1.PricebookEntryId = standardPrice.id;
        lineItem1.Quantity = 1;
        lineItem1.Retail_Price__c = 20;
        
        
        insert lineItem1;
        
        Test.stopTest();
    }
    @isTest
    static void Test8() {
        
        Test.setMock(HttpCalloutMock.class, new AssigningContactInCadenceTestMock());
        Account acc = new Account(Name = 'Test Account32');
        insert acc;
        
        Contact con = new Contact();
        con.FirstName = 'Test';
        con.LastName = 'Account32';
        con.AccountId = acc.Id;
        con.Affiliate_Name__c='test';
        
        // con.Same_Name_as_Account_Name__c = true;
        insert con;  
        
        //Pricebook2  standardPb = [select id, name, isActive from Pricebook2 where IsStandard = true limit 1];
        Id  standardPb = Test.getStandardPricebookId();
        Pricebook2 pbk1 = new Pricebook2 (Name='Test Pricebook Entry 1',Description='Test Pricebook Entry 1', isActive=true);
        insert pbk1;
        
        Product2 prd1 = new Product2 (Name='Affiliate Marketing MX Voucher',Description='Test Product Entry 1', isActive = true);
        insert prd1;
        
        
        PricebookEntry pbe1 = new PricebookEntry (Product2ID=prd1.id,Pricebook2ID=standardPb,UnitPrice=0, isActive=true);
        insert pbe1;
        
        Id opprecordtypeid = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Voucher').getRecordTypeId();
        
        Opportunity opp1 = new Opportunity (Name='Opp1',StageName='New',
                                            CloseDate=Date.today(),
                                            Pricebook2Id = pbe1.Pricebook2Id, Upgrade_Type__c = 'SFX Diamond Premier-Membership Upgrade', 
                                            AccountId = acc.id,
                                            Reservation_Status__c='',
                                            leadassist__Use_Round_Robin__c='TRUE',
                                            Booking_Agent__c = UserInfo.getUserId(),
                                            RecordTypeId = opprecordtypeid);
        insert opp1;
        
        //opp1.Name = 'NewTest Opp1';
        opp1.StageName='Closed Won';
        opp1.Original_Confirmation__c = false;
        opp1.leadassist__Use_Round_Robin__c='ASSIGNED';
        update opp1;
        
    }
    
    @isTest
    static void Test9() {
        
        Test.setMock(HttpCalloutMock.class, new AssigningContactInCadenceTestMock());
        Account acc = new Account(Name = 'Test Account32');
        insert acc;
        
        Contact con = new Contact();
        con.FirstName = 'Test';
        con.LastName = 'Account32';
        con.AccountId = acc.Id;
        con.Affiliate_Name__c='test';
        
        // con.Same_Name_as_Account_Name__c = true;
        insert con;  
        
        //Pricebook2  standardPb = [select id, name, isActive from Pricebook2 where IsStandard = true limit 1];
        Id  standardPb = Test.getStandardPricebookId();
        Pricebook2 pbk1 = new Pricebook2 (Name='Test Pricebook Entry 1',Description='Test Pricebook Entry 1', isActive=true);
        insert pbk1;
        
        Product2 prd1 = new Product2 (Name='Test Product Entry 1',Description='Test Product Entry 1', isActive = true);
        insert prd1;
        
        
        PricebookEntry pbe1 = new PricebookEntry (Product2ID=prd1.id,Pricebook2ID=standardPb,UnitPrice=50, isActive=true);
        insert pbe1;
        
        Id opprecordtypeid = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Voucher').getRecordTypeId();
        
        Opportunity opp1 = new Opportunity (Name='Opp1',StageName='New',
                                            CloseDate=Date.today(),
                                            Pricebook2Id = pbe1.Pricebook2Id, Upgrade_Type__c = 'SFX Diamond Premier-Membership Upgrade', 
                                            AccountId = acc.id,
                                            Reservation_Status__c='',
                                            leadassist__Use_Round_Robin__c='TRUE',
                                            Booking_Agent__c = UserInfo.getUserId(),
                                            RecordTypeId = opprecordtypeid);
        insert opp1;
        
        //opp1.Name = 'NewTest Opp1';
        opp1.StageName='Closed Won';
        opp1.First_Payment_Date__c = Date.newInstance(2022,8,7);
        opp1.Original_Confirmation__c = false;
        opp1.leadassist__Use_Round_Robin__c='ASSIGNED';
        update opp1; 
        
        opp1.First_Payment_Date__c = Date.newInstance(2022,8,8);
        update opp1; 
    }
    
    @isTest
    static void Test10() {
        
        Test.setMock(HttpCalloutMock.class, new AssigningContactInCadenceTestMock());
        Account acc = new Account(Name = 'Test Account32');
        insert acc;
        
        Contact con = new Contact();
        con.FirstName = 'Test';
        con.LastName = 'Account32';
        con.AccountId = acc.Id;
        con.Affiliate_Name__c='test';
        
        // con.Same_Name_as_Account_Name__c = true;
        insert con;  
        
        //Pricebook2  standardPb = [select id, name, isActive from Pricebook2 where IsStandard = true limit 1];
        Id  standardPb = Test.getStandardPricebookId();
        Pricebook2 pbk1 = new Pricebook2 (Name='Test Pricebook Entry 1',Description='Test Pricebook Entry 1', isActive=true);
        insert pbk1;
        
        Product2 prd1 = new Product2 (Name='Test Product Entry 1',Description='Test Product Entry 1', isActive = true);
        insert prd1;
        
        
        PricebookEntry pbe1 = new PricebookEntry (Product2ID=prd1.id,Pricebook2ID=standardPb,UnitPrice=50, isActive=true);
        insert pbe1;
        
        Id opprecordtypeid = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Voucher').getRecordTypeId();
        
        List<Opportunity> oppList = new List<Opportunity>();
        Opportunity opp1 = new Opportunity (Name='Opp1',StageName='New',
                                            CloseDate=Date.today(),
                                            Pricebook2Id = pbe1.Pricebook2Id, Upgrade_Type__c = 'My Travel Rewards Club Platinum', 
                                            AccountId = acc.id,
                                            Reservation_Status__c='',
                                            leadassist__Use_Round_Robin__c='TRUE',
                                            Booking_Agent__c = UserInfo.getUserId(),
                                            RecordTypeId = opprecordtypeid);
        Opportunity opp2 = new Opportunity (Name='Opp1',StageName='New',
                                            CloseDate=Date.today(),
                                            Pricebook2Id = pbe1.Pricebook2Id, Upgrade_Type__c = 'My Travel Rewards Club Gold', 
                                            AccountId = acc.id,
                                            Reservation_Status__c='',
                                            leadassist__Use_Round_Robin__c='TRUE',
                                            Booking_Agent__c = UserInfo.getUserId(),
                                            RecordTypeId = opprecordtypeid);
        Opportunity opp3 = new Opportunity (Name='Opp1',StageName='New',
                                            CloseDate=Date.today(),
                                            Pricebook2Id = pbe1.Pricebook2Id, Upgrade_Type__c = 'My Travel Rewards Club Silver', 
                                            AccountId = acc.id,
                                            Reservation_Status__c='',
                                            leadassist__Use_Round_Robin__c='TRUE',
                                            Booking_Agent__c = UserInfo.getUserId(),
                                            RecordTypeId = opprecordtypeid);
        Opportunity opp4 = new Opportunity (Name='Opp1',StageName='New',
                                            CloseDate=Date.today(),
                                            Pricebook2Id = pbe1.Pricebook2Id, Upgrade_Type__c = 'SFX Diamond Preferred-Membership Upgrade', 
                                            AccountId = acc.id,
                                            Reservation_Status__c='',
                                            leadassist__Use_Round_Robin__c='TRUE',
                                            Booking_Agent__c = UserInfo.getUserId(),
                                            RecordTypeId = opprecordtypeid);
        oppList.add(opp1);
        oppList.add(opp2);
        oppList.add(opp3);
        oppList.add(opp4);
        insert oppList;
        
        Test.StartTest();
        //opp1.Name = 'NewTest Opp1';
        opp1.StageName='Closed Won';
        opp1.First_Payment_Date__c = Date.newInstance(2022,8,7);
        opp1.Original_Confirmation__c = false;
        opp1.leadassist__Use_Round_Robin__c='ASSIGNED';
        opp1.First_Payment_Date__c = Date.newInstance(2022,8,7);
        opp2.First_Payment_Date__c = Date.newInstance(2022,8,7);
        opp3.First_Payment_Date__c = Date.newInstance(2022,8,7);
        opp4.First_Payment_Date__c = Date.newInstance(2022,8,7);
        update oppList; 
        
        opp1.First_Payment_Date__c = Date.newInstance(2022,8,8);
        opp2.First_Payment_Date__c = Date.newInstance(2022,8,8);
        opp3.First_Payment_Date__c = Date.newInstance(2022,8,8);
        opp4.First_Payment_Date__c = Date.newInstance(2022,8,8);
        update oppList;
        Test.StopTest();
    }
    @isTest
    static void Test11() {
        try{
            Account acc = new Account(Name = 'Test Account32');
            insert acc;         
            Id opprecordtypeid = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Membership_Annual_Dues').getRecordTypeId();
            
            Opportunity opp1 = new Opportunity (Name='Opp1',
                                                StageName='Closed Won',
                                                CloseDate=Date.today(),
                                                Upgrade_Type__c = 'SFX Diamond Preferred-Membership Upgrade', 
                                                AccountId = acc.id, 
                                                RecordTypeId = opprecordtypeid);
            insert opp1;
            
            Test.stopTest();
        }
        catch(Exception e){
            Boolean expectedExceptionThrown =  ((e.getMessage().contains('Member Number and Contact Id')) ? true : false);
            System.AssertEquals(expectedExceptionThrown, true);
        }
    }
    
}