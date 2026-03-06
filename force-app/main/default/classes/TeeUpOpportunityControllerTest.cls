@isTest
public class TeeUpOpportunityControllerTest {
    
    @isTest
    public static void CreateOpportunity(){
        
         
        UserRole userRole2 = [SELECT Id FROM UserRole WHERE Name =: 'Membership Upgrade Manager' LIMIT 1];
        
        Profile pfad = [SELECT Id FROM Profile WHERE Name=:'Membership Upgrade Manager'];
        
        user us = new user();
        us.LastName = 'Account';
        us.Alias = 'Product';
        us.CommunityNickname = 'User16346538912806001385';
        us.UserRoleId = userRole2.Id;
        us.ProfileId = pfad.Id;
        system.debug('us--' + us);
        
        List<user> userList = new List<user>();
                
        User getUser = [select id,Name from User where Name =: 'Product Account' Limit 1];
        
        Id recId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Corp Travel').getRecordTypeId();
        system.debug('recId---'+recId);
        Account acc = new Account();
        acc.Name = 'Acme (Sample)';
        acc.RecordTypeId = recId;
        insert acc;
        system.debug('insert acc2' + acc);
        
        Id recTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Membership_Upgrade').getRecordTypeId();
        
        system.debug('recTypeId - ' + recTypeId);
        Opportunity opp = new Opportunity();
        opp.Name = 'Acme (Sample)';
        opp.AccountId = acc.Id;
        opp.StageName = 'new';
        opp.CloseDate = date.newInstance(2020, 1, 28);
        opp.RecordTypeId = recTypeId;
        opp.First_Agent__c = getUser.Id;
        opp.First_Agent_Percentage__c = 80;
        opp.Second_Agent_Percentage__c = 20;
         
        insert opp;
        system.debug('insert opp2' + opp);
        
        TeeUpOpportunityController.fetchRecord(opp.Id);
        
        Id recordId = opp.RecordTypeId;
        Id teeupuserId =  opp.First_Agent__c;
        
        Test.startTest();
        Date appToday = System.today();
        TeeUpOpportunityController.updateOpportunity(opp.Id,getUser.Id, appToday);
        Test.stopTest();
    }
}