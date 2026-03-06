@isTest(seeAllData=true)
public class OpportunityTrigger_Test {
    
    @isTest
    static void Test1() {
        
        
        Account acc = new Account(Name = 'Test Account', Affiliated_Id__c = 1235, Member_Number__c = '13523412');
        insert acc;
        
        Contact con = new Contact();
        con.FirstName = 'Test';
        con.LastName = 'Account';
        
        insert con;
        
        Case c = new Case();
        c.status = 'New';
        c.Type = 'Membership Upgrade';
        
        insert c;

        Pricebook2  standardPb = [select id, name, isActive from Pricebook2 where IsStandard = true limit 1];
        
        Pricebook2 pbk1 = new Pricebook2 (Name='Test Pricebook Entry 1',Description='Test Pricebook Entry 1', isActive=true);
        insert pbk1;
        
        Product2 prd1 = new Product2 (Name='Test Product Entry 1',Description='Test Product Entry 1', isActive = true);
        insert prd1;
        
        
        PricebookEntry pbe1 = new PricebookEntry (Product2ID=prd1.id,Pricebook2ID=standardPb.id,UnitPrice=50, isActive=true);
        insert pbe1;
        Id travelOppRecType = [Select id from RecordType where sObjectType = 'Opportunity' and developerName ='Travel' ].id ;
        Opportunity opp1 = new Opportunity (Name='Opp1',StageName='Negotiation',CloseDate=Date.today(),Pricebook2Id = pbe1.Pricebook2Id, Upgrade_Type__c = 'My Travel Rewards Club Silver', AccountId = acc.id, Auto_Created_BU_Opp__c = true, RecordTypeId = travelOppRecType);
        insert opp1;
        
        
        OpportunityLineItem lineItem1 = new OpportunityLineItem (OpportunityID=opp1.id,PriceBookEntryID=pbe1.id, quantity=4, totalprice=200, retail_price__c = 99);
        insert lineItem1;
        
        update opp1;
    }
    
     @isTest
    static void Test2() {
        
//        Account acc = new Account(Name = 'Test Account');
       Account acc = new Account(Name = 'Test Account', Affiliated_Id__c = 1235, Member_Number__c = '13523412');
         insert acc;

        Pricebook2  standardPb = [select id, name, isActive from Pricebook2 where IsStandard = true limit 1];
        
        Pricebook2 pbk1 = new Pricebook2 (Name='Test Pricebook Entry 1',Description='Test Pricebook Entry 1', isActive=true);
        insert pbk1;
        
        Product2 prd1 = new Product2 (Name='Test Product Entry 1',Description='Test Product Entry 1', isActive = true);
        insert prd1;
        
        
        PricebookEntry pbe1 = new PricebookEntry (Product2ID=prd1.id,Pricebook2ID=standardPb.id,UnitPrice=50, isActive=true);
        insert pbe1;
        
        Opportunity opp1 = new Opportunity (Name='Opp1',StageName='Negotiation',CloseDate=Date.today(),Pricebook2Id = pbe1.Pricebook2Id, Upgrade_Type__c = 'My Travel Rewards Club Gold', AccountId = acc.id, Auto_Created_BU_Opp__c = true);
        insert opp1;
        
        
        OpportunityLineItem lineItem1 = new OpportunityLineItem (OpportunityID=opp1.id,PriceBookEntryID=pbe1.id, quantity=4, totalprice=200, retail_price__c = 99);
        insert lineItem1;
        
        update opp1;
    }

        
         @isTest
    static void Test3() {
        
//        Account acc = new Account(Name = 'Test Account');
       Account acc = new Account(Name = 'Test Account', Affiliated_Id__c = 1235, Member_Number__c = '13523412');
         insert acc;

        Pricebook2  standardPb = [select id, name, isActive from Pricebook2 where IsStandard = true limit 1];
        
        Pricebook2 pbk1 = new Pricebook2 (Name='Test Pricebook Entry 1',Description='Test Pricebook Entry 1', isActive=true);
        insert pbk1;
        
        Product2 prd1 = new Product2 (Name='Test Product Entry 1',Description='Test Product Entry 1', isActive = true);
        insert prd1;
        
        
        PricebookEntry pbe1 = new PricebookEntry (Product2ID=prd1.id,Pricebook2ID=standardPb.id,UnitPrice=50, isActive=true);
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
        
        Contact con = new Contact();
        con.FirstName = 'Test';
        con.LastName = 'Account';
        
        insert con;

        
        //        Account acc = new Account(Name = 'Test Account');
        Account acc = new Account(Name = 'Test Account', Affiliated_Id__c = 1235, Member_Number__c = '13523412' );
        //Member Number and Contact Id cannot be empty in the account.: []

        insert acc;

        Pricebook2  standardPb = [select id, name, isActive from Pricebook2 where IsStandard = true limit 1];
        
        Pricebook2 pbk1 = new Pricebook2 (Name='Test Pricebook Entry 1',Description='Test Pricebook Entry 1', isActive=true);
        insert pbk1;
        
        Product2 prd1 = new Product2 (Name='Test Product Entry 1',Description='Test Product Entry 1', isActive = true);
        insert prd1;
        
        
        PricebookEntry pbe1 = new PricebookEntry (Product2ID=prd1.id,Pricebook2ID=standardPb.id,UnitPrice=50, isActive=true);
        insert pbe1;
        
        Opportunity opp1 = new Opportunity (Name='Opp1',StageName='Negotiation',CloseDate=Date.today(),Pricebook2Id = pbe1.Pricebook2Id,Annual_Dues__c = 99, AccountId = acc.id, RecordTypeId = System.Label.Opp_Membership_Annual_Dues);
        insert opp1;
        
        
        OpportunityLineItem lineItem1 = new OpportunityLineItem (OpportunityID=opp1.id,PriceBookEntryID=pbe1.id, quantity=4, totalprice=200, retail_price__c = 99);
        insert lineItem1;
        
        update opp1;
    }
    
