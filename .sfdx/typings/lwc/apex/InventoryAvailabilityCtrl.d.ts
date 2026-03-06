declare module "@salesforce/apex/InventoryAvailabilityCtrl.AvailabityByDate" {
  export default function AvailabityByDate(param: {fromDatevar: any, toDatevar: any, oppId: any, nightsInt: any, extraNightsInt: any}): Promise<any>;
}
declare module "@salesforce/apex/InventoryAvailabilityCtrl.getAllResort" {
  export default function getAllResort(param: {programName: any, PlazzaName: any, fromDateValue: any, toDateValue: any, oppId: any, nightsInt: any, extraNightsInt: any}): Promise<any>;
}
declare module "@salesforce/apex/InventoryAvailabilityCtrl.roomType" {
  export default function roomType(param: {programName: any, resoertName: any, PlazzaName: any, fromDateValue: any, toDateValue: any, oppId: any, nightsInt: any, extraNightsInt: any}): Promise<any>;
}
declare module "@salesforce/apex/InventoryAvailabilityCtrl.InventoryAvailabilityBasedOnroomType" {
  export default function InventoryAvailabilityBasedOnroomType(param: {programName: any, resoertName: any, PlazzaName: any, roomType: any, fromDateValue: any, toDateValue: any, oppId: any, nightsInt: any, extraNightsInt: any}): Promise<any>;
}
declare module "@salesforce/apex/InventoryAvailabilityCtrl.getAllProgram" {
  export default function getAllProgram(param: {programName: any, resoertName: any, PlazzaName: any, roomType: any, fromDateValue: any, toDateValue: any, oppId: any, nightsInt: any, extraNightsInt: any}): Promise<any>;
}
declare module "@salesforce/apex/InventoryAvailabilityCtrl.bookedInventoryInOppMethod" {
  export default function bookedInventoryInOppMethod(param: {selectedInvId: any, oppId: any, selectedSupplier: any, toDateValue: any, nightsInt: any, extraNightsInt: any}): Promise<any>;
}
declare module "@salesforce/apex/InventoryAvailabilityCtrl.checkbookingifExist" {
  export default function checkbookingifExist(param: {oppId: any}): Promise<any>;
}
declare module "@salesforce/apex/InventoryAvailabilityCtrl.getNumberOfNightsByOpportunityId" {
  export default function getNumberOfNightsByOpportunityId(param: {opportunityId: any}): Promise<any>;
}
declare module "@salesforce/apex/InventoryAvailabilityCtrl.checkVidantaInfluencerProducts" {
  export default function checkVidantaInfluencerProducts(param: {oppId: any}): Promise<any>;
}
