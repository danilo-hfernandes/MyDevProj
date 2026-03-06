({
    handleSiteChangeHelper: function(component, event) {
        // Retrieve the selected site name
        var selectedSiteName = component.get("v.siteNameMarival");
        var allInventories = component.get("v.inventoryRecords");
        
        console.log('selectedSiteName = '+selectedSiteName);
        // Initialize the capacity value based on the selected site name
        var capacityValue = '';
        var roomTypeValue = '';
        for (var i = 0; i < allInventories.length; i++) {
            if (allInventories[i].Id === selectedSiteName) {
                // Perform your desired action here
                console.log("Match found: ", allInventories[i]);
                // Example: set an attribute with the matched inventory record
                capacityValue = allInventories[i].Capacity__c;
                roomTypeValue = allInventories[i].Unit_Type__c
                //plaza = allInventories[i].Plaza__c;
                break; // Exit the loop once a match is found
            }
        }
        // Update the capacity attribute in the component
        component.set("v.capacityMarival", capacityValue);
        component.set("v.roomTypeMarival", roomTypeValue);

        // Ensure the callback for getExtraNightsTotalHelper is called only after attributes are set
        helper.getExtraNightsTotalHelper(component, event, helper);
        
        
    },
    handlePlazaChangeHelper : function(component, event) {
        var supplierType = component.get("v.supplierMarival");
        var selectedPlaza = component.get("v.plazaMarival");
        var action = component.get("c.getInventoryRecords");
        action.setParams({
            supplier: supplierType,
            plaza : selectedPlaza
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var records = response.getReturnValue();
                component.set("v.inventoryRecords", records);
                var options = [];
                for (var i = 0; i < records.length; i++) {
                    options.push({
                        "label": records[i].Site_Name__c,
                        "value": records[i].Id
                    });
                }
                component.set("v.resortOptions", options);
            } else {
                console.error("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);
    },
    
    saveReservationHelper: function(component) {
        component.set("v.showSpinMarival", true);        
        var action = component.get("c.saveOpportunityDetails");
        var recordId = component.get("v.recordId");
        var siteName = component.get("v.siteNameMarival");
        var roomType = component.get("v.roomTypeMarival");
        var checkIn = component.get("v.checkInMarival");
        var checkOut = component.get("v.checkOutMarival");
        var capacity = component.get("v.capacityMarival");
        var adults = component.get("v.adultsMarival");
        var children = component.get("v.childrenMarival");
        var sup = component.get("v.supplierMarival");
        var invs = component.get("v.inventoryRecords");
        var extraNights = component.get("v.extraNights");   //312
        
        /*console.log('adults = '+adults);*/
        console.log('roomType = '+roomType);
        
        
        action.setParams({
            recordId: recordId,
            inventoryId: siteName,  //?????????
            roomType: roomType,
            checkIn: checkIn,
            checkOut: checkOut,
            capacity: capacity,
            adults: adults,
            children: children,
            supplier: sup,
            extraNights: extraNights 
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                // Handle success, e.g., close the modal and show a success toast
                component.set("v.showSpinMarival", false);
                component.set("v.isOpenMarival", false);
                $A.get('e.force:refreshView').fire();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "Reservation has been successfully saved.",
                    "type": "success"
                });
                toastEvent.fire();                
            } else {
                // Handle errors, e.g., show an error toast
                var errors = response.getError();
                var message = 'Unknown error'; // Fallback error message
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    message = errors[0].message;
                }
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error",
                    "message": "Error in saving reservation: " + message,
                    "type": "error"
                });
                toastEvent.fire();
                component.set("v.showSpinMarival", false);
                $A.get('e.force:refreshView').fire();
            }
        });
        
        $A.enqueueAction(action);
    },
    
     handleCheckInChangeHelper: function(component, event, helper) {   //312
       
        var checkInDate = component.get("v.checkInMarival");
        var numberOfNights = component.get("v.numberOfNights");
        var extraNights = component.get("v.extraNights");

        
        var validCheckInDate = new Date(checkInDate);
        if (isNaN(validCheckInDate.getTime())) {
            console.error("Invalid date:", checkInDate);
        
            return;
        }
       
        try {
            var toDate = new Date(validCheckInDate.getTime() + ((parseInt(numberOfNights) + parseInt(extraNights)) * 24 * 60 * 60 * 1000));
        } catch (e) {
            console.error("Date calculation error:", e);
        }
        
        var toDateFormatted = toDate.toISOString().split('T')[0];
		component.set("v.checkOutMarival", toDateFormatted);

        //component.find("checkOutDateInput").set("v.value", component.get("v.checkOutMarival"));

    },
    
    initializeMinCheckInDate: function(component) {
        // Get today's date in yyyy-MM-dd format
        var today = new Date();
        var todayFormatted = today.toISOString().split('T')[0];
        
        // Set the attribute with today's date
        component.set("v.minCheckInDate", todayFormatted);
    },

     updateDateOptions: function(component) { //312
        const fromDate = component.get("v.checkInMarival");
        //const numberOfNights = component.get("v.numberOfNights");
        const dateOptions = [];

       console.log('updateDateOptions entered>>>');
         
        if (fromDate ) {
            const startDate = new Date(fromDate);

            for (let i = 1; i < 8; i++) {

                const nextDate = new Date(startDate);
                nextDate.setDate(startDate.getDate() + i); // Add i days
                const formattedDate = nextDate.toLocaleDateString('en-US', { year: 'numeric', month: 'short', day: 'numeric' }); // Format to "MMM D, YYYY"
                nextDate.setHours(0, 0, 0, 0); // Set to midnight
                dateOptions.push({ label: formattedDate, value: nextDate.toISOString().split('T')[0] });
            }
        }

        component.set("v.dateOptions", dateOptions);
         
    },
    
    checktheBooking : function(cmp,event,helper) {  //312
         cmp.set("v.isLoaded",false);
        var varoppId = cmp.get("v.recordId");
        //var varoppId = '0067g00000G3DPMAA3';
         var action;
        if(varoppId != null){
            action = cmp.get("c.checkbookingifExist");
             action.setParams({ 
                 oppId : varoppId
            });
        }else{
            alert('Please select Inventory Availability');
        }
         action.setCallback(this, function(response) {
            
            var result = response.getReturnValue();
            var state = response.getState();
            if (state === "SUCCESS") {
                cmp.set('v.oppRecord', result);
            }
            else{
                alert(response.getReturnValue());
            }
            cmp.set("v.isLoaded",true);
        });
        $A.enqueueAction(action);
    },
    
    
    getExtraNightsTotalHelper: function(component, event, helper) {
        
        component.set("v.showSpinMarival", true);        
        var action = component.get("c.getExtraNight");

        var plaza = component.get("v.plazaMarival");
        var supplier = component.get("v.supplierMarival");
        var siteName = component.get("v.siteNameMarival");
        var roomType = component.get("v.roomTypeMarival");
        var capacity = component.get("v.capacityMarival");
        var extraNights = component.get("v.extraNights");   
        
        action.setParams({
            sitename: siteName            
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            var result = response.getReturnValue();
            var formresult = result * extraNights;
			var formattedResult = `$${formresult}`;  // Format with $ and 2 decimal places

            formresult = "$" + formresult 
            component.set("v.extraNightsTotalPrice", formattedResult);
            
            if (state === "SUCCESS") {
                // Handle success
				component.set("v.showSpinMarival", false);        
            } else {
                // Handle errors, e.g., show an error toast
                var errors = response.getError();
                var message = 'Unknown error'; // Fallback error message
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    message = errors[0].message;
					console.log('error message = '+message);
                }
                component.set("v.showSpinMarival", false);
            }
        });
        
        $A.enqueueAction(action);
      
    }

})