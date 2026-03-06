({
    doInit : function(component, event, helper) {
    	 helper.getProductValues(component, event, helper);
    },
    productList : function(component, event, helper) {
    	 helper.picklistValue(component, event, helper);
    },
    LocationList : function(cmp, event, helper){
        helper.getAllLocationList(cmp, event, helper);
    },
    allSectionName : function(cmp, event, helper){
        helper.getAllSectionName(cmp, event, helper);
    },
    roomSizeOptions :  function(cmp, event, helper){
        helper.getAllRoomSize(cmp, event, helper);
    },
    buttonClickCall : function(component,event,helper){
        component.set("v.buttonClick", false);
        $A.get('e.force:refreshView').fire();
    },
    isRefreshed : function(component,event,helper){
        //location.reload();
        
        //helper.checktheBooking(component,event,helper);
    },
    CloseMXVoucherProduct : function(component,event,helper){
        
        var action = component.get( "c.closeMethod" );  
        action.setCallback(this, function(response){  
            var state = response.getState();  
            if (state === "SUCCESS") { 
                component.set("v.buttonClick", true);
                helper.getProductValues(component, event, helper);
                $A.get('e.force:refreshView').fire();
                
            }  
        });  
        $A.enqueueAction(action);  
    },
    
    
    CreateOppProduct : function(cmp,event,helper){
        var varselectedMXId = cmp.get("v.MXvoucherobject"); 
        var inputprice = cmp.get("v.inputvalue");
        var varoppId = cmp.get("v.recordId");
        var  action;
        if(varselectedMXId != 'null'){
            action = cmp.get("c.CreateProduct");
            action.setParams({ 
                selectedMXId : varselectedMXId,
                oppId : varoppId,
                inputPrice : cmp.get("v.inputvalue"),
                productName  : cmp.get("v.selectedProductName"),
                
            });
            action.setCallback(this, function(response){  
                var state = response.getState();  
                 if (state === "SUCCESS") { 
                      cmp.set("v.buttonClick", true);
                     helper.getProductValues(cmp, event, helper);
                 	$A.get('e.force:refreshView').fire();
                }  
                else{
                    alert('ERROR');  
                }
            });  
            $A.enqueueAction(action);  
        }else{
            alert('please select one of the product');
        }
    },
    
    selectedMXVoucherAvailability : function(component,event,helper){
        var ctarget = event.currentTarget;
        var id_str = ctarget.dataset.value;
       // component.set("v.selectedInvId", id_str);
     //  alert('--id_str--'+id_str);
        component.set("v.MXvoucherobject", id_str);
		component.set('v.isSaved',true);
		alert('--MXvoucherobject'+MXvoucherobject);
        //$A.get('e.force:refreshView').fire();
    },
    
    inputvaluechanged : function(component,event,helper){        
        var ctarget = event.currentTarget;
        var id_str = ctarget.dataset.value;    
        var price = ctarget.dataset.label;
        var integer = parseFloat(id_str);
        var integer2 = parseFloat(price);
        var inputCmp = component.find("inputCmp");
        component.set("v.inputvalue", id_str);
        if (integer < integer2) {
            inputCmp.set('v.disabled',true);
            component.set('v.MessageNote', "Selling Price should be greater than Minimum Price");
        } else {
            inputCmp.set('v.disabled',false);
            component.set('v.MessageNote', "");
        }
    },
    
})