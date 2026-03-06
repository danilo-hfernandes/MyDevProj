global class CreateCaseOBCampaign implements Database.Batchable<sObject>
{
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        Id voucherRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Voucher').getRecordTypeId();
        Id referralDateRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('VI_Referral_Date_Request').getRecordTypeId();
        String twoWeeksPriorDateString = string.valueOf(System.today().addDays(-14)).removeEnd(' 00:00:00');
		
        String query = 'SELECT Id, Name,Account.Name,Account.Member_Number__c,AccountId,OB_Campaign_Case_Credated__c,Coast_Formula__c,StageName, Total_Amount_Paid__c FROM Opportunity where CloseDate != NULL AND CloseDate <= '+twoWeeksPriorDateString+' AND Reservation_Status__c = NULL AND OB_Campaign_Case_Credated__c = FALSE and (StageName = \'Closed Won\' OR StageName = \'Closed Won-Deposit\' OR StageName = \'Closed Booked\') and (RecordTypeId =\''+String.escapeSingleQuotes(voucherRecordTypeId)+'\' OR RecordTypeId =\''+String.escapeSingleQuotes(referralDateRecordTypeId)+'\')';
        system.debug('qry- ' + query);
        return Database.getQueryLocator(query);
    }
 
    global void execute(Database.BatchableContext BC, List<Opportunity> scope)
    {
        String activationPaidQueueId = [select Id from Group where Type = 'Queue' AND DeveloperNAME = 'Activations_Paid'].Id;
        String activationUnPaidQueueId = [select Id from Group where Type = 'Queue' AND DeveloperNAME = 'Activations_Unpaid'].Id;
        
        system.debug('qry= '  + scope);
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Activation').getRecordTypeId();
        List<Case> InsertCaseList = New List<Case>();
        List<Contact> contactRecord = New List<Contact>();
        List<Opportunity> OppUpdate = New List<Opportunity>();
        Map<Id,Id> AccountIdtoContactId = New Map<Id,Id>();
        Set<id> AccountIds = New Set<id>();
        for(Opportunity opps : scope){
            AccountIds.add(opps.Accountid);
        }
        contactRecord = [Select Id,Name,AccountId from Contact where AccountId IN:AccountIds];
        for(Contact ct : contactRecord){
            AccountIdtoContactId.put(ct.AccountId, ct.id);
        }
        for(Opportunity Opp : scope){
            
            if((Opp.StageName == 'Closed Won' || Opp.StageName == 'Closed Won-Deposit' || Opp.StageName == 'Closed Booked'))
            {
                Case createcase = New Case();
                createcase.AccountId = Opp.AccountId;
                createcase.RecordTypeId = recordTypeId;
                createcase.Priority = 'Medium';
                createcase.Member_Number__c = Opp.Account.Member_Number__c;
                createcase.Origin = 'Web';
                createcase.ContactId = AccountIdtoContactId.get(Opp.AccountId);
                /*if(Opp.Coast_Formula__c == 'West Coast'){
                    createcase.OwnerId = Label.Voucher_Sales_West_Queue_Id;
                }else{
                    createcase.OwnerId = Label.Voucher_Sales_East_Queue_Id;
                }*/
                if(Opp.Total_Amount_Paid__c > 0){
                    createcase.OwnerId = activationPaidQueueId;
                }else{
                    createcase.OwnerId = activationUnPaidQueueId;
                }
                createcase.Status = 'New';
                createcase.Subject = 'Voucher Activation - ' + opp.Account.Name;
                createcase.Opportunity_Link__c = Label.BaseUrl + Opp.Id;
                InsertCaseList.add(createcase);
                Opp.OB_Campaign_Case_Credated__c = True;
                OppUpdate.add(Opp);
                
            }
            
        }
        if(InsertCaseList.size() > 0 && InsertCaseList != Null){
            try{
                insert InsertCaseList;
                update OppUpdate;
            }catch(Exception e){
                system.debug('Exception=' + e);
            }
            
        }
        
    }  
    global void finish(Database.BatchableContext BC)
    {
    }
}