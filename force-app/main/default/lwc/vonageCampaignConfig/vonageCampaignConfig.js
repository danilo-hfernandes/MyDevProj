import { LightningElement, track } from 'lwc';

import getConfigurations from '@salesforce/apex/VonageCampaignConfigController.getConfigurations';
import getCampaignOptions from '@salesforce/apex/VonageCampaignConfigController.getCampaignOptions';
import getTriggerFieldOptions from '@salesforce/apex/VonageCampaignConfigController.getTriggerFieldOptions';
import saveConfiguration from '@salesforce/apex/VonageCampaignConfigController.saveConfiguration';
import getChildObjects from '@salesforce/apex/VonageCampaignConfigController.getChildObjects';

const CONFIG_TYPES = [
    /*'On Record Create',
    'On Record Update',
    'On Record Create and Update',*/
    'Scheduled Job'
];

const RUN_FREQ = [
    'Every 30 Minutes',
    'Every Hour',
    'Every 2 Hours',
    'Every 4 Hours',
    'Every 6 Hours',
    'Every 12 Hours',
    'Daily',
    'Weekly',
    'Monthly'
];

const TRIGGER_OBJECTS = ['Lead', 'Contact', 'Account'];

export default class VonageCampaignConfig extends LightningElement {
    @track isSaving = false;
    @track rows = [];
    @track campaignOptions = [];
    errorMsg;

    configurationTypeOptions = CONFIG_TYPES.map(v => ({ label: v, value: v }));
    runFrequencyOptions = RUN_FREQ.map(v => ({ label: v, value: v }));
    triggerObjectOptions = TRIGGER_OBJECTS.map(v => ({ label: v, value: v }));

    parentChildConditionOptions = [
        { label: 'HAVING', value: 'HAVING' },
        { label: 'NOT HAVING', value: 'NOT_HAVING' }
    ];

    async connectedCallback() {
        await this.loadAll();
    }

    extractValue(e) {
        if (e?.detail && e.detail.value !== undefined) return e.detail.value;
        if (e?.target?.type === 'checkbox') return e.target.checked;
        return e?.target?.value;
    }

    isIdLike(str) {
        return !!str && /^[a-zA-Z0-9]{15,18}$/.test(str);
    }

    maybeAutoPopulateName(row) {
        const shouldAutofill = !row.name || this.isIdLike(row.name);
        if (!shouldAutofill) return;

        const isScheduled = row.configurationType === 'Scheduled Job';
        const isTrigger =
            row.configurationType === 'On Record Create' ||
            row.configurationType === 'On Record Update' ||
            row.configurationType === 'On Record Create and Update';

        if (isScheduled) {
            if (row.campaignName) row.name = row.campaignName;
        } else if (isTrigger) {
            if (row.campaignName) row.name = row.campaignName;
        }
    }

    async loadAll() {
        this.errorMsg = null;
        try {
            const [cfgs, camps] = await Promise.all([
                getConfigurations(),
                getCampaignOptions()
            ]);

            this.campaignOptions = camps.map(o => ({ label: o.label, value: o.value }));

            this.rows = cfgs.map(r => this.toUiRow(r));

            // Load field metadata for rows that already have an object selected
            await Promise.all(
                this.rows.map((row, idx) => {
                    if (row._triggerSObject) {
                        return this.loadFieldOptions(idx, row._triggerSObject, true);
                    }
                    return null;
                })
            );

            // Load child field metadata for rows that already have children selected
            await Promise.all(
                this.rows.map((row, idx) => {
                    if (row._children?.length) {
                        return Promise.all(
                            row._children.map(async (ch, childIdx) => {
                                if (ch.sObject) {
                                    await this.loadChildFieldOptions(idx, childIdx, ch.sObject, true);
                                }
                                return null;
                            })
                        );
                    }
                    return null;
                })
            );

            this.recomputeAll();
        } catch (e) {
            this.errorMsg = this.normalizeError(e);
        }
    }

    /* ===================== UI ROW MODEL ===================== */

    parseConditionsFromBlock(recordId, keyPrefix, block) {
        const conds = (block?.conditions || []).map((c, i) => {
            let dateValue = '';
            let timeValue = '';

            if ((c.fieldType || '').toUpperCase() === 'DATETIME' && c.fieldValue) {
                const parts = this.fromUtcToGmt5Parts(c.fieldValue);
                dateValue = parts.date;
                timeValue = parts.time;
            }

            return {
                _key: `${recordId}-${keyPrefix}-c-${i}`,
                logicNumber: parseInt(c.fieldLogicNumber, 10),
                fieldAPI: c.fieldAPI || '',
                fieldType: c.fieldType || '',
                fieldOperator: c.fieldOperator || '',
                fieldValue: c.fieldValue,
                _dateValue: dateValue,
                _timeValue: timeValue,
                _boolValue:
                    (c.fieldType || '').toUpperCase() === 'BOOLEAN'
                        ? Boolean(c.fieldValue)
                        : null,
                _multiValues: Array.isArray(c.fieldValue) ? c.fieldValue : []
            };
        });

        return conds.length ? conds : [this.newCondition(1)];
    }

