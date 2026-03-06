({
    doInitHelper: function(component, event, helper) {
        //var userId = $A.get("$SObjectType.CurrentUser.Id");
        var leadId = component.get("v.recordId");
        var action = component.get("c.tryToConvertLead");
        action.setParams({
            recordId : leadId
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
                    this.fireToastMessage(component,log,'error');
                }else{
                    $A.get('e.force:refreshView').fire();
                    var accId = '';
                    var oppId = ''
                    var conId = '';
                    accId = log.substring((log.indexOf('getAccountId=')+13),(log.indexOf('getAccountId=')+31));
                    oppId = log.substring((log.indexOf('getOpportunityId=')+17),(log.indexOf('getOpportunityId=')+35));
                    conId = log.substring((log.indexOf('getContactId=')+13),(log.indexOf('getContactId=')+31));
                    console.log('accId : '+accId);
                    console.log('oppId : '+oppId);
                    console.log('conId : '+conId);
                    let urlString = window.location.href;
                    console.log('urlString : '+urlString);
                    let baseURL = urlString.substring(0, urlString.indexOf('.com/')) + '.com/';
                    console.log('baseURL : '+baseURL);
                    var accLink = baseURL + accId;
                    var conLink = baseURL + conId;
                    var oppLink = baseURL + oppId;
                    
                    component.set("v.accountLink", accLink);
                    component.set("v.contactLink", conLink);
                    component.set("v.opportunityLink", oppLink);
                    component.set("v.showConvertedRecords", true);
                    component.set("v.showSpin", false);
                    
                    this.fireToastMessage(component,'Lead Successfully Converted','success');
                }
            }
            else{
                component.set("v.showSpin", false);
                this.fireToastMessage(component,state,'error');
            }
        });
        $A.enqueueAction(action);
    },
    fireToastMessage : function(component,message,type){
        var showToast = $A.get("e.force:showToast");
        showToast.setParams({
            'duration': 5000,
            'title' : 'Message',
            'message' : message,
            'type': type
        });
        //$A.get('e.force:refreshView').fire();
        showToast.fire();
        component.set("v.showSpin", false);        
        //$A.get("e.force:closeQuickAction").fire()
    }
})