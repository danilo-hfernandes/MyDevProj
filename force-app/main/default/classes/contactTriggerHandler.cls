public class contactTriggerHandler {
    public static void updateMembershipProdconfig(List<Contact> contactRecords){
		String affliateid;
        String salesroomid;
        String subscriberid;
        Map<String,Contact> ContactIdSet = new Map<String,Contact>();
        List<Membership_Product_Configuration__c> memProdConfig = New List<Membership_Product_Configuration__c>();
        
        for(Contact cn : contactRecords){
            
            if(cn.AffiliatedId__c != null){
                affliateid = String.valueof(cn.AffiliatedId__c);
                ContactIdSet.put(affliateid,cn);
            }
            if(cn.Sales_Room_Id__c != null){
                salesroomid = cn.Sales_Room_Id__c;
                ContactIdSet.put(salesroomid,cn);
            }
            if(cn.Subscriber_Id__c != null){
                subscriberid = cn.Subscriber_Id__c;
                ContactIdSet.put(subscriberid,cn);
            }
        }
        
        if(affliateid != Null || salesroomid != Null ||  subscriberid != NULL){
        memProdConfig = [Select Id,Affiliated_Id__c,Sales_Room_Id__c,Subscriber_Id__c from Membership_Product_Configuration__c where 
                         Affiliated_Id__c IN :ContactIdSet.Keyset() OR
                         Sales_Room_Id__c IN :ContactIdSet.Keyset() OR
                         Subscriber_Id__c IN :ContactIdSet.Keyset() ];
        
        }
        if(memProdConfig.size() > 0 && memProdConfig != Null){
            
            for(Membership_Product_Configuration__c mpc :memProdConfig){
                
                if(ContactIdSet.containsKey(mpc.Affiliated_Id__c)){
                     ContactIdSet.get(mpc.Affiliated_Id__c).Membership_Product_Configuration__c = mpc.id;
                }
                else if(ContactIdSet.containsKey(mpc.Sales_Room_Id__c)){
                     ContactIdSet.get(mpc.Sales_Room_Id__c).Membership_Product_Configuration__c = mpc.id;
                }
                else if(ContactIdSet.containsKey(mpc.Subscriber_Id__c)){
                     ContactIdSet.get(mpc.Subscriber_Id__c).Membership_Product_Configuration__c = mpc.id;
                   
                }
            }
        }      
    }
    public static void assignRaiseAwayContactstoTourGen(set<Id> contactIds){
        List<Contact> updateContactList = new List<Contact>();
        set<Id> cadenceContactIds = new set<Id>();
        //1002465 affiliate added 2025-06-29
        for(Contact objcon : [select id, Assign_to_Sales_Cadence__c,Cadence_Flag__c,Match_Group_Name__c from Contact where Id IN : contactIds and (Account.Affiliated_Id__c = 1002464 OR Account.Affiliated_Id__c = 1002465)]){
            //2025-09-23 TGR-822 Add Raise Away and Engage Goods to Sales Cadence
            //objcon.Match_Group_Name__c = 'TourGen-LuxGive';
            objcon.Match_Group_Name__c = 'TourGen-Charity';
            objcon.Assign_to_Sales_Cadence__c=true;
            objcon.Cadence_Flag__c=1;
            updateContactList.add(objcon);
            cadenceContactIds.add(objcon.Id);
        }
        if(updateContactList != null && updateContactList.size() > 0){
            updateContactList =  GenericMatchGroupAssignmentHandler.assignMatchGroup(updateContactList, 'Assigned');
            update updateContactList;
        }
        if(cadenceContactIds != null && cadenceContactIds.size() > 0) {
            //2025-09-23 TGR-822 Add Raise Away and Engage Goods to Sales Cadence
            //System.enqueueJob(new GenericAssignToSalesCadence(cadenceContactIds, 'TourGen-LuxGive'));
            System.enqueueJob(new GenericAssignToSalesCadence(cadenceContactIds, 'TourGen-Charity'));
        }
    }
}