@istest
public class InventoryAvailabilityReBookCtrlTest {
    @istest
    static void InventoryAvailabilityReBookCtrlTest1(){
        //Date startDate = Date.parse('12/15/15');
        //Date endDate = Date.parse('12/16/15');
        //Date method1res1 = InventoryAvailabilitySearch.getAvailabityByDate(startDate, endDate);
        
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
      
        Opportunity opp = new Opportunity();
        opp.Name='Test Opp';
        opp.StageName='Proposal';
        opp.CloseDate=system.today();
        opp.Destination__c='Acapulco';
        opp.Property__c='Mayan Palace Acapulco';
        opp.Rooms__c='1BR';
        opp.Check_in__c=System.today();
        opp.Check_Out__c=System.today();
        opp.Reservation_Status__c='Pending';
        opp.Inventory_Availability_Id__c=inav.id;
        opp.Capacity__c='2A + 2K';
        Insert opp;
        
        opp.Destination__c=inav.Plaza__c;
		update opp;
        
        Test.StartTest();
        
        InventoryAvailabilityReBookCtrl.AvailabityByDate(system.today(),null,opp.Id,1,1);
        InventoryAvailabilityReBookCtrl.AvailabityByDate(null,system.today(),opp.Id,1,1);
        InventoryAvailabilityReBookCtrl.AvailabityByDate(system.today(),system.today(),opp.Id,1,1);
        InventoryAvailabilityReBookCtrl.getAllProgram('MTK','testabc', 'VALLARTA', 'Room 1', system.today(),null,opp.Id,1,1);
        
        InventoryAvailabilityCtrl.getAllProgram('MTK','testabc', 'VALLARTA', 'Room 1', system.today(),null,opp.Id,1,1);
        InventoryAvailabilityCtrl.getAllProgram('--None--','testabc', 'VALLARTA', 'Room 1', system.today(),null,opp.Id,1,1);
        InventoryAvailabilityReBookCtrl.getAllResort('MTK','VALLARTA',system.today(),null,opp.Id,1,1);
        InventoryAvailabilityReBookCtrl.getAllResort('MTK','VALLARTA',null,system.today(),opp.Id,1,1);
        InventoryAvailabilityReBookCtrl.getAllResort('MTK','VALLARTA',system.today(),system.today(),opp.Id,1,1);
        InventoryAvailabilityReBookCtrl.roomType('MTK','testabc', 'VALLARTA', system.today(),null,opp.Id,1,1);
        InventoryAvailabilityReBookCtrl.roomType('MTK','testabc', 'VALLARTA', null,system.today(),opp.Id,1,1);
        InventoryAvailabilityReBookCtrl.roomType('MTK','testabc', 'VALLARTA', system.today(),system.today(),opp.Id,1,1);
		InventoryAvailabilityReBookCtrl.InventoryAvailabilityBasedOnroomType('MTK','testabc', 'VALLARTA', 'Room 1', system.today(),null,opp.Id,1,1);
        InventoryAvailabilityReBookCtrl.InventoryAvailabilityBasedOnroomType('MTK','testabc', 'VALLARTA', 'Room 1', null,system.today(),opp.Id,1,1);
		InventoryAvailabilityReBookCtrl.InventoryAvailabilityBasedOnroomType('MTK','testabc', 'VALLARTA', 'Room 1', system.today(),system.today(),opp.Id,1,1);
        InventoryAvailabilityReBookCtrl.checkbookingifExist(opp.Id);
        InventoryAvailabilityReBookCtrl.bookedInventoryInOppMethod(inav.Id, opp.Id,1,1);        
        InventoryAvailabilityReBookCtrl.getNumberOfNightsByOpportunityId(opp.Id);

        Test.StopTest(); 
        
    }
}