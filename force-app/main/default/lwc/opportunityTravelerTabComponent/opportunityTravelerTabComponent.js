import { LightningElement, track , api,wire} from 'lwc';
import insertData from '@salesforce/apex/OpportunityTravelerTabController.insertTravelerData';
import fetchData from '@salesforce/apex/OpportunityTravelerTabController.getTravelerData';
import { deleteRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import { RefreshEvent } from "lightning/refresh";
export default class OpportunityTravelerTabComponent extends LightningElement {
    @track displayError;
    isLoading = false;
    @api recordId;
    @track rows = [];
    @track draftValues = [];
    @track columns = [{
            label: 'First Name',
            fieldName: 'First_Name__c',
            type: 'text',
            editable: true
        },
        {
            label: 'Last Name',
            fieldName: 'Last_Name__c',
            type: 'text',
            editable: true
        },
        {
            label: 'Date of Birth',
            fieldName: 'Date_Of_Birth__c',
            type: "date-local",
            typeAttributes: {
                month: "2-digit",
                day: "2-digit"
            },
            editable: true
        },
        {
            label: 'Age',
            fieldName: 'Age__c',
            type: 'text',
            editable: true
        },
        {
            label: 'Occupation',
            fieldName: 'Occupation__c',
            type: 'text',
            editable: true
        },
        {
            label: 'Relation',
            fieldName: 'Relation__c',
            type: 'text',
            editable: true
        },
        {
            type: 'button-icon',
            fixedWidth: 50,
            typeAttributes: {
                iconName: 'utility:delete',
                name: 'delete',
                alternativeText: 'Delete'
            }
        }
    ];
    rowId = 0; // To keep track of the row ID
    @wire(fetchData, {oppId: '$recordId'})
    travelerdata({error,data}) {
        if (data) {
            this.rows = data;
            this.draftValues = data;
        } else if (error) {
            console.log('In wire error....');
            this.displayError = error;
        }
    }
    
    addRow() {
        const newRow = {
            Id: this.rowId++,
            First_Name__c: '',
            Last_Name__c: '',
            Date_Of_Birth__c: null,
            Age__c: null,
            Occupation__c: '',
            Relation__c: ''
        };
        this.rows = [...this.rows, newRow];
        console.log('>>>>>', this.rows);
        console.log('>>>>>', JSON.stringify(this.rows));
    }
    handleSave(event) {
        const updatedFields = event.detail.draftValues;
        console.log('>>>>updatedFields>>>' , updatedFields);
        // Update the rows with the changed fields
        // Ensure `updatedFields` is an array
        if (Array.isArray(updatedFields)) {
            this.rows = this.rows.map(row => {
                const updatedRow = updatedFields.find(field => field.Id == row.Id);
                console.log('>>>>' + updatedRow);
                return updatedRow ? {
                    ...row,
                    ...updatedRow
                } : row;
            });

            // Clear draft values
            this.draftValues = [];
        } else {
            console.error('Updated fields are not an array:', updatedFields);
        }
    }
    // Handle button clicks in the data table
    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        console.log('>>>>event.detail.row>>>' + event.detail.row);
        console.log('>>>>row>>>', row);
        if (actionName === 'delete') {
            this.deleteRow(row.Id);
        }
    }

    // Function to delete a row
    deleteRow(rowId) {
        console.log('>>>>rowId>>>', rowId);
        this.rows = this.rows.filter(row => row.Id !== rowId);
        this.draftValues = this.draftValues.filter(row => row.Id !== rowId);
        deleteRecord(rowId)
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Record deleted',
                        variant: 'success'
                    })
                );
            })
            .catch((error) => {
                console.log(error);
            });
    }

    handleProceed() {
          this.isLoading = true;
        insertData({
                oppId: this.recordId,
                travelerData: this.rows
            })
            .then((result) => {
                if (result != null) {
                    console.log('>>>>>>>result>>>>', result);
                    this.isLoading = false;
                    this.displayError = '';
                    let data = result;
                    this.rows = data;
                    this.draftValues = data;
                    this.updateRecordView();
                } else if (result == null) {
                    this.displayError = 'Error - Please contact your Admin';
                    this.isLoading = false;
                }
            })
            .catch((error) => {
                console.log('>>>>>>>error>>>>', error);
                this.isLoading = false;
            });
    }
    updateRecordView() {
        setTimeout(() => {
            eval("$A.get('e.force:refreshView').fire();");
        }, 500);
    }
}