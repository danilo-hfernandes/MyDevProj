declare module "@salesforce/apex/MXVoucherProductController.getAllProductNames" {
  export default function getAllProductNames(): Promise<any>;
}
declare module "@salesforce/apex/MXVoucherProductController.AvailabityCheck" {
  export default function AvailabityCheck(param: {productName: any}): Promise<any>;
}
declare module "@salesforce/apex/MXVoucherProductController.getAllResort" {
  export default function getAllResort(param: {LocationName: any, productName: any}): Promise<any>;
}
declare module "@salesforce/apex/MXVoucherProductController.roomType" {
  export default function roomType(param: {LocationName: any, SectionName: any, productName: any}): Promise<any>;
}
declare module "@salesforce/apex/MXVoucherProductController.getAllProgram" {
  export default function getAllProgram(param: {resoertName: any, PlazzaName: any, roomType: any, productName: any}): Promise<any>;
}
declare module "@salesforce/apex/MXVoucherProductController.closeMethod" {
  export default function closeMethod(): Promise<any>;
}
declare module "@salesforce/apex/MXVoucherProductController.CreateProduct" {
  export default function CreateProduct(param: {selectedMXId: any, oppId: any, inputPrice: any, productName: any}): Promise<any>;
}
