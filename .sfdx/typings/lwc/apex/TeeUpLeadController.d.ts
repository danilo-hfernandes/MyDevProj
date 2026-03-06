declare module "@salesforce/apex/TeeUpLeadController.fetchOldAgentName" {
  export default function fetchOldAgentName(param: {leadId: any}): Promise<any>;
}
declare module "@salesforce/apex/TeeUpLeadController.getDivisions" {
  export default function getDivisions(): Promise<any>;
}
declare module "@salesforce/apex/TeeUpLeadController.getAgentsByDivision" {
  export default function getAgentsByDivision(param: {divisionId: any}): Promise<any>;
}
declare module "@salesforce/apex/TeeUpLeadController.updateLead" {
  export default function updateLead(param: {recordId: any, divisionId: any, divisionName: any, selectedAgentName: any, selectedAgentExternalId: any}): Promise<any>;
}
