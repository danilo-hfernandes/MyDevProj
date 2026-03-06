import { LightningElement, api } from 'lwc';

export default class AirFareOpportunityProductLayout extends LightningElement {
    @api recordId;

    fields = [

        'OpportunityId',
        'Travel_Apply_Credits__c',
        'Product2Id',
        'Product_Id__c',
        'Retail_Price__c',
        'ServiceDate',      
        'Quantity',
        'ProductCode',
        'Booking_Date__c',
        'ListPrice',
        'Closed_Date_String__c',

        'TotalPrice',

//        'PG_Id__c',
        'Auto_Id__c',

        
        'HSI_Policy_Number__c',
        'Sales_Price__c',
        'Insurance_cost__c',
        'Insured_amount__c',
        'Insurance_provider__c',


        'CreatedById',
        'CreatedDate',
        'LastModifiedById',
        'LastModifiedDate',


        'Guest_Name__c',
        'Confirmation_Number__c',
        'Check_In_Date__c',
        'Check_Out_Date__c',
        'HSI_Cost__c',
        'Name',


        'Product_Type__c',
        'Request_Assigned_To__c',
        'Requested_By__c',
        'Request_Id__c',
        'Travel_Invoice_Id__c',
        'Subtotal'

    ];
}