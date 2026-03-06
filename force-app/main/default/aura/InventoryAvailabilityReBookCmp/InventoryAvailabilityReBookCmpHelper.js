({
    //1
    filterForAdvancedSearch : function(cmp, event, helper){
        cmp.set("v.isLoaded",false);
        var varoppId = cmp.get("v.recordId");
        var fromDate = cmp.get('v.fromDate');
        var toDate = cmp.get('v.toDate');
        var nights = cmp.get('v.numberOfNights');
        var extranights = cmp.get('v.extraNights'); //263
        var action;
        if(fromDate == null && toDate == null){
            alert('Select From Date or To Date to get the latest Availability');
        }else{
            if(fromDate != null && toDate != null){
                action = cmp.get("c.AvailabityByDate");
                action.setParams({ 
                    fromDatevar : fromDate,
                    toDatevar : toDate,
                    oppId : varoppId,
                    nightsInt : nights,
                    extraNightsInt : extranights  //263
                });
            }else if(fromDate != null && toDate == null){
                action = cmp.get("c.AvailabityByDate");
                action.setParams({ 
                    fromDatevar : fromDate,
                    toDatevar : null,
                    oppId : varoppId,
                    nightsInt : nights,
                    extraNightsInt : extranights  //263 
                });
            }else if(fromDate == null && toDate != null){
                action = cmp.get("c.AvailabityByDate");
                action.setParams({ 
                    fromDatevar : null,
                    toDatevar : toDate,
                    oppId : varoppId,
                    nightsInt : nights,
                    extraNightsInt : extranights  //263 
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
                    cmp.set("v.showSpin", false);
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
        cmp.set("v.isLoaded",false);
        var selectProgram = cmp.get("v.selectProgram"); 
        var action;
        var nights = cmp.get('v.numberOfNights');
		var extranights = cmp.get('v.extraNights'); //263
        var varoppId = cmp.get("v.recordId");
        if(cmp.get("v.selectPlaza") != '--None--'){
            action = cmp.get("c.getAllResort");
            action.setParams(
                { 
                    programName: cmp.get("v.selectProgram"),
                    PlazzaName : cmp.get("v.selectPlaza"),
                    fromDateValue : cmp.get("v.fromDate"),
                    toDateValue : cmp.get("v.toDate"),
                    oppId : varoppId,
                    nightsInt : nights,
                    extraNightsInt : extranights  //263
                    
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
                    cmp.set("v.showSpin", false);
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
        var selectProgram = cmp.get("v.selectProgram"); 
        var varoppId = cmp.get("v.recordId");
        var selectPlazaValue = cmp.get('v.selectPlaza');
        var selectResortValue = cmp.get('v.selectResort');
        var nights = cmp.get('v.numberOfNights');
        var extranights = cmp.get('v.extraNights'); //263 
        var action;
        if(cmp.get("v.selectResort") != '--None--'){
            action = cmp.get("c.roomType");
            action.setParams({
                programName: cmp.get("v.selectProgram"),
                PlazzaName :cmp.get("v.selectPlaza"),
                resoertName : cmp.get("v.selectResort"),
                fromDateValue : cmp.get("v.fromDate"),
                toDateValue : cmp.get("v.toDate"),
                oppId : varoppId,
                nightsInt : nights,
                extraNightsInt : extranights  //263
                
            });
        }else{
            action = cmp.get("c.getAllResort");
            action.setParams({ 
                programName: cmp.get("v.selectProgram"),
               PlazzaName : cmp.get("v.selectPlaza"),
                fromDateValue : cmp.get("v.fromDate"),
                toDateValue : cmp.get("v.toDate"),
                oppId : varoppId,
                nightsInt : nights,
                extraNightsInt : extranights  //263
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
                cmp.set("v.showSpin", false);
            }
            cmp.set("v.isLoaded",true);
        });
        $A.enqueueAction(action);
        
    },
    //4
    getInventoryAvailability : function(cmp,event,helper) {
        cmp.set("v.isLoaded",false);
        var selectProgram = cmp.get("v.selectProgram"); 
        var varoppId = cmp.get("v.recordId");
        var nights = cmp.get('v.numberOfNights');
        var extranights = cmp.get('v.extraNights'); //263
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
                oppId : varoppId,
                nightsInt : nights,
                extraNightsInt : extranights  //263
            });
        }else{
            action = cmp.get("c.roomType");
            action.setParams({ 
                programName: cmp.get("v.selectProgram"),
                PlazzaName :cmp.get("v.selectPlaza"),
                resoertName : cmp.get("v.selectResort"),
                fromDateValue : cmp.get("v.fromDate"),
                toDateValue : cmp.get("v.toDate"),
                oppId : varoppId,
                nightsInt : nights ,
                extraNightsInt : extranights  //263
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
                cmp.set("v.showSpin", false);
            }
            cmp.set("v.isLoaded",true);
        });
        $A.enqueueAction(action);
        
    },
    //2
    getAllprogramType : function(cmp, event, helper){
        cmp.set("v.isLoaded",false);
        var action;
        var varoppId = cmp.get("v.recordId");
        var nights = cmp.get('v.numberOfNights');
        var extraNights = cmp.get('v.extraNights');
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
                    oppId : varoppId,
                nightsInt : nights,
                    extraNightsInt : extranights  //263
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
                    alert(response.getReturnValue());
                    cmp.set("v.showSpin", false);
                }
                cmp.set("v.isLoaded",true);
                
            });
            $A.enqueueAction(action);
            
        }else{
            this.filterForAdvancedSearch(cmp, event, helper);
        }                
        
    },
    //5
    bookedInventoryInOpp : function(cmp,event,helper) {
        cmp.set('v.isReadOnly',true);
        cmp.set("v.isLoaded",false);
        var selectProgram = cmp.get("v.selectProgram"); 
        var varselectedInvId = cmp.get('v.selectedInvId');
        var varoppId = cmp.get("v.recordId");
        var nights = cmp.get('v.numberOfNights');
        var extraNights = cmp.get('v.extraNights'); //263
        var action;
        if(varselectedInvId != null && varoppId != null){
            action = cmp.get("c.bookedInventoryInOppMethod");
             action.setParams({ 
                selectedInvId : varselectedInvId,
                oppId : varoppId,                
                nightsInt : nights,
                extraNightsInt : extraNights //263 extraNightsInt
            });
        }else{
            alert('Please select Inventory Availability');
            cmp.set('v.isReadOnly',false);  
        }
        action.setCallback(this, function(response) {            
            var result = response.getReturnValue();
            var state = response.getState();
            if (state === "SUCCESS") {
                // Booking sucess
                this.fireToastMessage('Reservation Updated','success'); 
                cmp.set('v.buttonClick',true);
                cmp.set('v.rebookInvSearch',false);
                cmp.set("v.fromDate", null);
                cmp.set("v.toDate", null);
                cmp.set("v.selectPlaza", null);
                cmp.set("v.resortOption", null);
                cmp.set("v.selectRoomType", null);
                cmp.set("v.InventoryAvailabilityList", null);
                cmp.set("v.showSpin", false);
                cmp.set('v.isReadOnly',false);                
                $A.get('e.force:refreshView').fire();
                $A.get("e.force:closeQuickAction").fire();
                window.location.reload();                
            }
            else{
                alert(response.getReturnValue());
                cmp.set("v.showSpin", false);
                cmp.set('v.isReadOnly',false);                
                $A.get('e.force:refreshView').fire();
                $A.get("e.force:closeQuickAction").fire();
                window.location.reload();
            }
            cmp.set("v.isLoaded",true);

        });
        
        $A.enqueueAction(action);
        $A.get('e.force:refreshView').fire();
    },
    checktheBooking : function(cmp,event,helper) {
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
    fireToastMessage : function(message,type){
        var showToast = $A.get("e.force:showToast");  
        showToast.setParams({ 
            'duration': 5000,
            'title' : 'Message', 
            'message' : message,
            'type': type
        }); 
        showToast.fire(); 
        /*$A.get("e.force:closeQuickAction").fire();
        $A.get('e.force:refreshView').fire();   */     
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