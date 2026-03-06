@RestResource(urlMapping='/CreateChatterUser/*')
global class CreateChatterUserServices {
    @Httppost
    global static void createUser(){
        RestRequest req = RestContext.request;
        try{
            
            List<Profile> profile = [SELECT Id FROM Profile WHERE Name = 'Chatter Free User' LIMIT 1];
            
            if(profile.size()>0){
                system.debug('req.requestBody.toString()=== '+req.requestBody.toString());
                Map<String,Object> userDetails = (Map<String,Object>)JSON.deserializeUntyped(req.requestBody.toString());
                system.debug('userDetails== '+userDetails);
                
                system.debug('User.LastName== '+userDetails.containsKey('LastName'));
                
                String emailAddress = userDetails.containsKey('Email')? String.valueOf(userDetails.get('Email')): '';                
                
                if(emailAddress != '' && emailAddress != null){
                    
                    List<User> userList = [Select id,Name,IsActive from User where Email =: emailAddress Limit 1];
                    
                    if(userDetails.containsKey('ActiveStatus') == true && userDetails.get('ActiveStatus') != null && userDetails.get('ActiveStatus') != '' 
                       && userList.size()>0){
                           if(userList[0].IsActive != boolean.valueof(userDetails.get('ActiveStatus'))){
                               userList[0].IsActive = boolean.valueof(userDetails.get('ActiveStatus'));
                               update userList[0];
                               system.debug('user active status === '+userList[0].IsActive);
                           }
                       }else{
                           User userRecord = new User();
                           userRecord.LastName = userDetails.containsKey('LastName')? String.valueOf(userDetails.get('LastName')): '';
                           userRecord.FirstName = userDetails.containsKey('FirstName')? String.valueOf(userDetails.get('FirstName')): '';
                           userRecord.Alias = userDetails.containsKey('Alias')? String.valueOf(userDetails.get('Alias')): '';
                           userRecord.CommunityNickname = userDetails.containsKey('CommunityNickname')? String.valueOf(userDetails.get('CommunityNickname')): '';
                           userRecord.Email = userDetails.containsKey('Email')? String.valueOf(userDetails.get('Email')): '';
                           userRecord.Username = userDetails.containsKey('Username')? String.valueOf(userDetails.get('Username')): '';
                           userRecord.ProfileId  = profile[0].Id;
                           userRecord.IsActive = true;
                           userRecord.TimeZoneSidKey = 'GMT';
                           userRecord.LanguageLocaleKey = 'en_US';
                           userRecord.EmailEncodingKey = 'UTF-8';
                           userRecord.LocaleSidKey = 'en_US';
                           insert userRecord;
                           system.debug('userRecord == '+userRecord);
                       }
                    
                }
            }
        }catch(Exception ex){
            System.debug('Exception occurrred on LineNumber:' + ex.getLineNumber() + ', Message:' + ex.getMessage());
        }
    }
}