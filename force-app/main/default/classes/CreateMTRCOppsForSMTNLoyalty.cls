public class CreateMTRCOppsForSMTNLoyalty implements Database.Batchable<sObject>,schedulable{
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        List<String> noMatchTimeshares = new List<String>{
            'Grand Luxxe Jungle Riviera Maya',
                'Grand Luxxe Nuevo Vallarta',
                'Grand Luxxe Riviera Maya',
                'Imperial Gardens',
                'Imperial Gardens',
                'Imperial Jungle Aqua',
                'Mayan Palace - Acapulco Golf Resort',
                'Mayan Palace - Acapulco Playa',
                'Mayan Palace - Mazatlan',
                'Mayan Palace - Nuevo Vallarta',
                'Mayan Palace - Puerto Penasco',
                'Mayan Palace - Puerto Vallarta',
                'Mayan Palace - Riviera Maya',
                'Sea Garden - Acapulco',
                'Sea Garden - Mazatlan',
                'Sea Garden - Nuevo Vallarta',
                'Sea Garden Mazatlan',
                'Sea Garden Puerto Vallarta',
                'The Grand Bliss - Nuevo Vallarta',
                'The Grand Bliss - Riviera Maya',
                'The Grand Mayan - Acapulco',
                'The Grand Mayan - Los Cabos',
                'The Grand Mayan - Nuevo Vallarta',
                'The Grand Mayan - Puerto Penasco',
                'The Grand Mayan - Riviera Maya',
                'Vidanta Acapulco - Mayan Palace',
                'Vidanta Acapulco - Sea Garden',
                'Vidanta Acapulco - The Grand Mayan',
                'Vidanta East Cape',
                'Vidanta Grand Bliss Nuevo Vallarta',
                'Vidanta Grand Bliss Riviera Maya',
                'Vidanta Grand Mayan Acapulco',
                'Vidanta Grand Mayan Los Cabos',
                'Vidanta Grand Mayan Nuevo Vallarta',
                'Vidanta Grand Mayan Puerto Penasco',
                'Vidanta Grand Mayan Riviera Maya',
                'Vidanta Los Cabos - The Grand Mayan',
                'Vidanta Mayan Palace - Acapulco Golf Resort',
                'Vidanta Mayan Palace - Acapulco Playa',
                'Vidanta Mayan Palace - Mazatlan',
                'Vidanta Mayan Palace - Puerto Vallarta',
                'Vidanta Mayan Palace - Riviera Maya',
                'Vidanta Mayan Palace Acapulco Golf Resort',
                'Vidanta Mayan Palace Mazatlan',
                'Vidanta Mayan Palace Nuevo Vallarta',
                'Vidanta Mayan Palace Puerto Penasco',
                'Vidanta Mayan Palace Puerto Vallarta',
                'Vidanta Mayan Palace Riviera Maya',
                'Vidanta Mayan Sea Garden Acapulco',
                'Vidanta Mayan Sea Garden Mazatlan',
                'Vidanta Mayan Sea Garden Nuevo Vallarta',
                'Vidanta Mazatlan - Mayan Palace',
                'Vidanta Mazatlan - Sea Garden',
                'Vidanta Nuevo Vallarta - Grand Luxxe',
                'Vidanta Nuevo Vallarta - Mayan Palace',
                'Vidanta Nuevo Vallarta - Mayan Sea Garden',
                'Vidanta Nuevo Vallarta - The Grand Bliss',
                'Vidanta Nuevo Vallarta - The Grand Mayan',
                'Vidanta Puerto Peñasco - Mayan Palace',
                'Vidanta Puerto Peñasco - The Grand Mayan',
                'Vidanta Puerto Vallarta - Mayan Palace',
                'Vidanta Riviera Maya - Mayan Palace',
                'Vidanta Riviera Maya - The Bliss',
                'Vidanta Riviera Maya - The Grand Bliss',
                'Vidanta Riviera Maya - The Grand Mayan',
                'Vidanta Sea Garden Acapulco',
                'Vidanta The Bliss Riviera Maya',
                'VidantaThe Bliss - Riviera Maya',
                'Global Discovery Vacations',
                'GDV Member Login (globaldiscoveryvacations.com)',
                'Ownership consists of Global Discovery Credits',
                'This ownership has additional reservation fees that can be between $385-$965',
                'Global Exchange Vacation Club',
                'Hacienda Tres Rios',
                'Ownership has all-inclusive fees of around $140 per person at the time of booking',
                'All Campgrounds',
                'All Occidental ownerships',
                'All FantaSea Resorts (Flagship, Atlantic Palace, La Sammana)',
                'The Manhattan Club',
                'Novaispania Residences in Cabo San Lucas',
                'Sapphire Resorts: SRG (staysapphire.com)',
                'Southern Journeys',
                'Sunset Royal – Owner pays an all-inclusive fee of $125',
                'Festiva Orlando Resort',
                'Inovation Travel by Marival Resorts',
                'Interchange Vacation Club - Home | Interchange Vacation Club Members Website',
                'StaySky Vacation Clubs',
                'La Herencia Residence Club at Tres Rios'
                };
                    
                    Date dtoday = System.today();
        //2023-06-05 HSIMU2-45 - CreatedDate = Exaclty 12 Months Ago From Today
        Date dmin = dtoday.addMonths(-12);
        //string MatchRule='0015300000LopHYAAZ';
        //System.debug('dmin = '+dmin);
        String dminT = String.valueOf(dmin).substring(0,10)+'T00:00:00Z';
        String dmaxT = String.valueOf(dmin).substring(0,10)+'T23:59:59Z';
        
        /*User zappierUser = [SELECT Id,Username FROM User WHERE Email = 'zappier@nerdsoft.com' OR Email = 'zappier@nerdsoft.com.invalid' LIMIT 1];
Id leadCFRecTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Carefree_Destinations').getRecordTypeId();*/
        String query = '';
        if(!Test.isRunningTest()){            
            /*query='Select id,name,Affiliated_Id__c from account where id=\''+MatchRule+'\'';*/
            query = 'SELECT Id,Affiliated_Id__c,(SELECT Id FROM Contacts),First_Name__c,Last_Name__c,Email__c,Phone,Master_Record_Id__c,Name FROM Account WHERE MFProtection__c = false AND (TRM_Owner_Flag__c = \'No\' OR TRM_Owner_Flag__c = null) AND Affiliated_Id__c = 1002222 AND Membership_Status__c != \'FrozenByResort\' AND Membership_Status__c != \'FrozenByHSI\' AND  Membership_Status__c != \'FrozenForEADiscrepancy\' AND CreatedDate >= '+dminT+' AND CreatedDate <= '+dmaxT+' AND Id NOT IN (SELECT Timeshare_Owner__c FROM Timeshare__c WHERE Name IN : noMatchTimeshares) AND Id NOT IN (SELECT AccountId FROM Opportunity WHERE (MTRC_Opp_For_SMTN_Loyalty__c = True OR (IsWon = True AND RecordType.DeveloperName = \'Membership_Upgrade\')))';
        }
        else
        {
            query = 'SELECT Id,Affiliated_Id__c,(SELECT Id FROM Contacts),First_Name__c,Last_Name__c,Email__c,Phone,Master_Record_Id__c,Name FROM Account WHERE Affiliated_Id__c = 1002222 AND Membership_Status__c != \'FrozenByResort\' AND Membership_Status__c != \'FrozenByHSI\' AND  Membership_Status__c != \'FrozenForEADiscrepancy\' AND CreatedDate >= '+dminT+' AND CreatedDate <= '+dmaxT+' AND Id NOT IN (SELECT Timeshare_Owner__c FROM Timeshare__c WHERE Name IN : noMatchTimeshares) AND Id NOT IN (SELECT AccountId FROM Opportunity WHERE (MTRC_Opp_For_SMTN_Loyalty__c = True OR (IsWon = True AND RecordType.DeveloperName = \'Membership_Upgrade\'))) LIMIT 200';
        }
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<Account> scope) {
        
        if(scope.size()>0 && scope != null)
        {
            //system.debug('103='+scope);
            System.debug('scope.size(): '+scope.size());
            Id oppMTRCMembership_UpgradeRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Membership_Upgrade').getRecordTypeId();
            List<Opportunity> oppList = new List<Opportunity>();
            List<Contact> conList = new List<Contact>();
            List<Contact> mainContacts = new List<Contact>();
            MU_Jobs_test_Record_Filter__c testRecordsFilterSettings = MU_Jobs_test_Record_Filter__c.getValues('Filters Enabled');            
            
            for(Account acc : scope){
                //if the custom settings is not checked, this job will run for _test accounts
                if(((!acc.Name.contains('_test')) && (!acc.Name.contains('_Test'))) || !(testRecordsFilterSettings != null && testRecordsFilterSettings.My_Travel_Rewards_Club__c)){
                    Opportunity opp = new Opportunity();
                    opp.AccountId = acc.Id;
                    Opp.Name = acc.Name;
                    opp.RecordTypeId = oppMTRCMembership_UpgradeRecordTypeId;
                    opp.StageName = 'New';
                    opp.CloseDate = system.Today()+15;
                    //opp.leadassist__Use_Round_Robin__c = 'TRUE';
                    //SRR Boolean Criteria
                    opp.MTRC_Opp_For_SMTN_Loyalty__c = true;
                    //opp.Match_Group_Name__c = 'Membership Upgrade-MTRC for SMTN Loyalty';
                    oppList.add(opp);
                    //NOT A REQUIREMENT - Assignment to Sales Cadence - based in the account main contact
                    //check and add account main contact to mainContacts list
                    //create main contact if it's missing
                    /*if(acc.Contacts.size()==0 || acc.Contacts == null)
{
Contact con = new Contact();                    
con.FirstName = acc.First_Name__c;
con.LastName = acc.Last_Name__c;
con.Email = acc.Email__c;
con.Phone = acc.Phone;                    
con.AccountId = acc.Id;
conList.add(con);
}*/
                }           
            }
            //System.debug('oppList size: '+oppList.size());
            //System.debug('oppList : '+oppList);
            /*if(conList.size()>0 && conList != null)
{
//insert conList;
mainContacts.addAll(conList);
}*/
            if(oppList.size()>0 && oppList != null)
            {
                //system.debug('143='+oppList);
                oppList = GenericMatchGroupAssignmentHandler.assignMatchGroup(oppList, 'Membership Upgrade-MTRC for SMTN Loyalty');
                insert oppList;
            } 
        }
    }
    
    public void finish(Database.BatchableContext bc) {
        //do something 
    }
    
    public void execute(SchedulableContext SC) {
        if(!Test.isRunningTest()){
            database.executebatch(new CreateMTRCOppsForSMTNLoyalty(),200);
        }
    }
    
}