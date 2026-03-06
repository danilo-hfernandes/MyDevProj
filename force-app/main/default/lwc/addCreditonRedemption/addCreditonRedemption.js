import { LightningElement, wire,api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import makeApiCallout from '@salesforce/apex/addCreditonRedemptionController.makeApiCallout';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class AddCreditonRedemption extends LightningElement {
   
    isExecuting = false;
    @api recordId;
     

    @api async invoke() {
        if (this.isExecuting) {
            console.log('Already executing, skipping invoke');
            return;
        }

        console.log('Starting asynchronous operation...');
       
        this.isExecuting = true;
         await this.sleep(2000);

        try {
            await this.makeApiCall();
        } catch (error) {
            console.error('Error during execution:', error);
            this.showToast('Error', error.body.message, 'error');
        } finally {
            this.isExecuting = false;
            console.log('Resetting execution flag.');
        }
    }

    // Make the API call here
    async makeApiCall() {
        try {
            console.log('recordID',this.recordId);
            // Assume you have the `recordId` you want to pass to the Apex method
            
            await makeApiCallout({ recordId: this.recordId})
                .then((result) => {
                    console.log('API call successful:', result);
                     this.isLoading = false;
                    this.showToast('Success', 'API call successful', 'success');
                    // Add your window location logic here if needed to refresh or redirect the page
                    this.closeQuickAction();
                    this.refreshPage(); // Refresh the record page safely
                })
                .catch((error) => {
                    console.error('API call failed:', error);
                    throw error; // Re-throw error to be caught by outer catch
                });
        } catch (error) {
            throw error;
        }
    }

     sleep(ms) {
       
        return new Promise((resolve) => setTimeout(resolve, ms));
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(event);
    }

    closeQuickAction() {
        // Dispatches an event to close the quick action
        this.dispatchEvent(new CustomEvent('close'));
    }
    refreshPage() {
        if (!this.hasRefreshed) {
            this.hasRefreshed = true; // Set the flag to true after first reload
            window.location.reload();
        }
    }

}