({
    doInit: function(component, event, helper) {       
        var parentOppId = component.get("v.recordId");
        
        var action = component.get("c.tryToAddChildOpp");
        action.setParams({
            recordId : parentOppId
        });
        action.setCallback(this, function(response) {
            //var mock = 'Database.LeadConvertResult[getAccountId=0015300000GSdNaAAL;getContactId=0035300000BDM45AAH;getErrors=();getLeadId=00Q53000002wEwzEAE;getOpportunityId=00653000005BZsBAAW;getRelatedPersonAccountId=null;isSuccess=true;]';
            //var jsonObj = Json.parse(mock);
            //console.log('jsonObj : '+jsonObj);
            //console.log('jsonObj strigify : '+JSON.stringify(jsonObj));
            var state = response.getState();
            console.log('state : '+state);
            if (state === "SUCCESS"){
                
                var map = response.getReturnValue();
                console.log('map : '+map);
                var stateStr = Object.keys(map)[0];
                console.log('stateStr : '+stateStr);
                var log = Object.values(map)[0];
                console.log('log : '+log);
                if(stateStr == 'false'){
                    component.set("v.showSpin", false);
                    helper.fireToastMessage(component,log,'error');
                }else{
                    $A.get('e.force:refreshView').fire();
                    var oppId = ''
                    oppId = log;
                    console.log('oppId : '+oppId);
                    let urlString = window.location.href;
                    console.log('urlString : '+urlString);
                    let baseURL = urlString.substring(0, urlString.indexOf('.com/')) + '.com/';
                    console.log('baseURL : '+baseURL);                    
                    var oppLink = baseURL + oppId;
                    component.set("v.opportunityLink", oppLink);
                    component.set("v.showCreatedRecords", true);
                    component.set("v.showSpin", false);
                    
                    helper.fireToastMessage(component,'Child Opportunity Successfully Created','success');
                }
            }
            else{
                component.set("v.showSpin", false);
                helper.fireToastMessage(component,state,'error');
            }
        });
        $A.enqueueAction(action);                
    }    
})