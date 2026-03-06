public class ReservationCtrl {
    public boolean isEdit{get;set;}
    public boolean displayPopup {get;set;}
    public boolean ConfirmedstatusError {get;set;}
    public boolean isEditBookUS{get;set;}
    public boolean isNoShowVisible{get;set;}
    public Opportunity oppObj{get;set;}    
	public Boolean hidedField {get; set;}

    public ReservationCtrl(ApexPages.StandardController stdController) {
        Id recordId = stdController.getId();
        oppObj = [select id,Status_Confirmed__c,No_Show__c,Program__c,Destination__c,Room_Type__c,Property__c,Rooms__c,Site_Name__c,Capacity__c,
                  Check_in__c,Check_Out__c,Reservation_Status__c,Record_Type_Name__c,Supplier__c,RecordType.DeveloperName,
                  Confirmation_Number__c,Confirmed_Date__c,Inventory_Availability_Id__c,AccountId,Adults__c,Children_0_17__c from Opportunity where Id =:recordId];
        isEdit = false;
        isEditBookUS = false;
        displayPopup = false;
        ConfirmedstatusError = false;
        isNoShowVisible = false;
        
        String userProfileName = [select Name from profile where id =: userinfo.getProfileId()].Name;
        if(userProfileName == 'System Administrator'){
            isNoShowVisible =  true;
        }else{
            isNoShowVisible = false;
        }
        
        if(oppObj.RecordType.DeveloperName == 'Marival' || oppObj.RecordType.DeveloperName == 'Hooked_Voucher')
        {           
            hidedField = true;
        }
    }
    public void enableEditMode(){
        isEdit = true;  
        if(oppObj.RecordType.DeveloperName == 'Vida_Book_With_Us'){
            isEditBookUS = true;
        }
    }
    public void updatecheckoutDate(){
        if(oppObj.Check_in__c != null && oppObj.RecordType.DeveloperName != 'Marival' && oppObj.RecordType.DeveloperName != 'Hooked_Voucher'){
            oppObj.Check_Out__c = oppObj.Check_in__c.addDays(7);
        }
    }
    public void savebutton(){
        
        //2024-09-24 TGR-167 Vidanta Voucher - Booking Number of Nights
        Id opportunityId = ApexPages.currentPage().getParameters().get('id');       
        system.debug('ApexPages.currentPage().getParameters().get(id) = '+opportunityId);
        Opportunity currentOpp = [select id,Status_Confirmed__c,No_Show__c,Program__c,Destination__c,Room_Type__c,Property__c,Rooms__c,Site_Name__c,Capacity__c,
                                  Check_in__c,Check_Out__c,Reservation_Status__c,Record_Type_Name__c,Supplier__c,RecordType.DeveloperName,
                                  Confirmation_Number__c,Confirmed_Date__c,Inventory_Availability_Id__c,AccountId,Adults__c,Children_0_17__c from Opportunity where Id =:opportunityId];
        
        try{
            
            Id profileId = UserInfo.getProfileId();
            String profileName =[Select Id, Name from Profile where Id=:profileId].Name;
            if(oppObj.Reservation_Status__c == 'Confirmed'){
                oppObj.Status_Confirmed__c = true;
            }
            if((oppObj.Reservation_Status__c == 'Pending' || oppObj.Reservation_Status__c == 'Confirmed') && oppObj.RecordType.DeveloperName != 'SFX_Membership'){
                oppObj.StageName = 'Closed Booked';
            }
            if(oppObj.Reservation_Status__c == 'Cancel'){
                oppObj.StageName = 'Closed Won';
                //2024-09-24 TGR-167 Vidanta Voucher - Booking Number of Nights
                if(currentOpp.Inventory_Availability_Id__c != null && currentOpp.Inventory_Availability_Id__c != '' && currentOpp.Check_Out__c != null)
                {
                    String invKey = [SELECT Id,Unique_Key_for_Product_Id__c FROM Inventory_Availability__c WHERE Id = : currentOpp.Inventory_Availability_Id__c LIMIT 1].Unique_Key_for_Product_Id__c;
                    Map<String,Date> invsToRestore = new Map<String,Date>();
                    invsToRestore.put(invKey,currentOpp.Check_Out__c.addDays(-1));
                    InventoryManager.addInventoryAvailability(invsToRestore);
                }
                
            }
            if(oppObj.Check_in__c != null && oppObj.Supplier__c != 'Marival' && oppObj.RecordType.DeveloperName != 'Marival' && oppObj.RecordType.DeveloperName != 'Hooked_Voucher'){
                //2024-09-24 removed - TGR-167 Vidanta Voucher - Booking Number of Nights
                //oppObj.Check_Out__c = oppObj.Check_in__c.addDays(7);
            }
            if(oppObj.Check_in__c != null && oppObj.Supplier__c == 'Marival'){
                //2024-09-24 removed - TGR-167 Vidanta Voucher - Booking Number of Nights
                //oppObj.Check_Out__c = oppObj.Check_in__c.addDays(4);
            }
            isEdit = false;
            upsert oppObj;
            
        }catch(Exception e)
        {

            isEdit = true;

            if(e.getMessage().contains('permission')){
                Apexpages.addMessage(new Apexpages.message(ApexPages.Severity.Error,'You do not have permission to make status as confirmed'));    
            }else if(e.getMessage().contains('Please enter Confirmed date and Confirmation Number')){
                Apexpages.addMessage(new Apexpages.message(ApexPages.Severity.Error,'Please enter Confirmed date and Confirmation Number'));    
            }else{
                Apexpages.addMessage(new Apexpages.message(ApexPages.Severity.Error,e.getMessage()));    
            }
            
        } 
    }
    
    public void closePopup(){
        displayPopup = false;
        ConfirmedstatusError = false;
    } 
    
    public void showPopup(){
        Id voucherCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Voucher').getRecordTypeId();
        
        if(oppObj.Reservation_Status__c == 'Cancel'){
            displayPopup = true;
            ConfirmedstatusError = false;
        }else if(oppObj.Reservation_Status__c == 'Confirmed' && (oppObj.Confirmation_Number__c == null || oppObj.Confirmed_Date__c == null)){
            displayPopup = false;
            ConfirmedstatusError = true; 
        }
        else{
            savebutton();
        }
    }
}