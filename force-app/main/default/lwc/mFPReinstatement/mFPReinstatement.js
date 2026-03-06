import { LightningElement,api,wire } from 'lwc';
import validateAccount from '@salesforce/apex/MFPReinstatementController.validateAccount';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';
const FIELDS = [
    'Account.Name',
    'Account.MFP_Type__c',
    'Account.MFP_Type_tracking__c',
    'Account.MFP_Opportunity__c'
];
export default class MFPReinstatement extends NavigationMixin(LightningElement) {
@api recordId;
displayMessage;
isLoading = false;
recordData={};

get sanitizedMFPTypeTracking() {
    if (this.recordData && this.recordData.MFP_Type_tracking__c.value) {
        const doc = new DOMParser().parseFromString(this.recordData.MFP_Type_tracking__c.value, 'text/html');
        return doc.body.textContent || "";
    }
    return "";
}
@wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredRecord({ error, data }) {
        if (data) {
            this.recordData = data.fields;
        } else if (error) {
            console.error('Error loading record', error);
        }
    }
    createOpportunity(){
        console.log('Inside Create Opportunity');
        // to close modal set isModalOpen tarck value as false
        //Add your code to call apex method or do some processing
        this.displayMessage = '';
        this.isLoading = true;
        validateAccount({accId : this.recordId})
        .then((result) => {
            if(result != null){
                console.log('>>>>>>>result>>>>',result);
                this.displayMessage = result;
                if(result == 'Successful'){
                    this.updateRecordView();
                }
                this.isLoading = false;
                
            }
        })
        .catch((error) => {
            console.log('>>>>>>>error>>>>',error);
            this.isLoading = false;
            this.displayMessage = error;
        });
    }
    updateRecordView() {
        setTimeout(() => {
             eval("$A.get('e.force:refreshView').fire();");
        }, 500); 
     }
    get opportunityUrl() {
        if (this.recordData.MFP_Opportunity__c && this.recordData.MFP_Opportunity__c.value) {
            return `/lightning/r/Opportunity/${this.recordData.MFP_Opportunity__c.value}/view`;
        }
        return null;
    }
}