    @isTest
    static void Test5() {
        
//        Account acc = new Account(Name = 'Test Account');
       Account acc = new Account(Name = 'Test Account', Affiliated_Id__c = 1235, Member_Number__c = '13523412');
         insert acc;

        Pricebook2  standardPb = [select id, name, isActive from Pricebook2 where IsStandard = true limit 1];
        
        Pricebook2 pbk1 = new Pricebook2 (Name='Test Pricebook Entry 1',Description='Test Pricebook Entry 1', isActive=true);
        insert pbk1;
        
        Product2 prd1 = new Product2 (Name='Test Product Entry 1',Description='Test Product Entry 1', isActive = true);
        insert prd1;
        
        
        PricebookEntry pbe1 = new PricebookEntry (Product2ID=prd1.id,Pricebook2ID=standardPb.id,UnitPrice=50, isActive=true);
        insert pbe1;
        
        Opportunity opp1 = new Opportunity (Name='Opp1',StageName='Negotiation',CloseDate=Date.today(),Pricebook2Id = pbe1.Pricebook2Id, Upgrade_Type__c = '', AccountId = acc.id, Auto_Created_BU_Opp__c = true);
        insert opp1;
        
        
        OpportunityLineItem lineItem1 = new OpportunityLineItem (OpportunityID=opp1.id,PriceBookEntryID=pbe1.id, quantity=4, totalprice=200, retail_price__c = 99);
        insert lineItem1;
    }
    
