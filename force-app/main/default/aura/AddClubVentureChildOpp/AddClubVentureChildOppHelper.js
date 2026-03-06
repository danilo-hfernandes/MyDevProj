({
	fireToastMessage: function(component,message,type){
        var showToast = $A.get("e.force:showToast");
        showToast.setParams({
            'duration': 7000,
            'title' : 'Message',
            'message' : message,
            'type': type
        });
        //$A.get('e.force:refreshView').fire();
        showToast.fire();
        component.set("v.showSpin", false);
        if(type === 'error'){        
            $A.get("e.force:closeQuickAction").fire()
        }
    }
})