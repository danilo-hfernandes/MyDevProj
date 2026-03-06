@isTest
public class DepositPaymentVerificationJobTest {

    @isTest
    static void testExecuteJob() {
        // Create Account
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;

        // Create Resort
        Resort__c r = new Resort__c();
        r.name = 'Americana Village';
        insert r;

        // Create Case
        Case obj = new Case();
        obj.Status = 'New';
        obj.AccountId = acc.Id;
        obj.Profile_Name__c = 'Internal Cash';
        obj.Payment_Type__c = 'Cash';
        obj.Client_Deposit_Payment_Schedule_Profile__c = 'Payment after Check In';
        insert obj;

        // Create Deposit 1 - Payment after Check In
        Deposits__c inv1 = new Deposits__c();
        inv1.Deposit_Resort_Name__c = 'Test Imperial Garden Resort';
        inv1.Check_in_Date__c = System.today();
        inv1.Unit_Number__c = '123';
        inv1.Check_Out__c = System.today();
        inv1.Reservation_Number__c = '1234';
        inv1.Occupancy__c = 123;
        inv1.City__c = 'Noida';
        inv1.MFP_Entitlement_Amount_Reservation__c = 1234;
        inv1.State__c = 'UP';
        inv1.Country__c = 'India';
        inv1.Final_BW_Price__c = 123;
        inv1.Price__c = 123;
        inv1.Max_Price_for_Profit_Agility__c = 123;
        inv1.Member_Price__c = 123;
        inv1.Priority__c = 'High';
        inv1.Season__c = 'Pull from BE';
        inv1.Lowest_Price_GPR__c = 234;
        inv1.Maint_Fees__c = 234;
        inv1.Due_Date__c = System.today();
        inv1.Case__c = obj.Id;
        inv1.Resort_Id__c = r.Id;
        inv1.Status__c = 'Approved';
        inv1.Profile_Name__c = 'Internal Cash';
        inv1.Payment_Type__c = 'Cash';
        inv1.Client_Deposit_Payment_Schedule_Profile__c = 'Payment after Check In';
        inv1.Inventory_Cost__c = 100;
        insert inv1;

        // Create Deposit 3 - 25% Down Payment + Balance at 270 Days
        Deposits__c inv3 = new Deposits__c();
        inv3.Deposit_Resort_Name__c = 'Test Imperial Garden Resort';
        inv3.Check_in_Date__c = System.today();
        inv3.Unit_Number__c = '123';
        inv3.Check_Out__c = System.today();
        inv3.Reservation_Number__c = '1234';
        inv3.Occupancy__c = 123;
        inv3.City__c = 'Noida';
        inv3.MFP_Entitlement_Amount_Reservation__c = 1234;
        inv3.State__c = 'UP';
        inv3.Country__c = 'India';
        inv3.Final_BW_Price__c = 123;
        inv3.Price__c = 123;
        inv3.Max_Price_for_Profit_Agility__c = 123;
        inv3.Member_Price__c = 123;
        inv3.Priority__c = 'High';
        inv3.Season__c = 'Pull from BE';
        inv3.Lowest_Price_GPR__c = 234;
        inv3.Maint_Fees__c = 234;
        inv3.Due_Date__c = System.today();
        inv3.Case__c = obj.Id;
        inv3.Resort_Id__c = r.Id;
        inv3.Status__c = 'Approved';
        inv3.Profile_Name__c = 'TRP Cash';
        inv3.Payment_Type__c = 'Cash';
        inv3.Client_Deposit_Payment_Schedule_Profile__c = '25%Down Payment + Balance at 270 Days';
        inv3.Inventory_Cost__c = 100;
        insert inv3;

        // Run job
        Test.startTest();
        new DepositPaymentVerificationJob().execute(null);
        Test.stopTest();
    }
}