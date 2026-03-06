@isTest
public class FBOutboundLeadTest {
    
    @testSetup
    public static void setupEnvironment() {
        
        Apex_Trigger_On_Off__c cs = new Apex_Trigger_On_Off__c();
        cs.isEnable__c = true;
        cs.Name = 'LeadDupliateTriggerLogic';
        
        Apex_Trigger_On_Off__c cs2 = new Apex_Trigger_On_Off__c();
        cs2.isEnable__c = true;
        cs2.Name = 'LeadSalesCadenceAssignment';
        
        Apex_Trigger_On_Off__c cs3 = new Apex_Trigger_On_Off__c();
        cs3.isEnable__c = true;
        cs3.Name = 'UpdateTimeZoneAccount';
        
        Apex_Trigger_On_Off__c cs4 = new Apex_Trigger_On_Off__c();
        cs4.isEnable__c = true;
        cs4.Name = 'UpdateTimeZoneLead';
        
        Apex_Trigger_On_Off__c cs5 = new Apex_Trigger_On_Off__c();
        cs5.isEnable__c = true;
        cs5.Name = 'LeadAndAccountTrigger';
        
        insert cs;
        insert cs2;
        insert cs3;
        insert cs4;
        insert cs5;
        
         Profile p = [select id
                     from
                     Profile
                     where
                     name='System Administrator'];
        
        
        
       User user = new user(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', firstName='Test', lastname='Name', languagelocalekey='en_US',
                             localesidkey='en_IN', profileid = p.Id, country='India',
                             timezonesidkey='Asia/Kolkata', username='test101_g@noemail.com', Assigned_Contacts__c=4);
        insert user;
                
        Lead l= new Lead();
        l.LastName='Test';
        l.OwnerId=user.id;
        l.email='test@t.com';
        l.status='New';
        l.Is_Duplicate__c=FALSE;
        l.leadSource='Test';
        l.Assign_to_Sales_Cadence__c=false;
        l.leadassist__Use_Round_Robin__c='FALSE';
        l.RecordTypeId='0123t000000dXngAAE';
        l.IsConverted=false;
        l.FB_Outbound_Group__c = 'true';
        l.company='TEST';
        l.LeadSource = 'CFD FB Riviera Maya';
        l.Phone='1234567890';
        insert l;
        
        //Test.setCreatedDate(l.Id, DateTime.newInstance(2022,06,25));
        
        
        Datetime CreatedDate = Datetime.now().addDays(-31);
        Test.setCreatedDate( l.Id, CreatedDate);
        
    } 
    @isTest 
    public static void assignLeadTest() {
        List<lead> leadList = [SELECT id, RecordTypeId, Name,FB_Outbound_Group__c, CreatedDate, ActionCadenceId, Is_Duplicate__c,status FROM Lead WHERE LastName Like 'Test%'];  
        // Set mock callout class     
        system.debug('71 test='+leadlist);
        Test.setMock(HttpCalloutMock.class, new FBOutboundLeadTestMock());  
        Test.startTest();
        FBOutboundLead ba= new FBOutboundLead();
        Id jobid= Database.executeBatch(ba,5);
        Test.stopTest();       
    }
}