    toUiRow(r) {
        const type = r.Configuration_Type__c || '';
        const isScheduled = type === 'Scheduled Job';
        const isTriggerBased =
            type === 'On Record Create' ||
            type === 'On Record Update' ||
            type === 'On Record Create and Update';

        let parsed = null;

        // Parent
        let triggerObj = null;
        let logic = '';
        let conds = [this.newCondition(1)];

        // Children
        let childrenUi = [];

        if (r.Trigger_Condition__c) {
            try {
                parsed = JSON.parse(r.Trigger_Condition__c);

                // V2 shape: { version: 2, parent: { sObject, logic, conditions }, children: [...] }
                if (parsed && parsed.version === 2 && parsed.parent) {
                    triggerObj = parsed.parent.sObject || null;
                    logic = parsed.parent.logic || '';
                    conds = this.parseConditionsFromBlock(r.Id, 'p', parsed.parent);

                    const children = Array.isArray(parsed.children) ? parsed.children : [];
                    childrenUi = children.map((ch, i) => {
                        const childBlock = ch || {};
                        const childConds = this.parseConditionsFromBlock(r.Id, `ch${i}`, childBlock);
                        return {
                            _key: `${r.Id}-child-${i}`,
                            index: i + 1,
                            sObject: childBlock.sObject || null,
                            relationshipCondition: childBlock.relationshipCondition || 'HAVING',
                            parentFieldOnChild: childBlock.parentFieldOnChild || null,
                            _conditions: childConds,
                            _logic: childBlock.logic || '1',
                            _fieldOptions: [],
                            _fieldMetaMap: {}
                        };
                    });
                } else {
                    // V1 fallback: { sObject, logic, conditions }
                    triggerObj = parsed.sObject || null;
                    logic = parsed.logic || '';
                    conds = this.parseConditionsFromBlock(r.Id, 'p', parsed);
                    childrenUi = [];
                }
            } catch {
                // ignore invalid JSON
            }
        }

        const ui = {
            _key: r.Id,
            id: r.Id,

            _openSections: [],
            _isNew: false,


            createdDate: r.CreatedDate,
            active: r.Active__c === true,

            name: r.Name || '',

            configurationType: type,
            campaignId: r.Campaign__c || null,
            campaignName: r.Campaign_Name__c || '',

            _campaignUrl: r.Campaign__c
    ? `/lightning/r/Campaign/${r.Campaign__c}/view`
    : null,

            runFrequency: r.Run_Frequency__c || '',

            _triggerSObject: triggerObj,
            _conditions: conds,
            _logic: logic,
            _fieldOptions: [],
            _fieldMetaMap: {},
            _childObjectOptions: [], //REQUIRED so combobox can bind value

            // FIX: use parsed children UI objects (not raw JSON)
            _children: childrenUi,
            _showAddChild: false,

            _rowMsg: '',
            _rowMsgClass: 'slds-text-body_small slds-m-top_x-small',
            _saveDisabled: true,

            _isScheduled: isScheduled,
            _isTriggerBased: isTriggerBased,
            _usesFilterBuilder: isScheduled || isTriggerBased,

            _title: r.Id ? r.Id : 'New',
            _createdDateLabel: r.CreatedDate ? new Date(r.CreatedDate).toLocaleString() : '-'
        };

        this.maybeAutoPopulateName(ui);

        // enrich after metadata (parent)
        ui._conditions = ui._conditions.map(c => this.enrichCondition(ui, c));

        // ✅ FIX: preload child object options so existing child combobox can resolve value
if (ui._triggerSObject && ui._children.length) {
    getChildObjects({ parentSObjectApiName: ui._triggerSObject })
        .then(childDtos => {
            ui._childObjectOptions = childDtos.map(d => ({
                label: d.label,
                value: d.value,
                parentFieldOnChild: d.parentFieldOnChild
            }));
        })
        .catch(() => {
            ui._childObjectOptions = [];
        });
}


        // initial show/hide child button
        ui._showAddChild =
            ui._usesFilterBuilder === true &&
            !!ui._triggerSObject &&
            (ui._children?.length || 0) < 2;

        return ui;
    }

removeChildCondition(e) {
    const idx = Number(e.target.dataset.idx);
    const childIdx = Number(e.target.dataset.childIdx);
    const cidx = Number(e.target.dataset.cidx);

    const child = this.rows[idx]._children[childIdx];

    child._conditions.splice(cidx, 1);

    // re-number logic
    child._conditions = child._conditions.map((c, i) => ({
        ...c,
        logicNumber: i + 1,
        _key: `${c._key}-${i}`
    }));

    this.recomputeRow(idx);
    this.rows = [...this.rows];
}

removeChildObject(e) {
    const idx = Number(e.target.dataset.idx);
    const childIdx = Number(e.target.dataset.childIdx);

    const row = this.rows[idx];

    row._children.splice(childIdx, 1);

    // re-index children
    row._children = row._children.map((ch, i) => ({
        ...ch,
        index: i + 1
    }));

    row._showAddChild = row._children.length < 2;

    this.recomputeRow(idx);
    this.rows = [...this.rows];
}



