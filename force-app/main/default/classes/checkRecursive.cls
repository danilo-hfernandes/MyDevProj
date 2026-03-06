public class checkRecursive {
    
    public static boolean accountTrigger = true;
    public static boolean accountTriggerAPI = true;
    public static boolean opportunitycreateReservationTrackingRecord = true;
    public static boolean productTrigger = true;
    public static boolean paymentTrigger = true;
    public static boolean leadTrigger = true;
    
    public static boolean runOnceLeadTrigger(){
        if(leadTrigger){
            leadTrigger=false;
            return true;
        }else{
            return leadTrigger;
        }
    }
    
}