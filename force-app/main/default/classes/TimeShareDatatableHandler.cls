public class TimeShareDatatableHandler {
 @AuraEnabled
    public static List<Timeshare__c> getTimeShare(Id OppId){
        Opportunity AccountId =[SELECT Id,AccountId From  Opportunity Where Id=:OppId ];
        Id AccountOpp = AccountId.AccountId;
        return [SELECT Id,Name  FROM Timeshare__c where Timeshare_Owner__c=:AccountOpp];                       
    }   
    
    @AuraEnabled 
    public static String addToOpportunity(String OppId, String timeShareId){  
       // recordId = '0067g00000FmXkaAAF'; // membership
       // recordId = '0063t00000wL43kAAC';
        
        List<Opportunity> updateOppList= new lisT<Opportunity>();
            List<Opportunity> oppList = [select id,AccountId,Timeshare_1__c,Timeshare_2__c,Timeshare_3__c,Timeshare_4__c,Timeshare_5__c,Timeshare_6__c,
                                         Timeshare_7__c,Timeshare_8__c,Timeshare_9__c,Timeshare_10__c,
                                         Timeshare_1__r.Name,Timeshare_2__r.Name,Timeshare_3__r.Name,Timeshare_4__r.Name,Timeshare_5__r.Name,
                                         Timeshare_6__r.Name,Timeshare_7__r.Name,Timeshare_8__r.Name,Timeshare_9__r.Name,Timeshare_10__r.Name,
                                         TS_1_Mortgage__c,TS_2_Mortgage__c,TS_3_Mortgage__c,TS_4_Mortgage__c,TS_5_Mortgage__c,TS_6_Mortgage__c,
                                         TS_7_Mortgage__c,
                                         Forbidden_or_Accepted_1__c,Forbidden_or_Accepted_2__c,Forbidden_or_Accepted_3__c,Forbidden_or_Accepted_4__c,Forbidden_or_Accepted_5__c,
                                         Forbidden_or_Accepted_6__c,Forbidden_or_Accepted_7__c,Forbidden_or_Accepted_8__c,Forbidden_or_Accepted_9__c,Forbidden_or_Accepted_10__c,
                                         RecordTypeId,RecordType.Name,RecordType.DeveloperName
                                         
                                         from Opportunity where Id =:OppId];
            system.debug('317='+oppList);
        set<String> timeshareIds=new Set<String>();
        
        for(opportunity opp :oppList){
            timeshareIds.add(opp.Timeshare_1__c);
            timeshareIds.add(opp.Timeshare_2__c);
            timeshareIds.add(opp.Timeshare_3__c);
            timeshareIds.add(opp.Timeshare_4__c);
            timeshareIds.add(opp.Timeshare_5__c);
            timeshareIds.add(opp.Timeshare_6__c);
            timeshareIds.add(opp.Timeshare_7__c);
            timeshareIds.add(opp.Timeshare_8__c);
            timeshareIds.add(opp.Timeshare_9__c);
            timeshareIds.add(opp.Timeshare_10__c);
        }
            List<OpportunityLineItem> oppLineitemList = [select id,Name,product2.Name,product2.Family,Timeshare__c from OpportunityLineItem where OpportunityId =:OppId];
            system.debug('--oppLineitemList--'+oppLineitemList.size());
            Map<Id,Id> isProductAdded = new Map<Id,Id>();
            Map<Id,String> isProductAddedName = new Map<Id,String>();
            for(OpportunityLineItem opLineitem : oppLineitemList){
                isProductAdded.put(opLineitem.Timeshare__c,opLineitem.Id);
                isProductAddedName.put(opLineitem.Timeshare__c,opLineitem.Name);
            }
            Id profileId=userinfo.getProfileId();
            
            String result;
        list<Timeshare__c> TSList=new list<Timeshare__c>();
        TSList=[SELECT Id, Mortgage_Balance__c, Preferred_Company__c FROM Timeshare__c where id=:timeShareId];
        
/*        
        if(timeshareIds.contains(TSList[0].Id)){  //HMR-601 allowing a timeshare to be used for multiple products - Phase 2 
            
            return 'Exist';
        }
        else{
*/            
            if(oppList != null && oppList.size() > 0){
                Opportunity opp = oppList[0];
                // Timeshare 1
                if(opp.Timeshare_1__c == null){
                    
                    opp.Timeshare_1__c =TSList[0].id ;
                    //     opp.Forbidden_or_Accepted_1__c=TSList[0].Preferred_Company__c;
                    //opp.TS_1_Mortgage__c=TSList[0].Mortgage_Balance__c;
                    updateOppList.add(opp);
                    
                }
                // Timeshare 2
                else if(opp.Timeshare_2__c == null){
                    opp.Timeshare_2__c =TSList[0].id ;
                    //    opp.Forbidden_or_Accepted_2__c=TSList[0].Preferred_Company__c;
                    //opp.TS_2_Mortgage__c=TSList[0].Mortgage_Balance__c;
                    updateOppList.add(opp);
                }
                // Timeshare 3
                else if(opp.Timeshare_3__c == null){
                    opp.Timeshare_3__c =TSList[0].id ;
                    //    opp.Forbidden_or_Accepted_3__c=TSList[0].Preferred_Company__c;
                    //opp.TS_3_Mortgage__c=TSList[0].Mortgage_Balance__c;
                    updateOppList.add(opp);
                }
                // Timeshare 4
                else if(opp.Timeshare_4__c == null){
                    opp.Timeshare_4__c =TSList[0].id ;
                    //    opp.Forbidden_or_Accepted_4__c=TSList[0].Preferred_Company__c;
                    //opp.TS_4_Mortgage__c=TSList[0].Mortgage_Balance__c;
                    updateOppList.add(opp);
                }
                // Timeshare 5
                else if(opp.Timeshare_5__c == null){
                    opp.Timeshare_5__c =TSList[0].id ;
                    //    opp.Forbidden_or_Accepted_5__c=TSList[0].Preferred_Company__c;
                    //opp.TS_5_Mortgage__c=TSList[0].Mortgage_Balance__c;
                    updateOppList.add(opp);
                }
                // Timeshare 6
                else  if(opp.Timeshare_6__c == null){
                    opp.Timeshare_6__c =TSList[0].id ;
                    opp.Forbidden_or_Accepted_6__c=TSList[0].Preferred_Company__c;
                    //opp.TS_6_Mortgage__c=TSList[0].Mortgage_Balance__c;
                    updateOppList.add(opp);
                }
                // Timeshare 7
                else if(opp.Timeshare_7__c == null){
                    opp.Timeshare_7__c =TSList[0].id ;
                    opp.Forbidden_or_Accepted_7__c=TSList[0].Preferred_Company__c;
                    //opp.TS_7_Mortgage__c=TSList[0].Mortgage_Balance__c;
                    updateOppList.add(opp);
                }
                // Timeshare 8
                else if(opp.Timeshare_8__c == null){
                    opp.Timeshare_8__c =TSList[0].id ;
                    opp.Forbidden_or_Accepted_8__c=TSList[0].Preferred_Company__c;
                    //opp.TS_8_Mortgage__c=TSList[0].Mortgage_Balance__c;
                    updateOppList.add(opp);
                }
                // Timeshare 9
                else if(opp.Timeshare_9__c == null){
                    opp.Timeshare_9__c =TSList[0].id ;
                    opp.Forbidden_or_Accepted_9__c=TSList[0].Preferred_Company__c;
                    //opp.TS_9_Mortgage__c=TSList[0].Mortgage_Balance__c;
                    updateOppList.add(opp);
                }
                
                // Timeshare 10
                else if(opp.Timeshare_10__c == null){
                    opp.Timeshare_10__c =TSList[0].id ;
                    // opp.Forbidden_or_Accepted_10__c=TSList[0].Preferred_Company__c;
                    //opp.TS_10_Mortgage__c=TSList[0].Mortgage_Balance__c;
                    updateOppList.add(opp);
                }
                
                
            }
            
            if(updateOppList.size()>0){
                
                update updateOppList;
                return 'Success';
            }
            else{
                return 'Fail';
            }
/*            
        }
*/        
        
        //return listTimeshareWrapper; 
    } 
}