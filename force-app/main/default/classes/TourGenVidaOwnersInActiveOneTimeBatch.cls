public class TourGenVidaOwnersInActiveOneTimeBatch implements Database.Batchable<sObject>{
    public List<Id> targetIds = new List<Id>();
    public TourGenVidaOwnersInActiveOneTimeBatch(){
        targetIds = GetAssignedTargetDetails.getSingleCadenceNamewithTargetList('TourGen-Vida Owners-Inactive');
    }
    public Database.QueryLocator start(Database.BatchableContext bc) {
        Date enrollmentStartdate=Date.newInstance(2023, 1, 1); 
        Date enrollmentEnddate=Date.newInstance(2024, 12, 31);
        List<String> membershipStatus = new List<String>{'Inactive', 'FrozenByHSI'};
            set<String> languagePrefered = new set<String>{'SPA'};
                List<Decimal> HCAffiliates = new List<Decimal>{1002243,1002311,1002312,1002310};//HC Affilates 
                    String query='';
        if(test.isRunningTest()){
            query = 'SELECT Id,AccountId,name,Match_Group_Name__c,Cadence_Flag__c,Assign_to_Sales_Cadence_Name__c,leadassist__Use_Round_Robin__c,ActionCadenceId FROM Contact' ;//Id IN :oppIds and
        }
        else{
            query = 'Select id,name,Cadence_Flag__c,leadassist__Use_Round_Robin__c,Assign_to_Sales_Cadence__c,Match_Group_Name__c from contact where Account.Enrollment_Date__c >=: enrollmentStartDate and Account.Enrollment_Date__c <=: enrollmentEndDate and Account.Preferred_Language__c NOT IN :languagePrefered AND ID NOT IN : targetIds and Marketing_Email_opt_out__c = false and Account.Membership_Status__c IN :membershipstatus AND Account.Affiliated_Id__c IN: HCAffiliates AND Parent_Id_Ext_Db__c = null AND Master_Record_Id__c!=null';
        }
        system.debug('Query'+query);
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext bc, List<Contact> scope) {
        Set<ID> cadenceContactsId=new set<Id>();
        list<contact> updateContacts=new list<contact>();
        for(Contact con: scope){
            con.Assign_to_Sales_Cadence__c=true;
            con.leadassist__Use_Round_Robin__c='TRUE';
            con.Cadence_Flag__c=1;
            con.Match_Group_Name__c = 'TourGen-Vida Owners-Inactive';
            updateContacts.add(con);
            cadenceContactsId.add(con.Id);
            
        }
        if(updateContacts.size()>0){
            updateContacts =  GenericMatchGroupAssignmentHandler.assignMatchGroup(updateContacts, 'TourGen-Vida Owners-Inactive');
            update updateContacts;
        }
        System.enqueueJob(new GenericAssignToSalesCadence(cadenceContactsId, 'TourGen-Vida Owners-Inactive'));
    }
    public void finish(Database.BatchableContext bc) {
        //do something 
    }  
}