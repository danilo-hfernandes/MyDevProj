({
    CSV2JSON: function (component,csv) {
        var arr = []; 
        arr =  csv.split('\n');
        arr.pop();
        var jsonObj = [];
        var headers = arr[0].split(',');
        //alert('--headers--'+headers);
        for(var i = 1; i < arr.length; i++) {
            var data = arr[i].split(',');
            var obj = {};
            for(var j = 0; j < data.length; j++) {
                if(data[j].trim() !== 'undefined' && data[j].trim() !== '' && data[j].trim() !== null){
                    console.log('data === '+JSON.stringify(data[j].trim()));
                   obj[headers[j].trim()] = data[j].trim();
                console.log('obj headers = ' + obj[headers[j].trim()]);
                }
            }
            //alert('obj.DateCreated'+obj.DateCreated);
            //alert('obj.DateCreated'+obj.DateCreated);
            if(obj.DateCreated || obj.CancelDate || obj.ReservationStatus || obj.FirstNight || obj.LastNight && obj.SiteName 
               || obj.RoomType || obj.ExternalConfirmationNumber || obj.BillingItem || obj.Invoiceamount){
                //console.log('obj=== '+obj);
                jsonObj.push(obj);
            }
        }
        //alert('--jsonObj--'+jsonObj);
        var json = JSON.stringify(jsonObj);
        console.log('json = '+ json);
        //alert('json = '+ json);
        return json;        
    },
    
    showToast : function(title,message,type) {
        console.log('title---'+title);
        console.log('message---'+message);
        console.log('type---'+type);
        console.log('calling toast method---');
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: title,
            message: message,
            type: type
        });
        toastEvent.fire();
        //window.setTimeout(function(){location.reload()},2000);
    },
    
    CreateInvoice : function (component,jsonstr){
        console.log('Create records=== ');
        //alert('Create records=== called'+jsonstr);
        var action = component.get('c.insertInvoice');
        action.setParams({
            strfromle : jsonstr
        });
        action.setCallback(this, function(response) {
            $A.get('e.force:refreshView').fire();
            window.setTimeout(function(){location.reload()},3000);
            var state = response.getState();
            console.log('state===  '+state);
            //alert('state===  '+state);
            if (state === "SUCCESS") {  
                //alert('SUCCESS=== ');
                var result=response.getReturnValue();
                const self = this;
                component.set("v.spinner", false); 
                component.set("v.showInfo", false); 
                if(result.startsWith("Total number of records created are")){
                   self.showToast('Success!',result,'success');
                }else{
                    self.showToast('Error!',result,'error');
                }
            }else if (state === "ERROR") {
                var errors = response.getError();
                //alert('Error=== '+errors[0]['exceptionType']);
                const self = this;
                component.set("v.spinner", false);
                component.set("v.showInfo", false); 
                if(errors[0]['exceptionType'] && errors[0]['message']){
                    self.showToast(errors[0]['exceptionType'],errors[0]['message'],'error'); 
                }else{
                    self.showToast('Error!','System Limits must be exceeded.','error');
                }
            }
        }); 
        $A.enqueueAction(action);    
    },
})