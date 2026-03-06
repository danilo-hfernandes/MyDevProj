import { LightningElement, api,track } from 'lwc';
import updateContactOwner from '@salesforce/apex/ChangeContactOwnerController.updateContactOwner';
export default class ChangeContactOwnerLWCComponent extends LightningElement {
    @api contactIds;
    @api message;
    selectedUserId;
    @track dispayMessage;
    //Boolean tracked variable to indicate if modal is open or not default value is false as modal is closed when page is loaded 
    @track isModalOpen = true;
    @track isLoading = false;
    openModal() {
        // to open modal set isModalOpen tarck value as true
        this.isModalOpen = true;
    }
    closeModal() {
        // to close modal set isModalOpen tarck value as false
        this.isModalOpen = false;
        window.open('/lightning/o/Contact/list', '_parent');
    }
    submitDetails() {
        console.log('Inside Submit');
        console.log('>>>>>>>contactIds>>>>>>'+this.contactIds);
        // to close modal set isModalOpen tarck value as false
        //Add your code to call apex method or do some processing
        console.log('>>>>>>>this.selectedUserId>>>>>>'+this.selectedUserId);
        if(this.selectedUserId == null){
            this.dispayMessage = 'Enter a new owner for this record.'
        }
        else{
            this.dispayMessage = '';
            this.isLoading = true;
            updateContactOwner({userId : this.selectedUserId, setOfConIds : this.contactIds})
            .then((result) => {
                if(result != null){
                    console.log('>>>>>>>result>>>>',result);
                    this.isModalOpen = false;
                    window.open('/lightning/o/Contact/list', '_parent');
                    this.isLoading = false;
                } 
            })
            .catch((error) => {
                console.log('>>>>>>>error>>>>',error);
                this.isLoading = false;
                this.error = error;
            });
        }
    }
    lookupRecord(event){
        console.log('Selected Record Value on Parent Component is ' +  JSON.stringify(event.detail.selectedRecord));
        this.dispayMessage = '';
        this.selectedUserId = JSON.stringify(event.detail.selectedRecord);
    }
}