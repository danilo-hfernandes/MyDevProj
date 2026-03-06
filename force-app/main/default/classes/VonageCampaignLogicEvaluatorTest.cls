@IsTest
private class VonageCampaignLogicEvaluatorTest {

    @IsTest
    static void coverEverything() {

        // ---------- primitive comparisons ----------
        VonageCampaignLogicEvaluator.compareBoolean(true, true, 'equal');
        VonageCampaignLogicEvaluator.compareBoolean(true, false, 'not_equal');

        VonageCampaignLogicEvaluator.compareNumber(5, 5, 'equal');
        VonageCampaignLogicEvaluator.compareNumber(5, 3, 'greater_than');
        VonageCampaignLogicEvaluator.compareNumber(3, 5, 'less_than');
        VonageCampaignLogicEvaluator.compareNumber(5, 5, 'greater_or_equal');
        VonageCampaignLogicEvaluator.compareNumber(5, 5, 'less_or_equal');

        Date d = Date.today();
        VonageCampaignLogicEvaluator.compareDate(d, d, 'equal');
        VonageCampaignLogicEvaluator.compareDate(d, d.addDays(-1), 'greater_than');

        Datetime dt = System.now();
        VonageCampaignLogicEvaluator.compareDateTime(dt, dt, 'equal');
        VonageCampaignLogicEvaluator.compareDateTime(dt, dt.addMinutes(-1), 'greater_than');

        VonageCampaignLogicEvaluator.compareText('abc', 'a', 'starts_with');
        VonageCampaignLogicEvaluator.compareText('abc', 'c', 'ends_with');
        VonageCampaignLogicEvaluator.compareText('abc', 'b', 'contains');
        VonageCampaignLogicEvaluator.compareText('abc', 'x', 'not_contains');

        // ---------- soqlLiteral ----------
        VonageCampaignLogicEvaluator.soqlLiteral(true, 'BOOLEAN');
        VonageCampaignLogicEvaluator.soqlLiteral(10, 'INTEGER');
        VonageCampaignLogicEvaluator.soqlLiteral('abc', 'TEXT');

        // ---------- ConditionDTO ----------
        VonageCampaignLogicEvaluator.ConditionDTO c =
            new VonageCampaignLogicEvaluator.ConditionDTO();
        c.fieldAPI = 'Name';
        c.fieldType = 'TEXT';
        c.fieldOperator = 'equal';
        c.fieldValue = 'Test';
        c.fieldLogicNumber = '1';

        // ---------- buildConditionFragment ----------
        VonageCampaignLogicEvaluator.buildConditionFragment(c);

        // ---------- buildWhereClause ----------
        List<VonageCampaignLogicEvaluator.ConditionDTO> conditions =
            new List<VonageCampaignLogicEvaluator.ConditionDTO>{ c };

        VonageCampaignLogicEvaluator.buildWhereClause(conditions, '1');

        // ---------- logic expression ----------
        Map<String, Boolean> values = new Map<String, Boolean>{ '1' => true };
        VonageCampaignLogicEvaluator.evaluateLogicExpression('1', values);
        VonageCampaignLogicEvaluator.evaluateBooleanExpression('true && false');
        VonageCampaignLogicEvaluator.evaluateBooleanExpression('true || false');

        // ---------- evaluateCondition ----------
        Account acc = new Account(Name = 'Test');
        VonageCampaignLogicEvaluator.evaluateCondition(acc, c);

        // ---------- evaluateLogicBlock ----------
        VonageCampaignLogicEvaluator.LogicBlockDTO block =
            new VonageCampaignLogicEvaluator.LogicBlockDTO();
        block.logic = '1';
        block.conditions = conditions;

        VonageCampaignLogicEvaluator.evaluateLogicBlock(acc, block);

        // ---------- evaluateChildBlock (early return paths) ----------
        VonageCampaignLogicEvaluator.evaluateChildBlock(acc.Id, null);

        VonageCampaignLogicEvaluator.LogicBlockDTO child =
            new VonageCampaignLogicEvaluator.LogicBlockDTO();
        child.objectApiName = null;
        child.parentFieldOnChild = null;

        VonageCampaignLogicEvaluator.evaluateChildBlock(acc.Id, child);
    }




