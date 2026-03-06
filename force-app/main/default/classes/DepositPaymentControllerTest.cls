@isTest
public class DepositPaymentControllerTest {

    @isTest
    static void testGetPaymentDetails() {
        
        
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;
        
        Resort__c r = new Resort__c();
        r.name = 'Americana Village';
        insert r;
        
        Case obj = new Case();
        obj.Status = 'New';
        obj.AccountId = acc.Id;
        obj.Profile_Name__c = 'Internal Cash';
        obj.Payment_Type__c = 'Cash';
        obj.Client_Deposit_Payment_Schedule_Profile__c = 'Payment after Check In';
        insert obj;
        
        Deposits__c inv = new Deposits__c();
        inv.Deposit_Resort_Name__c = 'Test Imperial Garden Resort';
        inv.Check_in_Date__c = System.today();
        //inv.Unit_Type__c = 'Clothes';
        inv.Unit_Number__c = '123';
        inv.Check_Out__c = System.today();
        inv.Reservation_Number__c = '1234';
        inv.Occupancy__c = 123;
        inv.City__c = 'Noida';
        inv.MFP_Entitlement_Amount_Reservation__c = 1234;
        inv.State__c = 'UP';
        inv.Country__c = 'India';
        inv.Final_BW_Price__c = 123;
        inv.Price__c = 123;
        inv.Max_Price_for_Profit_Agility__c = 123;
        inv.Member_Price__c = 123;
        //inv.Days_to_burn_before_Check_In__c = '0';
        inv.Priority__c = 'High';
        inv.Season__c = 'Pull from BE';
        inv.Lowest_Price_GPR__c = 234;
        inv.Maint_Fees__c = 234;
        inv.Due_Date__c = System.today();
        inv.Case__c = obj.Id;
        inv.Resort_Id__c = r.Id;
        inv.Status__c = 'Draft';
        inv.Profile_Name__c = 'Internal Cash';
        inv.Payment_Type__c = 'Cash';
        //inv.Client_Deposit_Payment_Schedule_Profile__c = 'Payment after Check In'; - test before insert trigger
        insert inv;
        
        // Create a Deposit_Payment_Tracking__c record
        Deposit_Payment_Tracking__c paymentRecord = new Deposit_Payment_Tracking__c(
            Cost__c = 1000,
            Due_Date__c = Date.today().addDays(10),            
            Check_Confirmation_Number__c = '12345',
            Deposit__c = inv.Id, 
            Case__c = obj.Id,            
            Payment_Type__c = 'Cash'
        );
        insert paymentRecord;

        // Test the getPaymentDetails method
        Test.startTest();
        Map<String, Object> paymentDetails = DepositPaymentController.getPaymentDetails(paymentRecord.Id);
        
        // Update some fields
        paymentRecord.Amount_Paid_Out__c = 500;
        paymentRecord.Payment_Status__c = 'Approved';
        paymentRecord.Paid_By__c = 'Test User';
        paymentRecord.Paid_On__c = Date.today();
        
        DepositPaymentController.savePaymentRecord(paymentRecord, paymentRecord.Id);
        
        
        inv.Profile_Name__c = 'TRP Credits';
        inv.Payment_Type__c = 'Credits';
        inv.Client_Deposit_Payment_Schedule_Profile__c = null;
        inv.Status__c = 'Approved';
        update inv;
        
        Test.stopTest();
       }
    
