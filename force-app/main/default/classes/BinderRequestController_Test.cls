@isTest
public class BinderRequestController_Test {
    @testSetup
    static void setup() {
        // Create a Policy Draft
        Policy_Draft__c policyDraft = new Policy_Draft__c (Name = 'Test Policy Draft');
        insert policyDraft;

        Insurance_Company__c inscompany = new Insurance_Company__c(Name = 'Test Insurer');
        insert inscompany;
        

        // Create MGA_Quote__c records related to the Policy_Draft__c
        List<MGA_Quote__c> mgaQuotes = new List<MGA_Quote__c>();
        for (Integer i = 0; i < 2; i++) {
            mgaQuotes.add(new MGA_Quote__c(Name = 'Test MGA Quote ' + i, Policy_Draft__c = policyDraft.Id));
        }
        insert mgaQuotes;

        // Create Mga_Quote_Insurance_Company__c records related to the MGA_Quote__c records
        List<Mga_Quote_Insurance_Company__c> insuranceCompanies = new List<Mga_Quote_Insurance_Company__c>();
        /*
        for (MGA_Quote__c quote : mgaQuotes) {
            insuranceCompanies.add(new Mga_Quote_Insurance_Company__c(
                Name = 'Insurance Company ' + quote.Name,
                MGA_Quote__c = quote.Id,
                Bind_Name__c = 'Bind Name ' + quote.Name
            ));
        }
            insert insuranceCompanies;
            */
        
        for (MGA_Quote__c quote : mgaQuotes) {

            Mga_Quote_Insurance_Company__c insCo = new Mga_Quote_Insurance_Company__c();
            insco.MGA_Quote__c = quote.Id;
            insCo.Insurance_Company__c = inscompany.id;

            insuranceCompanies.add(insCo);

        }

        insert insuranceCompanies;

        

        // Create a Binder_Request__c record
        Binder_Request__c binderRequest = new Binder_Request__c(Name = 'Test Binder Request', Policy_Draft__c = policyDraft.Id);
        insert binderRequest;
    }

    @isTest
    static void testGetAvailableInsuranceCompanies() {
        // Retrieve the Binder_Request__c record
        Binder_Request__c binderRequest = [SELECT Id FROM Binder_Request__c LIMIT 1];

        // Test the method
        Test.startTest();
        List<Map<String, String>> options = BinderRequestController.getAvailableInsuranceCompanies(binderRequest.Id);
        Test.stopTest();

        // Assertions
        //System.assertNotNull(options, 'Options should not be null');
        System.assertEquals(2, options.size(), 'There should be 2 available insurance companies');
        //System.assertEquals('Bind Name Test MGA Quote 0', options[0].get('label'), 'The first option label should match');
        //System.assertEquals('Bind Name Test MGA Quote 1', options[1].get('label'), 'The second option label should match');
    }

    @isTest
    static void testSaveSelectedCompanies() {
        // Retrieve the Binder_Request__c and Mga_Quote_Insurance_Company__c records
        Binder_Request__c binderRequest = [SELECT Id FROM Binder_Request__c LIMIT 1];
        List<Mga_Quote_Insurance_Company__c> insuranceCompanies = [
            SELECT Id, Binder_Request__c
            FROM Mga_Quote_Insurance_Company__c
            WHERE Binder_Request__c = NULL
            LIMIT 2
        ];

        // Test the method
        Test.startTest();
        BinderRequestController.saveSelectedCompanies(binderRequest.Id, new List<Id>{insuranceCompanies[0].Id, insuranceCompanies[1].Id});
        Test.stopTest();

        // Verify the Binder_Request__c field has been updated
        List<Mga_Quote_Insurance_Company__c> updatedCompanies = [
            SELECT Id, Binder_Request__c
            FROM Mga_Quote_Insurance_Company__c
            WHERE Id IN :insuranceCompanies
        ];
        for (Mga_Quote_Insurance_Company__c company : updatedCompanies) {
            System.assertEquals(binderRequest.Id, company.Binder_Request__c, 'Binder_Request__c should be updated');
        }
    }

    /*
    @isTest
    static void testSaveSelectedCompaniesWithException() {
        try {
            // Test the method with null parameters
            Test.startTest();
            BinderRequestController.saveSelectedCompanies(null, null);
            Test.stopTest();
            System.assert(false, 'Exception should have been thrown');
        } catch (AuraHandledException e) {
            System.assertEquals('Binder Request ID and selected insurance companies are required.', e.getMessage(), 'Error message should match');
        }
    }
        */
}