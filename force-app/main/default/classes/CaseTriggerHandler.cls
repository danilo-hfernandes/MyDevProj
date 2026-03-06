public class CaseTriggerHandler {
    public static void createTravelOpportunity(list<case> caselist){
        List<Opportunity> listOpportunity = new List<Opportunity>();
        List<Opportunity> updateListOpportunity = new List<Opportunity>();
        Set<Id> setCaseId = new set<Id>();
        for(Case objcase : caselist){
            Opportunity opp = new Opportunity();
            opp.Name = 'Travel Opportunity';
            opp.StageName = 'New';
            opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Travel').getRecordTypeId();
            //opp.Match_Group_Name__c = 'Travel Sales-Halo Resort Requests';
            //opp.leadassist__Use_Round_Robin__c = 'TRUE';
            opp.CloseDate = System.Today();
            opp.AccountId = objcase.AccountId;
            opp.Guest_Name__c = objcase.First_Name__c+' '+objcase.Last_Name__c;
            opp.Traveler_Phone__c = objcase.Phone__c != null ? objcase.Phone__c: objcase.SuppliedPhone;
            opp.Traveler_Email__c = objcase.SuppliedEmail;
            opp.Description = '-Resort: '+objcase.Resort_Name__c+'\n-Check in Date: '+objcase.Check_in_Date__c+'\n-Guests: '+objcase.Number_of_Guests__c+'\n-Comments: '+objcase.Description;
            listOpportunity.add(opp);
            setCaseId.add(objcase.Id);
        }
        if(listOpportunity != null && listOpportunity.size() > 0){
            insert listOpportunity;
            for(Opportunity opp : listOpportunity){
                opp.Match_Group_Name__c = 'Travel Sales-Halo Resort Requests';
           		opp.leadassist__Use_Round_Robin__c = 'TRUE';
                updateListOpportunity.add(opp);
            }
        }
        if(updateListOpportunity != null && updateListOpportunity.size() > 0){
//            updateListOpportunity =  GenericMatchGroupAssignmentHandler.assignMatchGroup(updateListOpportunity, 'Assigned');
            update updateListOpportunity;
        }
        //Delete Case
        if(setCaseId != null && setCaseId.size() > 0){
            List<Case> listCase = [select id from Case where Id IN: setCaseId];
            delete listCase;
        }
        
    }
}