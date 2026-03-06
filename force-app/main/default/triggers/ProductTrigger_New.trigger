trigger ProductTrigger_New on OpportunityLineItem (after insert, before delete,before update) {
    Apex_Trigger_On_Off__c cs = Apex_Trigger_On_Off__c.getValues('ProductTrigger_New');
    system.debug('--ProductTrigger_New--'+cs);
    if(cs != null && cs.isEnable__c){
        // All before insert or before update logic will go here
        if(trigger.isBefore){
            // All before delete logic will go here
            if(trigger.isDelete){
                ProductTriggerHandler.updateFlagOnOpportunity(trigger.old,trigger.isDelete);
                String profileName =[Select Id, Name from Profile where Id=:UserInfo.getProfileId()].Name;
                if(profileName != 'System Administrator' && profileName != 'Tour Generation Manager'){
                    Id oppId = null;
                    for(OpportunityLineItem opp : trigger.old) {
                        oppId = opp.OpportunityId; 
                        break;
                    }
                    List<Payment__c> paymentList = [Select id FROM Payment__c WHERE Opportunity__c = :oppId];
                    List<Opportunity> oppList = [Select id FROM Opportunity WHERE Id =: oppId AND (StageName = 'Closed Won' OR StageName = 'Closed Won-Deposit' OR StageName = 'Closed Booked')];
                    for(OpportunityLineItem opp2 : Trigger.old) {
                        if(!paymentList.isEmpty()) {
                            opp2.addError('You can not delete a product that already has a payment');
                        }else if(!oppList.isEmpty()) {
                            opp2.addError('You can not delete a product that has a closed Opportunity');
                        }
                    }
                }
            }
            // All before update logic will go here
            if(trigger.isUpdate){
                // MX vouhcer product update changes
                
                List<OpportunityLineItem> oppLineItemList = [Select Id ,File_Fee__c,Certificate_Type__c,Opportunity.First_Payment_Date__c from OpportunityLineItem where 
                                                             Id IN: trigger.new and
                                                             Product2.Name = 'MX Voucher' and Opportunity.First_Payment_Date__c != null];
                system.debug('--oppLineItemList--'+oppLineItemList); 
                if(oppLineItemList != null && oppLineItemList.size() > 0){
                    for(OpportunityLineItem oppLi : oppLineItemList){
                        OpportunityLineItem oldoppI = Trigger.oldMap.get(oppLi.Id);
                        Id profileId=userinfo.getProfileId();
                        String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
                        system.debug('--profileName--'+profileName);
                        List<Profile_Permission_Block__c> profileList = [select name,Profile_Name__c from Profile_Permission_Block__c where Profile_Name__c =: profileName];
                        system.debug('--profileList--'+profileList);
                        if(profileList == null || profileList.size() == 0){
                            if(oppLi != oldoppI){
                                Trigger.newMap.get(oppLi.Id).addError('You do not have permision to change the record post payment'); 
                            }
                        }
                        
                        
                    }
                }
                
                
                // Certificate related
                Set<String> certificatId = New Set<String>();
                String certid;
                
                Map<String,Certificate__c> certIdtoRedeemed = New Map<String,Certificate__c>();
                for(OpportunityLineItem prd : trigger.new){
                    if(prd.Certificate_ID__c != Null && trigger.oldMap.get(prd.id).Certificate_ID__c != prd.Certificate_ID__c){
                        certificatId.add(prd.Certificate_ID__c );
                    }
                }
                List<Certificate__c> cruisecert = New List<Certificate__c>();
                if(certificatId.size() > 0 && certificatId != Null){
                    List<Certificate__c> certificateType = [Select Id,Certificate_ID__c,Coupon_Type__c   from Certificate__c where Certificate_ID__c IN:certificatId];
                    set<String> setCouponType = new set<String>();
                    if(certificateType != null && certificateType.size() > 0) {
                        for(Certificate__c objcert : certificateType){
                            setCouponType.add(objcert.Coupon_Type__c);
                        }
                        system.debug('-certificateType[0].Coupon_Type__c---'+certificateType[0].Coupon_Type__c);
                        cruisecert = [Select Id,Certificate_ID__c,Coupon_Type__c,Certificate_Redeemed__c,Certificate_Balance_Low__c from Certificate__c where Coupon_Type__c IN : setCouponType /*where Certificate_ID__c IN:certificatId*/];
                    }
                }
                if(cruisecert.size() > 0 && cruisecert != Null){
                    Integer count = 0;
                    for(Certificate__c cert : cruisecert){
                        if(cert.Certificate_Redeemed__c == False){
                            count = count + 1;
                        }
                        system.debug('-count-'+count);
                        if(certificatId.contains(cert.Certificate_ID__c)){
                            certIdtoRedeemed.put(cert.Certificate_ID__c,cert);
                        }
                    }
                    for(OpportunityLineItem oppprdct : trigger.new){
                        if(certIdtoRedeemed.containsKey(oppprdct.Certificate_ID__c) && certIdtoRedeemed.get(oppprdct.Certificate_ID__c).Certificate_Redeemed__c == True){
                            oppprdct.addError('This Certificate ID is already redeemed');
                        }else{
                            if(certIdtoRedeemed.containsKey(oppprdct.Certificate_ID__c)){
                                oppprdct.Certificate_Product__c = certIdtoRedeemed.get(oppprdct.Certificate_ID__c).Id;
                                oppprdct.Certificate_Type__c = certIdtoRedeemed.get(oppprdct.Certificate_ID__c).Coupon_Type__c;
                                certIdtoRedeemed.get(oppprdct.Certificate_ID__c).Certificate_Redeemed__c = True;
                                certid = oppprdct.Certificate_ID__c;
                            }
                        }
                    }
                    Try{
                        system.debug('-count-'+count);
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
        // All after insert or after update logic will go here
        if(trigger.isAfter){
            // All after insert logic will go here
            if(trigger.isInsert){
                /*
List<OpportunityLineItem> oppLineItemList = new List<OpportunityLineItem>();
Map<Id,OpportunityLineItem> oppLineItemMap = new Map<Id,OpportunityLineItem>();

oppLineItemList = [Select Id from OpportunityLineItem where 
Id IN: trigger.new and 
Product2Id != null and 
Product2.Name = 'Vidanta Rebate $200' and 
(Opportunity.StageName = 'Closed Won' OR 
Opportunity.StageName = 'Closed Booked' OR v
Opportunity.StageName = 'Closed Won-Deposit')];

for(OpportunityLineItem oppLineItem: oppLineItemList){
oppLineItemMap.put(oppLineItem.Id,oppLineItem);
}

for(OpportunityLineItem oppLineItem: trigger.new){
if(oppLineItemMap.containsKey(oppLineItem.Id)){
oppLineItem.addError('You cannot add Rebate product after Opportunity is Closed.');
}
}
*/
                ProductTriggerHandler.updateFlagOnOpportunity(trigger.new,trigger.isDelete);
            }
        }
    }
}