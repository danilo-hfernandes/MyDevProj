@RestResource(urlMapping='/InsertFile/*')
global with sharing class filesUploadService {
    private static final String SUCCESS = 'Success';
    private static final String ERROR = 'Error';
    private static String TEMPLATE = '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd"><html lang="en"><head><meta http-equiv="content-type" content="text/html; charset=utf-8"><title>WWPT Contract</title></head><body><TABLE width="100%"><tr><td align="left"><img src="https://checkout.worldwidepropertytransfers.com/Content/Images/wwpt-logo.png" alt="WWPT Logo" height="100"></td><td align="right"></td></tr></TABLE><br><div style="margin:20px;">Dear [FIRSTLASTNAME], <br><br><br>The documents for your transaction have been electronic signed, the attached document contains your copy.<br><br><br>Best Regards,<br><br><br>Wordwide Property Transfer Contracts Team</div></body></html>'; 
    private static string NOTEBODY = 'Dear [FIRSTLASTNAME],\n\n\n The documents for your transaction have been electronic signed, the attached document contains your copy.\n\n\nBest Regards,\n\n\nWordwide Property Transfer Contracts Team';
    
    @Httppost
    global static ResponseWrapper createRecord(){
        ResponseWrapper response = new ResponseWrapper();
        response.status = SUCCESS; 
        response.errorMessage = '';
        RestRequest req = RestContext.request;
        webServiceParameter container = (webServiceParameter)System.JSON.deserialize(
            RestContext.request.requestBody.tostring(), webServiceParameter.class);
        try {
            List<Opportunity> opList = [Select Account.Name, Account.Email__c, StageName from Opportunity where Id =: container.OppId];
             if(opList != null && opList.size() > 0){
                 
                String noteTxt = NOTEBODY.replace( '[FIRSTLASTNAME]', opList[0].Account.Name);
                // File insert under opportunity 
                ContentVersion conVer = new ContentVersion();
                conVer.ContentLocation = 'S'; 
                conVer.PathOnClient = container.ContentType; // The files name, extension is very important here which will help the file in preview.
                conVer.Title = container.Name; // Display name of the files
                system.debug('----conVer---'+conVer);
                Blob body = EncodingUtil.base64Decode(container.Body);
                conVer.VersionData = body;
                conVer.Description = container.Description;
                insert conVer;    
                
                Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;
                ContentDocumentLink conDocLink = New ContentDocumentLink();
                conDocLink.LinkedEntityId = container.OppId; // Specify RECORD ID here i.e Any Object ID (Standard Object/Custom Object)
                conDocLink.ContentDocumentId = conDoc;  //ContentDocumentId Id from ContentVersion
                conDocLink.shareType = 'V';
                insert conDocLink;
                    
                Opportunity opp = opList[0];
                 
 				if (opp.StageName != 'Closed Won') {
                    opp.StageName = 'Contract Completed';
                    opp.Contract_Received__c = true;
                    update opp; 
                }
                response.recordId = container.OppId;
            }else{
                response.status = ERROR;
                response.errorMessage = 'The Opportunity ID does not exist';
                response.recordId = container.OppId;
            }
            
        } catch (Exception ex){
            System.debug('Exception occurrred on LineNumber:' + ex.getLineNumber() + ', Message:' + ex.getMessage());
            response.status = ERROR;
            response.errorMessage = 'Message:' + ex.getMessage()  + ' - Exception occurrred on LineNumber: ' + ex.getLineNumber();
            response.recordId = container.OppId;
        }
        return response;   
    }
    private class webServiceParameter {
        String Body;
        String ContentType;
        String Name;
        String OppId;
        string Description;
        boolean Email;
    }
    global class ResponseWrapper{
        webservice String status;
        webservice String errorMessage;
        webservice String recordId;
    }
    public class MyException extends Exception {}
}