({
    doInit: function(component, event, helper) {
        helper.doInitHelper(component, event);
    },
    addProductToTimeshare : function(component,event,helper){
        component.set("v.isLoaded",false);
        var AccId = component.get("v.recordId");
        var action = component.get("c.AllActiveProductList");
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                var oRes = response.getReturnValue();
                if(oRes.length > 0){
                    component.set('v.productList', oRes);
                    component.set("v.addProductView" , true);
                }else{
                    alert('Product not found');
                } 
            }
            else{
                this.fireToastMessage(state,'error');                
            }
            component.set("v.isLoaded",true);
        });
        $A.enqueueAction(action);
    },
    
    seletedProduct : function(component,event,helper){
        component.set("v.isLoaded",false);
        var ctarget = event.currentTarget;
        var id_str = ctarget.dataset.value;
        component.set("v.selectedProduct", id_str);
        component.set("v.isLoaded",true);
        $A.get('e.force:refreshView').fire();  
    },
    
    hideproductView : function(component,event,helper){
        $A.get('e.force:refreshView').fire();    
        $A.get("e.force:closeQuickAction").fire()  
    },
    saveproductLine : function(component,event,helper){
        component.set("v.isLoaded",false);
        var productId = component.get("v.selectedProduct");
        
        if(productId == 'null'){
            helper.fireToastMessage('Please select product','error');
            component.set("v.isLoaded",true);
        }else{
            var AccId = component.get("v.recordId");
            var wrapperlist = component.get("v.productList");
            var action = component.get("c.saveProductLineItem");
            //Setting the Apex Parameter
            action.setParams({ 
                proWrapperlist : wrapperlist,
                AccId : AccId,
                productId : productId
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS"){
                    component.set("v.addProductView" , false);
                    helper.fireToastMessage('Opportunity created, Please refresh the opportunity if product is not yet visible','success');
                    $A.get('e.force:refreshView').fire();  
                    component.set("v.isLoaded",true);
                    $A.get("e.force:closeQuickAction").fire()   
                }
                else{
                    var errors = response.getError();  
                    helper.fireToastMessage(errors[0].message,'error');  
                    component.set("v.isLoaded",true);
                }
                
            });
            $A.enqueueAction(action);
        }
    }
})