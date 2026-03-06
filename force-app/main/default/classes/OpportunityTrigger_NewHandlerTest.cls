@isTest(seeAllData=true)
public class OpportunityTrigger_NewHandlerTest {
    @isTest 
    public static void incentiveGiftProductsTest() {
                Account acc = new Account(Name = 'Test Account32',Affiliated_Id__c = 1002122);
        insert acc;
        
        Id standardPb = Test.getStandardPricebookId();
        
        Pricebook2 pbk1 = new Pricebook2 (Name='Gift Product 1',Description='Gift Product 1', isActive=true);
        insert pbk1;
        
        Product2 prd1 = new Product2 (Name='Gift Product 1',Description='Gift Product 1', isActive = true);
        insert prd1;
        
        PricebookEntry pbe1 = new PricebookEntry (Product2ID=prd1.id,Pricebook2ID=standardPb,UnitPrice=50, isActive=true);
        insert pbe1;
        
        Id opprecordtypeid = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Club_Venture_Membership').getRecordTypeId();
        
        Opportunity opp1 = new Opportunity (Name='Opp1',StageName='New',CloseDate=Date.today(),Pricebook2Id = pbe1.Pricebook2Id, AccountId = acc.id, RecordTypeId = opprecordtypeid);
        
        insert opp1;
        
        Test.startTest();
        
        // Simulate initial value for Gift__c (optional, no gift yet)
        opp1.Gift__c = null;
        update opp1;
        
        // Now simulate adding a gift to trigger the logic
        opp1.Gift__c = 'Gift Product 1';
        update opp1;
        
        Test.stopTest();        
    }
    @isTest 
    public static void oppVoucherTest() {
        Account acc = new Account(Name = 'Test Account32');
        insert acc;
        
        Id standardPb = Test.getStandardPricebookId();
        
        Pricebook2 pbk1 = new Pricebook2 (Name='Test Pricebook Entry 1',Description='Test Pricebook Entry 1', isActive=true);
        insert pbk1;
        
        Product2 prd1 = new Product2 (Name='Test Product Entry 1',Description='Test Product Entry 1', isActive = true);
        insert prd1;
        
        PricebookEntry pbe1 = new PricebookEntry (Product2ID=prd1.id,Pricebook2ID=standardPb,UnitPrice=50, isActive=true);
        insert pbe1;
        
        Id opprecordtypeid = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Voucher').getRecordTypeId();
        
        Opportunity opp1 = new Opportunity (Name='Opp1',StageName='New',CloseDate=Date.today(),Pricebook2Id = pbe1.Pricebook2Id, Upgrade_Type__c = 'My Travel Rewards Club Platinum', AccountId = acc.id, RecordTypeId = opprecordtypeid);
        
        insert opp1;
        
        Contact con = new Contact();
        con.FirstName = 'Test';
        con.LastName = 'Account32';
        con.AccountId = acc.Id;
                con.Affiliate_Name__c='test';

        insert con;
        
        Test.setMock(HttpCalloutMock.class, new AssigningContactInCadenceTestMock());
        Test.startTest();
        
        Profile p = [select id
                     from
                     Profile
                     where
                     name='System Administrator'];
        
        User user = new user(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', firstName='Test', lastname='Name', languagelocalekey='en_US',
                             localesidkey='en_IN', profileid = p.Id, country='India',
                             timezonesidkey='Asia/Kolkata', username='test101_g@noemail.com', Assigned_Contacts__c=4);
        insert user;
        
        // Set up user
        User u1 = [SELECT Id FROM User WHERE UserName='test101_g@noemail.com'];
        System.RunAs(u1){
            // Add startTest and stopTest to avoid mixed DML error
            
            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'HighVelocitySalesUser'];
            
            insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps.Id);
            
        }
        
        opp1.Name = 'NewTest Opp1';
        opp1.StageName = 'Closed Won';
        opp1.CloseDate = System.Today();
        opp1.Booking_Agent__c = user.Id;
        update opp1;
        
        Recursive.flag = true;
        Test.stopTest();
    }
    @isTest 
    public static void oppVoucherTest66() {
        Account acc = new Account(Name = 'Test Account32',Affiliated_Id__c=1002122);
        insert acc;
        
        Id standardPb = Test.getStandardPricebookId();
        
        Pricebook2 pbk1 = new Pricebook2 (Name='Test Pricebook Entry 1',Description='Test Pricebook Entry 1', isActive=true);
        insert pbk1;
        
        Product2 prd1 = new Product2 (Name='Test Product Entry 1',Description='Test Product Entry 1', isActive = true);
        insert prd1;
        
        PricebookEntry pbe1 = new PricebookEntry (Product2ID=prd1.id,Pricebook2ID=standardPb,UnitPrice=50, isActive=true);
        insert pbe1;
        
        Id opprecordtypeid = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Voucher').getRecordTypeId();
        
        Opportunity opp1 = new Opportunity (Name='Opp1',StageName='New',CloseDate=Date.today(),Pricebook2Id = pbe1.Pricebook2Id, Upgrade_Type__c = 'My Travel Rewards Club Platinum', AccountId = acc.id, RecordTypeId = opprecordtypeid);
        
        insert opp1;
        
        Contact con = new Contact();
        con.FirstName = 'Test';
        con.LastName = 'Account32';
        con.AccountId = acc.Id;
                con.Affiliate_Name__c='test';

        insert con;
        
        Test.setMock(HttpCalloutMock.class, new AssigningContactInCadenceTestMock());
        Test.startTest();
        
        Profile p = [select id
                     from
                     Profile
                     where
                     name='System Administrator'];
        
        User user = new user(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', firstName='Test', lastname='Name', languagelocalekey='en_US',
                             localesidkey='en_IN', profileid = p.Id, country='India',
                             timezonesidkey='Asia/Kolkata', username='test101_g@noemail.com', Assigned_Contacts__c=4);
        insert user;
        
        // Set up user
        User u1 = [SELECT Id FROM User WHERE UserName='test101_g@noemail.com'];
        System.RunAs(u1){
            // Add startTest and stopTest to avoid mixed DML error
            
            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'HighVelocitySalesUser'];
            
            insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps.Id);
            
        }
        
        opp1.Name = 'NewTest Opp1';
        opp1.StageName = 'Closed Won';
        opp1.CloseDate = System.Today();
        opp1.Booking_Agent__c = user.Id;
         
        update opp1;
        
        Recursive.flag = true;
        Test.stopTest();
    }
    @isTest 
    public static void oppDiamondTest() {
        Account acc = new Account(Name = 'Test Account32');
        insert acc;
        
        Id standardPb = Test.getStandardPricebookId();
        
        Pricebook2 pbk1 = new Pricebook2 (Name='Test Pricebook Entry 1',Description='Test Pricebook Entry 1', isActive=true);
        insert pbk1;
        
        Product2 prd1 = new Product2 (Name='Test Product Entry 1',Description='Test Product Entry 1', isActive = true);
        insert prd1;
        
        PricebookEntry pbe1 = new PricebookEntry (Product2ID=prd1.id,Pricebook2ID=standardPb,UnitPrice=50, isActive=true);
        insert pbe1;
        
        Id opprecordtypeid = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Voucher').getRecordTypeId();
        
        Opportunity opp1 = new Opportunity (Name='Opp1',StageName='New',
                                            CloseDate=Date.today(),
                                            Pricebook2Id = pbe1.Pricebook2Id, 
                                            Upgrade_Type__c = 'My Travel Rewards Club Platinum',
                                            AccountId = acc.id, RecordTypeId = opprecordtypeid,
                                            Reservation_Status__c='Confirmed');
        
        insert opp1;

        Test.startTest();
        
        opp1.Upgrade_Type__c = 'SFX Diamond Plus-Membership Upgrade';
        update opp1;
        
        opp1.Upgrade_Type__c = 'SFX Diamond Preferred-Membership Upgrade';
        update opp1;
        
        opp1.Upgrade_Type__c = 'SFX Diamond Premier-Membership Upgrade';
        update opp1;
        
        Test.stopTest();
    }
    
    @isTest 
    public static void assignOwnersTest() {
        
        ID ownerId= [SELECT Id FROM User where name='Dev Account' LIMIT 1].id;
        
        Account acc = new Account();
        acc.Name = 'Test';
        acc.ownerid=ownerId;
        acc.email__c='test@g.com';
        acc.Affiliated_Id__c=1002243;
        acc.TRM_Owner_Flag__c='Yes';
        acc.Enrollment_Date__c = System.today() - 10;
        Insert acc;
        
        Opportunity opp= new Opportunity();
        opp.name='test11';
        opp.ownerid=ownerId;
        opp.Automated_Hawaii_Opportunity__c=true;
        opp.accountId=acc.Id;
        opp.CloseDate=system.today();
        opp.StageName='New';
        opp.RecordTypeId='0123t000000mliUAAQ';
        insert opp;
        delete opp;
        
    }
    
    @isTest 
    public static void assignOwnersTest2GradeA() {
        
        ID ownerId= [SELECT Id FROM User where name='Dev Account' LIMIT 1].id;
        
        Account acc2 = new Account();
        acc2.Name = 'Test2';
        acc2.email__c='test2@g.com';
        acc2.ownerid=ownerId;
        acc2.Preferred_Language__c='ENG';
        acc2.Affiliated_Id__c=1002243;
        acc2.TRM_Owner_Flag__c='No';
        acc2.Enrollment_Date__c = System.today() - 9;
        Insert acc2;
        
        TimeShare__c tm=new timeshare__c();
        tm.name='The Estates East Cape';
        tm.Unit_Size__c='1 Bedroom';
        tm.Unit_Type__c='Empire Estates 2 Bdrm. 3 Bth';
        tm.Ownership__c='Deeded';        
        tm.Timeshare_Owner__c=acc2.id;
        tm.Usage__c='Biennial Odd';
        tm.Week__c='2';
        tm.Fees_Billing_Period__c='Annually';
        tm.MF_Paid_Until_Month__c='2';
        tm.MF_Paid_Until_Year__c='2';
        tm.MF_Amount__c=2;
        tm.First_Year_Use__c='2';
        tm.Master_Record_Id__c='2';
        insert tm;
        Inventory_Management__c invt = new Inventory_Management__c();
        Insert invt;
        
        Inventory_Availability__c inav = new Inventory_Availability__c();
        inav.Inventory_Management__c= invt.Id;
        inav.Resort_Name__c='testabc';
        inav.Check_In_Date__c=system.today();
        inav.New_Availability__c=1;
        inav.Plaza__c='VALLARTA';
        inav.Program__c='MTK';
         Insert inav;  
        
        Opportunity opp2= new Opportunity();
        opp2.name='test13';
        opp2.ownerid=ownerId;
        opp2.Automated_Hawaii_Opportunity__c=true;
        opp2.accountId=acc2.Id;
        opp2.CloseDate=system.today();
        opp2.StageName='New';
        opp2.RecordTypeId='0123t000000mliUAAQ';
         opp2.Reservation_Status__c = 'Cancel';
        insert opp2;
        
        Map<Id,Opportunity> oldmap = new Map<Id,Opportunity>();
        oldmap.put(opp2.Id,opp2);
        
        opp2.Destination__c=inav.Plaza__c;
        opp2.Reservation_Status__c = 'Cancel';
        update opp2;
        Map<Id,Opportunity> Newmap = new Map<Id,Opportunity>();
        Newmap.put(opp2.Id,opp2);

        OpportunityTriggerHandler.updateOppInfutue(opp2.Id,inav.Id);
        OpportunityTriggerHandler.createReservationTrackingRecord(oldmap,Newmap,true);
    }
    
    
    @isTest 
    public static void assignOwnersTest3() {
        
        ID ownerId= [SELECT Id FROM User where name='Dev Account' LIMIT 1].id;
        
        Account acc = new Account();
        acc.Name = 'Test';
        acc.ownerid=ownerId;
        acc.email__c='test@g.com';
        acc.Affiliated_Id__c=1002243;
        acc.TRM_Owner_Flag__c='No';
        acc.Preferred_Language__c='SPA';
        acc.Enrollment_Date__c = System.today() - 10;
        Insert acc;
        
        Opportunity opp= new Opportunity();
        opp.name='test11';
        opp.ownerid=ownerId;
        opp.Automated_Hawaii_Opportunity__c=true;
        opp.accountId=acc.Id;
        opp.CloseDate=system.today();
        opp.StageName='New';
        opp.RecordTypeId='0123t000000mliUAAQ';
        insert opp;
        
    }

    @isTest 
    public static void assignOwnersTest4GradeB() {
        
        ID ownerId= [SELECT Id FROM User where name='Dev Account' LIMIT 1].id;
        
        Account acc2 = new Account();
        acc2.Name = 'Test2';
        acc2.ownerid=ownerId;
        acc2.email__c='test2@g.com';
        acc2.Preferred_Language__c='ENG';
        acc2.Affiliated_Id__c=1002243;
        acc2.TRM_Owner_Flag__c='No';
        acc2.Enrollment_Date__c = System.today() - 10;
        Insert acc2;
        
        TimeShare__c tm=new timeshare__c();
        tm.name='Imperial Gardens Nuevo Vallarta';
        tm.Unit_Size__c='1 Bedroom';
        tm.Unit_Type__c='1 Bdrm. 2 Bth Suite';
        tm.Ownership__c='Deeded';        
        tm.Timeshare_Owner__c=acc2.id;
        tm.Usage__c='Biennial Odd';
        tm.Week__c='2';
        tm.Fees_Billing_Period__c='Annually';
        tm.MF_Paid_Until_Month__c='2';
        tm.MF_Paid_Until_Year__c='2';
        tm.MF_Amount__c=2;
        tm.First_Year_Use__c='2';
        tm.Master_Record_Id__c='2';
        insert tm;
        
        Opportunity opp2= new Opportunity();
        opp2.ownerid=ownerId;
        opp2.name='test13';
        opp2.Automated_Hawaii_Opportunity__c=true;
        opp2.accountId=acc2.Id;
        opp2.CloseDate=system.today();
        opp2.StageName='New';
        opp2.RecordTypeId='0123t000000mliUAAQ';
        insert opp2;
        
    }
    
    @isTest 
    public static void assignOwnersTest5GradeC() {
        
        ID ownerId= [SELECT Id FROM User where name='Dev Account' LIMIT 1].id;
        
        Account acc2 = new Account();
        acc2.Name = 'Test2';
        acc2.ownerid=ownerId;
        acc2.email__c='test2@g.com';
        acc2.Preferred_Language__c='ENG';
        acc2.Affiliated_Id__c=1002243;
        acc2.TRM_Owner_Flag__c='No';
        acc2.Enrollment_Date__c = System.today() - 10;
        Insert acc2;
        
        TimeShare__c tm=new timeshare__c();
        tm.name='Kingdom Of The Sun III';
        tm.Unit_Size__c='1 Bedroom';
        tm.Unit_Type__c='Imperial Jungle Aqua Suite';
        tm.Ownership__c='Deeded';        
        tm.Timeshare_Owner__c=acc2.id;
        tm.Usage__c='Biennial Odd';
        tm.Week__c='2';
        tm.Fees_Billing_Period__c='Annually';
        tm.MF_Paid_Until_Month__c='2';
        tm.MF_Paid_Until_Year__c='2';
        tm.MF_Amount__c=2;
        tm.First_Year_Use__c='2';
        tm.Master_Record_Id__c='2';
        insert tm;
        
        Opportunity opp2= new Opportunity();
        opp2.name='test13';
        opp2.Automated_Hawaii_Opportunity__c=true;
        opp2.ownerid=ownerId;
        opp2.accountId=acc2.Id;
        opp2.CloseDate=system.today();
        opp2.StageName='New';
        opp2.RecordTypeId='0123t000000mliUAAQ';
        insert opp2;
        
    }
    
    @isTest 
    public static void assignOwnersTest6GradeAB() {
        
        ID ownerId= [SELECT Id FROM User where name='Dev Account' LIMIT 1].id;
        
        Account acc2 = new Account();
        acc2.Name = 'Test2';
        acc2.email__c='test2@g.com';
        acc2.Preferred_Language__c='SPA';
        acc2.Affiliated_Id__c=1002243;
        acc2.ownerid=ownerId;
        acc2.TRM_Owner_Flag__c='No';
        acc2.Enrollment_Date__c = System.today() - 10;
        Insert acc2;
        
        TimeShare__c tm=new timeshare__c();
        tm.name='The Estates East Cape';
        tm.Unit_Size__c='1 Bedroom';
        tm.Unit_Type__c='Imperial 1 Bdddrm';
        tm.Ownership__c='Deeded';        
        tm.Timeshare_Owner__c=acc2.id;
        tm.Usage__c='Biennial Odd';
        tm.Week__c='2';
        tm.Fees_Billing_Period__c='Annually';
        tm.MF_Paid_Until_Month__c='2';
        tm.MF_Paid_Until_Year__c='2';
        tm.MF_Amount__c=2;
        tm.First_Year_Use__c='2';
        tm.Master_Record_Id__c='2';
        insert tm;
        
        Opportunity opp2= new Opportunity();
        opp2.name='test13';
        opp2.Automated_Hawaii_Opportunity__c=true;
        opp2.accountId=acc2.Id;
        opp2.CloseDate=system.today();
        opp2.ownerid=ownerId;
        opp2.StageName='New';
        opp2.RecordTypeId='0123t000000mliUAAQ';
        insert opp2;
    }
    
     @isTest 
    public static void oppTest1() {
        Account acc = new Account();
        acc.Name = 'Test Account32';
        acc.Member_Number__c = 'test';
        acc.Contact_Id__c = 123;
        insert acc;
        
        Id opprecordtypeid = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Membership Annual Dues').getRecordTypeId();

        Opportunity opp1 = new Opportunity ();
        opp1.Name='Opp1';
        opp1.stageName='New';
        opp1.CloseDate=Date.today();
        opp1.Upgrade_Type__c = 'My Travel Rewards Club Platinum';
        opp1.AccountId = acc.id;
        opp1.RecordTypeId = opprecordtypeid;
        opp1.Reservation_Status__c='Confirmed';
        insert opp1;
                
    }
    
    @isTest 
    public static void oppTest2() {
        Account acc = new Account();
        acc.Name = 'Test Account32';
        acc.Member_Number__c = 'test';
        acc.Contact_Id__c = 123;
        insert acc;
        
        Id opprecordtypeid = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Travel').getRecordTypeId();

        Opportunity opp1 = new Opportunity ();
        opp1.Name='Opp1';
        opp1.stageName='New';
        opp1.CloseDate=Date.today();
       opp1.Upgrade_Type__c = 'My Travel Rewards Club Platinum';
        opp1.AccountId = null;
        opp1.RecordTypeId = opprecordtypeid;
        opp1.Reservation_Status__c='Confirmed';
        opp1.Member_Number__c = 'test';
        insert opp1;
          
    }
    
    @isTest 
    public static void oppTest4() {
        Account acc = new Account();
        acc.Name = 'Test Account32';
        acc.Member_Number__c = 'test';
        acc.Contact_Id__c = 123;
        insert acc;
        
        Id opprecordtypeid = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Membership Enrollment Fee').getRecordTypeId();

        Opportunity opp1 = new Opportunity ();
        opp1.Name='Opp1';
        opp1.stageName='New';
        opp1.CloseDate=Date.today();
       
        opp1.Upgrade_Type__c = 'My Travel Rewards Club Platinum';
        opp1.AccountId = null;
        opp1.RecordTypeId = opprecordtypeid;
        opp1.Reservation_Status__c='Pending';
        opp1.Member_Number__c = 'test';
        opp1.Match_Group_Name__c = 'Travel Sales-Web Form Inquiry';
        //opp1.LeadSource = 'VI Referral';
        insert opp1;
        
         Id opprecordtypeid2 = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Membership_Enrollment_Fee').getRecordTypeId();

        Opportunity opp2 = new Opportunity ();
        opp2.Name='Opp1';
        opp2.stageName='New';
        opp2.CloseDate=Date.today();
       
        opp2.Upgrade_Type__c = 'My Travel Rewards Club Platinum';
        opp2.AccountId = null;
        opp2.RecordTypeId = opprecordtypeid2;
        opp2.Reservation_Status__c='Pending';
        opp2.Member_Number__c = 'test';
        opp2.Match_Group_Name__c = 'Travel Sales-Web Form Inquiry';
        opp2.Opportunity_Record_Type_Id_From_Lead__c = 'Membership_Enrollment_Fee';
        opp2.LeadSource = 'VI Referral';
        insert opp2;
        
         Id opprecordtypeid3 = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Membership_Enrollment_Fee').getRecordTypeId();

        Opportunity opp3 = new Opportunity ();
        opp3.Name='Opp1';
        opp3.stageName='New';
        opp3.CloseDate=Date.today();
       
        opp3.Upgrade_Type__c = 'My Travel Rewards Club Platinum';
        opp3.AccountId = null;
        opp3.RecordTypeId = opprecordtypeid2;
        opp3.Reservation_Status__c='Pending';
        opp3.Member_Number__c = 'test';
        opp3.Match_Group_Name__c = 'Travel Sales-Web Form Inquiry';
        opp3.Opportunity_Record_Type_Id_From_Lead__c = 'Membership_Enrollment_Fee';
        opp3.LeadSource = 'Vacation VIP - Web';
        insert opp3;
        
       
        
       /* opp1.StageName = 'Closed Won';
         opp1.Reservation_Status__c='Confirmed';
        system.debug('---opp.stage'+opp1.StageName);
        Update opp1;*/
        
        Task objtask = new Task();
        objtask.Subject = 'New Web Form Inquiry';
        objtask.ActivityDate = System.today();
        objtask.WhatId = opp1.Id;
        insert objtask;
    }
     @isTest 
    public static void oppTest5() {
        Account acc = new Account();
        acc.Name = 'Test Account32';
        acc.Member_Number__c = 'test';
        acc.Contact_Id__c = 123;
        acc.email__c = 'test@gmail.com';
        insert acc;
        
        Id opprecordtypeid = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Hawaii Collection Membership').getRecordTypeId();

        Opportunity opp1 = new Opportunity ();
        opp1.Name='Opp1';
        opp1.stageName='New';
        opp1.CloseDate=Date.today();
        opp1.AccountId = acc.Id;
        opp1.RecordTypeId = opprecordtypeid;
        opp1.Reservation_Status__c='Pending';
        opp1.Member_Number__c = 'test';
        opp1.Match_Group_Name__c = 'Travel Sales-Web Form Inquiry';
        //opp1.LeadSource = 'VI Referral';
        insert opp1;
        
        Id standardPb = Test.getStandardPricebookId();
        
        Pricebook2 pbk1 = new Pricebook2 (Name='Test Pricebook Entry 1',Description='Test Pricebook Entry 1', isActive=true);
        insert pbk1;
        
        Product2 product = new Product2 (Name='Back to Vidanta Pass',Description='Test Product Entry 1', isActive = true);
        insert product;
        
        PricebookEntry pbe1 = new PricebookEntry (Product2ID=product.id,Pricebook2ID=standardPb,UnitPrice=50, isActive=true);
        insert pbe1;
        
        OpportunityLineItem lineItem1 = new OpportunityLineItem (OpportunityID=opp1.id,Product2Id = product.Id,PriceBookEntryID=pbe1.id, quantity=1);
        insert lineItem1;
        
        opp1.StageName = 'Closed Won';
        system.debug('---opp.stage'+opp1.StageName);
        Update opp1;
    }
    @isTest 
    public static void oppTest6() {
        Account acc = new Account(Name = 'Test Account32',affiliated_id__c = 1002465);
        insert acc;
        
        Contact con = new Contact();
        con.FirstName = 'Test';
        con.LastName = 'Test Account32';
        con.AccountId = acc.Id;
        con.Affiliate_Name__c='test';
        
        insert con;
        
        Id standardPb = Test.getStandardPricebookId();
        
        Pricebook2 pbk1 = new Pricebook2 (Name='Test Pricebook Entry 1',Description='Test Pricebook Entry 1', isActive=true);
        insert pbk1;
        
        Product2 prd1 = new Product2 (Name='Test Product Entry 1',Description='Test Product Entry 1', isActive = true);
        insert prd1;
        
        PricebookEntry pbe1 = new PricebookEntry (Product2ID=prd1.id,Pricebook2ID=standardPb,UnitPrice=50, isActive=true);
        insert pbe1;
        
        Id opprecordtypeid = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Voucher').getRecordTypeId();
        
        Opportunity opp1 = new Opportunity (Name='Opp1',StageName='New',CloseDate=Date.today(),Pricebook2Id = pbe1.Pricebook2Id, AccountId = acc.id, RecordTypeId = opprecordtypeid);
        
        Test.setMock(HttpCalloutMock.class, new AssigningContactInCadenceTestMock());
        Test.startTest();
        
        insert opp1;
        
        Test.stopTest();
        

    }
}