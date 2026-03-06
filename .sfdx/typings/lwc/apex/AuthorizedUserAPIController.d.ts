declare module "@salesforce/apex/AuthorizedUserAPIController.getAuthorizedUserRecords" {
  export default function getAuthorizedUserRecords(param: {accountId: any}): Promise<any>;
}
declare module "@salesforce/apex/AuthorizedUserAPIController.getAuthorizedUser" {
  export default function getAuthorizedUser(param: {accountId: any}): Promise<any>;
}
declare module "@salesforce/apex/AuthorizedUserAPIController.postAuthorizedUser" {
  export default function postAuthorizedUser(param: {accountId: any, firstName: any, lastName: any, email: any, emailConfirmation: any, phone: any, country: any, isEnabled: any}): Promise<any>;
}
declare module "@salesforce/apex/AuthorizedUserAPIController.changeAuthorizedUserStatus" {
  export default function changeAuthorizedUserStatus(param: {authorizedUserId: any, isEnabled: any}): Promise<any>;
}
