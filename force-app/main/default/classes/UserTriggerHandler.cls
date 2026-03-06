public class UserTriggerHandler {

    public static void addUserToGroup(Set<Id> userIds){
        List<GroupMember>groupMemberList =new List<GroupMember>(); 
        
        List<Group> groupRec=[select Id from Group Where DeveloperName='Tour_Generation' limit 1];
        
        List<User> users=[Select Id,Name from user Where Id IN :userIds];
        
        for(User user : users){
            
            GroupMember grpMember= new GroupMember();
            if(groupRec.size()>0){
                grpMember.GroupId = groupRec[0].Id;
                grpMember.UserOrGroupId = user.Id;
                groupMemberList.add(grpMember);
            }
            
        }
        
        system.debug('groupMemberList=== '+groupMemberList);
        if(groupMemberList.size()>0){
            insert groupMemberList;
        }
    }
    
    public static void removeUserFromGroup(Set<Id> userIds){
        
        List<Group> groupRec=[select Id from Group Where DeveloperName ='Tour_Generation' Limit 1];
        
        if(groupRec.size()>0){
            List<GroupMember> groupMemberList  = [Select Id from GroupMember where GroupId =: groupRec[0].Id and UserOrGroupId in : userIds ];
            
            system.debug('groupMemberList=== '+groupMemberList);
            if(groupMemberList.size()>0){
                delete groupMemberList;
            } 
        }        
    }
}