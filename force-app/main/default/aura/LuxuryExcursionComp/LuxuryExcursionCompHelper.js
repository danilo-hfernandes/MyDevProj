({
    loadData : function(component){

        var action = component.get("c.getExcursions");

        action.setParams({
            recordId : component.get("v.recordId")
        });

        action.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
                component.set("v.excursionList", response.getReturnValue());
            }
        });

        $A.enqueueAction(action);
    }
})