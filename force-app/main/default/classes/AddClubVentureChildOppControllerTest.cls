@IsTest
public class AddClubVentureChildOppControllerTest {

    @IsTest
    public static void test1() {

        // --- Setup objects (Profile/UserRole/User) --- //
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Tour Generation' LIMIT 1];

        Blob b = Crypto.generateAesKey(128);
        String guid = EncodingUtil.convertToHex(b).substring(0, 8);

        UserRole r = new UserRole(DeveloperName = 'TourGen', Name = 'TourGen');
        insert r;

        User u = new User(
            Alias='test123',
            Email='tourgenagent@nerdsoft.com',
            EmailEncodingKey='UTF-8',
            FirstName='Test',
            LastName='Name',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_IN',
            ProfileId=p.Id,
            Country='India',
            TimeZoneSidKey='Asia/Kolkata',
            Username= guid + 'tourgenagent@nerdsoft.com.hsi',
            Assigned_Contacts__c=4,
            UserRoleId=r.Id
        );
        insert u;

        // --- Switch context to avoid Mixed DML --- //
        System.runAs(u) {
            Test.startTest();

            Account acc = new Account(Name = 'Test Account32', Affiliated_Id__c = 1002122);
            insert acc;

            Id standardPb = Test.getStandardPricebookId();

            // Extra pricebook created (kept for parity with original code)
            Pricebook2 pbk1 = new Pricebook2(Name='Gift Product 1', Description='Gift Product 1', IsActive=true);
            insert pbk1;

            Product2 prd1 = new Product2(Name='Gift Product 1', Description='Gift Product 1', IsActive=true);
            insert prd1;

            PricebookEntry pbe1 = new PricebookEntry(
                Product2Id = prd1.Id,
                Pricebook2Id = standardPb,
                UnitPrice = 50,
                IsActive = true
            );
            insert pbe1;

            Id oppRecordTypeId = Schema.SObjectType.Opportunity
                .getRecordTypeInfosByDeveloperName()
                .get('Club_Venture_Membership')
                .getRecordTypeId();

            Opportunity opp1 = new Opportunity(
                Name='Opp1',
                StageName='New',
                CloseDate=Date.today(),
                Pricebook2Id = pbe1.Pricebook2Id,
                AccountId = acc.Id,
                RecordTypeId = oppRecordTypeId
            );
            insert opp1;

            Tour__c tour = new Tour__c(
                Name = 'Test Tour',
                Date__c = Date.today().addDays(2),
                Tour_Time__c = Time.newInstance(10, 0, 0, 0),
                Booked_Tours__c = 5,
                Tour_Allotment__c = 10,
                Location__c = 'Test Location',
                Wave__c = 'Wave 1'
            );
            insert tour;

            Tour_appointment__c tourApp = new Tour_appointment__c(
                Name = 'Test Tour Appointment',
                Opportunity__c = opp1.Id,
                Tour__c = tour.Id,
                Appointment_Date__c = tour.Date__c,
                Appointment_Time__c = tour.Tour_Time__c,
                Opp_Status__c = 'Booked',
                Closing_Agents__c = u.Id
            );
            insert tourApp;

            Map<String, String> result = AddClubVentureChildOppController.tryToAddChildOpp(opp1.Id);

            Test.stopTest();
        }
    }
}