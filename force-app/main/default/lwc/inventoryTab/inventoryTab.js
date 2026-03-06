import { LightningElement, api, track,wire } from 'lwc';
import fetchInventoryData from '@salesforce/apex/DepositsRecords.fetchInventoryData';
import fetchAccountAndCaseDetails from '@salesforce/apex/DepositsRecords.fetchAccountAndCaseDetails';
import { NavigationMixin } from 'lightning/navigation';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
import { getRecord } from 'lightning/uiRecordApi';
import getParentCaseDetails from '@salesforce/apex/DepositsRecords.getParentCaseDetails';
//import FIELD_NAME from '@salesforce/schema/Case.MFP_Amount_Used__c';
const FIELDS = [
    'Case.MFP_Amount_Used__c'
];


export default class InventoryTab extends NavigationMixin(LightningElement) {
    @track columns = [];
    data = [];
    @api recordId;
	@track profileName;
    @track paymentType;
    @track clientDepositPaymentScheduleProfile;
    @api objectApiName;
    @track isShowEditModal = false;
    @track isShowNewModal = false;
    isButtonDisabled = false; // Reactive property to control button state

    // Fetch the Account field value
    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredAccount({ error, data }) {
        if (data) {
            // Update the button's disabled state based on the field value
            this.isButtonDisabled = data.fields.MFP_Amount_Used__c.value === true;
        } else if (error) {
            console.error('Error fetching Case data:', error);
        }
    }
    
