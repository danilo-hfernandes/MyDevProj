declare module "@salesforce/apex/BookReservationMarivalController.getPlazaRecords" {
  export default function getPlazaRecords(param: {supplier: any}): Promise<any>;
}
declare module "@salesforce/apex/BookReservationMarivalController.getInventoryRecords" {
  export default function getInventoryRecords(param: {supplier: any, plaza: any}): Promise<any>;
}
declare module "@salesforce/apex/BookReservationMarivalController.saveOpportunityDetails" {
  export default function saveOpportunityDetails(param: {recordId: any, inventoryId: any, roomType: any, checkIn: any, checkOut: any, capacity: any, adults: any, children: any, supplier: any, extraNights: any}): Promise<any>;
}
declare module "@salesforce/apex/BookReservationMarivalController.checkbookingifExist" {
  export default function checkbookingifExist(param: {oppId: any}): Promise<any>;
}
declare module "@salesforce/apex/BookReservationMarivalController.getNumberOfNightsByOpportunityId" {
  export default function getNumberOfNightsByOpportunityId(param: {opportunityId: any}): Promise<any>;
}
declare module "@salesforce/apex/BookReservationMarivalController.getExtraNight" {
  export default function getExtraNight(param: {sitename: any}): Promise<any>;
}
