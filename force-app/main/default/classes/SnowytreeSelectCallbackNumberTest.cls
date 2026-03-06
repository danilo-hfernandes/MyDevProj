@isTest
public class SnowytreeSelectCallbackNumberTest {

    @testSetup
    static void setupTestData() {
        // Create test data for Area_Code_to_Phone_Number_Mapping__c
        Area_Code_to_Phone_Number_Mapping__c mapping1 = new Area_Code_to_Phone_Number_Mapping__c(
            Area_Code__c = '123',
            Annual_Dues_Callback_Number__c = '4075504511',
            TourGen_Callback_Number__c = '407576123'
        );
        insert mapping1;
        
        // Callback numbers linked to the parent
        insert new List<Callback_Number__c>{
            new Callback_Number__c(
                Name = 'Member Engagement Agent',
                Area_Code_to_Phone_Number_Mapping__c = mapping1.Id,
                Call_Profile__c = 'Annual Dues',
                Callback_Number__c = '4075504511'
            ),
                new Callback_Number__c(
                    Name = 'Tour Generation',
                    Area_Code_to_Phone_Number_Mapping__c = mapping1.Id,
                    Call_Profile__c = 'TourGen',
                    Callback_Number__c = '407576123'
                )
         };
             
                     // Create test data for Area_Code_to_Phone_Number_Mapping__c
        Area_Code_to_Phone_Number_Mapping__c mapping2 = new Area_Code_to_Phone_Number_Mapping__c(
            Area_Code__c = '000',
            Annual_Dues_Callback_Number__c = '4075504511',
            TourGen_Callback_Number__c = '407576123'
        );
        insert mapping2;
        
        // Callback numbers linked to the parent
        insert new List<Callback_Number__c>{
            new Callback_Number__c(
                Name = 'Member Engagement Agent',
                Area_Code_to_Phone_Number_Mapping__c = mapping2.Id,
                Call_Profile__c = 'Annual Dues',
                Callback_Number__c = '4075504511'
            ),
                new Callback_Number__c(
                    Name = 'Tour Generation',
                    Area_Code_to_Phone_Number_Mapping__c = mapping2.Id,
                    Call_Profile__c = 'TourGen',
                    Callback_Number__c = '407576123'
                )
         };
                    
    }

    @isTest
    static void testGetPresentedClid_withMemberEngagementAgent() {

        // Retrieve the custom metadata for Member Engagement Agent profile
        Callback_Number_Profiles__mdt callbackProfile = [
            SELECT Type_of_Callback__c, Default_Number__c
            FROM Callback_Number_Profiles__mdt
            WHERE MasterLabel = 'Member Engagement Agent'
            LIMIT 1
        ];

        // Retrieve Mapping Data
        Area_Code_to_Phone_Number_Mapping__c mapping1 = [
            SELECT Annual_Dues_Callback_Number__c, TourGen_Callback_Number__c
            FROM Area_Code_to_Phone_Number_Mapping__c
            WHERE Area_Code__c = '123'
            LIMIT 1
        ];

                // Create a test profile with Member Engagement Agent
                Profile profile1 = [SELECT Id FROM Profile WHERE Name = 'Member Engagement Agent' LIMIT 1];
                
         Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String guid = h.SubString(0,8);
        
                User user1 = new User(
                    FirstName = 'Test',
                    LastName = 'User1',
                    Alias = 'tuser1',
                    Email = 'testuser1@example.com',
                    Username = guid+'testuser1@example.com.test',
                    CommunityNickname = 'testuser1',
                    ProfileId = profile1.Id,
                    LanguageLocaleKey = 'en_US',
                    TimeZoneSidKey = 'America/Los_Angeles',
                    LocaleSidKey = 'en_US',
                    EmailEncodingKey = 'UTF-8',
                    IsActive = true
                );

        Test.startTest();
        System.runAs(user1) {
            SnowytreeSelectCallbackNumber clidSelector = new SnowytreeSelectCallbackNumber();
            
            // JSON input for clickToDialJson
            String clickToDialJson = '{"number": "+11235551234"}';
            
            // Call method under test
            VCCCore.PresentedClidResult result = clidSelector.GetPresentedClid(clickToDialJson);

            Test.stopTest();

            // Verify the callback number matches the custom metadata's value
            String expectedCallbackNumber = (callbackProfile != null) 
                ? (String) mapping1.get(callbackProfile.Type_of_Callback__c)
                : callbackProfile.Default_Number__c;

            System.assertEquals(expectedCallbackNumber, result.presentedClid, 
                                'Callback number does not match expected for Member Engagement Agent');
        }
    }

