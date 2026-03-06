public class FileTrackerLeadConversionController {
    public static void convertLeads(List<Lead> leadsToConvert) {
        // Collect emails and phones for matching
        Set<String> emailSet = new Set<String>();
        Set<String> phoneSet = new Set<String>();
        Set<Decimal> affiliateIds = new Set<Decimal>();
        System.debug('>>>>>>>leadsToConvert>>>>'+leadsToConvert);
        for (Lead lead : leadsToConvert) {
            if (!String.isEmpty(lead.Email)) {
                emailSet.add(lead.Email);
            }
            if (!String.isEmpty(lead.Phone)) {
                phoneSet.add(lead.Phone);
            }
            if(lead.Match_Affiliate_Id__c != null){
                affiliateIds.add(lead.Match_Affiliate_Id__c);
            }
        }
        System.debug('>>>>>>>emailSet>>>>'+emailSet);
        System.debug('>>>>>>>phoneSet>>>>'+phoneSet);
        // Query accounts matching the emails and phones
        Map<String, Account> emailToAccountMap = new Map<String, Account>();
        Map<String, Account> phoneToAccountMap = new Map<String, Account>();
        Map<Id, Id> leadToConvertedAccountMap = new Map<Id, Id>(); // Maps lead to newly converted accounts
        Set<Id> accountIds = new Set<Id>();
        for (Account acc : [SELECT Id, Name, Phone, Email_2__c,Email__c FROM Account WHERE Affiliated_Id__c IN : affiliateIds and (Email__c IN :emailSet OR Phone IN :phoneSet OR Email_2__c IN :emailSet)]) {
            if (!String.isEmpty(acc.Email_2__c)) {
                emailToAccountMap.put(acc.Email_2__c, acc);
            }
            if (!String.isEmpty(acc.Email__c)) {
                emailToAccountMap.put(acc.Email__c, acc);
            }
            if (!String.isEmpty(acc.Phone)) {
                phoneToAccountMap.put(acc.Phone, acc);
            }
            accountIds.add(acc.Id);
        }
        Map<Id, Contact> accountToContactMap = new Map<Id, Contact>();
        for (Contact con : [SELECT Id, AccountId FROM Contact WHERE AccountId IN :accountIds]) {
            accountToContactMap.put(con.AccountId, con);
        }
        System.debug('>>>>>>>emailToAccountMap>>>>'+emailToAccountMap);
        System.debug('>>>>>>>phoneToAccountMap>>>>'+phoneToAccountMap);
        // Convert leads and create cases
        List<Database.LeadConvert> leadConversions = new List<Database.LeadConvert>();
        
        for (Lead lead : leadsToConvert) {
            Account linkedAccount = null;
            Contact relatedContact = null;
            // Find account by email or phone
            if (!String.isEmpty(lead.Email) && emailToAccountMap.containsKey(lead.Email)) {
                linkedAccount = emailToAccountMap.get(lead.Email);
            } else if (!String.isEmpty(lead.Phone) && phoneToAccountMap.containsKey(lead.Phone)) {
                linkedAccount = phoneToAccountMap.get(lead.Phone);
            }
            if (linkedAccount != null) {
                relatedContact = accountToContactMap.get(linkedAccount.Id);
            }
            System.debug('>>>>>linkedAccount>>>>>>'+linkedAccount);
            Database.LeadConvert leadConvert = new Database.LeadConvert();
            leadConvert.setLeadId(lead.Id);
            leadConvert.setConvertedStatus('Reservation Completed');
            leadConvert.setDoNotCreateOpportunity(true);
            if (linkedAccount != null) {
                leadConvert.setAccountId(linkedAccount.Id);
                if (relatedContact != null) {
                    leadConvert.setContactId(relatedContact.Id);
                }
            }
            leadConversions.add(leadConvert);
            String errorMessage = leadConversionProcess(leadConversions, leadsToConvert);
            if(errorMessage != null && errorMessage != ''){
                lead.addError(errorMessage);
            }
        }
    }
    public static String leadConversionProcess(List<Database.LeadConvert> leadConversions, List<Lead> leadsToConvert){
        Map<Id, Id> leadToConvertedAccountMap = new Map<Id, Id>();
        List<Case> casesToInsert = new List<Case>();
        List<Deposits__c> depositToInsert = new List<Deposits__c>();
        List<Timeshare__c> timesharesToInsert = new List<Timeshare__c>();
        map<String,String> mapAccountIdtoResortId = new map<String,String>();
		String errorMessage = '';
        System.debug('>>>>>>leadConversions>>>>>>>>>>'+leadConversions);
        // Perform lead conversions
        if (!leadConversions.isEmpty()) {
            List<Database.LeadConvertResult> conversionResults = Database.convertLead(leadConversions, false);
            System.debug('>>>conversionResults>>>'+conversionResults);
            // Map leads to their converted accounts
            for (Database.LeadConvertResult result : conversionResults) {
                if (result.isSuccess()) {
                    Lead convertedLead = [SELECT ConvertedAccountId,Description,FileTracker_File_Number__c,Resort_ID__c FROM Lead WHERE Id = :result.getLeadId()];
                    if (convertedLead.ConvertedAccountId != null) {
                        leadToConvertedAccountMap.put(result.getLeadId(), convertedLead.ConvertedAccountId);
                    }
                    // Parse description to extract Timeshare details
                    if (!String.isEmpty(convertedLead.Description)) {
                        Map<String, String> parsedDetails = parseDescription(convertedLead.Description);
                        System.debug('>>>>parsedDetails>>>>'+parsedDetails);
                        String ResortName = parsedDetails.get('Resort Name');
                        System.debug('>>ResortName>>'+ResortName);
						String resortVINId = convertedLead.Resort_ID__c;
						List<Resort__c> resortList = new List<Resort__c>();
                        if(resortVINId != null && resortVINId != ''){
                            resortList = [select id from Resort__c where Name =: ResortName or Vin_Id__c =: resortVINId];
                        }
                        else{
                            resortList = [select id from Resort__c where Name =: ResortName];
                        }
                        if(resortList!= null && resortList.size() > 0){
                            String resortId = resortList[0].Id;
                            mapAccountIdtoResortId.put(convertedLead.ConvertedAccountId,resortId);
                            // Create a Timeshare record
                            system.debug('>>>parsedDetails>>>'+parsedDetails);
                            // List<String> listBedrooms = new List<String>{'2','3','4','5','6'};
                            Timeshare__c newTimeshare = new Timeshare__c(
                                Name = parsedDetails.get('Resort Name'),
                                Timeshare_Owner__c = convertedLead.ConvertedAccountId,
                                Resort__c = resortId,
                                Usage_Fee__c = (parsedDetails.get('Usage') != null && parsedDetails.get('Usage') != '') ? Decimal.ValueOf(parsedDetails.get('Usage')): 0,
                                Week__c = (parsedDetails.get('Week')!= null && parsedDetails.get('Week')!= '') ? parsedDetails.get('Week') : '',
                                Amount_of_Points__c = (parsedDetails.get('Points') != null && parsedDetails.get('Points') != '')? Decimal.valueOf(parsedDetails.get('Points')) : 0,
                                Property_Grade__c = (parsedDetails.get('Grade') != null && parsedDetails.get('Grade')!= '')? parsedDetails.get('Grade'): '',
                                Bathrooms__c = (parsedDetails.get('Bathrooms') != null && parsedDetails.get('Bathrooms')!= '')? parsedDetails.get('Bathrooms'): '',
                                Unit_Size__c = (parsedDetails.get('Bedrooms')!= null && parsedDetails.get('Bedrooms') != '')? (parsedDetails.get('Bedrooms')+' Bedroom'):''
                                //Unit_Size__c = ((parsedDetails.get('Bedrooms')!= null && parsedDetails.get('Bedrooms') != '')? (parsedDetails.get('Bedrooms') == '1'? (parsedDetails.get('Bedrooms')+' Bedroom'): (listBedrooms.contains(parsedDetails.get('Bedrooms'))?(parsedDetails.get('Bedrooms')+' Bedrooms'):parsedDetails.get('Bedrooms'))): '')
                            );
                            
                            timesharesToInsert.add(newTimeshare);
                        }
                        else{
                            errorMessage = 'The resort name or ID is not available in our system. Please contact the administrator.'; 
							
                        }
                    }
                }
            }
        }
        System.debug('>>>>>timesharesToInsert>>>>>'+timesharesToInsert);
        if (!timesharesToInsert.isEmpty()) {
            insert timesharesToInsert;
            //}
            map<String,Timeshare__c> mapAccountIdtoTimeshareId = new map<String,Timeshare__c>();
            
            for(Timeshare__c objtimeshare : timesharesToInsert){
                mapAccountIdtoTimeshareId.put(objtimeshare.Timeshare_Owner__c, objtimeshare); 
            }
            Id fileTrackerRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('File_Tracker').getRecordTypeId(); 
            // Create cases for converted accounts
            for (Lead lead : leadsToConvert) {
                Id accountId = leadToConvertedAccountMap.get(lead.Id);
                if (accountId != null) {
                    Case newCase = new Case(
                        AccountId = accountId,
                        Ownership_Resort_Timeshare__c = mapAccountIdtoTimeshareId.get(accountId).Id,
                        Subject = 'File Tracker Case',
                        Description = 'This case was automatically created upon File Tracker lead conversion.',
                        RecordTypeId = fileTrackerRecTypeId,
                        Status = 'New',
                        Exchange_Type__c = 'File Tracker'
                    );
                    casesToInsert.add(newCase);  
                }
            }
            System.debug('>>>>>casesToInsert>>>>>'+casesToInsert);
            if (!casesToInsert.isEmpty()) {
                insert casesToInsert;
            }
            map<String,String> mapAccountIdtoCaseId = new map<String,String>();
            for(Case objcase : casesToInsert){
                mapAccountIdtoCaseId.put(objcase.AccountId, objcase.Id); 
            }
            for (Lead lead : leadsToConvert) {//(bathroom == 'Varies' ? 'Varies' : '')
                Id accountId = leadToConvertedAccountMap.get(lead.Id);
                if (accountId != null) {
                    String bathroom = mapAccountIdtoTimeshareId.get(accountId).Bathrooms__c;
                    Deposits__c newdeposit = new Deposits__c(
                        Account_Name__c = accountId,
                        Resort_Id__c = mapAccountIdtoResortId.get(accountId),
                        Case__c = mapAccountIdtoCaseId.get(accountId),
                        Lead__c = lead.Id,
                        Bathrooms__c = ((bathroom!= '' && bathroom != null && bathroom != 'Varies' && Integer.valueOf(bathroom) != 0) ?(Integer.valueOf(bathroom) > 1 ? bathroom +' Bathrooms' : bathroom +' Bathroom'):''),
                        Unit_Size__c = mapAccountIdtoTimeshareId.get(accountId).Unit_Size__c,
                        Weeks__c = mapAccountIdtoTimeshareId.get(accountId).Week__c,
                        Status__c = 'Draft',
                        Check_Out__c = System.today(),
                        Check_in_Date__c = System.today(),
                        Maint_Fees__c = 0,
                        Occupancy__c = 0,
                        file_tracker_number__c = lead.FileTracker_File_Number__c,
                        CaseType__c = 'FileTracker',
                        Deposit_Type__c = 'Regular'
                        
                    );
                    depositToInsert.add(newdeposit);  
                }
            }
            System.debug('>>>>>casesToInsert>>>>>'+depositToInsert);
            if (!depositToInsert.isEmpty()) {
                insert depositToInsert;
            }
        }
		return errorMessage;
    }
    // Helper method to parse the description field
    public static Map<String, String> parseDescription(String description) {
        Map<String, String> detailsMap = new Map<String, String>();
        
        // Regular expression to correctly extract key-value pairs
        Pattern pattern = Pattern.compile('([\\w\\s]+):\\s*([^:]+)(?=(,\\s*[\\w\\s]+:|$))');
        Matcher matcher = pattern.matcher(description);
        
        while (matcher.find()) {
            String key = matcher.group(1).trim();   // Extract key
            String value = matcher.group(2).trim(); // Extract value (handles commas inside values)
            
            detailsMap.put(key, value);
        }
        
        return detailsMap;
    }
    
    
}