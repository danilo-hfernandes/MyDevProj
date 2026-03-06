({
    init: function(component, event, helper) {
        // Call the Apex controller method to retrieve contacts
        var action = component.get("c.getContacts");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.contacts", response.getReturnValue());
            } else {
                console.error("Error fetching contacts");
            }
        });
        $A.enqueueAction(action);
    },

    exportToCSV: function(component, event, helper) {
        // Get the contacts data
        var contacts = component.get("v.contacts");

        // Create a CSV string
        var csvString = helper.convertToCSV(contacts);

        // Create a Blob object and initiate the download
        var blob = new Blob([csvString], { type: 'text/csv;charset=utf-8;' });
        var fileName = 'contacts.csv';
        var link = document.createElement("a");

        if (link.download !== undefined) {
            // Browsers that support HTML5 download attribute
            var url = URL.createObjectURL(blob);
            link.setAttribute("href", url);
            link.setAttribute("download", fileName);
            document.body.appendChild(link);
            link.click();
            document.body.removeChild(link);
        } else {
            // Fallback for older browsers
            alert("Your browser does not support HTML5 download. Please try a different browser.");
        }
    },
    
    convertintocsvfile : function(component, event, helper) {
        debugger;
        var getRecord = component.get("v.contacts");
        var formatcsvfile  = helper.convertintocsvfileHelper(component, getRecord);
        if (formatcsvfile == null){
            return;
        }
        debugger;
        var hiddenElement = document.createElement('a');
        hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(formatcsvfile);
        hiddenElement.target = '_self';
        hiddenElement.download = 'ContactList.csv';
        //hiddenElement.download = component.get("v.fileName");
        document.body.appendChild(hiddenElement); //Required for FireFox browser
        hiddenElement.click(); // using click() js function to download csv file
    }

})