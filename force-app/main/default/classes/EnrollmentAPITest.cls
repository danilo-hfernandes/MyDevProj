@isTest
public class EnrollmentAPITest {
    @isTest static void callAPITest(){
        
        
        HSI_Enrollment_Queue__c callbatch = New HSI_Enrollment_Queue__c();
        
        
        callbatch.Member_Number__c = 'mem123';
        callbatch.First_Name__c = 'te123';
        callbatch.Last_Name__c = 'es3';
        callbatch.Email__c = 'a@abc.com';
        callbatch.Primary_Phone__c = '1234567890';
        callbatch.Address__c = 'tet address';
        callbatch.City__c = 'ciyt';
        callbatch.Zip_Code__c = '12345';
        callbatch.State__c = 'FL';
        callbatch.Country__c = 'UnitedStates';
        callbatch.Created_By__c = 'VI Referral Form';
        insert callbatch;
        list<HSI_Enrollment_Queue__c> hsi = New List<HSI_Enrollment_Queue__c>();
        hsi.add(callbatch);
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        EnrollmentAPI enr = New EnrollmentAPI();
        enr.senddata(hsi);      
        
        //requestdataWrapper req = New requestdataWrapper();
        /*req.tierLevel = 'VIR';

req.memberNumber = 'mem123';
req.firstName = 'te123';
req.lastName = 'es3';
req.emailAddress = 'a@abc.com';
req.phoneNumber = '1234567890';
req.address = 'tet address';
req.city = 'ciyt';
req.postalCode = '12345';
req.stateCode = 'FL';
req.countryCode = 'UnitedStates';
req.RenewableYears = 1;
req.AdvantageWeeksAllocated = 1;*/
        
    }
    
