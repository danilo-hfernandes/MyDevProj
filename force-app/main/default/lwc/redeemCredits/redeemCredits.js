import { LightningElement,api,wire } from 'lwc';
import { getRecord,getFieldValue} from 'lightning/uiRecordApi';
import createPaymentRecord from '@salesforce/apex/RedeemCreditsController.createPaymentRecord';
import getCreditBalance from '@salesforce/apex/RedeemCreditsController.getCreditsData';
import { CloseActionScreenEvent } from 'lightning/actions';
const FIELDS = [
    'Opportunity.AccountId',
    'Opportunity.Total_Amount__c',
    'Opportunity.Total_Amount_Paid__c',
    'Opportunity.Account.Credits_Balance__c'
];
export default class RedeemCredits extends LightningElement {
    @api recordId;
    totalAmountDue;
    creditBalance;
    numberOfCredits;
    isLoading = false;
    displayError;
    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredRecord({ error, data }) {
        if (data) {
            console.log('>>>recordId>>>',this.recordId);
            let recordData = data.fields;
            let totalAmount;
            let totalAmountPaid;
            if(recordData.Total_Amount__c != null && recordData.Total_Amount__c.value != null){
                totalAmount = recordData.Total_Amount__c.value;
            }
            if(recordData.Total_Amount_Paid__c != null && recordData.Total_Amount_Paid__c.value != null){
                totalAmountPaid = recordData.Total_Amount_Paid__c.value;
            }
            this.totalAmountDue = totalAmount - totalAmountPaid;
            //this.creditBalance = getFieldValue(data,'Opportunity.Account.Credits_Balance__c')
        } else if (error) {
            console.error('Error loading record', error);
        }
    }
    /*@wire(getCreditBalance, {recordId: '$recordId'})
        wiredData({ error,data }){   
        if(data){
          console.log('In wire result....');
          console.log(data);
          this.creditBalance = data;
        }
        else if(error){
          console.log('In wire error....');
          this.error = error;
          console.log('Error is ' , this.error);
        }
    } */
    renderedCallback() {
        //code
        getCreditBalance({ recordId : this.recordId})
        .then((result) => {
            if(result != null){
                console.log('>>>>>>>result>>>>',result);
                this.creditBalance = result;
            }
        })
        .catch((error) => {
            console.log('>>>>>>>error>>>>',error);
            this.isLoading = false;
        });
    }
    createPayment(){
        this.isLoading = true;
        console.log('<>>>Save Date');
        if(this.numberOfCredits === 0 || this.numberOfCredits == null){
            this.displayError = 'Number Of Credits should be greater than zero.';
            this.isLoading = false;
        }
        if(this.numberOfCredits >  this.totalAmountDue){
            this.displayError = 'Apply Credits cannot be greater than the balance to pay';
            this.isLoading = false;
        }
        else{
            createPaymentRecord({ recordId : this.recordId, applyCredits : this.numberOfCredits, actualCreditBalance : this.creditBalance})
            .then((result) => {
                if(result != null && result === 'Success'){
                    console.log('>>>>>>>result>>>>',result);
                    this.updateRecordView();
                    this.closeQuickAction();
                    this.isLoading = false;
                }
                else{
                    this.displayError = result;
                    this.isLoading = false;
                }
            })
            .catch((error) => {
                console.log('>>>>>>>error>>>>',error);
                this.isLoading = false;
            });
        }
    }
    handleNoOfCredits(event){
        this.numberOfCredits = event.detail.value;
    }
    closeQuickAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }
    updateRecordView() {
        console.log('refresh>>>>>')
        setTimeout(() => {
             eval("$A.get('e.force:refreshView').fire();");
        }, 500); 
     }
}