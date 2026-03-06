declare module "@salesforce/apex/InventoryAvailabilityReBookCtrl.AvailabityByDate" {
  export default function AvailabityByDate(param: {fromDatevar: any, toDatevar: any, oppId: any, nightsInt: any, extraNightsInt: any}): Promise<any>;
}
declare module "@salesforce/apex/InventoryAvailabilityReBookCtrl.getAllProgram" {
  export default function getAllProgram(param: {programName: any, resoertName: any, PlazzaName: any, roomType: any, fromDateValue: any, toDateValue: any, oppId: any, nightsInt: any, extraNightsInt: any}): Promise<any>;
}
declare module "@salesforce/apex/InventoryAvailabilityReBookCtrl.getAllResort" {
  export default function getAllResort(param: {programName: any, PlazzaName: any, fromDateValue: any, toDateValue: any, oppId: any, nightsInt: any, extraNightsInt: any}): Promise<any>;
}
declare module "@salesforce/apex/InventoryAvailabilityReBookCtrl.roomType" {
  export default function roomType(param: {programName: any, resoertName: any, PlazzaName: any, fromDateValue: any, toDateValue: any, oppId: any, nightsInt: any, extraNightsInt: any}): Promise<any>;
}
declare module "@salesforce/apex/InventoryAvailabilityReBookCtrl.InventoryAvailabilityBasedOnroomType" {
  export default function InventoryAvailabilityBasedOnroomType(param: {programName: any, resoertName: any, PlazzaName: any, roomType: any, fromDateValue: any, toDateValue: any, oppId: any, nightsInt: any, extraNightsInt: any}): Promise<any>;
}
declare module "@salesforce/apex/InventoryAvailabilityReBookCtrl.bookedInventoryInOppMethod" {
  export default function bookedInventoryInOppMethod(param: {selectedInvId: any, oppId: any, nightsInt: any, extraNightsInt: any}): Promise<any>;
}
declare module "@salesforce/apex/InventoryAvailabilityReBookCtrl.checkbookingifExist" {
  export default function checkbookingifExist(param: {oppId: any}): Promise<any>;
}
declare module "@salesforce/apex/InventoryAvailabilityReBookCtrl.getNumberOfNightsByOpportunityId" {
  export default function getNumberOfNightsByOpportunityId(param: {opportunityId: any}): Promise<any>;
}
