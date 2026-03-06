public with sharing class GetEnhancedSmsCutoffDate {

    public class Output {
        @InvocableVariable(label='Cutoff Date')
        public Date cutoffDate;
    }

    @InvocableMethod(label='Get Enhanced SMS Cutoff Date')
    public static List<Output> getCutoffDate(List<String> requests) {
        
        List<Output> results = new List<Output>();
        Output out = new Output();

        // Get the first record from the List Custom Setting
        Enhanced_SMS_Cutoff_Date__c settingRecord = 
            Enhanced_SMS_Cutoff_Date__c.getAll().values().isEmpty()
            ? null
            : Enhanced_SMS_Cutoff_Date__c.getAll().values()[0];

        if (settingRecord != null) {
            out.cutoffDate = settingRecord.Cutoff_Date__c;
        }

        results.add(out);
        return results;
    }
}