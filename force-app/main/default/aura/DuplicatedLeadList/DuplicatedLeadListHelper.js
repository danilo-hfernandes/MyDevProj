({
    getLeadList: function(component) {

        var action = component.get('c.GetLeads');
        action.setParams({
            leadId : component.get('v.recordId')
        });

        action.setCallback(this, function(response) {

            var state = response.getState();
            var map = response.getReturnValue();

            var message = Object.keys(map)[0];
            var records = Object.values(map)[0];

            if(records != null && records.length > 0)
            {
                records.forEach(function(record){
                    record.linkName = '/' + record.Id;
                    record.OwnerName = record.Owner ? record.Owner.Name : '';
                });

                component.set('v.lstLead', records);
                component.set('v.ShowComponent', true);
            }
            else
            {
                component.set('v.ShowComponent', false);
            }

            component.set('v.errorMsg', message);
            component.set('v.ShowComponent2', true);
            component.set('v.ShowSpinner', false);
        });

        $A.enqueueAction(action);
    }
})