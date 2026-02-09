@isTest
public class PolicyDraftMGAQuoteInsuranceCompTest {

    @testSetup
    static void setupTestData() {
        // Create a test Policy Draft
        Policy_Draft__c testPolicyDraft = new Policy_Draft__c(Name = 'Test Policy Draft');
        insert testPolicyDraft;

        Insurance_Company__c insco = new Insurance_Company__c(Name = 'New Insurance Co');
        insert insco;

        // Create MGA_Quote__c records related to the Policy Draft
        List<MGA_Quote__c> quotes = new List<MGA_Quote__c>();
        for (Integer i = 0; i < 2; i++) {
            quotes.add(new MGA_Quote__c(Name = 'Test Quote ' + i, Policy_Draft__c = testPolicyDraft.Id, Status__c = 'Open'));
        }
        insert quotes;

        // Create Insurance Company records related to each MGA_Quote__c
        List<MGA_Quote_Insurance_Company__c> insuranceCompanies = new List<MGA_Quote_Insurance_Company__c>();
        for (MGA_Quote__c quote : quotes) {
            for (Integer j = 0; j < 2; j++) {
                insuranceCompanies.add(new MGA_Quote_Insurance_Company__c(
                    //Name = 'Insurance Company ' + j,
                    MGA_Quote__c = quote.Id,
                    Status__c = 'Pending',
                    Insurance_Company__c = insco.Id
                ));
            }
        }
        insert insuranceCompanies;
    }

    @isTest
    static void testGetMGAQuotesWithInsurance() {
        // Fetch the Policy Draft ID to use in the test
        Policy_Draft__c testPolicyDraft = [SELECT Id FROM Policy_Draft__c LIMIT 1];

        // Execute the method to get MGA Quotes with Insurance Companies
        Test.startTest();
        List<PolicyDraftMGAQuoteInsuranceComp.QuoteWithInsuranceWrapper> results =
            PolicyDraftMGAQuoteInsuranceComp.getMGAQuotesWithInsurance(testPolicyDraft.Id);
        Test.stopTest();

        // Assertions to verify the results
        System.assertEquals(2, results.size(), 'There should be two MGA_Quote__c records in the results.');

        for (PolicyDraftMGAQuoteInsuranceComp.QuoteWithInsuranceWrapper wrapper : results) {
            System.assertNotEquals(null, wrapper.quote, 'Each wrapper should have a quote.');
            System.assert(wrapper.insuranceCompanies != null && wrapper.insuranceCompanies.size() == 2,
                'Each quote should have two related insurance companies.');
            
            for (MGA_Quote_Insurance_Company__c insuranceCompany : wrapper.insuranceCompanies) {
                System.assertEquals('Pending', insuranceCompany.Status__c, 'Each insurance company should have a Status of "Pending".');
            }
        }
    }

    @isTest
    static void testGetMGAQuotesWithNoInsurance() {
        // Create a Policy Draft with an MGA Quote that has no Insurance Companies
        Policy_Draft__c testPolicyDraftNoInsurance = new Policy_Draft__c(Name = 'Test Policy Draft No Insurance');
        insert testPolicyDraftNoInsurance;

        MGA_Quote__c quoteNoInsurance = new MGA_Quote__c(Name = 'Quote with No Insurance', Policy_Draft__c = testPolicyDraftNoInsurance.Id, Status__c = 'Open');
        insert quoteNoInsurance;

        // Execute the method to get MGA Quotes for the policy draft with no insurance companies
        Test.startTest();
        List<PolicyDraftMGAQuoteInsuranceComp.QuoteWithInsuranceWrapper> results =
            PolicyDraftMGAQuoteInsuranceComp.getMGAQuotesWithInsurance(testPolicyDraftNoInsurance.Id);
        Test.stopTest();

        // Assertions to verify results when there are no insurance companies
        System.assertEquals(1, results.size(), 'There should be one MGA_Quote__c record in the results.');
        System.assertEquals(quoteNoInsurance.Id, results[0].quote.Id, 'The quote ID should match the inserted quote with no insurance.');
        System.assertEquals(null, results[0].insuranceCompanies, 'Insurance companies list should be null for a quote with no insurance companies.');
    }
}