({
    doInit: function(component, event, helper) {        
        var oppId = component.get("v.recordId");
        var action = component.get("c.tryToGetCreditsData");
        action.setParams({
            recordId : oppId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            //console.log('state : '+state);
            if (state === "SUCCESS"){
                
                var map = response.getReturnValue();
                //console.log('map : '+map);
                var stateStr = Object.keys(map)[0];
                //console.log('stateStr : '+stateStr);
                var log = Object.values(map)[0];
                //console.log('log : '+log);
                //console.log('Object.values(log)[0] : '+Object.keys(log)[0]);
                
                if(stateStr == 'false'){
                    component.set("v.showSpin", false);
                    helper.fireToastMessage(component, event,Object.keys(log)[0],'error');
                }else{
                    $A.get('e.force:refreshView').fire();
                    component.set("v.Credits_Balance", log.Credits_Balance_c);
                    //component.set("v.Membership_Annual_Due", log.Membership_Annual_Due_c);
                    component.set("v.Opportunity_Total_Amount", log.Opportunity_Total_Amount_c);
                    component.set("v.Number_Of_Years_To_Pay", log.Number_Of_Years_To_Pay_c);
                    //component.set("v.Total_Due", log.Opportunity_Total_Amount_c * component.get("v.Number_Of_Years_To_Pay"));
                    component.set("v.Total_Due", log.Opportunity_Total_Amount_c);
                    component.set("v.Balance_To_Pay", component.get("v.Total_Due") - component.get("v.Apply_Credits"));
                    if(component.get("v.Credits_Balance") == null || component.get("v.Credits_Balance") == undefined || component.get("v.Credits_Balance") <= 0)
                    {
                        component.set("v.subimitBtnDisabled", true);
                        component.set("v.editableFieldsDisabled", true);
                    }
                    if(component.get("v.Opportunity_Total_Amount") == null || component.get("v.Opportunity_Total_Amount") == undefined || component.get("v.Opportunity_Total_Amount") <= 0)
                    {
                        component.set("v.subimitBtnDisabled", true);
                        component.set("v.editableFieldsDisabled", true);
                    }
                    component.set("v.showApplyCreditsComp", true);
                    component.set("v.showSpin", false);
                }
            }
            else{
                component.set("v.showSpin", false);
                helper.fireToastMessage(component, event,state,'error');
            }
        });
        $A.enqueueAction(action);
    },
    
    Calculate: function(component, event, helper) {
                
        var AvaliableCredits = component.get("v.Credits_Balance");
        var ApplyCredits = component.get("v.Apply_Credits");
        var NumberOfYears = component.get("v.Number_Of_Years_To_Pay");
        /*var AnnualDue = component.get("v.Membership_Annual_Due");
        var TotalDue = component.get("v.Total_Due");
        var BalanceToPay = component.get("v.Balance_To_Pay");*/
        
        if(AvaliableCredits != null && AvaliableCredits > 0)
        {
            if(NumberOfYears != null && NumberOfYears < 0)
            {
                component.set("v.Number_Of_Years_To_Pay", Math.abs(NumberOfYears));
                NumberOfYears = Math.abs(NumberOfYears);
            }
            
            if(ApplyCredits != null && ApplyCredits < 0)
            {
                component.set("v.Apply_Credits", Math.abs(ApplyCredits));
                ApplyCredits = Math.abs(ApplyCredits)
            }
            
            if(ApplyCredits != null && ApplyCredits != 0 && AvaliableCredits != null && ApplyCredits > AvaliableCredits)
            {
                component.set("v.Apply_Credits", AvaliableCredits);
                ApplyCredits = AvaliableCredits;
            }
            
            //console.log('new value = '+event.getSource().get("v.value"));
            
            //$A.util.addClass(PortfolioPriceRow,'alerted');
            //var PortfolioPriceRow = component.find("PricePortfolio")[i];
            
            component.set("v.Total_Due", component.get("v.Opportunity_Total_Amount"));
            component.set("v.Balance_To_Pay", component.get("v.Total_Due") - component.get("v.Apply_Credits"));
            
            if(ApplyCredits == null || ApplyCredits == 0 || NumberOfYears == null || NumberOfYears == 0 || component.get("v.Balance_To_Pay") < 0 || component.get("v.Balance_To_Pay") == null)
            {
                component.set("v.subimitBtnDisabled", true);
                if(component.get("v.Balance_To_Pay") < 0 || component.get("v.Balance_To_Pay") == null)
                {
                    $A.util.addClass(component.find("BalanceToPayDiv"),'alerted');
                }
                else
                {
                    $A.util.removeClass(component.find("BalanceToPayDiv"),'alerted');
                }
            }
            else
            {
                component.set("v.subimitBtnDisabled", false);
                $A.util.removeClass(component.find("BalanceToPayDiv"),'alerted');
            }
        }
        else
        {
            component.set("v.subimitBtnDisabled", true);
            component.set("v.editableFieldsDisabled", true);
        }
         
    },
    
    Submit: function(component, event, helper){
        component.set("v.showSpin", true);
        var checkAvaliableCredits = component.get("v.Credits_Balance");
        var checkApplyCredits = component.get("v.Apply_Credits");
        var checkNumberOfYears = component.get("v.Number_Of_Years_To_Pay");
        var checkAnnualDue = component.get("v.Opportunity_Total_Amount");
        var checkTotalDue = component.get("v.Total_Due");
        var checkBalanceToPay = component.get("v.Balance_To_Pay");
        var fieldsWithErrors = "";
        
        if(checkAvaliableCredits <= 0)
        {
            fieldsWithErrors = fieldsWithErrors + 'Avaliable Credits <= 0';
        }
        else if(checkApplyCredits <= 0)
        {
            fieldsWithErrors = fieldsWithErrors + 'Apply Credits <= 0';
        }
        else if(checkNumberOfYears <= 0)
        {
            fieldsWithErrors = fieldsWithErrors + 'Number Of Years <= 0';
        }
        else if(checkAnnualDue <= 0)
        {
            fieldsWithErrors = fieldsWithErrors + 'Annual Due <= 0';
        }
        else if(checkTotalDue <= 0)
        {
            fieldsWithErrors = fieldsWithErrors + 'Total Due <= 0';
        }
        else if(checkBalanceToPay < 0)
        {
            fieldsWithErrors = fieldsWithErrors + 'Balance To Pay < 0';
        }
        else if(checkAvaliableCredits < checkApplyCredits)
        {
            fieldsWithErrors = fieldsWithErrors + 'Avaliable Credits < Apply Credits';
        }
        
        //console.log('fields checked = '+fieldsWithErrors);
        
        if(fieldsWithErrors != ""){
            component.set("v.showSpin", false);
            helper.fireToastMessage(component, event,log,'Please review the following fields : '+fieldsWithErrors);            
        }
        else
        {            
            component.set("v.showSpin", false);
            component.set("v.editableFieldsDisabled", true);
            component.set("v.showConfirmButton", true);
        }
    },
    
    
    Confirm: function(component, event, helper){
        component.set("v.showSpin", true);
        component.set("v.showApplyCreditsComp", false);
        const credits = new Object();        
        credits.Credits_Balance_c = component.get("v.Credits_Balance");
        credits.Opportunity_Total_Amount_c = component.get("v.Opportunity_Total_Amount");
        credits.Number_Of_Years_To_Pay_c = component.get("v.Number_Of_Years_To_Pay");
        credits.Total_Due_c = component.get("v.Total_Due");
        credits.Apply_Credits_c = component.get("v.Apply_Credits");
        credits.Balance_To_Pay_c = component.get("v.Balance_To_Pay");
        
        var opportunityId = component.get("v.recordId");
        var action = component.get("c.tryToUseCredits");
        action.setParams({
            recordId : opportunityId,
            creditsData : credits
        });
        
        action.setCallback(this, function(response) {            
            var state = response.getState();
            //console.log('state : '+state);
            if (state === "SUCCESS"){                
                var map = response.getReturnValue();
                //console.log('map : '+map);
                var stateStr = Object.keys(map)[0];
                //console.log('stateStr : '+stateStr);
                var log = Object.values(map)[0];
                //console.log('log : '+log);
                if(stateStr == 'false'){
                    component.set("v.showSpin", false);
                    component.set("v.showApplyCreditsComp", true);
                    helper.fireToastMessage(component, event,log,'error');
                }else{
                    //$A.get('e.force:refreshView').fire();                    
                    component.set("v.showSpin", false);                    
                    //console.log('this fire success ToastMessage');
                    helper.fireToastMessage(component, event,"Credits successfully applied !","success");
                    $A.get("e.force:closeQuickAction").fire();
                }
            }
            else{
                component.set("v.showSpin", false);
                component.set("v.showApplyCreditsComp", true);
                helper.fireToastMessage(component, event,state,'error');
            }
        });
        $A.enqueueAction(action);        
    }    
})