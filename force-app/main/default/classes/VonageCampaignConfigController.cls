public with sharing class VonageCampaignConfigController {

    /* ===================== DTOs ===================== */

    public class OptionDTO {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        @AuraEnabled public String developerName;

        public OptionDTO(String lbl, String val) {
            label = lbl;
            value = val;
        }

        public OptionDTO(String lbl, String val, String dev) {
            label = lbl;
            value = val;
            developerName = dev;
        }
    }

    public class FieldOptionDTO {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        @AuraEnabled public String dataType;
        @AuraEnabled public List<OptionDTO> picklistValues;
        @AuraEnabled public List<String> referenceTo; // optional: helps record-picker / ref UI

        public FieldOptionDTO(String lbl, String api, String dt) {
            label = lbl;
            value = api;
            dataType = dt;
            picklistValues = new List<OptionDTO>();
            referenceTo = new List<String>();
        }
    }

    public class ChildObjectDTO {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        @AuraEnabled public String parentFieldOnChild;

        public ChildObjectDTO(String lbl, String val, String parentField) {
            label = lbl;
            value = val;
            parentFieldOnChild = parentField;
        }
    }

    /* ===================== CONSTANTS ===================== */

    private static final Set<String> ALLOWED_PARENT_SOBJECTS = new Set<String>{ 'Lead', 'Contact', 'Account', 'Opportunity', 'Case' };

    private static final Set<String> ALLOWED_RELATIONSHIP_CONDITIONS = new Set<String>{ 'HAVING', 'NOT_HAVING' };

    /* ===================== READ ===================== */

    @AuraEnabled(cacheable=true)
    public static List<Vonage_Campaigns_Configuration__c> getConfigurations() {
        return [
            SELECT Id, Name, CreatedDate,
                   Active__c,
                   Configuration_Type__c,
                   Campaign_Name__c,
                   Campaign__c,
                   Run_Frequency__c,
                   Scheduled_Job_Query__c,
                   Last_Run__c,
                   Trigger_Condition__c
            FROM Vonage_Campaigns_Configuration__c
            ORDER BY CreatedDate DESC
        ];
    }

    @AuraEnabled(cacheable=true)
    public static List<OptionDTO> getCampaignOptions() {
        List<OptionDTO> out = new List<OptionDTO>();
        for (Campaign c : [SELECT Id, Name FROM Campaign WHERE IsActive = true ORDER BY Name]) {
            out.add(new OptionDTO(c.Name, c.Id));
        }
        return out;
    }

    @AuraEnabled(cacheable=true)
    public static List<FieldOptionDTO> getTriggerFieldOptions(String sObjectApiName) {
        if (String.isBlank(sObjectApiName) || !ALLOWED_PARENT_SOBJECTS.contains(sObjectApiName)) {
            throw new AuraHandledException('Only Lead, Contact, and Account are supported.');
        }

        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        if (!gd.containsKey(sObjectApiName)) {
            throw new AuraHandledException('Invalid object: ' + sObjectApiName);
        }

        Map<String, Schema.SObjectField> fMap =
            gd.get(sObjectApiName).getDescribe().fields.getMap();

        List<FieldOptionDTO> out = new List<FieldOptionDTO>();

        for (Schema.SObjectField f : fMap.values()) {
            Schema.DescribeFieldResult d = f.getDescribe();
            if (!d.isAccessible()) continue;

            // skip problematic/unwanted types
            if (d.getType() == Schema.DisplayType.Location ||
                d.getType() == Schema.DisplayType.Address ||
                d.getType() == Schema.DisplayType.Base64) {
                continue;
            }

            FieldOptionDTO dto = new FieldOptionDTO(
                d.getLabel() + ' (' + d.getName() + ')',
                d.getName(),
                String.valueOf(d.getType()).toUpperCase()
            );

            if (d.getType() == Schema.DisplayType.Picklist ||
                d.getType() == Schema.DisplayType.MultiPicklist) {
                for (Schema.PicklistEntry pe : d.getPicklistValues()) {
                    if (pe.isActive()) {
                        dto.picklistValues.add(new OptionDTO(pe.getLabel(), pe.getValue()));
                    }
                }
            }

            if (d.getType() == Schema.DisplayType.Reference) {
                for (Schema.SObjectType rt : d.getReferenceTo()) {
                    if (rt != null) dto.referenceTo.add(rt.getDescribe().getName());
                }
            }

            out.add(dto);
        }

        out.sort(new FieldOptionSorter());
        return out;
    }

    /**
     * Returns child objects that have a Lookup or Master-Detail field pointing to the parent object.
     *
     * IMPORTANT: This method applies explicit filters per your requirements:
     *  - Parent Account: only Contact + Opportunity
     *  - Parent Opportunity: only Payment__c
     *  - Parent Contact: only Contact (as requested)
     *
     * Each option includes the relationship field API name (parentFieldOnChild),
     * which is required to build the subquery (SELECT parentFieldOnChild FROM ChildObject ...).
     */
    @AuraEnabled(cacheable=true)
    public static List<ChildObjectDTO> getChildObjects(String parentSObjectApiName) {
        if (String.isBlank(parentSObjectApiName)) {
            throw new AuraHandledException('Parent object is required.');
        }
        if (!ALLOWED_PARENT_SOBJECTS.contains(parentSObjectApiName) && parentSObjectApiName != 'Opportunity') {
            // you asked for Opportunity filter too
            throw new AuraHandledException('Invalid parent object: ' + parentSObjectApiName);
        }

        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        if (!gd.containsKey(parentSObjectApiName)) {
            throw new AuraHandledException('Invalid parent object: ' + parentSObjectApiName);
        }

        Schema.SObjectType parentType = gd.get(parentSObjectApiName);

        // ---- Explicit allowed child objects per parent (as requested) ----
        Set<String> allowedChildObjects = new Set<String>();
        if (parentSObjectApiName == 'Account') {
            allowedChildObjects.add('Contact');
            allowedChildObjects.add('Opportunity');
            allowedChildObjects.add('Case');
        } else if (parentSObjectApiName == 'Opportunity') {
            allowedChildObjects.add('Payment__c');
        } else if (parentSObjectApiName == 'Contact') {
            allowedChildObjects.add('Contact');
        } else {
            return new List<ChildObjectDTO>();
        }

        List<ChildObjectDTO> result = new List<ChildObjectDTO>();

        for (String childObjectName : allowedChildObjects) {
            if (!gd.containsKey(childObjectName)) continue;

            Schema.SObjectType childType = gd.get(childObjectName);
            Schema.DescribeSObjectResult childDescribe = childType.getDescribe();
            if (!childDescribe.isQueryable() || childDescribe.isCustomSetting()) continue;

            // Find a reference field on child that points to parent
            String relFieldApi = null;
            for (Schema.SObjectField f : childDescribe.fields.getMap().values()) {
                Schema.DescribeFieldResult fd = f.getDescribe();
                if (fd.getType() != Schema.DisplayType.Reference) continue;
                if (!fd.isAccessible()) continue;

                for (Schema.SObjectType ref : fd.getReferenceTo()) {
                    if (ref == parentType) {
                        relFieldApi = fd.getName();
                        break;
                    }
                }
                if (relFieldApi != null) break;
            }

            if (relFieldApi != null) {
                result.add(new ChildObjectDTO(childDescribe.getLabel(), childDescribe.getName(), relFieldApi));
            }
        }

        result.sort(new ChildObjectSorter());
        return result;
    }

    /* ===================== SAVE ===================== */

    @AuraEnabled
    public static Vonage_Campaigns_Configuration__c saveConfiguration(Map<String, Object> req) {
        if (req == null) throw new AuraHandledException('Save request is required.');

        Id id = (Id) req.get('id');
        Boolean active = (Boolean) req.get('active');
        String name = (String) req.get('name');
        String configurationType = (String) req.get('configurationType');
        Id campaignId = (Id) req.get('campaignId');
        String campaignName = (String) req.get('campaignName');
        String runFrequency = (String) req.get('runFrequency');
        String triggerConditionJson = (String) req.get('triggerConditionJson');

        if (String.isBlank(name) || String.isBlank(configurationType) ||
            campaignId == null || String.isBlank(campaignName)) {
            throw new AuraHandledException('Missing required fields.');
        }

        Boolean isScheduled = configurationType == 'Scheduled Job';

        Vonage_Campaigns_Configuration__c rec =
            id != null
            ? [SELECT Id FROM Vonage_Campaigns_Configuration__c WHERE Id = :id LIMIT 1]
            : new Vonage_Campaigns_Configuration__c();

        rec.Name = name;
        rec.Active__c = (active == true);
        rec.Configuration_Type__c = configurationType;
        rec.Campaign__c = campaignId;
        rec.Campaign_Name__c = campaignName;

        if (String.isBlank(triggerConditionJson)) {
            throw new AuraHandledException('Conditions JSON is required.');
        }

        // V2 only (your request: fix V2, don't support V1)
        String normalized = validateAndNormalizeTriggerJsonV2(triggerConditionJson);

        String scheduledQuery = null;
        if (isScheduled) {
            scheduledQuery = buildSoqlFromTriggerJsonV2(normalized);
            try {
                // Validate that the query parses & runs
                Database.query(scheduledQuery + ' LIMIT 1');
            } catch (Exception e) {
                throw new AuraHandledException('Generated SOQL is invalid: ' + e.getMessage());
            }
            rec.Run_Frequency__c = runFrequency;
            rec.Scheduled_Job_Query__c = scheduledQuery;
        } else {
            rec.Run_Frequency__c = null;
            rec.Scheduled_Job_Query__c = null;
        }

        rec.Trigger_Condition__c = normalized;
        upsert rec;
        return rec;
    }

    /* ===================== V2 VALIDATION ===================== */

    private static String validateAndNormalizeTriggerJsonV2(String jsonStr) {
        Object raw = JSON.deserializeUntyped(jsonStr);
        if (!(raw instanceof Map<String, Object>)) {
            throw new AuraHandledException('Invalid JSON shape.');
        }

        Map<String, Object> root = (Map<String, Object>) raw;

        Integer version = (root.containsKey('version') && root.get('version') != null)
            ? Integer.valueOf(String.valueOf(root.get('version')))
            : null;
        if (version == null || version != 2) {
            throw new AuraHandledException('Only version 2 JSON is supported.');
        }

        Map<String, Object> parent = (Map<String, Object>) root.get('parent');
        if (parent == null) {
            throw new AuraHandledException('Parent block is required.');
        }

        validateBlock(parent, true);

        List<Object> children = (List<Object>) root.get('children');
        if (children != null) {
            for (Object o : children) {
                if (o == null) continue;
                if (!(o instanceof Map<String, Object>)) {
                    throw new AuraHandledException('Invalid child block.');
                }
                Map<String, Object> ch = (Map<String, Object>) o;
                validateBlock(ch, false);

                // relationshipCondition required for children
                String rel = (String) ch.get('relationshipCondition');
                if (String.isBlank(rel) || !ALLOWED_RELATIONSHIP_CONDITIONS.contains(rel)) {
                    throw new AuraHandledException('Invalid relationship condition on child.');
                }

                // must have parentFieldOnChild for building subquery
                String pf = (String) ch.get('parentFieldOnChild');
                /*if (String.isBlank(pf)) {
                    throw new AuraHandledException('parentFieldOnChild is required for child blocks.');
                }*/
            }
        }

        // normalize back to string (preserves V2 contract)
        return JSON.serialize(root);
    }

    private static void validateBlock(Map<String, Object> block, Boolean isParent) {
        String sObj = (String) block.get('sObject');
        if (String.isBlank(sObj)) {
            throw new AuraHandledException((isParent ? 'Parent' : 'Child') + ' sObject is required.');
        }

        if (isParent) {
            if (!ALLOWED_PARENT_SOBJECTS.contains(sObj)) {
                throw new AuraHandledException('Invalid parent object.');
            }
        } else {
            // child object can be standard/custom; must exist & be queryable
            Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
            if (!gd.containsKey(sObj)) {
                throw new AuraHandledException('Invalid child object: ' + sObj);
            }
            Schema.DescribeSObjectResult d = gd.get(sObj).getDescribe();
            if (!d.isQueryable()) {
                throw new AuraHandledException('Child object not queryable: ' + sObj);
            }
        }

        String logic = (String) block.get('logic');
        if (String.isBlank(logic)) {
            throw new AuraHandledException((isParent ? 'Parent' : 'Child') + ' logic is required.');
        }
        validateLogicExpression(logic);

        List<Object> conds = (List<Object>) block.get('conditions');
        if (conds == null || conds.isEmpty()) {
            throw new AuraHandledException((isParent ? 'Parent' : 'Child') + ' conditions are required.');
        }

        // Ensure logic numbers exist 1..N and fieldAPI/operator exist
        Set<Integer> seen = new Set<Integer>();
        Integer maxN = 0;

        for (Object o : conds) {
            if (!(o instanceof Map<String, Object>)) {
                throw new AuraHandledException('Invalid condition shape.');
            }
            Map<String, Object> c = (Map<String, Object>) o;

            String nStr = (String) c.get('fieldLogicNumber');
            if (String.isBlank(nStr)) {
                throw new AuraHandledException('fieldLogicNumber is required.');
            }
            Integer n = Integer.valueOf(nStr);
            if (n <= 0) throw new AuraHandledException('fieldLogicNumber must be >= 1.');
            if (seen.contains(n)) throw new AuraHandledException('Duplicate fieldLogicNumber: ' + n);

            seen.add(n);
            if (n > maxN) maxN = n;

            if (String.isBlank((String) c.get('fieldAPI'))) {
                throw new AuraHandledException('fieldAPI is required.');
            }
            if (String.isBlank((String) c.get('fieldOperator'))) {
                throw new AuraHandledException('fieldOperator is required.');
            }
        }

        // basic: logic must reference only existing numbers
        for (Integer referenced : extractLogicNumbers(logic)) {
            if (!seen.contains(referenced)) {
                throw new AuraHandledException('Logic references missing condition number: ' + referenced);
            }
        }
    }

    private static void validateLogicExpression(String logic) {
        // Allow only digits, spaces, AND/OR/NOT, and parentheses.
        // This prevents injection into SOQL generation.
        String upper = logic.toUpperCase();

        // quick character whitelist
        for (Integer i = 0; i < upper.length(); i++) {
            String ch = upper.substring(i, i + 1);
            if (ch == ' ' || ch == '(' || ch == ')' ||
                (ch >= '0' && ch <= '9') ||
                ch == 'A' || ch == 'N' || ch == 'D' ||
                ch == 'O' || ch == 'R' || ch == 'T') {
                continue;
            }
            throw new AuraHandledException('Logic contains invalid characters.');
        }

        // Ensure tokens are sensible (very lightweight)
        if (upper.contains('&&') || upper.contains('||') || upper.contains(';')) {
            throw new AuraHandledException('Logic contains invalid tokens.');
        }
    }

    private static Set<Integer> extractLogicNumbers(String logic) {
        Set<Integer> nums = new Set<Integer>();
        if (String.isBlank(logic)) return nums;

        // Extract digit runs
        String current = '';
        for (Integer i = 0; i < logic.length(); i++) {
            String ch = logic.substring(i, i + 1);
            if (ch >= '0' && ch <= '9') {
                current += ch;
            } else {
                if (current != '') {
                    nums.add(Integer.valueOf(current));
                    current = '';
                }
            }
        }
        if (current != '') nums.add(Integer.valueOf(current));

        return nums;
    }

    /* ===================== SOQL BUILD (V2) ===================== */

    private static String buildSoqlFromTriggerJsonV2(String normalizedJson) {
        Map<String, Object> root =
            (Map<String, Object>) JSON.deserializeUntyped(normalizedJson);

        Map<String, Object> parent = (Map<String, Object>) root.get('parent');
        List<Object> children = (List<Object>) root.get('children');

        String parentSObj = (String) parent.get('sObject');

        String baseWhere = buildWhereFromBlock(parent, parentSObj);
        String soql = 'SELECT Id FROM ' + parentSObj + ' WHERE ' + baseWhere;

        if (children != null) {
            for (Object o : children) {
                if (o == null) continue;
                Map<String, Object> child = (Map<String, Object>) o;

                String rel = (String) child.get('relationshipCondition');
                String childObj = (String) child.get('sObject');
                //String parentField = (String) child.get('parentFieldOnChild');
				String parentField = resolveParentFieldOnChild(parentSObj, childObj);

                String childWhere = buildWhereFromBlock(child, childObj);

                String sub =
                    'SELECT ' + parentField +
                    ' FROM ' + childObj +
                    (String.isBlank(childWhere) ? '' : ' WHERE ' + childWhere);

                if (rel == 'NOT_HAVING') {
                    soql += ' AND Id NOT IN (' + sub + ')';
                } else {
                    soql += ' AND Id IN (' + sub + ')';
                }
            }
        }

        return soql;
    }

    private static String buildWhereFromBlock(Map<String, Object> block, String sObjectApiName) {
        List<Object> conds = (List<Object>) block.get('conditions');
        String logic = (String) block.get('logic');

        Map<Integer, String> fragments = new Map<Integer, String>();
        for (Object o : conds) {
            Map<String, Object> c = (Map<String, Object>) o;
            Integer n = Integer.valueOf((String) c.get('fieldLogicNumber'));
            fragments.put(n, buildConditionFragment(sObjectApiName, c));
        }

        // Replace tokens like "1" with "(<fragment>)" using word boundaries
        String expr = logic;

        // Iterate in descending length to avoid replacing "1" in "10"
        List<Integer> keys = new List<Integer>();
        keys.addAll(fragments.keySet());
        keys.sort();
        keys = reverseList(keys);

        for (Integer k : keys) {
            expr = expr.replaceAll('\\b' + String.valueOf(k) + '\\b', '(' + fragments.get(k) + ')');
        }

        // Normalize operators to SOQL-friendly (AND/OR/NOT already valid)
        return expr;
    }

    private static String buildConditionFragment(String sObjectApiName, Map<String, Object> c) {
        String fieldApi = (String) c.get('fieldAPI');
        String op = (String) c.get('fieldOperator');
        String typeStr = (String) c.get('fieldType');
        Object valueObj = c.get('fieldValue');

        if (String.isBlank(fieldApi) || String.isBlank(op)) {
            throw new AuraHandledException('Condition must include fieldAPI and fieldOperator.');
        }

        // Validate field exists on the object
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        if (!gd.containsKey(sObjectApiName)) {
            throw new AuraHandledException('Invalid object: ' + sObjectApiName);
        }
        Schema.DescribeSObjectResult dor = gd.get(sObjectApiName).getDescribe();
        Map<String, Schema.SObjectField> fmap = dor.fields.getMap();
        if (!fmap.containsKey(fieldApi)) {
            throw new AuraHandledException('Field not found on ' + sObjectApiName + ': ' + fieldApi);
        }

        Schema.DescribeFieldResult fd = fmap.get(fieldApi).getDescribe();
        String fieldType = String.isBlank(typeStr) ? String.valueOf(fd.getType()).toUpperCase() : typeStr.toUpperCase();

        // Null operators: no value
        if (op == 'is_null') {
            return fieldApi + ' = NULL';
        }
        if (op == 'is_not_null') {
            return fieldApi + ' != NULL';
        }

        // Value required for other ops
        if (valueObj == null) {
            throw new AuraHandledException('Value is required for operator ' + op + ' on field ' + fieldApi);
        }

        // Convert the value to a SOQL literal
        String soqlVal = toSoqlLiteral(fieldType, valueObj);

        // Operator mapping
        if (op == 'equal') return fieldApi + ' = ' + soqlVal;
        if (op == 'not_equal') return fieldApi + ' != ' + soqlVal;
        if (op == 'greater_than') return fieldApi + ' > ' + soqlVal;
        if (op == 'less_than') return fieldApi + ' < ' + soqlVal;
        if (op == 'greater_or_equal') return fieldApi + ' >= ' + soqlVal;
        if (op == 'less_or_equal') return fieldApi + ' <= ' + soqlVal;

        if (op == 'contains') return fieldApi + ' LIKE ' + quoteLike('%' + String.valueOf(valueObj) + '%');
        if (op == 'not_contains') return 'NOT (' + fieldApi + ' LIKE ' + quoteLike('%' + String.valueOf(valueObj) + '%') + ')';
        if (op == 'starts_with') return fieldApi + ' LIKE ' + quoteLike(String.valueOf(valueObj) + '%');
        if (op == 'ends_with') return fieldApi + ' LIKE ' + quoteLike('%' + String.valueOf(valueObj));

        // multipicklist ops
        if (op == 'includes') return fieldApi + ' INCLUDES ' + soqlVal;
        if (op == 'excludes') return fieldApi + ' EXCLUDES ' + soqlVal;

        throw new AuraHandledException('Unsupported operator: ' + op);
    }

    private static String toSoqlLiteral(String fieldType, Object valueObj) {
        String t = (fieldType == null) ? '' : fieldType.toUpperCase();

        // Multi-select picklist includes/excludes expects ('A','B') or ('A')
        if (t == 'MULTIPICKLIST') {
            if (valueObj instanceof List<Object>) {
                List<Object> vals = (List<Object>) valueObj;
                List<String> quoted = new List<String>();
                for (Object v : vals) {
                    if (v == null) continue;
                    quoted.add('\'' + escapeSoql(String.valueOf(v)) + '\'');
                }
                if (quoted.isEmpty()) {
                    throw new AuraHandledException('At least one value is required for multipicklist.');
                }
                return '(' + String.join(quoted, ',') + ')';
            } else if (valueObj instanceof List<String>) {
                List<String> vals = (List<String>) valueObj;
                List<String> quoted = new List<String>();
                for (String v : vals) {
                    if (String.isBlank(v)) continue;
                    quoted.add('\'' + escapeSoql(v) + '\'');
                }
                if (quoted.isEmpty()) {
                    throw new AuraHandledException('At least one value is required for multipicklist.');
                }
                return '(' + String.join(quoted, ',') + ')';
            } else {
                // single value
                return '(\'' + escapeSoql(String.valueOf(valueObj)) + '\')';
            }
        }

        if (t == 'BOOLEAN') {
            if (valueObj instanceof Boolean) {
                return ((Boolean) valueObj) ? 'TRUE' : 'FALSE';
            }
            String s = String.valueOf(valueObj).toLowerCase();
            if (s == 'true' || s == '1') return 'TRUE';
            if (s == 'false' || s == '0') return 'FALSE';
            throw new AuraHandledException('Invalid boolean value.');
        }

        if (t == 'INTEGER' || t == 'DOUBLE' || t == 'CURRENCY' || t == 'PERCENT') {
            // numeric: do not quote
            return String.valueOf(valueObj);
        }

        if (t == 'DATE') {
            // value as YYYY-MM-DD
            String s = String.valueOf(valueObj);
            // Date literal must be quoted
            return '\'' + escapeSoql(s) + '\'';
        }

        if (t == 'DATETIME') {
            // Expect UTC string from UI like "YYYY-MM-DD HH:MM:SS" OR "YYYY-MM-DD HH:MM"
            // We will parse as GMT and then emit a GMT formatted SOQL literal.
            String s = String.valueOf(valueObj).trim();

            // If UI sends seconds-less, add :00
            if (s.length() == 16) { // "YYYY-MM-DD HH:MM"
                s = s + ':00';
            }

            DateTime dt;
            try {
                dt = DateTime.valueOfGmt(s);
            } catch (Exception e) {
                throw new AuraHandledException('Invalid datetime value: ' + s);
            }

            // SOQL datetime literal: 2026-01-21T05:00:00Z
            return dt.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        }

        if (t == 'REFERENCE') {
            // treat as Id or string
            return '\'' + escapeSoql(String.valueOf(valueObj)) + '\'';
        }

        // Default (text / picklist / etc.)
        return '\'' + escapeSoql(String.valueOf(valueObj)) + '\'';
    }

    private static String escapeSoql(String s) {
        if (s == null) return '';
        return s.replace('\\', '\\\\').replace('\'', '\\\'');
    }

    private static String quoteLike(String raw) {
        return '\'' + escapeSoql(raw) + '\'';
    }

    /* ===================== SORTERS ===================== */

    private class FieldOptionSorter implements Comparator<FieldOptionDTO> {
        public Integer compare(FieldOptionDTO a, FieldOptionDTO b) {
            return String.valueOf(a.label).toLowerCase()
                .compareTo(String.valueOf(b.label).toLowerCase());
        }
    }

    private class ChildObjectSorter implements Comparator<ChildObjectDTO> {
        public Integer compare(ChildObjectDTO a, ChildObjectDTO b) {
            return String.valueOf(a.label).toLowerCase()
                .compareTo(String.valueOf(b.label).toLowerCase());
        }
    }
    
    private static List<Integer> reverseList(List<Integer> input) {
        List<Integer> out = new List<Integer>();
        for (Integer i = input.size() - 1; i >= 0; i--) {
            out.add(input[i]);
        }
        return out;
    }
    
    private static String resolveParentFieldOnChild(String parentSObject, String childSObject) {
    Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();

    if (!gd.containsKey(parentSObject) || !gd.containsKey(childSObject)) {
        throw new AuraHandledException('Invalid parent/child object');
    }

    Schema.SObjectType parentType = gd.get(parentSObject);
    Schema.DescribeSObjectResult childDescribe = gd.get(childSObject).getDescribe();

    for (Schema.SObjectField f : childDescribe.fields.getMap().values()) {
        Schema.DescribeFieldResult fd = f.getDescribe();
        if (fd.getType() != Schema.DisplayType.Reference) continue;

        for (Schema.SObjectType ref : fd.getReferenceTo()) {
            if (ref == parentType) {
                return fd.getName(); // ✅ e.g. AccountId
            }
        }
    }

    throw new AuraHandledException(
        'No relationship field found from ' + childSObject + ' to ' + parentSObject
    );
}


}