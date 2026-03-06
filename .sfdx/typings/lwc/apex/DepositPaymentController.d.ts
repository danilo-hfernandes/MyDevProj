declare module "@salesforce/apex/DepositPaymentController.getPaymentDetails" {
  export default function getPaymentDetails(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/DepositPaymentController.savePaymentRecord" {
  export default function savePaymentRecord(param: {payment: any, recId: any}): Promise<any>;
}
