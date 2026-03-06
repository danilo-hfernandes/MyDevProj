public  class UpdateTimeZoneBasedOnAreaCodeController {
    public static void updateAccountTimeZone(List<Account> lstAccount , map<Id, Account> oldMapAccount){
        set<Id> SObjectId = new set<Id>();
        SObjectId = genericUpdateTimeZone(lstAccount,oldMapAccount, 'Account', null);
    }
    public static void updateLeadTimeZone(List<Lead> lstLead , map<Id, Lead> oldMapLead){
        set<Id> SObjectId = new set<Id>();
        SObjectId = genericUpdateTimeZone(lstLead, oldMapLead, 'Lead', null);
    }
    public static set<Id> genericUpdateTimeZone(List<SObject> SObjectlst , map<Id, SObject> sObjectOldMap, String ObjectName, set<Id> setIds){
        map<Id, String> mapSObjectIdvsAreaCode = new map<Id, String>();
        map<String, String> mapAreaCodeToTimezone = new map<String, String>();
        list<SObject> listSObjectUpdate = new List<SObject>();
        set<Id> SObjectId = new set<Id>();
        for(SObject objSObject : SObjectlst){
            if((sObjectOldMap == null &&  ((String)objSObject.get('Phone')) != null )|| (sObjectOldMap != null && ((String)objSObject.get('Phone')) != ((String)sObjectOldMap.get((Id)objSObject.get('Id')).get('Phone')) && ((String)objSObject.get('Phone')) != null)){
                String areaCode = '';
                //check if the area code in rapped in cicle bracket
                if(((String)objSObject.get('Phone')).contains('(') && ((String)objSObject.get('Phone')).contains(')')){
                    areaCode = ((String)objSObject.get('Phone')).substringBetween('(', ')'); 
                }
                //check if the area code is the starting 3 digits separated by '-'
                else if(((String)objSObject.get('Phone')).contains('-')){
                    areaCode = ((String)objSObject.get('Phone')).substringBefore('-');
                }
                //check if the phone number doesn't contain '()' and '-'
                else if(((String)objSObject.get('Phone')).length() >= 3){
                    areaCode = ((String)objSObject.get('Phone')).substring(0, 3);
                }
                if(areaCode.length() == 3){
                    system.debug('>>>Area Code >>>>'+areaCode);
                    mapSObjectIdvsAreaCode.put(objSObject.Id, 'X'+areaCode);
                }    
            }
        }
        system.debug('>>>>mapSObjectIdvsAreaCode>>>>'+mapSObjectIdvsAreaCode);
        if(mapSObjectIdvsAreaCode != null && mapSObjectIdvsAreaCode.size() > 0){
            List<Timezone__mdt>  listTimeZone = [select id, DeveloperName, Timezone__c from Timezone__mdt where DeveloperName IN: mapSObjectIdvsAreaCode.values()];
            if(listTimeZone.size() > 0){
                for(Timezone__mdt objtimezone : listTimeZone){
                    mapAreaCodeToTimezone.put(objtimezone.DeveloperName, objtimezone.Timezone__c);
                }
            } 
            system.debug('>>>>>mapAreaCodeToTimezone>>>>'+mapAreaCodeToTimezone);
            
            
            for(Id objSObject : mapSObjectIdvsAreaCode.keyset()){
                String areaCode = mapSObjectIdvsAreaCode.get(objSObject);
                
                if(mapAreaCodeToTimezone.containsKey(areaCode) && mapAreaCodeToTimezone.get(areaCode) != null  && ((setIds != null && !setIds.contains(objSObject) ) || (setIds == null ))){
                    sObject objSObjectUpdate = Schema.getGlobalDescribe().get(ObjectName).newSObject() ;
                    SObjectId.add(objSObject);
                    objSObjectUpdate.put('Id',objSObject);
                    objSObjectUpdate.put('Timezone__c', mapAreaCodeToTimezone.get(areaCode));  
                    listSObjectUpdate.add(objSObjectUpdate);
                }
            }
        }
        if(listSObjectUpdate.size() > 0){
            update listSObjectUpdate;
        }
        return SObjectId;
    }
}