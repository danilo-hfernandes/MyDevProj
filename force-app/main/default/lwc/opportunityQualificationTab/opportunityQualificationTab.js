import { LightningElement, wire, track } from 'lwc';
import getSupplierData from '@salesforce/apex/opportunityQualificationTabController.getSupplierData';
import updateSupplierData from '@salesforce/apex/opportunityQualificationTabController.updateSupplierData';
import systemAdminEditPermission from '@salesforce/customPermission/Edit_LWC_Qualification_Tab';
import hasEditPermission from '@salesforce/apex/opportunityQualificationTabController.hasEditPermission';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class OpportunityQualificationTab extends LightningElement {
    @track data = [];
    @track draftValues = []; // Store draft values (edited rows)
    @track additionalData = ''; // Store the additional info for the modal
    @track selectedSupplier; // Store selected supplier for modal
    @track isCreateSupplierModalOpen = false; // Separate flag for creating modal
    isModalOpen = false;
    @track isEditable = systemAdminEditPermission;
     @track isEditable1 = false;

    get isDisable(){
        return !this.isEditable
    }

    // Check edit permission dynamically via Apex
    @wire(hasEditPermission)
    wiredEditPermission({ error, data }) {
        if (data) {
            this.isEditable1 = data; // Set isEditable based on custom permission
        } else if (error) {
            console.error('Error checking permission:', error);
        }
    }  

    // Define the columns for the datatable with editable fields
    columns = [
        {
            label: 'Supplier',
            fieldName: 'Supplier', // Change to match the data mapping key
            type: 'button', // Makes the field clickable
            typeAttributes: {
                label: { fieldName: 'Supplier' }, // Display the Supplier name
                name: 'view_supplier', // Action name for event handling
                variant: 'base' // Styling of the button
            }
        },
        { label: 'Age', fieldName: 'age', type: 'text', editable: true },
        { label: 'Marital Status', fieldName: 'maritalStatus', type: 'text', editable: true },
        { label: 'Income', fieldName: 'income', type: 'text', editable: true },
        { label: 'Credit Card', fieldName: 'creditCard', type: 'text', editable: true },
        { label: 'Gainfully Retired/Employed', fieldName: 'employmentStatus', type: 'text', editable: true },
       
    ];

   

    @wire(getSupplierData)
    wiredSuppliers({ error, data }) {
        if (data) {
            this.data = data.map(supplier => ({
                id: supplier.Id,
                Supplier: supplier.Name,
                age: supplier.Age__c,
                maritalStatus: supplier.Marital_Status__c,
                income: supplier.Income__c,
                creditCard: supplier.Credit_Card__c ? 'Yes' : 'No',
                employmentStatus: supplier.Employment_Status__c,
                additionalInfo: supplier.Additional_Info__c // Ensure this field exists in the custom object
            }));
        } else if (error) {
            console.error(error);
        }
    }

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        if (actionName === 'view_supplier') {
            this.selectedSupplier = this.data.find(supplier => supplier.id === row.id);
            this.additionalData = this.selectedSupplier ? this.selectedSupplier.additionalInfo : '';
            this.isModalOpen = true;
        }
    }

    handleAdditionalInfoChange(event) {
        this.additionalData = event.target.value; // Capture the changes made to additional info in modal
    }

    saveModalData() {
        // Update the selected supplier's additional info
        this.selectedSupplier.additionalInfo = this.additionalData;

        // Close the modal
        this.isModalOpen = false;
    }

    openCreateSupplierModal() {
        this.isCreateSupplierModalOpen = true;
    }

    closeCreateSupplierModal() {
       this.isCreateSupplierModalOpen = false;
    }

    closeModal() {
        this.isModalOpen = false;
    }

   

     // Handle successful record creation
    handleSuccess(event) {
        const evt = new ShowToastEvent({
            title: "Success",
            message: "Supplier created successfully!",
            variant: "success",
        });
        this.dispatchEvent(evt);
        this.closeCreateSupplierModal(); // Close the modal after creation
         setTimeout(() => {
        window.location.reload();
    }, 1000); // Delay before refreshing the page

    }

    // Handle record creation error
    handleError(event) {
        const evt = new ShowToastEvent({
            title: "Error",
            message: "There was an error creating the supplier.",
            variant: "error",
        });
        this.dispatchEvent(evt);
        this.closeCreateSupplierModal(); // Close the modal after creation
    }

 handleSave(event) {
      if (!this.isEditable) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Permission Denied',
                    message: 'You do not have permission to update Qualification data.',
                    variant: 'error'
                })
            );
            return;
        }

    let updatedFields;

    if (this.isModalOpen) {
        // If the modal is open, we are saving additional info for the selected supplier
        updatedFields = [{
            Id: this.selectedSupplier.id, // Ensure the 'Id' is passed
            Additional_Info__c: this.additionalData // Save the updated additional info from the modal
        }];
    } else {
        // If we're saving from the datatable, handle draft values as before
        updatedFields = event.detail.draftValues.map(draft => {
            const record = this.data.find(supplier => supplier.id === draft.id);
            if (record) {
                return {
                    Id: draft.id, // Ensure the 'Id' field is passed correctly
                    Age__c: draft.age || record.age,
                    Marital_Status__c: draft.maritalStatus || record.maritalStatus,
                    Income__c: draft.income || record.income,
                    Credit_Card__c: draft.creditCard === 'Yes' ? true : false,
                    Employment_Status__c: draft.employmentStatus || record.employmentStatus
                };
            }
            return draft;
        });
    }

    // Call Apex method to save the changes
    updateSupplierData({ data: updatedFields })
        .then(() => {
            // Display success message
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Supplier data updated successfully',
                    variant: 'success'
                })
            );

            // Clear draft values
            this.draftValues = [];
            
            // Close the modal if open
            if (this.isModalOpen) {
                this.closeModal();
            }

            // Hard refresh the page after a short delay
            setTimeout(() => {
                window.location.reload();
            }, 1000); // 1 second delay before refreshing
        })
        .catch(error => {
            console.error('Error updating supplier data:', error);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Error updating supplier data: ' + error.body.message,
                    variant: 'error'
                })
            );
        });
}


}