@isTest
public class InvoiceTriggerTest {
	@isTest
    static void test1() {
        Apex_Trigger_On_Off__c cs = new Apex_Trigger_On_Off__c();
        cs.Name = 'InvoiceTrigger';
        cs.isEnable__c = true;
        insert cs;
        
        Account acc = new Account(Name = 'Test Account', Affiliated_Id__c = 1235, Member_Number__c = '13523412');
        insert acc;
        
        Opportunity opp1 = new Opportunity (Name='Opp1',StageName='Negotiation',CloseDate=Date.today(),Arrived__c=true, AccountId = acc.id);
        insert opp1;
        
        Reservation_Tracking_Object__c rec = new Reservation_Tracking_Object__c();
        rec.Confirmation_Number__c = 'Confirmed';
        rec.Reservation_Status__c='Confirmed';
        rec.Opportunity__c = opp1.Id;
        insert rec;
        
        
        Invoice__c invoice = new Invoice__c();
        invoice.Confirmation__c =rec.Confirmation_Number__c;
        invoice.Invoice_Amount__c = 123;
        invoice.Reservation_Status__c = 'Complete';
        invoice.Opportunity__c = opp1.Id;
        insert invoice;
        invoice.Invoice_Amount__c = 1235;
        update invoice;
        //delete invoice;
    }
    
    @isTest
    static void test2() {
        Apex_Trigger_On_Off__c cs = new Apex_Trigger_On_Off__c();
        cs.Name = 'InvoiceTrigger';
        cs.isEnable__c = true;
        insert cs;
        
        Account acc = new Account(Name = 'Test Account', Affiliated_Id__c = 1235, Member_Number__c = '13523412');
        insert acc;
        
        Opportunity opp1 = new Opportunity (Name='Opp1',StageName='Negotiation',CloseDate=Date.today(),Arrived__c=true, AccountId = acc.id);
        insert opp1;
        
        Reservation_Tracking_Object__c rec = new Reservation_Tracking_Object__c();
        rec.Confirmation_Number__c = 'Cancel';
        rec.Reservation_Status__c='Cancel';
        rec.Opportunity__c = opp1.Id;
        insert rec;
        
        
        Invoice__c invoice = new Invoice__c();
        invoice.Confirmation__c =rec.Confirmation_Number__c;
        invoice.Invoice_Amount__c = 123;
        invoice.Reservation_Status__c = 'Canceled';
        invoice.Opportunity__c = opp1.Id;
        insert invoice;
        invoice.Invoice_Amount__c = 1235;
        update invoice;
        delete invoice;
    }
    @isTest
    static void test3() {
        Apex_Trigger_On_Off__c cs = new Apex_Trigger_On_Off__c();
        cs.Name = 'InvoiceTrigger';
        cs.isEnable__c = true;
        insert cs;
        
        Account acc = new Account(Name = 'Test Account', Affiliated_Id__c = 1235, Member_Number__c = '13523412');
        insert acc;
        
        Opportunity opp1 = new Opportunity (Name='Opp1',StageName='Negotiation',CloseDate=Date.today(),Arrived__c=true, AccountId = acc.id,Total_Invoiced_Amount__c = null);
        insert opp1;
        
        Reservation_Tracking_Object__c rec = new Reservation_Tracking_Object__c();
        rec.Confirmation_Number__c = 'Confirmed';
        rec.Reservation_Status__c='Cancel';
        rec.Opportunity__c = opp1.Id;
        insert rec;
        
        
        Invoice__c invoice = new Invoice__c();
        invoice.Confirmation__c =rec.Confirmation_Number__c;
        invoice.Invoice_Amount__c = 123;
        invoice.Reservation_Status__c = 'Canceled';
        insert invoice;
        invoice.Invoice_Amount__c = 1235;
        update invoice;
        //delete invoice;
    }
}