@IsTest
public class VonageCampaignConfigControllerTest {

    @IsTest
    static void coverControllerHappyPath() {

        // ---------- DATA SETUP ----------

        Campaign camp = new Campaign(
            Name = 'Test Campaign',
            IsActive = true
        );
        insert camp;

        Account acc = new Account(
            Name = 'Test Account',
            Affiliated_Id__c = 1002421,
            Member_Number__c = '13523412',
            Contact_Id__c = 5420.0
        );
        insert acc;

        Contact con = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            AccountId = acc.Id,
            Affiliate_Name__c = 'test',
            Member_Number__c = '13523413'
        );
        insert con;

        Case cs = new Case(
            Status = 'New',
            Type = 'Membership Upgrade',
            AccountId = acc.Id
        );
        insert cs;

        Id oppRtId =
            Schema.SObjectType.Opportunity
                .getRecordTypeInfosByDeveloperName()
                .get('Membership_Annual_Dues')
                .getRecordTypeId();

        Opportunity opp = new Opportunity(
            Name = 'Opp1',
            StageName = 'Closed Won',
            CloseDate = Date.today(),
            AccountId = acc.Id,
            RecordTypeId = oppRtId
        );
        insert opp;

        // ---------- READ METHODS ----------

        Test.startTest();

        VonageCampaignConfigController.getConfigurations();
        VonageCampaignConfigController.getCampaignOptions();
        VonageCampaignConfigController.getTriggerFieldOptions('Account');
        VonageCampaignConfigController.getChildObjects('Account');

        // ---------- SAVE CONFIGURATION ----------

        Map<String, Object> parent = new Map<String, Object>{
            'sObject' => 'Account',
            'logic' => '1',
            'conditions' => new List<Object>{
                new Map<String, Object>{
                    'fieldAPI' => 'Name',
                    'fieldType' => 'STRING',
                    'fieldOperator' => 'contains',
                    'fieldValue' => 'Test',
                    'fieldLogicNumber' => '1'
                }
            }
        };

        Map<String, Object> child = new Map<String, Object>{
            'sObject' => 'Contact',
            'relationshipCondition' => 'HAVING',
            'logic' => '1',
            'conditions' => new List<Object>{
                new Map<String, Object>{
                    'fieldAPI' => 'AccountId',
                    'fieldType' => 'REFERENCE',
                    'fieldOperator' => 'is_not_null',
                    'fieldValue' => null,
                    'fieldLogicNumber' => '1'
                }
            }
        };

        Map<String, Object> triggerJson = new Map<String, Object>{
            'version' => 2,
            'parent' => parent,
            'children' => new List<Object>{ child }
        };

        Map<String, Object> req = new Map<String, Object>{
            'active' => true,
            'name' => 'Test Config',
            'configurationType' => 'Scheduled Job',
            'campaignId' => camp.Id,
            'campaignName' => camp.Name,
            'runFrequency' => 'Every Hour',
            'triggerConditionJson' => JSON.serialize(triggerJson)
        };

        VonageCampaignConfigController.saveConfiguration(req);

        Test.stopTest();
    }
    
    @IsTest
static void coverDateTimeAndOptionDtoConstructor() {

    // ---------- OPTION DTO (3-ARG CONSTRUCTOR) ----------
    VonageCampaignConfigController.OptionDTO opt =
        new VonageCampaignConfigController.OptionDTO(
            'Report Label',
            '00Oxx0000000001',
            'Developer_Name'
        );

    // ---------- CAMPAIGN ----------
    Campaign camp = new Campaign(
        Name = 'DT Campaign',
        IsActive = true
    );
    insert camp;

    // ---------- ACCOUNT ----------
    Account acc = new Account(
        Name = 'Datetime Test Account'
    );
    insert acc;

    // ---------- DATETIME CONDITION ----------
    // Use a fixed past datetime so the query always works
    DateTime dt = System.now().addDays(-1);
    String dtStr = dt.formatGmt('yyyy-MM-dd HH:mm:ss');

    Map<String, Object> parent = new Map<String, Object>{
        'sObject' => 'Account',
        'logic' => '1',
        'conditions' => new List<Object>{
            new Map<String, Object>{
                'fieldAPI' => 'CreatedDate',
                'fieldType' => 'DATETIME',
                'fieldOperator' => 'greater_or_equal',
                'fieldValue' => dtStr,
                'fieldLogicNumber' => '1'
            }
        }
    };

    Map<String, Object> triggerJson = new Map<String, Object>{
        'version' => 2,
        'parent' => parent,
        'children' => new List<Object>()
    };

    Map<String, Object> req = new Map<String, Object>{
        'active' => true,
        'name' => 'Datetime Config',
        'configurationType' => 'Scheduled Job',
        'campaignId' => camp.Id,
        'campaignName' => camp.Name,
        'runFrequency' => 'Every Hour',
        'triggerConditionJson' => JSON.serialize(triggerJson)
    };

    Test.startTest();
    VonageCampaignConfigController.saveConfiguration(req);
    Test.stopTest();
}

}