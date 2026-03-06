({
    openModel: function(component, event, helper) {
        // for Display Model,set the "isOpenMarival" attribute to "true"
        var supplierType = component.get("v.opportunityRecord.Supplier__c");
        component.set("v.plazaOptions", null);
        component.set("v.plazaMarival", null);
        component.set("v.resortOptions", null);
        component.set("v.siteNameMarival", null);
        component.set("v.capacityMarival", null);
        component.set("v.roomTypeMarival", null);
        component.set("v.checkOutMarival", null);
        component.set("v.checkInMarival", null);
        component.set("v.supplierMarival", supplierType);
        var action = component.get("c.getPlazaRecords");
        action.setParams({
            supplier: supplierType
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var records = response.getReturnValue();
                console.log('>>>'+records);
                var options = [];
                //var plaza = '';
                for (var i = 0; i < records.length; i++) {
                    console.log('>>>'+records[i]);
                    options.push({
                        "label": records[i],
                        "value": records[i]
                    });
                }
                console.log('>>>'+options);
                component.set("v.plazaOptions", options);
            } else {
                console.error("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);
        
        component.set("v.isOpenMarival", true);
    },
    
    closeModel: function(component, event, helper) {

        component.set("v.isOpenMarival", false);
    },
    
    handleSiteChange: function(component, event, helper) {
        // Update the capacity based on site selection
        console.log('handleSiteChange entered>>>');
        helper.handleSiteChangeHelper(component);
    },
    handlePlazaChange : function(component, event, helper) {
        // Update the site based on plaza selection
        console.log('handleSiteChange entered>>>');
        helper.handlePlazaChangeHelper(component);
    },
    saveReservation: function(component, event, helper) {
        // Implement the save logic in helper
        component.set("v.showSpinMarival", true);
        helper.saveReservationHelper(component);
        
    },
    handleCheckInChange: function(component, event, helper) {
        
        
        console.log('handleCheckInChange entered>>>');
        
        //312
        var checkInMarivalDt = component.get("v.checkInMarival");
        if ((checkInMarivalDt !== undefined && checkInMarivalDt !== null)) {
            helper.updateDateOptions(component, event, helper);
        }

        helper.handleCheckInChangeHelper(component, event, helper);

        helper.getExtraNightsTotalHelper(component, event, helper);

    },
    doInit : function(cmp, event, helper){ //312
        var recordTypeId = cmp.get("v.recordId");
        console.log('Record type === '+recordTypeId);
        helper.checktheBooking(cmp,event,helper);
        helper.initializeMinCheckInDate (cmp);
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
                for (var i = 0; i <= maxExtraNights; i++) {  
                    extraNightsOptions.push(i);
                }
            }
            else
            {
                extraNightsOptions.push(0);
            }
            
            // Set the 'extraNightsOptions' attribute with the valid options
            cmp.set("v.extraNightsOptions", extraNightsOptions);
            //cmp.set("v.numberOfNights", numberOfNights);
        	console.log('doInit extraNightsOptions>>>'+extraNightsOptions);
        	console.log('doInit numberOfNights>>>'+numberOfNights);
        });
        $A.enqueueAction(action);
    },
    handleNightsChange : function(cmp, event, helper){ //329

        var numberOfNights = cmp.get("v.numberOfNights");
        var extraNightsOptions = [];
        var maxExtraNights = 7 - numberOfNights;
        var extraNights = cmp.get("v.extraNights");

        // Add extra night options, only if the remaining nights are positive
        if (maxExtraNights > 0) {
            //for (var i = 0; i <= maxExtraNights; i++) {  
            for (var i = 0; i <= Math.min(maxExtraNights, 3); i++) {

                extraNightsOptions.push(i);
            }
        }
        else
        {
            extraNightsOptions.push(0);
        }
                
        // Set the 'extraNightsOptions' attribute with the valid options
        cmp.set("v.extraNightsOptions", extraNightsOptions);
		cmp.set("v.extraNights", 0);

        helper.handleCheckInChangeHelper(cmp, event, helper);
       
    }
    
    
    
})