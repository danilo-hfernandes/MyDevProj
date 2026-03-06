declare module "@salesforce/apex/MXVoucherAvailabilitySearch.getProductDetails" {
  export default function getProductDetails(): Promise<any>;
}
declare module "@salesforce/apex/MXVoucherAvailabilitySearch.getAvailabity" {
  export default function getAvailabity(param: {productName: any}): Promise<any>;
}
declare module "@salesforce/apex/MXVoucherAvailabilitySearch.getAllResortName" {
  export default function getAllResortName(param: {LocationName: any, productName: any}): Promise<any>;
}
declare module "@salesforce/apex/MXVoucherAvailabilitySearch.getroomSize" {
  export default function getroomSize(param: {LocationName: any, SectionName: any, productName: any}): Promise<any>;
}
declare module "@salesforce/apex/MXVoucherAvailabilitySearch.getAllProgram" {
  export default function getAllProgram(param: {resoertName: any, PlazzaName: any, roomType: any, productName: any}): Promise<any>;
}
