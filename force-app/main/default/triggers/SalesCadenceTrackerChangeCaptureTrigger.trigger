trigger SalesCadenceTrackerChangeCaptureTrigger on ActionCadenceTrackerChangeEvent (after insert) {
    Apex_Trigger_On_Off__c cs = Apex_Trigger_On_Off__c.getValues('SalesCadenceTrackerChangeCapture');
    
    if(cs != null && cs.isEnable__c){        
        List<Lead> leadToSetCustomCadenceTracker = new List<Lead>();
        Map<Id,Lead> leadsToCheck = new Map<Id,Lead>();
        
        for (ActionCadenceTrackerChangeEvent event : Trigger.New) {
            /*System.debug('ActionCadenceTrackerChangeEvent : '+event);
			System.debug('event.ActionCadenceId : '+event.ActionCadenceId);
			System.debug('event.ActionCadenceId : '+event.TargetId);*/
            if(event.ActionCadenceId != null && event.TargetId != null){
                String myIdPrefix = String.valueOf(event.TargetId).substring(0,3);
                if(myIdPrefix == '00Q'){ //Lead Object
                    Lead ld = new Lead();
                    ld.Id = event.TargetId;
                    ld.First_Action_Cadence_Id__c = event.ActionCadenceId;
                    //System.debug('ld to put in  leadsToCheck: '+ld);
                    leadsToCheck.put(ld.Id,ld);
                }
            }
            
        }
        if(leadsToCheck.size()>0 && leadsToCheck != null)
        {
            List<Lead> leadsWithBlankFirst_Action_Cadence = [SELECT Id,First_Action_Cadence_Id__c FROM Lead WHERE Id IN : leadsToCheck.keySet() AND (First_Action_Cadence_Id__c = NULL OR First_Action_Cadence_Id__c = '')];
            if(leadsWithBlankFirst_Action_Cadence != null && leadsWithBlankFirst_Action_Cadence.size()>0)
            {
                //System.debug('leadsWithBlankFirst_Action_Cadence: '+leadsWithBlankFirst_Action_Cadence);
                for(Lead leadRec : leadsWithBlankFirst_Action_Cadence)
                {
                    leadRec.First_Action_Cadence_Id__c = leadsToCheck.get(leadRec.Id).First_Action_Cadence_Id__c;
                    leadRec.Sales_Cadence_Assignment_Attempt__c = 4;
                }
                update leadsWithBlankFirst_Action_Cadence;
            }
        }        
        
    }
}