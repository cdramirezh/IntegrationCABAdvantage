public with sharing class OppPoliciesAndCoverages {
    
    @AuraEnabled(cacheable=true)
    public static List<PolicyWrapper> getPoliciesWithCoverages(Id opportunityId) {
        List<PolicyWrapper> policiesWithCoverages = new List<PolicyWrapper>();
        
        // Retrieve all Policy__c records related to the Opportunity
        List<Policy__c> policies = [
            SELECT Id, Name, Effective_Date__c, Expiration_Date__c, Premium__c, Status__c, 	MGA_Company__r.Name, Insurance_Company__r.Name                   
            FROM Policy__c 
            WHERE Opportunity__c = :opportunityId
        ];
        
        // For each policy, retrieve the related Coverages__c
        for (Policy__c policy : policies) {
            List<Coverage__c> coverages = [
                SELECT Id, Name, Coverage_Product__r.Name, 	Limit__c, Deductible__c, Insurance_Company__r.Name
                FROM Coverage__c 
                WHERE Policy__c = :policy.Id
            ];
            policiesWithCoverages.add(new PolicyWrapper(policy, coverages));
        }
        
        return policiesWithCoverages;
    }

    public class PolicyWrapper {
        @AuraEnabled public Policy__c policy { get; set; }
        @AuraEnabled public List<Coverage__c> coverages { get; set; }
        
        public PolicyWrapper(Policy__c policy, List<Coverage__c> coverages) {
            this.policy = policy;
            this.coverages = coverages;
        }
    }
}