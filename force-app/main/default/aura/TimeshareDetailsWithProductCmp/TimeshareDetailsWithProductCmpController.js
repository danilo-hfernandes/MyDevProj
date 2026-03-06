({
    doInit: function(component, event, helper) {
        console.log('3==JS');
        helper.doInitHelper(component, event);
    }, 
    toggleSection : function(component, event, helper) {
        // dynamically get aura:id name from 'data-auraId' attribute
        var sectionAuraId = event.target.getAttribute("data-auraId");
        // get section Div element using aura:id
        var sectionDiv = component.find(sectionAuraId).getElement();
        /* The search() method searches for 'slds-is-open' class, and returns the position of the match.
         * This method returns -1 if no match is found.
        */
        var sectionState = sectionDiv.getAttribute('class').search('slds-is-open'); 
        
        // -1 if 'slds-is-open' class is missing...then set 'slds-is-open' class else set slds-is-close class to element
        if(sectionState == -1){
            sectionDiv.setAttribute('class' , 'slds-section slds-is-open');
        }else{
            sectionDiv.setAttribute('class' , 'slds-section slds-is-close');
        }
    },
    onTimesharSelection : function(component,event){ 
        component.set("v.isLoaded",false);
        var selectedValue = event.getSource().get("v.value");
        component.set('v.selectedTimeshare', selectedValue);
        var action = component.get("c.selectedTimeshare");
        action.setParams({
            timeshareId:selectedValue
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                var timeshare = response.getReturnValue();
                component.set('v.addExistingTimeshare', timeshare);
            }
            else{
                helper.fireToastMessage(state,'error');     
            }
            component.set("v.isLoaded",true);
        });
        $A.enqueueAction(action);  
    },
    
    handleOnSuccess : function(component, event, helper) {
        component.set("v.isLoaded",false);
        var param = event.getParams(); //get event params
        var fields = param.response.fields; //get all field info
        var childRelationships = param.response.childRelationships; //get child relationship info
        var recordTypeInfo = param.response.recordTypeInfo; //get record type info
        var timeShareRecordId = param.response.id; //get record id
        var oppId = component.get("v.recordId");
        var action = component.get("c.updateOpportunity");
        //Setting the Apex Parameter
        action.setParams({
            timeshareId : timeShareRecordId,
            oppId : oppId
        });
        //Setting the Callback
        action.setCallback(this,function(a){
            //get the response state
            var state = a.getState();
            //check if result is successfull
            if(state == "SUCCESS"){
                helper.fireToastMessage('Record added sucessfully','success');  
                
                component.set("v.newTimeshareOpen", false);
                $A.get('e.force:refreshView').fire();
            } else if(state == "ERROR"){
                helper.fireToastMessage(state,'error');     
            }
            component.set("v.isLoaded",true);
        });
        $A.enqueueAction(action);
    },
    
    showMTRC : function(component,event,helper){
        component.set("v.MTRCProductPopupId", true);
        component.set("v.isLoaded",false);
        var action = component.get("c.AllActiveMTRCProductList");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                var oRes = response.getReturnValue();
                if(oRes.length > 0){
                    component.set('v.productListMTRC', oRes);
                    component.set("v.MTRCProductPopupId", true);
                }else{
                    // if there is no records then display message
                    component.set("v.bNoRecordsFound" , true);
                } 
            }
            else{
                this.fireToastMessage(state,'error');                
            }
            component.set("v.isLoaded",true);
        });
        $A.enqueueAction(action);
    },
    
    showMTRCClose : function(component,event,helper){
         component.set("v.MTRCProductPopupId" , false);
        $A.get('e.force:refreshView').fire();      
    },
    
    show : function(component,event,helper){
        component.set("v.timeshareId", null);
        component.set("v.newTimeshareOpen", true);
        
    },
 
    hideproductView : function(component,event,helper){
        component.set("v.addProductView" , false);
        $A.get('e.force:refreshView').fire();        
    },
    
    hide : function(component,event,helper){
        component.set("v.isLoaded",false);
       
        component.set("v.newTimeshareOpen", false);
        component.set("v.timeshareId", null);
        $A.get('e.force:refreshView').fire();        
        component.find('Resort').set('v.value', null);
        component.find('Points_Anniversary_Effective_Date').set('v.value', null);    
        component.find('Unit_Size').set('v.value',null);    
        component.find('Annual_Allocation').set('v.value',null);    
        component.find('Ownership').set('v.value', null);    
        component.find('Fees_Billing_Period').set('v.value', null);    
        component.find('Bathrooms').set('v.value', null);    
        component.find('Renewal_Month').set('v.value', null);    
        component.find('Usage').set('v.value', null);    
        component.find('MF_Paid_Until_Month').set('v.value',null);    
        component.find('Occupancy').set('v.value', null);    
        component.find('MF_Paid_Until_Year').set('v.value',null);    
        component.find('Week_Type').set('v.value', null);    
        component.find('MF_Amount').set('v.value', null);
        //component.find('Multiplier').set('v.value', null); 
        component.find('Unit_Number').set('v.value', null);    
        component.find('Past_Due_MF').set('v.value', null);    
        component.find('Week').set('v.value', null);    
        component.find('Special_Assessment').set('v.value',null);    
        component.find('ViewId').set('v.value', null);    
        component.find('MortgageId').set('v.value', null);    
        component.find('Season').set('v.value', null);    
        component.find('Mortgage_Balance').set('v.value',null);    
        component.find('Points_Program').set('v.value', null);    
        component.find('Mortgage_Monthly_Payment').set('v.value', null);    
        component.find('Contract').set('v.value', null);    
        component.find('Number_of_past_due_mortgage_payments').set('v.value', null);    
        component.find('Year_Purchased').set('v.value', null);    
        component.find('Mortgage_Interest_Rate').set('v.value',null);    
        component.find('RTU_Year').set('v.value', null);    
        component.find('First_Year_Use').set('v.value',null);    
        component.find('SMTN_OwnerId').set('v.value', null);    
        component.find('Timeshare_Owner').set('v.value', null);    
        component.set("v.isLoaded",true);
    },
 
    deletetimeshareConfimation : function(component,event,helper){
        var ctarget = event.currentTarget;
        var id_str = ctarget.dataset.value;
        component.set("v.timeshareId", id_str);

        console.log('==deletetimeshareConfimation==');
        console.log('==ctarget.dataset.timeshareNumber=='+ctarget.dataset.timesharenumber);

        // HMR-664
    	var timeshareId = ctarget.dataset.timeshareid;
    	var productaddedId = ctarget.dataset.productaddedid;
        var timeshareNumber = ctarget.dataset.timesharenumber;
        component.set("v.timeshareId", timeshareId);
        component.set("v.productaddedId", productaddedId);
        component.set("v.timeshareNumber", timeshareNumber);
        console.log('==timeshareId=='+timeshareId);
        console.log('==productaddedId=='+productaddedId);
        console.log('==timeshareNumber=='+timeshareNumber);
        console.log('==comp timeshareNumber=='+component.get("v.timeshareNumber"));
        
        var elements = document.getElementsByClassName("deletetimeshare");
        elements[0].style.display = 'block';
    },
    
    deletetimeshareConfimationclose : function(component,event,helper){
        component.set("v.timeshareId", null);
        var elements = document.getElementsByClassName("deletetimeshare");
        elements[0].style.display = 'none';
        $A.get('e.force:refreshView').fire();      
    },
    
    handleDelete : function(component,event,helper){
         component.set("v.isLoaded",false);
        
        var timeshareId = component.get("v.timeshareId");
        var oppId = component.get("v.recordId");

        var prdid = component.get("v.productaddedId");
        var timeshareNumber = component.get("v.timeshareNumber");
        console.log('==timeshareId handleDelete=='+timeshareId);
        console.log('==oppId handleDelete=='+oppId);
        console.log('==prdid handleDelete=='+prdid);
        console.log('==handleDelete comp timeshareNumber=='+timeshareNumber);
		//HMR-664
        
/*
		//HMR-664
        var tsId = event.currentTarget.dataset.timeshareid;
        var prdid = event.currentTarget.dataset.productaddedid;
        console.log('==tsId handleDelete=='+tsId);
        console.log('==prdid handleDelete=='+prdid);
*/
        
        var action = component.get("c.timesharDelete");

        console.log('==timeshareId handleDelete=='+timeshareId);
        console.log('==Calling Apex Method timesharDelete==');

        //Setting the Apex Parameter
        action.setParams({ 
            timeshareId : timeshareId,
            oppId : oppId,
            timeshareNumber : timeshareNumber
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            console.log('==Apex Response State==', state);

            if(state == "SUCCESS"){
	            console.log('==Delete Success==');
                helper.fireToastMessage('Timeshare deleted successfully','success');     
                var elements = document.getElementsByClassName("deletetimeshare");
                elements[0].style.display = 'none';
                $A.get('e.force:refreshView').fire();
            } else if(state == "ERROR"){
               console.error('==Delete Failed, Apex Error==', response.getError());

                helper.fireToastMessage('Timeshares cant be removed as its attached with product','error');     

            }
             console.log('==Setting isLoaded to True==');
            component.set("v.isLoaded",true);
        });
        $A.enqueueAction(action);
      
    },
    
    addProductToTimeshare : function(component,event,helper){
        component.set("v.isLoaded",false);
        var timesharId = event.currentTarget.dataset.id;
        var timeshareName = event.currentTarget.dataset.label;
        var timeshareNumber = event.currentTarget.dataset.timesharenumber;
        var oppId = component.get("v.recordId");
         component.set("v.timeshareName", timeshareName);
        component.set("v.timeshareId", timesharId);
        //2024-04-17 HSIMU2-687 Multiplier for MFP Products - 3 [mfpMultiplier]
        
        component.set("v.timeshareNumber", timeshareNumber);
        console.log('v.timeshareNumber = '+timeshareNumber);

        
        var action = component.get("c.AllActiveProductList");
        //Setting the Apex Parameter
        action.setParams({ 
            oppId : oppId,
            timeshareIdentifier: timesharId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                var oRes = response.getReturnValue();
                if(oRes.length > 0){
                    console.log('AllActiveProductList oRes = '+JSON.stringify(oRes));
                    component.set('v.productList', oRes);
                    component.set("v.addProductView" , true);
                }else{
                    // if there is no records then display message
                    component.set("v.bNoRecordsFound" , true);
                } 
            }
            else{
                this.fireToastMessage(state,'error');                
            }
            component.set("v.isLoaded",true);
        });
        $A.enqueueAction(action);
    },
    seletedProduct : function(component,event,helper){
        component.set("v.isLoaded",false);
        var ctarget = event.currentTarget;
        var id_str = ctarget.dataset.value;
        //console.log('id_str = '+id_str);
        component.set("v.selectedProduct", id_str);
        component.set("v.isLoaded",true);
        var wrapperlist = component.get("v.productList");
        if(wrapperlist != null && wrapperlist != undefined && id_str != null && id_str != undefined && id_str != ''){
            if(wrapperlist.length > 0){
                for (let i = 0; i < wrapperlist.length; i++){
                    const item = wrapperlist[i];
                    if(item.prd != null && item.prd != undefined && item.prd != '')
                    {
                        if(item.prd.Id != null && item.prd.Id != undefined && item.prd.Id != '')
                        {
                            if(item.prd.Id == id_str)
                            {
                                item.selected = true;
                            }
                            else
                            {
                                item.selected = false;
                            }
                        }
                    }
                    
                    // Do something with the current item
                    //console.log('wrapper prd id = '+item.prd.Id);
                }
            }
        }
        component.set("v.productList", wrapperlist);
        //console.log('wrapperlist = '+JSON.stringify(wrapperlist));
        $A.get('e.force:refreshView').fire();  
    },
    
    ReasontoSellPickselectedValuejs : function(component,event){ 
        component.set("v.isLoaded",false);
        var ctarget = event.currentTarget;
        var id_str = ctarget.dataset.value;
         component.set("v.selectedProductForDropDown", id_str);
        component.set("v.isLoaded",true);
         $A.get('e.force:refreshView').fire();  
    },
    
    saveproductLine : function(component,event,helper){

        component.set("v.isLoaded",false);
        var productId = component.get("v.selectedProduct");
        var selectedProductForDropDown = component.get("v.selectedProductForDropDown");

        // Get all selected product radio buttons - HMR-601
        var selectedRadios = component.find("others");
        // Get all MFMultiplier fields
        var multipliers = component.find("MFMultiplier");
        var invalidMultiplier = false; // Flag to check if validation fails

        //HMR-664
        var timeshareNumber = component.get("v.timeshareNumber");
        console.log('v.timeshareNumber = '+timeshareNumber);
        
        
        // HMR-601 - multiplier cannot be null        
       	var wrapperlist = component.get("v.productList"); // Get all products
        // Ensure wrapperlist exists before looping
        if (!wrapperlist || wrapperlist.length === 0) {
            window.alert("Error: No products found.");
            helper.fireToastMessage('System Error: No products available.', 'error');
            component.set("v.isLoaded", true);
            return;
        }
        
        // Loop through products and check if selected products have a valid multiplier - HMR-601
        wrapperlist.forEach(function(prodObj) {
            if (prodObj.selected === true) { // Check only selected products
                
                var mfValue = prodObj.productMFMultiplier;
                var isMultiplierDisabled = (prodObj.prd.Name !== 'Maintenance Fee Protection' && prodObj.prd.Name !== 'HC Vida Collection Weeks Usage Fee TC Rebate');
    
                // Only validate the multiplier if it is NOT disabled
                if (!isMultiplierDisabled) { 
                    if (mfValue == null || mfValue === undefined || mfValue === 0) {
//                        window.alert("Invalid Multiplier");  // Show alert only when MFMultiplier is enabled
                        invalidMultiplier = true;
                    }
                }
            }
        });        
            

        if(productId == 'null'){
             helper.fireToastMessage('Please select product','error');
             component.set("v.isLoaded",true);
         }else if(invalidMultiplier){ // HMR-601 - multiplier cannot be null        
             helper.fireToastMessage('Multiplier is missing.','error');
             component.set("v.isLoaded",true);
         }else{
            var oppId = component.get("v.recordId");
            var timeshareId = component.get("v.timeshareId");
            var wrapperlist = component.get("v.productList");
            console.log('wrapperlist = '+wrapperlist);
            var action = component.get("c.saveProductLineItem");
            //Setting the Apex Parameter
            action.setParams({ 
                proWrapperlist : wrapperlist,
                OppId : oppId,
                timeshareId : timeshareId,
                productId : productId,
                timeshareNumber : timeshareNumber
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS"){
                    
                    component.set("v.addProductView" , false);
                    $A.get('e.force:refreshView').fire();  
                    component.set("v.isLoaded",true);
                }
                else{
                    var errors = response.getError();  
                    helper.fireToastMessage(errors[0].message,'error');  
                    component.set("v.isLoaded",true);
                }
                
            });
            $A.enqueueAction(action);
        }
    },
	saveproductLineforMTRC : function(component,event,helper){
        component.set("v.isLoaded",false);
        var productId = component.get("v.selectedProduct");
        var selectedProductForDropDown = component.get("v.selectedProductForDropDown");
          if(productId == 'null'){
             helper.fireToastMessage('Please select product','error');
             component.set("v.isLoaded",true);
         }else{
            var oppId = component.get("v.recordId");
            var wrapperlist = component.get("v.productListMTRC");
            var action = component.get("c.saveProductLineItemMTRC");
             //Setting the Apex Parameter
            action.setParams({ 
                proWrapperlist : wrapperlist,
                OppId : oppId,
                productId : productId
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                 if (state === "SUCCESS"){
                    $A.get('e.force:refreshView').fire();  
                    component.set("v.isLoaded",true);
                    component.set("v.MTRCProductPopupId" , false);
                }
                else{
                    var errors = response.getError();  
                    helper.fireToastMessage(errors[0].message,'error');  
                    component.set("v.isLoaded",true);
                }
                
            });
            $A.enqueueAction(action);
        }
    },    
    handleEdit : function(component,event,helper){
        component.set("v.isLoaded",false);
        var ctarget = event.currentTarget;
        var id_str = ctarget.dataset.value;
        component.set("v.timeshareId", id_str);
        var action = component.get("c.timesharRecordDetails");
         action.setParams({ 
            timeshareId : id_str
        });
         action.setCallback(this,function(response){
             var state = response.getState();
              if(state == "SUCCESS"){
                var timeshareObj = response.getReturnValue();
                component.set('v.timeshareObjectEdit', timeshareObj);
                var times =  component.get('v.timeshareObjectEdit');
                 component.set("v.newTimeshareOpen", true);
                component.find('Resort').set('v.value', times.Resort__c);
                 if(times.Points_Anniversary_Effective_Date__c != null && times.Points_Anniversary_Effective_Date__c != 'undefined'){
                    component.find('Points_Anniversary_Effective_Date').set('v.value', times.Points_Anniversary_Effective_Date__c);    
                }else{
                    component.find('Points_Anniversary_Effective_Date').set('v.value', null);
                }
                 
                if(times.Unit_Size__c != null && times.Unit_Size__c != 'undefined'){
                    component.find('Unit_Size').set('v.value', times.Unit_Size__c);    
                }else{
                    component.find('Unit_Size').set('v.value', null);
                }
                if(times.Annual_Allocation__c != null && times.Annual_Allocation__c != 'undefined'){
                    component.find('Annual_Allocation').set('v.value', times.Annual_Allocation__c);    
                }else{
                    component.find('Annual_Allocation').set('v.value', null);
                }
                if(times.Ownership__c != null && times.Ownership__c != 'undefined'){
                    component.find('Ownership').set('v.value', times.Ownership__c);    
                }else{
                    component.find('Ownership').set('v.value', null);
                }      
                if(times.Fees_Billing_Period__c != null && times.Fees_Billing_Period__c != 'undefined'){
                    component.find('Fees_Billing_Period').set('v.value', times.Fees_Billing_Period__c);    
                }else{
                    component.find('Fees_Billing_Period').set('v.value', null);
                }
                if(times.Bathrooms__c != null && times.Bathrooms__c != 'undefined'){
                    component.find('Bathrooms').set('v.value', times.Bathrooms__c);    
                }else{
                    component.find('Bathrooms').set('v.value', null);
                }                
                if(times.Renewal_Month__c != null && times.Renewal_Month__c != 'undefined'){
                    component.find('Renewal_Month').set('v.value', times.Renewal_Month__c);    
                }else{
                    component.find('Renewal_Month').set('v.value', null);
                }
                if(times.Usage__c != null && times.Usage__c != 'undefined'){
                    component.find('Usage').set('v.value', times.Usage__c);    
                }else{
                    component.find('Usage').set('v.value', null);
                }                
                if(times.MF_Paid_Until_Month__c != null && times.MF_Paid_Until_Month__c != 'undefined'){
                    component.find('MF_Paid_Until_Month').set('v.value', times.MF_Paid_Until_Month__c);    
                }else{
                    component.find('MF_Paid_Until_Month').set('v.value', null);
                }
                 if(times.Occupancy__c != null && times.Occupancy__c != 'undefined'){
                    component.find('Occupancy').set('v.value', times.Occupancy__c);    
                }else{
                    component.find('Occupancy').set('v.value', null);
                }
                if(times.MF_Paid_Until_Year__c != null && times.MF_Paid_Until_Year__c != 'undefined'){
                    component.find('MF_Paid_Until_Year').set('v.value', times.MF_Paid_Until_Year__c);    
                }else{
                    component.find('MF_Paid_Until_Year').set('v.value', null);
                }
                if(times.Week_Type__c != null && times.Week_Type__c != 'undefined'){
                    component.find('Week_Type').set('v.value', times.Week_Type__c);    
                }else{
                    component.find('Week_Type').set('v.value', null);
                }                
                if(times.MF_Amount__c != null && times.MF_Amount__c != 'undefined'){
                    component.find('MF_Amount').set('v.value', times.MF_Amount__c);    
                }else{
                    component.find('MF_Amount').set('v.value', null);
                }
                /*if(times.Multiplier__c != null && times.Multiplier__c != 'undefined'){
                    component.find('Multiplier').set('v.value', times.Multiplier__c);
                }else{
                    component.find('Multiplier').set('v.value', null);
                }*/
                if(times.Unit_Number__c != null && times.Unit_Number__c != 'undefined'){
                    component.find('Unit_Number').set('v.value', times.Unit_Number__c);    
                }else{
                    component.find('Unit_Number').set('v.value', null);
                }                
                if(times.Past_Due_MF__c != null && times.Past_Due_MF__c != 'undefined'){
                    component.find('Past_Due_MF').set('v.value', times.Past_Due_MF__c);    
                }else{
                    component.find('Past_Due_MF').set('v.value', null);
                }                
                if(times.Week__c != null && times.Week__c != 'undefined'){
                    component.find('Week').set('v.value', times.Week__c);    
                }else{
                    component.find('Week').set('v.value', null);
                }                
                if(times.Special_Assessment__c != null && times.Special_Assessment__c != 'undefined'){
                    component.find('Special_Assessment').set('v.value', times.Special_Assessment__c);    
                }else{
                    component.find('Special_Assessment').set('v.value', null);
                }               
                if(times.View__c != null && times.View__c != 'undefined'){
                    component.find('ViewId').set('v.value', times.View__c);    
                }else{
                    component.find('ViewId').set('v.value', null);
                }                
                if(times.Mortgage__c != null && times.Mortgage__c != 'undefined'){
                    component.find('MortgageId').set('v.value', times.Mortgage__c);    
                }else{
                    component.find('MortgageId').set('v.value', null);
                }                
                if(times.Season__c != null && times.Season__c != 'undefined'){
                    component.find('Season').set('v.value', times.Season__c);    
                }else{
                    component.find('Season').set('v.value', null);
                }
                if(times.Mortgage_Balance__c != null && times.Mortgage_Balance__c != 'undefined'){
                    component.find('Mortgage_Balance').set('v.value', times.Mortgage_Balance__c);    
                }else{
                    component.find('Mortgage_Balance').set('v.value', null);
                }
                if(times.Points_Program__c != null && times.Points_Program__c != 'undefined'){
                    component.find('Points_Program').set('v.value', times.Points_Program__c);    
                }else{
                    component.find('Points_Program').set('v.value', null);
                }                
                if(times.Mortgage_Monthly_Payment__c != null && times.Mortgage_Monthly_Payment__c != 'undefined'){
                    component.find('Mortgage_Monthly_Payment').set('v.value', times.Mortgage_Monthly_Payment__c);    
                }else{
                    component.find('Mortgage_Monthly_Payment').set('v.value', null);
                }
                if(times.Contract__c != null && times.Contract__c != 'undefined'){
                    component.find('Contract').set('v.value', times.Contract__c);    
                }else{
                    component.find('Contract').set('v.value', null);
                }
                if(times.Number_of_past_due_mortgage_payments__c != null && times.Number_of_past_due_mortgage_payments__c != 'undefined'){
                    component.find('Number_of_past_due_mortgage_payments').set('v.value', times.Number_of_past_due_mortgage_payments__c);    
                }else{
                    component.find('Number_of_past_due_mortgage_payments').set('v.value', null);
                }
                if(times.Year_Purchased__c != null && times.Year_Purchased__c != 'undefined'){
                    component.find('Year_Purchased').set('v.value', times.Year_Purchased__c);    
                }else{
                    component.find('Year_Purchased').set('v.value', null);
                }
                if(times.Mortgage_Interest_Rate__c != null && times.Mortgage_Interest_Rate__c != 'undefined'){
                    component.find('Mortgage_Interest_Rate').set('v.value', times.Mortgage_Interest_Rate__c);    
                }else{
                    component.find('Mortgage_Interest_Rate').set('v.value', null);
                }
                if(times.RTU_Year__c != null && times.RTU_Year__c != 'undefined'){
                    component.find('RTU_Year').set('v.value', times.RTU_Year__c);    
                }else{
                    component.find('RTU_Year').set('v.value', null);
                }
                if(times.First_Year_Use__c != null && times.First_Year_Use__c != 'undefined'){
                    component.find('First_Year_Use').set('v.value', times.First_Year_Use__c);    
                }else{
                    component.find('First_Year_Use').set('v.value', null);
                }                
                if(times.SMTN_OwnerId__c != null && times.SMTN_OwnerId__c != 'undefined'){
                    component.find('SMTN_OwnerId').set('v.value', times.SMTN_OwnerId__c);    
                }else{
                    component.find('SMTN_OwnerId').set('v.value', null);
                }
                if(times.Timeshare_Owner__c != null && times.Timeshare_Owner__c != 'undefined'){
                    component.find('Timeshare_Owner').set('v.value', times.Timeshare_Owner__c);    
                }else{
                    component.find('Timeshare_Owner').set('v.value', null);
                } 
                
                
            } else if(state == "ERROR"){
                helper.fireToastMessage(state,'error');     
            }
            component.set("v.isLoaded",true);
        });
        $A.enqueueAction(action);
    }
})