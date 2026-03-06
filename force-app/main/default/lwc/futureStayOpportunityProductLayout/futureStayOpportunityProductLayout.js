import { LightningElement , api} from 'lwc';
import NAME_FIELD from '@salesforce/schema/OpportunityLineItem.Name';
import Quantity_FIELD from '@salesforce/schema/OpportunityLineItem.Quantity';
import RPrice_FIELD from '@salesforce/schema/OpportunityLineItem.Retail_Price__c';
import ProductCode from '@salesforce/schema/OpportunityLineItem.ProductCode';
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
import Rev_Share_HSI__c from '@salesforce/schema/OpportunityLineItem.Rev_Share_HSI__c';
import Rev_Share_Vendor__c from '@salesforce/schema/OpportunityLineItem.Rev_Share_Vendor__c';
import Timeshare__c from '@salesforce/schema/OpportunityLineItem.Timeshare__c';
import LineDescription from '@salesforce/schema/OpportunityLineItem.Description';
import Booking_Date__c from '@salesforce/schema/OpportunityLineItem.Booking_Date__c';
import Check_In_Date__c from '@salesforce/schema/OpportunityLineItem.Check_In_Date__c';
import Check_Out_Date__c from '@salesforce/schema/OpportunityLineItem.Check_Out_Date__c';
import Confirmation_Number__c from '@salesforce/schema/OpportunityLineItem.Confirmation_Number__c';
import HSI_Cost__c from '@salesforce/schema/OpportunityLineItem.HSI_Cost__c';
import Inventory_Id__c from '@salesforce/schema/OpportunityLineItem.Inventory_Id__c';
import Product_Type__c from '@salesforce/schema/OpportunityLineItem.Product_Type__c';
import Request_Id__c from '@salesforce/schema/OpportunityLineItem.Request_Id__c';
import Request_Id2__c from '@salesforce/schema/OpportunityLineItem.Request_Id2__c';
import Resort_Name__c from '@salesforce/schema/OpportunityLineItem.Resort_Name__c';
import Sale_Created_By__c from '@salesforce/schema/OpportunityLineItem.Sale_Created_By__c';
import Sale_Date__c from '@salesforce/schema/OpportunityLineItem.Sale_Date__c';
import Sale_Inventory_Id__c from '@salesforce/schema/OpportunityLineItem.Sale_Inventory_Id__c';
import Listing_ID__c from '@salesforce/schema/OpportunityLineItem.Listing_ID__c';
import Inventory_Source__c from '@salesforce/schema/OpportunityLineItem.Inventory_Source__c';
export default class futureStayOpportunityProductLayout extends LightningElement {
    @api recordId;
    @api objectApiName;
    fields = [OpportunityId,Product_Id__c,Product2Id,ServiceDate,RPrice_FIELD,ProductCode,ListPrice,Quantity_FIELD,TotalPrice, CreatedById,CreatedDate,LastModifiedById,LastModifiedDate,NAME_FIELD,Subtotal,Rev_Share_HSI__c,Rev_Share_Vendor__c,Timeshare__c,LineDescription,Booking_Date__c,Check_In_Date__c,Check_Out_Date__c,Confirmation_Number__c,HSI_Cost__c,Inventory_Id__c,Inventory_Source__c,Listing_ID__c,Product_Type__c,Request_Id__c,Request_Id2__c,Resort_Name__c,Sale_Created_By__c,Sale_Date__c,Sale_Inventory_Id__c];
    handleSubmit(event){
        console.log('OpportunityLineItem detail : ',event.detail.fields);
        console.log('OpportunityLineItem name : ',event.detail.fields.Name);
    }

}