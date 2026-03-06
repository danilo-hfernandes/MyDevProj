public class InvoiceTriggerHandler {
    
    Public Static boolean allow = true;
    
    public static void stopTrigger(){
        allow = false;
    }
    
    public static boolean executeMethod(){
        return allow;
    }
    
    @future(callout = true) 
    public static void updateInvoiceOpportunity(Set<Id> invoiceId) {
        try{
            List<Invoice__c> invoiceList = [select id,Confirmation__c,Reservation_Status__c,Invoice_Amount__c,Opportunity__c from Invoice__c where Id In : invoiceId];
            
            Set<String> confirmationNumberSet = new Set<String>(); 
            List<Opportunity> oppList = new List<Opportunity>();
            Map<String,String> confirmationNumberWithstatus = new Map<String,String>();
            for(Invoice__c inc: invoiceList){
                if(inc.Confirmation__c != null){
                    confirmationNumberSet.add(inc.Confirmation__c);
                    if(inc.Reservation_Status__c == 'NoShow' || inc.Reservation_Status__c == 'Complete'){
                        confirmationNumberWithstatus.put(inc.Confirmation__c, 'Confirmed');
                    }else if(inc.Reservation_Status__c == 'Canceled'){
                        confirmationNumberWithstatus.put(inc.Confirmation__c, 'Cancel');
                    }
                }
            }
            
            if(confirmationNumberSet != null && confirmationNumberSet.size() > 0){
                
                Map<String,String> confirmationNumberWithOppIdMap = new Map<String,String>();
                Map<String,String> confirmationNumberWithStatusIdMapConfirmed = new Map<String,String>();
                Map<String,String> confirmationNumberWithStatusIdMapCancel = new Map<String,String>();
                Map<Id,Opportunity> oppMapToUpdate = New Map<Id,Opportunity>();
                Set<Id> oppIdSet = new Set<Id>(); 
                List<Reservation_Tracking_Object__c> reservationTrackingList = [Select Id,Reservation_Status__c,Opportunity__c,Confirmation_Number__c from Reservation_Tracking_Object__c where Confirmation_Number__c IN: confirmationNumberSet and Reservation_Status__c != 'Pending'];
                if(reservationTrackingList != null && reservationTrackingList.size() > 0){
                    for(Reservation_Tracking_Object__c rto : reservationTrackingList){
                        oppIdSet.add(rto.Opportunity__c);
                        
                        if(rto.Reservation_Status__c == 'Confirmed'){
                            confirmationNumberWithStatusIdMapConfirmed.put(rto.Confirmation_Number__c,rto.Reservation_Status__c);
                        }
                        else if(rto.Reservation_Status__c == 'Cancel'){
                            confirmationNumberWithStatusIdMapCancel.put(rto.Confirmation_Number__c,rto.Reservation_Status__c);
                        }
                        confirmationNumberWithOppIdMap.put(rto.Confirmation_Number__c,rto.Opportunity__c);
                    }
                }
                system.debug('oppIdSet--'+oppIdSet);
                oppList = [Select Id,Confirmation_Number__c,Total_Invoiced_Amount__c from Opportunity where Id IN: oppIdSet];
                system.debug('oppList--'+oppList);
                List<Invoice__c> updateListInvoice = new List<Invoice__c>();
                for(Invoice__c rec: invoiceList){
                    for(Opportunity oppRec: oppList){
                        if(confirmationNumberWithOppIdMap.containsKey(rec.Confirmation__c) 
                           && oppRec.Id == confirmationNumberWithOppIdMap.get(rec.Confirmation__c)){
                               if((rec.Reservation_Status__c == 'NoShow' || rec.Reservation_Status__c == 'Complete') && 'Confirmed' == confirmationNumberWithStatusIdMapConfirmed.get(rec.Confirmation__c)){
                                   if(rec.Reservation_Status__c == 'NoShow'){
                                       oppRec.No_Show__c = true;
                                   }else if(rec.Reservation_Status__c == 'Complete'){
                                       oppRec.Arrived__c = true;
                                   }
                                   system.debug('--rec.Invoice_Amount__c--'+rec.Invoice_Amount__c);
                                   system.debug('--oppRec.Total_Invoiced_Amount__c--'+oppRec.Total_Invoiced_Amount__c);
                                   if(oppRec.Total_Invoiced_Amount__c == null){
                                       if(rec.Invoice_Amount__c != null){
                                           oppRec.Total_Invoiced_Amount__c = rec.Invoice_Amount__c;
                                       }
                                   }else{
                                       if(rec.Invoice_Amount__c != null){
                                           oppRec.Total_Invoiced_Amount__c = oppRec.Total_Invoiced_Amount__c + rec.Invoice_Amount__c;
                                       }
                                   }
                                   
                                   rec.Opportunity__c = oppRec.Id;
                                   updateListInvoice.add(rec);
                                   oppMapToUpdate.put(oppRec.Id,oppRec);
                                   system.debug('confirmationNumberWithStatusIdMapCancel.get(rec.Confirmation__c)=== '+confirmationNumberWithStatusIdMapCancel.get(rec.Confirmation__c));
                               }else if(rec.Reservation_Status__c == 'Canceled' && 'Cancel' == confirmationNumberWithStatusIdMapCancel.get(rec.Confirmation__c)){
                                   
                                   
                                   system.debug('--rec.Invoice_Amount__c--'+rec.Invoice_Amount__c);
                                   system.debug('--oppRec.Total_Invoiced_Amount__c--'+oppRec.Total_Invoiced_Amount__c);
                                   if(oppRec.Total_Invoiced_Amount__c == null){
                                       if(rec.Invoice_Amount__c != null){
                                           oppRec.Total_Invoiced_Amount__c = rec.Invoice_Amount__c;
                                       }
                                   }else{
                                       if(rec.Invoice_Amount__c != null){
                                           oppRec.Total_Invoiced_Amount__c = oppRec.Total_Invoiced_Amount__c + rec.Invoice_Amount__c;
                                       }
                                   }
                                   rec.Opportunity__c = oppRec.Id;
                                   updateListInvoice.add(rec);
                                   oppMapToUpdate.put(oppRec.Id,oppRec);
                               }
                           }
                    }
                }
                if(!oppMapToUpdate.isEmpty()){
                    InvoiceTriggerHandler.stopTrigger();
                    update updateListInvoice;
                    update oppMapToUpdate.values();
                    system.debug('updateListInvoice=== '+updateListInvoice);
                    system.debug('updateListInvoice size=== '+updateListInvoice.size());
                }
            }
        }catch(Exception ex){
            system.debug('Error === '+ex.getMessage());
            system.debug('Error === '+ex.getLineNumber());
        }
    }
}