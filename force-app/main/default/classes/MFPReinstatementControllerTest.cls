@isTest
public class MFPReinstatementControllerTest {
    @isTest
    static void createOppTest(){
        
        Account objAcc = new Account();
        objAcc.Name = 'Test';
        objAcc.Dues_Last_Paid_Until__c = System.today();
        insert objAcc;
        
        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 standardPricebook = new Pricebook2(
            Id = pricebookId,
            IsActive = true
        );
        update standardPricebook;
        
        Product2 objprod = new Product2();
        objprod.Name = 'MFP Reinstatement';
        objprod.IsActive = true;
        insert objprod;
        
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = objProd.Id, UnitPrice = 100, IsActive = true);
		insert standardPrice;
        
        MFPReinstatementController.validateAccount(objAcc.Id);
        MFPReinstatementController.createOpportunity(objAcc.Id);
    }
    
}