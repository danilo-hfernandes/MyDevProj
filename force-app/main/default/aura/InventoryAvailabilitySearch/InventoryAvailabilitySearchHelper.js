({
    //1
    filterForAdvancedSearch : function(cmp, event, helper){
        cmp.set("v.isLoaded",false);
        var fromDate = cmp.get('v.fromDate');
        var toDate = cmp.get('v.toDate');
        var nights = cmp.get('v.numberOfNights');
        var action;
        if(fromDate == null && toDate == null){
            alert('Select From Date or To Date to get the letest Availability');
            cmp.set("v.isLoaded",true);
        }else{
            if(fromDate != null && toDate != null){
                action = cmp.get("c.AvailabityByDate");
                action.setParams({ 
                    fromDatevar : fromDate,
                    toDatevar : toDate,
                    nightsInt : nights
                });
            }else if(fromDate != null && toDate == null){
                action = cmp.get("c.AvailabityByDate");
                action.setParams({ 
                    fromDatevar : fromDate,
                    toDatevar : null,
                    nightsInt : nights
                });
            }else if(fromDate == null && toDate != null){
                action = cmp.get("c.AvailabityByDate");
                action.setParams({ 
                    fromDatevar : null,
                    toDatevar : toDate,
                    nightsInt : nights
                });
            }
            action.setCallback(this, function(response) {
                var result = response.getReturnValue();
                var state = response.getState();
                if (state === "SUCCESS") {
                    cmp.set('v.InventoryAvailabilityList', result.InventoryAvailability);
                    cmp.set('v.PlazaOption', result.locationOption);
                    cmp.set('v.MessageNote', result.MessageNote);
                    cmp.set('v.ProgramOption', result.programType);
                    cmp.set('v.selectPlaza', '--None--');
                    cmp.set("v.selectResort",'--None--');
                    cmp.set("v.selectRoomType",'--None--');
                    cmp.set('v.mapMinimumNights', result.mapforMinNights);
                    this.processInventoryData(cmp);
                }
                else{
                    alert(response.getReturnValue());
                }
                cmp.set("v.isLoaded",true);
            });
            $A.enqueueAction(action);
        }
        
    },
    
    processInventoryData: function (component) {
        console.log('>>>>Inside Process');
        let mapMinimumNights = component.get("v.mapMinimumNights");
        let inventory = component.get("v.InventoryAvailabilityList");
        
        // Loop through inventory and check if the key exists in the map
        inventory.forEach(function (item) {
            console.log('>>>>Inside item'+item);
            
            let key = String(item.Unique_key_for_without_Checkin_Date__c);
            console.log('>>>>Inside item'+key);
            // Check if key exists in mapMinimumNights
            if (mapMinimumNights && key in mapMinimumNights) {
                item.minimumNights = mapMinimumNights[key];
            } else {
                // Handle missing key (e.g., set a default or error message)
                item.minimumNights = "N/A";
            }
        });
        
        // Update inventory data with the new field
        component.set("v.InventoryAvailabilityList", inventory);
    },
    //2
    getAllRoomList : function(cmp, event, helper){
        var nights = cmp.get('v.numberOfNights');
        cmp.set("v.isLoaded",false);
        var selectProgram = cmp.get("v.selectProgram"); 
        var action;
        if(cmp.get("v.selectPlaza") != '--None--'){
            action = cmp.get("c.getAllResort");
            action.setParams(
                { 
                    programName: cmp.get("v.selectProgram"),
                    PlazzaName : cmp.get("v.selectPlaza"),
                    fromDateValue : cmp.get("v.fromDate"),
                    toDateValue : cmp.get("v.toDate"),
                    nightsInt : nights,
                    extraNightsInt : 0 //263
                }
            );
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    cmp.set("v.resortOption",result.resortOption);
                    cmp.set('v.InventoryAvailabilityList', result.InventoryAvailability);
                    cmp.set('v.MessageNote', result.MessageNote);
                    
                    cmp.set("v.selectResort",'--None--');
                    cmp.set("v.selectRoomType",'--None--');
                    cmp.set('v.mapMinimumNights', result.mapforMinNights);
                    this.processInventoryData(cmp);
                }
                else{
                    alert(response.getReturnValue());
                }
                cmp.set("v.isLoaded",true);
                
            });
            $A.enqueueAction(action);
            
        }else{
            this.filterForAdvancedSearch(cmp, event, helper);
        }                
        
    },
    //3
    getallRoomType : function(cmp,event,helper) {
        cmp.set("v.isLoaded",false);
        var selectPlazaValue = cmp.get('v.selectPlaza');
        var selectResortValue = cmp.get('v.selectResort');
        var selectProgram = cmp.get("v.selectProgram");
        var nights = cmp.get('v.numberOfNights');
        var action;
        if(cmp.get("v.selectResort") != '--None--'){
            action = cmp.get("c.roomType");
            action.setParams({ 
                programName: cmp.get("v.selectProgram"),
                PlazzaName :cmp.get("v.selectPlaza"),
                resoertName : cmp.get("v.selectResort"),
                fromDateValue : cmp.get("v.fromDate"),
                toDateValue : cmp.get("v.toDate"),
                nightsInt : nights,
                extraNightsInt : 0 //263
                
            });
        }else{
            action = cmp.get("c.getAllResort");
            action.setParams({ 
                programName: cmp.get("v.selectProgram"),
                PlazzaName : cmp.get("v.selectPlaza"),
                fromDateValue : cmp.get("v.fromDate"),
                toDateValue : cmp.get("v.toDate"),
                nightsInt : nights,
                extraNightsInt : 0 //263
            });
        }
        action.setCallback(this, function(response) {
            var result = response.getReturnValue();
            var state = response.getState();
            if (state === "SUCCESS") {
                cmp.set("v.roomTypeOption",result.roomType);
                cmp.set('v.MessageNote', result.MessageNote);
                
                cmp.set("v.selectRoomType",'--None--');
                cmp.set('v.InventoryAvailabilityList', result.InventoryAvailability);
                cmp.set('v.mapMinimumNights', result.mapforMinNights);
                this.processInventoryData(cmp);
                
            }
            else{
                alert(response.getReturnValue());
            }
            cmp.set("v.isLoaded",true);
        });
        $A.enqueueAction(action);
        
    },
    //4
    getInventoryAvailability : function(cmp,event,helper) {
        cmp.set("v.isLoaded",false);
        var selectProgram = cmp.get("v.selectProgram"); 3
        var nights = cmp.get('v.numberOfNights');
        var action;
        if(cmp.get("v.selectRoomType") != '--None--'){
            action = cmp.get("c.InventoryAvailabilityBasedOnroomType");
            action.setParams({ 
                programName: cmp.get("v.selectProgram"),
                resoertName : cmp.get("v.selectResort"),
                PlazzaName : cmp.get("v.selectPlaza"),
                roomType : cmp.get("v.selectRoomType"),
                fromDateValue : cmp.get("v.fromDate"),
                toDateValue : cmp.get("v.toDate"),
                nightsInt : nights,
                extraNightsInt : 0 //263
            });
        }else{
            action = cmp.get("c.roomType");
            action.setParams({ 
                programName: cmp.get("v.selectProgram"),
                PlazzaName :cmp.get("v.selectPlaza"),
                resoertName : cmp.get("v.selectResort"),
                fromDateValue : cmp.get("v.fromDate"),
                toDateValue : cmp.get("v.toDate"),
                nightsInt : nights,
                extraNightsInt : 0 //263
            });
        }
        action.setCallback(this, function(response) {
            var result = response.getReturnValue();
            var state = response.getState();
            if (state === "SUCCESS") {
                cmp.set('v.InventoryAvailabilityList', result.InventoryAvailability);
                cmp.set('v.MessageNote', result.MessageNote);
                cmp.set('v.mapMinimumNights', result.mapforMinNights);
                this.processInventoryData(cmp);
            }
            else{
                alert(response.getReturnValue());
            }
            cmp.set("v.isLoaded",true);
        });
        $A.enqueueAction(action);
        
    },
    //2
    getAllprogramType : function(cmp, event, helper){
        cmp.set("v.isLoaded",false);
        var action;
        var nights = cmp.get('v.numberOfNights');
        var selectProgram = cmp.get("v.selectProgram"); 
        if(cmp.get("v.selectProgram") != '--None--'){
            
            action = cmp.get("c.getAllProgram");
            action.setParams(
                { 
                    programName: cmp.get("v.selectProgram"),
                    resoertName : cmp.get("v.selectResort"),
                    PlazzaName : cmp.get("v.selectPlaza"),
                    roomType : cmp.get("v.selectRoomType"),
                    fromDateValue : cmp.get("v.fromDate"),
                    toDateValue : cmp.get("v.toDate"),
                    nightsInt : nights,
                    extraNightsInt : 0 //263
                }
            );
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    cmp.set("v.resortOption",result.resortOption);
                    cmp.set('v.InventoryAvailabilityList', result.InventoryAvailability);
                    cmp.set('v.MessageNote', result.MessageNote);
                    cmp.set('v.mapMinimumNights', result.mapforMinNights);
                    this.processInventoryData(cmp);
                    
                }
                else{
                    alert('206');
                    alert(response.getReturnValue());
                }
                cmp.set("v.isLoaded",true);
                
            });
            $A.enqueueAction(action);
            
        }else{
            this.filterForAdvancedSearch(cmp, event, helper);
        }                
        
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
        $A.get("e.force:closeQuickAction").fire();
        $A.get('e.force:refreshView').fire();
        
    },
    updateDateOptions: function(component) {
        const fromDate = component.get("v.fromDate");
        const numberOfNights = component.get("v.numberOfNights");
        const dateOptions = [];
        
        if (fromDate && numberOfNights) {
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
    }    
})