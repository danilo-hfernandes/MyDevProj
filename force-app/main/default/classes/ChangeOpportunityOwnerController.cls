public class ChangeOpportunityOwnerController {
    public List<Opportunity> OppList{get;private set;}
    public Integer noOfRecords{get;set;}
    public String opportunityString{get;set;}
    public Boolean errorMessage{get;set;}
    public ChangeOpportunityOwnerController(ApexPages.StandardSetController stdSetController){
        // Returns all selected records
        errorMessage = false;
        noOfRecords = 0;
        set<Id> selectedContactIds = new set<Id>();
        OppList = (List<Opportunity>) stdSetController.getSelected();
        system.debug('>>>>>>OppList>>>>>>'+OppList);
        Id profileId= userinfo.getProfileId();
        Id userId = userinfo.getUserId();
        String UserWhoHasAccess = System.Label.Opportunity_Bulk_Assign_Access;
        List<String> userIds = new List<String>();
        if(UserWhoHasAccess != null && UserWhoHasAccess.contains(',')){
            userIds = UserWhoHasAccess.split(',');
        }
        else if(UserWhoHasAccess != null ){
            userIds.add(UserWhoHasAccess);
        }
        String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
        system.debug('ProfileName'+profileName);
        if(profileName != 'System Administrator' && profileName != 'MX National Sales Manager' && profileName != 'Membership Upgrade Manager' && profileName != 'MU National Sales Manager' && !userIds.contains(userId)){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'You do not have access, Please contact to Administrator'));
            errorMessage = true;
        }
        else if(OppList != null && OppList.size() > 0){
            for(Opportunity objcon : OppList){
                selectedContactIds.add(objcon.Id);
            }
            noOfRecords = selectedContactIds.size();
            opportunityString = '';
            opportunityString = JSON.serialize(selectedContactIds);
            system.debug('>>>>selectedContactIds>>>>>>'+selectedContactIds);
        }
        else {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Select at least one record and try again.'));
            errorMessage = true;
        }
    }
    @AuraEnabled
    public static string updateOpportunityOwner(list<Id> setOfConIds , String userId){
        try {
            List<Opportunity> OppListU = new List<Opportunity>();
            system.debug('>>>>setOfConIds>>>>'+setOfConIds);
            system.debug('>>>>>userId>>>>>>>'+userId);
            for(Id conId : setOfConIds){
                Opportunity objcon = new Opportunity();
                objcon.Id = conId;
                objcon.OwnerId = (Id)(userId.replace('"',''));
                objcon.Owner_Updated_Date__c = system.today();
                OppListU.add(objcon);
            }
            system.debug('>>>conlst>>>>>'+OppListU);
            if(OppListU != null && OppListU.size() > 0){
                update OppListU;
                return 'Success';
            }
            return null;
        } catch (Exception e) {
            system.debug('---e--'+e);
            throw new AuraHandledException(e.getMessage());
        }
    }
}