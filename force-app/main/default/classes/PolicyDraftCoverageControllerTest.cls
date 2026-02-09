@isTest
public class PolicyDraftCoverageControllerTest {

    @testSetup
    static void setupTestData() {
        // Create test Coverage Products
        List<Coverage_Product__c> coverageProducts = new List<Coverage_Product__c>();
        for (Integer i = 0; i < 3; i++) {
            coverageProducts.add(new Coverage_Product__c(Name = 'Coverage Product ' + i));
        }
        insert coverageProducts;

        // Create a test Policy Draft record
        Policy_Draft__c policyDraft = new Policy_Draft__c(Name = 'Test Policy Draft');
        insert policyDraft;
    }

    @isTest
    static void testGetAvailableCoverageProducts() {
        // Execute the method to get available coverage products
        Test.startTest();
        List<Coverage_Product__c> coverageProducts = PolicyDraftCoverageController.getAvailableCoverageProducts();
        Test.stopTest();

        // Assertions
        System.assertNotEquals(null, coverageProducts, 'The returned list should not be null.');
        System.assertEquals(3, coverageProducts.size(), 'There should be three coverage products returned.');
        System.assertEquals('Coverage Product 0', coverageProducts[0].Name, 'The name of the first coverage product should match.');
    }

    @isTest
    static void testCreateCoverages() {
        // Retrieve test data
        List<Coverage_Product__c> coverageProducts = [SELECT Id FROM Coverage_Product__c];
        Policy_Draft__c policyDraft = [SELECT Id FROM Policy_Draft__c LIMIT 1];

        // Prepare selected coverage product IDs for the test
        List<Id> selectedCoverageProductIds = new List<Id>();
        for (Coverage_Product__c product : coverageProducts) {
            selectedCoverageProductIds.add(product.Id);
        }

        // Execute the method to create coverages
        Test.startTest();
        PolicyDraftCoverageController.createCoverages(selectedCoverageProductIds, policyDraft.Id);
        Test.stopTest();

        // Query and validate created Coverage__c records
        List<Coverage__c> createdCoverages = [SELECT Id, Coverage_Product__c, Policy_Draft__c FROM Coverage__c WHERE Policy_Draft__c = :policyDraft.Id];
        
        System.assertEquals(3, createdCoverages.size(), 'Three coverages should have been created.');
        for (Coverage__c coverage : createdCoverages) {
            System.assert(selectedCoverageProductIds.contains(coverage.Coverage_Product__c), 'Coverage product ID should match one of the selected IDs.');
            System.assertEquals(policyDraft.Id, coverage.Policy_Draft__c, 'The policy draft ID should match the test policy draft.');
        }
    }
}