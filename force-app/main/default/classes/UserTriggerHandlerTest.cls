@isTest
public class UserTriggerHandlerTest {
    
    @isTest
    static void testAddUserToGroup() {
        
        Apex_Trigger_On_Off__c cp = new Apex_Trigger_On_Off__c();
        cp.name = 'UserTrigger';
        cp.isEnable__c = true;
        insert cp;
        
        Group testGroup = new Group(
            Name = 'Test Group',
            DeveloperName = 'Test_Group'
        );
        insert testGroup;
        
        Profile tourGenerationProfile = [SELECT Id FROM Profile WHERE Name = 'Tour Generation' LIMIT 1];
        
        
        User newUser = new User(
            FirstName = 'John',
            LastName = 'Doe',
            Email = 'johndoe@example.com',
            IsActive = true,
            ProfileId = tourGenerationProfile.Id,
            Username = 'puser@Test.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
        );
        
        system.runAs(new User(Id = UserInfo.getUserId())){
            insert newUser;
            
            Set<Id> userIds = new Set<Id>{newUser.Id};
                
            Test.startTest();
            UserTriggerHandler.addUserToGroup(userIds);
            Test.stopTest();
            
            List<GroupMember> groupMembers = [SELECT Id, UserOrGroupId FROM GroupMember WHERE GroupId = :testGroup.Id and UserOrGroupId =: newUser.Id];
            //system.assert(groupMembers.size()>0);
        }
    }
    
    
    @isTest
    static void testRemoveUserFromGroup() {
        
        Apex_Trigger_On_Off__c cp = new Apex_Trigger_On_Off__c();
        cp.name = 'UserTrigger';
        cp.isEnable__c = true;
        insert cp;       
        
        Group testGroup = new Group(
            Name = 'Test Group',
            DeveloperName = 'Test_Group'
        );
        insert testGroup;
        
        Profile tourGenerationProfile = [SELECT Id FROM Profile WHERE Name = 'Tour Generation' LIMIT 1];
        Profile tourGenerationProfile1 = [SELECT Id FROM Profile WHERE Name != 'Tour Generation' LIMIT 1];
        
        User existingUser = new User(
            FirstName = 'Alice',
            LastName = 'Smith',
            Email = 'alicesmith@example.com',
            IsActive = true,
            ProfileId = tourGenerationProfile.Id,
            Username = 'puser@Test.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
        );
        
        system.runAs(new User(Id = UserInfo.getUserId())){
            insert existingUser;
            existingUser.ProfileId = tourGenerationProfile1.Id;
            update existingUser;
            
            Set<Id> userIds = new Set<Id>{existingUser.Id};
                
                GroupMember groupMember = new GroupMember(
                    GroupId = testGroup.Id,
                    UserOrGroupId = existingUser.Id
                );
            
            
            Test.startTest();        
            UserTriggerHandler.addUserToGroup(userIds);
            Test.stopTest();
            
            List<GroupMember> groupMembers = [SELECT Id, UserOrGroupId FROM GroupMember WHERE GroupId = :testGroup.Id and UserOrGroupId =: existingUser.Id];
            system.assert(groupMembers.size()==0);
        }
    }
}