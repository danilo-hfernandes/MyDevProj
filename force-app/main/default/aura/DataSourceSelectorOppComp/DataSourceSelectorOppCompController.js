({

    doInit : function(component, event, helper) {
 		
        console.log('[DEBUG] doInit running...');
        
        // Force refresh to prevent caching issues
        $A.get('e.force:refreshView').fire(); 
        
        // Set picklist options
        let options = [
            { label: 'Email', value: 'Email' },
            { label: 'SMS Text Message', value: 'SMS Text Message' },
            { label: 'AI Calls', value: 'AI' }  //<!-- ✅ AI Dialer -->
        ];
        
        component.set("v.sourceOptions", options);
        console.log('[DEBUG] Picklist Options Set: ', JSON.stringify(options));
        console.log('[DEBUG] component.get("v.sourceOptions"): ', JSON.stringify(component.get("v.sourceOptions")));
    },

    handleSourceChange : function(component, event, helper) {
        let selectedSource = event.getSource().get("v.value");
        component.set("v.selectedSource", selectedSource);
        console.log('[DEBUG] User selected: ', selectedSource);
        
    }
})