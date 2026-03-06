Global class MonsterTaskCreationBatch implements Database.Batchable<sObject>,schedulable{
    
    Global Database.QueryLocator start(Database.BatchableContext bc) {
        String salesCadenceName='TourGen-Monster Vida Reservations';
        List<Id> targetIds = new List<Id>();
        targetIds = GetAssignedTargetDetails.getSingleCadenceNamewithTargetList(salesCadenceName);
        system.debug('targetIds>>>>>'+targetIds);
        String fromToday35 = String.valueOf(System.now().addDays(35)).substring(0,10)/*+'T00:00:00.000+0000'*/;
        String fromToday45 = String.valueOf(System.now().addDays(45)).substring(0,10)/*+'T00:00:00.000+0000'*/;
        String fromToday60 = String.valueOf(System.now().addDays(60)).substring(0,10)/*+'T00:00:00.000+0000'*/;
        String fromToday90 = String.valueOf(System.now().addDays(90)).substring(0,10)/*+'T00:00:00.000+0000'*/;
        String fromToday35max = String.valueOf(System.now().addDays(35)).substring(0,10)/*+'T23:59:59.999+0000'*/;
        String fromToday45max = String.valueOf(System.now().addDays(45)).substring(0,10)/*+'T23:59:59.999+0000'*/;
        String fromToday60max = String.valueOf(System.now().addDays(60)).substring(0,10)/*+'T23:59:59.999+0000'*/;
        String fromToday90max = String.valueOf(System.now().addDays(90)).substring(0,10)/*+'T23:59:59.999+0000'*/;
        
        //String test = fromToday35.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
        System.debug('fromToday35 = '+fromToday35);
        System.debug('fromToday45 = '+fromToday45);
        System.debug('fromToday60 = '+fromToday60);
        System.debug('fromToday90 = '+fromToday90);
        System.debug('fromToday35max = '+fromToday35max);
        System.debug('fromToday45max = '+fromToday45max);
        System.debug('fromToday60max = '+fromToday60max);
        System.debug('fromToday90max = '+fromToday90max);
        
        //List<DateTime> datesToQuery = new List<DateTime>{fromToday35,fromToday45,fromToday60,fromToday90};        
        String query = 'SELECT Id,Check_in__c,Traveler_Name__c, (SELECT Id FROM Contacts__r where Marketing_Email_opt_out__c = false and Id NOT IN : targetIds) FROM Opportunity WHERE IsClosed = true AND IsWon = true AND Property__c LIKE \'%Mayan Palace%\' AND Account.Member_Number__c = \'142519-support@monsterrg.com\' AND ((Check_in__c = '+fromToday35+') OR (Check_in__c = '+fromToday45+') OR (Check_in__c = '+fromToday60+') OR (Check_in__c = '+fromToday90+')) AND RecordType.DeveloperName = \'Profit_Agility_Voucher\' AND (Rooms__c = \'1BR\' OR Rooms__c = \'U.H.\')';
        return Database.getQueryLocator(query);
    }
    
    Global void execute(Database.BatchableContext bc, List<Opportunity> scope) {
        
        String fromToday35 = String.valueOf(System.now().addDays(35)).substring(0,10);
        String fromToday45 = String.valueOf(System.now().addDays(45)).substring(0,10);
        String fromToday60 = String.valueOf(System.now().addDays(60)).substring(0,10);
        String fromToday90 = String.valueOf(System.now().addDays(90)).substring(0,10);         
        //List<Task> monsterTasks = new List<Task>();
        List<Contact> contactsToAssignSRR = new List<Contact>();
        Set<Id> contactsToAssignCadence = new Set<Id>();
        for(Opportunity opp: scope){
            System.debug(opp.Check_in__c);
            String checkinString = String.valueOf(opp.Check_in__c).substring(0,10);
            System.debug('fromToday35 = '+fromToday35);
            System.debug('fromToday45 = '+fromToday45);
            System.debug('fromToday60 = '+fromToday60);
            System.debug('fromToday90 = '+fromToday90);
            System.debug('checkinString = '+checkinString);
            /*Task task = new Task();
task.WhatId = opp.id;
task.Status = 'Pending';
task.Priority = 'Normal';

String tName = '';
if(opp.Traveler_Name__c != null)
{
if(opp.Traveler_Name__c != ''){
tName = opp.Traveler_Name__c;
}
}*/
            if(opp.Contacts__r != null && opp.Contacts__r.size()>0){
                Contact con = opp.Contacts__r[0];
                con.Assign_to_Sales_Cadence__c=true;
                contactsToAssignSRR.add(con);
                contactsToAssignCadence.add(con.id);
                
                /*if(checkinString == fromToday35){                
task.Subject = 'Monster 35 Day Upgrade ['+tName+']';            
task.ActivityDate = System.today();
}
else if(checkinString == fromToday45)
{
task.Subject = 'Monster 45 Day Upgrade ['+tName+']';            
task.ActivityDate = System.today();
}
else if(checkinString == fromToday60)
{
task.Subject = 'Monster 60 Day Upgrade ['+tName+']';            
task.ActivityDate = System.today();
}
else if(checkinString == fromToday90)
{
task.Subject = 'Monster 90 Day Upgrade ['+tName+']';            
task.ActivityDate = System.today();
}*/
            }
            //monsterTasks.add(task);
        }
        
        /*if(monsterTasks != null && monsterTasks.size()>0)
{
insert monsterTasks;
}*/
        if(contactsToAssignSRR != null && contactsToAssignSRR.size()>0)
        {
            contactsToAssignSRR =  GenericMatchGroupAssignmentHandler.assignMatchGroup(contactsToAssignSRR, 'TourGen-Monster Vida Reservations');
            update contactsToAssignSRR;
            System.enqueueJob(new MonsterTaskCreationBatchQueueable(contactsToAssignCadence)); 
        }
    }
    Global void finish(Database.BatchableContext bc) {
        //method required - not used
    }  
    Global void execute(SchedulableContext SC) {
        database.executebatch(new MonsterTaskCreationBatch(),100);
    }
}