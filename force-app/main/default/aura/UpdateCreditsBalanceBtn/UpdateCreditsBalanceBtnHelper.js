({
    getAccountDetails: function(component) {
        var accId = component.get("v.recordId");
        var action = component.get("c.getAccountData");
        
        action.setParams({
            accountId: accId
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var account = response.getReturnValue();
                console.log('account = '+account);
                console.log('account +account.Credits_Balance__c = '+account.Credits_Balance__c);
                component.set("v.creditsBalance", account.Credits_Balance__c);
                if(account.Member_Number__c == null || account.Member_Number__c == '' || account.Member_Number__c == undefined)
                {
                    component.set("v.isUpdating", true);
                }
            } else {                
                this.fireToastMessage(component,'Error fetching account details: '+response.getError(),'error');
            }
        });
        
        $A.enqueueAction(action);
    },
    
    updateAccountCreditsBalance: function(component) {
        
        component.set("v.isUpdating", true);
        
        var accId = component.get("v.recordId");
        var action = component.get("c.updateAccountCredits");
        
        action.setParams({
            accountId: accId
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var map = response.getReturnValue();
                var stateStr = Object.keys(map)[0];
                var log = Object.values(map)[0];
                if(stateStr == 'error'){
                    this.fireToastMessage(component,log,'error');
                }
                else
                {
                    this.fireToastMessage(component,log,'success');
                }
                this.getAccountDetails(component);
                $A.get('e.force:refreshView').fire();
            } else {
                this.fireToastMessage(component,'Error updating credits balance: '+response.getError(),'error');                
            }
            component.set("v.isUpdating", false);
        });
        
        $A.enqueueAction(action);


    },

    fireToastMessage : function(component,message,type){
        var showToast = $A.get("e.force:showToast");
        showToast.setParams({
            'duration': 5000,
            'title' : 'Message',
            'message' : message,
            'type': type
        });
        $A.get('e.force:refreshView').fire();
        showToast.fire();
        component.set("v.showSpin", false);
        //$A.get("e.force:closeQuickAction").fire();
    }
})