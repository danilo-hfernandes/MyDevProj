public without sharing  class TeeUpOpportunityController {
    
    /*@AuraEnabled 
    public static list<user> fetchRecord(){
        return [select Id, Name,IsActive from user where IsActive = True order by Name asc];
    }*/
    
@AuraEnabled
public static List<User> fetchRecord(String oppId){

    Opportunity opp = [
        SELECT RecordType.DeveloperName
        FROM Opportunity
        WHERE Id = :oppId
        LIMIT 1
    ];

    String profileLike;

    // Social Ad Sales
    if(opp.RecordType.DeveloperName == 'Social_Ad_Sales'){
        profileLike = 'Social Ad Sales%';
    }

    // Membership Upgrade family
    Set<String> membershipRTs = new Set<String>{
        'SFX_Membership',
        'Hawaii_Collection_Membership',
        'Membership_Upgrade',
        'MTRC_Retail',
        'Membership_Add_On',
        'Reserve_Collection_Membership'
    };

    if(membershipRTs.contains(opp.RecordType.DeveloperName)){
        profileLike = 'Membership Upgrade%';
    }

    // Fallback → all active users
    if(String.isBlank(profileLike)){
        return [
            SELECT Id, Name
            FROM User
            WHERE IsActive = true
            ORDER BY Name
        ];
    }

    // Membership Upgrade needs two profile prefixes
    if(profileLike == 'Membership Upgrade%'){
        return [
            SELECT Id, Name
            FROM User
            WHERE IsActive = true
            AND (
                Profile.Name LIKE 'Membership Upgrade%' OR
                Profile.Name LIKE 'MU National Sales%'
            )
            ORDER BY Name
        ];
    }
    
    // Default single prefix (e.g., Social Ad Sales)
    return [
        SELECT Id, Name
        FROM User
        WHERE IsActive = true
        AND Profile.Name LIKE :profileLike
        ORDER BY Name
    ];
}
    
    @AuraEnabled
    public static Opportunity updateOpportunity(String recordId,string teeupuserId, Date appointmentDate){
        system.debug('--recordId---'+recordId);
        system.debug('--teeupuserId---'+teeupuserId);
        Opportunity opp = [select id,First_Agent__c,OwnerId,Second_Agent_Percentage__c,Second_Agent__c,Referral_Agent__c,Tee_Up_Date__c,Tee_Up_Agent__c, Closing_Agent__c  from Opportunity where id=:recordId];
        User u = [SELECT Id,Profile.Name,UserRole.Name FROM User WHERE Id =: UserInfo.getUserId() LIMIT 1];
        system.debug('--opp--'+opp);
        system.debug('--OwnerId--'+opp.OwnerId);
        
        if(teeupuserId != null && teeupuserId != ''){
            opp.Tee_Up_Agent__c = UserInfo.getUserId();
            opp.Closing_Agent__c = teeupuserId;
            opp.First_Agent__c = teeupuserId; 
            opp.OwnerId = teeupuserId;
            String currentUserProfile = '';
            String currentUserRole = '';
            if(u.Profile.Name != null && u.Profile.Name != '')
            {
                currentUserProfile = u.Profile.Name;
            }
            if(u.UserRole.Name != null && u.UserRole.Name != '')
            {
                currentUserRole = u.UserRole.Name;
            }
            
            if(currentUserRole.contains('Tour Gen') || currentUserRole.contains('TourGen') || currentUserProfile.contains('Tour Gen'))
            {
                opp.First_Agent_Percentage__c = 75;//80;
                opp.Second_Agent_Percentage__c = 25;//20;
            }
            else if(currentUserRole.contains('Membership Upgrade') || currentUserProfile.contains('Membership Upgrade'))
            {
                opp.First_Agent_Percentage__c = 80;//80;
                opp.Second_Agent_Percentage__c = 20;//20;
            }
            else
            {
                opp.First_Agent_Percentage__c = 80;//80;
                opp.Second_Agent_Percentage__c = 20;//20;  
            }
            
            opp.Second_Agent__c = UserInfo.getUserId();
            opp.Tee_Up_Date__c = System.now();
        }
        if(appointmentDate != null){
            opp.Opportunity_Appointment_Date__c = appointmentDate;
        }
        try{
            system.debug('opp - ' + opp);
            update opp;
            system.debug('opp - ' + opp);
        }catch(Exception e){
            system.debug('--e--'+e);
            system.debug('--e---'+e.getLineNumber());
            system.debug('--e---'+e.getCause());
            system.debug('--e---'+e.getMessage());
            system.debug('--e---'+e.getTypeName());
	        throw new AuraHandledException('Error updating Opportunity: ' + e.getMessage()); //TGR-512
       } 
        return opp;
    }
    
    @AuraEnabled
    public static Opportunity fetchOldAgentName(String oppId) {
        return [select Id, Tee_Up_Agent__c,Tee_Up_Agent__r.Name, Closing_Agent__c,Closing_Agent__r.Name, Referral_Agent__c, Record_Type_Name__c,Opportunity_Appointment_Date__c from Opportunity where id=:oppId];
    }
}