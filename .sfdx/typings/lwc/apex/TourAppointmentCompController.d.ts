declare module "@salesforce/apex/TourAppointmentCompController.getTourAppointment" {
  export default function getTourAppointment(param: {opportunityId: any}): Promise<any>;
}
declare module "@salesforce/apex/TourAppointmentCompController.createRebookTourAppointment" {
  export default function createRebookTourAppointment(param: {oppRecordId: any, tourRecordId: any, teeUpAgentId: any, closingAgentId: any}): Promise<any>;
}
declare module "@salesforce/apex/TourAppointmentCompController.getToursByDateTime" {
  export default function getToursByDateTime(param: {selectedDate: any, selectedTime: any}): Promise<any>;
}
declare module "@salesforce/apex/TourAppointmentCompController.getActiveUsers" {
  export default function getActiveUsers(): Promise<any>;
}
