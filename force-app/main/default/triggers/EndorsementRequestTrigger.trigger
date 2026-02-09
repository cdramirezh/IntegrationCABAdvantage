trigger EndorsementRequestTrigger on Endorsement_Request__c (before update) {

    // Get current user's alias
    String currentAlias = [SELECT Alias FROM User WHERE Id = :UserInfo.getUserId()].Alias;

    for (Endorsement_Request__c newRec : Trigger.new) {
        Endorsement_Request__c oldRec = Trigger.oldMap.get(newRec.Id);

        String oldStatus = oldRec.Status__c;
        String newStatus = newRec.Status__c;

        // Case 1: If status is 'Open'
        if (oldStatus == 'Open') {
            // Any user can only move it to 'Verification'
            if (newStatus != 'Open' && newStatus != 'Verification') {
                newRec.addError('You can only move the status from Open to Verification.');
            }
            // Any other field edits are allowed when status is Open — no restrictions
        }

        // Case 2: If status is 'Verification'
        else if (oldStatus == 'Verification') {
            if (currentAlias != 'Kpino') {
                newRec.addError('Only Kpino can update the record when the status is Verification or beyond.');
            }
        }

        // Case 3: If status is anything else
        else {
            if (currentAlias != 'Kpino') {
                newRec.addError('Only Kpino can edit the record when the status is not Open.');
            }
        }
    }
}