    @isTest
    static void testGetPresentedClid_withTourGeneration() {

        // Retrieve the custom metadata for Tour Generation profile
        Callback_Number_Profiles__mdt callbackProfile = [
            SELECT Type_of_Callback__c, Default_Number__c
            FROM Callback_Number_Profiles__mdt
            WHERE MasterLabel = 'Tour Generation'
            LIMIT 1
        ];

        // Retrieve Mapping Data
        Area_Code_to_Phone_Number_Mapping__c mapping1 = [
            SELECT Annual_Dues_Callback_Number__c, TourGen_Callback_Number__c
            FROM Area_Code_to_Phone_Number_Mapping__c
            WHERE Area_Code__c = '123'
            LIMIT 1
        ];

        // Create a test profile with Tour Generation
        Profile profile2 = [SELECT Id FROM Profile WHERE Name = 'Tour Generation' LIMIT 1];
		
                 Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String guid = h.SubString(0,8);
        
        User user2 = new User(
            FirstName = 'Test',
            LastName = 'User2',
            Alias = 'tuser2',
            Email = 'testuser2@example.com',
            Username = guid+'testuser2@example.com.test',
            CommunityNickname = 'testuser2',
            ProfileId = profile2.Id,
            LanguageLocaleKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            IsActive = true
        );

        Test.startTest();
        System.runAs(user2) {
            SnowytreeSelectCallbackNumber clidSelector = new SnowytreeSelectCallbackNumber();
            
            // JSON input for clickToDialJson
            String clickToDialJson = '{"number": "+11235551234"}';
            
            // Call method under test
            VCCCore.PresentedClidResult result = clidSelector.GetPresentedClid(clickToDialJson);
            
            Test.stopTest();

            // Verify the callback number matches the custom metadata's value
            String expectedCallbackNumber = (callbackProfile != null) 
                ? (String) mapping1.get(callbackProfile.Type_of_Callback__c)
                : callbackProfile.Default_Number__c;

            System.assertEquals(expectedCallbackNumber, result.presentedClid, 
                                'Callback number does not match expected for Tour Generation');
        }
    }

