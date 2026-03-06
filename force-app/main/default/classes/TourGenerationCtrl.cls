@RestResource(urlMapping='/TourGeneration/*')
global class TourGenerationCtrl{

    private static final String SUCCESS = 'Success';
    private static final String ERROR = 'Error';
    
    @Httppost
    global static ResponseWrapper createAccountRecord(){
        
        ResponseWrapper response = new ResponseWrapper();
        
        RestRequest req = RestContext.request;

        try {
            Map<String,Object> receivedData = (Map<String,Object>)JSON.deserializeUntyped(req.requestBody.toString());
            system.debug('--receivedData--'+receivedData);
            String firstName = receivedData.containsKey('FirstName') ? String.valueOf(receivedData.get('FirstName')) : '';
            String lastName = receivedData.containsKey('LastName') ? String.valueOf(receivedData.get('LastName')) : '';
            String email = receivedData.containsKey('Email') ? String.valueOf(receivedData.get('Email')) : '';
            String mainPhone = receivedData.containsKey('MainPhone') ? String.valueOf(receivedData.get('MainPhone')) : '';
            String alternatePhone1 = receivedData.containsKey('AlternatePhone1') ? String.valueOf(receivedData.get('AlternatePhone1')) : '';
            String alternatePhone2 = receivedData.containsKey('AlternatePhone2') ? String.valueOf(receivedData.get('AlternatePhone2')) : '';
            String address = receivedData.containsKey('Address') ? String.valueOf(receivedData.get('Address')) : '';
            String city = receivedData.containsKey('City') ? String.valueOf(receivedData.get('City')) : '';
            String state = receivedData.containsKey('State') ? String.valueOf(receivedData.get('State')) : '';
            String country = receivedData.containsKey('Country') ? String.valueOf(receivedData.get('Country')) : '';
            String zip = receivedData.containsKey('Zip') ? String.valueOf(receivedData.get('Zip')) : '';
            
            if(firstName != '' && lastName != '' && email != '' && mainPhone != '' && address != '' && city != '' && state != '' && country != '' && zip != ''){
                List<Account> accList = [Select Id From Account where Email__c =: email or Phone =: mainPhone];
                if(!accList.isEmpty()){
                    response.status = ERROR;
                    response.errorMessage = 'Member already exists and is not eligible for the promotion.';
                }else{
                    
                    HSI_Enrollment_Queue__c enrollmentRec = new HSI_Enrollment_Queue__c();
                    enrollmentRec.First_Name__c = firstName;
                    enrollmentRec.Last_Name__c = lastName;
                    enrollmentRec.Email__c = email;
                    enrollmentRec.Primary_Phone__c = mainPhone;
                    enrollmentRec.Alternate_Phone__c = alternatePhone1;
                    enrollmentRec.Address__c = address;
                    enrollmentRec.City__c = city;
                    enrollmentRec.State__c = state;
                    enrollmentRec.Country__c = country;
                    enrollmentRec.Zip_Code__c = zip;
                    enrollmentRec.Record_Origin__c = 'SMTN Survey';
                    enrollmentRec.Created_By__c = 'SMTN Survey';
                    insert enrollmentRec;
                    
                    HSI_Enrollment_Queue__c insertedEnrollmentRecord = [Select Id,Auto_Id__c from HSI_Enrollment_Queue__c where Id =: enrollmentRec.Id];
                    
                    //return membernumber for success
                    Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Advantage_Program_Inc_Holiday_Systems').getRecordTypeId();
                    Account acc = new Account();
                    acc.RecordTypeId = accRecordTypeId;
                    acc.First_Name__c = firstName;
                    acc.Last_Name__c = lastName;
                    acc.Name = firstName +' '+ lastName;
                    acc.Email__c = email;
                    acc.Phone = mainPhone;
                    acc.Alternate_Phone_1__c = alternatePhone1;
                    acc.Alternate_Phone_2__c = alternatePhone2;
                    acc.BillingStreet = address;
                    acc.BillingCity = city;
                    acc.BillingState = state;
                    acc.BillingCountry = country;
                    acc.BillingPostalCode = zip;
                    acc.Member_Number__c = 'AP-TGS-' + insertedEnrollmentRecord.Auto_Id__c;
                    acc.Affiliate_Name__c = 'Tour Gen Survey';
                    acc.Affiliated_Id__c = 1002268;
                    insert acc;
                    
                    Id conRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Advantage_Program_Inc_Holiday_Systems').getRecordTypeId();
                    Contact con = new Contact();
                    con.RecordTypeId = conRecordTypeId;
                    con.AccountId = acc.Id;
                    con.FirstName = firstName;
                    con.LastName = lastName;
                    con.Email = email;
                    con.Phone = mainPhone;
                    con.Alternate_Phone_1__c = alternatePhone1;
                    con.Alternate_Phone_2__c = alternatePhone2;
                    con.MailingStreet = address;
                    con.MailingCity = city;
                    con.MailingState = state;
                    con.MailingCountry = country;
                    con.MailingPostalCode = zip;
                    con.Affiliate_Name__c = 'Tour Gen Survey';
                    con.AffiliatedId__c = 1002268;
                    insert con;
                    
                    insertedEnrollmentRecord.AccountId__c = acc.Id;
                    insertedEnrollmentRecord.Member_Number__c = 'AP-TGS-' + insertedEnrollmentRecord.Auto_Id__c;
                    update insertedEnrollmentRecord;
                    
                    response.status = SUCCESS;
                    response.memberNumber = insertedEnrollmentRecord.Member_Number__c;
                }
            }else{
                response.status = ERROR;
                response.errorMessage = 'Mandatory fields are missing.';
            }
            
            
        } catch (Exception ex){
            response.status = ERROR;
            response.errorMessage = 'Message:' + ex.getMessage()  + ' - Exception occurrred on LineNumber: ' + ex.getLineNumber();
        }
        return response;   
    }
    global class ResponseWrapper{
        webservice String status; 
        webservice String errorMessage;
        webservice string memberNumber;
    }
}