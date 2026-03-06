public with sharing class FlowSOQLChecker {
    @InvocableMethod(label='Get SOQL Query Count' description='Returns the current number of SOQL queries executed in this transaction.')
    public static List<Integer> getSOQLQueryCount(List<String> input) {
        Integer queryCount = Limits.getQueries(); 
        System.debug('Current SOQL Query Count: ' + queryCount);
        return new List<Integer>{ queryCount };
    }
}