    newBlankRow() {
        return {
            _key: `tmp-${Date.now()}`,
            id: null,

            _isNew: true,
            _openSections: ['basics'],


            createdDate: null,
            active: true,

            name: '',

            configurationType: '',
            campaignId: null,
            campaignName: '',
            _campaignUrl: null,

            runFrequency: '',

            _triggerSObject: null,
            _conditions: [this.newCondition(1)],
            _logic: '',
            _fieldOptions: [],
            _fieldMetaMap: {},

            _children: [],
            _showAddChild: false,

            _rowMsg: '',
            _rowMsgClass: 'slds-text-body_small slds-m-top_x-small',
            _saveDisabled: true,

            _isScheduled: false,
            _isTriggerBased: false,
            _usesFilterBuilder: false,

            _title: 'New',
            _createdDateLabel: '-'
        };
    }

    newCondition(n) {
        return this.enrichCondition(
            null,
            {
                _key: `cond-${Date.now()}-${n}`,
                logicNumber: n,
                fieldAPI: '',
                fieldType: '',
                fieldOperator: '',
                fieldValue: '',
                _boolValue: null,
                _multiValues: [],
                _dateValue: '',
                _timeValue: ''
            }
        );
    }

    onConditionDateChange = (e) => {
        const idx = parseInt(e.target.dataset.idx, 10);
        const cidx = parseInt(e.target.dataset.cidx, 10);

        this.rows[idx]._conditions[cidx]._dateValue = e.detail.value;
        this.recomputeRow(idx);
        this.rows = [...this.rows];
    };

    onConditionTimeChange = (e) => {
        const idx = parseInt(e.target.dataset.idx, 10);
        const cidx = parseInt(e.target.dataset.cidx, 10);
        const val = this.extractValue(e);

        const TIME_REGEX = /^([01]\d|2[0-3]):[0-5]\d$/;

        if (val && !TIME_REGEX.test(val)) {
            e.target.setCustomValidity('Time must be in HH:mm format (00:00–23:59)');
            e.target.reportValidity();
            return;
        }

        e.target.setCustomValidity('');

        const cond = this.rows[idx]._conditions[cidx];
        cond._timeValue = val;

        this.recomputeRow(idx);
        this.rows = [...this.rows];
    };

    /* ===================== CONDITION ENRICHMENT ===================== */

    operatorOptionsForType(fieldType) {
        const t = (fieldType || '').toUpperCase();

        if (t === 'MULTIPICKLIST') {
            return [
                { label: 'includes', value: 'includes' },
                { label: 'excludes', value: 'excludes' }
            ];
        }

        if (t === 'BOOLEAN') {
            return [
                { label: 'equal', value: 'equal' },
                { label: 'not_equal', value: 'not_equal' }
            ];
        }

        if (t === 'REFERENCE') {
            return [
                { label: 'equal', value: 'equal' },
                { label: 'not_equal', value: 'not_equal' },
                { label: 'is null', value: 'is_null' },
                { label: 'is not null', value: 'is_not_null' }
            ];
        }

        if (['DATE', 'DATETIME', 'INTEGER', 'DOUBLE', 'CURRENCY', 'PERCENT'].includes(t)) {
            return [
                { label: 'equal', value: 'equal' },
                { label: 'not_equal', value: 'not_equal' },
                { label: 'greater_than', value: 'greater_than' },
                { label: 'less_than', value: 'less_than' },
                { label: 'greater_or_equal', value: 'greater_or_equal' },
                { label: 'less_or_equal', value: 'less_or_equal' },
                { label: 'is null', value: 'is_null' },
                { label: 'is not null', value: 'is_not_null' }
            ];
        }

        if (t === 'PICKLIST') {
            return [
                { label: 'equal', value: 'equal' },
                { label: 'not_equal', value: 'not_equal' },
                { label: 'is null', value: 'is_null' },
                { label: 'is not null', value: 'is_not_null' }
            ];
        }

        return [
            { label: 'equal', value: 'equal' },
            { label: 'not_equal', value: 'not_equal' },
            { label: 'contains', value: 'contains' },
            { label: 'not_contains', value: 'not_contains' },
            { label: 'starts_with', value: 'starts_with' },
            { label: 'ends_with', value: 'ends_with' },
            { label: 'is null', value: 'is_null' },
            { label: 'is not null', value: 'is_not_null' }
        ];
    }