    @isTest static void callAPITest2(){
        
        
        HSI_Enrollment_Queue__c callbatch = New HSI_Enrollment_Queue__c();
        
        
        callbatch.Member_Number__c = 'mem123';
        callbatch.First_Name__c = 'te123';
        callbatch.Last_Name__c = 'es3';
        callbatch.Email__c = 'a@abc.com';
        callbatch.Primary_Phone__c = '1234567890';
        callbatch.Address__c = 'tet address';
        callbatch.City__c = 'ciyt';
        callbatch.Zip_Code__c = '12345';
        callbatch.State__c = 'FL';
        callbatch.Country__c = 'UnitedStates';
        callbatch.Created_By__c = 'RR Flex Date Checkout';
        insert callbatch;
        list<HSI_Enrollment_Queue__c> hsi = New List<HSI_Enrollment_Queue__c>();
        hsi.add(callbatch);
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        EnrollmentAPI enr = New EnrollmentAPI();
        enr.senddata(hsi);
        
    }
    @isTest static void callAPITest3(){
        
        
        HSI_Enrollment_Queue__c callbatch = New HSI_Enrollment_Queue__c();
        
        
        callbatch.Member_Number__c = 'mem123';
        callbatch.First_Name__c = 'te123';
        callbatch.Last_Name__c = 'es3';
        callbatch.Email__c = 'a@abc.com';
        callbatch.Primary_Phone__c = '1234567890';
        callbatch.Address__c = 'tet address';
        callbatch.City__c = 'ciyt';
        callbatch.Zip_Code__c = '12345';
        callbatch.State__c = 'FL';
        callbatch.Country__c = 'UnitedStates';
        callbatch.Created_By__c = 'SMTN Survey';
        insert callbatch;
        list<HSI_Enrollment_Queue__c> hsi = New List<HSI_Enrollment_Queue__c>();
        hsi.add(callbatch);
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        EnrollmentAPI enr = New EnrollmentAPI();
        enr.senddata(hsi);
        
    }
    @isTest static void callAPITest4(){
        
        
        HSI_Enrollment_Queue__c callbatch = New HSI_Enrollment_Queue__c();
        
        
        callbatch.Member_Number__c = 'mem123';
        callbatch.First_Name__c = 'te123';
        callbatch.Last_Name__c = 'es3';
        callbatch.Email__c = 'a@abc.com';
        callbatch.Primary_Phone__c = '1234567890';
        callbatch.Address__c = 'tet address';
        callbatch.City__c = 'ciyt';
        callbatch.Zip_Code__c = '12345';
        callbatch.State__c = 'FL';
        callbatch.Country__c = 'UnitedStates';
        callbatch.Created_By__c = 'Carefree Destinations';
        insert callbatch;
        list<HSI_Enrollment_Queue__c> hsi = New List<HSI_Enrollment_Queue__c>();
        hsi.add(callbatch);
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        EnrollmentAPI enr = New EnrollmentAPI();
        enr.senddata(hsi);
        
    }
    @isTest static void callAPITest5(){
        
        
        HSI_Enrollment_Queue__c callbatch = New HSI_Enrollment_Queue__c();
        
        
        callbatch.Member_Number__c = 'mem123';
        callbatch.First_Name__c = 'te123';
        callbatch.Last_Name__c = 'es3';
        callbatch.Email__c = 'a@abc.com';
        callbatch.Primary_Phone__c = '1234567890';
        callbatch.Address__c = 'tet address';
        callbatch.City__c = 'ciyt';
        callbatch.Zip_Code__c = '12345';
        callbatch.State__c = 'FL';
        callbatch.Country__c = 'UnitedStates';
        callbatch.Created_By__c = 'SMTN Mexico';
        insert callbatch;
        list<HSI_Enrollment_Queue__c> hsi = New List<HSI_Enrollment_Queue__c>();
        hsi.add(callbatch);
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        EnrollmentAPI enr = New EnrollmentAPI();
        enr.senddata(hsi);
        
    }
    @isTest static void callAPITest6(){
        
        
        HSI_Enrollment_Queue__c callbatch = New HSI_Enrollment_Queue__c();
        
        
        callbatch.Member_Number__c = 'mem123';
        callbatch.First_Name__c = 'te123';
        callbatch.Last_Name__c = 'es3';
        callbatch.Email__c = 'a@abc.com';
        callbatch.Primary_Phone__c = '1234567890';
        callbatch.Address__c = 'tet address';
        callbatch.City__c = 'ciyt';
        callbatch.Zip_Code__c = '12345';
        callbatch.State__c = 'FL';
        callbatch.Country__c = 'UnitedStates';
        callbatch.Created_By__c = 'Think Direct';
        insert callbatch;
        list<HSI_Enrollment_Queue__c> hsi = New List<HSI_Enrollment_Queue__c>();
        hsi.add(callbatch);
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        EnrollmentAPI enr = New EnrollmentAPI();
        enr.senddata(hsi);
        
    }
    @isTest static void callAPITest7(){
        
        
        HSI_Enrollment_Queue__c callbatch = New HSI_Enrollment_Queue__c();
        
        
        callbatch.Member_Number__c = 'mem123';
        callbatch.First_Name__c = 'te123';
        callbatch.Last_Name__c = 'es3';
        callbatch.Email__c = 'a@abc.com';
        callbatch.Primary_Phone__c = '1234567890';
        callbatch.Address__c = 'tet address';
        callbatch.City__c = 'ciyt';
        callbatch.Zip_Code__c = '12345';
        callbatch.State__c = 'FL';
        callbatch.Country__c = 'UnitedStates';
        callbatch.Created_By__c = 'Vacation VIP';
        insert callbatch;
        list<HSI_Enrollment_Queue__c> hsi = New List<HSI_Enrollment_Queue__c>();
        hsi.add(callbatch);
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        EnrollmentAPI enr = New EnrollmentAPI();
        enr.senddata(hsi);
        
    }
    @isTest static void callAPITest8(){
        
        
        HSI_Enrollment_Queue__c callbatch = New HSI_Enrollment_Queue__c();
        
        
        callbatch.Member_Number__c = 'mem123';
        callbatch.First_Name__c = 'te123';
        callbatch.Last_Name__c = 'es3';
        callbatch.Email__c = 'a@abc.com';
        callbatch.Primary_Phone__c = '1234567890';
        callbatch.Address__c = 'tet address';
        callbatch.City__c = 'ciyt';
        callbatch.Zip_Code__c = '12345';
        callbatch.State__c = 'FL';
        callbatch.Country__c = 'UnitedStates';
        callbatch.Created_By__c = 'Vidanta Converter';
        callbatch.Record_Origin__c = 'Vidanta Converter';
        insert callbatch;
        list<HSI_Enrollment_Queue__c> hsi = New List<HSI_Enrollment_Queue__c>();
        hsi.add(callbatch);
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        EnrollmentAPI enr = New EnrollmentAPI();
        enr.senddata(hsi);
        
    }
    @isTest static void callAPITest9(){
        
        
        HSI_Enrollment_Queue__c callbatch = New HSI_Enrollment_Queue__c();
        
        
        callbatch.Member_Number__c = 'mem123';
        callbatch.First_Name__c = 'te123';
        callbatch.Last_Name__c = 'es3';
        callbatch.Email__c = 'a@abc.com';
        callbatch.Primary_Phone__c = '1234567890';
        callbatch.Address__c = 'tet address';
        callbatch.City__c = 'ciyt';
        callbatch.Zip_Code__c = '12345';
        callbatch.State__c = 'FL';
        callbatch.Country__c = 'UnitedStates';
        callbatch.Created_By__c = 'SF Enrollment Queue';
        callbatch.Record_Origin__c = 'SF Leads';
        insert callbatch;
        list<HSI_Enrollment_Queue__c> hsi = New List<HSI_Enrollment_Queue__c>();
        hsi.add(callbatch);
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        EnrollmentAPI enr = New EnrollmentAPI();
        enr.senddata(hsi);
        
    }
    @isTest static void callAPITest10(){
        HSI_Enrollment_Queue__c callbatch = New HSI_Enrollment_Queue__c();
        
        callbatch.Member_Number__c = 'mem123';
        callbatch.First_Name__c = 'te123';
        callbatch.Last_Name__c = 'es3';
        callbatch.Email__c = 'a@abc.com';
        callbatch.Primary_Phone__c = '1234567890';
        callbatch.Address__c = 'tet address';
        callbatch.City__c = 'ciyt';
        callbatch.Zip_Code__c = '12345';
        callbatch.State__c = 'FL';
        callbatch.Country__c = 'UnitedStates';
        callbatch.Created_By__c = 'CoolVacay Plus';
        callbatch.Record_Origin__c = 'CoolVacay Plus';
        insert callbatch;
        list<HSI_Enrollment_Queue__c> hsi = New List<HSI_Enrollment_Queue__c>();
        hsi.add(callbatch);
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        EnrollmentAPI enr = New EnrollmentAPI();
        enr.senddata(hsi);
        
    }
        @isTest static void callAPITest11(){
        HSI_Enrollment_Queue__c callbatch = New HSI_Enrollment_Queue__c();
        
        callbatch.Member_Number__c = 'mem123';
        callbatch.First_Name__c = 'te123';
        callbatch.Last_Name__c = 'es3';
        callbatch.Email__c = 'a@abc.com';
        callbatch.Primary_Phone__c = '1234567890';
        callbatch.Address__c = 'tet address';
        callbatch.City__c = 'ciyt';
        callbatch.Zip_Code__c = '12345';
        callbatch.State__c = 'FL';
        callbatch.Country__c = 'UnitedStates';
        callbatch.Created_By__c = 'LuxGive Guest';
        callbatch.Record_Origin__c = 'LuxGive Guest';
        insert callbatch;
        list<HSI_Enrollment_Queue__c> hsi = New List<HSI_Enrollment_Queue__c>();
        hsi.add(callbatch);
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        EnrollmentAPI enr = New EnrollmentAPI();
        enr.senddata(hsi);
        
    }
    
