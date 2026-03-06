public class GenericMatchGroupAssignmentHandler{
    public static List<SObject> assignMatchGroup(List<SObject> SObjectList, String matchGroupName){
        Apex_Trigger_On_Off__c srrLogic = Apex_Trigger_On_Off__c.getValues('SRR Logic');
        try{
            if(srrLogic != null && srrLogic.isEnable__c){
                List<SObject> listSObject = new List<SObject>();
                for(SObject obj : SObjectList){
                    obj.put('leadassist__Use_Round_Robin__c','True');
                    if(matchGroupName != 'Assigned' && matchGroupName != null){
                        obj.put('Match_Group_Name__c', matchGroupName);
                    }
                    listSObject.add(obj);
                }
                system.debug('>>>>listSObject>>>'+listSObject);
                return listSObject;
            }
            return SObjectList;
        }
        catch(System.Exception ex) {
            System.debug('ERROR: '+ ex);
            Error_Handler__c err = new Error_Handler__c();
            err.Name = 'Apex Class : GenericMatchGroupAssignmentHandler';
            err.Error_Message__c = 'Method : assignMatchGroup(List) -> Message:' + ex.getMessage()  + ' - Exception occurrred on LineNumber: ' + ex.getLineNumber();
            insert err;
        }
        return SObjectList;
    }
    public static List<SObject> assignMatchGroup(SObject SObjectInstance, String matchGroupName){
        Apex_Trigger_On_Off__c srrLogic = Apex_Trigger_On_Off__c.getValues('SRR Logic');
        try{
            List<SObject> listSObject = new List<SObject>();
            if(srrLogic != null && srrLogic.isEnable__c){
                SObjectInstance.put('leadassist__Use_Round_Robin__c','True');
                SObjectInstance.put('Match_Group_Name__c', matchGroupName);
            }
            listSObject.add(SObjectInstance);
            system.debug('>>>>listSObject>>>'+listSObject);
            return listSObject;
        }
        catch(System.Exception ex) {
            System.debug('ERROR: '+ ex);
            Error_Handler__c err = new Error_Handler__c();
            err.Name = 'Apex Class : GenericMatchGroupAssignmentHandler';
            err.Error_Message__c = 'Method : assignMatchGroup(Instance) -> Message:' + ex.getMessage()  + ' - Exception occurrred on LineNumber: ' + ex.getLineNumber();
            insert err;
        }
        return null;
    }
    public static set<String> fetchMatchGroupDetails(String matchGroupName){
        Apex_Trigger_On_Off__c srrLogic = Apex_Trigger_On_Off__c.getValues('SRR Logic');
        try{
            if(srrLogic != null && srrLogic.isEnable__c){
                String matchGroupId ; 
                list<leadassist__Assignee__c> srrUserList= new list<leadassist__Assignee__c>();
                set<String> srrUserIds = new set<String>();
                if(!test.isRunningTest()){
                    matchGroupId = [SELECT Name, Id FROM leadassist__MatchGroup__c where name= : matchGroupName limit 1].id;
                    srrUserList =[SELECT Id, leadassist__MatchGroup__c,leadassist__User__c  FROM leadassist__Assignee__c where leadassist__MatchGroup__c=:matchGroupId AND leadassist__Active__c=true];
                    for(leadassist__Assignee__c objassigned : srrUserList){
                        srrUserIds.add(objassigned.leadassist__User__c);
                    }
                }
                return srrUserIds;
            }
            return null;
        }
        catch(System.Exception ex) {
            System.debug('ERROR: '+ ex);
            Error_Handler__c err = new Error_Handler__c();
            err.Name = 'Apex Class : GenericMatchGroupAssignmentHandler';
            err.Error_Message__c = 'Method : fetchMatchGroupDetails -> Message:' + ex.getMessage()  + ' - Exception occurrred on LineNumber: ' + ex.getLineNumber();
            insert err;
        }
        return null;
        
    }
    public static List<SObject> removeMatchGroup(List<SObject> SObjectList){
        Apex_Trigger_On_Off__c srrLogic = Apex_Trigger_On_Off__c.getValues('SRR Logic');
        try{
            if(srrLogic != null && srrLogic.isEnable__c){
                List<SObject> listSObject = new List<SObject>();
                for(SObject obj : SObjectList){
                    obj.put('leadassist__Use_Round_Robin__c','False');
                    listSObject.add(obj);
                }
                system.debug('>>>>listSObject>>>'+listSObject);
                return listSObject;
            }
            return SObjectList;
        }
        catch(System.Exception ex) {
            System.debug('ERROR: '+ ex);
            Error_Handler__c err = new Error_Handler__c();
            err.Name = 'Apex Class : GenericMatchGroupAssignmentHandler';
            err.Error_Message__c = 'Method : removeMatchGroup -> Message:' + ex.getMessage()  + ' - Exception occurrred on LineNumber: ' + ex.getLineNumber();
            insert err;
        }
        return null;
    }
    public static String addWhereClause(String useRoundRobin, String operator){
        Apex_Trigger_On_Off__c srrLogic = Apex_Trigger_On_Off__c.getValues('SRR Logic');
        try{
            String whereClause='';
            if(srrLogic != null && srrLogic.isEnable__c){
                if(operator == 'equals')
                	whereClause = 'leadassist__Use_Round_Robin__c=\''+useRoundRobin+'\'';
                else if(operator == 'notEquals')
                	whereClause = 'leadassist__Use_Round_Robin__c !=\''+useRoundRobin+'\'';
            }
            return whereClause;
        }
        catch(System.Exception ex) {
            System.debug('ERROR: '+ ex);
            Error_Handler__c err = new Error_Handler__c();
            err.Name = 'Apex Class : GenericMatchGroupAssignmentHandler';
            err.Error_Message__c = 'Method : addWhereClause -> Message:' + ex.getMessage()  + ' - Exception occurrred on LineNumber: ' + ex.getLineNumber();
            insert err;
        }
        return null;
    }
}