    enrichCondition(row, cond) {
        const meta = row?._fieldMetaMap?.[cond.fieldAPI];

        const fieldType = (meta?.dataType || cond.fieldType || '').toUpperCase();
        const isBoolean = fieldType === 'BOOLEAN';
        const isPicklist = fieldType === 'PICKLIST';
        const isMultiPicklist = fieldType === 'MULTIPICKLIST';
        const isDate = fieldType === 'DATE';
        const isDateTime = fieldType === 'DATETIME';
        const isNumber = ['INTEGER', 'DOUBLE', 'CURRENCY', 'PERCENT'].includes(fieldType);
        const isNullOp = ['is_null', 'is_not_null'].includes(cond.fieldOperator);
        const isReference = fieldType === 'REFERENCE';

        const operatorOptions = this.operatorOptionsForType(fieldType);

        const picklistOptions = (meta?.picklistValues || []).map(v => ({
            label: v.label,
            value: v.value
        }));

        let fieldValue = cond.fieldValue;
        let boolValue = cond._boolValue;
        let multiValues = cond._multiValues || [];
        let dateValue = cond._dateValue || '';
        let timeValue = cond._timeValue || '';

        if (isBoolean) {
            if (typeof fieldValue === 'boolean') boolValue = fieldValue;
            if (boolValue === null || boolValue === undefined) boolValue = null;
        } else if (isMultiPicklist) {
            if (Array.isArray(fieldValue)) multiValues = fieldValue;
            if (!Array.isArray(multiValues)) multiValues = [];
        } else {
            if (fieldValue === null || fieldValue === undefined) fieldValue = '';
        }

        let op = cond.fieldOperator || '';
        if (op && !operatorOptions.some(o => o.value === op)) {
            op = '';
        }
        if (!op && operatorOptions.length) op = operatorOptions[0].value;

        return {
            ...cond,
            fieldType,
            fieldOperator: op,
            _operatorOptions: operatorOptions,
            _picklistOptions: picklistOptions,

            _isBoolean: isBoolean,
            _isPicklist: isPicklist,
            _isMultiPicklist: isMultiPicklist,
            _isDate: isDate,
            _isDateTime: isDateTime,
            _isNumber: isNumber,
            _isReference: isReference,
            _dateValue: dateValue,
            _timeValue: timeValue,

            _isText: !(isBoolean || isPicklist || isMultiPicklist || isDate || isDateTime || isNumber || isReference),

            _isNullOperator: isNullOp,
            _hideValue: isNullOp,

            _boolValue: boolValue,
            _multiValues: multiValues,
            fieldValue: isNullOp ? null : fieldValue
        };
    }

    /* ===================== EVENTS ===================== */

    addBlankRow = () => {
        this.rows = [this.newBlankRow(), ...this.rows];
        this.recomputeAll();
    };

    onFieldChange = (e) => {
        const idx = parseInt(e.target.dataset.idx, 10);
        const field = e.target.dataset.field;
        if (!field) return;

        this.rows[idx][field] = this.extractValue(e);

        this.maybeAutoPopulateName(this.rows[idx]);
        this.recomputeRow(idx);
        this.rows = [...this.rows];
    };

    onConfigTypeChange = (e) => {
        const idx = parseInt(e.target.dataset.idx, 10);
        const val = this.extractValue(e);
        const row = this.rows[idx];

        row.configurationType = val || '';
        row._isScheduled = row.configurationType === 'Scheduled Job';
        row._isTriggerBased =
            row.configurationType === 'On Record Create' ||
            row.configurationType === 'On Record Update' ||
            row.configurationType === 'On Record Create and Update';

        row._usesFilterBuilder = row._isScheduled || row._isTriggerBased;

        if (!row._usesFilterBuilder) {
            row._triggerSObject = null;
            row._conditions = [this.newCondition(1)];
            row._logic = '';
            row._fieldOptions = [];
            row._fieldMetaMap = {};
            row._children = [];
            row._showAddChild = false;
        }

        if (!row._isScheduled) {
            row.runFrequency = '';
        }

        this.maybeAutoPopulateName(row);
        this.recomputeRow(idx);
        this.rows = [...this.rows];
    };

    /*onCampaignChange = (e) => {
        const idx = parseInt(e.target.dataset.idx, 10);
        const id = this.extractValue(e);

        const opt = this.campaignOptions.find(o => o.value === id);
        this.rows[idx].campaignId = id;
        this.rows[idx].campaignName = opt ? opt.label : '';

        this.maybeAutoPopulateName(this.rows[idx]);
        this.recomputeRow(idx);
        this.rows = [...this.rows];
    };*/

    onCampaignChange = (e) => {
    const idx = parseInt(e.target.dataset.idx, 10);
    const id = this.extractValue(e);

    const opt = this.campaignOptions.find(o => o.value === id);

    const row = this.rows[idx];
    row.campaignId = id;
    row.campaignName = opt ? opt.label : '';

    // ✅ ADD THIS (this is the fix)
    row._campaignUrl = id
        ? `/lightning/r/Campaign/${id}/view`
        : null;

    this.maybeAutoPopulateName(row);
    this.recomputeRow(idx);
    this.rows = [...this.rows];
};


    /*onTriggerObjectChange = async (e) => {
    const idx = parseInt(e.target.dataset.idx, 10);
    const sObj = this.extractValue(e);

    const row = this.rows[idx];
    row._triggerSObject = sObj;

    // Load parent field metadata
    await this.loadFieldOptions(idx, sObj, false);

    // Reset parent conditions
    row._conditions = [this.newCondition(1)];
    row._logic = '1';

    // 🔹 LOAD CHILD OBJECT OPTIONS DYNAMICALLY
    try {
        const childObjects = await getChildObjects({ parentSObject: sObj });
        row._childObjectOptions = childObjects.map(o => ({
            label: o,
            value: o
        }));
    } catch (err) {
        row._childObjectOptions = [];
        row._rowMsg = this.normalizeError(err);
        row._rowMsgClass = 'slds-text-color_error slds-text-body_small';
    }

    // Reset children
    row._children = [];
    row._showAddChild =
        row._usesFilterBuilder === true &&
        !!row._triggerSObject;

    this.maybeAutoPopulateName(row);
    this.recomputeRow(idx);
    this.rows = [...this.rows];
};*/

onTriggerObjectChange = async (e) => {
    const idx = parseInt(e.target.dataset.idx, 10);
    const sObj = this.extractValue(e);

    const row = this.rows[idx];
    row._triggerSObject = sObj;

    // Load parent field metadata
    await this.loadFieldOptions(idx, sObj, false);

    // Reset parent conditions
    row._conditions = [this.newCondition(1)];
    row._logic = '1';

    // ✅ FIX: correct Apex param + correct DTO handling
    try {
        const childDtos = await getChildObjects({
            parentSObjectApiName: sObj
        });

        // Store full DTOs (label, value, parentFieldOnChild)
        row._childObjectOptions = childDtos.map(d => ({
            label: d.label,
            value: d.value,
            parentFieldOnChild: d.parentFieldOnChild
        }));
    } catch (err) {
        row._childObjectOptions = [];
        row._rowMsg = this.normalizeError(err);
        row._rowMsgClass = 'slds-text-color_error slds-text-body_small';
    }

    // Reset children
    row._children = [];
    row._showAddChild =
        row._usesFilterBuilder === true &&
        !!row._triggerSObject;

    this.maybeAutoPopulateName(row);
    this.recomputeRow(idx);
    this.rows = [...this.rows];
};



