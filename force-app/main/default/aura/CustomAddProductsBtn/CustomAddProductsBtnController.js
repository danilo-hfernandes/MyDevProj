({
    
    doInit: function(component, event, helper) {
        
        var action = component.get("c.checkOppLineItemCreatePermission");
        
        
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                var accessResult = response.getReturnValue();                
                var logStr = Object.keys(accessResult)[0];
                var userWithAccess = Object.values(accessResult)[0];
                
                if(!userWithAccess)
                {
                    component.set("v.blockMainBtn",true);
                }
                else
                {
                    component.set("v.blockMainBtn",false);
                }    
                    
                 
            } else {
                helper.showToast(component, "Error", "An error occurred while fetching data", "error");
                component.set("v.showSpin", false);
            }
        });
        
        $A.enqueueAction(action);  
        
    },    
    openModal: function(component, event, helper) { 
        component.set("v.showSpin", true);
        helper.fetchPriceBookEntries(component, event, helper);        
        component.set("v.showPBEModal",true);        
    },
    closeModal: function(component, event, helper) {
        component.set("v.showPBEModal",false);        
    },
    closeOLIModal: function(component, event, helper) {
        component.set("v.showOLIModal",false);        
    },
    prepareOpportunityProducts: function(component, event, helper) {
        component.set("v.showSpin", true);
        var selectedEntries = [];
        var checkboxes = component.find('selectRow');
        
        checkboxes.forEach(function(checkbox) {            
            if (checkbox.get("v.checked")) { // Check if the checkbox is selected                
                var title = checkbox.get("v.name");
                //add selected price book entry Id
                selectedEntries.push(title);
            }
        });
        
        if (selectedEntries.length === 0) {
            // Display error message using showToast helper method
            helper.showToast(component, "Error", "Please select at least one product to add.", "error");
            component.set("v.showSpin", false);
        }else{
            // Proceed with further processing
            //console.log(selectedEntries);
            var priceBookEntries = component.get("v.priceBookEntries");
            var pbesSelected = [];
            priceBookEntries.forEach(function(entry) {
                if (selectedEntries.includes(entry.Id)){
                    pbesSelected.push(entry);
                }
            });
            
            console.log('pbesSelected = '+pbesSelected);
            var opportunityId = component.get("v.recordId");
            
            // Call the Apex method and pass the priceBookEntries list
            var action = component.get("c.generateOppLineItems");
            action.setParams({
                pbeList: pbesSelected,
                oppId: opportunityId
            });
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {                    
                    var mapOlis = response.getReturnValue();                
                    var logStr = Object.keys(mapOlis)[0];                
                    var opportunityLineItems = Object.values(mapOlis)[0];                    
                    component.set("v.oppLineItems",opportunityLineItems);
                    component.set("v.showPBEModal",false);
                    component.set("v.showOLIModal",true);                    
                    component.set("v.showSpin", false);
                    
                } else {
                    helper.showToast(component, "Error", "An error occurred while fetching data", "error");
                    component.set("v.showSpin", false);
                }
            });
            
            $A.enqueueAction(action);            
        }
    },
    saveOpportunityProducts: function(component, event, helper){
        component.set("v.showSpin", true);
        var action = component.get("c.saveOppLineItems");
         var opportunityLineItems = component.get("v.oppLineItems");
        action.setParams({
            oliList: opportunityLineItems
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {                    
                var mapOlis = response.getReturnValue();                
                var stateStr = Object.keys(mapOlis)[0];                
                var errorLog = Object.values(mapOlis)[0];
                /*component.set("v.showPBEModal",false);
                component.set("v.showOLIModal",true);
                component.set("v.oppLineItems",opportunityLineItems); */
                
                if (stateStr == 'true') {                    
                    helper.showToast(component,'Done!',"Products Created !","success");
                    component.set("v.showOLIModal",false);
                    component.set("v.showSpin", false);
                    $A.get('e.force:refreshView').fire();
                } else if (stateStr == 'false') {
                    var errorMsg = stateStr;
                    // Display error message
                    helper.showToast(component, "Error", errorLog, "error");
                    component.set("v.showSpin", false);
                } else {
                    helper.showToast(component, "Error", "Invalid response from the server", "error");
                    component.set("v.showSpin", false);
                }
            } else {
                helper.showToast(component, "Error", "An error occurred while fetching data", "error");
                component.set("v.showSpin", false);
            }
        });        
        $A.enqueueAction(action);      
    }
   
})