trigger PolicyDraftRestrictionsTrigger on Policy_Draft__c (before update, before delete) {
    // Get the current user's alias
    String userAlias = UserInfo.getUserName();
    Boolean isAllowedUser = userAlias == 'techcenter-qhcy@force.com';
    //Boolean isAllowedUser = userAlias == 'techcenter-qhcy@force.com.vantcrm3';

    // Restrict updates
    if (Trigger.isUpdate) {
        for (Policy_Draft__c record : Trigger.new) {
            Policy_Draft__c oldRecord = Trigger.oldMap.get(record.Id);
            
            // Check if the Status__c is "Ready to Bind" and if the user is not allowed
            if (oldRecord.Status__c == 'Ready to Bind' && !isAllowedUser) {
                record.addError('You cannot update this Policy Draft record because its status is "Ready to Bind" and you are not authorized.');
            }
        }
    }

    // Restrict deletions
    if (Trigger.isDelete) {
        for (Policy_Draft__c record : Trigger.old) {
            // Check if the Status__c is "Ready to Bind" and if the user is not allowed
            if (record.Status__c == 'Ready to Bind' && !isAllowedUser) {
                record.addError('You cannot delete this Policy Draft record because its status is "Ready to Bind" and you are not authorized.');
            }
        }
    }
}