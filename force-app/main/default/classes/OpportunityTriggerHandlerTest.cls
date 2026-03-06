@isTest(seeAllData=true)
public class OpportunityTriggerHandlerTest {

    
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