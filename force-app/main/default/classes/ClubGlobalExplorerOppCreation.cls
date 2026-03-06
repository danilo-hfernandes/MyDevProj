public class ClubGlobalExplorerOppCreation implements Database.Batchable<sObject>, Schedulable{ 
    public Database.QueryLocator start(Database.BatchableContext bc) {
            Date targetDate = Date.today().addDays(-10);
            DateTime startOfDay = DateTime.newInstance(targetDate.year(), targetDate.month(), targetDate.day());
            DateTime endOfDay = startOfDay.addDays(1);
            String query;
            if(test.isRunningTest()){
                query = 'SELECT Id,Name,Preferred_Language__c,Ownerid,Affiliated_Id__c,Email__c,Email_2__c,Formatted_Phone__c,Formatted_Alternate_Phone__c FROM Account Where Affiliated_Id__c = 1002447 and Owner.Name = \'Dev Account\'';//
            }
            else{
                query = 'SELECT Id,Name,Preferred_Language__c,Ownerid,Affiliated_Id__c,Email__c,Email_2__c,Formatted_Phone__c,Formatted_Alternate_Phone__c FROM Account Where Affiliated_Id__c = 1002447 and Owner.Name = \'Salesforce\' and CreatedDate >= :startOfDay AND CreatedDate < :endOfDay';//
            }
                system.debug('Query>>>'+query);
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext bc, List<Account> scope) {
        list<Opportunity> clubGlobalOpportunity=new list<opportunity>();
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>(); 
        List<EmailTemplate> emailTemplateList = new List<EmailTemplate>();
        Map<String, EmailTemplate> mapTemplateNamevsTemplate = new Map<String, EmailTemplate>();
        emailTemplateList = [SELECT Id, Body,developername, Subject, HtmlValue, Name FROM EmailTemplate WHERE developername = 'Club_Global_Explorer_Enrollment' or DeveloperName = 'Club_Global_Explorer_Enrollment_SPA'];
        for(EmailTemplate objtemplate : emailTemplateList){
            mapTemplateNamevsTemplate.put(objtemplate.DeveloperName, objtemplate);
        }
        for(Account acc: scope){
            if(acc.Affiliated_Id__c == 1002447){
                Boolean flag = GenericDuplicatesCheckController.GetAccounts(acc, true);//HC Flag check
                if(flag){
                    Opportunity opp= new Opportunity();
                    opp.name=acc.name;
                    opp.stagename='New';
                    opp.AccountId=acc.id;
                    opp.CloseDate=system.today();
                    opp.RecordTypeId=Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Club_Global_Explorer').getRecordTypeId();
                    opp.OwnerId = System.label.SystemAdminUserId ;
                    clubGlobalOpportunity.add(opp);
                    
//Send Welcome Email                   
                    List<String> emailAddress=new list<string>();
                    emailAddress.add(acc.email__c);
                    String templateBody;
                    Messaging.SingleEmailMessage newEmail; 
                    Messaging.SingleEmailMessage mailToBeSent = new Messaging.SingleEmailMessage(); 
                    OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'welcome@myadvantageservices.com'];
                    if (owea.size() > 0 ) {
                        mailToBeSent.setOrgWideEmailAddressId(owea.get(0).Id); 
                    }
                    if(!emailTemplateList.isEmpty()) {
                        if(acc.Preferred_Language__c == 'SPA'){
                            newEmail = Messaging.renderStoredEmailTemplate(mapTemplateNamevsTemplate.get('Club_Global_Explorer_Enrollment_SPA').Id,acc.Id,acc.Id);
                        }
                        else{ 
                            newEmail = Messaging.renderStoredEmailTemplate(mapTemplateNamevsTemplate.get('Club_Global_Explorer_Enrollment').Id,acc.Id,acc.Id);
                        }
                    }
                    
                    if(!emailAddress.isEmpty()) {
                        if(newEmail != null) {
                            mailToBeSent.setSubject(newEmail.subject);
                            mailToBeSent.setHtmlBody(newEmail.HTMLBody);
                            mailToBeSent.setToAddresses(emailAddress);
                            mailToBeSent.setSaveAsActivity(true);
                            mailToBeSent.setWhatId(acc.Id);
                            emailList.add(mailToBeSent);
                        }
                    }
                }
            }
        }
        if(clubGlobalOpportunity.size()>0){
            insert clubGlobalOpportunity;
        }  
        if(!emailList.isEmpty()){
            Messaging.sendEmail(emailList);
        }
        
    }
    public void finish(Database.BatchableContext bc) {
        //do something 
    }  
    public void execute(SchedulableContext SC) {
        database.executebatch(new ClubGlobalExplorerOppCreation(),100);
    }
}