@isTest
private class EndorsementRequestPolicyControllerTest {

@IsTest
    static void testGetPoliciesByOpportunity() {
        // Create test Endorsement_Request__c record
        Endorsement_Request__c endorsementRequest = new Endorsement_Request__c();
        insert endorsementRequest;

        // Create test Policy__c records
        List<Policy__c> policies = new List<Policy__c>();
        for (Integer i = 0; i < 5; i++) {
            policies.add(new Policy__c(
                Opportunity__c = endorsementRequest.Opportunity__c,
                Status__c = 'Active'
            ));
        }
        insert policies;

        // Call the method to test
        List<Policy__c> result = EndorsementRequestPolicyController.getPoliciesByOpportunity(endorsementRequest.Id);
        Map<String, Object> response = EndorsementRequestPolicyController.createEndorsementPolicies(endorsementRequest.Id, new List<Id>{policies[0].Id});
        

        // Assert the result
        System.assertEquals(policies.size(), result.size());
    }
}