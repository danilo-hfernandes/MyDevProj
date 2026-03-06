public with sharing class DNCAPICallController {
    
    @future(callout=true)
    public static void sendDNCRequest(Id recordId) {
        try {
            //String endpoint = 'https://aidialerintegration.azurewebsites.net/api/Lead/donotcall/' + recordId;
            
            Boolean runningInASandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
            String endpoint = '';
            // API endpoint - only recordId is dynamic
            if(runningInASandbox){
                endpoint = 'https://aidialerintegration.azurewebsites.net/api/Lead/donotcall/00QVm00000EtpkzMAB'; //' + recordId;
            } else {
                endpoint = 'https://aidialerintegration.azurewebsites.net/api/Lead/donotcall/' + recordId;
                
            }
            HttpRequest req = new HttpRequest();
            req.setEndpoint(endpoint);
            req.setMethod('GET');

            // Authorization Header (use Named Credential ideally)
            String authToken = 'Bearer OWDQj3uNYsNDIM0ixzhrDy4LwhHC425j4zkmXh1q1BrbaHTS2Av0nu7NtKo_CfgOnZqaf0phLF86lqtRbgXNsA';
            req.setHeader('Authorization', authToken);

            Http http = new Http();
            HttpResponse res = http.send(req);

            System.debug('DNC API Response: ' + res.getStatus() + ' - ' + res.getBody());

            if (res.getStatusCode() == 200) {
                insertNote(recordId);
                
            }

        } catch (Exception e) {
            System.debug('Error in sendDNCRequest: ' + e.getMessage());
        }
    }

    // Create ContentNote attached to the record
    private static void insertNote(Id recordId) {
        try {
            // Create the ContentNote
            ContentNote note = new ContentNote();
            note.Title = 'Do Not Call Updated';
            note.Content = Blob.valueOf(
                'API AI - DoNotCall field was updated on ' +
                String.valueOf(Datetime.now().format('yyyy-MM-dd HH:mm:ss z'))
            );
            insert note;
    
            // Link the ContentNote to the parent record
            ContentDocumentLink link = new ContentDocumentLink();
            link.ContentDocumentId = note.Id;
            link.LinkedEntityId = recordId;
            link.ShareType = 'V'; // Viewer
            link.Visibility = 'AllUsers';
            insert link;
    
            System.debug('ContentNote created and linked successfully for record ' + recordId);
        } catch (Exception e) {
            System.debug('Error inserting ContentNote: ' + e.getMessage());
        }
    }
}