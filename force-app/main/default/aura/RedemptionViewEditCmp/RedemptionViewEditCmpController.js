({
    doInit: function(component, event, helper) {
        helper.doInitHelper(component, event);
        helper.doValidateColumns(component, event);
    }, 
    timeshareJs : function(component,event){ 
        component.set("v.isLoaded",false);
        var ctarget = event.currentTarget;
        var id_str = ctarget.dataset.value;
        component.set("v.seletedTimeshareId", id_str);
        component.set("v.isLoaded",true);
        //$A.get('e.force:refreshView').fire();  
    },
    editRecord : function(component, event, helper) {
        var idx = event.target.id;
        var idx2 = event.target.value;
        var action = component.get("c.redemptionWrapper");
        action.setParams({
            "redId":idx 
        });
        action.setCallback(this, function(response){
            var STATE = response.getState();
            if(STATE === "SUCCESS") {
                var oRes = response.getReturnValue();
                console.log(oRes);
                component.set('v.redemptionWrpobj', idx);
                component.set('v.redemptionWrpobjwrp', oRes);
                const profileName = component.get('v.CurrentUser')['Profile'].Name;
          			if(profileName == 'System Administrator'){
             			component.set("v.noShow", true);
                     } else{
                       component.set("v.noShow", false);      
                    }
             }
             component.set("v.isModalOpen", true);
            
        })
        $A.enqueueAction(action);
    },
    addRecord : function(component, event, helper) {
        var idx = event.target.id;
        var idx2 = event.target.value;
        console.log('38='+idx);
       var action = component.get("c.addNewRedemption");
        action.setParams({
            "redId":idx 
        });
        action.setCallback(this, function(response){
            var STATE = response.getState();
            if(STATE === "SUCCESS") {
                var oRes = response.getReturnValue();
                console.log(oRes);
                //component.set('v.redemptionWrpobj', idx);
                //component.set('v.redemptionWrpobjwrp', oRes);
                
            }
        })
        $A.enqueueAction(action);
        $A.get('e.force:refreshView').fire();
    },
    closeModel: function(component, event, helper) {
        
        // Set isModalOpen attribute to false  
        component.set("v.isModalOpen", false);
    },
    handleRedemption : function(component, event, helper) {
        var timeshareid = component.get("v.redemptionWrpobjwrp.selectedTimeShareId");
        var redrecord = component.get("v.redemptionWrpobj");
        
        event.preventDefault(); //Prevent default submit
        var eventFields = event.getParam("fields"); //get the fields
       // alert(timeshareid);
        eventFields["Property__c"] = timeshareid; //Add Description field Value
        
      //  alert('eventFields'+eventFields.Check_In_Date__c);
      //  alert('eventFields'+eventFields.Status__c);
        
        component.find('recordViewForm').submit(eventFields);
        component.set("v.isModalOpen", false);
        
        var oppId = component.get("v.recordId");
        
        if(eventFields.Check_In_Date__c != null && eventFields.Status__c == 'Reservation Pending' ){
            
            var action = component.get("c.casecreation");
            action.setParams({
                recordId : redrecord
            });
            action.setCallback(this, function(response){
                var STATE = response.getState();
                if(STATE === "SUCCESS") {
                    var oRes = response.getReturnValue();
                    console.log(oRes);
                    
                }
               
            })
            $A.enqueueAction(action);
        }
        $A.get('e.force:refreshView').fire();     
    },
    handleChange : function(component, event, helper){
        helper.checkProductName(component, event);
    },
    handleStatusChange : function(component, event, helper){
        var status = event.getParam("value");
        const profileName = component.get('v.CurrentUser')['Profile'].Name;
        console.log('>>>>status>>>>'+status);
        console.log('>>>>profileName>>>>'+profileName);
        if((profileName != 'Inventory Agent' && profileName != 'Membership Upgrade Manager') && status == 'Reservation Confirmed'){
            component.set("v.statusMessage", true);
            component.set("v.disableButton", true);
        }
        else if(!component.get("v.showMessage")){
            component.set("v.statusMessage", false); 
            component.set("v.disableButton", false);
        }
        else{
           component.set("v.statusMessage", false);      
        }
    }
})