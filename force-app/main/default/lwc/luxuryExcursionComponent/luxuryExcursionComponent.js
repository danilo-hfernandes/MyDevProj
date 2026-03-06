import { LightningElement, api, wire, track } from 'lwc';
import getExcursions from '@salesforce/apex/LuxuryExcursionsController.getExcursions';
import createExcursion from '@salesforce/apex/LuxuryExcursionsController.createExcursion';
import { refreshApex } from '@salesforce/apex';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { notifyRecordUpdateAvailable } from 'lightning/uiRecordApi';
import { subscribe, unsubscribe, onError } from 'lightning/empApi';


export default class LuxuryExcursionComponent extends NavigationMixin(LightningElement) {
    @api recordId; 
    wiredResult;
    @track excursions = [];

channelName = '/data/Luxury_Excursion__ChangeEvent';
subscription = null;

    @wire(CurrentPageReference)
    setCurrentPageReference(pageRef) {
    this.pageRef = pageRef;

    if (this.wiredResult) {
        refreshApex(this.wiredResult);
    }
}
    //pageRef;

    //renderedCallback() {
        //if (this.wiredResult) {
            //refreshApex(this.wiredResult);
        //}
    //}

    @wire(getExcursions, { parentId: '$recordId' })
    wiredExcursions(result) {
        this.wiredResult = result;
        if (result.data) {
            // Mapping ensures the productName is available for the HTML
            this.excursions = result.data.map(exc => ({
                ...exc,
                productName: exc.Opportunity_Product__r?.Product2?.Name || '' ,
                // NEW: Generate the URL for the new tab link
                recordUrl: `/lightning/r/Luxury_Excursion__c/${exc.Id}/view`
            }));
        } else if (result.error) {
            console.error('Error fetching excursions:', result.error);
            this.excursions = [];
        }
    }

connectedCallback() {
    subscribe(this.channelName, -1, (message) => {
        refreshApex(this.wiredResult);
    }).then(response => {
        this.subscription = response;
    });

    onError(error => {
        console.error('EMP API error:', error);
    });
}

disconnectedCallback() {
    if (this.subscription) {
        unsubscribe(this.subscription, () => {});
    }
}

    async handleAdd(event) {
        const sourceId = event.currentTarget.dataset.id; 
        try {
            const newId = await createExcursion({ 
                parentId: this.recordId, 
                sourceExcursionId: sourceId 
            });
            
            await refreshApex(this.wiredResult);
            this.navigateToRecord(newId);
        } catch (error) {
            this.showToast('Error', error.body?.message || error.message, 'error');
        }
    }

 //       handleEdit(event) {
//        const recId = event.currentTarget.dataset.id;
//        this.navigateToRecord(recId);
        //refreshApex(this.wiredResult);
        //notifyRecordUpdateAvailable([{ recordId: recId }])
        //    .then(() => {
        //        return refreshApex(this.wiredResult);
        //    });
//    }

handleEdit(event) {
    const recId = event.currentTarget.dataset.id;
    this.navigateToRecord(recId);
}


    navigateToRecord(recId) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recId,
                actionName: 'edit'
            }
        });
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}