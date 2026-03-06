import { LightningElement,track,wire,api } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { getRecord, getFieldValue} from 'lightning/uiRecordApi';
import validateRecord from '@salesforce/apex/TravelInsuranceController.validateRecord';
import hitPurchaseAPI from '@salesforce/apex/TravelInsuranceController.hitPurchaseAPI';
import hitQuoteAPI from '@salesforce/apex/TravelInsuranceController.hitQuoteAPI';
import hitProductCreation from '@salesforce/apex/TravelInsuranceController.hitProductCreation';
import deleteTravelInsuranceProduct from '@salesforce/apex/TravelInsuranceController.deleteTravelInsuranceProduct';
const FIELDS = [
    'Opportunity.Account.First_Name__c',
    'Opportunity.Account.Last_Name__c',
    'Opportunity.Account.BillingStreet',
    'Opportunity.Account.BillingCity',
    'Opportunity.Account.BillingState',
    'Opportunity.Account.BillingCountry',
    'Opportunity.Account.BillingPostalCode',
    'Opportunity.Account.Email__c'
];

const DisplayErrorCommunicationTI = 'There was a communication issue with the Travel Insurance API. Please try again or contact support for assistance.';

export default class TravelInsuranceComponent extends LightningElement {
    @track rows = [];
    @track draftValues = [];
    @track columns = [
        { label: 'First Name', fieldName: 'firstName', type: 'text' , editable: true},
        { label: 'Last Name', fieldName: 'lastName', type: 'text' , editable: true},
       /* { label: 'Email', fieldName: 'email', type: 'text' ,editable: true },
        { label: 'Billing Street', fieldName: 'billingStreet', type: 'text' ,editable: true},
        { label: 'Billing City', fieldName: 'billingCity', type: 'text' ,editable: true},
        { label: 'Billing State', fieldName: 'billingState', type: 'text' ,editable: true},*/
        {
            type: 'button-icon',
            fixedWidth: 50,
            typeAttributes: { iconName: 'utility:delete', name: 'delete', alternativeText: 'Delete' }
        }
    ];

