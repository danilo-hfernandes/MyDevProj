@isTest
public class NotesListViewCtrlTest {
	@isTest
    static void Test1() {
        
        Lead objlead = new Lead();
        objlead.FirstName = 'Testing';
        objlead.LastName = 'Testing';
        objlead.Company = 'Testing';
        objlead.LeadSource = 'Web';
        objlead.email = 'test@test.com'; 
        objlead.phone = '123456123456';
        insert objlead;
        
        Account a = new Account();
        a.Name = 'test';
        insert a;
        
        Contact objcon = new Contact();
        objcon.LastName = 'testing';
        objcon.email = 'test@gmail.com';
        objcon.AccountId = a.Id;
        insert objcon;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'test opp';
        opp.AccountId = a.id;
        opp.CloseDate = System.today();
        opp.StageName = 'Process of Closing*';
        opp.Timeshare_1__c = null;
        opp.Timeshare_2__c = null;
        opp.Timeshare_3__c = null;
        opp.Timeshare_4__c = null;
        opp.Timeshare_5__c = null;
        opp.Source__c = 'SMTN Referral';
         
        insert opp;
        
        Payment__c pay = new Payment__c();
        pay.Name = 'test';
        pay.Opportunity__c = opp.Id;
        pay.Payment_Amount__c = 1;
        insert pay;
        
        ContentVersion contentVersion = new ContentVersion(
          Title = 'Penguins',
          PathOnClient = 'Penguins.jpg',
          VersionData = Blob.valueOf('Test Content'),
          IsMajorVersion = true
        );
        insert contentVersion;     
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        //create ContentDocumentLink  record 
        //ContentDocumentLink cdl = New ContentDocumentLink();
        //cdl.LinkedEntityId = opp.id;
        //cdl.ContentDocumentId = documents[0].Id;
        //cdl.shareType = 'V';
        //insert cdl;
                
        ContentNote cnt = new ContentNote();
        cnt.Title = 'test';
        insert cnt;
        
        ContentDocument cd=[select id from ContentDocument where id=:cnt.Id];
        ContentDocumentLink cdl=new ContentDocumentLink();
        cdl.ContentDocumentId=cd.id;
        cdl.LinkedEntityId=opp.id;
        cdl.ShareType='V';
        cdl.Visibility='AllUsers';
        insert cdl;
        
        //Task tk = new Task();
        //tk.subject = 'test task';
        //tk.Description = 'test classes description';
        //tk.WhatId = a.Id;
        
        //insert tk;
        
        //Event ev = new Event();
        //ev.subject = 'Event subject' ;
        //ev.StartDateTime = system.now();
        //ev.whatid = a.Id;
        //ev.DurationInMinutes = 60;
        //insert ev;
        
        NotesListViewCtrl notesClas = new NotesListViewCtrl();
        NotesListViewCtrl.notestListWrapper wrp = new NotesListViewCtrl.notestListWrapper();
        NotesListViewCtrl.fetchNotesWrapper(a.Id);// wrapper = new NotesListViewCtrl.fetchNotesWrapper(a.Id);
        NotesListViewCtrl.fetchNotesWrapper(objcon.Id);
        NotesListViewCtrl.fetchNotesWrapper(objlead.Id);
        NotesListViewCtrl.createRecord(cnt,a.Id);
    }
    @isTest
    static void Test2() {
        Account a = new Account();
        a.Name = 'test';
 
        insert a;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'test opp';
        opp.AccountId = a.id;
        opp.CloseDate = System.today();
        opp.StageName = 'Process of Closing*';
        opp.Timeshare_1__c = null;
        opp.Timeshare_2__c = null;
        opp.Timeshare_3__c = null;
        opp.Timeshare_4__c = null;
        opp.Timeshare_5__c = null;
        opp.Source__c = 'SMTN Referral';
         
        insert opp;
        
		Payment__c pay = new Payment__c();
        pay.Name = 'test';
        pay.Opportunity__c = opp.Id;
        pay.Payment_Amount__c = 1;
        insert pay;
        
        Task tk = new Task();
        tk.subject = 'test task';
        tk.Description = 'test classes description';
        tk.WhatId = opp.Id;
        
        insert tk;
        
        Event ev = new Event();
        ev.subject = 'Event subject' ;
        ev.StartDateTime = system.now();
        ev.whatid = opp.Id;
        ev.DurationInMinutes = 60;
        insert ev;
        
        ContentNote cnt = new ContentNote();
        cnt.Title = 'test';
        insert cnt;
        
        NotesListViewCtrl notesClas = new NotesListViewCtrl();
        NotesListViewCtrl.fetchNotesWrapper(opp.Id);// wrapper = new NotesListViewCtrl.fetchNotesWrapper(a.Id);
        NotesListViewCtrl.createRecord(cnt,opp.Id);
    }
    @isTest
    static void Test3() {
        Account a = new Account();
        a.Name = 'test';

        insert a;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'test opp';
        opp.AccountId = a.id;
        opp.CloseDate = System.today();
        opp.StageName = 'Process of Closing*';
        opp.Timeshare_1__c = null;
        opp.Timeshare_2__c = null;
        opp.Timeshare_3__c = null;
        opp.Timeshare_4__c = null;
        opp.Timeshare_5__c = null;
        opp.Source__c = 'SMTN Referral';
         
        insert opp;
        
        Contact con = new Contact();
        con.Lastname = 'Mitul';
        con.AccountId = a.Id;
        
        insert con;
        
        
        Payment__c pay = new Payment__c();
        pay.Name = 'test';
        pay.Opportunity__c = opp.Id;
        pay.Payment_Amount__c = 1;
        insert pay;
        ContentNote cnt = new ContentNote();
        cnt.Title = 'test';
        insert cnt;
        
        Task tk = new Task();
        tk.subject = 'test task';
        tk.Description = 'test classes description';
        tk.WhatId = pay.Id;
        
        insert tk;
        
        Event ev = new Event();
        ev.subject = 'Event subject' ;
        ev.StartDateTime = system.now();
        ev.whatid = pay.Id;
        ev.DurationInMinutes = 60;
        insert ev;
        
        NotesListViewCtrl notesClas = new NotesListViewCtrl();
        NotesListViewCtrl.fetchNotesWrapper(pay.Id);// wrapper = new NotesListViewCtrl.fetchNotesWrapper(a.Id);
        NotesListViewCtrl.createRecord(cnt,con.Id);
    }
}