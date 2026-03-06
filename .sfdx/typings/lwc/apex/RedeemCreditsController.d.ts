declare module "@salesforce/apex/RedeemCreditsController.getCreditsData" {
  export default function getCreditsData(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/RedeemCreditsController.createPaymentRecord" {
  export default function createPaymentRecord(param: {recordId: any, applyCredits: any, actualCreditBalance: any}): Promise<any>;
}
