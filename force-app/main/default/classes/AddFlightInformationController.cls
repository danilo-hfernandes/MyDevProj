public class AddFlightInformationController {
    @AuraEnabled 
    public static boolean fetchUserAccess(){
        String userProfileName = [select Name from profile where id =: userinfo.getProfileId()].Name;
        if(userProfileName == 'System Administrator'){
            return true;
        }else{
            return false;
        }
    }
}