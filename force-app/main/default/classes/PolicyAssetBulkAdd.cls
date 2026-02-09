public with sharing class PolicyAssetBulkAdd {
    @AuraEnabled(cacheable=true)
    public static List<Vehicle__c> getVehicles(Id policyDraftId) {
        Policy_Draft__c policyDraft = [SELECT Opportunity__c, Lead__c FROM Policy_Draft__c WHERE Id = :policyDraftId LIMIT 1];

        if (policyDraft.Opportunity__c != null) {
            Opportunity opp = [SELECT AccountId FROM Opportunity WHERE Id = :policyDraft.Opportunity__c LIMIT 1];
            return [SELECT Id, Name FROM Vehicle__c WHERE Account__c = :opp.AccountId];
        } else {
            return [SELECT Id, Name FROM Vehicle__c WHERE Lead__c = :policyDraft.Lead__c];
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<Trailer__c> getTrailers(Id policyDraftId) {
        Policy_Draft__c policyDraft = [SELECT Opportunity__c, Lead__c FROM Policy_Draft__c WHERE Id = :policyDraftId LIMIT 1];

        if (policyDraft.Opportunity__c != null) {
            Opportunity opp = [SELECT AccountId FROM Opportunity WHERE Id = :policyDraft.Opportunity__c LIMIT 1];
            return [SELECT Id, Name FROM Trailer__c WHERE Account__c = :opp.AccountId];
        } else {
            return [SELECT Id, Name FROM Trailer__c WHERE Lead__c = :policyDraft.Lead__c];
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<Driver__c> getDrivers(Id policyDraftId) {
        Policy_Draft__c policyDraft = [SELECT Opportunity__c, Lead__c FROM Policy_Draft__c WHERE Id = :policyDraftId LIMIT 1];

        if (policyDraft.Opportunity__c != null) {
            Opportunity opp = [SELECT AccountId FROM Opportunity WHERE Id = :policyDraft.Opportunity__c LIMIT 1];
            return [SELECT Id, Name, CDL__c FROM Driver__c WHERE Account__c = :opp.AccountId];
        } else {
            return [SELECT Id, Name, CDL__c FROM Driver__c WHERE Lead__c = :policyDraft.Lead__c];
        }
    }

    @AuraEnabled
    public static void createPolicyAssetRecords(Id policyDraftId, List<Id> vehicleIds, List<Id> trailerIds, List<Id> driverIds) {

        System.debug('Policy Draft ID: ' + policyDraftId);
        System.debug('Vehicle IDs: ' + vehicleIds);
        System.debug('Trailer IDs: ' + trailerIds);
        System.debug('Driver IDs: ' + driverIds);

        // Query existing Policy_Vehicle__c records
        Map<String, Id> existingPolicyVehicles = new Map<String, Id>();
        for (Policy_Vehicle__c pv : [SELECT Id, Vehicle__r.Name FROM Policy_Vehicle__c WHERE Policy_Draft__c = :policyDraftId]) {
            existingPolicyVehicles.put(pv.Vehicle__r.Name, pv.Id);
        }

        // Query existing Policy_Trailer__c records
        Map<String, Id> existingPolicyTrailers = new Map<String, Id>();
        for (Policy_Trailer__c pt : [SELECT Id, Trailer__r.Name FROM Policy_Trailer__c WHERE Policy_Draft__c = :policyDraftId]) {
            existingPolicyTrailers.put(pt.Trailer__r.Name, pt.Id);
        }

        // Query existing Policy_Driver__c records
        Map<String, Id> existingPolicyDrivers = new Map<String, Id>();
        for (Policy_Driver__c pd : [SELECT Id, Driver__r.CDL__c FROM Policy_Driver__c WHERE Policy_Draft__c = :policyDraftId]) {
            existingPolicyDrivers.put(pd.Driver__r.CDL__c, pd.Id);
        }

        // Lists to store new policy asset records
        List<Policy_Vehicle__c> policyVehicles = new List<Policy_Vehicle__c>();
        List<Policy_Trailer__c> policyTrailers = new List<Policy_Trailer__c>();
        List<Policy_Driver__c> policyDrivers = new List<Policy_Driver__c>();

        // Create Policy_Vehicle__c records if not already present
        for (Id vehicleId : vehicleIds) {
            Vehicle__c vehicle = [SELECT Id, Name FROM Vehicle__c WHERE Id = :vehicleId LIMIT 1];
            if (!existingPolicyVehicles.containsKey(vehicle.Name)) {
                policyVehicles.add(new Policy_Vehicle__c(
                    Vehicle__c = vehicleId,
                    Policy_Draft__c = policyDraftId,
                    Status__c = 'Active'
                ));
            }
        }

        // Create Policy_Trailer__c records if not already present
        for (Id trailerId : trailerIds) {
            Trailer__c trailer = [SELECT Id, Name FROM Trailer__c WHERE Id = :trailerId LIMIT 1];
            if (!existingPolicyTrailers.containsKey(trailer.Name)) {
                policyTrailers.add(new Policy_Trailer__c(
                    Trailer__c = trailerId,
                    Policy_Draft__c = policyDraftId,
                    Status__c = 'Active'
                ));
            }
        }

        // Create Policy_Driver__c records if not already present
        for (Id driverId : driverIds) {
            Driver__c driver = [SELECT Id, CDL__c FROM Driver__c WHERE Id = :driverId LIMIT 1];
            if (!existingPolicyDrivers.containsKey(driver.CDL__c)) {
                policyDrivers.add(new Policy_Driver__c(
                    Driver__c = driverId,
                    Policy_Draft__c = policyDraftId,
                    Status__c = 'Active'
                ));
            }
        }

        // Insert records separately for each object type
        if (!policyVehicles.isEmpty()) {
            insert policyVehicles;
        }
        if (!policyTrailers.isEmpty()) {
            insert policyTrailers;
        }
        if (!policyDrivers.isEmpty()) {
            insert policyDrivers;
        }
    }
}