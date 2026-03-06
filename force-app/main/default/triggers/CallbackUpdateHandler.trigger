trigger CallbackUpdateHandler on Callback_Update_Event__e (after insert) {
    List<Id> callbackIds = new List<Id>();
    for (Callback_Update_Event__e evt : Trigger.new) {
        if (evt.CallbackId__c != null)
            callbackIds.add(evt.CallbackId__c);
    }
    if (callbackIds.isEmpty()) return;

    List<Callback_Number__c> updates = [
        SELECT Id, Call_Count__c, Last_Call_Made__c
        FROM Callback_Number__c
        WHERE Id IN :callbackIds
    ];

    for (Callback_Number__c rec : updates) {
        rec.Call_Count__c = (rec.Call_Count__c == null ? 1 : rec.Call_Count__c + 1);
        rec.Last_Call_Made__c = System.now();
    }
    update updates;
}