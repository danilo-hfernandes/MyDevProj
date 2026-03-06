declare module "@salesforce/apex/InventoryAvailabilitySearch.getAvailabityByDate" {
  export default function getAvailabityByDate(param: {fromDate: any, toDate: any, oppId: any, nights: any, extraNights: any}): Promise<any>;
}
declare module "@salesforce/apex/InventoryAvailabilitySearch.getAllResortName" {
  export default function getAllResortName(param: {programName: any, PlazzaName: any, fromDateValue: any, toDateValue: any, oppId: any, nights: any, extraNights: any}): Promise<any>;
}
declare module "@salesforce/apex/InventoryAvailabilitySearch.getroomType" {
  export default function getroomType(param: {programName: any, resoertName: any, PlazzaName: any, fromDateValue: any, toDateValue: any, oppId: any, nights: any, extraNights: any}): Promise<any>;
}
declare module "@salesforce/apex/InventoryAvailabilitySearch.InventoryAvailabilityBasedOnroomType" {
  export default function InventoryAvailabilityBasedOnroomType(param: {programName: any, resoertName: any, PlazzaName: any, roomType: any, fromDateValue: any, toDateValue: any, oppId: any, nights: any, extraNights: any}): Promise<any>;
}
declare module "@salesforce/apex/InventoryAvailabilitySearch.getAllProgram" {
  export default function getAllProgram(param: {programName: any, resoertName: any, PlazzaName: any, roomType: any, fromDateValue: any, toDateValue: any, oppId: any, nights: any, extraNights: any}): Promise<any>;
}