    @isTest
    static void testGetPresentedClid_withDefaultNumber() {

        // Retrieve the custom metadata for Member Engagement Agent profile
        Callback_Number__c callbackNumberRec = [
            SELECT Callback_Number__c,Call_Count__c FROM Callback_Number__c WHERE Area_Code__c = '000' AND Name = 'Member Engagement Agent' LIMIT 1
        ];
                
        Profile profile1 = [SELECT Id FROM Profile WHERE Name = 'Member Engagement Agent' LIMIT 1];
                
                 Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String guid = h.SubString(0,8);
        
            User user1 = new User(
                FirstName = 'Test',
                LastName = 'User1',
                Alias = 'tuser1',
                Email = 'testuser1@example.com',
                Username = guid+'testuser1@example.com.test',
                CommunityNickname = 'testuser1',
                ProfileId = profile1.Id,
                LanguageLocaleKey = 'en_US',
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                EmailEncodingKey = 'UTF-8',
                IsActive = true
            );

        Test.startTest();
        System.runAs(user1) {
            SnowytreeSelectCallbackNumber clidSelector = new SnowytreeSelectCallbackNumber();
            
            // JSON input with an unknown area code
            String clickToDialJson = '{"number": "+19995551234"}';
            
            // Call method under test
            VCCCore.PresentedClidResult result = clidSelector.GetPresentedClid(clickToDialJson);

            Test.stopTest();

            // Verify the default callback number from custom metadata
            System.assertEquals(callbackNumberRec.Callback_Number__c, result.presentedClid, 
                                'Default callback number does not match expected for unknown area code');
        }
    }
    
/*@isTest
static void testGetPresentedClid_withOrderingAndCallCount() {
    // Reuse mapping for area code '123' created in @testSetup
    Area_Code_to_Phone_Number_Mapping__c mapping = [
        SELECT Id 
        FROM Area_Code_to_Phone_Number_Mapping__c 
        WHERE Area_Code__c = '123' 
        LIMIT 1
    ];

    // Reuse the same Call_Profile__c used in setup ("TourGen")
    // Add two new callback records with different Last_Call_Made__c values
    Datetime now = System.now();

    Callback_Number__c older = new Callback_Number__c(
        Name = 'Tour Generation - Oldest',
        Call_Profile__c = 'TourGen',
        Callback_Number__c = '5551110000',
        Last_Call_Made__c = now.addDays(-5),
        Call_Count__c = 2,
        Area_Code_to_Phone_Number_Mapping__c = mapping.Id
    );

    Callback_Number__c newer = new Callback_Number__c(
        Name = 'Tour Generation - Newer',
        Call_Profile__c = 'TourGen',
        Callback_Number__c = '5552220000',
        Last_Call_Made__c = now.addDays(-1),
        Call_Count__c = 1,
        Area_Code_to_Phone_Number_Mapping__c = mapping.Id
    );

    insert new List<Callback_Number__c>{ older, newer };

    // Reuse existing Tour Generation profile from the org
    Profile profile = [SELECT Id FROM Profile WHERE Name = 'Tour Generation' LIMIT 1];

    // Generate a unique username
    Blob b = Crypto.GenerateAESKey(128);
    String h = EncodingUtil.ConvertTohex(b);
    String guid = h.substring(0,8);

    User user = new User(
        FirstName = 'Order',
        LastName = 'Test',
        Alias = 'ordert',
        Email = 'ordertest@example.com',
        Username = guid + 'ordertest@example.com.test',
        CommunityNickname = 'ordertest',
        ProfileId = profile.Id,
        LanguageLocaleKey = 'en_US',
        TimeZoneSidKey = 'America/Los_Angeles',
        LocaleSidKey = 'en_US',
        EmailEncodingKey = 'UTF-8',
        IsActive = true
    );

    insert user;

    Test.startTest();
    System.runAs(user) {
        SnowytreeSelectCallbackNumber selector = new SnowytreeSelectCallbackNumber();

        // JSON input matching area code '123'
        String clickToDialJson = '{"number": "+11235551234"}';
        VCCCore.PresentedClidResult result = selector.GetPresentedClid(clickToDialJson);
    }
    Test.stopTest();

    // Verify that the oldest record was selected and updated
    Callback_Number__c selectedRecord = [
        SELECT Callback_Number__c, Call_Count__c, Last_Call_Made__c
        FROM Callback_Number__c
        WHERE Id = :older.Id
    ];

    System.assertEquals('5551110000', selectedRecord.Callback_Number__c,
        'The record with the oldest Last_Call_Made__c should be selected first.');

    System.assertEquals(3, selectedRecord.Call_Count__c,
        'Call_Count__c should have incremented by 1 when selected.');

    // Verify that the newer record was not updated
    Callback_Number__c notSelected = [
        SELECT Call_Count__c, Last_Call_Made__c
        FROM Callback_Number__c
        WHERE Id = :newer.Id
    ];

    System.assertEquals(1, notSelected.Call_Count__c,
        'The newer record should remain unchanged.');
    System.assertEquals(now.addDays(-1).millisecond(), notSelected.Last_Call_Made__c.millisecond(),
        'The newer record’s timestamp should not change.');
}*/
    
}