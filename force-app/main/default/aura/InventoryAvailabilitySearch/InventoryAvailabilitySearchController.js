({
    // 1
    advancedSearchFilter: function(component, event, helper){
        component.set("v.selectedInvId", null);
        helper.filterForAdvancedSearch(component, event, helper);
        var fromDt = component.get("v.fromDate");
        var toDt = component.get("v.toDate");
        if ((fromDt !== undefined && fromDt !== null) || (toDt !== undefined && toDt !== null)) {
            helper.filterForAdvancedSearch(component, event, helper);
            helper.updateDateOptions(component, event, helper);
        }
    },
    advancedSearchFilterToDate: function(component, event, helper){
        var fromDt = component.get("v.fromDate");
        var toDt = component.get("v.toDate");
        //console.log('toDt = '+toDt);
        component.set("v.selectedInvId", null);       
        component.set("v.InventoryAvailabilityList", null);
        if ((fromDt !== undefined && fromDt !== null) || (toDt !== undefined && toDt !== null)) {
            helper.filterForAdvancedSearch(component, event, helper);
        }
        //helper.updateDateOptions(component, event, helper);
    },
    //2 - Progam type
    allProgramType : function(cmp, event, helper){
        cmp.set("v.selectedInvId", null);
        helper.getAllprogramType(cmp, event, helper);
    },
    //2
    allRoomList : function(cmp, event, helper){
        cmp.set("v.selectedInvId", null);
        helper.getAllRoomList(cmp, event, helper);
    },
    
    //3
    allRoomType : function(cmp, event, helper){
        cmp.set("v.selectedInvId", null);
        helper.getallRoomType(cmp,event,helper);
    },
    //4
    InventoryAvailability : function(cmp, event, helper){
        cmp.set("v.selectedInvId", null);
        helper.getInventoryAvailability(cmp,event,helper);
    },
    //5
    
    //6
    doInit : function(cmp, event, helper){
        var checkUserAction;
        checkUserAction = cmp.get("c.checkUserPermission");        
        checkUserAction.setCallback(this, function(response) {
            var checkUserActionResult = response.getReturnValue();
            cmp.set("v.showComponent",checkUserActionResult);
        });
        $A.enqueueAction(checkUserAction);
    }, 
    
    
    ClosebookedInventory : function(component,event,helper){
        component.set("v.fromDate", null);
        component.set("v.toDate", null);
        component.set("v.selectPlaza", null);
        component.set("v.resortOption", null);
        component.set("v.selectRoomType", null);
        component.set("v.InventoryAvailabilityList", null);
        
        $A.get('e.force:refreshView').fire();
    },
    
    
})