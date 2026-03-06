@isTest
private class AssignCadenceWithChainingTest {
    @isTest static void testChaining() {
        Account acc = new Account(Name = 'Chaining Account');
        insert acc;
        
        Contact con1 = new Contact(FirstName = 'Chain', LastName = 'One', AccountId = acc.Id);
        Contact con2 = new Contact(FirstName = 'Chain', LastName = 'Two', AccountId = acc.Id);
        insert new List<Contact>{con1, con2};
            
            Map<String, Set<Id>> cadenceMap = new Map<String, Set<Id>>();
        cadenceMap.put('CadenceOne', new Set<Id>{con1.Id});
        //cadenceMap.put('CadenceTwo', new Set<Id>{con2.Id});
        
        Test.setMock(HttpCalloutMock.class, new mockHttpResponseGeneratorAssignCadence()); 
        
        Test.startTest();
        System.enqueueJob(new AssignCadenceWithChaining(cadenceMap, 0)); 
        Test.stopTest();
    }
    
    @isTest static void testMockConstructorWithBody() {
        // This will hit the constructor mockHttpResponseGeneratorAssignCadence(String bodyString)
        mockHttpResponseGeneratorAssignCadence mock = new mockHttpResponseGeneratorAssignCadence('{"status":"mocked"}');
        
        Test.setMock(HttpCalloutMock.class, mock);
        
        System.HttpRequest req = new System.HttpRequest();
        req.setEndpoint('https://example.com');
        req.setMethod('POST');
        
        System.HttpResponse res = mock.respond(req);
        
        System.assertEquals(200, res.getStatusCode(), 'Expected status 200');
        System.assertEquals('{"status":"mocked"}', res.getBody(), 'Expected mocked body');
    }
    
    
}