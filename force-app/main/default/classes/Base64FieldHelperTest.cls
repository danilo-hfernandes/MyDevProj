@IsTest
private class Base64FieldHelperTest {
    
    @IsTest
    static void testPopulateBase64FieldsForLeads() {
        // Create sample Leads without hashed fields
        Lead l1 = new Lead(
            FirstName = 'John',
            LastName = 'Doe',
            Email = 'john.doe@test.com',
            Phone = '1234567890',
            Company = 'Test Company'
        );
        
        Lead l2 = new Lead(
            FirstName = 'Jane',
            LastName = 'Smith',
            Email = 'jane.smith@test.com',
            Phone = '0987654321',
            Company = 'Test Company 2'
        );

        List<SObject> leadList = new List<SObject>{ l1, l2 };

        // Call method under test
        Test.startTest();
        Base64FieldHelper.populateBase64Fields(leadList, 'Lead');
        Test.stopTest();

        // Verify that the Base64 fields were populated correctly
        for (SObject sobj : leadList) {
            Lead l = (Lead)sobj;
            
            System.assertNotEquals(null, l.Hashed_Email__c, 'Hashed_Email__c should not be null');
            System.assertNotEquals(null, l.Hashed_Phone__c, 'Hashed_Phone__c should not be null');
            System.assertNotEquals(null, l.Hashed_FirstName__c, 'Hashed_FirstName__c should not be null');
            System.assertNotEquals(null, l.Hashed_LastName__c, 'Hashed_LastName__c should not be null');
            
            // Validate Base64 encoding correctness
            String expectedEmail = EncodingUtil.base64Encode(Blob.valueOf(l.Email.trim()));
            String expectedPhone = EncodingUtil.base64Encode(Blob.valueOf(l.Phone.trim()));
            String expectedFirstName = EncodingUtil.base64Encode(Blob.valueOf(l.FirstName.trim()));
            String expectedLastName = EncodingUtil.base64Encode(Blob.valueOf(l.LastName.trim()));

            System.assertEquals(expectedEmail, l.Hashed_Email__c, 'Email hash mismatch');
            System.assertEquals(expectedPhone, l.Hashed_Phone__c, 'Phone hash mismatch');
            System.assertEquals(expectedFirstName, l.Hashed_FirstName__c, 'FirstName hash mismatch');
            System.assertEquals(expectedLastName, l.Hashed_LastName__c, 'LastName hash mismatch');
        }
    }

    @IsTest
    static void testPopulateBase64FieldsWithBlankHashedFields() {
        // Lead with already populated hashed fields should remain unchanged
        Lead l = new Lead(
            FirstName = 'Tom',
            LastName = 'Lee',
            Email = 'tom.lee@test.com',
            Phone = '5555555555',
            Company = 'Test Co',
            Hashed_Email__c = 'existingHash',
            Hashed_Phone__c = 'existingHash',
            Hashed_FirstName__c = 'existingHash',
            Hashed_LastName__c = 'existingHash'
        );
        
        List<SObject> leads = new List<SObject>{ l };
        
        Test.startTest();
        Base64FieldHelper.populateBase64Fields(leads, 'Lead');
        Test.stopTest();
        
        Lead updated = (Lead)leads[0];
        // Verify that existing hashes were not overwritten
        System.assertEquals('existingHash', updated.Hashed_Email__c, 'Existing email hash should not change');
        System.assertEquals('existingHash', updated.Hashed_Phone__c, 'Existing phone hash should not change');
        System.assertEquals('existingHash', updated.Hashed_FirstName__c, 'Existing first name hash should not change');
        System.assertEquals('existingHash', updated.Hashed_LastName__c, 'Existing last name hash should not change');
    }
}