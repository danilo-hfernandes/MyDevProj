({
    doInit: function (component, event, helper) {
        helper.fetchAICallEvents(component);
    },
    
    /*    handlePlay: function (component, event, helper) {
        const url = event.getSource().get("v.value");
        if (url) {
            window.open(url, "_blank");
        }
    },
*/
    toggleRow: function(component, event, helper) {
        let clickedId = event.getSource().get("v.value");
        let currentId = component.get("v.activeRowId");
        console.log('Clicked:', clickedId, '| Current Active:', currentId);
        // Toggle logic
        if (currentId === clickedId) {
            component.set("v.activeRowId", null);  // Collapse if already open
        } else {
            component.set("v.activeRowId", clickedId);  // Open new row
        }
   },
    toggleTranscript: function(component, event, helper) {
        let clickedId = event.getSource().get("v.value");
        let currentId = component.get("v.transcriptVisibleRowId");
        
        // Toggle logic: hide if same row, show if different
        component.set("v.transcriptVisibleRowId", clickedId === currentId ? null : clickedId);
    },
    
    handleDownload: function (component, event, helper) {
        const url = event.getSource().get("v.value");
        if (url) {
            const link = document.createElement("a");
            link.href = url;
            link.download = '';
            document.body.appendChild(link);
            link.click();
            document.body.removeChild(link);
        }
    }
});