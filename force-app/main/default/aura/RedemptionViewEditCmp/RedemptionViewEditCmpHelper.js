({ 
    /* doInitHelper funcation to fetch all records, and set attributes value on component load */
    doInitHelper : function(component,event){ 
        //component.set('v.recordId', '0063t000013HQdPAAW');
        var oppId = component.get("v.recordId");
        //var oppId = component.get("0063t000013HQdPAAW");
        
        var action = component.get("c.RedemptionList");
        action.setParams({
            recordId : oppId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                console.log('Redumption records === '+JSON.stringify(response.getReturnValue()));
                
                var oRes = response.getReturnValue();
                if(oRes.length > 0){+
                    component.set('v.rdmList', oRes);
                    if(oRes[0].Add_New_Button_Access__c){
                        component.set('v.addButtonIsVisible', true);
                    }
                    
                }else{
                    // if there is no records then display message
                }  
            }
        });
        $A.enqueueAction(action);  
    },
    doValidateColumns : function(component, event){
        var oppId = component.get("v.recordId");
        var action = component.get("c.showProductName");
        action.setParams({
            recordId : oppId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                var oRes = response.getReturnValue();
                console.log('>>showProductName>>'+oRes);
                component.set('v.showProdColumn', oRes); 
            }
        });
        $A.enqueueAction(action); 
    },
    checkProductName : function(component, event){
        var oppProduct = component.find("OpportunityProduct").get("v.value");
        console.log('>>>>oppProduct>>>>'+oppProduct);
        var action = component.get("c.validateProductName");
        action.setParams({
            recordId : oppProduct
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                var oRes = response.getReturnValue();
                console.log('>>>>>>',oRes);
                if(!oRes){
                    var redAmount = event.getParam("value");
        			console.log('>>>>redAmount>>>>'+redAmount);
                    if(redAmount > 1000){
                        component.set("v.showMessage", true);
                        component.set("v.disableButton", true);
                        
                    }
                    else if(!component.get("v.statusMessage")){
                        component.set("v.showMessage", false); 
                        component.set("v.disableButton", false);
                    }
                    else{
                        component.set("v.showMessage", false);     
                   } 
                }  
            }
        });
        $A.enqueueAction(action);
    }
})