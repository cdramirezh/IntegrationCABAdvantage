@isTest
public class PolicyDraftCloneAction_v2_Test {
    
    @TestSetup
    static void setupTestData() {
        // Create test Lead
        Lead testLead = new Lead(
            FirstName = 'Test',
            LastName = 'Lead',
            Company = 'Test Company',
            Email = 'testlead@example.com',
            Owner_DOB__c = Date.today().addYears(-30) // Assuming Owner_DOB__c is a custom field for date of birth
        );
        insert testLead;
        
        // Create test Opportunity
        Opportunity testOpp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30)
        );
        insert testOpp;
        
        /*
        // Create test User for Producer (assuming Producer__c is a User lookup)
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'Producer',
            Email = 'testproducer@example.com',
            Username = 'testproducer@testcompany.com',
            Alias = 'tprod',
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;
        */

        //Create Test Contact for Producer
        Contact testProducerContact = new Contact(
            FirstName = 'Test',
            LastName = 'Producer',
            Email = 'test@mycompany.com',
            Birthdate = Date.today().addYears(-30) // Assuming Birthdate is a custom field for date of birth
        );  
        insert testProducerContact;
        
        // Create test Policy Draft
        Policy_Draft__c testPolicy = new Policy_Draft__c(
            Name = 'Test Policy Draft',
            Lead__c = testLead.Id,
            Opportunity__c = testOpp.Id,
            Producer__c =  testProducerContact.Id, // Assuming Producer__c is a Contact lookup
            Status__c = 'Open'
        );
        insert testPolicy;
        
        // Create test Coverage Product (assuming this exists)
        // Note: You may need to adjust this based on your actual Coverage_Product__c object structure
        Coverage_Product__c testCoverageProduct = new Coverage_Product__c(
            Name = 'Test Coverage Product'
        );
        insert testCoverageProduct;
        
        // Create test Coverage records
        List<Coverage__c> testCoverages = new List<Coverage__c>();
        for (Integer i = 0; i < 2; i++) {
            testCoverages.add(new Coverage__c(
                Policy_Draft__c = testPolicy.Id,
                Coverage_Product__c = testCoverageProduct.Id,
                Limit__c = 100000 + (i * 50000),
                Deductible__c = 1000 + (i * 500)
            ));
        }
        insert testCoverages;
        
        // Create test Vehicle records (assuming Vehicle__c object exists)
        List<Vehicle__c> testVehicles = new List<Vehicle__c>();
        for (Integer i = 0; i < 2; i++) {
            testVehicles.add(new Vehicle__c(
                Name = 'Test Vehicle ' + (i + 1)
            ));
        }
        insert testVehicles;
        
        // Create test Policy Vehicle records
        List<Policy_Vehicle__c> testPolicyVehicles = new List<Policy_Vehicle__c>();
        for (Vehicle__c vehicle : testVehicles) {
            testPolicyVehicles.add(new Policy_Vehicle__c(
                Policy_Draft__c = testPolicy.Id,
                Vehicle__c = vehicle.Id
            ));
        }
        insert testPolicyVehicles;
        
        // Create test Trailer records (assuming Trailer__c object exists)
        List<Trailer__c> testTrailers = new List<Trailer__c>();
        for (Integer i = 0; i < 2; i++) {
            testTrailers.add(new Trailer__c(
                Name = 'Test Trailer ' + (i + 1)
            ));
        }
        insert testTrailers;
        
        // Create test Policy Trailer records
        List<Policy_Trailer__c> testPolicyTrailers = new List<Policy_Trailer__c>();
        for (Trailer__c trailer : testTrailers) {
            testPolicyTrailers.add(new Policy_Trailer__c(
                Policy_Draft__c = testPolicy.Id,
                Trailer__c = trailer.Id
            ));
        }
        insert testPolicyTrailers;
        
        // Create test Driver records (assuming Driver__c object exists)
        List<Driver__c> testDrivers = new List<Driver__c>();
        for (Integer i = 0; i < 2; i++) {
            testDrivers.add(new Driver__c(
                Name = 'Test Driver ' + (i + 1),
                CDL__c = 'cdl-abc' + i 
            ));
        }
        insert testDrivers;
        
        // Create test Policy Driver records
        List<Policy_Driver__c> testPolicyDrivers = new List<Policy_Driver__c>();
        for (Driver__c driver : testDrivers) {
            testPolicyDrivers.add(new Policy_Driver__c(
                Policy_Draft__c = testPolicy.Id,
                Driver__c = driver.Id
            ));
        }
        insert testPolicyDrivers;
    }
    
    @isTest
    static void testSuccessfulClone() {
        // Get the test Policy Draft
        Policy_Draft__c originalPolicy = [
            SELECT Id, Name, Lead__c, Opportunity__c, Producer__c
            FROM Policy_Draft__c 
            WHERE Name = 'Test Policy Draft'
            LIMIT 1
        ];
        
        // Prepare the request
        PolicyDraftCloneAction_v2.CloneRequest request = new PolicyDraftCloneAction_v2.CloneRequest();
        request.policyDraftId = originalPolicy.Id;
        
        Test.startTest();
        List<PolicyDraftCloneAction_v2.CloneResponse> responses = PolicyDraftCloneAction_v2.clonePolicyDraft(
            new List<PolicyDraftCloneAction_v2.CloneRequest>{ request }
        );
        Test.stopTest();
        
        // Assertions
        System.assertEquals(1, responses.size(), 'Should return one response');
        PolicyDraftCloneAction_v2.CloneResponse response = responses[0];
        
        System.assertEquals(true, response.success, 'Clone should be successful');
        System.assertNotEquals(null, response.newPolicyDraftId, 'New Policy Draft ID should not be null');
        System.assertEquals('Policy Draft cloned successfully with all related records.', response.message, 'Success message should match');
        
        // Verify the cloned Policy Draft
        Policy_Draft__c clonedPolicy = [
            SELECT Id, Name, Lead__c, Opportunity__c, Producer__c, Status__c
            FROM Policy_Draft__c 
            WHERE Id = :response.newPolicyDraftId
        ];
        
        System.assertEquals(originalPolicy.Name + ' - Clone', clonedPolicy.Name, 'Cloned policy name should have - Clone suffix');
        System.assertEquals('Open', clonedPolicy.Status__c, 'Cloned policy status should be Open');
        System.assertEquals(originalPolicy.Lead__c, clonedPolicy.Lead__c, 'Lead should be copied');
        System.assertEquals(originalPolicy.Opportunity__c, clonedPolicy.Opportunity__c, 'Opportunity should be copied');
        System.assertEquals(originalPolicy.Producer__c, clonedPolicy.Producer__c, 'Producer should be copied');
        
        // Verify Coverage records were cloned
        List<Coverage__c> clonedCoverages = [
            SELECT Id, Policy_Draft__c, Coverage_Product__c, Limit__c, Deductible__c
            FROM Coverage__c 
            WHERE Policy_Draft__c = :response.newPolicyDraftId
        ];
        System.assertEquals(2, clonedCoverages.size(), 'Should have cloned 2 coverage records');
        
        // Verify Policy Vehicle records were cloned
        List<Policy_Vehicle__c> clonedVehicles = [
            SELECT Id, Policy_Draft__c, Vehicle__c
            FROM Policy_Vehicle__c 
            WHERE Policy_Draft__c = :response.newPolicyDraftId
        ];
        System.assertEquals(2, clonedVehicles.size(), 'Should have cloned 2 policy vehicle records');
        
        // Verify Policy Trailer records were cloned
        List<Policy_Trailer__c> clonedTrailers = [
            SELECT Id, Policy_Draft__c, Trailer__c
            FROM Policy_Trailer__c 
            WHERE Policy_Draft__c = :response.newPolicyDraftId
        ];
        System.assertEquals(2, clonedTrailers.size(), 'Should have cloned 2 policy trailer records');
        
        // Verify Policy Driver records were cloned
        List<Policy_Driver__c> clonedDrivers = [
            SELECT Id, Policy_Draft__c, Driver__c
            FROM Policy_Driver__c 
            WHERE Policy_Draft__c = :response.newPolicyDraftId
        ];
        System.assertEquals(2, clonedDrivers.size(), 'Should have cloned 2 policy driver records');
    }
    
    @isTest
    static void testCloneWithNullLookupFields() {
        // Create a Policy Draft with null lookup fields
        Policy_Draft__c policyWithNulls = new Policy_Draft__c(
            Name = 'Policy with Nulls',
            Status__c = 'Open'
            // Lead__c, Opportunity__c, and Producer__c are null
        );
        insert policyWithNulls;
        
        // Prepare the request
        PolicyDraftCloneAction_v2.CloneRequest request = new PolicyDraftCloneAction_v2.CloneRequest();
        request.policyDraftId = policyWithNulls.Id;
        
        Test.startTest();
        List<PolicyDraftCloneAction_v2.CloneResponse> responses = PolicyDraftCloneAction_v2.clonePolicyDraft(
            new List<PolicyDraftCloneAction_v2.CloneRequest>{ request }
        );
        Test.stopTest();
        
        // Assertions
        PolicyDraftCloneAction_v2.CloneResponse response = responses[0];
        System.assertEquals(true, response.success, 'Clone should be successful even with null lookups');
        
        // Verify the cloned Policy Draft has null lookup fields
        Policy_Draft__c clonedPolicy = [
            SELECT Id, Lead__c, Opportunity__c, Producer__c
            FROM Policy_Draft__c 
            WHERE Id = :response.newPolicyDraftId
        ];
        
        System.assertEquals(null, clonedPolicy.Lead__c, 'Lead should remain null');
        System.assertEquals(null, clonedPolicy.Opportunity__c, 'Opportunity should remain null');
        System.assertEquals(null, clonedPolicy.Producer__c, 'Producer should remain null');
    }
    
    @isTest
    static void testCloneWithNoRelatedRecords() {
        // Create a Policy Draft with no related records
        Policy_Draft__c policyWithNoRelated = new Policy_Draft__c(
            Name = 'Policy with No Related',
            Status__c = 'Open'
        );
        insert policyWithNoRelated;
        
        // Prepare the request
        PolicyDraftCloneAction_v2.CloneRequest request = new PolicyDraftCloneAction_v2.CloneRequest();
        request.policyDraftId = policyWithNoRelated.Id;
        
        Test.startTest();
        List<PolicyDraftCloneAction_v2.CloneResponse> responses = PolicyDraftCloneAction_v2.clonePolicyDraft(
            new List<PolicyDraftCloneAction_v2.CloneRequest>{ request }
        );
        Test.stopTest();
        
        // Assertions
        PolicyDraftCloneAction_v2.CloneResponse response = responses[0];
        System.assertEquals(true, response.success, 'Clone should be successful even with no related records');
        
        // Verify no related records were created
        System.assertEquals(0, [SELECT COUNT() FROM Coverage__c WHERE Policy_Draft__c = :response.newPolicyDraftId], 'No coverage records should be created');
        System.assertEquals(0, [SELECT COUNT() FROM Policy_Vehicle__c WHERE Policy_Draft__c = :response.newPolicyDraftId], 'No vehicle records should be created');
        System.assertEquals(0, [SELECT COUNT() FROM Policy_Trailer__c WHERE Policy_Draft__c = :response.newPolicyDraftId], 'No trailer records should be created');
        System.assertEquals(0, [SELECT COUNT() FROM Policy_Driver__c WHERE Policy_Draft__c = :response.newPolicyDraftId], 'No driver records should be created');
    }
    
    @isTest
    static void testCloneWithInvalidId() {
        // Create a fake ID (this will cause a query exception)
        Id fakeId = '001000000000000AAA'; // Assuming this is a valid 18-character ID format but doesn't exist
        
        // Prepare the request
        PolicyDraftCloneAction_v2.CloneRequest request = new PolicyDraftCloneAction_v2.CloneRequest();
        request.policyDraftId = fakeId;
        
        Test.startTest();
        List<PolicyDraftCloneAction_v2.CloneResponse> responses = PolicyDraftCloneAction_v2.clonePolicyDraft(
            new List<PolicyDraftCloneAction_v2.CloneRequest>{ request }
        );
        Test.stopTest();
        
        // Assertions
        PolicyDraftCloneAction_v2.CloneResponse response = responses[0];
        System.assertEquals(false, response.success, 'Clone should fail with invalid ID');
        System.assertEquals(null, response.newPolicyDraftId, 'New Policy Draft ID should be null on failure');
        System.assert(response.message.startsWith('Error cloning Policy Draft:'), 'Error message should start with expected text');
    }
    
    @isTest
    static void testMultipleCloneRequests() {
        // Get multiple test Policy Drafts
        List<Policy_Draft__c> policies = [
            SELECT Id FROM Policy_Draft__c 
            WHERE Name = 'Test Policy Draft'
            LIMIT 1
        ];
        
        // Create an additional policy for testing
        Policy_Draft__c additionalPolicy = new Policy_Draft__c(
            Name = 'Additional Test Policy',
            Status__c = 'open'
        );
        insert additionalPolicy;
        
        // Prepare multiple requests
        List<PolicyDraftCloneAction_v2.CloneRequest> requests = new List<PolicyDraftCloneAction_v2.CloneRequest>();
        
        PolicyDraftCloneAction_v2.CloneRequest request1 = new PolicyDraftCloneAction_v2.CloneRequest();
        request1.policyDraftId = policies[0].Id;
        requests.add(request1);
        
        PolicyDraftCloneAction_v2.CloneRequest request2 = new PolicyDraftCloneAction_v2.CloneRequest();
        request2.policyDraftId = additionalPolicy.Id;
        requests.add(request2);
        
        Test.startTest();
        List<PolicyDraftCloneAction_v2.CloneResponse> responses = PolicyDraftCloneAction_v2.clonePolicyDraft(requests);
        Test.stopTest();
        
        // Assertions
        System.assertEquals(2, responses.size(), 'Should return two responses');
        
        for (PolicyDraftCloneAction_v2.CloneResponse response : responses) {
            System.assertEquals(true, response.success, 'Both clones should be successful');
            System.assertNotEquals(null, response.newPolicyDraftId, 'Both should have new Policy Draft IDs');
        }
        
        // Verify both policies were cloned
        List<Policy_Draft__c> clonedPolicies = [
            SELECT Id, Name FROM Policy_Draft__c 
            WHERE Name LIKE '%Clone%'
        ];
        System.assertEquals(2, clonedPolicies.size(), 'Should have created 2 cloned policies');
    }
    
    @isTest
    static void testBulkDataLimits() {
        // This test ensures the code can handle bulk operations efficiently
        // Get the test Policy Draft
        Policy_Draft__c originalPolicy = [
            SELECT Id FROM Policy_Draft__c 
            WHERE Name = 'Test Policy Draft'
            LIMIT 1
        ];
        
        // Create multiple requests for the same policy to test bulk handling
        List<PolicyDraftCloneAction_v2.CloneRequest> bulkRequests = new List<PolicyDraftCloneAction_v2.CloneRequest>();
        
        for (Integer i = 0; i < 5; i++) {
            PolicyDraftCloneAction_v2.CloneRequest request = new PolicyDraftCloneAction_v2.CloneRequest();
            request.policyDraftId = originalPolicy.Id;
            bulkRequests.add(request);
        }
        
        Test.startTest();
        List<PolicyDraftCloneAction_v2.CloneResponse> responses = PolicyDraftCloneAction_v2.clonePolicyDraft(bulkRequests);
        Test.stopTest();
        
        // Assertions
        System.assertEquals(5, responses.size(), 'Should return 5 responses');
        
        for (PolicyDraftCloneAction_v2.CloneResponse response : responses) {
            System.assertEquals(true, response.success, 'All clones should be successful');
            System.assertNotEquals(null, response.newPolicyDraftId, 'All should have new Policy Draft IDs');
        }
        
        // Verify all policies were cloned
        List<Policy_Draft__c> clonedPolicies = [
            SELECT Id FROM Policy_Draft__c 
            WHERE Name LIKE '%Clone%'
        ];
        System.assertEquals(5, clonedPolicies.size(), 'Should have created 5 cloned policies');
    }
}