@isTest
public class OpportunityFirstPaymentDateUpdateTest {
    @isTest
    static void OpportunityFirstPaymentDateUpdateTest(){
        

        List<Opportunity> opplist = new List<Opportunity>();
        Opportunity opp = new Opportunity ();
        opp.Name='Opp1';
        opp.StageName='Negotiation';
        opp.CloseDate=Date.today();
        opp.First_Payment_Date__c = null;
        opplist.add(opp);
        
        insert opplist;
        
      /*  Payment__c pay = new Payment__c();
        
        pay.Paid_On__c = null;
        pay.Payment_Amount__c = 1;
        pay.Opportunity__c = opp.Id;
        insert pay;*/
        
        Test.startTest();
        OpportunityFirstPaymentDateUpdateBatch oppfirstpay = new OpportunityFirstPaymentDateUpdateBatch();
        database.executeBatch(oppfirstpay);
        Test.stopTest();
    }
    
}