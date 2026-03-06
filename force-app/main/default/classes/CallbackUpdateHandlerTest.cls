@IsTest
private class CallbackUpdateHandlerTest {

    @IsTest
    static void testHandler() {
        // 1. Create a Callback_Number__c record
        Callback_Number__c cb = new Callback_Number__c(
            Call_Count__c = 0
        );
        insert cb;

        // 2. Create the Platform Event referencing the Callback Id
        Callback_Update_Event__e evt = new Callback_Update_Event__e(
            CallbackId__c = cb.Id
        );

        // 3. Publish the platform event
        Database.SaveResult sr = EventBus.publish(evt);

        // 4. Run asynchronous PE trigger logic
        Test.startTest();
        Test.stopTest();  // Executes the platform-event trigger
    }
}