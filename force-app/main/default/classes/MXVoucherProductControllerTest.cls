@isTest
public class MXVoucherProductControllerTest {
    
    @isTest
    public static void MXVoucherProductControllerTest1(){
        
        Inventory_Management__c invt = new Inventory_Management__c();
        Insert invt;
        
        Inventory_Availability__c inav = new Inventory_Availability__c();
        inav.Inventory_Management__c= invt.Id;
        inav.Resort_Name__c='testabc';
        inav.Check_In_Date__c=system.today();
        inav.New_Availability__c=1;
        inav.Plaza__c='VALLARTA';
        inav.Program__c='MTK';
        Insert inav;  
        
        Opportunity opp = new Opportunity();
        opp.Name='Test Opp';
        
        opp.StageName='Proposal';
        opp.CloseDate=system.today();
        opp.Destination__c='Acapulco';
        opp.Property__c='Mayan Palace Acapulco';
        opp.Rooms__c='1BR';
        opp.Check_in__c=System.today();
        opp.Check_Out__c=System.today();
        opp.Reservation_Status__c='Pending';
        opp.Inventory_Availability_Id__c=inav.id;
        opp.Capacity__c='2A + 2K';
        Insert opp;
        
        opp.Destination__c=inav.Plaza__c;
        update opp;
        
        Pricebook2 pb = new Pricebook2();
        pb.Name = 'Standard Price Book 2009';
        pb.Description = 'Price Book 2009 Products';
        pb.IsActive = true;
        insert pb;
        
        Product2 prod = new Product2();
        prod.Name = 'MX Voucher 8/7';
        prod.IsActive = true;
        insert prod;
        
        PricebookEntry pbe=new PricebookEntry(); 
        pbe.unitprice=0.01;
        pbe.Product2Id=prod.Id;
        pbe.Pricebook2Id=Test.getStandardPricebookId();
        pbe.IsActive= true;
        insert pbe;   
        
        OpportunityLineItem oppLine = new OpportunityLineItem();
        oppLine.pricebookentryid=pbe.Id;
        oppLine.TotalPrice=2000;
        oppLine.Quantity = 2;
        oppLine.OpportunityID = opp.Id;
        insert oppLine;
        
        MX_Voucher_Product__c mxvoucher = new MX_Voucher_Product__c();
        mxvoucher.Location__c = 'Nuevo Vallarta';
        mxvoucher.Suggested_Price__c = 10;
        mxvoucher.Input_Price__c = 10;
        mxvoucher.Minimal_Price__c = 10; 
        mxvoucher.Section_Name__c = 'Master Room';
        mxvoucher.Room_Size__c = 'Master Room';
        mxvoucher.Section_Name__c = 'Master Room';
        insert mxvoucher;        
        
        
        MXVoucherProductController mxvProduct = new MXVoucherProductController();
        MXVoucherProductController.searchWrapper smxvProduct = new MXVoucherProductController.searchWrapper();
        MXVoucherProductController.AvailabityCheck('MX Voucher 8/7');
        MXVoucherProductController.getAllProductNames();
        MXVoucherProductController.closeMethod();
        MXVoucherProductController.roomType('test', 'test', 'MX Voucher 8/7');
        MXVoucherProductController.getAllResort('test', 'MX Voucher 8/7');
        MXVoucherProductController.getAllProgram('test', 'test', 'test', 'MX Voucher 8/7');
        try{
            MXVoucherProductController.CreateProduct(mxvoucher.Id, opp.Id, 10,'MX Voucher 8/7');
        }
        catch(Exception e){
        }
        
    }
    
}