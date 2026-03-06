@isTest
public class DataSyncToSQLTest {
    @testSetup static void methodName() {
		 Account acc = new Account();
        acc.Name = 'Mitul Test';
        insert acc;
        acc.Name = 'Mitul Test a';
        acc.Dues_Last_Paid_Until__c = System.today();
        update acc;
        
        Contact con = new Contact();
        con.LastName = 'Mitul';
        con.AccountId = acc.Id;
        con.Member_Number__c = '123TEST';
        insert con;
        con.LastName = 'Mitul Test';
        update con; 
	}
    @isTest static void callAPITest(){
        Account objacc = [select id from Account limit 1];
        Contact objcon = [select id from Contact limit 1];
        set<Id> setAccountContactId = new set<Id>();
        setAccountContactId.add(objacc.Id);
        Test.setMock(HttpCalloutMock.class, new MockPaymentAPI());
        DataSyncToSQL.GetToken();
        DataSyncToSQL.AccountContactDataSync(setAccountContactId, 'Account');
        DataSyncToSQL.accountDuesPaidSync(setAccountContactId);
        setAccountContactId = new set<Id>();
        setAccountContactId.add(objcon.Id);
        DataSyncToSQL.AccountContactDataSync(setAccountContactId, 'Contact');
    }
}