    @isTest
    static void Test6() {
        
//        Account acc = new Account(Name = 'Test Account');
       Account acc = new Account(Name = 'Test Account', Affiliated_Id__c = 1235, Member_Number__c = '13523412');
 
        insert acc;

        Pricebook2  standardPb = [select id, name, isActive from Pricebook2 where IsStandard = true limit 1];
        
        Pricebook2 pbk1 = new Pricebook2 (Name='Test Pricebook Entry 1',Description='Test Pricebook Entry 1', isActive=true);
        insert pbk1;
        
        Product2 prd1 = new Product2 (Name='Test Product Entry 1',Description='Test Product Entry 1', isActive = true);
        insert prd1;
        
        
        PricebookEntry pbe1 = new PricebookEntry (Product2ID=prd1.id,Pricebook2ID=standardPb.id,UnitPrice=50, isActive=true);
        insert pbe1;
        
        Opportunity opp1 = new Opportunity (Name='Opp1',StageName='Negotiation',CloseDate=Date.today(),Pricebook2Id = pbe1.Pricebook2Id, Upgrade_Type__c = 'My Travel Rewards Club Platinum', AccountId = acc.id, Auto_Created_BU_Opp__c = true);
        insert opp1;
        
        
        OpportunityLineItem lineItem1 = new OpportunityLineItem (OpportunityID=opp1.id,PriceBookEntryID=pbe1.id, quantity=4, totalprice=200, retail_price__c = 99);
        insert lineItem1;
        
        delete opp1;
    }
    @isTest
    static void Test7() {
        
//        Account acc = new Account(Name = 'Test Account32');
        Account acc = new Account(Name = 'Test Account32', Affiliated_Id__c = 1235, Member_Number__c = '13523412');
         insert acc;

        Pricebook2  standardPb = [select id, name, isActive from Pricebook2 where IsStandard = true limit 1];
        
        Pricebook2 pbk1 = new Pricebook2 (Name='Test Pricebook Entry 1',Description='Test Pricebook Entry 1', isActive=true);
        insert pbk1;
        
        Product2 prd1 = new Product2 (Name='Test Product Entry 1',Description='Test Product Entry 1', isActive = true);
        insert prd1;
        
        
        PricebookEntry pbe1 = new PricebookEntry (Product2ID=prd1.id,Pricebook2ID=standardPb.id,UnitPrice=50, isActive=true);
        insert pbe1;
        
        //Id opprecordtypeid = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Membership Upgrade').getRecordTypeId();
        Id opprecordtypeid = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('MTRC Membership Upgrade').getRecordTypeId();
        
        Opportunity opp1 = new Opportunity (Name='Opp1',StageName='Closed Won',CloseDate=Date.today(),Pricebook2Id = pbe1.Pricebook2Id, Upgrade_Type__c = 'My Travel Rewards Club Platinum', AccountId = acc.id, RecordTypeId = opprecordtypeid);
        insert opp1;
        
        opp1.Name = 'NewTest Opp1';
        update opp1;
            
    
    }
    @isTest
    static void Test8() {
        
//        Account acc = new Account(Name = 'Test Account32');
       Account acc = new Account(Name = 'Test Account32', Affiliated_Id__c = 1235, Member_Number__c = '13523412');
         insert acc;

        Pricebook2  standardPb = [select id, name, isActive from Pricebook2 where IsStandard = true limit 1];
        
        Pricebook2 pbk1 = new Pricebook2 (Name='Test Pricebook Entry 1',Description='Test Pricebook Entry 1', isActive=true);
        insert pbk1;
        
        Product2 prd1 = new Product2 (Name='Test Product Entry 1',Description='Test Product Entry 1', isActive = true);
        insert prd1;
        
        
        PricebookEntry pbe1 = new PricebookEntry (Product2ID=prd1.id,Pricebook2ID=standardPb.id,UnitPrice=50, isActive=true);
        insert pbe1;
        
        Id opprecordtypeid = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Voucher').getRecordTypeId();
        
        Opportunity opp1 = new Opportunity (Name='Opp1',StageName='New',CloseDate=Date.today(),Pricebook2Id = pbe1.Pricebook2Id, Upgrade_Type__c = 'My Travel Rewards Club Platinum', AccountId = acc.id, RecordTypeId = opprecordtypeid);
        insert opp1;
        
        opp1.Name = 'NewTest Opp1';
        opp1.StageName='Closed Won';
        update opp1;
            
    
    }
    
    
    
    @isTest
    static void Test9() {
        
        
        Account acc = new Account(Name = 'Test Account', Affiliated_Id__c = 1235, Member_Number__c = '13523412');
        insert acc;
        
        Contact con = new Contact();
        con.FirstName = 'Test';
        con.LastName = 'Account';
        
        insert con;
        
        Case c = new Case();
        c.status = 'New';
        c.Type = 'Membership Upgrade';
        
        insert c;
        
        Pricebook2  standardPb = [select id, name, isActive from Pricebook2 where IsStandard = true limit 1];
        
        Pricebook2 pbk1 = new Pricebook2 (Name='Test Pricebook Entry 1',Description='Test Pricebook Entry 1', isActive=true);
        insert pbk1;
        
        Product2 prd1 = new Product2 (Name='Test Product Entry 1',Description='Test Product Entry 1', isActive = true);
        insert prd1;
        
        
        PricebookEntry pbe1 = new PricebookEntry (Product2ID=prd1.id,Pricebook2ID=standardPb.id,UnitPrice=50, isActive=true);
        insert pbe1;
        Id travelOppRecType = [Select id from RecordType where sObjectType = 'Opportunity' and developerName ='Travel' ].id ;
        Opportunity opp1 = new Opportunity (Name='Opp1',StageName='Negotiation',CloseDate=Date.today(),Pricebook2Id = pbe1.Pricebook2Id, Upgrade_Type__c = 'My Travel Rewards Club Silver', AccountId = acc.id, Auto_Created_BU_Opp__c = true, RecordTypeId = travelOppRecType);
        insert opp1;
        
        
        OpportunityLineItem lineItem1 = new OpportunityLineItem (OpportunityID=opp1.id,PriceBookEntryID=pbe1.id, quantity=4, totalprice=200, retail_price__c = 99);
        insert lineItem1;
        
//        update opp1;

        lineItem1.File_Fee__c = 200;
        //insert lineItem1;
		update lineItem1;

 //if(oppty.Inventory_Availability_Id__c != null && oppty.Property_Address__c == null){
 //SELECT Id FROM Inventory_Availability__c WHERE Id = 'a0d7d000003RTYZAA4'
 
        
        
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
opp2.Inventory_Availability_Id__c = inav.Id;
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
    
}