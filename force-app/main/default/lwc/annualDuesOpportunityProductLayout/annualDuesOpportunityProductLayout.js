import { LightningElement , api} from 'lwc';
import NAME_FIELD from '@salesforce/schema/OpportunityLineItem.Name';
import Quantity_FIELD from '@salesforce/schema/OpportunityLineItem.Quantity';
import RPrice_FIELD from '@salesforce/schema/OpportunityLineItem.Retail_Price__c';
import OpportunityId from '@salesforce/schema/OpportunityLineItem.OpportunityId';
import CreatedById from '@salesforce/schema/OpportunityLineItem.CreatedById';
import CreatedDate from '@salesforce/schema/OpportunityLineItem.CreatedDate';
import ServiceDate from '@salesforce/schema/OpportunityLineItem.ServiceDate';
import ListPrice from '@salesforce/schema/OpportunityLineItem.ListPrice';
import Product_Id__c from '@salesforce/schema/OpportunityLineItem.Product_Id__c';
import Product2Id from '@salesforce/schema/OpportunityLineItem.Product2Id';
import TotalPrice from '@salesforce/schema/OpportunityLineItem.TotalPrice';
import Subtotal from '@salesforce/schema/OpportunityLineItem.Subtotal';
import LastModifiedById from '@salesforce/schema/OpportunityLineItem.LastModifiedById';
import LastModifiedDate from '@salesforce/schema/OpportunityLineItem.LastModifiedDate';
export default class AnnualDuesOpportunityProductLayout extends LightningElement {
    @api recordId;
    @api objectApiName;
    fields = [OpportunityId,Product_Id__c,Product2Id,ServiceDate,RPrice_FIELD,ListPrice,Quantity_FIELD,TotalPrice, CreatedById,CreatedDate,LastModifiedById,LastModifiedDate,NAME_FIELD,Subtotal];
    handleSubmit(event){
        console.log('OpportunityLineItem detail : ',event.detail.fields);
        console.log('OpportunityLineItem name : ',event.detail.fields.Name);
    }

}