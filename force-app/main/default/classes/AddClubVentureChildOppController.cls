public class AddClubVentureChildOppController {
    
    @AuraEnabled 
    public static Map<String,String> tryToAddChildOpp(String recordId){
        Id cvRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Club_Venture_Membership').getRecordTypeId();
        String returnSuccess = 'true';        
        String returnResults = '';
        Map<String,String> results = new Map<String,String>();
        try
        {
            List<Tour_appointment__c> tas = [SELECT Id,Closing_Agents__c FROM Tour_appointment__c WHERE Opportunity__r.Id =: recordId AND Closing_Agents__c != NULL ORDER BY CreatedDate DESC LIMIT 1];
            if (tas.isEmpty()) {
                results.put(
                    'false', 
                    'No tour appointment with a closing agent was found for this opportunity.'
                );
                return results;    
            }
            
            Tour_appointment__c ta = tas[0];
            
            List<Opportunity> parentOpps = [SELECT Id,AccountId,RecordTypeId,Account.Name FROM Opportunity WHERE Id =: recordId AND RecordTypeId =: cvRecordTypeId];            
            Opportunity parentOpp = parentOpps[0];
            
            Opportunity opp = new Opportunity();
            opp.First_Agent__c = ta.Closing_Agents__c;
            opp.AccountId = parentOpp.AccountId;
            opp.Name = 'Club Venture Membership';
            opp.RecordTypeId = parentOpp.RecordTypeId;
            opp.StageName = 'New';
            opp.CloseDate = system.Today();
            opp.Parent_Opportunity__c = parentOpp.Id;
            opp.ParentOpportunity__c = parentOpp.Id;
            opp.Vidanta_Voucher_Email_Sent__c = true;
            opp.Voucher_18_Months_Email_Sent__c = true;
            opp.Vidanta_SFX_Voucher_Email_Sent__c = true;
            insert opp;
			returnSuccess = 'true';
            returnResults = opp.Id;
        }
        Catch(Exception e)
        {
            returnSuccess = 'false';
            returnResults = e.getMessage();
        }
        results.put(returnSuccess,returnResults);
        return results;
    }

}