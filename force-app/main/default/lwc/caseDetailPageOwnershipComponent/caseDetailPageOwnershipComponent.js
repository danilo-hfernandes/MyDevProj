import { LightningElement, api, track, wire } from 'lwc';
import fetchTimeshareData from '@salesforce/apex/DepositsRecords.timeShareRecords';
import getMFPData from '@salesforce/apex/DepositsRecords.getMFPValue';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import updateCaseOwnerShipData from '@salesforce/apex/DepositsRecords.updateCaseData';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getCases from '@salesforce/apex/DepositsRecords.getCases';
import createLinkedCase from '@salesforce/apex/DepositsRecords.createLinkedCase';

export default class CaseDetailPageOwnershipComponent extends NavigationMixin(LightningElement) {
    @track cases = [];
    @track isModalOpen = false;
    @api recordId;
    @track selectedCaseId = ''; // Holds selected case ID (for radio buttons)
    @track columns = []; // Columns configuration for the table
    @api objectApiName;
    @track isShowEditModal = false;
    @track isShowNewModal = false;
    @track isLoading = false;
    resortName ;
    selectedResortId;
    balanceAmount = 0;
    timeshareId;
    points= 0;
    timeShare = [];
    @track mfpValue = false;
    @track showMFP = false;
    @track sFtimeshareId = '';//Last 4 digit
    @wire(getRecord, { recordId : '$recordId' ,fields: [ 'Case.Ownership_Resort_Timeshare__c' ] })
    wiredRecord(result) {
        this.record = result;
        if (result.data) {
            this.selectedResortId = getFieldValue(result.data,'Case.Ownership_Resort_Timeshare__c');
            this.fetchingTimeshare();
        }
    }
    connectedCallback() {
        // Define columns for the datatable
        this.columns = [
            { label: 'Case Number', fieldName: 'CaseNumber', type: 'text' },
            { label: 'Account Name', fieldName: 'Account_Name__c', type: 'text' },
            { type:'url',
                fieldName: 'Ownership_Resort_Timeshare__c',
                label:'Timeshare',
                typeAttributes: {label: { fieldName: 'resortName' }, target: '_blank',tooltip : {fieldName : 'resortName'}}
            },
            {label : 'MFP Entitlement Remaining', fieldName : 'Balance_MFP_Amount__c' , type :'currency', typeAttributes: { currencyCode: 'USD'}},
            {label: 'Points', fieldName: 'Amount_of_Points__c', type: 'number'},
        ];
    }

    // Open the modal and fetch cases
    openModal() {
        this.isModalOpen = true;
        this.fetchCases();
    }

    // Close the modal
    closeModal() {
        this.isModalOpen = false;
    }

    // Fetch cases via Apex
    fetchCases() {
        this.isLoading = true;
        getCases({parentCaseId : this.recordId})
            .then((data) => {
                var tempData = data;
                this.cases =  tempData.map((objcase) => {
                    return {
                        ...objcase,
                        resortName : objcase.Ownership_Resort_Timeshare__c != null?objcase.Ownership_Resort_Timeshare__r.Name:''
                    }
                });
                this.isLoading = false;
            })
            .catch((error) => {
                console.error('Error fetching cases:', error);
                this.showToast('Error', 'Unable to fetch cases', 'errohandleRowSelectionr');
                this.isLoading = false;
            });
    }

    // Handle radio button selection
    handleRowSelection(event) {
        console.log('>>>>>'+event.detail.value);
        const selectedRows = event.detail.selectedRows;
        this.selectedCaseId = selectedRows[0].Id; // Captures the selected row's ID
        this.balanceAmount = selectedRows[0].Balance_MFP_Amount__c;
        this.timeshareId = selectedRows[0].Ownership_Resort_Timeshare__c;
        this.points = selectedRows[0].Amount_of_Points__c;
    }

    // Link the selected case
    linkSelectedCase() {
        console.log('>>>>selectedCaseId>'+this.selectedCaseId);
        
        if (!this.selectedCaseId) {
            this.showToast('Error', 'Please select a case first', 'error');
            return;
        }

        createLinkedCase({
            parentCaseId: this.recordId,
            childCaseId: this.selectedCaseId,
            balanceAmount : this.balanceAmount,
            timeshareId : this.timeshareId,
            points : this.points,
        })
            .then(() => {
                this.showToast('Success', 'Case linked successfully', 'success');
                this.isModalOpen = false;
                setTimeout(() => {
                 eval("$A.get('e.force:refreshView').fire();");
            }, 500);
            })
            .catch((error) => {
                console.error('Error creating linked case:', error);
                this.showToast('Error', 'Failed to link case', 'error');
            });
    }

    // Show toast notifications
    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title,
            message,
            variant
        });
        this.dispatchEvent(event);
    }
    fetchingTimeshare(){
        console.log('>>>>reocrd id>>',this.recordId);
        fetchTimeshareData({ caseRecordId: this.recordId })
        .then((result) =>{
            console.log('>>>>',this.recordId);
            console.log('>>>result>>>',result);
            let listOfTimeShare = [] ;
            for (var key in result) {
                  listOfTimeShare.push({
                     value: key,
                     label: result[key]
                  });
                  console.log('key', key, result[key]);
               }
               this.timeShare = listOfTimeShare;
            console.log('>>>Timshare>>>',JSON.stringify(this.timeShare));
        })
        .catch((error)=>{

        })
    }
    saveDateFromModalBox() {  
        let arrayOfInventory = [];
        console.log('thisrecordId>>>'+this.recordId);
        let updateInventoryData = {
            'Id' : this.recordId , 
            'Ownership_Resort_Timeshare__c' : this.selectedResortId ,
        };
        console.log('updateInventoryData>>>>',JSON.stringify(updateInventoryData));
        arrayOfInventory.push(updateInventoryData);
        console.log('arrayOfInventory>>>>',JSON.stringify(arrayOfInventory));
        updateCaseOwnerShipData({ caseRecords: arrayOfInventory , timeshareId : this.selectedResortId})
        .then((result) =>{
            console.log('>>>>',this.recordId);
            console.log('>>>result>118>fetchTimeshareData',result);
            console.log('>>>Timshare out of for loop');
            const event = new ShowToastEvent({
                title: 'SUCCESS',
                message: 'Record Saved Successfully',
                variant: 'success'
            });
            this.dispatchEvent(event);
            setTimeout(() => {
                 eval("$A.get('e.force:refreshView').fire();");
            }, 500);
        })
        .catch((error)=>{
            const event = new ShowToastEvent({
                title: 'ERROR',
                message: 'Opps! Something Went Wrong... Please contact your System Administrator',
                variant: 'error'
            });
            this.dispatchEvent(event);
        })      
    }
    handleChange(event) {
        this.showMFP = true;
        console.log('inside handleCHange>>>', event.target.value);
        this.selectedLabel = event.target.options.find(opt => opt.value === event.detail.value).label;
        this.selectedResortId = event.target.value;
        this.sFtimeshareId = this.selectedResortId.substr(-4);
        if(event.target.name === 'Ownership_Resort_Timeshare__c'){
            console.log('inside resort name if');
            this.resortName = this.selectedLabel;
           
            getMFPData({timeshareId :  this.selectedResortId})
            .then((result) =>{
                console.log('>>>>'+ result);
                this.mfpValue = result;
                console.log('>>>>'+ this.mfpValue);
            })
            .catch((error)=>{
                const event = new ShowToastEvent({
                    title: 'ERROR',
                    message: 'Opps! Something Went Wrong... Please contact your System Administrator',
                    variant: 'error'
                });
                this.dispatchEvent(event);
            })   
        } 
    }
}