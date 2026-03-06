/**
* @File Name : CadenceSchedularHandler.cls
* @Description :
* @Author :
* @Last Modified By :
* @Last Modified On : May 16, 2025
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | May 16, 2025 |   | Initial Version
**/

public class CadenceSchedularHandler {
	@AuraEnabled
	public static void LightningStudio(){
		System.debug('Lightning Studio');
	}
	public static String buildWhereClause(String filtersJson, String filterLogic) {
		List<FilterCondition> conditions = (List<FilterCondition>) JSON.deserialize(filtersJson, List<FilterCondition>.class);
		List<String> conditionStrings = new List<String>();

		for (Integer i = 0; i < conditions.size(); i++) {
			FilterCondition cond = conditions[i];
			String val = cond.value;

			// Detect number
			Boolean isNumber = Pattern.matches('^\\d+(\\.\\d+)?$', val);
			// Detect date format: YYYY-MM-DD
			Boolean isDate = Pattern.matches('^\\d{4}-\\d{2}-\\d{2}$', val);

			// Quote string values if not number or date
			if (!isNumber && !isDate) {
				val = '\'' + String.escapeSingleQuotes(val) + '\'';
			}

			String condition = cond.field + ' ' + cond.operator + ' ' + val;
			conditionStrings.add(condition);
		}

		// Replace 1, 2, 3... in logic with actual conditions
		String whereClause = filterLogic;
		for (Integer i = 0; i < conditionStrings.size(); i++) {
			whereClause = whereClause.replaceAll('\\b' + String.valueOf(i + 1) + '\\b', '(' + conditionStrings[i] + ')');
		}

		return whereClause;
	}
	public class FilterCondition {
		public String field;
		public String operator;
		public String value;
	}
}