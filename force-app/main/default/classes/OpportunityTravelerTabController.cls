/**
* @File Name : OpportunityTravelerTabController.cls
* @Description :
* @Author :
* @Last Modified By : Shivani Chauhan
* @Last Modified On : September 24, 2024
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | September 17, 2024 | Shivani Chauhan  | Initial Version
**/

public class OpportunityTravelerTabController {
	@AuraEnabled(cacheable=true)
	public static List<Traveler__c> getTravelerData(Id oppId){
		List<Traveler__c> listTraveler = [select id,First_Name__c,Last_Name__c,Date_Of_Birth__c,Age__c,Occupation__c,Relation__c  from Traveler__c where Opportunity__c =: oppId];
		if(listTraveler != null && listTraveler.size() > 0){
			return listTraveler;
		}
		return null;
	}
	@AuraEnabled
	Public static List<Traveler__c> insertTravelerData(Id oppId, List<Map<String, String>> travelerData){
		try{
			List<Traveler__c> listTraveler = new List<Traveler__c>();
			if(travelerData != null && travelerData.size() > 0){
				for(Map<String, String> objdata : travelerData){ 
					Traveler__c objTraveler = new Traveler__c();
                    String firstName = objdata.get('First_Name__c') != null ?objdata.get('First_Name__c') : ''; 
                    String lastName = objdata.get('Last_Name__c') != null ?objdata.get('Last_Name__c') : ''; 
					objTraveler.Name = firstName+' '+ lastName;
					objTraveler.First_Name__c = firstName;
					objTraveler.Last_Name__c = lastName;
					objTraveler.Date_Of_Birth__c = objdata.get('Date_Of_Birth__c') != null ? date.valueOf(objdata.get('Date_Of_Birth__c')) : null;
					objTraveler.Age__c = objdata.get('Age__c') != null ? Integer.valueOf(objdata.get('Age__c')) : null;
					objTraveler.Occupation__c = objdata.get('Occupation__c') != null ?objdata.get('Occupation__c') : '';
					objTraveler.Relation__c = objdata.get('Relation__c') != null ? objdata.get('Relation__c') : '';
					objTraveler.Opportunity__c = oppId; 
                    Boolean runningInASandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
					if(runningInASandbox && objdata.get('Id').startsWith('a20')){
						objTraveler.Id = objdata.get('Id');
					} 
                    else if(!runningInASandbox && objdata.get('Id').startsWith('a23')){
						objTraveler.Id = objdata.get('Id');
					}
					listTraveler.add(objTraveler);
				}
			}
			if(listTraveler.size() > 0){
				upsert listTraveler;
			}
			List<Traveler__c> updatedListTraveler = [select id,First_Name__c,Last_Name__c,Date_Of_Birth__c,Age__c,Occupation__c,Relation__c  from Traveler__c where Opportunity__c =: oppId];
			if(updatedListTraveler != null && updatedListTraveler.size() > 0){
				return updatedListTraveler;
			}
			return null;
		}
		catch( System.Exception ex) {
            System.debug('ERROR: '+ ex);
            Error_Handler__c err = new Error_Handler__c();
            err.Name = 'Apex Class : OpportunityTravelerTabController';
            err.Error_Message__c = 'Message:' + ex.getMessage()  + ' - Exception occurrred on LineNumber: ' + ex.getLineNumber();
            insert err; 
			return  null;
		}
	}
}