    async loadFieldOptions(idx, sObj, enrichExisting) {
        try {
            const opts = await getTriggerFieldOptions({ sObjectApiName: sObj });

            const row = this.rows[idx];
            row._fieldOptions = opts.map(o => ({
                label: o.label,
                value: o.value
            }));

            const metaMap = {};
            opts.forEach(o => {
                metaMap[o.value] = {
                    dataType: (o.dataType || '').toUpperCase(),
                    picklistValues: o.picklistValues || [],
                    referenceTo: o.referenceTo || null
                };
            });
            row._fieldMetaMap = metaMap;

            if (enrichExisting && row._conditions?.length) {
                row._conditions = row._conditions.map(c => this.enrichCondition(row, c));
            }
        } catch (e) {
            this.rows[idx]._fieldOptions = [];
            this.rows[idx]._fieldMetaMap = {};
            this.rows[idx]._rowMsg = this.normalizeError(e);
            this.rows[idx]._rowMsgClass = 'slds-text-color_error slds-text-body_small';
        }
    }

    async loadChildFieldOptions(idx, childIdx, sObj, enrichExisting) {
        const row = this.rows[idx];
        const child = row._children[childIdx];
        try {
            const opts = await getTriggerFieldOptions({ sObjectApiName: sObj });

            child._fieldOptions = opts.map(o => ({
                label: o.label,
                value: o.value
            }));

            const metaMap = {};
            opts.forEach(o => {
                metaMap[o.value] = {
                    dataType: (o.dataType || '').toUpperCase(),
                    picklistValues: o.picklistValues || [],
                    referenceTo: o.referenceTo || null
                };
            });
            child._fieldMetaMap = metaMap;

            if (enrichExisting && child._conditions?.length) {
                child._conditions = child._conditions.map(c => this.enrichCondition({ _fieldMetaMap: child._fieldMetaMap }, c));
            }
        } catch (e) {
            child._fieldOptions = [];
            child._fieldMetaMap = {};
        }
    }

    addCondition = (e) => {
        const idx = parseInt(e.target.dataset.idx, 10);
        const row = this.rows[idx];
        const n = row._conditions.length + 1;

        row._conditions = [...row._conditions, this.newCondition(n)];
        if (!row._logic) {
            row._logic = row._conditions.map(c => c.logicNumber).join(' AND ');
        }

        this.recomputeRow(idx);
        this.rows = [...this.rows];
    };

    removeCondition = (e) => {
        const idx = parseInt(e.target.dataset.idx, 10);
        const cidx = parseInt(e.target.dataset.cidx, 10);
        const row = this.rows[idx];

        row._conditions.splice(cidx, 1);
        row._conditions = row._conditions.map((c, i) => ({
            ...c,
            logicNumber: i + 1,
            _key: `${c._key}-${i}`
        }));

        this.recomputeRow(idx);
        this.rows = [...this.rows];
    };

    onConditionFieldChange = (e) => {
        const idx = parseInt(e.target.dataset.idx, 10);
        const cidx = parseInt(e.target.dataset.cidx, 10);
        const fieldAPI = this.extractValue(e);

        const row = this.rows[idx];
        const cond = row._conditions[cidx];

        const next = {
            ...cond,
            fieldAPI,
            fieldOperator: '',
            fieldValue: '',
            _boolValue: null,
            _multiValues: [],
            _dateValue: '',
            _timeValue: ''
        };

        row._conditions[cidx] = this.enrichCondition(row, next);

        this.recomputeRow(idx);
        this.rows = [...this.rows];
    };

    onConditionOperatorChange = (e) => {
        const idx = parseInt(e.target.dataset.idx, 10);
        const cidx = parseInt(e.target.dataset.cidx, 10);
        const op = this.extractValue(e);

        const row = this.rows[idx];
        const cond = row._conditions[cidx];

        const updated = {
            ...cond,
            fieldOperator: op
        };

        row._conditions[cidx] = this.enrichCondition(row, updated);

        this.recomputeRow(idx);
        this.rows = [...this.rows];
    };

