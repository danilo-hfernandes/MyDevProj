// Class for sending emails again
Global class SFXWelcomeEmailAgain implements Database.Batchable<sObject>,schedulable{
    
    
    Global List<OrgWideEmailAddress> orgList = new List<OrgWideEmailAddress>();
    List<EmailTemplate> emailTemplateList = new List<EmailTemplate>();
    
    global SFXWelcomeEmailAgain(){
        orgList = [select Id from OrgWideEmailAddress where Address = 'welcome@myadvantageservices.com'];
        emailTemplateList = [SELECT Id, Body,developername, Subject, HtmlValue, Name
                             FROM EmailTemplate
                             WHERE developername = 'SFX_Welcome_Email'];
    }
    
    Global Database.QueryLocator start(Database.BatchableContext bc) {
        system.debug('4');
        String Ownerid=[select id from user where name='Dev Account'].id;
        String recordtype='SFX Membership';
       
        String query = 'SELECT Id,Name,Stagename,ownerId,Accountid,Account.HC_Flag__c,Account.Preferred_Language__c,Account.Original_Source__c,SFX_Welcome_Email__c,Account.Enrollment_Date__c,Account.TRM_Owner_Flag__c,Account.email__c,Account.First_name__c, Account.Returning_Vidanta_Costumer__c from opportunity where record_type_name__c=\''+recordtype+'\'  and ownerid=\''+Ownerid+'\'  and CreatedDate = N_DAYS_AGO:45 '+(Test.isRunningTest()?' LIMIT 10':'');
        system.debug('9='+query);
        system.debug('size='+Database.getQueryLocator(query));
        return Database.getQueryLocator(query);
    }
    
    Global void execute(Database.BatchableContext bc, List<Opportunity> scope) {
        try{
            
            if(scope.size()!=0){
                System.debug('scope='+scope);
                List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>(); 
                for(Opportunity opp:scope){
                    system.debug('64='+opp.account.First_name__c);
                    string whoid=opp.Id;
                    string whatid=opp.AccountId;
                    List<String> emailAddress=new list<string>();
                    emailAddress.add(opp.Account.email__c);
                    String templateBody;
                    Messaging.SingleEmailMessage newEmail; 
                    Messaging.SingleEmailMessage mailToBeSent = new Messaging.SingleEmailMessage(); 
                    
                    if(!emailTemplateList.isEmpty()) {
                        newEmail = Messaging.renderStoredEmailTemplate(emailTemplateList[0].id,whoId,whatId);
                    }
                    if(!emailAddress.isEmpty()) {
                        if(newEmail != null) {
                            if ( orgList.size() > 0 ) {
                                mailToBeSent.setOrgWideEmailAddressId(orgList[0].Id);
                            }
                            mailToBeSent.setSubject(newEmail.subject);
                            mailToBeSent.setHtmlBody(newEmail.HTMLBody);
                            mailToBeSent.setToAddresses(emailAddress);
                            mailToBeSent.setSaveAsActivity(true);
                            mailToBeSent.setWhatId(whoId);
                            emailList.add(mailToBeSent);
                        }
                    }
                }
                if(!emailList.isEmpty()){
                    system.debug('92');
                    Messaging.sendEmail(emailList); 
                }
                
            }
            
        }catch(Exception e){
            system.debug('277 Exception='+e.getLineNumber());
            system.debug('278 Exception='+e.getMessage());
        }
    }
    
    Global void finish(Database.BatchableContext bc) {
        //do something 
    }   
    
    Global void execute(SchedulableContext SC) {
        database.executebatch(new SFXWelcomeEmailAgain(),100);
    }
    
}