@isTest(SeeAllData=true)
public class SalesCadenceTrackerChangeCaptureTest {
    @isTest
    static void testChangeDataCapture(){
        Test.enableChangeDataCapture();
        
        ActionCadenceTracker anActionCadence = [SELECT ActionCadenceId,CompletionDisposition,CompletionReason,CurrentStepId,ErrorMessage,ExitGlobalRuleId,IsTrackerActive,LastCompletedStepId,OwnerId,State,TargetId FROM ActionCadenceTracker ORDER BY TargetId ASC LIMIT 1];
        User zappierUser = [SELECT Id,Username FROM User WHERE Email = 'zappier@nerdsoft.com' OR Email = 'zappier@nerdsoft.com.invalid' LIMIT 1];
        Id leadCFRecTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Carefree_Destinations').getRecordTypeId();
        Lead ld = [SELECT Id FROM Lead WHERE RecordTypeId =: leadCFRecTypeId AND ActionCadenceId = NULL AND IsConverted = FALSE AND Phone != null AND Email != Null LIMIT 1];
        
        /*List<User> users = new List<User>();
        users.add(zappierUser);*/
        System.debug('anActionCadence : '+anActionCadence);
        
        // Create mock CREATE change event
        EventBus.ChangeEventHeader createHeader = new EventBus.ChangeEventHeader();
        //createHeader.recordIds = new List<String>{ '8HFR00000005BfAOAU',stepTrackers[0].id };
        createHeader.changeType='CREATE';
        createHeader.entityName='ActionCadenceTracker';
        createHeader.changeOrigin='com/salesforce/api/rest/55.0';
        createHeader.transactionKey = '0004541-cd0b-4b1c-5400-2f18d8f2feb7';
        createHeader.commitUser = zappierUser.Id;
        ActionCadenceTrackerChangeEvent createEvent = new ActionCadenceTrackerChangeEvent();
        createEvent.changeEventHeader = createHeader;
        createEvent.put('ActionCadenceId', anActionCadence.Id);
        createEvent.put('LastCompletedStepId', anActionCadence.LastCompletedStepId);
        createEvent.put('State', anActionCadence.State);
        createEvent.put('TargetId', ld.Id);
        createEvent.put('CurrentStepId', anActionCadence.CurrentStepId);
        EventBus.publish(createEvent);
        Test.getEventBus().deliver();
        
    }
}