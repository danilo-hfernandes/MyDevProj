@isTest
public class TestleadTriggerOM {
    @isTest
    public static void testLead() {
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
        Lead a = new Lead(Company='test', LeadSource = 'CFD FB', FirstName ='test', LastName ='Test');
        insert a;        
    }
}