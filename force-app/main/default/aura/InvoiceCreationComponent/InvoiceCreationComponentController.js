({    
    CreateRecord: function (component, event, helper) {
        
        //helper.showToast('Info!','Record insert might take few seconds','info');
        var fileInput = component.find("file").getElement();
        var file = fileInput.files[0];
        //alert(file);
        component.set("v.spinner", true);
        component.set("v.showInfo", true);
        if (file){
            var reader = new FileReader();
            reader.readAsText(file, "UTF-8");
            reader.onload = function (evt) {
                var csv = evt.target.result;
                console.log('csv file contains=== '+ csv);
                //alert('csv file contains=== '+ csv);
                var result = helper.CSV2JSON(component,csv);
                console.log('result = ' + result);
                // console.log('Result = '+JSON.parse(result));
                //alert('result = ' + result);
                helper.CreateInvoice(component,result);
            }
            reader.onerror = function (evt) {
                console.log("error reading file");
            }
        }
        
    },
    
})