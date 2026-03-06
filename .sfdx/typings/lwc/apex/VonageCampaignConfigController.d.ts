declare module "@salesforce/apex/VonageCampaignConfigController.getConfigurations" {
  export default function getConfigurations(): Promise<any>;
}
declare module "@salesforce/apex/VonageCampaignConfigController.getCampaignOptions" {
  export default function getCampaignOptions(): Promise<any>;
}
declare module "@salesforce/apex/VonageCampaignConfigController.getTriggerFieldOptions" {
  export default function getTriggerFieldOptions(param: {sObjectApiName: any}): Promise<any>;
}
declare module "@salesforce/apex/VonageCampaignConfigController.getChildObjects" {
  export default function getChildObjects(param: {parentSObjectApiName: any}): Promise<any>;
}
declare module "@salesforce/apex/VonageCampaignConfigController.saveConfiguration" {
  export default function saveConfiguration(param: {req: any}): Promise<any>;
}
