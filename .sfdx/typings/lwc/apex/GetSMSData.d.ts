declare module "@salesforce/apex/GetSMSData.getMessagingSessions" {
  export default function getMessagingSessions(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/GetSMSData.getConversationEntriesThread" {
  export default function getConversationEntriesThread(param: {sessionId: any, pageSize: any, pageNumber: any}): Promise<any>;
}
