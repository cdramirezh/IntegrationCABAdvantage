@isTest
private class OppPoliciesAndCoveragesTest {


@IsTest
    static void testGetPoliciesWithCoverages() {
        // Create a test Opportunity
        Opportunity testOpp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today()
        );
        insert testOpp;
        
        // Create a test Policy__c related to the test Opportunity
        Policy__c testPolicy = new Policy__c(
            Opportunity__c = testOpp.Id,
            Status__c = 'Active'
        );
        insert testPolicy;
        
        // Create a test Coverage__c related to the test Policy__c
        Coverage__c testCoverage = new Coverage__c(
            Policy__c = testPolicy.Id
        );
        insert testCoverage;
        
        // Call the method to retrieve policies with coverages
        List<OppPoliciesAndCoverages.PolicyWrapper> result = OppPoliciesAndCoverages.getPoliciesWithCoverages(testOpp.Id);
        
        // Assert that the result is not null and contains the expected number of policies
        System.assertNotEquals(null, result);
        System.assertEquals(1, result.size());
        
        // Assert that the policy and coverages are correctly set in the wrapper
        OppPoliciesAndCoverages.PolicyWrapper wrapper = result[0];
        System.assertEquals(testPolicy.Id, wrapper.policy.Id);
        System.assertEquals(1, wrapper.coverages.size());
        System.assertEquals(testCoverage.Id, wrapper.coverages[0].Id);
    }
}