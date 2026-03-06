public class FlowInvocablemethods {
    /*@InvocableMethod
public static void assignContactInOverflowCadenceQueueable(List<String> cadenceContactsId){
set<Id> setContactIds = new set<Id>();
for(String objId : cadenceContactsId){
setContactIds.add(objId);
}
System.enqueueJob(new AssignContactInOverflowCadenceQueueable(setContactIds)); 
}*/
    @InvocableMethod
    public static void genericAssignSalesCadence(List<String> cadenceContactsId){
        String salesCadenceName = 'TourGen-Affiliate Marketing';
        list<Contact> conList= new list<Contact>();
        conList=[select id,name,Preferred_Language__c,Original_Source__c,LeadSource from contact where id IN:cadenceContactsId and Marketing_Email_opt_out__c = false];
        set<Id> setContactIdsDefaut = new set<Id>();
        set<Id> setContactIdsPOR = new set<Id>();
        set<Id> setContactIdsSPA = new set<Id>();
        set<Id> setContactIdsVidantaInfluencer = new set<Id>();
        set<Id> setContactIdsOriginalSource = new set<Id>();
        set<Id> setContactIdsOriginalSourceASAffiliateMarketing = new set<Id>();
        for(Contact con:conList){
            if(con.Original_Source__c == 'Diamonds International' || con.Original_Source__c == 'Diamonds International-Alaska' || con.Original_Source__c == 'Diamonds International Mayan'){
                setContactIdsOriginalSource.add(con.Id);
            }
            else if(con.Original_Source__c == 'Vidanta Affiliate Marketing' || con.Original_Source__c == 'Marival Affiliate Marketing') {
                setContactIdsOriginalSourceASAffiliateMarketing.add(con.id);
            }
            else if(con.LeadSource == 'Vidanta Influencer'){
                setContactIdsVidantaInfluencer.add(con.Id);
            }
            else if(con.Preferred_Language__c=='POR'  ){
                setContactIdsPOR.add(con.id);
            }
            else if(con.Preferred_Language__c=='SPA' ){
                setContactIdsSPA.add(con.id);
            }
            else { 
                setContactIdsDefaut.add(con.id);
            }
        }
        if(setContactIdsOriginalSource.size()>0){
            System.enqueueJob(new GenericAssignToSalesCadence(setContactIdsOriginalSource, 'TourGen-Affiliate Marketing Diamonds Intl')); 
        }
        if(setContactIdsOriginalSourceASAffiliateMarketing.size()>0){
            System.enqueueJob(new GenericAssignToSalesCadence(setContactIdsOriginalSourceASAffiliateMarketing, 'TourGen-AS Affiliate Marketing')); 
        }
        if(setContactIdsVidantaInfluencer.size()>0){
            System.enqueueJob(new GenericAssignToSalesCadence(setContactIdsVidantaInfluencer, 'TourGen-Vidanta Influencer')); 
        }
        if(setContactIdsDefaut.size()>0){
            System.enqueueJob(new GenericAssignToSalesCadence(setContactIdsDefaut, 'TourGen-Affiliate Marketing')); 
        }
        if(setContactIdsSPA.size()>0){
            System.enqueueJob(new GenericAssignToSalesCadence(setContactIdsSPA, 'TourGen-Affiliate Marketing SPA')); 
        }
        if(setContactIdsPOR.size()>0){
            System.enqueueJob(new GenericAssignToSalesCadence(setContactIdsPOR, 'TourGen-Affiliate Marketing POR')); 
        }
    }    
}