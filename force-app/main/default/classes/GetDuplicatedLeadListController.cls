public with sharing class GetDuplicatedLeadListController {

    @AuraEnabled
    public static Map<String, List<Lead>> GetLeads(String leadId) {

        Map<String, List<Lead>> returnMap = new Map<String, List<Lead>>();
        List<Lead> duplicateLeads = new List<Lead>();
        String message = 'We found no potential duplicated leads.';

        try {
            if (String.isBlank(leadId)) {
                returnMap.put(message, duplicateLeads);
                return returnMap;
            }

            // Load current Lead
            Lead currentLead = [
                SELECT Id,
                       Email,
                       Phone,
                       Formatted_Phone_Number__c,
                       RecordType.Name
                FROM Lead
                WHERE Id = :leadId
                LIMIT 1
            ];

            // Apply logic only for Social Ad Sales
            if (currentLead.RecordType.Name != 'Ad Sales') {
                returnMap.put(message, duplicateLeads);
                return returnMap;
            }

            List<String> emails = new List<String>();
            List<String> phones = new List<String>();

            if (!String.isBlank(currentLead.Email)) {
                emails.add(currentLead.Email);
            }

            if (!String.isBlank(currentLead.Formatted_Phone_Number__c)) {
                phones.add(currentLead.Formatted_Phone_Number__c);
            }

            // If nothing to match, exit
            if (emails.isEmpty() && phones.isEmpty()) {
                returnMap.put(message, duplicateLeads);
                return returnMap;
            }

            // Find duplicates created in the last 15 days
            duplicateLeads = [
                SELECT Id,
                       Name,
                       Email,
                       Phone,
                       Formatted_Phone_Number__c,
                       LeadSource,
                       CreatedDate,
                       Owner.Name
                FROM Lead
                WHERE Id != :currentLead.Id
                AND CreatedDate = LAST_N_DAYS:15
                AND (
                        Email IN :emails
                        OR Formatted_Phone_Number__c IN :phones
                    )
                AND RecordType.Name = 'Ad Sales'
                ORDER BY CreatedDate DESC
                LIMIT 200
            ];

        } catch (Exception e) {
            message = e.getMessage();
        }

        returnMap.put(message, duplicateLeads);
        return returnMap;
    }
}