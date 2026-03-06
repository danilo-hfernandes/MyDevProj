import { LightningElement, api,track,wire } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { getRecord,getFieldValue } from 'lightning/uiRecordApi';
import { loadScript } from 'lightning/platformResourceLoader';
import nodeForge from '@salesforce/resourceUrl/nodeForge';
import bufferLib from '@salesforce/resourceUrl/bufferLib';
import hitSubmissionAPI from '@salesforce/apex/MonsterProductsWebservice.hitSubmissionAPI';
const FIELDS = [
    'Opportunity.Account.First_Name__c',
    'Opportunity.Account.Last_Name__c',
    'Opportunity.Account.BillingStreet',
    'Opportunity.Account.BillingCity',
    'Opportunity.Account.BillingState',
    'Opportunity.Account.BillingCountry',
    'Opportunity.Account.BillingPostalCode',
    'Opportunity.Account.Email__c',
    'Opportunity.Account.Phone',
    'Opportunity.Amount'
];
export default class MonsterPaymentComponent extends LightningElement {
    @api recordId;
    @track displayMessage;
    isLoading = false;
    nodeForgeInitialized = false;
    bufferLibInitialized = false;
    cardType;
    cardNumber;
    cardExp;
    cardCVV;
    @track firstName = '';
    @track lastName = '';
    @track street = '';
    @track city = '';
    @track state = '';
    @track country = '';
    @track email = '';
    @track phone = '';
    @track zipCode = '';
    @track flag = true;
    @track totalAmount = 0.0;
    handleInputChange(event) {
        const field = event.target.dataset.id;
        console.log('>>>>>field>>>'+field);
        console.log('>>>>>event.target.value>>>'+event.target.value);
        if (field) {
            this[field] = event.target.value;
        }
        if(field == 'flag'){
            this[field] =  event.target.checked;
        }
        console.log('>>>>>'+this.flag);
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
            this.state = getFieldValue(data,'Opportunity.Account.BillingState');
            this.country = getFieldValue(data,'Opportunity.Account.BillingCountry');
            this.phone = getFieldValue(data,'Opportunity.Account.Phone');
            this.zipCode = getFieldValue(data,'Opportunity.Account.BillingPostalCode');
            this.email = getFieldValue(data,'Opportunity.Account.Email__c');
            this.totalAmount = getFieldValue(data, 'Opportunity.Amount')
            console.log('>>>firstName>>>',this.firstName);

        } else if (error) {
            console.error('Error loading record', error);
            this.displayMessage = error;
        }
    }
    connectedCallback(){
        console.log('>>>>Hiii>>>>'+ this.recordId);
        if (this.nodeForgeInitialized) {
            return;
        }
        this.nodeForgeInitialized = true;

        Promise.all([
            loadScript(this, nodeForge + '/node-forge/dist/forge.min.js'),
        ])
        .then(() => {
            console.log('Node-Forge loaded successfully.');
            // You can now use Node-Forge here
            const forge = window.forge;
        })
        .catch(error => {
            console.error('Error loading Node-Forge', error);
        });
        if (this.bufferLibInitialized) {
            return;
        }
        this.bufferLibInitialized = true;

        // Load the Buffer library
        loadScript(this, bufferLib + '/buffer.min.js')
            .then(() => {
                console.log('Buffer library loaded successfully.');
                // Ensure Buffer is available globally
                window.Buffer = buffer.Buffer;
            })
            .catch(error => {
                console.error('Error loading Buffer library', error);
            });
    }
    handleEncrypt() {
        const requiredFields = this.template.querySelectorAll('lightning-input');
        let isValid = true;
        requiredFields.forEach(field => {
            if (!field.checkValidity()) {
                field.reportValidity();
                isValid = false;
            }
        });
        if (isValid) {
            this.isLoading = true;
            //console.log('>>>>Hiii>>>>'+this.cardNumber);
            //console.log('>>>>Hiii>>>>'+this.cardExp);
            const publicRsaKey ='LS0tLS1CRUdJTiBQVUJMSUMgS0VZLS0tLS0NCk1JSUJJakFOQmdrcWhraUc5dzBCQVFFRkFBT0NBUThBTUlJQkNnS0NBUUVBcDdlNDcxNXJacHRBZUEvV21MaW0NCjVBZDJCbldoWnQ0WlBpb3I3d2RSSXNXVjM4dy9Ja1V6MktCOWxoNDB6ZHNyUU9rZVdMdEo5dlV0Z1UzS1lqblANCjVzNUgzcmFWVUV2VWkyYmVtZEdUSklEbGJTMFg4Z3l3UUVWZ05jNm1wMzY5b2JuZHBrK3hoTkdjdVpFZHoxczcNCmVDc3E0Wm9KaDdQN3Z1VkFxc3MxQmZUcWdQOElaOWR2RWZtekUxQ0QrV001ekZLYjh2a0pOODZqYzBWTUtmKy8NCkNLSWFaTUNUYVBzUFQrVExPdS94bnJwWUpxTllBc0wvdTVPVGZaeU9DVWxqTzVzN1dLaldyWGE0YkM2VFJYeEINCjNsaVpPREV6RkFGVGU3T2szU20vZ25nWTlmM1NubXlaTDE3QWsyT2N6QlZueWR5dHNQT1BpeUNsNGxrckZiUUkNClN3SURBUUFCDQotLS0tLUVORCBQVUJMSUMgS0VZLS0tLS0NCg==';
            //console.log('>>>>Hiii>>>>'+publicRsaKey);
            const card = {
                ccNum: this.cardNumber,
                exp: this.cardExp,
                cvv: this.cardCVV,
            };
            window.Buffer = buffer.Buffer;
            console.log('>>>>Hiii>>>>',card);
            let pem = Buffer.from(publicRsaKey, "base64").toString();//this.convertBase64ToPem(publicRsaKey);
            //console.log('>>>>pem>>>>'+pem);
            const Forge = window.forge;
            if (!Forge) {
                console.error('Node-Forge is not loaded.');
                return;
            }
            
            try {
                let rsa = Forge.pki.publicKeyFromPem(pem);
                console.log('RSA Public Key:', rsa);
                // Encrypt the card object
                let encrypted = Forge.util.encode64(rsa.encrypt(JSON.stringify(card)));
                //console.log('Encrypted Message:', encrypted);
                
            console.log('Submission clicked'+this.zipCode);
            hitSubmissionAPI({ oppId : this.recordId, token : encrypted, cardNumber : this.cardNumber, cardExp : this.cardExp, cardType : this.cardType, flag : this.flag, firstName : this.firstName, lastName : this.lastName, street :this.street, city :this.city, state : this.state, country : this.country, zipCode : this.zipCode, email : this.email, phone : this.phone})
                .then((result) => {
                    console.log('>>>>>>>result>>>>'+result);
                    this.isLoading = false;

                    if(result != null && result == 'Success'){
                        console.log('>>>>>>>result>>>>'+result);
                        this.isLoading = false;
                        this.displayMessage = '';
                        this.cardNumber = '';
                        this.cardExp ='';
                        this.cardCVV ='';
                        this.cardType ='';
                        this.closeQuickAction();
                    }
                    else {
                        this.displayMessage = result;
                        this.isLoading = false;
                    }
                })
                .catch((error) => {
                    console.log('>>>>>>>error>>>>',error);
                    this.isLoading = false;
                }); 
            } catch (error) {
                console.error('Error during encryption:', error);
            }
        }
    }
    closeQuickAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
        this.updateRecordView();
    }
    updateRecordView() {
        setTimeout(() => {
             eval("$A.get('e.force:refreshView').fire();");
        }, 500); 
    }
    handleCancel() {
        // Handle the cancel action here
        // You might want to reset the form or navigate away
        console.log('Cancel clicked');
        this.dispatchEvent(new CloseActionScreenEvent());
        this.updateRecordView();
    }
}