global class OpportunityTimeshareUpdaterBatch implements Database.Batchable<SObject>, Database.Stateful {
    
    global Database.QueryLocator start(Database.BatchableContext bc) {


        String query = '';
        
        If (!Test.isRunningTest()) {
            
	            query = 'SELECT Id, CreatedDate, StageName, Count_HC_Vida_Coll_Weeks_Usage_Fee_TC_Re__c, Timeshare_1__c, Timeshare_2__c, Timeshare_3__c, Timeshare_4__c, Timeshare_5__c, Timeshare_6__c, Timeshare_7__c, Timeshare_8__c, Timeshare_9__c, Timeshare_10__c ';
	            query = query + 'FROM Opportunity ';
	            query = query + 'WHERE (Timeshare_1__c != null OR Timeshare_2__c != null OR Timeshare_3__c != null OR Timeshare_4__c != null OR Timeshare_5__c != null OR Timeshare_6__c != null OR Timeshare_7__c != null OR Timeshare_8__c != null OR Timeshare_9__c != null OR ';
	            query = query + 'Timeshare_10__c != null) ORDER BY CreatedDate DESC';
                    
        } Else  { //test
                    
				query = 'SELECT Id, CreatedDate, StageName, Count_HC_Vida_Coll_Weeks_Usage_Fee_TC_Re__c, ';
				query = query + 'Timeshare_1__c, Timeshare_2__c, Timeshare_3__c, Timeshare_4__c, Timeshare_5__c, ';
				query = query + 'Timeshare_6__c, Timeshare_7__c, Timeshare_8__c, Timeshare_9__c, Timeshare_10__c ';
				query = query + 'FROM Opportunity ';
		   	    query = query + 'WHERE (Timeshare_1__c != null OR Timeshare_2__c != null OR Timeshare_3__c != null OR ';
		   	    query = query + 'Timeshare_4__c != null OR Timeshare_5__c != null OR Timeshare_6__c != null OR ';
		   	    query = query + 'Timeshare_7__c != null OR Timeshare_8__c != null OR Timeshare_9__c != null OR ';
		   	    query = query + 'Timeshare_10__c != null) ';
		   	    query = query + 'AND Name = \'Test Opp BatchTest\' ';
		        query = query + 'ORDER BY CreatedDate DESC';
            
            }
        
        return Database.getQueryLocator(query);
    }
 
    global void execute(Database.BatchableContext bc, List<SObject> scope) {
        List<Opportunity> oppsToUpdate = new List<Opportunity>();
        Set<Id> oppIds = new Set<Id>();

        for (Opportunity opp : (List<Opportunity>)scope) {
            oppIds.add(opp.Id);
        }

        // Query all related OpportunityLineItems and map by OpportunityId
        Map<Id, List<OpportunityLineItem>> oliMap = new Map<Id, List<OpportunityLineItem>>();
        for (OpportunityLineItem oli : [
            SELECT Id, OpportunityId, Timeshare__c, Product2.Name
            FROM OpportunityLineItem
            WHERE OpportunityId IN :oppIds
        ]) {
            if (!oliMap.containsKey(oli.OpportunityId)) {
                oliMap.put(oli.OpportunityId, new List<OpportunityLineItem>());
            }
            oliMap.get(oli.OpportunityId).add(oli);
        }

        // Loop over Opportunities and match Timeshare fields
        for (Opportunity opp : (List<Opportunity>)scope) {
            List<OpportunityLineItem> olis = oliMap.get(opp.Id);
            if (olis == null) continue;

            Map<String, Id> timeshareToIdMap = new Map<String, Id>();
           
            Integer hcWeeksCount = 0;  
            
            for (OpportunityLineItem oli : olis) {
                if (oli.Timeshare__c != null) {
                    timeshareToIdMap.put(oli.Timeshare__c, oli.Id);
                }
                if (oli.Product2 != null && oli.Product2.Name == 'HC Collection Weeks') {
                    hcWeeksCount++;
                }
            }

            // Match each timeshare field and set corresponding OppProd ID
            if (opp.Timeshare_1__c != null && timeshareToIdMap.containsKey(opp.Timeshare_1__c))
                opp.Timeshare_1_OppProd_Id__c = timeshareToIdMap.get(opp.Timeshare_1__c);

            if (opp.Timeshare_2__c != null && timeshareToIdMap.containsKey(opp.Timeshare_2__c))
                opp.Timeshare_2_OppProd_Id__c = timeshareToIdMap.get(opp.Timeshare_2__c);

            if (opp.Timeshare_3__c != null && timeshareToIdMap.containsKey(opp.Timeshare_3__c))
                opp.Timeshare_3_OppProd_Id__c = timeshareToIdMap.get(opp.Timeshare_3__c);

            if (opp.Timeshare_4__c != null && timeshareToIdMap.containsKey(opp.Timeshare_4__c))
                opp.Timeshare_4_OppProd_Id__c = timeshareToIdMap.get(opp.Timeshare_4__c);

            if (opp.Timeshare_5__c != null && timeshareToIdMap.containsKey(opp.Timeshare_5__c))
                opp.Timeshare_5_OppProd_Id__c = timeshareToIdMap.get(opp.Timeshare_5__c);

            if (opp.Timeshare_6__c != null && timeshareToIdMap.containsKey(opp.Timeshare_6__c))
                opp.Timeshare_6_OppProd_Id__c = timeshareToIdMap.get(opp.Timeshare_6__c);

            if (opp.Timeshare_7__c != null && timeshareToIdMap.containsKey(opp.Timeshare_7__c))
                opp.Timeshare_7_OppProd_Id__c = timeshareToIdMap.get(opp.Timeshare_7__c);

            if (opp.Timeshare_8__c != null && timeshareToIdMap.containsKey(opp.Timeshare_8__c))
                opp.Timeshare_8_OppProd_Id__c = timeshareToIdMap.get(opp.Timeshare_8__c);

            if (opp.Timeshare_9__c != null && timeshareToIdMap.containsKey(opp.Timeshare_9__c))
                opp.Timeshare_9_OppProd_Id__c = timeshareToIdMap.get(opp.Timeshare_9__c);

            if (opp.Timeshare_10__c != null && timeshareToIdMap.containsKey(opp.Timeshare_10__c))
                opp.Timeshare_10_OppProd_Id__c = timeshareToIdMap.get(opp.Timeshare_10__c);
            
            if (hcWeeksCount > 0 && opp.StageName == 'Closed Won') {
                if (opp.Count_HC_Vida_Coll_Weeks_Usage_Fee_TC_Re__c == null) {
                    opp.Count_HC_Vida_Coll_Weeks_Usage_Fee_TC_Re__c = 0;
                }
                opp.Count_HC_Vida_Coll_Weeks_Usage_Fee_TC_Re__c = (hcWeeksCount * 2);
            }
            
             oppsToUpdate.add(opp);
        }

        if (!oppsToUpdate.isEmpty()) {
            update oppsToUpdate;
        }
    }

    global void finish(Database.BatchableContext bc) {
        // Optional: send email or log results
    }
}