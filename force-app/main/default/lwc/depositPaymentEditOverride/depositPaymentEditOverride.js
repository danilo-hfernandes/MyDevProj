import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import USER_ID from '@salesforce/user/Id';
import USER_NAME from '@salesforce/schema/User.Name';
import COST_FIELD from '@salesforce/schema/Deposit_Payment_Tracking__c.Cost__c';
import PAYMENT_OBJECT from '@salesforce/schema/Deposit_Payment_Tracking__c';

export default class DepositPaymentEditOverride extends NavigationMixin(LightningElement) {
    @api recordId;
    userName;
    cost;
    
    @wire(getRecord, { recordId: USER_ID, fields: [USER_NAME] })
    wiredUser({ error, data }) {
        if (data) {
            this.userName = getFieldValue(data, USER_NAME);
        }
    }

    @wire(getRecord, { recordId: '$recordId', fields: [COST_FIELD] })
    wiredDepositPayment({ error, data }) {
        if (data) {
            this.cost = getFieldValue(data, COST_FIELD);
        }
    }

    connectedCallback() {
        if (this.recordId && this.userName !== undefined && this.cost !== undefined) {
            this.openEditForm();
        }
    }

    openEditForm() {
        const defaultValues = {
            Paid_By__c: this.userName,
            Amount_Paid_Out__c: this.cost,
            Paid_On__c: new Date().toISOString().split('T')[0],
            Payment_Status__c: 'Paid'
        };

        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Deposit_Payment_Tracking__c',
                actionName: 'edit',
                recordId: this.recordId
            },
            state: {
                defaultFieldValues: this.encodeDefaultValues(defaultValues)
            }
        });
    }

    encodeDefaultValues(values) {
        return Object.keys(values)
            .map(field => `${field}=${encodeURIComponent(values[field])}`)
            .join('&');
    }
}