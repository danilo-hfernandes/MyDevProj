@isTest
public class ReservationCtrlTest {
    public static testmethod void opportunityProductTest(){        
        Account newAcc = new Account();
        newAcc.name='test';
        
        insert newAcc;
        
        Contact con=new Contact();
        con.lastname='Testing';
        con.email='test@test.com';
        con.AccountId = newAcc.Id; // Link Contact to the Account
        insert con;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'test opp';
        opp.AccountId = newAcc.id;
        opp.CloseDate = System.today();
        opp.StageName = 'Process of Closing*';
        insert opp;
        
        PageReference pageRef = new PageReference('/apex/ReservationCtrl'); // Use your actual page name
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', opp.Id);
        
        ApexPages.StandardController ol = new ApexPages.StandardController(opp);
        ReservationCtrl opPrdtCtrl = new ReservationCtrl(ol);
        opPrdtCtrl.enableEditMode();
        opPrdtCtrl.showPopup();
        
    }
    
    public static testmethod void opportunityTest1(){        
        Account newAcc = new Account();
        newAcc.name='test';
        
        insert newAcc;
        
        Contact con=new Contact();
        con.lastname='Testing';
        con.email='test@test.com';
        con.AccountId = newAcc.Id; // Link Contact to the Account
        insert con;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'test opp';
        opp.AccountId = newAcc.id;
        opp.CloseDate = System.today();
        opp.StageName = 'Process of Closing*';
        opp.Reservation_Status__c = 'Cancel';
        insert opp;
        
        PageReference pageRef = new PageReference('/apex/ReservationCtrl'); // Use your actual page name
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', opp.Id);
        
        ApexPages.StandardController ol = new ApexPages.StandardController(opp);
        ReservationCtrl opPrdtCtrl = new ReservationCtrl(ol);
        opPrdtCtrl.enableEditMode();
        opPrdtCtrl.showPopup();
        opPrdtCtrl.savebutton();
    }
    
    public static testmethod void opportunityTest2(){        
        Account newAcc = new Account();
        newAcc.name='test';
        
        insert newAcc;
        
        Contact con=new Contact();
        con.lastname='Testing';
        con.email='test@test.com';
        con.AccountId = newAcc.Id; // Link Contact to the Account
        insert con;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'test opp';
        opp.AccountId = newAcc.id;
        opp.CloseDate = System.today();
        opp.StageName = 'Process of Closing*';
        opp.Reservation_Status__c = 'Confirmed';
        opp.Check_in__c = system.today();
        insert opp;
        
                PageReference pageRef = new PageReference('/apex/ReservationCtrl'); // Use your actual page name
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', opp.Id);
        
        ApexPages.StandardController ol = new ApexPages.StandardController(opp);
        ReservationCtrl opPrdtCtrl = new ReservationCtrl(ol);
        opPrdtCtrl.enableEditMode();
        opPrdtCtrl.showPopup();
        opPrdtCtrl.closePopup();
        opPrdtCtrl.updatecheckoutDate();
    }
    
}