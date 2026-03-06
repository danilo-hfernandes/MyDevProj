declare module "@salesforce/apex/DepositsRecords.getCases" {
  export default function getCases(param: {parentCaseId: any}): Promise<any>;
}
declare module "@salesforce/apex/DepositsRecords.getParentCaseDetails" {
  export default function getParentCaseDetails(param: {parentCaseId: any}): Promise<any>;
}
declare module "@salesforce/apex/DepositsRecords.createLinkedCase" {
  export default function createLinkedCase(param: {parentCaseId: any, childCaseId: any, balanceAmount: any, timeshareId: any, points: any}): Promise<any>;
}
declare module "@salesforce/apex/DepositsRecords.fetchInventoryData" {
  export default function fetchInventoryData(param: {caseRecordId: any}): Promise<any>;
}
declare module "@salesforce/apex/DepositsRecords.fetchAccountAndCaseDetails" {
  export default function fetchAccountAndCaseDetails(param: {leadId: any}): Promise<any>;
}
declare module "@salesforce/apex/DepositsRecords.timeShareRecords" {
  export default function timeShareRecords(param: {caseRecordId: any}): Promise<any>;
}
declare module "@salesforce/apex/DepositsRecords.getMFPValue" {
  export default function getMFPValue(param: {timeshareId: any}): Promise<any>;
}
declare module "@salesforce/apex/DepositsRecords.updateCaseData" {
  export default function updateCaseData(param: {caseRecords: any, timeshareId: any}): Promise<any>;
}