     @isTest static void callAPITest12(){
        
        
        HSI_Enrollment_Queue__c callbatch = New HSI_Enrollment_Queue__c();
        
        
        callbatch.Member_Number__c = 'AP-CGEVWT-mem123';
        callbatch.First_Name__c = 'te123';
        callbatch.Last_Name__c = 'es3';
        callbatch.Email__c = 'a@abc.com';
        callbatch.Primary_Phone__c = '1234567890';
        callbatch.Address__c = 'tet address';
        callbatch.City__c = 'ciyt';
        callbatch.Zip_Code__c = '12345';
        callbatch.State__c = 'FL';
        callbatch.Country__c = 'UnitedStates';
        callbatch.Created_By__c = 'Club Global Explorer VW - Trial';
        callbatch.Record_Origin__c = 'Club Global Explorer VW - Trial';
        insert callbatch;
        list<HSI_Enrollment_Queue__c> hsi = New List<HSI_Enrollment_Queue__c>();
        hsi.add(callbatch);
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        EnrollmentAPI enr = New EnrollmentAPI();
        enr.senddata(hsi);
        
    }
    
         @isTest static void callAPITest13(){
        
        
        HSI_Enrollment_Queue__c callbatch = New HSI_Enrollment_Queue__c();
        
        
        callbatch.Member_Number__c = 'AP-CGEVW-mem123';
        callbatch.First_Name__c = 'te123';
        callbatch.Last_Name__c = 'es3';
        callbatch.Email__c = 'a@abc.com';
        callbatch.Primary_Phone__c = '1234567890';
        callbatch.Address__c = 'tet address';
        callbatch.City__c = 'ciyt';
        callbatch.Zip_Code__c = '12345';
        callbatch.State__c = 'FL';
        callbatch.Country__c = 'UnitedStates';
        callbatch.Created_By__c = 'Club Global Explorer VW';
        callbatch.Record_Origin__c = 'Club Global Explorer VW';
        insert callbatch;
        list<HSI_Enrollment_Queue__c> hsi = New List<HSI_Enrollment_Queue__c>();
        hsi.add(callbatch);
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        EnrollmentAPI enr = New EnrollmentAPI();
        enr.senddata(hsi);
        
    }
    
