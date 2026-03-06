@IsTest
public class CustomAddProductsControllerTest {
    
    @testSetup static void setup(){
        Profile p = [select id from Profile where name='Tour Generation'];
        
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String guid = h.SubString(0,8); 
        
        UserRole r = new UserRole(DeveloperName = 'TourGen', Name = 'TourGen');
        insert r;
        
        
        User u = new user(alias = 'test123', email='tourgenagent@nerdsoft.com',
                          emailencodingkey='UTF-8', firstName='Test', lastname='Name', languagelocalekey='en_US',
                          localesidkey='en_IN', profileid = p.Id, country='India',
                          timezonesidkey='Asia/Kolkata', username=guid+'tourgenagent@nerdsoft.com.hsi', Assigned_Contacts__c=4, UserRoleId=r.Id);
        
        insert u;
    }
    
    @isTest
    public static void tryToCreateProducts() {
        Id standardPbId = Test.getStandardPricebookId();
        
        Product2 prd1 = new Product2 (Profiles_Enabled__c='Tour Generation',Opportunity_Record_Types_Enabled__c='Hawaii Collection Membership',Name='Test Product Entry 1',Description='Test Product Entry 1', isActive = true);
        insert prd1;
        
        PricebookEntry pbe1 = new PricebookEntry (Product2ID=prd1.id,Pricebook2ID=standardPbId,UnitPrice=50, isActive=true);
        insert pbe1;
        
        User u = [SELECT Id,UserRole.Name,Profile.Name FROM User WHERE Email = 'tourgenagent@nerdsoft.com' LIMIT 1];
        
        Test.startTest();
        
        System.RunAs(u){            
            Account acc = new Account(Name = 'Test Account');
            insert acc;
            
            Opportunity opp1 = new Opportunity (Name='Opp1',StageName='New',CloseDate=Date.today(),Pricebook2Id = pbe1.Pricebook2Id, AccountId = acc.id,RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Hawaii_Collection_Membership').getRecordTypeId());
            insert opp1;
            
            Map<String,Boolean> checkOppLineItemCreatePermission = CustomAddProductsController.checkOppLineItemCreatePermission();
                
            Map<String,List<PriceBookEntry>> resultmap = CustomAddProductsController.fetchPriceBookEntries(opp1.Id);
            
            Map<String,List<OpportunityLineItem>> resultmap2 = CustomAddProductsController.generateOppLineItems(resultmap.get('true'),opp1.Id);
            
            Map<String,String> resultmap3 = CustomAddProductsController.saveOppLineItems(resultmap2.get('true'));
        }
    }

}