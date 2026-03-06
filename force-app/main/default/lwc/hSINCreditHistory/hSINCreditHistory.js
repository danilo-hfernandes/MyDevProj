import { LightningElement, api,wire,track } from 'lwc';
import { getRecord} from 'lightning/uiRecordApi';
import getHistoryData from '@salesforce/apex/HSINCreditHistoryController.getHistoryData';
import getMemberCredits from '@salesforce/apex/HSINCreditHistoryController.getMemberCredits';
const FIELDS = [
    'Account.Id',
    'Account.Contact_Id__c',
    'Account.Member_Number__c'
];
export default class HSINCreditHistory extends LightningElement {
    @api recordId;
    @track contactId;
    @track memberNumber;
    creditTransactionList;
    showHistory = false;
    isLoading = false;
    totalRedeemableCredits = 0.0;
    totalRedeemedCredits = 0.0;
    totalPendingCredits = 0.0;
    totalRetractedCredits = 0.0;
    totalEarnedCredits = 0.0;
    historyIsClicked = false;

    get isButtonDisabled() {
        return this.isLoading;
    }

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredRecord({ error, data }) {
        if (data) {
            console.log('>>>recordId>>>',this.recordId);
            let recordData = data.fields;
            if(recordData.Contact_Id__c != null && recordData.Contact_Id__c.value != null){
                this.contactId = recordData.Contact_Id__c.value;
                this.memberNumber = recordData.Member_Number__c.value;
                console.log('>>>>this.contactId>>>'+this.contactId);
                console.log('>>>>this.memberNumber>>>'+this.memberNumber);
            }
        } else if (error) {
            console.error('Error loading record', error);
        }
    }

    handleButtonClick(){

        if (this.historyIsClicked) {
            console.log(' ------ Prevent a new API request ------');
            return;
        }

        this.historyIsClicked = true;
        this.showHistory = false;
        this.isLoading = true;

        console.log('------ getMemberCredits -> start ------ ');
        getMemberCredits({ memberNumber : this.memberNumber})
            .then(result => {
                if (result) {
                    console.log('------ getMemberCredits.results ------ ');
                    console.log('Member Credits Result:', result);
                    this.totalEarnedCredits = parseFloat(result.totalEarnedCredits) || 0.0;
                    this.totalRedeemedCredits = parseFloat(result.totalRedeemedCredits) || 0.0;
                    this.totalRedeemableCredits = parseFloat(result.totalRedeemableCredits) || 0.0;
                    this.totalPendingCredits = parseFloat(result.totalPendingCredits) || 0.0;
                    console.log('getMemberCredits-TotalEarnedCredits:', this.totalEarnedCredits);
                    console.log('getMemberCredits-TotalRedeemableCredits:', this.totalRedeemableCredits);
                    console.log('getMemberCredits-TotalRedeemedCredits:', this.totalRedeemedCredits);
                    console.log('getMemberCredits-TotalPendingCredits:', this.totalPendingCredits);
                    this.showHistory = true;
                } else {
                    console.log('getMemberCredits ->>>>> No credits found for this member.');
                }
            })
            .catch(error => {
                console.error('getMemberCredits ->>>>>> Error fetching member credits:', error);
            });

        console.log('------ getHistoryData -> start ------ ');
        getHistoryData({ contactId : this.contactId})
        .then((result) => {
            if(result != null){
                console.log('>>>>>>>result>>>>',result);
                this.creditTransactionList = result;
                /*for (let key in result) {
                    if(result[key].CreditTransactionStatusType == 'Pending'){
                        this.totalPendingCredits = (result[key].totalPendingCredits).toFixed(2);
                    }
                    else if(result[key].CreditTransactionStatusType == 'Redeemable'){
                        this.totalRedeemableCredits = (result[key].totalRedeemableCredits).toFixed(2);
                    }
                    else if(result[key].CreditTransactionStatusType == 'Earned'){
                        this.totalEarnedCredits = (result[key].totalEarnedCredits).toFixed(2);
                    }
                    else if(result[key].CreditTransactionStatusType == 'Redeemed'){
                        this.totalRedeemedCredits = (result[key].totalRedeemedCredits).toFixed(2);
                    }
                    else if(result[key].CreditTransactionStatusType == 'Retracted'){
                        this.totalRetractedCredits = (result[key].totalRetractedCredits).toFixed(2);
                    }     
                } */
                //this.totalRedeemableCredits = (this.totalEarnedCredits - this.totalRedeemedCredits).toFixed(2);
                console.log('>>>>>>>this.creditTransactionList>>>>'+this.creditTransactionList);

                console.log('getHistoryData-TotalEarnedCredits:', this.totalEarnedCredits);
                console.log('getHistoryData-TotalRedeemableCredits:', this.totalRedeemableCredits);
                console.log('getHistoryData-TotalRedeemedCredits:', this.totalRedeemedCredits);
                console.log('getHistoryData-TotalPendingCredits:', this.totalPendingCredits);
                console.log('getHistoryData-TotalRetractedCredits:', this.totalRetractedCredits);
                this.showHistory = true;
            }
        })
        .catch((error) => {
            console.log('>>>>>>>error>>>>',error);
        })
        .finally(() => {
                this.isLoading = true;
            });
    }
}