    onConditionValueChange = (e) => {
        const idx = parseInt(e.target.dataset.idx, 10);
        const cidx = parseInt(e.target.dataset.cidx, 10);
        const val = this.extractValue(e);

        this.rows[idx]._conditions[cidx].fieldValue = val;

        this.recomputeRow(idx);
        this.rows = [...this.rows];
    };

    onConditionBooleanChange = (e) => {
        const idx = parseInt(e.target.dataset.idx, 10);
        const cidx = parseInt(e.target.dataset.cidx, 10);
        const checked = this.extractValue(e);

        const cond = this.rows[idx]._conditions[cidx];
        cond._boolValue = checked;
        cond.fieldValue = checked;

        this.recomputeRow(idx);
        this.rows = [...this.rows];
    };

    onConditionMultiPicklistChange = (e) => {
        const idx = parseInt(e.target.dataset.idx, 10);
        const cidx = parseInt(e.target.dataset.cidx, 10);
        const selected = this.extractValue(e) || [];

        const cond = this.rows[idx]._conditions[cidx];
        cond._multiValues = selected;
        cond.fieldValue = selected;

        this.recomputeRow(idx);
        this.rows = [...this.rows];
    };

    onLogicChange = (e) => {
        const idx = parseInt(e.target.dataset.idx, 10);
        this.rows[idx]._logic = e.target.value;

        this.recomputeRow(idx);
        this.rows = [...this.rows];
    };

    /* ===================== CHILD OBJECTS ===================== */

    /*addChildObject(e) {
        const idx = Number(e.target.dataset.idx);
        const row = this.rows[idx];

        if (!row._children) row._children = [];
        if (row._children.length >= 2) return;

        row._children.push({
            _key: Date.now() + '-' + Math.random(),
            index: row._children.length + 1,
            sObject: null,
            relationshipCondition: 'HAVING',
            parentFieldOnChild: null,
            _conditions: [this.newCondition(1)],
            _logic: '1',
            _fieldOptions: [],
            _fieldMetaMap: {}
        });

        row._showAddChild = row._children.length < 2;
        this.recomputeRow(idx);
        this.rows = [...this.rows];
    }*/
   async addChildObject(e) {
    const idx = Number(e.target.dataset.idx);
    const row = this.rows[idx];

    if (!row._children) row._children = [];
    if (row._children.length >= 2) return;

    // 🔥 FIX: ensure child object options are loaded
    if (
        row._triggerSObject &&
        (!row._childObjectOptions || row._childObjectOptions.length === 0)
    ) {
        try {
            const childDtos = await getChildObjects({
                parentSObjectApiName: row._triggerSObject
            });

            row._childObjectOptions = childDtos.map(d => ({
                label: d.label,
                value: d.value,
                parentFieldOnChild: d.parentFieldOnChild
            }));
        } catch (err) {
            row._childObjectOptions = [];
            row._rowMsg = this.normalizeError(err);
            row._rowMsgClass = 'slds-text-color_error slds-text-body_small';
        }
    }

    // Add child block
    row._children.push({
        _key: Date.now() + '-' + Math.random(),
        index: row._children.length + 1,
        sObject: null,
        relationshipCondition: 'HAVING',
        parentFieldOnChild: null,
        _conditions: [this.newCondition(1)],
        _logic: '1',
        _fieldOptions: [],
        _fieldMetaMap: {}
    });

    row._showAddChild = row._children.length < 2;

    this.recomputeRow(idx);
    this.rows = [...this.rows];
}


    async onChildObjectChange(e) {
        const idx = Number(e.target.dataset.idx);
        const childIdx = Number(e.target.dataset.childIdx);
        const sObj = this.extractValue(e);

        const child = this.rows[idx]._children[childIdx];
        child.sObject = sObj;

        await this.loadChildFieldOptions(idx, childIdx, sObj, false);

        child._conditions = [this.newCondition(1)];
        child._logic = '1';

        this.recomputeRow(idx);
        this.rows = [...this.rows];
    }

    onParentChildConditionChange(e) {
        const idx = Number(e.target.dataset.idx);
        const childIdx = Number(e.target.dataset.childIdx);
        this.rows[idx]._children[childIdx].relationshipCondition = this.extractValue(e);
        this.recomputeRow(idx);
        this.rows = [...this.rows];
    }

    addChildCondition(e) {
        const idx = Number(e.target.dataset.idx);
        const childIdx = Number(e.target.dataset.childIdx);
        const child = this.rows[idx]._children[childIdx];

        const n = child._conditions.length + 1;
        child._conditions = [...child._conditions, this.newCondition(n)];

        if (!child._logic) {
            child._logic = child._conditions.map(c => c.logicNumber).join(' AND ');
        }

        this.recomputeRow(idx);
        this.rows = [...this.rows];
    }

    onChildConditionFieldChange(e) {
        const idx = Number(e.target.dataset.idx);
        const childIdx = Number(e.target.dataset.childIdx);
        const cidx = Number(e.target.dataset.cidx);
        const fieldAPI = this.extractValue(e);

        const child = this.rows[idx]._children[childIdx];
        const cond = child._conditions[cidx];

        child._conditions[cidx] = this.enrichCondition(
            { _fieldMetaMap: child._fieldMetaMap },
            { ...cond, fieldAPI, fieldOperator: '', fieldValue: '', _dateValue: '', _timeValue: '' }
        );

        this.recomputeRow(idx);
        this.rows = [...this.rows];
    }

