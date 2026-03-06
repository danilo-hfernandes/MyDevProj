public class ChangeContactOwnerController {
    public List<Contact> contactList{get;private set;}
    public Integer noOfRecords{get;set;}
    public String contactString{get;set;}
    public Boolean errorMessage{get;set;}
    public ChangeContactOwnerController(ApexPages.StandardSetController stdSetController){
        // Returns all selected records
        errorMessage = false;
        noOfRecords = 0;
        set<Id> selectedContactIds = new set<Id>();
        contactList = (List<Contact>) stdSetController.getSelected();
        system.debug('>>>>>>contactList>>>>>>'+contactList);
        if(contactList != null && contactList.size() > 0){
            for(Contact objcon : contactList){
                selectedContactIds.add(objcon.Id);
            }
            noOfRecords = selectedContactIds.size();
            contactString = '';
            contactString = JSON.serialize(selectedContactIds);
            system.debug('>>>>selectedContactIds>>>>>>'+selectedContactIds);
        }
        else {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Select at least one record and try again.'));
            errorMessage = true;
        }
    }
    @AuraEnabled
    public static string updateContactOwner(list<Id> setOfConIds , String userId){
        try {
            String CsvData;
            Boolean flag = false;
            List<Contact> conlst = new List<Contact>();
            system.debug('>>>>setOfConIds>>>>'+setOfConIds);
            system.debug('>>>>>userId>>>>>>>'+userId);
            for(Id conId : setOfConIds){
                Contact objcon = new Contact();
                objcon.Id = conId;
                objcon.OwnerId = (Id)(userId.replace('"',''));
                conlst.add(objcon);
            }
            system.debug('>>>conlst>>>>>'+conlst);
            if(conlst != null && conlst.size() > 0){
                //update conlst;
                Database.SaveResult[] srList = Database.update(conlst, false);
                Integer i = 0;
                // Iterate through each returned result
                CsvData = 'Record Id,Field,Error Message, StatusCode\n'; 
                for (Database.SaveResult sr : srList) {
                    if (sr.isSuccess()) {
                        // Operation was successful, so get the ID of the record that was processed
                        System.debug('Successfully inserted account. Contact ID: ' + sr.getId());
                    }
                    else {
                        flag = true;
                        // Operation failed, so get all errors           
                        for(Database.Error err : sr.getErrors()) {
                            CsvData += conlst.get(i).Id +','+err.getFields() + ','+err.getMessage() +','+err.getStatusCode()+ '\n';
                            System.debug('The following error has occurred.'+err);                    
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('Contact fields that affected this error: ' + err.getFields());
                        }
                    }
                    i++;
                }
                system.debug('>>>>>CsvData>>>.'+CsvData);
                if(flag){
                    ChangeContactOwnerController.sendEmail(CsvData);
                }
                return 'Success';
            }
            return null;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    public static void sendEmail(String CsvData){
        Messaging.EmailFileAttachment csvAttachment = new Messaging.EmailFileAttachment();
        Blob csvBlob = blob.valueOf(CsvData);
        String csvName = 'ContactOwnerError.csv';
        csvAttachment.setFileName(csvName);
        csvAttachment.setBody(csvBlob);
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[]{'amadeu.lettieri@nerdsoft.com','shivani.chauhan@nerdsoft.com'};
        String subject = 'Bulk Update Owner Error sheet';
        email.setSubject(subject);
        email.setToAddresses(toAddresses);
        email.setHtmlBody('<html><body><h5>Hi,<br/><br/>Please find the Contact Owner Update Error Sheet. <br/><br/> Thank you!</h5></body></html>');
        email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttachment});
        Messaging.SendEmailResult[] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});
    }
}