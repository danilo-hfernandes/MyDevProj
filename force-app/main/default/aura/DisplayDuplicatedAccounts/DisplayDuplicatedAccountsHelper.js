({
    getAccountList: function(component) {
        var action = component.get('c.GetAccounts');
        action.setParams({ accountId : component.get('v.recordId') });
        // Set up the callback
        var self = this;

        action.setCallback(this, function(actionResult) {
            var state = actionResult.getState();
            var map = actionResult.getReturnValue();            
            var errorLog = Object.keys(map)[0];
            var records = Object.values(map)[0];
            
            /*console.log('errorLog : '+errorLog);
            console.log('records : '+records);*/
            
            if(records != null && records != '' && records != undefined)
            {
                records.forEach(function(record){
                    record.linkName = '/'+record.Id;
                });
                component.set('v.lstAccount', records);
                component.set('v.ShowComponent',true);
            }
            else
            {
                component.set('v.ShowComponent',false);
            }
            /*if(errorLog == 'We found no potential duplicated accounts.')
            {
                component.set('v.errorMsg',errorLog);
                component.set('v.ShowSpinner',false);
                component.set('v.ShowComponent2',true);
            }
            else
            {
                component.set('v.errorMsg',errorLog);
                component.set('v.ShowSpinner',false);
                component.set('v.ShowComponent2',true);
            }*/
            component.set('v.errorMsg',errorLog);            
            component.set('v.ShowComponent2',true);
            component.set('v.ShowSpinner',false);
        });
        $A.enqueueAction(action);
    }
})