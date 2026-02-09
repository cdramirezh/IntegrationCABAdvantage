trigger PolicyVehicleRestrictionsTrigger on Policy_Vehicle__c (before insert, before update, before delete) {
    // Get the current user's alias
    String userAlias = UserInfo.getUserName();
    Boolean isAllowedUser = userAlias == 'techcenter-qhcy@force.com';

    // Map to store the statuses of related Policy_Draft__c records
    Map<Id, String> policyDraftStatuses = new Map<Id, String>();

    // Collect Policy_Draft__c IDs from Policy_Vehicle__c records in the trigger context
    Set<Id> policyDraftIds = new Set<Id>();
    if (Trigger.isInsert || Trigger.isUpdate || Trigger.isDelete) {
        for (Policy_Vehicle__c record : (Trigger.isInsert ? Trigger.new : Trigger.old)) {
            if (record.Policy_Draft__c != null) {
                policyDraftIds.add(record.Policy_Draft__c);
            }
        }
    }

    // Query related Policy_Draft__c records to get their statuses
    if (!policyDraftIds.isEmpty()) {
        for (Policy_Draft__c policyDraft : [
            SELECT Id, Status__c 
            FROM Policy_Draft__c 
            WHERE Id IN :policyDraftIds
        ]) {
            policyDraftStatuses.put(policyDraft.Id, policyDraft.Status__c);
        }
    }

    // Validate insertions
    if (Trigger.isInsert) {
        for (Policy_Vehicle__c record : Trigger.new) {
            if (record.Policy_Draft__c != null &&
                policyDraftStatuses.get(record.Policy_Draft__c) == 'Ready to Bind') {
                record.addError('You cannot create a Policy Vehicle record because the related Policy Draft is in "Ready to Bind" status.');
            }
        }
    }

    // Validate updates
    if (Trigger.isUpdate) {
        for (Policy_Vehicle__c record : Trigger.new) {
            Policy_Vehicle__c oldRecord = Trigger.oldMap.get(record.Id);

            // Restrict updates if the related Policy_Draft__c.Status__c is "Ready to Bind"
            if (record.Policy_Draft__c != null &&
                policyDraftStatuses.get(record.Policy_Draft__c) == 'Ready to Bind') {
                record.addError('You cannot update this Policy Vehicle record because the related Policy Draft is in "Ready to Bind" status.');
            }

            // Restrict updates if Policy__c is populated and the user is not allowed
            if (!isAllowedUser && oldRecord.Policy__c != null) {
                record.addError('You are not allowed to update this record because it is related to a Policy.');
            }
        }
    }

    // Validate deletions
    if (Trigger.isDelete) {
        for (Policy_Vehicle__c record : Trigger.old) {
            // Restrict deletions if the related Policy_Draft__c.Status__c is "Ready to Bind"
            if (record.Policy_Draft__c != null &&
                policyDraftStatuses.get(record.Policy_Draft__c) == 'Ready to Bind') {
                record.addError('You cannot delete this Policy Vehicle record because the related Policy Draft is in "Ready to Bind" status.');
            }

            // Restrict deletions if Policy__c is populated and the user is not allowed
            if (!isAllowedUser && record.Policy__c != null) {
                record.addError('You are not allowed to delete this record because it is related to a Policy.');
            }
        }
    }
}