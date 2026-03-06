({
    // 1
    advancedSearchFilter: function(component, event, helper){
        component.set("v.selectedInvId", null);
        component.set("v.showSpin", true);
        component.set("v.InventoryAvailabilityList", null);
        /*var fromDT = component.get('v.fromDate');      
        var nights = parseInt(component.get('v.numberOfNights'),10);
        console.log('nights = '+nights);
        var dt = new Date(fromDT);        
        dt.setDate(dt.getDate() + nights);
        var year = dt.getFullYear();
        var month = String(dt.getMonth() + 1).padStart(2, '0'); // Months are 0-based
        var day = String(dt.getDate()).padStart(2, '0');
        var formattedDate = `${year}-${month}-${day}`;
        if(fromDT != null && nights != null)
        {
            console.log('dt = '+formattedDate);
            component.set('v.toDate',formattedDate);            
        }*/
        var vidaInfluencerFlag= component.get("v.hasVidaInfluencerProd");
        var nights = component.get('v.numberOfNights');
        var numberOfNights = component.get("v.defaultnumberOfNights");
        console.log('>>numberOfNights>>',numberOfNights);
        if(vidaInfluencerFlag && nights > 7 && nights != null && nights != undefined){
            component.set('v.numberOfNights', numberOfNights);
            alert('The Number Of Nights can\'t be greater than 7 for Vidanta Influencer Products');
            
        }
        else{
            var fromDt = component.get("v.fromDate");
            var toDt = component.get("v.toDate");
            if ((fromDt !== undefined && fromDt !== null) || (toDt !== undefined && toDt !== null)) {
                if(nights != null && nights != undefined)
                helper.filterForAdvancedSearch(component, event, helper);
                helper.updateDateOptions(component, event, helper);
            }
        }
    },
    advancedSearchFilterToDate: function(component, event, helper){
        var fromDt = component.get("v.fromDate");
        var toDt = component.get("v.toDate");
        console.log('toDt = '+toDt);
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
        helper.checktheBooking(cmp,event,helper);
        helper.checkforVidaInfluencerProduct(cmp,event,helper);
        var varoppId = cmp.get("v.recordId");
        //console.log('entrou no doInit');
        var action = cmp.get("c.getNumberOfNightsByOpportunityId");
        //console.log('action getNumberOfNightsByOpportunityId = '+action);
        //console.log('varoppId = '+varoppId);
        action.setParams({ 
            opportunityId : varoppId
        });        
        action.setCallback(this, function(response) {            
            var result = response.getReturnValue();
            //console.log('standard number of nights = ? ' +result);
            cmp.set("v.numberOfNights", result);
            cmp.set("v.defaultnumberOfNights", result);
            
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
            cmp.set('v.disableBookReservation',true);
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
    setSupplier : function(component,event,helper){
        var ctarget = event.currentTarget;
        var id_str = ctarget.dataset.value;
        component.set("v.supplierInv", id_str);
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
    ClosebookedInventory : function(component,event,helper){
        component.set("v.buttonClick", true);
        component.set("v.fromDate", null);
        component.set("v.toDate", null);
        component.set("v.selectPlaza", null);
        component.set("v.resortOption", null);
        component.set("v.selectRoomType", null);
        component.set("v.InventoryAvailabilityList", null);
         
        $A.get('e.force:refreshView').fire();
    }
})