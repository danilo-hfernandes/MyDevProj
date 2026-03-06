trigger ProductTrigger on OpportunityLineItem (after insert, before delete,before update) {
    Apex_Trigger_On_Off__c cs = Apex_Trigger_On_Off__c.getValues('ProductTrigger');
    system.debug('--ProductTrigger--'+cs);
    if(cs != null && cs.isEnable__c){ 
        if(trigger.isAfter && trigger.isInsert){
            /* Vidanta Rebate $300 not in Use /*Optimization 01/02/2025
List<OpportunityLineItem> oppLineItemList = new List<OpportunityLineItem>();
Map<Id,OpportunityLineItem> oppLineItemMap = new Map<Id,OpportunityLineItem>();

oppLineItemList = [Select Id from OpportunityLineItem where 
Id IN: trigger.new and 
Product2Id != null and 
Product2.Name = 'Vidanta Rebate $300' and 
(Opportunity.StageName = 'Closed Won' OR 
Opportunity.StageName = 'Closed Booked' OR 
Opportunity.StageName = 'Closed Won-Deposit')];

for(OpportunityLineItem oppLineItem: oppLineItemList){
oppLineItemMap.put(oppLineItem.Id,oppLineItem);
}

for(OpportunityLineItem oppLineItem: trigger.new){
if(oppLineItemMap.containsKey(oppLineItem.Id)){
oppLineItem.addError('You cannot add Rebate product after Opportunity is Closed.');
}
}*/
            
            ProductTriggerHandler.updateFlagOnOpportunity(trigger.new,trigger.isDelete);
        }
        
        if(trigger.isBefore && trigger.isDelete){
            ProductTriggerHandler.updateFlagOnOpportunity(trigger.old,trigger.isDelete);
            
            Id oppId = null;
            
            for(OpportunityLineItem opp : trigger.old) {
                oppId = opp.OpportunityId; 
                break;
            }
            
            List<Payment__c> paymentList = [Select id FROM Payment__c WHERE Opportunity__c = :oppId];
            List<Opportunity> oppList = [Select id FROM Opportunity WHERE Id =: oppId AND (StageName = 'Closed Won' OR StageName = 'Closed Won-Deposit' OR StageName = 'Closed Booked')];
            String profileName =[Select Id, Name from Profile where Id=:UserInfo.getProfileId()].Name;
            system.debug('Profile Name'+profileName);
            for(OpportunityLineItem opp2 : Trigger.old) {
                if(!paymentList.isEmpty() && profileName != 'System Administrator') {
                    opp2.addError('You can not delete a product that already has a payment');
                }else if(!oppList.isEmpty() && profileName != 'System Administrator') {
                    opp2.addError('You can not delete a product that has a closed Opportunity');
                }
            }
        }
        
        if(trigger.isBefore && trigger.isUpdate){
            Set<String> certificatId = New Set<String>();
            String certid;
            
            List<Cruise_Certificates__c> cruisecert = New List<Cruise_Certificates__c>();
            Map<String,Cruise_Certificates__c> certIdtoRedeemed = New Map<String,Cruise_Certificates__c>();
            for(OpportunityLineItem prd : trigger.new){
                
                if(prd.Certificate_ID__c != Null && trigger.oldMap.get(prd.id).Certificate_ID__c != prd.Certificate_ID__c){
                    certificatId.add(prd.Certificate_ID__c );
                }
                
            }
            if(certificatId.size() > 0 && certificatId != Null){
                cruisecert = [Select Id,Certificate_ID__c,Cruise_Cert_Redeemed__c,Certificate_Balance_Low__c   from Cruise_Certificates__c where Certificate_ID__c IN:certificatId];
            }
            if(cruisecert.size() > 0 && cruisecert != Null){
                Integer count = 0;
                for(Cruise_Certificates__c cert : cruisecert){
                    if(cert.Cruise_Cert_Redeemed__c == False){
                        count = count + 1;
                    }
                    certIdtoRedeemed.put(cert.Certificate_ID__c,cert);
                }
                for(OpportunityLineItem oppprdct : trigger.new){
                    system.debug('t4est==='+oppprdct);
                    system.debug('tttttttt==='+certIdtoRedeemed);
                    if(certIdtoRedeemed.containsKey(oppprdct.Certificate_ID__c) && certIdtoRedeemed.get(oppprdct.Certificate_ID__c).Cruise_Cert_Redeemed__c == True){
                        oppprdct.addError('This Certificate ID is already redeemed');
                    }else{
                        oppprdct.Cruise_Certificate__c = certIdtoRedeemed.get(oppprdct.Certificate_ID__c).Id;
                        certIdtoRedeemed.get(oppprdct.Certificate_ID__c).Cruise_Cert_Redeemed__c = True;
                        certid = oppprdct.Certificate_ID__c;
                    }
                }
                Try{
                    if(count < 20){
                        certIdtoRedeemed.get(certid).Certificate_Balance_Low__c = true;
                    }
                    checkRecursive.productTrigger = false;
                    update certIdtoRedeemed.values();
                    
                }catch(Exception e){
                    system.debug('exception== ' +e);
                }
            }else{
                system.debug('certificatId' + certificatId);
                
                for(OpportunityLineItem prd : trigger.new){
                    if(prd.Certificate_ID__c != Null && trigger.oldMap.get(prd.id).Certificate_ID__c != prd.Certificate_ID__c){
                        prd.Certificate_ID__c.addError('Certificate ID does not exists');
                    }
                    
                }
            }
        }
    }
}