({
    doInit: function(component, event, helper) {
        console.log("doInit fired with recordId:", component.get("v.recordId"));
        helper.doInitHelper(component, event);
    },
    
    /* javaScript function for pagination */
    navigation: function(component, event, helper) { 
        var sObjectList = component.get("v.listOfAllAccounts");
        var end = component.get("v.endPage");
        var start = component.get("v.startPage");
        var pageSize = component.get("v.pageSize");
        var whichBtn = event.getSource().get("v.name");
        // check if whichBtn value is 'next' then call 'next' helper method
        if (whichBtn == 'next') {
            component.set("v.currentPage", component.get("v.currentPage") + 1);
            helper.next(component, event, sObjectList, end, start, pageSize);
        }
        // check if whichBtn value is 'previous' then call 'previous' helper method
        else if (whichBtn == 'previous') {
            component.set("v.currentPage", component.get("v.currentPage") - 1);
            helper.previous(component, event, sObjectList, end, start, pageSize);
        }
    },
    
    create : function(component, event, helper) {
        component.set('v.loaded', true);
        //getting the candidate information
        var candidate = component.get("v.note");
        //Calling the Apex Function
        var action = component.get("c.createRecord");
        //Setting the Apex Parameter
        action.setParams({
            nt : candidate,
            PrentId : component.get("v.recordId")
        });
        //Setting the Callback
        action.setCallback(this,function(a){
            //get the response state
            var state = a.getState();
            //check if result is successfull
            if(state == "SUCCESS"){
                //Reset Form
                var newCandidate = {'sobjectType': 'ContentNote',
                                    'Title': '',
                                    'Content': ''
                                   };
                //resetting the Values in the form
                component.set("v.note",newCandidate);
                /*var elements = document.getElementsByClassName("myTest");
                elements[0].style.display = 'none';*/
                component.set('v.loaded', false);
                component.set('v.isModalOpen', false);
                //call doinit to refresh
                helper.doInitHelper(component, event);
                
            } else if(state == "ERROR"){
                component.set('v.loaded', false);
                alert('Error in calling server side action');
            }
        });
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get("v.recordId"),
            "slideDevName": "detail"
        });
        navEvt.fire();
        $A.get('e.force:refreshView').fire();
        //adds the server-side action to the queue        
        $A.enqueueAction(action);
    },
    
    hide : function(component,event,helper){
        /* var elements = document.getElementsByClassName("myTest");
        elements[0].style.display = 'none';*/
        component.set('v.isModalOpen', false);
    },
    
    show : function(component,event,helper){
        /*var elements = document.getElementsByClassName("myTest");
        elements[0].style.display = 'block';*/
        component.set('v.isModalOpen', true);
    },
    
    closeModal: function(component, event, helper) {
        component.set("v.showEmailModal", false);
    },
    
    showEmail: function(component, event, helper) {
        const emailId = event.target.getAttribute("data-id")
        console.log("Email Record Id:", emailId);
        
        component.set("v.selectedEmailId", emailId);
        component.set("v.showEmailModal", true);
        
        // Wait for rendering
        setTimeout(() => {
        const childCmp = component.find("getSingleEmail");
        if (childCmp) {
            childCmp.loadEmail(emailId);
        } else {
            console.warn("Could not find GetSingleEmailComp");
        }
		}, 200);
	}


}



 

    
)