        @isTest static void callAPITest14(){
        
        
        HSI_Enrollment_Queue__c callbatch = New HSI_Enrollment_Queue__c();
        
        
        callbatch.Member_Number__c = 'AP-IRW-mem123';
        callbatch.First_Name__c = 'te123';
        callbatch.Last_Name__c = 'es3';
        callbatch.Email__c = 'a@abc.com';
        callbatch.Primary_Phone__c = '1234567890';
        callbatch.Address__c = 'tet address';
        callbatch.City__c = 'ciyt';
        callbatch.Zip_Code__c = '12345';
        callbatch.State__c = 'FL';
        callbatch.Country__c = 'UnitedStates';
        callbatch.Created_By__c = 'Inspira Resort Week';
        callbatch.Record_Origin__c = 'Inspira Resort Week';
        insert callbatch;
        list<HSI_Enrollment_Queue__c> hsi = New List<HSI_Enrollment_Queue__c>();
        hsi.add(callbatch);
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        EnrollmentAPI enr = New EnrollmentAPI();
        enr.senddata(hsi);
        
    }
    
        @isTest static void callAPITest15(){
        
        
        HSI_Enrollment_Queue__c callbatch = New HSI_Enrollment_Queue__c();
        
        
        callbatch.Member_Number__c = 'AP-FT-mem123';
        callbatch.First_Name__c = 'te123';
        callbatch.Last_Name__c = 'es3';
        callbatch.Email__c = 'a@abc.com';
        callbatch.Primary_Phone__c = '1234567890';
        callbatch.Address__c = 'tet address';
        callbatch.City__c = 'ciyt';
        callbatch.Zip_Code__c = '12345';
        callbatch.State__c = 'FL';
        callbatch.Country__c = 'UnitedStates';
        callbatch.Created_By__c = 'Filetracker';
        callbatch.Record_Origin__c = 'Filetracker';
        insert callbatch;
        list<HSI_Enrollment_Queue__c> hsi = New List<HSI_Enrollment_Queue__c>();
        hsi.add(callbatch);
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        EnrollmentAPI enr = New EnrollmentAPI();
        enr.senddata(hsi);
        
    }
    
