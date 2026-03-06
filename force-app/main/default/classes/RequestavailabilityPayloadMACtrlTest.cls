@isTest
public class RequestavailabilityPayloadMACtrlTest {
    static testmethod void test1() {
        list<Inventory_Availability__c> tst = New list<Inventory_Availability__c>();
        Inventory_Availability__c inven = New Inventory_Availability__c();
        inven.Available_Weeks__c = 2.00;
        inven.New_Availability__c = 5;
        inven.Check_In_Date__c = Date.today();
        tst.add(inven);
        insert tst;
        RequestavailabilityPayloadMACtrl te = New RequestavailabilityPayloadMACtrl();
        te.getAvailabilityPayload(tst);
    }
}