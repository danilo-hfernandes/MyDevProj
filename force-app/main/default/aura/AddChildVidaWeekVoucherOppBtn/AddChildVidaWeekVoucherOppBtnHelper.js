({
    doInitHelper: function(component, event, helper) {
        var oppId = component.get("v.recordId");
        var action = component.get("c.tryToAddChildVidaWeekVoucherOpp");
        action.setParams({
            recordId : oppId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state : '+state);
            if (state === "SUCCESS"){
                var map = response.getReturnValue();
                console.log('map : '+map);
                var stateStr = Object.keys(map)[0];
                console.log('stateStr : '+stateStr);
                var log = Object.values(map)[0];
                console.log('log : '+log);                
                if(stateStr == 'error'){
                    this.fireToastMessage(log,'error');
                    component.set("v.showSpin", false);
                }else{
                    this.fireToastMessage('Child Voucher Opp with a Membership Upgrade Vida Week Product created','success');
                    component.set("v.showSpin", false);
                }                
            }
            else{
                this.fireToastMessage(state,'error');
				component.set("v.showSpin", false);                
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
        component.set("v.showSpin", false);
    }
})