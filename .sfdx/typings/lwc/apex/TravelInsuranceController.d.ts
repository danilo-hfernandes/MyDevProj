declare module "@salesforce/apex/TravelInsuranceController.validateRecord" {
  export default function validateRecord(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/TravelInsuranceController.hitProductCreation" {
  export default function hitProductCreation(param: {recordId: any, netPrice: any, quoteId: any}): Promise<any>;
}
declare module "@salesforce/apex/TravelInsuranceController.hitQuoteAPI" {
  export default function hitQuoteAPI(param: {recordId: any, firstName: any, lastName: any, street: any, city: any, state: any, country: any, email: any, startDate: any, endDate: any, destination: any, travelerData: any}): Promise<any>;
}
declare module "@salesforce/apex/TravelInsuranceController.hitPurchaseAPI" {
  export default function hitPurchaseAPI(param: {recordId: any, quoteId: any, productId: any}): Promise<any>;
}
declare module "@salesforce/apex/TravelInsuranceController.deleteTravelInsuranceProduct" {
  export default function deleteTravelInsuranceProduct(param: {productId: any}): Promise<any>;
}
