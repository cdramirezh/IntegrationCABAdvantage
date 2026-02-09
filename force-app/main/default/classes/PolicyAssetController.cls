public with sharing class PolicyAssetController {
    @AuraEnabled(cacheable=true)
    public static Map<String, List<sObject>> getPolicyAssets(Id policyId) {
        if (policyId == null) {
            throw new AuraHandledException('Policy ID is required.');
        }

        // Fetch Binder_Request__c related to Policy__c
        Policy__c policy = [
            SELECT Binder_Request__c
            FROM Policy__c
            WHERE Id = :policyId
            LIMIT 1
        ];

        Id binderRequestId = policy.Binder_Request__c;

        if (binderRequestId == null) {
            throw new AuraHandledException('No Binder Request found for this Policy.');
        }

        // Fetch Policy_Draft__c related to Binder_Request__c
        Binder_Request__c binderRequest = [
            SELECT Policy_Draft__c
            FROM Binder_Request__c
            WHERE Id = :binderRequestId
            LIMIT 1
        ];

        Id policyDraftId = binderRequest.Policy_Draft__c;

        if (policyDraftId == null) {
            throw new AuraHandledException('No Policy Draft found for this Binder Request.');
        }

        // Fetch Policy_Vehicle__c, Policy_Trailer__c, and Policy_Driver__c records
        List<Policy_Vehicle__c> vehicles = [
            SELECT Id, Name, Policy__c, Vehicle__c, Vehicle__r.Name
            FROM Policy_Vehicle__c
            WHERE Policy_Draft__c = :policyDraftId
        ];

        List<Policy_Trailer__c> trailers = [
            SELECT Id, Name, Policy__c, Trailer__c, Trailer__r.Name
            FROM Policy_Trailer__c
            WHERE Policy_Draft__c = :policyDraftId
        ];

        List<Policy_Driver__c> drivers = [
            SELECT Id, Name, Policy__c, Driver__c, Driver__r.Name
            FROM Policy_Driver__c
            WHERE Policy_Draft__c = :policyDraftId
        ];

        return new Map<String, List<sObject>>{
            'vehicles' => vehicles,
            'trailers' => trailers,
            'drivers' => drivers
        };
    }

    @AuraEnabled
    public static void updatePolicyAssets(Id policyId, List<Id> vehicleIds, List<Id> trailerIds, List<Id> driverIds) {
        if (policyId == null) {
            throw new AuraHandledException('Policy ID is required.');
        }

        // Update Policy_Vehicle__c
        if (vehicleIds != null && !vehicleIds.isEmpty()) {
            List<Policy_Vehicle__c> vehicles = [
                SELECT Id, Policy__c
                FROM Policy_Vehicle__c
                WHERE Id IN :vehicleIds
            ];
            for (Policy_Vehicle__c vehicle : vehicles) {
                vehicle.Policy__c = policyId;
            }
            update vehicles;
        }

        // Update Policy_Trailer__c
        if (trailerIds != null && !trailerIds.isEmpty()) {
            List<Policy_Trailer__c> trailers = [
                SELECT Id, Policy__c
                FROM Policy_Trailer__c
                WHERE Id IN :trailerIds
            ];
            for (Policy_Trailer__c trailer : trailers) {
                trailer.Policy__c = policyId;
            }
            update trailers;
        }

        // Update Policy_Driver__c
        if (driverIds != null && !driverIds.isEmpty()) {
            List<Policy_Driver__c> drivers = [
                SELECT Id, Policy__c
                FROM Policy_Driver__c
                WHERE Id IN :driverIds
            ];
            for (Policy_Driver__c driver : drivers) {
                driver.Policy__c = policyId;
            }
            update drivers;
        }
    }
}