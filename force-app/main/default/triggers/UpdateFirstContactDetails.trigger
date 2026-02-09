trigger UpdateFirstContactDetails on Contact (after insert, after update, after delete) {
    Set<Id> accountIds = new Set<Id>();

    // Collect the Account Ids impacted by the Contact changes
    if (Trigger.isInsert || Trigger.isUpdate) {
        for (Contact c : Trigger.new) {
            if (c.AccountId != null) {
                accountIds.add(c.AccountId);
            }
        }
    } else if (Trigger.isDelete) {
        for (Contact c : Trigger.old) {
            if (c.AccountId != null) {
                accountIds.add(c.AccountId);
            }
        }
    }

    if (accountIds.isEmpty()) {
        return; // No Accounts to process, exit early.
    }

    List<Account> accountsToUpdate = new List<Account>();

    try {
        // Query for the first contact (ordered by CreatedDate) for each impacted Account
        for (Id accountId : accountIds) {
            List<Contact> contacts = [SELECT Email, Phone 
                                      FROM Contact 
                                      WHERE AccountId = :accountId 
                                      ORDER BY CreatedDate 
                                      LIMIT 1];

            if (!contacts.isEmpty()) { 
                Contact firstContact = contacts[0];
                accountsToUpdate.add(new Account(
                    Id = accountId,
                    First_Contact_Email__c = firstContact.Email,
                    First_Contact_Phone__c = firstContact.Phone
                ));
            }
        }

        // Update the Account records with the first contact's details
        if (!accountsToUpdate.isEmpty()) {
            update accountsToUpdate;
        }
    } catch (Exception e) {
        System.debug('Error updating Account first contact details: ' + e.getMessage());
    }
}