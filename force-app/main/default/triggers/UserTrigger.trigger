trigger UserTrigger on User (After insert,After Update) {
    
    Apex_Trigger_On_Off__c cs = Apex_Trigger_On_Off__c.getValues('UserTrigger');
    system.debug('--UserTrigger--'+cs);
    if(cs != null && cs.isEnable__c){ 
        
        if(trigger.isAfter){            
            Id tourGenerationProfileId = [select id from Profile where Name =: 'Tour Generation'].Id;
            
            // Adding user to 'Tour Generation' group when user is created with Tour Generation profile.
            If(trigger.isInsert){
                Set<Id> userIds = new Set<Id>();
                for(User userRecord : trigger.new){
                    if(userRecord.ProfileId == tourGenerationProfileId){
                        userIds.add(userRecord.Id);
                    }
                }
                if(userIds.size()>0){
                    UserTriggerHandler.addUserToGroup(userIds);
                }
            }
            
            // Removing or adding user in 'Tour Generation' group when user profile is changed.
            If(trigger.isUpdate){
                Set<Id> userIds = new Set<Id>();
                Set<Id> userIdsRemove = new Set<Id>();
                for(User userRecord : trigger.new){
                    if(userRecord.IsActive == true && userRecord.ProfileId == tourGenerationProfileId){
                        userIds.add(userRecord.Id);
                    }
                    if(trigger.oldMap.get(userRecord.Id).ProfileId == tourGenerationProfileId &&
                       trigger.newMap.get(userRecord.Id).ProfileId != tourGenerationProfileId){
                           userIdsRemove.add(userRecord.Id);
                       }
                }
                if(userIds.size()>0){
                    UserTriggerHandler.addUserToGroup(userIds);
                }
                if(userIdsRemove.size()>0){
                    UserTriggerHandler.removeUserFromGroup(userIdsRemove);
                }
            }
        }
    }
}