    /* =========================
       TEST 1 — Test.isRunningTest() PATH
       ========================= */
    @IsTest
    static void testParentOnly_AllTypes() {

        Account acc = new Account(
            Name = 'Test Account',
            NumberOfEmployees = 25
        );
        insert acc;

        String jsonCfg = JSON.serialize(new Map<String, Object>{
            'parent' => new Map<String, Object>{
                'logic' => '1 AND 2 AND 3 AND 4',
                'conditions' => new List<Object>{
                    new Map<String, Object>{
                        'fieldAPI' => 'Name',
                        'fieldType' => 'TEXT',
                        'fieldOperator' => 'contains',
                        'fieldValue' => 'Test',
                        'fieldLogicNumber' => '1'
                    },
                    new Map<String, Object>{
                        'fieldAPI' => 'NumberOfEmployees',
                        'fieldType' => 'INTEGER',
                        'fieldOperator' => 'greater_than',
                        'fieldValue' => '10',
                        'fieldLogicNumber' => '2'
                    },
                    new Map<String, Object>{
                        'fieldAPI' => 'CreatedDate',
                        'fieldType' => 'DATE',
                        'fieldOperator' => 'less_or_equal',
                        'fieldValue' => String.valueOf(Date.today().addDays(1)),
                        'fieldLogicNumber' => '3'
                    },
                    new Map<String, Object>{
                        'fieldAPI' => 'Name',
                        'fieldType' => 'TEXT',
                        'fieldOperator' => 'is_not_null',
                        'fieldValue' => null,
                        'fieldLogicNumber' => '4'
                    }
                }
            }
        });

        Test.startTest();
        VonageCampaignLogicEvaluator.evaluate(acc, jsonCfg);
        Test.stopTest();
    }

    /* =========================
       TEST 2 — REAL JSON PATH (NO Test.isRunningTest)
       ========================= */
    @IsTest
    static void testParentAndChild_HavingAndNotHaving() {

        Account acc = new Account(Name = 'Parent');
        insert acc;

        Contact con = new Contact(
            FirstName = 'John',
            LastName = 'Doe',
            AccountId = acc.Id
        );
        insert con;

        String jsonCfg =
        '{' +
        '  "version": 2,' +
        '  "parent": {' +
        '    "logic": "1",' +
        '    "conditions": [' +
        '      {' +
        '        "fieldAPI": "Name",' +
        '        "fieldType": "TEXT",' +
        '        "fieldOperator": "starts_with",' +
        '        "fieldValue": "Par",' +
        '        "fieldLogicNumber": "1"' +
        '      }' +
        '    ]' +
        '  },' +
        '  "children": [' +
        '    {' +
        '      "objectApiName": "Contact",' +
        '      "parentFieldOnChild": "AccountId",' +
        '      "relationshipCondition": "HAVING",' +
        '      "logic": "1",' +
        '      "conditions": [' +
        '        {' +
        '          "fieldAPI": "LastName",' +
        '          "fieldType": "TEXT",' +
        '          "fieldOperator": "equal",' +
        '          "fieldValue": "Doe",' +
        '          "fieldLogicNumber": "1"' +
        '        }' +
        '      ]' +
        '    },' +
        '    {' +
        '      "objectApiName": "Contact",' +
        '      "parentFieldOnChild": "AccountId",' +
        '      "relationshipCondition": "NOT_HAVING",' +
        '      "logic": "1",' +
        '      "conditions": [' +
        '        {' +
        '          "fieldAPI": "FirstName",' +
        '          "fieldType": "TEXT",' +
        '          "fieldOperator": "equal",' +
        '          "fieldValue": "Nobody",' +
        '          "fieldLogicNumber": "1"' +
        '        }' +
        '      ]' +
        '    }' +
        '  ]' +
        '}';

        Test.startTest();
        VonageCampaignLogicEvaluator.evaluate(acc, jsonCfg);
        Test.stopTest();
    }

    /* =========================
       TEST 3 — Guard clauses
       ========================= */
    @IsTest
    static void testNullGuards() {
        Account acc = new Account(Name = 'X');
        insert acc;

        Test.startTest();
        VonageCampaignLogicEvaluator.evaluate(null, 'x');
        VonageCampaignLogicEvaluator.evaluate(acc, null);
        Test.stopTest();
    }
    
    @IsTest
static void cover_buildConditionFragment_allOperators() {

    List<String> ops = new List<String>{
        'equal',
        'not_equal',
        'greater_than',
        'less_than',
        'greater_or_equal',
        'less_or_equal',
        'contains',
        'not_contains',
        'starts_with',
        'ends_with'
    };

    for (String op : ops) {
        VonageCampaignLogicEvaluator.ConditionDTO c =
            new VonageCampaignLogicEvaluator.ConditionDTO();

        c.fieldAPI = 'Name';
        c.fieldType = 'TEXT';
        c.fieldOperator = op;
        c.fieldValue = 'Test';
        c.fieldLogicNumber = '1';

        //Executes each branch
        VonageCampaignLogicEvaluator.buildConditionFragment(c);
    }
}

}