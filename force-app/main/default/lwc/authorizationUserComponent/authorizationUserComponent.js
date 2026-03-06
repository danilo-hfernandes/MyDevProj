import { LightningElement, track, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import getChildRecords from '@salesforce/apex/AuthorizedUserAPIController.getAuthorizedUserRecords'; 
import callSyncMethod from '@salesforce/apex/AuthorizedUserAPIController.getAuthorizedUser';
import saveRecord from '@salesforce/apex/AuthorizedUserAPIController.postAuthorizedUser';
import editRecord from '@salesforce/apex/AuthorizedUserAPIController.changeAuthorizedUserStatus';
export default class AuthorizationUserComponent extends LightningElement {
    @api recordId;
    @track disableAddRow = true;
    @track isModalOpen = false; // Modal visibility
    @track isEditMode = false;
    @track modalTitle = 'Add Authorized User'; // Modal title
    @track currentRecordId; // To track the record being edited
    @track data = []; // Data for the datatable
    @track firstName = '';
    @track lastName = '';
    @track email = '';
    @track emailConfirmation = '';
    @track country = '';
    @track phone = '';
    @track isEnabled = false;

    // Data table columns
    columns = [
        { label: 'First Name', fieldName: 'First_Name__c', type: 'text' },
        { label: 'Last Name', fieldName: 'Last_Name__c', type: 'text' },
        { label: 'Member Number', fieldName: 'Member_Number__c', type: 'text' },
        { label: 'Email', fieldName: 'Email__c', type: 'email' },
        { label: 'Email Confirmation', fieldName: 'Email_Confirmation__c', type: 'email' },
        { label: 'Phone', fieldName: 'Primary_Phone__c', type: 'phone' },
        { label: 'Country', fieldName: 'Country__c', type: 'text' },
        { label: 'Is Enabled', fieldName: 'IsEnabled__c', type: 'boolean' },
         {
            type: 'button',
            typeAttributes: {
                label: 'Edit',
                name: 'edit',
                variant: 'neutral'
            }
        }
    ];

    @wire(getChildRecords , { accountId: '$recordId' })
    wiredChildRecords(result) {
        this.wiredRecords = result; // Store the wire result for refreshApex
        if (result.data) {
            this.data = result.data;
            console.log(this.data);
        } else if (result.error) {
            this.showToast('Error', 'Failed to fetch records: ' + result.error.body.message, 'error');
        }
    }
     // Handle row actions (Edit)
    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;

        if (actionName === 'edit') {
            this.openEditModal(row);
        }
    }
    // Open the modal in Edit mode
    openEditModal(row) {
        this.isEditMode = true;
        this.modalTitle = 'Edit Authorized User';
        this.currentRecordId = row.Id;
        this.firstName = row.First_Name__c;
        this.lastName = row.Last_Name__c;
        this.email = row.Email__c;
        this.emailConfirmation = row.Email_Confirmation__c; // Assuming it's the same initially
        this.phone = row.Primary_Phone__c;
        this.country = row.Country__c;
        this.isEnabled = row.IsEnabled__c;
        this.isModalOpen = true;
    }
    // Open the modal in Add mode
    handleAddRowClick() {
        this.isEditMode = false;
        this.modalTitle = 'Add Authorized User';
        this.clearForm();
        this.isModalOpen = true;
    }
     // Close the modal
    closeModal() {
        this.isModalOpen = false;
        this.clearForm();
    }

    // Handle form input changes
    handleInputChange(event) {
        const field = event.target.dataset.field;
        this[field] = event.target.type === 'checkbox' ? event.target.checked : event.target.value;
    }

    // Save the new row to the data table
    handleSave() {
        if (this.email !== this.emailConfirmation) {
            this.showToast('Error', 'Email and Email Confirmation must match', 'error');
            return;
        }
        if (this.isEditMode) {
            this.updateRow();
        } else {
            this.addRow();
        }

        this.closeModal();
    }
    addRow() {
        saveRecord({accountId: this.recordId, firstName: this.firstName, lastName: this.lastName, email: this.email,emailConfirmation: this.emailConfirmation, phone: this.phone, country: this.country, isEnabled: this.isEnabled })
            .then(result => {
                console.log('>>>>'+result);
                if(result == 'Success'){
                    this.showToast('Success', result, 'success');
                    this.refreshTable();
                    this.handleSync();
                }
                else {
                    this.showToast('Information', result, 'info');
                }   
                
            })
            .catch(error => {
                this.showToast('Error', 'Error saving record: ' + error.body.message, 'error');
            });
    }

    updateRow() {
        editRecord({ authorizedUserId: this.currentRecordId, isEnabled: this.isEnabled })
            .then(result => {
                this.showToast('Success', result, 'success');
                this.refreshTable();
                this.handleSync();
            })
            .catch(error => {
                this.showToast('Error', 'Error updating record: ' + error.body.message, 'error');
            });
    }
     handleSync() {
        // Call the Apex method
        callSyncMethod({accountId : this.recordId})
            .then(result => {
                // Handle success
                console.log('Sync successful:', result);
                this.showToast('Success', 'User synced successfully', 'success');
                this.disableAddRow = false;
                return refreshApex(this.wiredRecords);
            })
            .catch(error => {
                // Handle error
                console.error('Error during sync:', error);
                this.showToast('Error', 'Sync failed', 'error');
            });
    }
    // Helper method to show a toast message
    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title,
            message,
            variant
        });
        this.dispatchEvent(event);
    }

    refreshTable() {
        refreshApex(this.wiredRecords); // Refresh table data
    }
    // Clear form data
    clearForm() {
        this.firstName = '';
        this.lastName = '';
        this.email = '';
        this.emailConfirmation = '';
        this.phone = '';
        this.country = '';
        this.isEnabled = false;
    }
}