declare module "@salesforce/apex/TimeshareDetailsWithProduct.saveProductLineItem" {
  export default function saveProductLineItem(param: {proWrapperlist: any, OppId: any, timeshareId: any, productId: any, timeshareNumber: any}): Promise<any>;
}
declare module "@salesforce/apex/TimeshareDetailsWithProduct.saveProductLineItemMTRC" {
  export default function saveProductLineItemMTRC(param: {proWrapperlist: any, OppId: any, productId: any}): Promise<any>;
}
declare module "@salesforce/apex/TimeshareDetailsWithProduct.AllActiveProductList" {
  export default function AllActiveProductList(param: {oppId: any, timeshareIdentifier: any}): Promise<any>;
}
declare module "@salesforce/apex/TimeshareDetailsWithProduct.AllActiveMTRCProductList" {
  export default function AllActiveMTRCProductList(): Promise<any>;
}
declare module "@salesforce/apex/TimeshareDetailsWithProduct.timeshareWrapper" {
  export default function timeshareWrapper(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/TimeshareDetailsWithProduct.timesharDelete" {
  export default function timesharDelete(param: {timeshareId: any, oppId: any, timeshareNumber: any}): Promise<any>;
}
declare module "@salesforce/apex/TimeshareDetailsWithProduct.saveSelectedTimeshare" {
  export default function saveSelectedTimeshare(param: {timeshareId: any, oppId: any}): Promise<any>;
}
declare module "@salesforce/apex/TimeshareDetailsWithProduct.selectedTimeshare" {
  export default function selectedTimeshare(param: {timeshareId: any}): Promise<any>;
}
declare module "@salesforce/apex/TimeshareDetailsWithProduct.timesharRecordDetails" {
  export default function timesharRecordDetails(param: {timeshareId: any}): Promise<any>;
}
declare module "@salesforce/apex/TimeshareDetailsWithProduct.updateOpportunity" {
  export default function updateOpportunity(param: {timeshareId: any, oppId: any}): Promise<any>;
}
