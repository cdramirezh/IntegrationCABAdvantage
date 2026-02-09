public with sharing class PolicyDraftCoverageController {

    @AuraEnabled(cacheable=true)
    public static List<Coverage_Product__c> getAvailableCoverageProducts() {
        // Query to fetch available Coverage Products
        return [SELECT Id, Name FROM Coverage_Product__c];
    }

    @AuraEnabled
    public static void createCoverages(List<Id> selectedCoverageProductIds, Id policyDraftId) {
        List<Coverage__c> coveragesToCreate = new List<Coverage__c>();

        for (Id coverageProductId : selectedCoverageProductIds) {
            // Create Coverage__c records based on the selected Coverage_Product__c
            Coverage__c newCoverage = new Coverage__c();
            newCoverage.Coverage_Product__c = coverageProductId;
            newCoverage.Policy_Draft__c = policyDraftId;
            coveragesToCreate.add(newCoverage);
        }

        // Insert all coverages in bulk
        insert coveragesToCreate;
    }
}