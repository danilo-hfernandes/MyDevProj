declare module "@salesforce/apex/InventoryAvailabilitySearchCtrl.checkUserPermission" {
  export default function checkUserPermission(): Promise<any>;
}
declare module "@salesforce/apex/InventoryAvailabilitySearchCtrl.AvailabityByDate" {
  export default function AvailabityByDate(param: {fromDatevar: any, toDatevar: any, oppId: any, nightsInt: any, extraNightsInt: any}): Promise<any>;
}
declare module "@salesforce/apex/InventoryAvailabilitySearchCtrl.getAllResort" {
  export default function getAllResort(param: {programName: any, PlazzaName: any, fromDateValue: any, toDateValue: any, oppId: any, nightsInt: any, extraNightsInt: any}): Promise<any>;
}
declare module "@salesforce/apex/InventoryAvailabilitySearchCtrl.roomType" {
  export default function roomType(param: {programName: any, resoertName: any, PlazzaName: any, fromDateValue: any, toDateValue: any, oppId: any, nightsInt: any, extraNightsInt: any}): Promise<any>;
}
declare module "@salesforce/apex/InventoryAvailabilitySearchCtrl.InventoryAvailabilityBasedOnroomType" {
  export default function InventoryAvailabilityBasedOnroomType(param: {programName: any, resoertName: any, PlazzaName: any, roomType: any, fromDateValue: any, toDateValue: any, oppId: any, nightsInt: any, extraNightsInt: any}): Promise<any>;
}
declare module "@salesforce/apex/InventoryAvailabilitySearchCtrl.getAllProgram" {
  export default function getAllProgram(param: {programName: any, resoertName: any, PlazzaName: any, roomType: any, fromDateValue: any, toDateValue: any, oppId: any, nightsInt: any, extraNightsInt: any}): Promise<any>;
}
