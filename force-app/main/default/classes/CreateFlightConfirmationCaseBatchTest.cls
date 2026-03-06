@isTest 
public class CreateFlightConfirmationCaseBatchTest 
{
    static testMethod void testMethod1() 
    {
         Id oppRecordTypeId = [Select id from RecordType where sObjectType = 'Opportunity' and developerName ='Profit_Agility_Voucher' ].id ;
       
        Account a = new Account();
        a.Name = 'test account';
        a.Member_Number__c = '142519-support@monsterrg.com';
        insert a;
        
        Opportunity o = new Opportunity();
        o.name = 'test opp';
        o.CloseDate = System.today();
        o.AccountId = a.id;
        o.Opportunity_Closed_Date__c = DateTime.now() - 1;
        o.RecordTypeId = oppRecordTypeId;
        o.VI_Referral_Comments__c = 'testing';
        o.Flight_Confirmation_Case_Created__c = false;
        o.Check_in__c = Date.today() + 3;
        o.First_Payment_Made__c = True;
        o.StageName = 'Closed Won';
        o.Reservation_Status__c = 'Confirmed';
        o.Member_Number__c = '142519-support@monsterrg.com';
        insert o; 
        
        
        Opportunity om = new Opportunity();
        om.name = 'test opp';
        om.CloseDate = System.today();
        om.AccountId = a.id;
        om.Opportunity_Closed_Date__c = DateTime.now() - 1;
        om.RecordTypeId = oppRecordTypeId;
        om.VI_Referral_Comments__c = 'testing';
        om.Flight_Confirmation_Case_Created__c = false;
        om.Check_in__c = Date.today() + 40;
        om.First_Payment_Made__c = True;
        om.StageName = 'Closed Won';
        om.Reservation_Status__c = 'Confirmed';
        om.Member_Number__c = 'test-142519-support@monsterrg.com';
        insert om; 
        
        
        Opportunity o1 = new Opportunity();
        o1.name = 'test opp';
        o1.CloseDate = System.today();
        o1.AccountId = a.id;
        o1.Opportunity_Closed_Date__c = DateTime.now() - 1;
        o1.RecordTypeId = [Select id from RecordType where sObjectType = 'Opportunity' and developerName ='Voucher' ].id ;
        o1.VI_Referral_Comments__c = 'testing';
        o1.Flight_Confirmation_Case_Created__c = false;
        o1.Check_in__c = Date.today() + 3;
        o1.First_Payment_Made__c = True;
        o1.StageName = 'Closed Won';
        o1.Reservation_Status__c = 'Confirmed';
        
        insert o1; 


        Opportunity om1 = new Opportunity();
        om1.name = 'test opp';
        om1.CloseDate = System.today();
        om1.AccountId = a.id;
        om1.Opportunity_Closed_Date__c = DateTime.now() - 1;
        om1.RecordTypeId = [Select id from RecordType where sObjectType = 'Opportunity' and developerName ='Voucher' ].id ;
        om1.VI_Referral_Comments__c = 'testing';
        om1.Flight_Confirmation_Case_Created__c = false;
        om1.Check_in__c = Date.today() + 33;
        om1.First_Payment_Made__c = True;
        om1.StageName = 'Closed Won';
        om1.Reservation_Status__c = 'Confirmed';
        insert om1; 

        Opportunity o2 = new Opportunity();
        o2.name = 'test account';
        o2.CloseDate = System.today();
        o2.AccountId = a.id;
        o2.Opportunity_Closed_Date__c = DateTime.now() - 1;
        o2.RecordTypeId = [Select id from RecordType where sObjectType = 'Opportunity' and developerName ='Marival' ].id ;
        o2.VI_Referral_Comments__c = 'testing';
        o2.Flight_Confirmation_Case_Created__c = false;
        o2.Check_in__c = Date.today() + 3;
        o2.First_Payment_Made__c = True;
        o2.StageName = 'Closed Won';
        o2.Reservation_Status__c = 'Confirmed';
        o2.Supplier__c = 'Sunset';
        insert o2; 

        
        Opportunity om2 = new Opportunity();
        om2.name = 'test account';
        om2.CloseDate = System.today();
        om2.AccountId = a.id;
        om2.Opportunity_Closed_Date__c = DateTime.now() - 1;
        om2.RecordTypeId = [Select id from RecordType where sObjectType = 'Opportunity' and developerName ='Marival' ].id ;
        om2.VI_Referral_Comments__c = 'testing';
        om2.Flight_Confirmation_Case_Created__c = false;
        om2.Check_in__c = Date.today() + 33;
        om2.First_Payment_Made__c = True;
        om2.StageName = 'Closed Won';
        om2.Reservation_Status__c = 'Confirmed';
        om2.Supplier__c = 'Sunset';
        insert om2; 

        
		Opportunity o3 = new Opportunity();
        o3.name = 'test account';
        o3.CloseDate = System.today();
        o3.AccountId = a.id;
        o3.Opportunity_Closed_Date__c = DateTime.now() - 1;
        o3.RecordTypeId = [Select id from RecordType where sObjectType = 'Opportunity' and developerName ='Marival' ].id ;
        o3.VI_Referral_Comments__c = 'testing';
        o3.Flight_Confirmation_Case_Created__c = false;
        o3.Check_in__c = Date.today() + 3;
        o3.First_Payment_Made__c = True;
        o3.StageName = 'Closed Won';
        o3.Reservation_Status__c = 'Confirmed';
        o3.Supplier__c = 'Marival';
        insert o3; 
        
		Opportunity om3 = new Opportunity();
        om3.name = 'test account';
        om3.CloseDate = System.today();
        om3.AccountId = a.id;
        om3.Opportunity_Closed_Date__c = DateTime.now() - 1;
        om3.RecordTypeId = [Select id from RecordType where sObjectType = 'Opportunity' and developerName ='Marival' ].id ;
        om3.VI_Referral_Comments__c = 'testing';
        om3.Flight_Confirmation_Case_Created__c = false;
        om3.Check_in__c = Date.today() + 33;
        om3.First_Payment_Made__c = True;
        om3.StageName = 'Closed Won';
        om3.Reservation_Status__c = 'Confirmed';
        om3.Supplier__c = 'Marival';
        insert om3; 
        
		Opportunity o4 = new Opportunity();
        o4.name = 'test account';
        o4.CloseDate = System.today();
        o4.AccountId = a.id;
        o4.Opportunity_Closed_Date__c = DateTime.now() - 1;
        o4.RecordTypeId = [Select id from RecordType where sObjectType = 'Opportunity' and developerName ='Hooked_Voucher' ].id ;
        o4.VI_Referral_Comments__c = 'testing';
        o4.Flight_Confirmation_Case_Created__c = false;
        o4.Check_in__c = Date.today() + 3;
        o4.First_Payment_Made__c = True;
        o4.StageName = 'Closed Won';
        o4.Reservation_Status__c = 'Confirmed';
        o4.Supplier__c = 'Holidays NG';
        insert o4; 
        
        Opportunity om4 = new Opportunity();
        om4.name = 'test account';
        om4.CloseDate = System.today();
        om4.AccountId = a.id;
        om4.Opportunity_Closed_Date__c = DateTime.now() - 1;
        om4.RecordTypeId = [Select id from RecordType where sObjectType = 'Opportunity' and developerName ='Hooked_Voucher' ].id ;
        om4.VI_Referral_Comments__c = 'testing';
        om4.Flight_Confirmation_Case_Created__c = false;
        om4.Check_in__c = Date.today() + 33;
        om4.First_Payment_Made__c = True;
        om4.StageName = 'Closed Won';
        om4.Reservation_Status__c = 'Confirmed';
        om4.Supplier__c = 'Holidays NG';
        insert om4; 

       	Opportunity o5 = new Opportunity();
        o5.name = 'test account';
        o5.CloseDate = System.today();
        o5.AccountId = a.id;
        o5.Opportunity_Closed_Date__c = DateTime.now() - 1;
        o5.RecordTypeId = [Select id from RecordType where sObjectType = 'Opportunity' and developerName ='Hooked_Voucher' ].id ;
        o5.VI_Referral_Comments__c = 'testing';
        o5.Flight_Confirmation_Case_Created__c = false;
        o5.Check_in__c = Date.today() + 3;
        o5.First_Payment_Made__c = True;
        o5.StageName = 'Closed Won';
        o5.Reservation_Status__c = 'Confirmed';
        o5.Supplier__c = 'Exploria';
        insert o5; 
  
       
       	Opportunity om5 = new Opportunity();
        om5.name = 'test account';
        om5.CloseDate = System.today();
        om5.AccountId = a.id;
        om5.Opportunity_Closed_Date__c = DateTime.now() - 1;
        om5.RecordTypeId = [Select id from RecordType where sObjectType = 'Opportunity' and developerName ='Hooked_Voucher' ].id ;
        om5.VI_Referral_Comments__c = 'testing';
        om5.Flight_Confirmation_Case_Created__c = false;
        om5.Check_in__c = Date.today() + 33;
        om5.First_Payment_Made__c = True;
        om5.StageName = 'Closed Won';
        om5.Reservation_Status__c = 'Confirmed';
        om5.Supplier__c = 'Exploria';
        insert om5; 

               	Opportunity o6 = new Opportunity();
        o6.name = 'test account';
        o6.CloseDate = System.today();
        o6.AccountId = a.id;
        o6.Opportunity_Closed_Date__c = DateTime.now() - 1;
        o6.RecordTypeId = [Select id from RecordType where sObjectType = 'Opportunity' and developerName ='Marival' ].id ;
        o6.VI_Referral_Comments__c = 'testing';
        o6.Flight_Confirmation_Case_Created__c = false;
        o6.Check_in__c = Date.today() + 3;
        o6.First_Payment_Made__c = True;
        o6.StageName = 'Closed Won';
        o6.Reservation_Status__c = 'Confirmed';
        o6.Supplier__c = 'Las Palmas';
        insert o6; 
        
               	Opportunity om6 = new Opportunity();
        om6.name = 'test account';
        om6.CloseDate = System.today();
        om6.AccountId = a.id;
        om6.Opportunity_Closed_Date__c = DateTime.now() - 1;
        om6.RecordTypeId = [Select id from RecordType where sObjectType = 'Opportunity' and developerName ='Marival' ].id ;
        om6.VI_Referral_Comments__c = 'testing';
        om6.Flight_Confirmation_Case_Created__c = false;
        om6.Check_in__c = Date.today() + 33;
        om6.First_Payment_Made__c = True;
        om6.StageName = 'Closed Won';
        om6.Reservation_Status__c = 'Confirmed';
        om6.Supplier__c = 'Las Palmas';
        insert om6; 
        
                	Opportunity o7 = new Opportunity();
        o7.name = 'test account';
        o7.CloseDate = System.today();
        o7.AccountId = a.id;
        o7.Opportunity_Closed_Date__c = DateTime.now() - 1;
        o7.RecordTypeId = [Select id from RecordType where sObjectType = 'Opportunity' and developerName ='Marival' ].id ;
        o7.VI_Referral_Comments__c = 'testing';
        o7.Flight_Confirmation_Case_Created__c = false;
        o7.Check_in__c = Date.today() + 3;
        o7.First_Payment_Made__c = True;
        o7.StageName = 'Closed Won';
        o7.Reservation_Status__c = 'Confirmed';
        o7.Supplier__c = 'The Fives';
        insert o7; 
        
               	Opportunity om7 = new Opportunity();
        om7.name = 'test account';
        om7.CloseDate = System.today();
        om7.AccountId = a.id;
        om7.Opportunity_Closed_Date__c = DateTime.now() - 1;
        om7.RecordTypeId = [Select id from RecordType where sObjectType = 'Opportunity' and developerName ='Marival' ].id ;
        om7.VI_Referral_Comments__c = 'testing';
        om7.Flight_Confirmation_Case_Created__c = false;
        om7.Check_in__c = Date.today() + 33;
        om7.First_Payment_Made__c = True;
        om7.StageName = 'Closed Won';
        om7.Reservation_Status__c = 'Confirmed';
        om7.Supplier__c = 'The Fives';
        insert om7; 
        
       //Lifestyle
		Opportunity o8 = new Opportunity();
        o8.name = 'test account';
        o8.CloseDate = System.today();
        o8.AccountId = a.id;
        o8.Opportunity_Closed_Date__c = DateTime.now() - 1;
        o8.RecordTypeId = [Select id from RecordType where sObjectType = 'Opportunity' and developerName ='Hooked_Voucher' ].id ;
        o8.VI_Referral_Comments__c = 'testing';
        o8.Flight_Confirmation_Case_Created__c = false;
        o8.Check_in__c = Date.today() + 3;
        o8.First_Payment_Made__c = True;
        o8.StageName = 'Closed Won';
        o8.Reservation_Status__c = 'Confirmed';
        o8.Supplier__c = 'Westgate';
        insert o8; 
        Contact con = new Contact();
        con.LastName = 'Test';
        con.Opportunity__c = o.Id;
        con.AccountId = a.Id;
        insert con;

        Contact con2 = new Contact();
        con2.LastName = 'test account';
        con2.Opportunity__c = o2.Id;
        con2.AccountId = a.Id;
        insert con2;
 
        
        
        //               else if((opp.RecordType.DeveloperName == 'Hooked_Voucher' && opp.Supplier__c == 'Holiday Inn')){
 
       //Holiday Inn
		Opportunity o9 = new Opportunity();
        o9.name = 'test account';
        o9.CloseDate = System.today();
        o9.AccountId = a.id;
        o9.Opportunity_Closed_Date__c = DateTime.now() - 1;
        o9.RecordTypeId = [Select id from RecordType where sObjectType = 'Opportunity' and developerName ='Hooked_Voucher' ].id ;
        o9.VI_Referral_Comments__c = 'testing';
        o9.Flight_Confirmation_Case_Created__c = false;
        o9.Check_in__c = Date.today() + 3;
        o9.First_Payment_Made__c = True;
        o9.StageName = 'Closed Won';
        o9.Reservation_Status__c = 'Confirmed';
        o9.Supplier__c = 'Holiday Inn';
        insert o9; 
        
        Contact con9 = new Contact();
        con9.LastName = 'Test';
        con9.Opportunity__c = o9.Id;
        con9.AccountId = a.Id;
        insert con9;

        Contact con29 = new Contact();
        con29.LastName = 'test account';
        con29.Opportunity__c = o9.Id;
        con29.AccountId = a.Id;
        insert con29;
 
       //Holiday Inn 30
		Opportunity o10 = new Opportunity();
        o10.name = 'test account';
        o10.CloseDate = System.today();
        o10.AccountId = a.id;
        o10.Opportunity_Closed_Date__c = DateTime.now() - 1;
        o10.RecordTypeId = [Select id from RecordType where sObjectType = 'Opportunity' and developerName ='Hooked_Voucher' ].id ;
        o10.VI_Referral_Comments__c = 'testing';
        o10.Flight_Confirmation_Case_Created__c = false;
        o10.Check_in__c = Date.today() + 33;
        o10.First_Payment_Made__c = True;
        o10.StageName = 'Closed Won';
        o10.Reservation_Status__c = 'Confirmed';
        o10.Supplier__c = 'Holiday Inn';
        insert o10; 
        
        Contact con10 = new Contact();
        con10.LastName = 'Test';
        con10.Opportunity__c = o10.Id;
        con10.AccountId = a.Id;
        insert con10;

        Contact con210 = new Contact();
        con210.LastName = 'test account';
        con210.Opportunity__c = o10.Id;
        con210.AccountId = a.Id;
        insert con210;
 
        
        Test.startTest();
        
        // Enqueue the scheduler
        String sch = '0 0 0 15 3 ?'; // Run every day at midnight (UTC) starting on March 15th
        System.schedule('Test Flight Confirmation Batch Scheduler', sch, new CreateFlightConfirmationBatchScheduler());
        
        Test.stopTest();
    }
    
    
    
    
    
    
}