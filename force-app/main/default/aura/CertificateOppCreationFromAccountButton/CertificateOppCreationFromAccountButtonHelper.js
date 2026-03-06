({
    /* doInitHelper funcation to fetch all records, and set attributes value on component load */
    doInitHelper : function(component,event){ 
        var oppId = component.get("v.recordId");
        var action = component.get("c.isOpportunityCreated");
        action.setParams({
            recordId : oppId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                var oRes = response.getReturnValue();
                if(oRes == false){
                    this.fireToastMessage('Voucher Opportunity exist','error');                
                }else{
                    this.fireToastMessage('Voucher Opportunity records created','success');   
                    
                }
                
            }
            else{
                this.fireToastMessage(state,'error');                
            }
        });
        $A.enqueueAction(action);  
    },
    fireToastMessage : function(message,type){
        var showToast = $A.get("e.force:showToast");  
        showToast.setParams({ 
            'duration': 5000,
            'title' : 'Message', 
            'message' : message,
            'type': type
        }); 
        showToast.fire(); 
        $A.get("e.force:closeQuickAction").fire()    
        
    }
})