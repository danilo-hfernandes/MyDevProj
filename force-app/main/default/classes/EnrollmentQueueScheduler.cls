global class EnrollmentQueueScheduler Implements Schedulable, Database.AllowsCallouts {
    global void execute(SchedulableContext ctx) {
        
        callapi();
        // Create a task for each opportunity in the list
        //TaskUtils.remindOwners(opptys);
        callhsiEnrollupdate();
    
}
     @Future(callout=true)
     public static void callapi(){
         List<HSI_Enrollment_Queue__c> enrollList = New List<HSI_Enrollment_Queue__c>();

         enrollList = [Select Id,Member_Number__c,First_Name__c,Last_Name__c,Email__c,Primary_Phone__c,Address__c,City__c,Zip_Code__c,State__c,Country__c, Record_Origin__c,
                      Processed_On__c,Successful_Processed__c,Created_By__c,Failure_Count__c,Update_Account__c,name__c,code__c,Auto_Id__c,First_Response_Log__c from HSI_Enrollment_Queue__c where
                     Processed_On__c = Null AND Successful_Processed__c = False AND
                     (Record_Origin__c = 'Vidanta Converter' OR Record_Origin__c = 'HC Self Enrollment' OR Created_By__c = 'VI Referral Form' OR Created_By__c = 'RR Flex Date Checkout' OR Created_By__c = 'SMTN Survey' OR Created_By__c = 'Carefree Destinations Affiliate Marketing MX Voucher' OR Created_By__c = 'Advantage Getaway Voucher'
                      OR Created_By__c = 'Carefree Destinations'  OR Created_By__c = 'Filetracker' OR Created_By__c = 'SMTN Mexico' OR Created_By__c = 'Future Stay' OR Created_By__c = 'Lead Conversion' OR Created_By__c = 'Vacation VIP' OR Created_By__c = 'SF Enrollment Queue' OR Created_By__c = 'Advantage Services Affiliate Marketing' OR Created_By__c = 'CoolVacay Plus' OR Created_By__c = 'LuxGive Guest' OR Created_By__c = 'Inspira Resort Week' OR  Created_By__c = 'Club Global Explorer VW - Trial' OR  Created_By__c = 'Club Global Explorer VW' OR  Created_By__c = 'Club Venture - Ruby' OR  Created_By__c = 'Club Venture - Guest' OR  Created_By__c = 'Club Venture - Emerald' OR  Created_By__c = 'Club Venture - Sapphire' OR Created_By__c = 'Raise Away Guest' OR Created_By__c = 'Engaged Good Guest' OR Created_By__c = 'Raise Away Voucher' OR Created_By__c = 'One Agency Bulk Voucher Sheet')
                     AND Failure_Count__c <=3 AND Member_Number__c IN ('AP-CFD-15982', 'AP-CGVW-15934', 'AP-CGVWT-15933', 'AP-AMMX-15833', 'AP-ABW-15813') ORDER BY Failure_Count__c ASC limit 50];
        
         // This is testing SOQL
        /* enrollList = [Select Id,Member_Number__c,First_Name__c,Last_Name__c,Email__c,Primary_Phone__c,Address__c,City__c,Zip_Code__c,State__c,Country__c,Record_Origin__c, 
                      Processed_On__c,Successful_Processed__c,Created_By__c,Failure_Count__c,Update_Account__c,name__c,code__c,Auto_Id__c from HSI_Enrollment_Queue__c where
                     Processed_On__c = Null AND Successful_Processed__c = False AND Created_By__c = 'Carefree Destinations Affiliate Marketing MX Voucher'];*/
        
        system.debug('--enrollList--'+enrollList.size());
        if(enrollList.size() > 0 && enrollList != null){
            EnrollmentAPI enrollment = New EnrollmentAPI();
            enrollment.senddata(enrollList);
        }
     }
    
    public void callhsiEnrollupdate(){
        List<HSI_Enrollment_Queue__c> enrollList = New List<HSI_Enrollment_Queue__c>();
        enrollList = [Select Id,Member_Number__c,First_Name__c,Last_Name__c,Email__c,Primary_Phone__c,Address__c,City__c,Zip_Code__c,State__c,Country__c, 
                      Processed_On__c,Successful_Processed__c,Created_By__c,Failure_Count__c,Notify_Business__c,Auto_Id__c from HSI_Enrollment_Queue__c where
                     Processed_On__c = Null AND Failure_Count__c >3];
        
        if(enrollList.size() > 0 && enrollList != null){
            for(HSI_Enrollment_Queue__c updaterec : enrollList){
                updaterec.Successful_Processed__c = False;
                updaterec.Processed_On__c = Date.today();
                updaterec.Notify_Business__c = true;
            }
            update enrollList;
        }
        
    }

}