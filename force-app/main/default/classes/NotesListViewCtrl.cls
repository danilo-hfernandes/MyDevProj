public class NotesListViewCtrl{
    
    @AuraEnabled 
    public static List<notestListWrapper> fetchNotesWrapper(String recordId){     
        List<notestListWrapper> lstnotestListWrapper = new List<notestListWrapper>();
        system.debug('-recordId-'+recordId);
        Set<Id> parentId = new set<Id>();
        Set<Id> OpportunityId = new Set<Id>();
        if(recordId != null){
            // For Account
            if(recordId.startsWith('001')){
                List<Opportunity> oppList = [select id from Opportunity where AccountId =: recordId];
                
                for(Opportunity opp :oppList){
                    parentId.add(opp.Id);
                }
                List<Contact> conList = [select id from Contact where AccountId =: recordId];
                for(Contact con :conList){
                    parentId.add(con.Id);
                }
                List<Payment__c> paymentList = [select id from Payment__c where Opportunity__c =:parentId];
                if(paymentList != null && paymentList.size() > 0){
                    for(Payment__c pay : paymentList){
                        parentId.add(pay.Id);
                    }
                }
                parentId.add(recordId);
            }
            // For Opportunity
            if(recordId.startsWith('006')){
                Opportunity Opp = [select id,AccountId from Opportunity where  Id =: recordId];
                parentId.add(opp.AccountId);
                
                List<Opportunity> oppList = [select id from Opportunity where AccountId =: opp.AccountId];
                for(Opportunity oppL :oppList){
                    parentId.add(oppL.Id);
                }
                List<Contact> conList = [select id from Contact where AccountId =: opp.AccountId];
                for(Contact con :conList){
                    parentId.add(con.Id);
                }
                
                List<Case> caselist = [Select Id,AccountId from Case where AccountId =:opp.AccountId];
                if(caselist != Null && caselist.size() > 0){
                    for(Case cs : caselist){
                        parentId.add(cs.id);
                    }
                }
                
                List<Payment__c> paymentList = [select id from Payment__c where Opportunity__c =:recordId];
                system.debug('--paymentList--'+paymentList);
                if(paymentList != null && paymentList.size() > 0){
                    for(Payment__c pay : paymentList){
                        parentId.add(pay.Id);
                    }
                }
            }
            // For Contact
            if(recordId.startsWith('003')){
                Contact con = [select id,AccountId from Contact where  Id =: recordId];
                parentId.add(con.AccountId);
                
                List<Opportunity> oppList = [select id from Opportunity where AccountId =: con.AccountId];
                for(Opportunity opp :oppList){
                    parentId.add(opp.Id);
                }
                List<Contact> conList = [select id from Contact where AccountId =: con.AccountId];
                for(Contact conl :conList){
                    parentId.add(conl.Id);
                }
                
                
            }
            // For lead
            if(recordId.startsWith('00Q')){
                Lead ld = [select id,ConvertedAccountId from Lead where  Id =: recordId];
                if(ld!=null && ld.ConvertedAccountId != null){
                    parentId.add(ld.ConvertedAccountId);
                }
                parentId.add(recordId); 
            }
            // For payment
            if(recordId.startsWith('a0R')){
                Payment__c paymt = [select id,Opportunity__c,Opportunity__r.AccountId from Payment__c where id =:recordId];
                parentId.add(paymt.Opportunity__c);
                parentId.add(paymt.Opportunity__r.AccountId);
                parentId.add(paymt.Id);
            }
            
            // For Case
            if(recordId.startsWith('500')){
                Case cs = [Select Id,AccountId from Case where Id =:recordId];
                parentId.add(cs.id);
                parentId.add(cs.AccountId);
                
            }
            
        }
        system.debug('>parentId>>>>'+parentId);
        if(parentId != null && parentId.size() > 0){
            List<ContentDocumentLink> contentDocLink = [SELECT Id, ContentDocumentId, ContentDocument.Title, ContentDocument.FileType, LinkedEntityId, ShareType, Visibility FROM ContentDocumentLink where LinkedEntityId IN :parentId];
            Set<id> contentDo = new Set<id>();
            for(ContentDocumentLink ctdl : contentDocLink){
                contentDo.add(ctdl.ContentDocumentId);
            }
            List<ContentNote> contList = [select id,Title,CreatedDate, Content,TextPreview,CreatedBy.Name from ContentNote Where Id IN :contentDo order by CreatedDate desc ];
            
            
            for(ContentNote nst : contList){
                notestListWrapper wrap = new notestListWrapper();
                wrap.title = nst.Title;
                wrap.details = nst.TextPreview;
                wrap.CreatedDate = nst.CreatedDate;
                wrap.createdBy = nst.CreatedBy.Name;
                
                //if(nst.Title != null && (nst.Title).length() > 20){
                //    system.debug('---inside if---');
                //    wrap.wrappedTitle = (nst.Title).substring(0,19)+'...'; 
                //}else{
                //    system.debug('---inside if---');
                wrap.wrappedTitle = nst.Title;
                //}
                
                //if(nst.TextPreview != null && (nst.TextPreview).length() > 20){
                //    system.debug('---inside if---');
                //    wrap.wrappedString = (nst.TextPreview).substring(0,19)+'...'; 
                //}else{
                system.debug('---inside if---');
                wrap.wrappedString = nst.TextPreview;
                //}
                system.debug('--wrap.wrappedString--'+wrap.wrappedString);
                wrap.recordId = nst.id;
                lstnotestListWrapper.add(wrap);
            } 
            // Related task
 			List<Task> taskList = [select Id,CreatedDate,CreatedBy.Name, subject,whatid ,description, Who.Type, ActivityDate FROM Task WHERE whatid IN :parentId or whoId IN : parentId order by CreatedDate desc];
 
            system.debug('--taskList--'+taskList.size());
            for(Task tk : taskList){
//MSR-297                if(tk.subject != null){
                if ( tk.subject != null && (tk.ActivityDate == null || tk.ActivityDate >= tk.CreatedDate.date().addDays(-1))  )  {
                        notestListWrapper wrap = new notestListWrapper();
                        wrap.title = tk.subject;
                    if(tk.subject != null && (tk.subject).length() > 20){
                        system.debug('---inside if---');
                        wrap.wrappedTitle = (tk.subject).substring(0,19)+'...'; 
                    }else{
                        system.debug('---inside if---');
                        wrap.wrappedTitle = tk.subject;
                    }
                    wrap.CreatedDate = tk.CreatedDate;
                    wrap.details = tk.description;
                    if(tk.description != null && (tk.description).length() > 200){
                        system.debug('---inside if---');
                        wrap.details = (tk.description).substring(0,200)+'...'; 
                    }else{
                        system.debug('---inside if---');
                        wrap.details = tk.description;
                    }
                    wrap.createdBy = tk.CreatedBy.Name;
                    wrap.recordId = tk.id;
                    lstnotestListWrapper.add(wrap);
                }
                
            } 
            //Email Message
            List<EmailMessageRelation> emailmessageRelationList = [select id,EmailMessageId from EmailMessageRelation where RelationId IN: parentId];
            set<Id> setEmailMessage = new set<Id>();
            for(EmailMessageRelation objemailMessageRecipient : emailmessageRelationList){
                setEmailMessage.add(objemailMessageRecipient.EmailMessageId);
            }
            List<EmailMessage> emailMessageList = [select id, Subject, CreatedDate, CreatedBy.Name,TextBody, PreviousCreatedDate__c, Previous_Id__c, SynchedFromSQL__c  from EmailMessage where Id IN: setEmailMessage or ParentId IN: parentId or relatedToId IN : parentId];
            for(EmailMessage objemailMessage : emailMessageList){
                notestListWrapper wrap = new notestListWrapper();
                wrap.recordId = objemailMessage.id;
                wrap.title = objemailMessage.Subject;
                wrap.details = objemailMessage.TextBody;
                If(objemailMessage.PreviousCreatedDate__c != null){
                    wrap.CreatedDate = objemailMessage.PreviousCreatedDate__c;
                }Else{
                    wrap.CreatedDate = objemailMessage.CreatedDate;
                }
                wrap.createdBy = objemailMessage.CreatedBy.Name;
                wrap.wrappedTitle = objemailMessage.Subject;
                wrap.wrappedString = objemailMessage.TextBody;
                wrap.SynchedFromSQL = objemailMessage.SynchedFromSQL__c;
                wrap.PreviousId = objemailMessage.Previous_Id__c;
                lstnotestListWrapper.add(wrap);
            }
            //ListEmails
            List<ListEmailIndividualRecipient> listRecipient = [select id,ListEmailId from ListEmailIndividualRecipient where RecipientId IN: parentId];
            set<Id> listEmailId = new set<Id>();
            for(ListEmailIndividualRecipient objrecipient : listRecipient){
                listEmailId.add(objrecipient.ListEmailId); 
            }
            List<ListEmail> listEmail = [select id,Subject,TextBody, CreatedDate, CreatedBy.Name from ListEmail where Id IN : listEmailId];
            for(ListEmail objemail : listEmail){
                notestListWrapper wrap = new notestListWrapper();
                wrap.recordId = objemail.id;
                wrap.title = objemail.Subject;
                wrap.details = objemail.TextBody;
                wrap.CreatedDate = objemail.CreatedDate;
                wrap.createdBy = objemail.CreatedBy.Name;
                wrap.wrappedTitle = objemail.Subject;
                wrap.wrappedString = objemail.TextBody;
                lstnotestListWrapper.add(wrap);                
            }
        }
        lstnotestListWrapper.sort();
        system.debug('--lstnotestListWrapper--'+lstnotestListWrapper.size());
        return lstnotestListWrapper; 
    }
    /* wrapper class */  
    public class notestListWrapper implements Comparable{
        @AuraEnabled  public string title{get;set;}
        @AuraEnabled  public string wrappedTitle{get;set;}
        @AuraEnabled  public string details{get;set;}
        @AuraEnabled  public string wrappedString{get;set;}
        @AuraEnabled  public string recordId{get;set;}
        @AuraEnabled  public datetime CreatedDate{get;set;}
        @AuraEnabled  public string createdBy{get;set;}
        @AuraEnabled  public boolean SynchedFromSQL{get;set;}
        @AuraEnabled  public string PreviousId{get;set;}
            
        public Integer compareTo(Object ObjectToCompare) { //Returns an Integer value that is the result of the comparison.  
            notestListWrapper noteWrp = (notestListWrapper)ObjectToCompare;  
            if (noteWrp.CreatedDate > CreatedDate) return +1;
            if (noteWrp.CreatedDate < CreatedDate) return -1;
            return 0;            
        }
    }
    
    // Note method : 
    @AuraEnabled
    public static void createRecord (ContentNote nt, id PrentId){
        try{
            if(nt != null){
                insert nt;
                ContentDocument cd=[select id from ContentDocument where id=:nt.Id];
                ContentDocumentLink cdl=new ContentDocumentLink();
                cdl.ContentDocumentId=cd.id;
                cdl.LinkedEntityId=PrentId;
                cdl.ShareType='V';
                cdl.Visibility='AllUsers';
                insert cdl;
            }
        } catch (Exception ex){
            
        }
    }    
    
}