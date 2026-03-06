({
    /* doInitHelper funcation to fetch all records, and set attributes value on component load */
    doInitHelper : function(component,event){ 
        console.log('4==JSHELPER');
        var oppId = component.get("v.recordId");
        var action = component.get("c.timeshareWrapper");
        action.setParams({
            recordId : oppId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                console.log('13==Success');
                var oRes = response.getReturnValue();
                console.log('15=='+oRes);
                console.log('16='+oRes.length);
                console.log('21='+JSON.stringify(oRes));
                oRes.forEach(record => component.set('v.accountId', record.accountId));
                oRes.forEach(record => component.set('v.isMTRCProductExist', record.isMTRCProductExist));
                
                if(oRes.length > 0){
                    console.log('21='+oRes.length);
                    if(oRes.length == 10){
                        component.set('v.TimeshareRecord10', true);   
                    }else{
                        component.set('v.TimeshareRecord10', false); 
                    }
                    component.set('v.listOfAllTimeshare', oRes);
                }else{
                    // if there is no records then display message
                    component.set("v.bNoRecordsFound" , true);
                } 
            }
            else{
                this.fireToastMessage(state,'error');                
            }
        });
        $A.enqueueAction(action);  
    },
    fireToastMessage : function(message,type){
        var showToast = $A.get("e.force:showToast");  
        showToast.setParams({ 
            'duration': 5000,
            'title' : 'Message', 
            'message' : message,
            'type': type
        }); 
        showToast.fire(); 
        
    }
})