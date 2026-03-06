public class RedemptionController {
    //List<redemptionWrapper> listredemptionWrapper = new List<redemptionWrapper>();
    /* wrapper class */  
    public class redemptionWrapper {
        @AuraEnabled  public Redemption__c RedemptionObj{get;set;}
        @AuraEnabled public List<SelectOptions> timeshareDetails;
        @AuraEnabled public String selectedTimeShareId{get;set;}
    }
    public class SelectOptions{
        @AuraEnabled 
        public string label;
        @AuraEnabled 
        public string value;
        public selectOptions(String Idstr,String Name){
            this.label = Name;
            this.value = Idstr;
        }
    }
    @AuraEnabled
    public static List<Redemption__c> RedemptionList(String recordId){
        List<Redemption__c> rdmList = [select id,Add_New_Button_Access__c, Name__c,No_Show__c,Name, Usage_Fee__c, Status__c, Reservation__c, Request_Date__c, Redemption_Amount__c,Hide_Edit_Button__c,
                                       Check_In_Date__c, Redemption_Type__c,Property__r.Name,Opportunity__r.Record_Type_Name__c,Opportunity_Product__c,Opportunity_Product__r.Product2.Name, Opportunity__r.Name, Opportunity__r.Product_Name__c,Parent_Redemption__c  from Redemption__c where Opportunity__c =:recordId order by Opportunity_Product__r.Product2.Name,Order_By__c,Name__c ASC];
        
        return rdmList;
    }
    @AuraEnabled
    public static Boolean showProductName(String recordId){
        List<Redemption__c> rdmList = [select id,Name__c,Opportunity_Product__c,Opportunity_Product__r.Product2.Name, Opportunity__r.Name, Opportunity__r.Product_Name__c  from Redemption__c where Opportunity__c =:recordId and Opportunity_Product__r.Product2.Name = 'Back to Vidanta Pass'];
        if(rdmList != null && rdmList.size() > 0){
            for(Redemption__c objred :rdmList){
                if(objred.Opportunity_Product__r.Product2.Name == 'Back to Vidanta Pass'){
                    return true;                
                }
            }
        }
        return false;
    }
    
    @AuraEnabled
    public static Boolean validateProductName(String recordId){
        List<OpportunityLineItem> opplineItem = [select id, Product2.Name from OpportunityLineItem where Id =:recordId limit 1];
        if(opplineItem != null && opplineItem.size() > 0){
            if(opplineItem[0].Product2.Name == 'Back to Vidanta Pass'){
                return true;
            } 
        }
        return false;
    }
    
    @AuraEnabled
    public static void casecreation(string recordId){
        
        system.debug('---redrecordRed--'+recordId);
        Redemption__c rdm = [select id,No_Show__c,Opportunity__r.Id,Opportunity__r.AccountId,Opportunity__r.Account.Name,Case_Gets_Created__c, Name, Usage_Fee__c, Status__c, Reservation__c, Request_Date__c, Redemption_Amount__c,
                             Check_In_Date__c, Property__r.Name , Opportunity__r.Name from Redemption__c where id =:recordId];
        
        
        system.debug('rdm--No_Show__c-'+rdm.No_Show__c);
        if(rdm.Case_Gets_Created__c == false){
            
            Id voucherRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Voucher').getRecordTypeId(); 
            Case cs = new Case();
            cs.Subject = 'New Redemption Request - '+rdm.Opportunity__r.Account.Name;
            cs.AccountId = rdm.Opportunity__r.AccountId;
            cs.Status = 'Open';
            cs.Priority = 'Medium';
            cs.Opportunity_Link__c = 'https://holidaysystems.lightning.force.com/'+rdm.Opportunity__r.Id;
            cs.RecordTypeId = voucherRecordType;
            cs.Case_Type__c = 'Rebook Cancelled Request';
            try{
                insert cs;
                rdm.Case_Gets_Created__c = true;
                update rdm;
                system.debug('rdm.Case_Gets_Created__c'+rdm.Case_Gets_Created__c);
            }catch(Exception e){
                system.debug('--e---'+e);
            }
            
        }
    }
    
    @AuraEnabled 
    public static redemptionWrapper redemptionWrapper(String redId){  
        Redemption__c redRecords = [select id, No_Show__c,Name, Usage_Fee__c, Status__c, Reservation__c, Request_Date__c, Redemption_Amount__c,
                                    Check_In_Date__c, Property__r.Id,Property__r.Name , Opportunity__r.Name from Redemption__c where Id =:redId limit 1];
        
        Id AccID=[SELECT id,AccountID FROM Opportunity where id=:redRecords.Opportunity__c].AccountID;
        List<Timeshare__c> timeshareList = [SELECT id, Name from TimeShare__c where Timeshare_Owner__c=:AccID ];
        
        system.debug('---rdmList---'+redRecords);
        system.debug('---timeshareList---'+timeshareList);
        redemptionWrapper wrp =new redemptionWrapper();
        wrp.timeshareDetails = new List<SelectOptions>();
        for (Timeshare__c timesahare: timeshareList) {
            wrp.timeshareDetails.add(new SelectOptions(timesahare.Id, timesahare.Name));
        }
        wrp.selectedTimeShareId = redRecords.Property__r.Id;
        wrp.RedemptionObj = redRecords;
        system.debug('---wrp---'+wrp);
        return wrp;
    }
    
    @AuraEnabled
    public static String addNewRedemption(String redId){
        system.debug('--redId--'+redId);
        Redemption__c redRecords = [select id, Name,Opportunity_Product__c, Usage_Fee__c, Status__c, Reservation__c, Request_Date__c, Redemption_Amount__c,
                                    Check_In_Date__c,Opportunity__r.id, Property__r.Id,Property__r.Name , Opportunity__r.Name from Redemption__c where Id =:redId limit 1];
        system.debug('88='+redRecords);
        
        Redemption__c newRed= new Redemption__c();
        newRed.Usage_Fee__c=redRecords.Usage_Fee__c;
        newRed.Status__c=redRecords.Status__c;
        newRed.Reservation__c=redRecords.Reservation__c;
        newRed.Redemption_Amount__c=redRecords.Redemption_Amount__c;
        newRed.Check_In_Date__c=redRecords.Check_In_Date__c;
        newRed.Property__c=redRecords.Property__r.Id;
        newRed.Opportunity__c=redRecords.Opportunity__r.id;
        newRed.Parent_Redemption__c=redRecords.id;
        newRed.Opportunity_Product__c = redRecords.Opportunity_Product__c;
        system.debug('99='+newRed);
        
        insert newRed;
        return 'Success';
    }
    
    
    @AuraEnabled
    public static List<SObJectResult> getResults(String ObjectName, String fieldName,string RecordId,String value) {
        ID OppoId = [select id, Name, Usage_Fee__c, Status__c, Reservation__c, Request_Date__c, Redemption_Amount__c,
                     Check_In_Date__c, Property__r.Name , Opportunity__r.Name from Redemption__c where id=:RecordId]. Opportunity__r.Id;
        
        system.debug('--OppoId--'+OppoId);
        
        Id AccID=[SELECT id,AccountID FROM Opportunity where id=:OppoId].AccountID;
        system.debug('--AccID--'+AccID);
        
        string tempInput = '%' + value + '%';
        
        system.debug('--tempInput--'+tempInput);
        
        
        List<Timeshare__c> lsttime =NEw List<Timeshare__c>();
        
        system.debug('--lsttime--'+lsttime);
        
        lsttime  = [SELECT id, Name from TimeShare__c where Timeshare_Owner__c=:AccID ];
        
        system.debug('--lsttime'+lsttime);
        
        /*  if(value!=''&& value!=null){
system.debug('--Value not Null');
system.debug('---value--'+value);
lsttime  = [SELECT id, Name from TimeShare__c where Timeshare_Owner__c=:AccID AND Name LIKE:tempInput];
system.debug('--lsttime--'+lsttime);
}
else{
system.debug('--Value  Null');

lsttime  = [SELECT id, Name from TimeShare__c where Timeshare_Owner__c=:AccID ];
}
*/
        List<SObJectResult> sObjectResultList = new List<SObJectResult>();
        for(sObject so : (lsttime)) {
            String fieldvalue = (String)so.get(fieldName);
            sObjectResultList.add(new SObjectResult(fieldvalue, so.Id));
        }
        system.debug('---sObjectResultList--'+sObjectResultList);
        return sObjectResultList;
    }
    public class SObJectResult {
        @AuraEnabled
        public String recName;
        @AuraEnabled
        public Id recId;
        
        public SObJectResult(String recNameTemp, Id recIdTemp) {
            recName = recNameTemp;
            recId = recIdTemp;
        }
    }
}