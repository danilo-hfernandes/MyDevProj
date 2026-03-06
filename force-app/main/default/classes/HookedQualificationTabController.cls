public class HookedQualificationTabController {
    @AuraEnabled(cacheable=true)
    public static String getRecordTypeName(Id recordId) {
        Opportunity opp = [SELECT RecordType.Name FROM Opportunity WHERE Id = :recordId];
        return opp.RecordType.Name;
    }
}