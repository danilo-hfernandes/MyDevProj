@isTest
public class ChangeContactOwnerController_Test {
    @testSetup static void testRecords() {
        Account objacc = new Account();
        objacc.Name = 'Test Sample';
        objacc.Phone = '631-00-000';
        insert objacc;
        
        Contact objcon = new Contact();
        objcon.LastName = 'Sample Test';
        objcon.email = 'testSample@gmail.com';
        objcon.Bypass_Sync_to_SQL__c = false;
        insert objcon;
    }
    @isTest static void test1() {
        Test.startTest();
        List<Contact> conlst = [select id from Contact where LastName = 'Sample Test' limit 1];
        list<Id> setConId = new list<Id>();
        setConId.add(conlst[0].Id);
        Test.setCurrentPage(Page.ChangeContactOwner);
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(conlst);
        stdSetController.setSelected(conlst);
        ChangeContactOwnerController ext = new ChangeContactOwnerController(stdSetController);
        ChangeContactOwnerController.updateContactOwner(setConId, UserInfo.getUserId());
        ChangeContactOwnerController.sendEmail('Id, Name');
        Test.stopTest();
    }
}