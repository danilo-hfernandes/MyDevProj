declare module "@salesforce/apex/ApplyCreditsController.tryToGetCreditsData" {
  export default function tryToGetCreditsData(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/ApplyCreditsController.tryToUseCredits" {
  export default function tryToUseCredits(param: {creditsData: any, recordId: any}): Promise<any>;
}