    onChildConditionOperatorChange(e) {
        const idx = Number(e.target.dataset.idx);
        const childIdx = Number(e.target.dataset.childIdx);
        const cidx = Number(e.target.dataset.cidx);

        const child = this.rows[idx]._children[childIdx];
        const cond = child._conditions[cidx];

        child._conditions[cidx] = this.enrichCondition(
            { _fieldMetaMap: child._fieldMetaMap },
            { ...cond, fieldOperator: this.extractValue(e) }
        );

        this.recomputeRow(idx);
        this.rows = [...this.rows];
    }

    onChildConditionValueChange(e) {
        const idx = Number(e.target.dataset.idx);
        const childIdx = Number(e.target.dataset.childIdx);
        const cidx = Number(e.target.dataset.cidx);

        this.rows[idx]._children[childIdx]._conditions[cidx].fieldValue = this.extractValue(e);

        this.recomputeRow(idx);
        this.rows = [...this.rows];
    }

    onChildLogicChange(e) {
        const idx = Number(e.target.dataset.idx);
        const childIdx = Number(e.target.dataset.childIdx);

        this.rows[idx]._children[childIdx]._logic = e.target.value;

        this.recomputeRow(idx);
        this.rows = [...this.rows];
    }

    /* ===================== SAVE ===================== */

    /*saveRow = async (e) => {
        const idx = parseInt(e.target.dataset.idx, 10);
        const row = this.rows[idx];
        row._rowMsg = '';

        try {
            this.maybeAutoPopulateName(row);

            const req = this.buildSaveRequest(row);
            await saveConfiguration({ req });
            //await this.loadAll();
            window.location.reload();
        } catch (err) {
            row._rowMsg = this.normalizeError(err);
            row._rowMsgClass = 'slds-text-color_error slds-text-body_small';
            this.rows = [...this.rows];
        }
    };*/
    saveRow = async (e) => {
    const idx = parseInt(e.target.dataset.idx, 10);
    const row = this.rows[idx];
    row._rowMsg = '';

    try {
        // 🔒 LOCK UI
        this.isSaving = true;

        this.maybeAutoPopulateName(row);

        const req = this.buildSaveRequest(row);
        await saveConfiguration({ req });

        // full refresh (keeps your current behavior)
        window.location.reload();
    } catch (err) {
        row._rowMsg = this.normalizeError(err);
        row._rowMsgClass = 'slds-text-color_error slds-text-body_small';

        // 🔓 UNLOCK UI if error
        this.isSaving = false;

        this.rows = [...this.rows];
    }
};


    /* ===================== JSON BUILD ===================== */

    buildConditionPayload(c) {
        let value = null;

        if (!['is_null', 'is_not_null'].includes(c.fieldOperator)) {
            if (c._isDateTime && c._dateValue && c._timeValue) {
                value = this.toUtcSalesforceDateTime(c._dateValue, c._timeValue);
            } else if (c._isMultiPicklist) {
                value = Array.isArray(c._multiValues) ? c._multiValues : [];
            } else if (c._isBoolean) {
                value = c._boolValue === true;
            } else {
                value = c.fieldValue;
            }
        }

        return {
            fieldAPI: c.fieldAPI,
            fieldType: c.fieldType,
            fieldOperator: c.fieldOperator,
            fieldValue: value,
            fieldLogicNumber: String(c.logicNumber)
        };
    }

    buildSaveRequest(row) {
        const isScheduled = row.configurationType === 'Scheduled Job';
        const isTrigger =
            row.configurationType === 'On Record Create' ||
            row.configurationType === 'On Record Update' ||
            row.configurationType === 'On Record Create and Update';

        const usesFilter = isScheduled || isTrigger;

        const parent = usesFilter ? {
            sObject: row._triggerSObject,
            logic: row._logic,
            conditions: row._conditions.map(c => this.buildConditionPayload(c))
        } : null;

        const children = (row._children || []).map(ch => ({
            sObject: ch.sObject,
            relationshipCondition: ch.relationshipCondition,
            parentFieldOnChild: ch.parentFieldOnChild || null,
            logic: ch._logic,
            conditions: (ch._conditions || []).map(c => this.buildConditionPayload(c))
        }));

        return {
            id: row.id,
            active: row.active,
            name: row.name,
            configurationType: row.configurationType,
            campaignId: row.campaignId,
            campaignName: row.campaignName,
            runFrequency: isScheduled ? row.runFrequency : null,
            triggerConditionJson: usesFilter ? JSON.stringify({
                version: 2,
                parent,
                children
            }) : null
        };
    }

    /* ===================== VALIDATION ===================== */

    recomputeAll() {
        this.rows.forEach((_, i) => this.recomputeRow(i));
        this.rows = [...this.rows];
    }

    isConditionComplete(c) {
        if (!c.fieldAPI || !c.fieldOperator) return false;

        if (['is_null', 'is_not_null'].includes(c.fieldOperator)) return true;

        if (c._isBoolean) {
            return c._boolValue === true || c._boolValue === false;
        }
        if (c._isMultiPicklist) {
            return Array.isArray(c._multiValues) && c._multiValues.length > 0;
        }
        if (c._isDateTime) {
            return !!c._dateValue && !!c._timeValue;
        }
        return String(c.fieldValue ?? '').trim() !== '';
    }

