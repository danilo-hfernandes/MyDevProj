({
    fireToastMessage : function(component, event, message,type){
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