    rowId = 0; // To keep track of the row ID
    @track displayError;
    rowAdded = false;
    firstScreen = false;
    secondScreen = false;
    thirdScreen = false;
    fourthScreen = false;
    addRowScreen = false;
    @api recordId;
    @track firstName = '';
    @track lastName = '';
    @track street = '';
    @track city = '';
    @track state = '';
    @track country = 'US';
    @track email = '';
    destination = 'US';
    startDate = '';
    endDate = '';
    primaryInsured = true;
    isLoading = false;
    quoteId = '';
    productId = '';
    net_price = 0;
    paymentUrl;
    paymentFlag = false;
    states = {
  'Alabama': 'AL',
  'Alaska': 'AK',
  'American Samoa': 'AS',
  'Arizona': 'AZ',
  'Arkansas': 'AR',
  'California': 'CA',
  'Colorado': 'CO',
  'Connecticut': 'CT',
  'Delaware': 'DE',
  'District Of Columbia': 'DC',
  'Federated States Of Micronesia': 'FM',
  'Florida': 'FL',
  'Georgia': 'GA',
  'Guam': 'GU',
  'Hawaii': 'HI',
  'Idaho': 'ID',
  'Illinois': 'IL',
  'Indiana': 'IN',
  'Iowa': 'IA',
  'Kansas': 'KS',
  'Kentucky': 'KY',
  'Louisiana': 'LA',
  'Maine': 'ME',
  'Marshall Islands': 'MH',
  'Maryland': 'MD',
  'Massachusetts': 'MA',
  'Michigan': 'MI',
  'Minnesota': 'MN',
  'Mississippi': 'MS',
  'Missouri': 'MO',
  'Montana': 'MT',
  'Nebraska': 'NE',
  'Nevada': 'NV',
  'New Hampshire': 'NH',
  'New Jersey': 'NJ',
  'New Mexico': 'NM',
  'New York': 'NY',
  'North Carolina': 'NC',
  'North Dakota': 'ND',
  'Northern Mariana Islands': 'MP',
  'Ohio': 'OH',
  'Oklahoma': 'OK',
  'Oregon': 'OR',
  'Palau': 'PW',
  'Pennsylvania': 'PA',
  'Puerto Rico': 'PR',
  'Rhode Island': 'RI',
  'South Carolina': 'SC',
  'South Dakota': 'SD',
  'Tennessee': 'TN',
  'Texas': 'TX',
  'Utah': 'UT',
  'Vermont': 'VT',
  'Virgin Islands': 'VI',
  'Virginia': 'VA',
  'Washington': 'WA',
  'West Virginia': 'WV',
  'Wisconsin': 'WI',
  'Wyoming': 'WY'
}
    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredRecord({ error, data }) {
        if (data) {
            console.log('>>>recordId>>>',this.recordId);
            let recordData = data.fields;
            console.log('>>>recordData>>>',recordData);
            this.firstName = getFieldValue(data,'Opportunity.Account.First_Name__c');
            this.lastName = getFieldValue(data,'Opportunity.Account.Last_Name__c');
            this.street = getFieldValue(data,'Opportunity.Account.BillingStreet');
            this.city = getFieldValue(data,'Opportunity.Account.BillingCity');
            this.state = this.states[getFieldValue(data,'Opportunity.Account.BillingState')];
            //this.country = getFieldValue(data,'Opportunity.Account.BillingCountry');
            this.email = getFieldValue(data,'Opportunity.Account.Email__c');
            //this.firstScreen = true;
            console.log('>>>firstName>>>',this.firstName);
        } else if (error) {
            console.error('Error loading record', error);
            this.displayError = error;
        }
    }
    @wire(validateRecord, {recordId: '$recordId'})
        validData({ error,data }){   
        if(data){
            let result = data;
            if(result != null && result.errorMessage == null){
                this.displayError = '';
                this.isLoading = false;//this.net_price = result.net_price;
                this.startDate = result.startDate;
                this.endDate = result.endDate;
                //this.destination = result.destination;
                this.productId = result.productId;
                if(result.quote_id != null  && result.productId != null){
                    this.paymentFlag = result.paymentFlag;
                    this.quoteId = result.quote_id;
                    this.paymentUrl = 'https://www.nerdsoft.com/certificate-redemption/?order_id='+this.productId;
                    this.firstScreen = false;
                    this.secondScreen = false;
                    this.thirdScreen = true;
                }
                else{
                     this.firstScreen = true;
                }
            }
            else if(result != null && result.errorMessage != null){
                console.log('>>result.errorMessage>>'+result.errorMessage);
                this.displayError = result.errorMessage;
                this.isLoading = false;
                this.fourthScreen = true;
                this.firstScreen = false;
                this.secondScreen = false;
                this.thirdScreen = false;
            }
        }
        else if(error){
          console.log('In wire error....');
          this.displayError = error;
          console.log('Error is ' , this.displayError);
          console.log('Error is ' + this.displayError);
        }
    }
    addRow() {
        if(!this.addRowScreen)
            this.addRowScreen = true;
        const newRow = {
            id: this.rowId++,
            firstName: '',
            lastName: ''
            /*email: `email${this.rowId}@example.com`,
            billingStreet: `Street ${this.rowId}`,
            billingCity: `City ${this.rowId}`,
            billingState: `State ${this.rowId}`*/
        };
        this.rows = [...this.rows, newRow];
        console.log('>>>>>', this.rows);
        console.log('>>>>>', JSON.stringify(this.rows));
    }
    handleSave(event){
        this.rowAdded = true;
        const updatedFields = event.detail.draftValues;
        // Update the rows with the changed fields
        // Ensure `updatedFields` is an array
        if (Array.isArray(updatedFields)) {
        this.rows = this.rows.map(row => {
                const updatedRow = updatedFields.find(field => field.id == row.id);
                console.log('>>>>'+updatedRow);
                return updatedRow ? { ...row, ...updatedRow } : row;
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

        if (actionName === 'delete') {
            this.deleteRow(row.id);
        }
    }

    // Function to delete a row
    deleteRow(rowId) {
        this.rows = this.rows.filter(row => row.id !== rowId);
        this.draftValues = this.draftValues.filter(row => row.id !== rowId);
    }
    handleInputChange(event) {
        this.displayError = '';
        const field = event.target.dataset.id;
        if (field) {
            this[field] = event.target.value;
        }
        if(field == 'state'){
            this.displayError = 'Please input the state in its abbreviated form, using a 2-letter code';
        }
    }

    handleProceed() {
        console.log('handleProceed >>>>this.rows>>>'+JSON.stringify(this.rows));
        const requiredFields = this.template.querySelectorAll('lightning-input');
        let isValid = true;
        requiredFields.forEach(field => {
            if (!field.checkValidity()) {
                field.reportValidity();
                isValid = false;
            }
        });
        if(this.rows != null && !this.rowAdded){
            console.log('handleProceed>>>>this.rows>>>'+JSON.stringify(this.rows));
            this.displayError = 'Please enter the traveler information before proceeding.';
        }
        else if (isValid) {
            this.isLoading = true;
            // Handle the proceed action here
            // You can collect the data and perform further actions
            console.log('Proceed clicked');//, primaryInsured : this.primaryInsured
            hitQuoteAPI({recordId : this.recordId, firstName : this.firstName, lastName : this.lastName, street :this.street, city :this.city, state : this.state, country : this.country, email : this.email,startDate : this.startDate, endDate : this.endDate, destination : this.destination ,travelerData : this.rows})
            .then((result) => {
                console.log('handleProceed >>>>>>>result: ',result);
                console.log('handleProceed >>>>>>>result>>>errorMessage: ',result.errorMessage);
                console.log('handleProceed >>>>>>>result>>>>quote_id: ',result.quote_id);
                if(result != null && result.errorMessage == null){
                    
                    if (!result.quote_id) {
                        this.displayError = DisplayErrorCommunicationTI;
                        this.isLoading = false;
                        return;
                    }

                    this.isLoading = false;
                    this.firstScreen = false;
                    this.secondScreen = true;
                    this.quoteId = result.quote_id;
                    this.net_price = result.net_price;
                    this.displayError = '';
                }
                else if(result != null && result.errorMessage != null){
                    this.displayError = result.errorMessage;
                    this.isLoading = false;
                }
            })
            .catch((error) => {
                console.log('handleProceed >>>>>>>error>>>>',error);
                this.displayError = DisplayErrorCommunicationTI
                this.isLoading = false;
            });
        }
    }

    handlePurchaseAPI(){
       this.isLoading = true;
        console.log('handlePurchaseAPI >>>>>>>>> Purchase clicked');
        console.log('handlePurchaseAPI >>>>>>>>> RecorId: ' + this.recordId);
        console.log('handlePurchaseAPI >>>>>>>>> QuoteId: ' + this.quoteId);
        console.log('handlePurchaseAPI >>>>>>>>> ProductId: ' + this.productId);

        hitPurchaseAPI({ recordId : this.recordId, quoteId : this.quoteId, productId : this.productId})
            .then((result) => {
                console.log('handlePurchaseAPI>>>>>>>result>>>>'+result);
                if(result != null && result.errorMessage == null){
                    console.log('handlePurchaseAPI>>>>>>> if >>> result>>>>'+result);
                    this.isLoading = false;
                    //this.thirdScreen = false;
                    //this.displayError = DisplayErrorCommunicationTI;
                    this.displayError = '';
                    this.closeQuickAction();
                }
                else if(result != null && result.errorMessage != null){
                    console.log('handlePurchaseAPI>>>>>>> else if >>> result>>>>'+result);
                    //this.displayError = result.errorMessage;
                    console.log('handlePurchaseAPI >>>>>>>message>>>>',result.message);
                    console.log(this.firstScreen, this.secondScreen, this.thirdScreen, this.fourthScreen, this.fiveScreen);  
                    if( result.message == 'NoPayment')
                    {
                        this.displayError = result.errorMessage;
                    }
                    else {
                        this.displayError = DisplayErrorCommunicationTI;
                        this.thirdScreen = false;
                        this.fourthScreen = false;
                        this.fiveScreen = true;   
                        
                    }
                    
                    this.isLoading = false;
                    return Promise.reject(result.errorMessage);
                }
            })
            .catch((error) => {
                console.log('handlePurchaseAPI >>>>>>>error>>>>',error);
                console.log('handlePurchaseAPI >>>>>>>message>>>>',result.message);
                console.log(this.firstScreen, this.secondScreen, this.thirdScreen, this.fourthScreen, this.fiveScreen);  
                if( result.message == 'NoPayment')
                {
                    this.displayError = result.errorMessage;
                }
                else {
                    this.displayError = DisplayErrorCommunicationTI;
                    this.thirdScreen = false;
                    this.fourthScreen = false;
                    this.fiveScreen = true;   
                    
                }
                
                this.isLoading = false;
                
                return Promise.reject(error);
            }); 
    }

    handleProductCreation(){
       this.isLoading = true;
        console.log('ProductCreation clicked');
        hitProductCreation({ recordId : this.recordId, netPrice : this.net_price, quoteId : this.quoteId})
            .then((result) => {
                if(result != null && result.errorMessage == null){
                    console.log('handleProductCreation>>>>>>>result>>>>',result);
                    this.isLoading = false;
                    this.secondScreen = false;
                    this.thirdScreen = true;
                    this.displayError = '';
                    this.productId = result.productId;
                    //this.productAdded = true;
                    this.paymentUrl = 'https://www.nerdsoft.com/certificate-redemption/?order_id='+this.productId;
                }
                else if(result != null && result.errorMessage != null){
                    this.displayError = result.errorMessage;
                    this.isLoading = false;
                }
            })
            .catch((error) => {
                console.log('>>>>>>>error>>>>',error);
                this.isLoading = false;
            }); 
    }
    handleCancel() {
        // Handle the cancel action here
        // You might want to reset the form or navigate away
        console.log('Cancel clicked');
        this.dispatchEvent(new CloseActionScreenEvent());
        this.updateRecordView();
    }
     renderedCallback() {
        console.log('>>>>Rendered Call back');
        if (this.secondScreen == true || this.thirdScreen == true) {
            //console.log('>>>>Rendered Call back >>>>>>>fourthScreen' +  this.fourthScreen);
            let style = document.createElement('style');
            style.innerText = '.slds-modal__close { display: none !important; }';
            document.head.appendChild(style);
        }
     }


    handleCancelAndDeleteProduct() {
        console.log('handleCancelAndDeleteProduct >>>>> Checking payment before canceling or deleting product.');
        const displayErrorMessageProductCreated = 'There was a communication issue with the Travel Insurance API. A product has been created but the Policy Number has not been generated, please contact support for assistance.';
        
        if (this.paymentFlag) {
            console.log('handleCancelAndDeleteProduct >>>>> Payment exists, proceeding with purchase.');
            this.handlePurchaseAPI()
            .catch(error => { 
                console.error('handleCancelAndDeleteProduct >>>>> Error during purchase:', error);
                this.displayError = displayErrorMessageProductCreated;
                this.handleProductCreation(); 
            })
            .finally(() => {
                this.handleCancel();
            }); 
        } else {
            console.log('handleCancelAndDeleteProduct >>>>> No payment found, deleting product.');
            if (this.productId) {
                deleteTravelInsuranceProduct({ productId: this.productId })
                    .then((hasPayment) => {
                        if (hasPayment) {
                            console.log('handleCancelAndDeleteProduct >>>>> Payment found, skipping deletion.');
                            this.handlePurchaseAPI()
                                .catch(error => {
                                    console.error('handleCancelAndDeleteProduct >>>>> Error:', error);
                                    this.displayError = displayErrorMessageProductCreated;
                                    this.handleProductCreation();
                                }); 
                        } else {
                            console.log('handleCancelAndDeleteProduct >>>>> No payment found, product deleted.');
                        }
                        this.productId = null;
                        this.firstScreen = false;
                        this.secondScreen = false;
                        this.thirdScreen = false;
                        this.fourthScreen = false;
                        this.fiveScreen = false;

                        this.dispatchEvent(new CloseActionScreenEvent());
                        this.updateRecordView();
                    })
                    .catch(error => {
                        console.error('handleCancelAndDeleteProduct >>>>> Error deleting product:', error);
                    });
            } else {
                console.log('handleCancelAndDeleteProduct >>>>> No product exists, closing modal only.');
                this.handleCancel();
            }
        }
    }

    closeQuickAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
        this.updateRecordView();
        //console.log('closeQuickAction >>>>> Closing modal - Same behavior as handleCancelAndDeleteProduct');
        //this.handleCancelAndDeleteProduct();
    }
    updateRecordView() {
        setTimeout(() => {
             eval("$A.get('e.force:refreshView').fire();");
        }, 500); 
     }
}