@IsTest
public class PolicyCoverageControllerTest {
    @TestSetup
    static void setupTestData() {
        // Create test data for Policy_Draft__c, Binder_Request__c, Policy__c, and Coverage__c
        
        // Create a Policy_Draft__c record
        Policy_Draft__c policyDraft = new Policy_Draft__c(Name = 'Test Policy Draft');
        insert policyDraft;
        
        // Create a Binder_Request__c record
        Binder_Request__c binderRequest = new Binder_Request__c(
            Name = 'Test Binder Request',
            Policy_Draft__c = policyDraft.Id
        );
        insert binderRequest;
        
        // Create a Policy__c record
        Policy__c policy = new Policy__c(
            Name = 'Test Policy',
            Binder_Request__c = binderRequest.Id
        );
        insert policy;

        //Create Coverage_Product__c
        Coverage_Product__c coverageproduct = new Coverage_Product__c(Name = 'General Liability');
        insert coverageproduct;
        
        // Create Coverage__c records related to the Policy_Draft__c
        List<Coverage__c> coverages = new List<Coverage__c>();
        for (Integer i = 1; i <= 3; i++) {
            Coverage__c coverage = new Coverage__c(
                //Name = 'Coverage ' + i,
                Policy_Draft__c = policyDraft.Id,
                //Coverage_Product__r = new Coverage_Product__c(Name = 'General Liabilityf')
                Coverage_Product__r = coverageproduct
            );
            coverages.add(coverage);
        }
        insert coverages;
    }
    
    @IsTest
    static void testGetAvailableCoverages() {
        // Fetch the Policy__c record
        Policy__c policy = [SELECT Id FROM Policy__c LIMIT 1];
        
        // Call the getAvailableCoverages method
        Test.startTest();
        List<Map<String, String>> result = PolicyCoverageController.getAvailableCoverages(policy.Id);
        Test.stopTest();
        
        // Assert that the result contains the correct number of options
        System.assertEquals(3, result.size(), 'There should be 3 available coverages.');
        
        // Assert that the options have correct labels and values
        for (Map<String, String> option : result) {
            System.assert(option.containsKey('label'), 'Option should have a label.');
            System.assert(option.containsKey('value'), 'Option should have a value.');
        }
    }
    
    @IsTest
    static void testSaveSelectedCoverages() {
        // Fetch the Policy__c record
        Policy__c policy = [SELECT Id FROM Policy__c LIMIT 1];
        
        // Fetch the Coverage__c records
        List<Coverage__c> coverages = [SELECT Id FROM Coverage__c WHERE Policy__c = NULL LIMIT 2];
        List<Id> selectedCoverageIds = new List<Id>();
        for (Coverage__c coverage : coverages) {
            selectedCoverageIds.add(coverage.Id);
        }
        
        // Call the saveSelectedCoverages method
        Test.startTest();
        PolicyCoverageController.saveSelectedCoverages(policy.Id, selectedCoverageIds);
        Test.stopTest();
        
        // Assert that the selected Coverage__c records now reference the Policy__c
        List<Coverage__c> updatedCoverages = [SELECT Policy__c FROM Coverage__c WHERE Id IN :selectedCoverageIds];
        for (Coverage__c updatedCoverage : updatedCoverages) {
            System.assertEquals(policy.Id, updatedCoverage.Policy__c, 'The Policy__c field should reference the Policy.');
        }
    }
}