    connectedCallback() {
		this.fetchParentCaseDetails();
        this.setDynamicColumns();
        console.log('>>>record ID>>>',this.recordId);
        console.log('>>>record ID>>>',this.objectApiName);
        console.log('>>>>',this.recordId);
        fetchInventoryData({ caseRecordId: this.recordId })
        .then((result) =>{
            var tempData = result;
            console.log('>>>result>47>>fetchInventoryData',result);
            // Calculate totals
            let totalGPR = 0;
            let totalMemberPrice = 0;
            let totalInventoryCost= 0;
            let totalPoints = 0;
            let totalMFPAmount = 0;
            const filteredData = tempData.filter(row => row.Status__c === 'Approved' || row.Status__c === 'New' || row.Status__c === 'Pending');
            if (this.recordId.startsWith('00Q')) {
                filteredData.forEach(row => {
                    totalMemberPrice += parseFloat(row.Member_Price__c) || 0;
                    totalGPR += parseFloat(row.Lowest_Price_GPR__c) || 0;
                });
                let i=1;
                this.data = tempData.map((inventory) => {
                    return {
                        ...inventory,
                        number : i++,
                        linkName : '/' + inventory.Id, 
                        resortId : inventory.Resort_Id__c != null? '/' + inventory.Resort_Id__c: null,
                        resortName : inventory.Resort_Id__c != null?inventory.Resort_Id__r.Name:'',
                        isButtonDisabled : this.isButtonDisabled
                    };
                });
                this.data = [...this.data, {
                            Id: 'total-row', // Unique ID for the total row
                            Name: '',
                            number : '',
                            Member_Price__c: totalMemberPrice,
                            Lowest_Price_GPR__c: totalGPR,
                            Status__c: '',
                            isButtonDisabled: true, // Disable the button for the Total row
                            rowClass: 'slds-text-title_bold', // Apply bold styling for the Total row
                            buttonClass: 'slds-hide',
                        }];
            }
            else{
                filteredData.forEach(row => {
                    totalInventoryCost += parseFloat(row.Inventory_Cost__c) || 0;
                    totalPoints += parseFloat(row.Points__c) || 0;
                    totalMFPAmount += parseFloat(row.MFP_Entitlement_Amount_Reservation__c) || 0;
                });
                let i=1;
                this.data = tempData.map((inventory) => {
                    return {
                        ...inventory,
                        number : i++,
                        linkName : '/' + inventory.Id, 
                        resortId : inventory.Resort_Id__c != null? '/' + inventory.Resort_Id__c: null,
                        resortName : inventory.Resort_Id__c != null?inventory.Resort_Id__r.Name:'',
                        isButtonDisabled : this.isButtonDisabled
                        //linkedCaseId : inventory.Linked_Case_1__c != null? '/' + inventory.Linked_Case_1__c: null,
                        //LinkedCase : inventory.Linked_Case_1__c != null?inventory.Linked_Case_1__r.CaseNumber:''
                    };
                });
                this.data = [...this.data, {
                            Id: 'total-row', // Unique ID for the total row
                            Name: 'MFP Allotment',
                            number : 'MFP Allotment',
                            Inventory_Cost__c: totalInventoryCost,
                            Points__c : totalPoints,
                            MFP_Entitlement_Amount_Reservation__c: totalMFPAmount,
                            Status__c: '',
                            isButtonDisabled: true, // Disable the button for the Total row
                            rowClass: 'slds-text-title_bold', // Apply bold styling for the Total row
                            buttonClass: 'slds-hide',
                        }];
            }
        })
        .catch((error)=>{

        })
        if (this.recordId.startsWith('00Q')) {
            this.fetchAccountAndCaseDetailsJS();
        }
        
    }
	fetchParentCaseDetails() {
        getParentCaseDetails({ parentCaseId: this.recordId })
            .then(result => {
                if (result) {
                    this.profileName = result.Profile_Name__c;
                    this.paymentType = result.Payment_Type__c;
                    this.clientDepositPaymentScheduleProfile = result.Client_Deposit_Payment_Schedule_Profile__c;
                    console.log('Case Fields:', this.profileName, this.paymentType, this.clientDepositPaymentScheduleProfile);
                }
            })
            .catch(error => {
                console.error('Error fetching case details:', error);
            });
    }
    setDynamicColumns() {
            // Example condition: show different columns based on record type
            if (this.recordId.startsWith('00Q')) {
                this.columns =[
                {fieldName: 'number', label: '', type : 'text', cellAttributes: { alignment: 'right', style: 'white-space: nowrap; overflow: visible; font-weight: bold;',}},
                {
                    type:'url',
                    fieldName: 'linkName',
                    label:'Reservation Id',
                    typeAttributes: {label: { fieldName: 'Name' }, target: '_self',tooltip : {fieldName : 'Name'}}
                },
                { fieldName: 'file_tracker_number__c', label: 'FT Number' },
                { fieldName: 'Check_in_Date__c', label: 'CHECK IN DATE', type: 'date-local',timeZone:'UTC'},
                { type:'url',
                    fieldName: 'resortId',
                    label:'PROPERTY',
                    typeAttributes: {label: { fieldName: 'resortName' }, target: '_blank',tooltip : {fieldName : 'resortName'}}
                },
                { fieldName: 'Member_Price__c', label: 'Member Price', type: 'currency',cellAttributes: { class: { fieldName: 'rowClass' }}},
                { fieldName: 'Lowest_Price_GPR__c', label: 'GPR' , type: 'currency' , cellAttributes: { class: { fieldName: 'rowClass' }}},
                { fieldName: 'Status__c', label: 'STATUS' },
                {
                    type:"button",
                    fixedWidth: 80,
                    typeAttributes: {
                        label: 'Edit',
                        name: 'edit',
                        variant: 'brand',
                        disabled: {fieldName: 'isButtonDisabled'},
                        class: { fieldName: 'buttonClass' }
                    }
                },
            ];
            } else {
               this.columns =[
                    {fieldName: 'number', label: '', type : 'text', cellAttributes: { alignment: 'right', style: 'white-space: nowrap; overflow: visible; font-weight: bold;',}},
                    {
                        type:'url',
                        fieldName: 'linkName',
                        label:'DEPOSIT',
                        typeAttributes: {label: { fieldName: 'Name' }, target: '_self',tooltip : {fieldName : 'Name'}}
                    },
                    { fieldName: 'Check_in_Date__c', label: 'CHECK IN DATE', type: 'date-local',timeZone:'UTC'},
                    { type:'url',
                        fieldName: 'resortId',
                        label:'PROPERTY',
                        typeAttributes: {label: { fieldName: 'resortName' }, target: '_blank',tooltip : {fieldName : 'resortName'}}
                    },
                    { fieldName: 'Inventory_Cost__c', label: 'Inventory Cost' , type: 'currency', cellAttributes: { class: { fieldName: 'rowClass' }}},
                    { fieldName: 'Points__c', label: 'Points', type: 'number',cellAttributes: { class: { fieldName: 'rowClass' }}},
                    { fieldName: 'MFP_Entitlement_Amount_Reservation__c', label: 'MFP Amount' , type: 'currency' , cellAttributes: { class: { fieldName: 'rowClass' }}},
                    { fieldName: 'Status__c', label: 'STATUS' },
                    {
                        type:"button",
                        fixedWidth: 80,
                        typeAttributes: {
                            label: 'Edit',
                            name: 'edit',
                            variant: 'brand',
                            disabled: {fieldName: 'isButtonDisabled'},
                            class: { fieldName: 'buttonClass' }
                        }
                    },
                ];
            }
        }
    fetchAccountAndCaseDetailsJS(){
        fetchAccountAndCaseDetails({ leadId: this.recordId })
        .then((result) =>{
            let data = result;
            console.log('>>>>result',data);
            console.log('>>>>result',+result);
            this.accountId = data.accountId;
            this.caseId = data.caseId;
            console.log('>>accountId>>>'+this.accountId+'>>>caseId>>'+this.caseId);
        })
        .catch((error)=>{

        })
    }
    navigateToNewInventoryPage() {
        let defaultValues;
        // Determine object type based on recordId prefix (optional validation)
        if (this.recordId.startsWith('00Q')) {
           defaultValues = encodeDefaultFieldValues({
            Lead__c: this.recordId,
            Case__c: this.caseId,
            Account_Name__c : this.accountId,
            CaseType__c : 'FileTracker' 
            });
        } 
        else if (this.recordId.startsWith('500')) {
            defaultValues = encodeDefaultFieldValues({
            Case__c: this.recordId,
            Account_Name__c : this.accountId,
            CaseType__c : 'E&D' ,
			Profile_Name__c: this.profileName,
			Payment_Type__c: this.paymentType,
			Client_Deposit_Payment_Schedule_Profile__c: this.clientDepositPaymentScheduleProfile
            });
        } else {
            console.error('Unsupported object type');
            return;
        }
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Deposits__c',
                actionName: 'new'
            },
            state: {
                useRecordTypeCheck: 1,
                defaultFieldValues: defaultValues
            }
        }); 
        console.log('>>>>inside new screen>>record');
    }
    navigateToRecordEditPage(event) {
        event.preventDefault();
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: event.detail.row.Id,
                objectApiName: 'Deposits__c', // objectApiName is optional
                actionName: 'edit'
            }
        });
    }
}