    @isTest
    static void testGetPaymentDetails2() {
        
        
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;
        
        Resort__c r = new Resort__c();
        r.name = 'Americana Village';
        insert r;
        
        Case obj = new Case();
        obj.Status = 'New';
        obj.AccountId = acc.Id;
        obj.Profile_Name__c = 'TRP Cash';
        obj.Payment_Type__c = 'Cash';
        obj.Client_Deposit_Payment_Schedule_Profile__c = '50% at 4 months and 50% at 10 months';
        obj.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Exchanges_and_Deposits').getRecordTypeId();
        insert obj;
        
        Deposits__c inv = new Deposits__c();
        inv.Deposit_Resort_Name__c = 'Test Imperial Garden Resort';
        inv.Check_in_Date__c = System.today();
        //inv.Unit_Type__c = 'Clothes';
        inv.Unit_Number__c = '123';
        inv.Check_Out__c = System.today();
        inv.Reservation_Number__c = '1234';
        inv.Occupancy__c = 123;
        inv.City__c = 'Noida';
        inv.MFP_Entitlement_Amount_Reservation__c = 1234;
        inv.State__c = 'UP';
        inv.Country__c = 'India';
        inv.Final_BW_Price__c = 123;
        inv.Price__c = 123;
        inv.Max_Price_for_Profit_Agility__c = 123;
        inv.Member_Price__c = 123;
        //inv.Days_to_burn_before_Check_In__c = '0';
        inv.Priority__c = 'High';
        inv.Season__c = 'Pull from BE';
        inv.Lowest_Price_GPR__c = 234;
        inv.Maint_Fees__c = 234;
        inv.Due_Date__c = System.today();
        inv.Case__c = obj.Id;
        inv.Resort_Id__c = r.Id;
        inv.Status__c = 'Draft';
        inv.Profile_Name__c = 'TRP Cash';
        inv.Payment_Type__c = 'Cash';
        //inv.Client_Deposit_Payment_Schedule_Profile__c = '25%Down Payment + Balance at 270 Days';
        insert inv;
        
        // Create a Deposit_Payment_Tracking__c record
        Deposit_Payment_Tracking__c paymentRecord = new Deposit_Payment_Tracking__c(
            Cost__c = 1000,
            Due_Date__c = Date.today().addDays(10),            
            Check_Confirmation_Number__c = '12345',
            Deposit__c = inv.Id, 
            Case__c = obj.Id,            
            Payment_Type__c = 'Cash'
        );
        insert paymentRecord;

        // Test the getPaymentDetails method
        Test.startTest();
        Map<String, Object> paymentDetails = DepositPaymentController.getPaymentDetails(paymentRecord.Id);
        
        // Update some fields
        paymentRecord.Amount_Paid_Out__c = 500;
        paymentRecord.Payment_Status__c = 'Approved';
        paymentRecord.Paid_By__c = 'Test User';
        paymentRecord.Paid_On__c = Date.today();
        
        DepositPaymentController.savePaymentRecord(paymentRecord, paymentRecord.Id);
        
        
        inv.Profile_Name__c = 'Internal Cash';
        inv.Payment_Type__c = 'Cash';
        inv.Client_Deposit_Payment_Schedule_Profile__c = null;   
        inv.Status__c = 'Approved';
        update inv;
        
        Test.stopTest();
    }
    
    @isTest
    static void testGetPaymentDetails3() {        
        
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;
        
        Resort__c r = new Resort__c();
        r.name = 'Americana Village';
        insert r;
        
        Case obj = new Case();
        obj.Status = 'New';
        obj.AccountId = acc.Id;
        obj.Profile_Name__c = 'Internal Cash';
        obj.Payment_Type__c = 'Cash';
        obj.Client_Deposit_Payment_Schedule_Profile__c = 'Payment after Check In';
        insert obj;
        
        Deposits__c inv = new Deposits__c();
        inv.Deposit_Resort_Name__c = 'Test Imperial Garden Resort';
        inv.Check_in_Date__c = System.today();
        //inv.Unit_Type__c = 'Clothes';
        inv.Unit_Number__c = '123';
        inv.Check_Out__c = System.today();
        inv.Reservation_Number__c = '1234';
        inv.Occupancy__c = 123;
        inv.City__c = 'Noida';
        inv.MFP_Entitlement_Amount_Reservation__c = 1234;
        inv.State__c = 'UP';
        inv.Country__c = 'India';
        inv.Final_BW_Price__c = 123;
        inv.Price__c = 123;
        inv.Max_Price_for_Profit_Agility__c = 123;
        inv.Member_Price__c = 123;
        //inv.Days_to_burn_before_Check_In__c = '0';
        inv.Priority__c = 'High';
        inv.Season__c = 'Pull from BE';
        inv.Lowest_Price_GPR__c = 234;
        inv.Maint_Fees__c = 234;
        inv.Due_Date__c = System.today();
        inv.Case__c = obj.Id;
        inv.Resort_Id__c = r.Id;
        inv.Status__c = 'Draft';
        inv.Profile_Name__c = 'Internal Cash';
        inv.Payment_Type__c = 'Cash';
        //inv.Client_Deposit_Payment_Schedule_Profile__c = 'Payment after Check In';
        insert inv;
        
        // Create a Deposit_Payment_Tracking__c record
        Deposit_Payment_Tracking__c paymentRecord = new Deposit_Payment_Tracking__c(
            Cost__c = 1000,
            Due_Date__c = Date.today().addDays(10),            
            Check_Confirmation_Number__c = '12345',
            Deposit__c = inv.Id, 
            Case__c = obj.Id,            
            Payment_Type__c = 'Cash'
        );
        insert paymentRecord;

        // Test the getPaymentDetails method
        Test.startTest();
        Map<String, Object> paymentDetails = DepositPaymentController.getPaymentDetails(paymentRecord.Id);
        
        // Update some fields
        paymentRecord.Amount_Paid_Out__c = 500;
        paymentRecord.Payment_Status__c = 'Approved';
        paymentRecord.Paid_By__c = 'Test User';
        paymentRecord.Paid_On__c = Date.today();
        
        DepositPaymentController.savePaymentRecord(paymentRecord, paymentRecord.Id);
        
        
        inv.Profile_Name__c = 'TRP Cash';
        inv.Payment_Type__c = 'Cash';
        inv.Client_Deposit_Payment_Schedule_Profile__c = null;   
        inv.Status__c = 'Approved';
        inv.Inventory_Cost__c = 100;
        update inv;
        
        Test.stopTest();        
    }
}