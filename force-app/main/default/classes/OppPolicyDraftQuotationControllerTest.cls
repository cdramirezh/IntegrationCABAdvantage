@isTest
public class OppPolicyDraftQuotationControllerTest {
    @testSetup
    static void setupData() {
        // Create a Account
        Account Account = new Account(Name = 'Test Account');
        insert Account;

        // Create a Opportunity
        Opportunity Opportunity = new Opportunity(AccountId = Account.Id, Name = 'Test Opportunity', CloseDate = Date.Today(), StageName = 'Qualification');
        insert Opportunity;

        // Create a Policy Draft associated with the Opportunity
        Policy_Draft__c policyDraft = new Policy_Draft__c(
            Opportunity__c = Opportunity.Id,
            //Name = 'Test Policy Draft',
            Status__c = 'Working'
        );
        insert policyDraft;

        // Create MGA Comapny
        MGA_Company__c mag_a = new MGA_Company__c(
            Name = 'MGA Company A'
        );
        insert mag_a;

        // Create MGA Comapny
        MGA_Company__c mag_b = new MGA_Company__c(
            Name = 'MGA Company B'
        );
        insert mag_b;

        // Create MGA Quotes associated with the Policy Draft
        MGA_Quote__c quote1 = new MGA_Quote__c(
            Policy_Draft__c = policyDraft.Id,
            Name = 'Quote 1',
            Status__c = 'Negotiation',
            MGA_Company__c = mag_a.Id
        );
        
        MGA_Quote__c quote2 = new MGA_Quote__c(
            Policy_Draft__c = policyDraft.Id,
            Name = 'Quote 2',
            Status__c = 'Submitted',
            MGA_Company__c = mag_b.Id
        );
        insert new List<MGA_Quote__c>{ quote1, quote2 };

        // Create Coverage records associated with the Policy Draft
        Coverage__c coverage1 = new Coverage__c(Policy_Draft__c = policyDraft.Id);
        Coverage__c coverage2 = new Coverage__c(Policy_Draft__c = policyDraft.Id);
        insert new List<Coverage__c>{ coverage1, coverage2 };

        // Create Insurance Comapny
        Insurance_Company__c Insco_a = new Insurance_Company__c(
            Name = 'Ins Company A'
        );
        insert Insco_a;

        // Create Insurance Comapny
        Insurance_Company__c Insco_b = new Insurance_Company__c(
            Name = 'Ins Company B'
        );
        insert Insco_b;

        // Create Insurance Companies associated with MGA Quotes
        MGA_Quote_Insurance_Company__c insuranceCompany1 = new MGA_Quote_Insurance_Company__c(
            MGA_Quote__c = quote1.Id,
            //Insurance_Company__r = new Insurance_Company__c(Name = 'Insurance Company 1'),
            Insurance_Company__c = Insco_a.Id,
            Status__c = 'Pending'
        );
        MGA_Quote_Insurance_Company__c insuranceCompany2 = new MGA_Quote_Insurance_Company__c(
            MGA_Quote__c = quote2.Id,
            //Insurance_Company__r = new Insurance_Company__c(Name = 'Insurance Company 2'),
            Insurance_Company__c = Insco_b.Id,
            Status__c = 'Declined'
        );
        insert new List<MGA_Quote_Insurance_Company__c>{ insuranceCompany1, insuranceCompany2 };
    }

    @isTest
    static void testGetPoliciesWithQuotesAndCompanies() {
        // Get the test Opportunity ID
        Opportunity testOpportunity = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity' LIMIT 1];

        // Call the method
        Test.startTest();
        List<OppPolicyDraftQuotationController.PolicyWrapper> results = OppPolicyDraftQuotationController.getPoliciesWithQuotesAndCompanies(testOpportunity.Id);
        Test.stopTest();

        // Verify the results
        System.assertNotEquals(null, results, 'The results should not be null.');
        System.assertEquals(1, results.size(), 'There should be one PolicyWrapper returned.');

        OppPolicyDraftQuotationController.PolicyWrapper policyWrapper = results[0];
        System.assertEquals('Working', policyWrapper.policy.Status__c, 'Policy Status should match.');
        System.assertEquals(2, policyWrapper.quotesWithCompanies.size(), 'There should be two quotes associated with the policy.');

        // Verify details for each QuoteWithCompanies
        OppPolicyDraftQuotationController.QuoteWithCompanies quoteWithCompanies1 = policyWrapper.quotesWithCompanies[0];
        System.assertEquals('Quote 1', quoteWithCompanies1.quote.Name, 'First quote name should match.');
        System.assertEquals(1, quoteWithCompanies1.insuranceCompanies.size(), 'First quote should have one insurance company associated.');

        OppPolicyDraftQuotationController.QuoteWithCompanies quoteWithCompanies2 = policyWrapper.quotesWithCompanies[1];
        System.assertEquals('Quote 2', quoteWithCompanies2.quote.Name, 'Second quote name should match.');
        System.assertEquals(1, quoteWithCompanies2.insuranceCompanies.size(), 'Second quote should have one insurance company associated.');
    }
}