    @isTest static void callAPITest16(){
        
        
        HSI_Enrollment_Queue__c callbatch = New HSI_Enrollment_Queue__c();
        
        
        callbatch.Member_Number__c = 'AP-RAG-mem123';
        callbatch.First_Name__c = 'te123';
        callbatch.Last_Name__c = 'es3';
        callbatch.Email__c = 'a@abc.com';
        callbatch.Primary_Phone__c = '1234567890';
        callbatch.Address__c = 'tet address';
        callbatch.City__c = 'ciyt';
        callbatch.Zip_Code__c = '12345';
        callbatch.State__c = 'FL';
        callbatch.Country__c = 'UnitedStates';
        callbatch.Created_By__c = 'Raise Away Guest';
        callbatch.Record_Origin__c = 'Raise Away Guest';
        insert callbatch;
        list<HSI_Enrollment_Queue__c> hsi = New List<HSI_Enrollment_Queue__c>();
        hsi.add(callbatch);
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        EnrollmentAPI enr = New EnrollmentAPI();
        enr.senddata(hsi);
        
    }
    
 
    @isTest static void callAPITest17(){
        
        
        HSI_Enrollment_Queue__c callbatch = New HSI_Enrollment_Queue__c();
        
        
        callbatch.Member_Number__c = 'AP-EGG-mem123';
        callbatch.First_Name__c = 'te123';
        callbatch.Last_Name__c = 'es3';
        callbatch.Email__c = 'a@abc.com';
        callbatch.Primary_Phone__c = '1234567890';
        callbatch.Address__c = 'tet address';
        callbatch.City__c = 'ciyt';
        callbatch.Zip_Code__c = '12345';
        callbatch.State__c = 'FL';
        callbatch.Country__c = 'UnitedStates';
        callbatch.Created_By__c = 'Engaged Good Guest';
        callbatch.Record_Origin__c = 'Engaged Good Guest';
        insert callbatch;
        list<HSI_Enrollment_Queue__c> hsi = New List<HSI_Enrollment_Queue__c>();
        hsi.add(callbatch);
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        EnrollmentAPI enr = New EnrollmentAPI();
        enr.senddata(hsi);
        
    }
    
    @isTest static void callAPITest18(){
        
        
        HSI_Enrollment_Queue__c callbatch = New HSI_Enrollment_Queue__c();
        
        
        callbatch.Member_Number__c = 'AP-EGG-mem123';
        callbatch.First_Name__c = 'te123';
        callbatch.Last_Name__c = 'es3';
        callbatch.Email__c = 'a@abc.com';
        callbatch.Primary_Phone__c = '1234567890';
        callbatch.Address__c = 'tet address';
        callbatch.City__c = 'ciyt';
        callbatch.Zip_Code__c = '12345';
        callbatch.State__c = 'FL';
        callbatch.Country__c = 'UnitedStates';
        callbatch.Created_By__c = 'Engaged Good Guest';
        callbatch.Record_Origin__c = 'Engaged Good Guest';
        callbatch.Failure_Count__c = 3;
        insert callbatch;
        list<HSI_Enrollment_Queue__c> hsi = New List<HSI_Enrollment_Queue__c>();
        hsi.add(callbatch);
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        EnrollmentAPI enr = New EnrollmentAPI();
        enr.senddata(hsi);
        
    }
                    
    public class MockHttpResponseGenerator implements HttpCalloutMock 
    {
        public HTTPResponse respond(HTTPRequest req) 
        {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            String str = '{"tierLevel": "VIR","contractNumber": "5","memberNumber": "AP-VIR-5","firstName": "TestFirst","lastName": "TestLastName","emailAddress": "test@test.com"';
            str = str + ',"phoneNumber": "1234567890","address": "1252 Some Random Street","city": "Orlando","postalCode": "32555","stateCode": "FL","countryCode": "United States","RenewableYears": 1,"AdvantageWeeksAllocated": 1,"languagePreferred": {"code": "ENG","name": "ENGLISH"}}';
            res.setBody(str);
            res.setStatusCode(200);
            return res;
        }
    }
}