({
    getProductValues : function(component, event, helper) {
        var action;
        action = component.get("c.getAllProductNames");
        action.setCallback(this, function(response) {
            var result = response.getReturnValue();
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.selectLocation', null);
                component.set('v.selectSection', null);
                component.set('v.selectRoomSize', null);
                component.set('v.MXVoucherAvailabilityList', null);
                component.set('v.LocationOption', null);
                component.set("v.selectedInvId", 'null');
                component.set("v.productOption", result.productOption);
            }
        });
        $A.enqueueAction(action);
    },
    picklistValue : function(component, event, helper) {
        var selectProgram = component.get("v.selectedProductName");
        console.log('>>>>selectProgram>>>'+selectProgram);
        var action;
        action = component.get("c.AvailabityCheck");
        action.setParams({ 
            productName  : component.get("v.selectedProductName"),
        });
        action.setCallback(this, function(response) {
            var result = response.getReturnValue();
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.selectLocation', null);
                component.set('v.selectSection', null);
                component.set('v.selectRoomSize', null);
                component.set('v.MXVoucherAvailabilityList', result.MXVoucherAvailability);
                component.set('v.LocationOption', result.locationOption);
                component.set("v.selectedInvId", 'null');
            }
        });
        $A.enqueueAction(action);
    },
    
    //2
    getAllLocationList : function(cmp, event, helper){
        var selectProgram = cmp.get("v.selectProgram"); 
        var action;
        if(cmp.get("v.selectLocation") != '--None--'){
            action = cmp.get("c.getAllResort");
            action.setParams({ 
                    LocationName : cmp.get("v.selectLocation"),
                    productName  : cmp.get("v.selectedProductName"),
                });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    cmp.set("v.SectionOptions",result.SectionOption);
                    cmp.set('v.MXVoucherAvailabilityList', result.MXVoucherAvailability);
                    // cmp.set('v.MessageNote', result.MessageNote);
                    cmp.set("v.selectedInvId", 'null');
                }
                else{
                    alert(response.getReturnValue());
                }
                
            });
            $A.enqueueAction(action);
            
        }else{
            alert('please select options');
        }                
        
    },
    
    //3
    getAllSectionName : function(cmp,event,helper) {
        var action;
        if(cmp.get("v.selectSection") != '--None--'){
            action = cmp.get("c.roomType");
            action.setParams({ 
                LocationName :cmp.get("v.selectLocation"),
                SectionName : cmp.get("v.selectSection"),
                productName  : cmp.get("v.selectedProductName"),
            });
        }else{
            action = cmp.get("c.getAllResort");
            action.setParams({ 
                LocationName : cmp.get("v.selectLocation"),
                productName  : cmp.get("v.selectedProductName"),
            });
        }
        action.setCallback(this, function(response) {
            var result = response.getReturnValue();
            var state = response.getState();
            if (state === "SUCCESS") {
                cmp.set("v.roomSizeOptionList",result.roomType);
                // cmp.set('v.MessageNote', result.MessageNote);
                cmp.set("v.selectedInvId", 'null');
                cmp.set('v.MXVoucherAvailabilityList', result.MXVoucherAvailability);
                
            }
            else{
                alert(response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
        
    },
    
    getAllRoomSize : function(cmp,event,helper) {
        var selectProgram = cmp.get("v.selectRoomSize"); 
        var action;
        if(cmp.get("v.selectRoomSize") != '--None--'){
            action = cmp.get("c.getAllProgram");
            action.setParams({ 
                resoertName : cmp.get("v.selectSection"),
                PlazzaName : cmp.get("v.selectLocation"),
                roomType : cmp.get("v.selectRoomSize"),
                productName  : cmp.get("v.selectedProductName"),
            });
        }else{
            action = cmp.get("c.roomType");
            action.setParams({ 
                PlazzaName :cmp.get("v.selectLocation"),
                resoertName : cmp.get("v.selectSection"),
                productName  : cmp.get("v.selectedProductName"),
            });
        }
        action.setCallback(this, function(response) {
            var result = response.getReturnValue();
            var state = response.getState();
            if (state === "SUCCESS") {
                cmp.set('v.MXVoucherAvailabilityList', result.MXVoucherAvailability);
                //cmp.set('v.MessageNote', result.MessageNote);
                cmp.set("v.selectedInvId", 'null');
            }
            else{
                alert(response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
        
    },
    
    
})