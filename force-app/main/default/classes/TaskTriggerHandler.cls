public class TaskTriggerHandler {
    public void blockCadenceTaskCompletionWithoutDisposition(List<Task> newRecordList,Map<id,Task> oldMap){
        Id userId = userinfo.getUserId();
        for(Task tsk : newRecordList){
            System.debug('task blockCadenceTaskCompletionWithoutDisposition method triggered');
            System.debug('tsk.Subject.contains(TourGen-FB-MX *New Lead)='+tsk.Subject.contains('TourGen-FB-MX *New Lead'));
            System.debug('tsk.Disposition__c = '+tsk.Disposition__c);
            System.debug('tsk.CallDisposition = '+tsk.CallDisposition);
            System.debug('tsk.rcsfl__hvs_disposition__c = '+tsk.rcsfl__hvs_disposition__c);
            if(tsk.Subject.contains('TourGen-FB-MX *New Lead') && tsk.Status == 'Completed' && (tsk.Disposition__c == '' || tsk.CallDisposition == '' || tsk.rcsfl__hvs_disposition__c == '')){
             System.debug('blockCadenceTaskCompletionWithoutDisposition validation rule entered');
            }
        }
    }
    public void updateTaskStatus(List<Task> newRecordList,Map<id,Task> oldMap){
        Id devRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Replacement Property Request').getRecordTypeId();
        Id taskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Inventory Replacement Request').getRecordTypeId();
        Map<id,Task> oppId = New Map<Id,Task>();
        List<Task> taskrec = New List<Task>();
        for(Task tsk : newRecordList){
            
            
            if(tsk.RecordTypeId == devRecordTypeId && tsk.Status == 'Rejected' && oldMap.get(tsk.id).Status != tsk.Status){
                oppId.put(tsk.WhatId,tsk);
            }
            if(tsk.RecordTypeId == devRecordTypeId && tsk.Status == 'Accepted' && oldMap.get(tsk.id).Status != tsk.Status){
                oppId.put(tsk.WhatId,tsk);
            }
        }
        taskrec = [Select Id,Status,RecordTypeId,WhatId from Task where WhatId IN:oppId.keySet()];
        
        List<Task> tskupdate = New List<Task>();
        if(taskrec.size() > 0 && taskrec != Null){
            for(Task ts : taskrec){
                Task tk = New Task();
                
                if(ts.RecordTypeId == taskRecordTypeId && oppId.get(ts.WhatId).Status == 'Rejected'){
                    ts.Status = 'Replacement Property Rejected';
                    tk.id = ts.Id;
                    tk.Status = ts.Status;
                    tskupdate.add(tk);
                }
                if(ts.RecordTypeId == taskRecordTypeId && oppId.get(ts.WhatId).Status == 'Accepted'){
                    ts.Status = 'Replacement Property Approved';
                    tk.id = ts.Id;
                    tk.Status = ts.Status;
                    tskupdate.add(tk);
                }
                
                
            }
            update tskupdate;
        }
    }

}