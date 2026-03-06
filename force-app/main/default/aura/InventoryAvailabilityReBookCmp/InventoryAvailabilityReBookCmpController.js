({
    // 1
    advancedSearchFilter: function(component, event, helper){
        component.set("v.selectedInvId", null);
        component.set("v.showSpin", true);
        component.set("v.InventoryAvailabilityList", null);
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
        component.set("v.selectedInvId", null);
        component.set("v.showSpin", true);
        component.set("v.InventoryAvailabilityList", null);
        if ((fromDt !== undefined && fromDt !== null) || (toDt !== undefined && toDt !== null)) {
            helper.filterForAdvancedSearch(component, event, helper);
        }
        //helper.updateDateOptions(component, event, helper);
    },
    //2 - Progam type
    allProgramType : function(cmp, event, helper){
        cmp.set("v.selectedInvId", null);
        cmp.set("v.InventoryAvailabilityList", null);
        cmp.set("v.showSpin", true);
        helper.getAllprogramType(cmp, event, helper);
    },
    //2
    allRoomList : function(cmp, event, helper){
        cmp.set("v.selectedInvId", null);
        cmp.set("v.InventoryAvailabilityList", null);
        cmp.set("v.showSpin", true);
        helper.getAllRoomList(cmp, event, helper);
    },
    //3
    allRoomType : function(cmp, event, helper){
        cmp.set("v.selectedInvId", null);
        cmp.set("v.InventoryAvailabilityList", null);
        cmp.set("v.showSpin", true);
        helper.getallRoomType(cmp,event,helper);
    },
    //4
    InventoryAvailability : function(cmp, event, helper){
        cmp.set("v.selectedInvId", null);
        cmp.set("v.InventoryAvailabilityList", null);
        cmp.set("v.showSpin", true);
        helper.getInventoryAvailability(cmp,event,helper);
    },
    //5
    bookedInventory : function(cmp,event,helper){
         helper.bookedInventoryInOpp(cmp,event,helper);
    },
    // 6
    doInit : function(cmp, event, helper){
          var recordTypeId = cmp.get("v.recordId");
        console.log('Record type === '+recordTypeId);
          helper.checktheBooking(cmp,event,helper);
        var varoppId = cmp.get("v.recordId");
        var action = cmp.get("c.getNumberOfNightsByOpportunityId");
        action.setParams({ 
            opportunityId : varoppId
        });        
        action.setCallback(this, function(response) {
            var result = response.getReturnValue();            
            cmp.set("v.numberOfNights", result);
            var numberOfNights = result;
            var extraNightsOptions = [];
            
            // Calculate the maximum number of extra nights
            var maxExtraNights = 7 - numberOfNights;
            
            // Add extra night options, only if the remaining nights are positive
            if (maxExtraNights > 0) {
                for (var i = 0; i <= maxExtraNights; i++) {  //263 for (var i = 1; i <= maxExtraNights; i++)
                    extraNightsOptions.push(i);
                }
            }
            else
            {
                extraNightsOptions.push(0);
            }
            
            // Set the 'extraNightsOptions' attribute with the valid options
            cmp.set("v.extraNightsOptions", extraNightsOptions);
        });
        $A.enqueueAction(action);
    }, 
    getData : function(cmp, event, helper){
      console.log(JSON.stringify(cmp.get("v.opportunityObj")));
        var oppRecordtype = cmp.get("v.opportunityObj").Record_Type_Name__c;
        console.log('oppRectype== '+oppRecordtype);
        var oppNoShow = cmp.get("v.opportunityObj").No_Show__c;
        console.log('oppNoShow== '+oppNoShow);
        
        if(oppNoShow == true && (oppRecordtype == 'Voucher' || oppRecordtype == 'VI Referral Date Request' || oppRecordtype == 'Vida Book With Us')){
            cmp.set('v.disableRebookReservation',true);
        }

    },
    // Extra
    selectedInvAvailability : function(component,event,helper){
        var ctarget = event.currentTarget;
        var id_str = ctarget.dataset.value;
        component.set("v.selectedInvId", id_str);
        $A.get('e.force:refreshView').fire();
    },
    // Extra
    isRefreshed : function(component,event,helper){
       helper.checktheBooking(component,event,helper);
    },
    buttonClickCall : function(component,event,helper){
        $A.enqueueAction(component.get('c.doInit'));
        component.set("v.buttonClick", false);
        $A.get('e.force:refreshView').fire();
    },
     rebookInventoryYes : function(component,event,helper){
        component.set("v.rebookInvSearch", true);
         component.set("v.buttonClick", true);
         
        $A.get('e.force:refreshView').fire();
    },
    rebookInventoryNo : function(component,event,helper){
        component.set("v.rebookInvSearch", false);
        component.set("v.buttonClick", true);
        $A.get('e.force:refreshView').fire();
    },
    ClosebookedInventory : function(component,event,helper){
        component.set("v.buttonClick", true);
        component.set("v.rebookInvSearch", false);
        component.set("v.fromDate", null);
        component.set("v.toDate", null);
        component.set("v.selectPlaza", null);
        component.set("v.resortOption", null);
        component.set("v.selectRoomType", null);
        component.set("v.InventoryAvailabilityList", null);
         
        $A.get('e.force:refreshView').fire();
    },
    
    
})