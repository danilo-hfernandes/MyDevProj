public class AuthorizationUserTriggerHandler {
    public static void afterInsert(List<Authorize_Users__c> listAuthorizedUser){
        for(Authorize_Users__c objauthUser: listAuthorizedUser){
            if(objauthUser.Contact_Id__c == null){
                AuthorizedUserAPIController.postAuthorizedUser(objauthUser.Id);
                
            }
        }
    }
    public static void afterUpdate(List<Authorize_Users__c> listAuthorizedUser, Map<Id, Authorize_Users__c> oldMapAuthorizedUser){
        for(Authorize_Users__c objauthUser: listAuthorizedUser){
            if(objauthUser.IsEnabled__c != oldMapAuthorizedUser.get(objauthUser.Id).IsEnabled__c && objauthUser.Contact_Id__c != null){
                AuthorizedUserAPIController.changeAuthorizedUserStatus(objauthUser.Id);
            }
            else if(objauthUser.Contact_Id__c == null){
                objauthUser.adderror('Please contact your system admin as Contact Id is blank');
            }
        }
    }
}