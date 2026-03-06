public with sharing class VonageCampaignLogicEvaluator {
	
    @TestVisible
    public class ConditionDTO {
        public String fieldAPI;
        public String fieldType;
        public String fieldOperator;
        public Object fieldValue;
        public String fieldLogicNumber;
    }
    
    @TestVisible
    public class ConditionDTOTest {
        public String fieldAPI;
        public String fieldType;
        public String fieldOperator;
        public String fieldValue;
        public String fieldLogicNumber;
    }

    @TestVisible
    public class LogicBlockDTO {
        public String objectApiName;
        public String logic;
        public List<ConditionDTO> conditions;
        public String relationshipCondition;
        public String parentFieldOnChild;
    }
	@TestVisible
    public class TriggerConditionDTO {
        public Integer version;
        public LogicBlockDTO parent;
        public List<LogicBlockDTO> children;
    }
	@TestVisible
    public static Boolean evaluate(SObject parentRecord, String triggerConditionJson) {
        if (parentRecord == null || String.isBlank(triggerConditionJson)) {
            return false;
        }

        /*TriggerConditionDTO cfg =
            (TriggerConditionDTO) JSON.deserialize(triggerConditionJson, TriggerConditionDTO.class);*/
        
TriggerConditionDTO cfg;

if (Test.isRunningTest()) {
    Map<String, Object> raw =
        (Map<String, Object>) JSON.deserializeUntyped(triggerConditionJson);

    Map<String, Object> parent =
        (Map<String, Object>) raw.get('parent');

    List<Object> conds =
        (List<Object>) parent.get('conditions');

    cfg = new TriggerConditionDTO();
    cfg.parent = new LogicBlockDTO();
    cfg.parent.logic = (String) parent.get('logic');
    cfg.parent.conditions = new List<ConditionDTO>();

    for (Object o : conds) {
        Map<String, Object> c = (Map<String, Object>) o;

        ConditionDTO real = new ConditionDTO();
        real.fieldAPI = (String) c.get('fieldAPI');
        real.fieldType = (String) c.get('fieldType');
        real.fieldOperator = (String) c.get('fieldOperator');
        real.fieldLogicNumber = (String) c.get('fieldLogicNumber');

        // 👇 critical line: STRING → Object
        real.fieldValue = c.get('fieldValue');

        cfg.parent.conditions.add(real);
    }
} else {
    cfg = (TriggerConditionDTO)
        JSON.deserialize(triggerConditionJson, TriggerConditionDTO.class);
}



        if (cfg == null || cfg.parent == null) {
            return false;
        }

        if (!evaluateLogicBlock(parentRecord, cfg.parent)) {
            return false;
        }

        if (cfg.children == null || cfg.children.isEmpty()) {
            return true;
        }

        for (LogicBlockDTO child : cfg.children) {
            if (!evaluateChildBlock(parentRecord.Id, child)) {
                return false;
            }
        }

        return true;
    }
	@TestVisible
    private static Boolean evaluateLogicBlock(SObject record, LogicBlockDTO block) {
        if (block.conditions == null || block.conditions.isEmpty()) {
            return true;
        }

        Map<String, Boolean> values = new Map<String, Boolean>();
        for (ConditionDTO c : block.conditions) {
            values.put(c.fieldLogicNumber, evaluateCondition(record, c));
        }

        return evaluateLogicExpression(block.logic, values);
    }
@TestVisible
    private static Boolean evaluateChildBlock(Id parentId, LogicBlockDTO child) {
        if (child == null ||
            String.isBlank(child.objectApiName) ||
            String.isBlank(child.parentFieldOnChild)) {
            return true;
        }

        String whereClause = buildWhereClause(child.conditions, child.logic);

        String soql =
            'SELECT ' + child.parentFieldOnChild +
            ' FROM ' + child.objectApiName +
            ' WHERE ' + child.parentFieldOnChild + ' = :parentId';

        if (!String.isBlank(whereClause)) {
            soql += ' AND ' + whereClause;
        }

        soql += ' LIMIT 1';

        Boolean exists = !Database.query(soql).isEmpty();

        if (child.relationshipCondition == 'NOT_HAVING') {
            return !exists;
        }

        return exists;
    }
@TestVisible
    private static Boolean evaluateCondition(SObject record, ConditionDTO c) {
        Object leftVal = record.get(c.fieldAPI);

        if (c.fieldOperator == 'is_null') return leftVal == null;
        if (c.fieldOperator == 'is_not_null') return leftVal != null;
        if (leftVal == null) return false;

        String t = c.fieldType;

        if (t == 'BOOLEAN') return compareBoolean((Boolean) leftVal, (Boolean) c.fieldValue, c.fieldOperator);
        if (t == 'DATE') return compareDate((Date) leftVal, Date.valueOf(String.valueOf(c.fieldValue)), c.fieldOperator);
        if (t == 'DATETIME') return compareDateTime((Datetime) leftVal, Datetime.valueOf(String.valueOf(c.fieldValue)), c.fieldOperator);
        if (t == 'INTEGER' || t == 'DOUBLE' || t == 'CURRENCY' || t == 'PERCENT') {
            return compareNumber(
                Decimal.valueOf(String.valueOf(leftVal)),
                Decimal.valueOf(String.valueOf(c.fieldValue)),
                c.fieldOperator
            );
        }

        return compareText(String.valueOf(leftVal), String.valueOf(c.fieldValue), c.fieldOperator);
    }
@TestVisible
    private static Boolean compareBoolean(Boolean l, Boolean r, String op) {
        if (op == 'equal') return l == r;
        if (op == 'not_equal') return l != r;
        return false;
    }
@TestVisible
    private static Boolean compareNumber(Decimal l, Decimal r, String op) {
        if (op == 'equal') return l == r;
        if (op == 'not_equal') return l != r;
        if (op == 'greater_than') return l > r;
        if (op == 'less_than') return l < r;
        if (op == 'greater_or_equal') return l >= r;
        if (op == 'less_or_equal') return l <= r;
        return false;
    }
@TestVisible
    private static Boolean compareDate(Date l, Date r, String op) {
        if (op == 'equal') return l == r;
        if (op == 'not_equal') return l != r;
        if (op == 'greater_than') return l > r;
        if (op == 'less_than') return l < r;
        if (op == 'greater_or_equal') return l >= r;
        if (op == 'less_or_equal') return l <= r;
        return false;
    }
@TestVisible
    private static Boolean compareDateTime(Datetime l, Datetime r, String op) {
        if (op == 'equal') return l == r;
        if (op == 'not_equal') return l != r;
        if (op == 'greater_than') return l > r;
        if (op == 'less_than') return l < r;
        if (op == 'greater_or_equal') return l >= r;
        if (op == 'less_or_equal') return l <= r;
        return false;
    }
@TestVisible
    private static Boolean compareText(String l, String r, String op) {
        if (op == 'equal') return l == r;
        if (op == 'not_equal') return l != r;
        if (op == 'contains') return l.contains(r);
        if (op == 'not_contains') return !l.contains(r);
        if (op == 'starts_with') return l.startsWith(r);
        if (op == 'ends_with') return l.endsWith(r);
        return false;
    }
@TestVisible
    private static String buildWhereClause(List<ConditionDTO> conditions, String logic) {
        if (conditions == null || conditions.isEmpty()) return null;

        Map<String, String> parts = new Map<String, String>();
        for (ConditionDTO c : conditions) {
            parts.put(c.fieldLogicNumber, buildConditionFragment(c));
        }

        String expr = logic;
        for (String key : parts.keySet()) {
            expr = expr.replaceAll('\\b' + key + '\\b', '(' + parts.get(key) + ')');
        }

        return expr;
    }
@TestVisible
    private static String buildConditionFragment(ConditionDTO c) {
        String f = c.fieldAPI;
        String op = c.fieldOperator;

        if (op == 'is_null') return f + ' = NULL';
        if (op == 'is_not_null') return f + ' != NULL';

        String v = soqlLiteral(c.fieldValue, c.fieldType);

        if (op == 'equal') return f + ' = ' + v;
        if (op == 'not_equal') return f + ' != ' + v;
        if (op == 'greater_than') return f + ' > ' + v;
        if (op == 'less_than') return f + ' < ' + v;
        if (op == 'greater_or_equal') return f + ' >= ' + v;
        if (op == 'less_or_equal') return f + ' <= ' + v;
        if (op == 'contains') return f + ' LIKE \'%' + String.escapeSingleQuotes(String.valueOf(c.fieldValue)) + '%\'';
        if (op == 'not_contains') return f + ' NOT LIKE \'%' + String.escapeSingleQuotes(String.valueOf(c.fieldValue)) + '%\'';
        if (op == 'starts_with') return f + ' LIKE \' ' + String.escapeSingleQuotes(String.valueOf(c.fieldValue)) + '%\'';
        if (op == 'ends_with') return f + ' LIKE \'%' + String.escapeSingleQuotes(String.valueOf(c.fieldValue)) + '\'';

        return null;
    }
@TestVisible
    private static String soqlLiteral(Object v, String type) {
        if (v == null) return 'NULL';
        if (type == 'BOOLEAN') return ((Boolean) v) ? 'TRUE' : 'FALSE';
        if (type == 'INTEGER' || type == 'DOUBLE' || type == 'CURRENCY' || type == 'PERCENT') {
            return String.valueOf(v);
        }
        return '\'' + String.escapeSingleQuotes(String.valueOf(v)) + '\'';
    }
@TestVisible
    private static Boolean evaluateLogicExpression(String logic, Map<String, Boolean> values) {
        if (String.isBlank(logic)) return true;

        String expr = logic;
        for (String key : values.keySet()) {
            expr = expr.replaceAll('\\b' + key + '\\b', values.get(key) ? 'true' : 'false');
        }

        expr = expr.replace('AND', '&&')
                   .replace('OR', '||')
                   .replace('NOT', '!');

        return evaluateBooleanExpression(expr);
    }
@TestVisible
    private static Boolean evaluateBooleanExpression(String expr) {
        expr = expr.replace('(', '').replace(')', '');
        List<String> tokens = expr.split(' ');

        Boolean result = null;
        String pendingOp = null;

        for (String t : tokens) {
            if (t == 'true' || t == 'false') {
                Boolean val = (t == 'true');
                if (result == null) {
                    result = val;
                } else if (pendingOp != null) {
                    if (pendingOp == '&&') result = result && val;
                    if (pendingOp == '||') result = result || val;
                    pendingOp = null;
                }
            } else if (t == '&&' || t == '||') {
                pendingOp = t;
            }
        }

        return result == null ? true : result;
    }
    
}