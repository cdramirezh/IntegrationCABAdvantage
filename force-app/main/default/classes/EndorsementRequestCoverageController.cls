public with sharing class EndorsementRequestCoverageController {
    @AuraEnabled(cacheable=true)
    public static List<Coverage__c> getCoveragesByEndorsementRequest(Id endorsementRequestId) {
        // Fetch all Policy__c records related to Endorsement_Policy__c for the given Endorsement_Request__c
        List<Endorsement_Policy__c> endorsementPolicies = [
            SELECT Policy__c 
            FROM Endorsement_Policy__c 
            WHERE Endorsement_Request__c = :endorsementRequestId
        ];

        // Extract Policy__c IDs
        Set<Id> policyIds = new Set<Id>();
        for (Endorsement_Policy__c endorsementPolicy : endorsementPolicies) {
            policyIds.add(endorsementPolicy.Policy__c);
        }

        if (policyIds.isEmpty()) {
            return new List<Coverage__c>();
        }

        // Fetch related Coverages
        return [
            SELECT Id, Name, Coverage_Product__r.Name
            FROM Coverage__c
            WHERE Policy__c IN :policyIds
        ];
    }

    @AuraEnabled
    public static Map<String, Object> createEndorsementCoverages(Id endorsementRequestId, List<Id> coverageIds) {
        Map<String, Object> response = new Map<String, Object>();
        response.put('success', false);

        if (coverageIds == null || coverageIds.isEmpty()) {
            response.put('message', 'No coverages selected.');
            return response;
        }

        // Fetch existing Endorsement_Coverage__c for the given Endorsement_Request__c
        Set<Id> existingCoverageIds = new Set<Id>();
        for (Endorsement_Coverage__c ec : [
            SELECT Coverage__c 
            FROM Endorsement_Coverage__c 
            WHERE Endorsement_Request__c = :endorsementRequestId
        ]) {
            existingCoverageIds.add(ec.Coverage__c);
        }

        // Prepare new Endorsement_Coverage__c records for insert
        List<Endorsement_Coverage__c> newEndorsementCoverages = new List<Endorsement_Coverage__c>();
        for (Id coverageId : coverageIds) {
            if (!existingCoverageIds.contains(coverageId)) {
                newEndorsementCoverages.add(new Endorsement_Coverage__c(
                    Endorsement_Request__c = endorsementRequestId,
                    Coverage__c = coverageId
                ));
            }
        }

        if (newEndorsementCoverages.isEmpty()) {
            response.put('message', 'No new endorsements coverages to create. Selected coverages are already associated.');
        } else {
            insert newEndorsementCoverages;
            response.put('success', true);
            response.put('message', 'Endorsements Coverages created successfully.');
        }

        return response;
    }
}