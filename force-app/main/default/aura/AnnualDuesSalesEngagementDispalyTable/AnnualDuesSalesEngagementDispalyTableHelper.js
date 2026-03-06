({
    /*fetchRecord : function(component, event, helper) {
        var action = component.get('c.fetchAccountsRecord');
        action.setCallback(this, function(response){
            var state = response.getState();      
            if (state === "SUCCESS") { 
                var result = response.getReturnValue();
                if(result != null){
                    component.set("v.recordList",result);   
                }else{
                    alert('No record to fetch');
                }   
            }
            else{
                alert('ERROR');
            }
        });
        $A.enqueueAction(action); 
    },*/
    convertintocsvfileHelper : function(component, sObjectList){
        
        var csvStringResult, counter, keys, columnDivider, lineDivider;
        var csvHeader = ' ';
        if (sObjectList == null || sObjectList.length == 0) {
            return null; // 
        }
        columnDivider = ',';
        lineDivider =  '\n';
        console.log('sObjectList = '+JSON.stringify(sObjectList));
        //keys = ['id','Match_Group_Name__c','Account.name','name','leadassist__Use_Round_Robin__c','Assign_to_Sales_Cadence__c','Cadence_Flag__c,Account.Dues_Last_Paid_Until__c', 'Account.Affiliated_Id__c', 'Account.Preferred_Language__c', 'Account.Membership_SubType__c'];
        keys = ['Id','leadassist__Use_Round_Robin__c','Assign_to_Sales_Cadence__c','Assign_to_Sales_Cadence_Name__c','Cadence_Flag__c'];
        csvStringResult = csvHeader + lineDivider;
        csvStringResult += keys.join(columnDivider);
        csvStringResult += lineDivider;
        for(var i=0; i < sObjectList.length; i++){
            counter = 0;
            for(var sTempkey in keys) {
                var skey = keys[sTempkey];
                // add , [comma] after every String value,. [except first]
                if(counter > 0){
                    csvStringResult += columnDivider;
                }
                csvStringResult += '"'+ sObjectList[i][skey]+'"';
                
                counter++;
            } 
            csvStringResult += lineDivider;
        }
        return csvStringResult;
    }
})