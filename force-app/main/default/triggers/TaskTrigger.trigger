trigger TaskTrigger on Task (before update) {
TaskTriggerHandler tsk = New TaskTriggerHandler();
    tsk.updateTaskStatus(trigger.new,trigger.OldMap);
}