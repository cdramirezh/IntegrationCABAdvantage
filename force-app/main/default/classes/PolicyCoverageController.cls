public with sharing class PolicyCoverageController {

    @AuraEnabled(cacheable=true)
    public static List<Map<String, String>> getAvailableCoverages(Id policyId) {
        // Get the Binder_Request__c related to the Policy__c
        Policy__c policy = [SELECT Binder_Request__c FROM Policy__c WHERE Id = :policyId];
        Binder_Request__c binderRequest = [SELECT Policy_Draft__c FROM Binder_Request__c WHERE Id = :policy.Binder_Request__c];

        // Fetch related Coverage__c records through the Policy_Draft__c
        List<Coverage__c> coverages = [
            SELECT Id, Name, Coverage_Product__r.Name
            FROM Coverage__c
            WHERE Policy_Draft__c = :binderRequest.Policy_Draft__c
                  AND Policy__c = NULL
        ];

        // Prepare options for the dual listbox
        List<Map<String, String>> options = new List<Map<String, String>>();
        for (Coverage__c coverage : coverages) {
            Map<String, String> option = new Map<String, String>();
            option.put('label', coverage.Coverage_Product__r.Name);
            option.put('value', coverage.Id);
            options.add(option);
        }

        return options;
    }

    @AuraEnabled
    public static void saveSelectedCoverages(Id policyId, List<Id> selectedCoverageIds) {
        if (policyId == null || selectedCoverageIds == null) {
            throw new AuraHandledException('Policy ID and selected coverage IDs are required.');
        }

        // Fetch the selected Coverages and update their Policy__c lookup field
        List<Coverage__c> selectedCoverages = [
            SELECT Id, Policy__c
            FROM Coverage__c
            WHERE Id IN :selectedCoverageIds
        ];

        for (Coverage__c coverage : selectedCoverages) {
            coverage.Policy__c = policyId;
        }

        update selectedCoverages;
    }
}