public class InvoiceCreation {
    
    @AuraEnabled
    
    public static string insertInvoice(string strfromle){
        
        system.debug('strfromle==='+strfromle);
        String returnresponse ='';
        
        try{
        Date dateCreated;
        Date cancelDate;
        Date firstNight;
        Date lastNight;
        List<Invoice__c> InvoiceListToInsert = new List<Invoice__c>();
        system.debug('strfromle = ' + strfromle);
        List<fieldWrapper> datalist = (List<fieldWrapper>)JSON.deserialize(strfromle, List<fieldWrapper>.class);
        system.debug('datalist = ' + datalist);
        system.debug('datalistSize = ' + datalist.size());
        for(fieldWrapper wrapper: datalist){
            system.debug('wrapper=== '+wrapper);
            if(wrapper.DateCreated != null && wrapper.DateCreated != ''){
                dateCreated = getFormatedDate(wrapper.DateCreated);
            }else{
                dateCreated = null;
            }
            
            if(wrapper.CancelDate != null && wrapper.CancelDate != ''){
                cancelDate = getFormatedDate(wrapper.CancelDate);
            }else{
                cancelDate = null;
            }
            
            if(wrapper.FirstNight != null && wrapper.FirstNight != ''){
                firstNight = getFormatedDate(wrapper.FirstNight);
            }else{
                firstNight = null;
            }
            
            if(wrapper.LastNight != null && wrapper.LastNight != ''){
                lastNight = getFormatedDate(wrapper.LastNight);
            }else{
                lastNight = null;
            }
            system.debug('--wrapper.Invoiceamount--'+wrapper.Invoiceamount);
            //Decimal amount = Decimal.valueOf(wrapper.Invoiceamount.substringAfterLast(' '));
            //system.debug('Amount=== '+amount);
            
            Invoice__c Inv =new Invoice__c();
            Inv.Date_Created__c = dateCreated;
            Inv.Cancel_Date__c = cancelDate;
            //Confirmation__c is not mapping and due to that opportunity is not mapping.
            Inv.Confirmation__c = wrapper.ReservationNumber;
            Inv.Reservation_Status__c = wrapper.ReservationStatus;
            Inv.First_Night__c = firstNight; 
            Inv.Last_Night__c = lastNight;
            Inv.Room_Type__c = wrapper.RoomType; 
            Inv.External_Confirmation_Number__c = wrapper.ExternalConfirmationNumber; 
            Inv.Site_Name__c = wrapper.SiteName; 
            Inv.Billing_Item__c = wrapper.BillingItem;
            // We have to update data if amount is 0
            if(wrapper.Invoiceamount != null && wrapper.Invoiceamount != '-'){
                Inv.Invoice_Amount__c = decimal.valueof(wrapper.Invoiceamount); 
            }else{
                Inv.Invoice_Amount__c = 0;
            }
            
            InvoiceListToInsert.add(Inv);     
            
            system.debug('--InvoiceListToInsert size--'+InvoiceListToInsert.size());
        }
        
        if(InvoiceListToInsert.size() > 0){
            
            system.debug('--InvoiceListToInsert SUCCESS --'+InvoiceListToInsert);
                insert InvoiceListToInsert;
                /*Database.SaveResult[] result = Database.insert(InvoiceListToInsert, False);
                System.debug('SaveResult: ' + result);
                System.debug('InvoiceListToInsert: ' + InvoiceListToInsert);*/
                returnresponse = 'Total number of records created are '+string.valueOf(InvoiceListToInsert.size())+' out of '+string.valueOf(datalist.size())+'.';
                system.debug('---returnresponse--'+returnresponse);
        }
        }catch(Exception ex){
            system.debug('ex=== '+ex.getMessage());
            system.debug('ex line=== '+ex.getLineNumber());
            returnresponse = ex.getMessage();
        }
        return returnresponse;
    }
    
    public static date getFormatedDate(String inputDate){
        if(inputDate != null && inputDate != '' && inputDate != '-'){
            string monthOfDate = inputDate.substringBetween('', '/');
            string dayOfDate = inputDate.substringBetween('/', '/');
            string yearOfDate = inputDate.substringAfterLast('/');
            
            system.debug('dayOfDate is===' + dayOfDate + ' monthOfDate is=== '+ monthOfDate + ' yearOfDateCreated is=== '+yearOfDate);
            date outputDate = date.valueOf(yearOfDate+'-'+monthOfDate+'-'+dayOfDate);
            return outputDate;
        }
        return null;
    }
    
    public class fieldWrapper{        
        public string DateCreated;        
        public string CancelDate;        
        public String ReservationNumber;
        public String ReservationStatus;        
        public string FirstNight;        
        public string LastNight;
        public String SiteName;        
        public String RoomType;        
        public String ExternalConfirmationNumber;
        public String BillingItem;        
        public string Invoiceamount;        
    } 
}