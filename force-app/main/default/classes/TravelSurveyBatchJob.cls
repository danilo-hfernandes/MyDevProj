global class TravelSurveyBatchJob implements Schedulable, Database.Batchable<SObject> {
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = '';
        if(!Test.isRunningTest()){
            query = 'SELECT Id, Phone__c, Survey_Sent_Date__c, Survey_Status__c, Step__c, Messaging_Session_Date__c FROM Travel_Survey__c ' + 
                       'WHERE Rating__c = NULL AND Survey_Status__c = \'Waiting for Response\' ' +
                       'AND CreatedDate >= LAST_N_DAYS:1';
        } else
        {
            query = 'SELECT Id, Phone__c, Survey_Sent_Date__c, Survey_Status__c, Step__c, Messaging_Session_Date__c FROM Travel_Survey__c ' + 
                       'WHERE CreatedDate >= LAST_N_DAYS:1 LIMIT 20';
        }
        system.debug('query:'+query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Travel_Survey__c> surveyList) {
        if (surveyList.isEmpty()) return;

        Map<String, Id> phoneToSurveyMap = new Map<String, Id>();
        Map<String, Datetime> createdToSurveyMap = new Map<String, Datetime>();
        
        for (Travel_Survey__c survey : surveyList) {
            String actorName = '+1' + survey.Phone__c;
            phoneToSurveyMap.put(actorName, survey.Id);
            createdToSurveyMap.put(actorName, survey.Messaging_Session_Date__c);
        }

        // get Messagingsession records from channel 
		string channelKey = '';
        Boolean runningInASandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
        if (!runningInASandbox) {
            	channelKey = '+18335503944';
            }
        Else {
            	channelKey = '+18335503950';
            }
        system.debug('channelKey:'+channelKey);

        List<MessagingSession> sessions = [ 
            SELECT id 
            FROM MessagingSession  
            WHERE ChannelKey = :channelKey 
            AND CreatedDate >= LAST_N_DAYS:1
        ];                
        system.debug('sessions:'+sessions);
        
        // Fetch conversation entries for matching ActorNames
        List<ConversationEntry> conversations = [ 
            SELECT ActorName, Message, CreatedDate 
            FROM ConversationEntry 
            WHERE ActorType = 'EndUser' 
            AND ActorName IN :phoneToSurveyMap.keySet()
            AND ConversationId IN :sessions
            //AND CreatedDate > :createdToSurveyMap.keySet()
            ORDER BY CreatedDate DESC
        ];                
        
        system.debug('phoneToSurveyMap.keySet():'+phoneToSurveyMap.keySet());
        system.debug('conversations:'+conversations);
        Map<Id, Travel_Survey__c> surveyUpdates = new Map<Id, Travel_Survey__c>();

        system.debug('before For ConversationEntry');
        for (ConversationEntry entry : conversations) {
            Id surveyId = phoneToSurveyMap.get(entry.ActorName);
	        Datetime created = createdToSurveyMap.get(entry.ActorName);
	        system.debug('entry:'+entry);
	        system.debug('surveyId:'+surveyId);
	        system.debug('surveyUpdates:'+surveyUpdates);
            if (surveyId != null && !surveyUpdates.containsKey(surveyId)) {
	            if (created < entry.createdDate) {
                    system.debug('entered If ');
                    Integer rating;
                    try {
                        rating = Integer.valueOf(entry.Message);
                        system.debug('rating: '+rating);
                        if (rating >= 1 && rating <= 10) {
                            // Update the survey record with both Rating and Response Date
                            Travel_Survey__c ts = new Travel_Survey__c(
                                Id = surveyId, 
                                Rating__c = rating, 
                                Survey_Response_Date__c = entry.CreatedDate.date(),
                                Survey_Status__c = 'Answered'
                            );
                            system.debug('surveyId: '+surveyId);
                            system.debug('ts: '+ts);
                            surveyUpdates.put(surveyId, ts);
                            //break;
                        }
                    } catch (Exception e) {
                        // Ignore non-numeric messages
                    }
            	}
            }
        }

        // Update the surveys
        if (!surveyUpdates.isEmpty()) {
            update surveyUpdates.values(); //commented for test <<<
        }
    }

    global void finish(Database.BatchableContext BC) {
        System.debug('Batch Job Completed.');
    }

    global void execute(SchedulableContext SC) {
        Database.executeBatch(new TravelSurveyBatchJob(), 200);
    }
}