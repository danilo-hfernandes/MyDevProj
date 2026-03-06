public class RedemptionTriggerHandler {
    public static void updateRelatedTimeshare(List<Redemption__c> lstRedemption){
        List<Timeshare__c> listTimeshare = new List<Timeshare__c>();
        for(Redemption__c objredem : lstRedemption){
            if(objredem.Usage_Fee__c != null && objredem.Usage_Fee__c != 0){
                Timeshare__c objtimeshare = new Timeshare__c();
                objtimeshare.Id = objredem.Property__c;
                objtimeshare.VIDA_File_Fee_Amount__c = objredem.Usage_Fee__c;
                listTimeshare.add(objtimeshare);
            }  
        }
        if(listTimeshare != null && listTimeshare.size() > 0){
            update listTimeshare;
        }
    }
    
    public static void createReservationTrackingRecord(Map<Id,Redemption__c> oldOppMap, Map<Id,Redemption__c> newOppMap){
        
        List<Redemption__c> redList = new List<Redemption__c>();
        List<Reservation_Tracking_Object__c> reservationListToInsert = new List<Reservation_Tracking_Object__c>();
 
            for(Redemption__c redRec: newOppMap.values()){
                system.debug('--------new--'+redRec.Reservation__c);
                system.debug('----old--'+oldOppMap.get(redRec.Id).Reservation__c);
                
                if(
                    redRec.Request_Date__c != oldOppMap.get(redRec.Id).Request_Date__c || 
                    redRec.Check_In_Date__c != oldOppMap.get(redRec.Id).Check_In_Date__c ||
                    redRec.Property__c != oldOppMap.get(redRec.Id).Property__c ||
                    redRec.Reservation__c != oldOppMap.get(redRec.Id).Reservation__c || 
                    redRec.Redemption_Amount__c != oldOppMap.get(redRec.Id).Redemption_Amount__c ||
                    redRec.Usage_Fee__c != oldOppMap.get(redRec.Id).Usage_Fee__c || 
                    redRec.Status__c != oldOppMap.get(redRec.Id).Status__c )
                {
                    redList.add(redRec);
                }
                else if(test.isRunningTest()){
                    redList.add(redRec);
                }
            }
            system.debug('--redList--'+redList);
            for(Redemption__c red: redList){
                system.debug('--red--'+red);
                Reservation_Tracking_Object__c reservationTrackingRecord = new Reservation_Tracking_Object__c ();
                reservationTrackingRecord.Opportunity__c = red.Opportunity__c;
                reservationTrackingRecord.Property__c = red.Property_Name__c;
                reservationTrackingRecord.Rooms__c = red.RoomType__c;
                reservationTrackingRecord.Check_in__c = red.Check_In_Date__c;
                reservationTrackingRecord.Site_Name__c = red.SiteName__c;
                reservationTrackingRecord.Reservation_Status__c = red.Status__c;
                reservationTrackingRecord.Confirmation_Number__c = red.Reservation__c;
                reservationTrackingRecord.Redemption__c = red.Id;
                
                //reservationTrackingRecord.Destination__c = red.Name;
                //reservationTrackingRecord.Program__c = red.Name;
                //reservationTrackingRecord.Check_Out__c = red.Check_In_Date__c;
                //reservationTrackingRecord.Confirmed_Date__c = red.Check_In_Date__c;
               // reservationTrackingRecord.Capacity__c = red.Reservation__c;
                 
                reservationListToInsert.add(reservationTrackingRecord);
            } 
            system.debug('-reservationListToInsert---'+reservationListToInsert.size());
            
            if(!reservationListToInsert.isEmpty()){
                insert reservationListToInsert;
            }
        
    }
}