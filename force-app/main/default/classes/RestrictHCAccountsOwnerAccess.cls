public with sharing class RestrictHCAccountsOwnerAccess {
    public static void revokeAccessFromMXNationalProfileOwners() {
        try {
            // Query all sharing entries for HC Accounts owned by MX National Sales agents,MX National Sales Managers  Profile users
            List<AccountShare> sharesToDelete = [SELECT Id 
                                                 FROM AccountShare 
                                                 WHERE RowCause = 'Owner' 
                                                 AND Account.Affiliated_Id__c = 1002243
                                                 AND UserOrGroupId IN (
                                                     SELECT Id 
                                                     FROM User 
                                                     WHERE Profile.Name = 'MX National Sales' and Profile.Name = 'MX National Sales Manager'
                                                 )];
            
            // Delete the ownership-based sharing records
            if (!sharesToDelete.isEmpty()) {
                delete sharesToDelete;
                System.debug('Successfully removed access for ' + sharesToDelete.size() + ' records.');
            } else {
                System.debug('No sharing records found to delete.');
            }
        } catch (Exception e) {
            System.debug('Error while revoking access: ' + e.getMessage());
            throw new AuraHandledException('Error while revoking access: ' + e.getMessage());
        }
    }
}