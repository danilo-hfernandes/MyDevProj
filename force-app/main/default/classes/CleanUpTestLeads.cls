/**
 * Name:          CleanUpTestLeads
 * Description:   Clean the test lead created within 48 hrs.
 * Author         Hitarth Raval
 */


public class CleanUpTestLeads implements Database.Batchable<sObject>, Schedulable 
{
    public void execute(SchedulableContext sc)
    {
        CleanUpTestLeads b = new CleanUpTestLeads ();
        database.executebatch(b,200);
    }
    public Database.QueryLocator start(Database.BatchableContext BC)
    {
        String query = 'SELECT Id FROM Lead WHERE FirstName LIKE \'%test%\'';
        return Database.getQueryLocator(query);
    }
 
    public void execute(Database.BatchableContext BC, List<Lead> Leads)
    {
         for(Lead a : Leads)
         {
             a.status = 'Test';
             a.Email = 'test@test.com';
             a.Phone = '9999999999';
         }
        system.debug('leads== ' + Leads);
         update Leads;
    }  
    public void finish(Database.BatchableContext BC)
    {
    }
}