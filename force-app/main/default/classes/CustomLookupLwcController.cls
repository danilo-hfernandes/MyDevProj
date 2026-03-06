public class CustomLookupLwcController {
    // Method to fetch lookup search result   
     @AuraEnabled(cacheable=true)
     public static list<sObject> fetchLookupData(string searchKey , string sObjectApiName) {    
         List < sObject > returnList = new List < sObject > ();
 
         string sWildCardText = '%' + searchKey + '%';
         string sQuery = '';
         if(sObjectApiName == 'User'){
             sQuery = 'Select Id,Name From ' + sObjectApiName + ' Where Name Like : sWildCardText and isActive = true order by createdDate DESC LIMIT 5';
         }else{
              sQuery = 'Select Id,Name From ' + sObjectApiName + ' Where Name Like : sWildCardText order by createdDate DESC LIMIT 5';
         }
         system.debug('---sQuery-'+sQuery);
         for (sObject obj: database.query(sQuery)) {
             returnList.add(obj);
         }
         return returnList; 
     }
     
     // Method to fetch lookup default value 
     @AuraEnabled
     public static sObject fetchDefaultRecord(string recordId , string sObjectApiName) {
         string sRecId = recordId;    
         string sQuery = 'Select Id,Name From ' + sObjectApiName + ' Where Id = : sRecId LIMIT 1';
         for (sObject obj: database.query(sQuery)) {
             return obj;
         }
         return null;
     }
 }