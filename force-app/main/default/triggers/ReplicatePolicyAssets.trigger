trigger ReplicatePolicyAssets on Policy__c (after insert) {
    // Map to hold Policy_Draft__c IDs associated with Policy__c records
    Map<Id, Id> policyDraftMap = new Map<Id, Id>();

    // Collect the Binder_Request__c IDs for the newly created Policy__c records
    Set<Id> binderRequestIds = new Set<Id>();
    for (Policy__c policy : Trigger.new) {
        if (policy.Binder_Request__c != null) {
            binderRequestIds.add(policy.Binder_Request__c);
        }
    }

    // Query the related Binder_Request__c and Policy_Draft__c records
    Map<Id, Id> binderToDraftMap = new Map<Id, Id>();
    if (!binderRequestIds.isEmpty()) {
        for (Binder_Request__c binder : [
            SELECT Id, Policy_Draft__c
            FROM Binder_Request__c
            WHERE Id IN :binderRequestIds
        ]) {
            binderToDraftMap.put(binder.Id, binder.Policy_Draft__c);
        }
    }

    // Map Policy__c to the related Policy_Draft__c
    for (Policy__c policy : Trigger.new) {
        if (policy.Binder_Request__c != null && binderToDraftMap.containsKey(policy.Binder_Request__c)) {
            policyDraftMap.put(policy.Id, binderToDraftMap.get(policy.Binder_Request__c));
        }
    }

    // Collect the Policy_Draft__c IDs
    Set<Id> policyDraftIds = new Set<Id>(policyDraftMap.values());

    // Query the related Policy_Vehicle__c, Policy_Trailer__c, and Policy_Driver__c records
    List<Policy_Vehicle__c> policyVehicles = [
        SELECT Id, Vehicle__c, Policy_Draft__c
        FROM Policy_Vehicle__c
        WHERE Policy_Draft__c IN :policyDraftIds
    ];

    List<Policy_Trailer__c> policyTrailers = [
        SELECT Id, Trailer__c, Policy_Draft__c
        FROM Policy_Trailer__c
        WHERE Policy_Draft__c IN :policyDraftIds
    ];

    List<Policy_Driver__c> policyDrivers = [
        SELECT Id, Driver__c, Policy_Draft__c
        FROM Policy_Driver__c
        WHERE Policy_Draft__c IN :policyDraftIds
    ];

    // Create new records for Policy_Vehicle__c, Policy_Trailer__c, and Policy_Driver__c
    List<Policy_Vehicle__c> newPolicyVehicles = new List<Policy_Vehicle__c>();
    List<Policy_Trailer__c> newPolicyTrailers = new List<Policy_Trailer__c>();
    List<Policy_Driver__c> newPolicyDrivers = new List<Policy_Driver__c>();

    for (Policy_Vehicle__c vehicle : policyVehicles) {
        for (Policy__c policy : Trigger.new) {
            if (policyDraftMap.get(policy.Id) == vehicle.Policy_Draft__c) {
                newPolicyVehicles.add(new Policy_Vehicle__c(
                    Policy__c = policy.Id,
                    Vehicle__c = vehicle.Vehicle__c,
                    //Policy_Draft__c = vehicle.Policy_Draft__c,
                    Status__c = 'Active'
                ));
            }
        }
    }

    for (Policy_Trailer__c trailer : policyTrailers) {
        for (Policy__c policy : Trigger.new) {
            if (policyDraftMap.get(policy.Id) == trailer.Policy_Draft__c) {
                newPolicyTrailers.add(new Policy_Trailer__c(
                    Policy__c = policy.Id,
                    Trailer__c = trailer.Trailer__c,
                    //Policy_Draft__c = trailer.Policy_Draft__c,
                    Status__c = 'Active'
                ));
            }
        }
    }

    for (Policy_Driver__c driver : policyDrivers) {
        for (Policy__c policy : Trigger.new) {
            if (policyDraftMap.get(policy.Id) == driver.Policy_Draft__c) {
                newPolicyDrivers.add(new Policy_Driver__c(
                    Policy__c = policy.Id,
                    Driver__c = driver.Driver__c,
                    //Policy_Draft__c = driver.Policy_Draft__c,
                    Status__c = 'Active'
                ));
            }
        }
    }

    // Insert the new records
    if (!newPolicyVehicles.isEmpty()) {
        insert newPolicyVehicles;
    }
    if (!newPolicyTrailers.isEmpty()) {
        insert newPolicyTrailers;
    }
    if (!newPolicyDrivers.isEmpty()) {
        insert newPolicyDrivers;
    }
}