declare module "@salesforce/apex/CadenceScheduleController.getObjects" {
  export default function getObjects(): Promise<any>;
}
declare module "@salesforce/apex/CadenceScheduleController.getFields" {
  export default function getFields(param: {objectName: any}): Promise<any>;
}
declare module "@salesforce/apex/CadenceScheduleController.getPicklistValues" {
  export default function getPicklistValues(param: {objectName: any, fieldName: any}): Promise<any>;
}
declare module "@salesforce/apex/CadenceScheduleController.getMatchGroups" {
  export default function getMatchGroups(param: {objectName: any}): Promise<any>;
}
declare module "@salesforce/apex/CadenceScheduleController.getCadences" {
  export default function getCadences(param: {objectName: any}): Promise<any>;
}
declare module "@salesforce/apex/CadenceScheduleController.saveCadenceSchedule" {
  export default function saveCadenceSchedule(param: {config: any}): Promise<any>;
}
