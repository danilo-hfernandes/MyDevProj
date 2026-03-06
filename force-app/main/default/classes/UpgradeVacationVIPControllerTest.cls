@isTest
public class UpgradeVacationVIPControllerTest {
    @isTest
    static void contactValidAffliate(){
        Account acc = New Account();
        acc.Name = 'acctest';
        acc.Member_Number__c = 'AP-*-EMP01';
        acc.Affiliated_Id__c = 1002336;
        acc.Affiliate_Name__c = 'Vacation VIP';
        acc.Email__c = 'test@accountemail.com';
        acc.First_Name__c = 'test';
        acc.Last_Name__c = 'name';
        Insert acc;
        
        Id standardPbId = Test.getStandardPricebookId();
        
        Product2 prd1 = new Product2 (Name='Vacation VIP Membership Upgrade',Description='Test Product Entry 1', isActive = true);
        insert prd1;
        
        PricebookEntry pbe1 = new PricebookEntry (Product2ID=prd1.id,Pricebook2ID=standardPbId,UnitPrice=699, isActive=true);
        insert pbe1;
        
        Product2 prd2 = new Product2 (Name='Cruise Certificate Add-On',Description='Test Product Entry 2', isActive = true);
        insert prd2;
        
        PricebookEntry pbe2 = new PricebookEntry (Product2ID=prd2.id,Pricebook2ID=standardPbId,UnitPrice=0, isActive=true);
        insert pbe2;
        
        Contact cont= New Contact();
        cont.FirstName='test';
        cont.LastName = 'testname';
        cont.AffiliatedId__c = 1002336;
        cont.AccountId = acc.id;
        Insert cont;
        
        Map<String,String> results = UpgradeVacationVIPController.tryToUpgradeVacationVIP(cont.Id);
        //error opp already exist
        Map<String,String> results2 = UpgradeVacationVIPController.tryToUpgradeVacationVIP(cont.Id);
    }
    @isTest
    static void contactInvalidAffliate(){
        Account acc = New Account();
        acc.Name = 'acctest';
        acc.Member_Number__c = 'AP-*-EMP01';
        acc.Affiliated_Id__c = 999999;
        acc.Affiliate_Name__c = 'Vacation VIP';
        acc.Email__c = 'test@accountemail.com';
        acc.First_Name__c = 'test';
        acc.Last_Name__c = 'name';
        Insert acc;
        
        Contact cont= New Contact();
        cont.FirstName='test';
        cont.LastName = 'testname';
        cont.AffiliatedId__c = 999999;
        cont.AccountId = acc.id;
        Insert cont;
        
        Map<String,String> results = UpgradeVacationVIPController.tryToUpgradeVacationVIP(cont.Id);
    }
}