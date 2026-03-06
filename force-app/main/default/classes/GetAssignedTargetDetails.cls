public class GetAssignedTargetDetails {
    public static map<String,List<Id>> getMultipleCadenceNamewithTargetList(List<String> listOfSalesCadenceNames, set<Id> targetIds){
        List<ActionCadenceTracker> cadenceTrackersList = [SELECT TargetId,ActionCadence.Name FROM ActionCadenceTracker WHERE State = 'running' AND ActionCadence.Name IN :listOfSalesCadenceNames and targetId IN: targetIds];
        system.debug('cadenceTrackersList=='+cadenceTrackersList);
        system.debug('listOfSalesCadenceNames=='+listOfSalesCadenceNames);
        system.debug('targetIds=='+targetIds);
        map<String,List<Id>> mapCadenceNameVstargetIds = new map<String,List<Id>>();
        for (ActionCadenceTracker objTracker : cadenceTrackersList) {
            if (mapCadenceNameVstargetIds.containsKey(objTracker.ActionCadence.Name)){
                mapCadenceNameVstargetIds.get(objTracker.ActionCadence.Name).add(objTracker.TargetId);
            }
            else{
                mapCadenceNameVstargetIds.put(objTracker.ActionCadence.Name , new List<Id>{objTracker.TargetId});
            }
        }
        return mapCadenceNameVstargetIds;
    }
    
    public static List<Id> getSingleCadenceNamewithTargetList(String salesCadenceNames){
        List<ActionCadenceTracker> cadenceTrackersList = [SELECT TargetId,ActionCadence.Name FROM ActionCadenceTracker WHERE State = 'running' AND ActionCadence.Name =: salesCadenceNames];
        List<Id> listTargetIds = new List<Id>();
        for (ActionCadenceTracker objTracker : cadenceTrackersList) {
            listTargetIds.add(objTracker.TargetId);
        }
        return listTargetIds;
    }
    
    public static List<Id> getChainTargetList(List<String> listOfSalesCadenceNames){
        List<ActionCadenceTracker> cadenceTrackersList = [SELECT TargetId,ActionCadence.Name FROM ActionCadenceTracker WHERE State = 'running' AND ActionCadence.Name in :listOfSalesCadenceNames];
        Set<Id> setTargetIds = new Set<Id>();
        for (ActionCadenceTracker objTracker : cadenceTrackersList) {
            setTargetIds.add(objTracker.TargetId);
        }
        // Convert the Set to a List
        List<Id> myIdList = new List<Id>(setTargetIds);
        return myIdList;
        
    }
    
    
    
      // Helper method to retrieve all chained cadences recursively //public //TGR-413
    public static Set<String> getAllChainedCadences(Set<String> cadenceNames) {  
        // Collect all cadences
        Set<String> allCadences = new Set<String>();
        allCadences.addAll(cadenceNames);
 		//allCadences.add(cadenceNames);
 
        // Query ActionCadenceStep to find all chained cadences //ActionCadence.Name, // group by ChainedCadence.Name //WHERE ActionCadence.Name IN :cadenceNames AND ChainedCadenceId != null
        List<ActionCadenceStep> chainedCadenceSteps = [
            SELECT  ChainedCadence.Name
            FROM ActionCadenceStep
            WHERE ActionCadence.Name IN :cadenceNames AND ChainedCadenceId != null
        ];

        // Collect the next level of cadences
        Set<String> nextCadenceNames = new Set<String>();
        for (ActionCadenceStep step : chainedCadenceSteps) {
            if (step.ChainedCadence != null) {
                nextCadenceNames.add(step.ChainedCadence.Name);
            }
        }

        // If new cadences are found, continue the recursion
        if (!nextCadenceNames.isEmpty()) {
            allCadences.addAll(getAllChainedCadences(nextCadenceNames));
        }

        return allCadences;
    }
    
    
}