@isTest
public class InventoryAvailabilitySearchCtrlTest {

    @isTest
    static void InventoryAvailabilityCtrlTest1() {
        // Creating test data
        Inventory_Management__c invt = new Inventory_Management__c();
        insert invt;

        Inventory_Availability__c inav = new Inventory_Availability__c();
        inav.Inventory_Management__c = invt.Id;
        inav.Resort_Name__c = 'testabc';
        inav.Check_In_Date__c = Date.today();
        inav.New_Availability__c = 1;
        inav.Plaza__c = 'VALLARTA';
        inav.Program__c = 'MTK';
        insert inav;

        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp';
        opp.StageName = 'Proposal';
        opp.CloseDate = Date.today();
        opp.Destination__c = 'Acapulco';
        opp.Property__c = 'Mayan Palace Acapulco';
        opp.Rooms__c = '1BR';
        opp.Check_in__c = Date.today();
        opp.Check_Out__c = Date.today();
        opp.Reservation_Status__c = 'Pending';
        opp.Inventory_Availability_Id__c = inav.Id;
        opp.Capacity__c = '2A + 2K';
        insert opp;

        // Updating opportunity's destination to match plaza
        opp.Destination__c = inav.Plaza__c;
        update opp;

        Test.startTest();

        // Testing various methods with different parameters
        // Method AvailabityByDate
        InventoryAvailabilitySearchCtrl.AvailabityByDate(Date.today(), null, opp.Id,1,1);
        InventoryAvailabilitySearchCtrl.AvailabityByDate(null, Date.today(), opp.Id,1,1);
        InventoryAvailabilitySearchCtrl.AvailabityByDate(Date.today(), Date.today(), opp.Id,1,1);

        // Method getAllProgram
        InventoryAvailabilitySearchCtrl.getAllProgram('MTK', 'testabc', 'VALLARTA', 'Room 1', Date.today(), null, opp.Id,1,1);
        InventoryAvailabilitySearchCtrl.getAllProgram('--None--', 'testabc', 'VALLARTA', 'Room 1', Date.today(), null, opp.Id,1,1);

        // Method getAllResort
        InventoryAvailabilitySearchCtrl.getAllResort('MTK', 'VALLARTA', Date.today(), null, opp.Id,1,1);
        InventoryAvailabilitySearchCtrl.getAllResort('MTK', 'VALLARTA', null, Date.today(), opp.Id,1,1);
        InventoryAvailabilitySearchCtrl.getAllResort('MTK', 'VALLARTA', Date.today(), Date.today(), opp.Id,1,1);

        // Method roomType
        InventoryAvailabilitySearchCtrl.roomType('MTK', 'testabc', 'VALLARTA', Date.today(), null, opp.Id,1,1);
        InventoryAvailabilitySearchCtrl.roomType('MTK', 'testabc', 'VALLARTA', null, Date.today(), opp.Id,1,1);
        InventoryAvailabilitySearchCtrl.roomType('MTK', 'testabc', 'VALLARTA', Date.today(), Date.today(), opp.Id,1,1);

        // Method InventoryAvailabilityBasedOnroomType
        InventoryAvailabilitySearchCtrl.InventoryAvailabilityBasedOnroomType('MTK', 'testabc', 'VALLARTA', 'Room 1', Date.today(), null, opp.Id,1,1);
        InventoryAvailabilitySearchCtrl.InventoryAvailabilityBasedOnroomType('MTK', 'testabc', 'VALLARTA', 'Room 1', null, Date.today(), opp.Id,1,1);
        InventoryAvailabilitySearchCtrl.InventoryAvailabilityBasedOnroomType('MTK', 'testabc', 'VALLARTA', 'Room 1', Date.today(), Date.today(), opp.Id,1,1);

        // Method checkUserPermission
        InventoryAvailabilitySearchCtrl.checkUserPermission();

        Test.stopTest();
    }
}