    recomputeRow(i) {
        const r = this.rows[i];

        const usesFilter = r._usesFilterBuilder === true;

        let ok =
            !!r.name &&
            !!r.configurationType &&
            !!r.campaignId &&
            !!r.campaignName;

        if (r._isScheduled) {
            ok = ok && !!r.runFrequency;
        }

        if (usesFilter) {
            ok =
                ok &&
                !!r._triggerSObject &&
                !!r._logic &&
                r._conditions.length > 0 &&
                r._conditions.every(c => this.isConditionComplete(c));
        }

        // child button visibility (THIS FIXES YOUR UI ISSUE)
        const childCount = r._children ? r._children.length : 0;
        r._showAddChild = usesFilter && !!r._triggerSObject && childCount < 2;

        r._saveDisabled = !ok;
        r._title = r.id ? r.id : 'New';
        r._createdDateLabel = r.createdDate ? new Date(r.createdDate).toLocaleString() : '-';
    }

    normalizeError(e) {
        if (e?.body?.message) return e.body.message;
        if (e?.message) return e.message;
        return 'Unknown error';
    }

    /* ===================== DATETIME HELPERS ===================== */

    toUtcSalesforceDateTime(dateValue, timeValue) {
        if (!dateValue || !timeValue) {
            return null;
        }

        const [year, month, day] = dateValue.split('-').map(Number);
        const [hour, minute] = timeValue.split(':').map(Number);

        // Convert GMT-5 → UTC by ADDING 5 hours
        let utcHour = hour + 5;
        let utcDay = day;
        let utcMonth = month;
        let utcYear = year;

        if (utcHour >= 24) {
            utcHour -= 24;
            utcDay += 1;

            const daysInMonth = new Date(year, month, 0).getDate();
            if (utcDay > daysInMonth) {
                utcDay = 1;
                utcMonth += 1;
                if (utcMonth > 12) {
                    utcMonth = 1;
                    utcYear += 1;
                }
            }
        }

        const yyyy = String(utcYear);
        const mm = String(utcMonth).padStart(2, '0');
        const dd = String(utcDay).padStart(2, '0');
        const hh = String(utcHour).padStart(2, '0');
        const mi = String(minute).padStart(2, '0');

        return `${yyyy}-${mm}-${dd} ${hh}:${mi}:00`;
    }

    fromUtcToGmt5Parts(utcValue) {
        const iso = String(utcValue).replace('+0000', 'Z');
        const utc = new Date(iso);

        utc.setHours(utc.getHours() - 5);

        const yyyy = utc.getFullYear();
        const MM = String(utc.getMonth() + 1).padStart(2, '0');
        const dd = String(utc.getDate()).padStart(2, '0');
        const HH = String(utc.getHours()).padStart(2, '0');
        const mi = String(utc.getMinutes()).padStart(2, '0');

        return {
            date: `${yyyy}-${MM}-${dd}`,
            time: `${HH}:${mi}`
        };
    }

    onChildConditionBooleanChange = (e) => {
    const idx = Number(e.target.dataset.idx);
    const childIdx = Number(e.target.dataset.childIdx);
    const cidx = Number(e.target.dataset.cidx);
    const checked = this.extractValue(e);

    const cond = this.rows[idx]._children[childIdx]._conditions[cidx];
    cond._boolValue = checked;
    cond.fieldValue = checked;

    this.recomputeRow(idx);
    this.rows = [...this.rows];
};

onChildConditionMultiPicklistChange = (e) => {
    const idx = Number(e.target.dataset.idx);
    const childIdx = Number(e.target.dataset.childIdx);
    const cidx = Number(e.target.dataset.cidx);
    const selected = this.extractValue(e) || [];

    const cond = this.rows[idx]._children[childIdx]._conditions[cidx];
    cond._multiValues = selected;
    cond.fieldValue = selected;

    this.recomputeRow(idx);
    this.rows = [...this.rows];
};

onChildConditionDateChange = (e) => {
    const idx = Number(e.target.dataset.idx);
    const childIdx = Number(e.target.dataset.childIdx);
    const cidx = Number(e.target.dataset.cidx);

    this.rows[idx]._children[childIdx]._conditions[cidx]._dateValue = e.detail.value;

    this.recomputeRow(idx);
    this.rows = [...this.rows];
};

onChildConditionTimeChange = (e) => {
    const idx = Number(e.target.dataset.idx);
    const childIdx = Number(e.target.dataset.childIdx);
    const cidx = Number(e.target.dataset.cidx);
    const val = this.extractValue(e);

    const TIME_REGEX = /^([01]\d|2[0-3]):[0-5]\d$/;

    if (val && !TIME_REGEX.test(val)) {
        e.target.setCustomValidity('Time must be in HH:mm format (00:00–23:59)');
        e.target.reportValidity();
        return;
    }

    e.target.setCustomValidity('');

    const cond = this.rows[idx]._children[childIdx]._conditions[cidx];
    cond._timeValue = val;

    this.recomputeRow(idx);
    this.rows = [...this.rows];
};


}