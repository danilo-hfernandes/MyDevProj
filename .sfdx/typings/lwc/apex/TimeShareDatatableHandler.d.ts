declare module "@salesforce/apex/TimeShareDatatableHandler.getTimeShare" {
  export default function getTimeShare(param: {OppId: any}): Promise<any>;
}
declare module "@salesforce/apex/TimeShareDatatableHandler.addToOpportunity" {
  export default function addToOpportunity(param: {OppId: any, timeShareId: any}): Promise<any>;
}
