declare module "@salesforce/apex/CustomAddProductsController.checkOppLineItemCreatePermission" {
  export default function checkOppLineItemCreatePermission(): Promise<any>;
}
declare module "@salesforce/apex/CustomAddProductsController.fetchPriceBookEntries" {
  export default function fetchPriceBookEntries(param: {oppId: any}): Promise<any>;
}
declare module "@salesforce/apex/CustomAddProductsController.generateOppLineItems" {
  export default function generateOppLineItems(param: {pbeList: any, oppId: any}): Promise<any>;
}
declare module "@salesforce/apex/CustomAddProductsController.saveOppLineItems" {
  export default function saveOppLineItems(param: {oliList: any}): Promise<any>;
}
