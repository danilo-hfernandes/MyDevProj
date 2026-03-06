import { LightningElement,track, api} from 'lwc';
import validateCertificateId from '@salesforce/apex/CertificateComponentController.validateCertificateId';
import createOpportunity from '@salesforce/apex/CertificateComponentController.createOpportunity';
export default class CertificateComponent extends LightningElement {
    @track certificateId;
    @api recordId;
    dispayMessage;
    isLoading = false;
    @track hideButton = false;
    @track certificatelist;
    @track certificateSFId;
    @track columns = [{
        label: 'Certificate ID',
        fieldName: 'Certificate_ID__c',
        type: 'text',
        hideDefaultActions: true
    },
    {
        label: 'Certificate Redeemed',
        fieldName: 'Certificate_Redeemed__c',
        type: 'text',
        hideDefaultActions: true
    },
    {
        label: 'Expiration Date',
        fieldName: 'Expiration_Date__c',
        type: 'Date',
        hideDefaultActions: true
    }
];
    handleCertificateId(event){
        console.log('>>>event.value',event.detail.value);
        this.certificateId = event.detail.value;
    }
    validateCertificate() {
        console.log('Inside validate certificate');
        console.log('>>>>>>>contactIds>>>>>>'+this.certificateId);
        // to close modal set isModalOpen tarck value as false
        //Add your code to call apex method or do some processing
        if(this.certificateId == null){
            this.dispayMessage = 'Enter the valid certificate Id';
        }
        else{
            this.dispayMessage = '';
            this.isLoading = true;
            let date = new Date().toJSON().slice(0, 10);
            validateCertificateId({certificateId : this.certificateId})
            .then((result) => {
                if(result != null){
                    console.log('>>>>>>>result>>>>',result);
                    console.log('>>>>>>result.Certificate_Redeemed__c>>>>>>>',result[0].Certificate_Redeemed__c);
                    console.log('>>>>>>result.Expiration_Date__c>>>>>>>',result[0].Expiration_Date__c);
                    console.log('>>>>>>today>>>>>>>',date);
                    if(result[0].Certificate_Redeemed__c){
                        this.dispayMessage = 'Certificate ID already redeemed';
                    }
                   /* else if(result[0].Expiration_Date__c < date){
                        this.dispayMessage = 'Certificate ID Expired!';
                    }*/
                    else{
                        this.hideButton = true;
                        this.certificatelist = result;
                        this.certificateSFId = result[0].Id;
                        console.log('>>>>',this.certificatelist);
                    }
                    this.isLoading = false;
                } 
                else {
                    this.dispayMessage = 'No record found!';
                    this.isLoading = false;
                }
            })
            .catch((error) => {
                console.log('>>>>>>>error>>>>',error);
                this.isLoading = false;
                this.dispayMessage = error;
            });
        }
    }
    createOpportunity(){
        console.log('Inside Create Opportunity');
        console.log('>>>>>>>contactIds>>>>>>'+this.certificateId);
        // to close modal set isModalOpen tarck value as false
        //Add your code to call apex method or do some processing
        if(this.certificateId == null){
            this.dispayMessage = 'Enter the valid certificate Id';
        }
        else{ 
            this.dispayMessage = '';
            this.isLoading = true;
            createOpportunity({accountId : this.recordId, productType : this.certificateId, certificateSFId : this.certificateSFId})
            .then((result) => {
                if(result != null && result == 'Success'){
                    console.log('>>>>>>>result>>>>',result);
                    this.isLoading = false;
                    this.hideButton = false;
                    this.certificateId = '';
                    this.certificatelist=[];
                    this.updateRecordView();
                }
                else{
                    this.dispayMessage = result;
                    this.isLoading = false;
                    this.updateRecordView(); 
                } 
            })
            .catch((error) => {
                console.log('>>>>>>>error>>>>',error);
                this.isLoading = false;
                this.dispayMessage = error;
            });
        }
    }
    updateRecordView() {
        setTimeout(() => {
             eval("$A.get('e.force:refreshView').fire();");
        }, 500); 
     }
}