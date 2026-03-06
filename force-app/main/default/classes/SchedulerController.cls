public with sharing class SchedulerController {
    @AuraEnabled
    public static void createScheduler(String objectName, List<String> fields, String scheduleTime, String mainObjectFilters, String parentObjectFilters) {
        // Construct SELECT clause
        String query = 'SELECT ' + String.join(fields, ',') + ' FROM ' + objectName;
        
        // Build WHERE clause from filters
        String whereClause = '';

        if (String.isNotBlank(mainObjectFilters)) {
            List<Map<String, String>> mainFilters = (List<Map<String, String>>) JSON.deserializeUntyped(mainObjectFilters);
            whereClause += buildFilterClause(mainFilters, false);
        }

        if (String.isNotBlank(parentObjectFilters)) {
            List<Map<String, String>> parentFilters = (List<Map<String, String>>) JSON.deserializeUntyped(parentObjectFilters);
            if (!String.isBlank(whereClause)) whereClause += ' AND ';
            whereClause += buildFilterClause(parentFilters, true);
        }

        if (!String.isBlank(whereClause)) {
            query += ' WHERE ' + whereClause;
        }

        // Schedule class
        System.schedule('Dynamic_Scheduler', scheduleTime, new DynamicScheduler(query));
    }

    private static String buildFilterClause(List<Map<String, String>> filters, Boolean isParent) {
        List<String> filterClauses = new List<String>();
        for (Map<String, String> filter : filters) {
            String field = filter.get('field');
            String condition = filter.get('condition');
            String value = filter.get('value');
            String clause = (isParent ? 'ParentObject__r.' : '') + field + ' ' + condition + ' ' + value;
            filterClauses.add(clause);
        }
        return String.join(filterClauses, ' AND ');
    }
}