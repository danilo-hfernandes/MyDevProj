@isTest
private class DepositWrapperTest {
    
    @isTest
    static void testDepositWrapperProperties() {
        DepositWrapper dw = new DepositWrapper();
        dw.accountId = '001000000000001AAA';
        dw.accountPhone = '1234567890';
        dw.accountFormattedPhone = '+11234567890';
        dw.caseId = '500000000000001AAA';
        dw.depositId = 'a1n000000000001AAA';
        
        System.assertEquals('001000000000001AAA', dw.accountId);
        System.assertEquals('1234567890', dw.accountPhone);
        System.assertEquals('500000000000001AAA', dw.caseId);
        System.assertEquals('a1n000000000001AAA', dw.depositId);
    }
}