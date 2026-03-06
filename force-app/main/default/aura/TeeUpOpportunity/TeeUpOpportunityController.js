({
	 doInit: function(component, event, helper){
         var userId = $A.get("$SObjectType.CurrentUser.Id");
         console.log('>>>>', userId);
         helper.doInitHelper(component, event);
        // helper.doInIt(component, event);
    },
    changeAction : function(component, event, helper) {
        var userID = event.getSource().get('v.value');
        //alert('userID - ' + userID);
        component.set('v.selectedUser',userID);
    },
    saveOpportunity: function(component, event, helper) {
        //alert('test');
        helper.saveOpportunityHelper(component, event,helper);
    },
    cancelOpportunity: function(component, event, helper) {
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    }
})