@isTest
public class ContentDocumentTriggerTest {
    @isTest    
    static void test1() {
        
        Apex_Trigger_On_Off__c cs = new Apex_Trigger_On_Off__c();
        cs.isEnable__c = false;
        cs.Name = 'ContentNoteCustomClass';
        insert cs;
        
        ContentVersion contentVersion = new ContentVersion(
          Title          = 'a picture',
          PathOnClient   = 'Pic.snote',
          VersionData    = Blob.valueOf('Test Content'),
          IsMajorVersion = true);
        insert contentVersion; 
        
        //Get Content Version
        List<ContentVersion> cvList = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id];
        System.assertEquals(cvList.size(), 1);
        
        //Get Content Documents
        List<ContentDocument> cdList = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        System.assertEquals(cdList.size(), 1);
        
        Database.delete(cdList,false);
    }
}