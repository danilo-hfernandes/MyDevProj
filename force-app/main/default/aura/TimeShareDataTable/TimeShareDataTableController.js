({
    doInit : function(component, event, helper) {
        component.set('v.mycolumns', [
            {label: 'Account Timeshares', fieldName: 'linkName',type: 'url', 
             typeAttributes:{label: { fieldName: 'Name' }, target: '_blank'}},{
                 type:  'button',
                 typeAttributes: 
                 {
                     label: 'Add', 
                     variant:'brand',
                     name: 'AddToOpp', 
                     title: 'AddToOpp', 
                     disabled: false, 
                     value: 'Add',
                     iconPosition:'right'
                 }
             }
            
        ]);
        var OppId = component.get("v.recordId");
        
        var action=component.get("c.getTimeShare");
        action.setParams({
            "OppId":OppId});
        action.setCallback(this,function(e){  
            if(e.getState()=='SUCCESS'){
                var results=e.getReturnValue(); 
                console.log(results);
                if(results.length>0){
                    results.forEach(function(record){
                        record.linkName = '/'+record.Id;
                    });
                    component.set('v.results', results);                                          
                }
            }
        });
        $A.enqueueAction(action);
    }, 
    
    addRecord : function(component, event, helper) {
        
        var action = event.getParam('action');
        var row = event.getParam('row');
        var OppId = component.get("v.recordId");
        
        console.log('45=='+JSON.parse(JSON.stringify(row.Id)));
        var rowId=JSON.parse(JSON.stringify(row.Id));
        
        var action=component.get("c.addToOpportunity");
        action.setParams({
            "OppId":OppId,
            "timeShareId":rowId });
        action.setCallback(this,function(e){   
            console.log('54='+e.getReturnValue());
            
            console.log('55='+JSON.stringify(e));
            
            if(e.getReturnValue()=='Success'){
                console.log('59');
                var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Success!",
            "duration":"5000",
            "type":"success",
            "message": "The record has been updated successfully."
        });
        toastEvent.fire();
            }
   		/*  //HMR-601  phase 2     */
/*
            else if(e.getReturnValue()=='Exist'){
                console.log('59');
                var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Error!",
            "duration":"5000",
            "type":"error",
            "message": "Record already exist"
        });
        toastEvent.fire();
            }
            */
     	/**/       
            else if(e.getReturnValue()=='Fail'){
                console.log('70');
                var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Error!",
            "duration":"5000",
            "type":"error",
            "message": "Unexpected error"
        });
        toastEvent.fire();
            }
            
            
        });
        $A.enqueueAction(action);
        window.location.reload();
        console.log('84');
        //$A.get('e.force:refreshView').fire();
    },
    
    
    
})