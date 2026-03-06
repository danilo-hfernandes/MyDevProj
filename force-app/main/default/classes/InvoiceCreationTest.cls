@isTest
public class InvoiceCreationTest {
    
    @isTest
    public static void InvoiceCreationTest1(){        
        List<InvoiceCreation.fieldWrapper> InvoiceCreationList = new List<InvoiceCreation.fieldWrapper>();
        
        Account acc = new Account(Name = 'Test Account', Affiliated_Id__c = 1235, Member_Number__c = '13523412');
        insert acc;
        
        Opportunity opp1 = new Opportunity (Name='Opp1',StageName='Negotiation',CloseDate=Date.today(),Arrived__c=true, AccountId = acc.id);
        insert opp1;
        
        Reservation_Tracking_Object__c rec = new Reservation_Tracking_Object__c();
        rec.Confirmation_Number__c = 'Confirmed';
        rec.Reservation_Status__c='Confirmed';
        rec.Opportunity__c = opp1.Id;
        insert rec;
        
        List<Invoice__c> inlist = new List<Invoice__c>();
        Invoice__c invoice = new Invoice__c();
        invoice.Confirmation__c =rec.Confirmation_Number__c;
        invoice.Invoice_Amount__c = 123;
        invoice.Reservation_Status__c = 'Complete';
        inlist.add(invoice);
        insert inlist;
        
        InvoiceCreation Invcre = new InvoiceCreation();
        InvoiceCreation.insertInvoice('invoice');
        InvoiceCreation.fieldWrapper invwrp = new InvoiceCreation.fieldWrapper();
        invwrp.DateCreated = '06/22/2021';        
        invwrp.CancelDate = '12/20/2021';        
        invwrp.ReservationNumber = '5462910';
        invwrp.ReservationStatus = 'Canceled';        
        invwrp.FirstNight = '01/01/2022';        
        invwrp.LastNight = '07/01/2022';
        invwrp.SiteName = 'Grand Luxxe Riviera Maya';        
        invwrp.Roomtype = 'Grand Luxxe DeLuxxe 1 Bdrm.';        
        invwrp.ExternalConfirmationNumber = '299003';
        invwrp.BillingItem = 'Penalty';        
        invwrp.InvoiceAmount = '150';
        InvoiceCreationList.add(invwrp);
        
        string inputData1 = JSON.serialize(InvoiceCreationList);
        system.debug('inputData1=== '+inputData1);
        
        test.startTest();
        InvoiceCreation.getFormatedDate('12/20/2021');
        InvoiceCreation.insertInvoice(inputData1);
        test.stopTest();
        
        system.assert(invoice.Id != null, 'Invoice is inserted successfully');
    }
}