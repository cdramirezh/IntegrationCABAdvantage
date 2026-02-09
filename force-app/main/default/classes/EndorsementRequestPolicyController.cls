public with sharing class EndorsementRequestPolicyController {
    @AuraEnabled(cacheable=true)
    public static List<Policy__c> getPoliciesByOpportunity(Id endorsementRequestId) {
        // Fetch the related Opportunity
        Endorsement_Request__c endorsementRequest = [
            SELECT Opportunity__c 
            FROM Endorsement_Request__c 
            WHERE Id = :endorsementRequestId
            LIMIT 1
        ];

        // Fetch related policies
        return [
            SELECT Id, Name 
            FROM Policy__c 
            WHERE Opportunity__c = :endorsementRequest.Opportunity__c AND Status__c = 'Active'
        ];
    }

    @AuraEnabled
    public static Map<String, Object> createEndorsementPolicies(Id endorsementRequestId, List<Id> policyIds) {
        Map<String, Object> response = new Map<String, Object>();
        response.put('success', false);

        if (policyIds.isEmpty()) {
            response.put('message', 'No policies selected.');
            return response;
        }

        /*
        // Fetch existing Endorsement_Policy__c records
        Set<Id> existingPolicyIds = new Map<Id, Endorsement_Policy__c>(
            [SELECT Policy__c FROM Endorsement_Policy__c WHERE Endorsement_Request__c = :endorsementRequestId]
        ).keySet();
        */

        Set<Id> existingPolicyIds = new Set<Id>();
            for (Endorsement_Policy__c ep : [SELECT Policy__c FROM Endorsement_Policy__c WHERE Endorsement_Request__c = :endorsementRequestId]) {
                existingPolicyIds.add(ep.Policy__c);
            }


        // Filter out already existing policies
        List<Endorsement_Policy__c> newEndorsementPolicies = new List<Endorsement_Policy__c>();
        for (Id policyId : policyIds) {
            if (!existingPolicyIds.contains(policyId)) {
                newEndorsementPolicies.add(new Endorsement_Policy__c(
                    Endorsement_Request__c = endorsementRequestId,
                    Policy__c = policyId
                ));
            }
        }

        if (newEndorsementPolicies.isEmpty()) {
            response.put('message', 'No new endorsement policies to create. Selected policies are already associated.');
        } else {
            insert newEndorsementPolicies;
            response.put('success', true);
            response.put('message', 'Endorsement Policies created successfully.');
        }

        return response;
    }
}