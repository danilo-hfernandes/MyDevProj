@isTest
public class BookReservationMarivalControllerTest {

    @isTest
    static void testSaveOpportunityDetails() {

Account acc = new Account(Name = 'Test Account', Affiliated_Id__c = 1002421, Member_Number__c = '13523412', Contact_Id__c = 5420.0);
        insert acc;
        
        Id marivalRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Marival').getRecordTypeId();
        Opportunity testOpp = new Opportunity (Name='Opp2',StageName='New', CloseDate=Date.today(),First_Payment_Date__c = system.today().addDays(2),AccountId = acc.id, RecordTypeId = marivalRecordTypeId);
        insert testOpp;
        
        Inventory_Management__c newRecord = new Inventory_Management__c();
        newRecord.Plaza__c = 'VALLARTA';
        newRecord.Resort_Name__c = 'Marival Armony Luxury Resort & Spa';
        newRecord.Unit_Type__c = 'U.H.';
        newRecord.Site_Name__c = 'Marival Armony Luxury Resort & Spa';
        newRecord.Site_Name_Id__c = '6036011';
        newRecord.Room_Type__c = 'SIERRA ROOM';
        newRecord.Room_Type_ID__c = '6036011';
        newRecord.Capacity__c = '2A';
        newRecord.Size_Upgrade__c = 0;
        newRecord.Property_Upgrade__c = 0;
        newRecord.Total_Upgrade__c = 0;
        newRecord.Property_Address__c = 'Carretera a Punta de Mita km 8.3, Playa Destiladeras';
        newRecord.Property_City__c = 'Bahia de Banderas';
        newRecord.Property_State__c = 'Nayarit';
        newRecord.Property_Country__c = 'Mexico';
        newRecord.Property_Zipcode__c = '63734';
        newRecord.Supplier__c = 'Marival';
        
        insert newRecord;


        // Call the method under test
        BookReservationMarivalController.saveOpportunityDetails(
            testOpp.Id,
            newRecord.Id,
            'U.H.',
            Date.today(),
            Date.today().addDays(3),
            '2A',
            2,
            1,
            'Marival',
            0
        );

        // Retrieve the updated opportunity
        Opportunity updatedOpp = [SELECT Id, Site_Name__c, Property__c, Destination__c, Rooms__c, Check_in__c, Check_Out__c, Capacity__c, Property_Address__c, Property_City__c, Property_Country__c, Property_State__c, Property_Zipcode__c, Room_Type__c, Adults__c, Children_0_17__c, StageName FROM Opportunity WHERE Id = :testOpp.Id];

        // Assert that the fields are updated as expected
        System.assertEquals('Marival Armony Luxury Resort & Spa', updatedOpp.Site_Name__c);
        System.assertEquals('Marival Armony Luxury Resort & Spa', updatedOpp.Property__c);
        System.assertEquals('Marival Armony', updatedOpp.Destination__c);
        System.assertEquals('Carretera a Punta de Mita km 8.3, Playa Destiladeras', updatedOpp.Property_Address__c);
        List<String> plazaList = BookReservationMarivalController.getPlazaRecords('Marival');
        List<Inventory_Management__c> invs = BookReservationMarivalController.getInventoryRecords('Marival', 'VALLARTA');
        
        // Call the method under test
        /*BookReservationMarivalController.saveOpportunityDetails(
            testOpp.Id,
            'Marival Distinct Luxury Residences',
            '1BR',
            Date.today(),
            Date.today().addDays(3),
            '2A',
            2,
            1,
            'Marival'
        );*/

        // Call the method under test
        /*BookReservationMarivalController.saveOpportunityDetails(
            testOpp.Id,
            'Marival Emotions Resort & Suites',
            'U.H.',
            Date.today(),
            Date.today().addDays(3),
            '2A + 2K',
            2,
            1,
            'Marival'
        );*/

        
          
        // Call the method under test
        BookReservationMarivalController.getExtraNight(
            invs[0].Id
        );

        // Call the method under test
        BookReservationMarivalController.getNumberOfNightsByOpportunityId(
            updatedOpp.Id
        );

        // Call the method under test
        BookReservationMarivalController.checkbookingifExist(
            updatedOpp.Id
        );

                           
                
        
    }
}