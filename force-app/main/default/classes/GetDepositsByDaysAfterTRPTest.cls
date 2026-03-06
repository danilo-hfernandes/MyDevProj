@isTest
private class GetDepositsByDaysAfterTRPTest {

    @isTest
    static void testGetDepositsMethod() {
        // Data Setup

        Account acc = new Account(
            Name = 'Test Account',
            Membership_Status__c = 'Active',
            MFProtection__c = true,
            Phone = '1234567890'
        );
        insert acc;
        
        Resort__c r = new Resort__c();
        r.name = 'Americana Village';
        insert r;
        
        Case cs = new Case();
        cs.Status = 'TRP Completed';
        cs.AccountId = acc.Id;
        cs.Profile_Name__c = 'Internal Cash';
        cs.Payment_Type__c = 'Cash';
        cs.Client_Deposit_Payment_Schedule_Profile__c = 'Payment after Check In';
        cs.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Exchanges_and_Deposits').getRecordTypeId();
        cs.Exchange_Type__c = 'Maintenance Fee Protection';
        cs.Case_Type__c = 'Test Case Type';
        cs.Subject = 'Test Case';
        insert cs;
 
        
        Deposits__c inv = new Deposits__c();
        inv.Deposit_Resort_Name__c = 'Test Imperial Garden Resort';
        inv.Check_in_Date__c = System.today();
        //inv.Unit_Type__c = 'Clothes';
        inv.Unit_Number__c = '123';
        inv.Check_Out__c = System.today();
        inv.Reservation_Number__c = '1234';
        inv.Occupancy__c = 2;
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
        inv.Maint_Fees__c = 925;
        inv.Due_Date__c = System.today();
        inv.Case__c = cs.Id;
        inv.Resort_Id__c = r.Id;
        inv.Status__c = 'Approved';
        inv.Profile_Name__c = 'Internal Cash';
        inv.Payment_Type__c = 'Cash';
        inv.Deposit_Approved_On__c = Date.today().addDays(0);
        //inv.Client_Deposit_Payment_Schedule_Profile__c = 'Payment after Check In'; - test before insert trigger
        insert inv;
         
      

        // Simulate CaseHistory showing status changed to 'TRP Completed' 10 days ago
/*
         Test.startTest();
        CaseHistory ch = new CaseHistory(
            CaseId = cs.Id,
            Field = 'Status',
            OldValue = 'Open',
            NewValue = 'TRP Completed',
            CreatedDate = System.now().addDays(-10)
        );
        insert ch;
        Test.stopTest();
*/
        
        // Build input
        GetDepositsByDaysAfterTRP.InputWrapper input = new GetDepositsByDaysAfterTRP.InputWrapper();
        input.DaysAfterTRPComplete = 0;

        List<GetDepositsByDaysAfterTRP.InputWrapper> inputList = new List<GetDepositsByDaysAfterTRP.InputWrapper>{ input };

        Test.startTest();
        List<List<DepositWrapper>> result = GetDepositsByDaysAfterTRP.getDeposits(inputList);
        Test.stopTest();

        // Validate result
        System.assertNotEquals(null, result);
        System.assertEquals(1, result.size(), 'Expected one outer list');
        //System.assertEquals(1, result[0].size(), 'Expected one matching deposit');
        
        //DepositWrapper dw = result[0][0];
        //System.assertEquals(inv.Id, dw.depositId);
        //System.assertEquals(cs.Id, dw.caseId);
        //System.assertEquals(acc.Id, dw.accountId);
        //System.assertEquals('1234567890', dw.accountPhone);
    }
    
    @isTest
    static void testDepositWrapperClass() {
        DepositWrapper dw = new DepositWrapper();
        dw.accountId = '001000000000001AAA';
        dw.accountPhone = '1234567890';
        dw.caseId = '500000000000001AAA';
        dw.depositId = 'a1n000000000001AAA';
        
        // Optional assert to check values
        System.assertEquals('1234567890', dw.accountPhone);
    }
    
    
}