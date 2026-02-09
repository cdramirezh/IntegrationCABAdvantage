@isTest
public class OpportunityEndorsementsController_Test {
    /*
    @TestSetup
    static void makeData() {
        // Create test Opportunity
        Opportunity testOpp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30)
        );
        insert testOpp;
        
        // Create test Endorsement Request
        Endorsement_Request__c testEndorsement = new Endorsement_Request__c(
            //Name = 'TEST-001',
            Opportunity__c = testOpp.Id,
            Effective_Date__c = Date.today(),
            Other_Request__c = 'Test other request'
        );
        insert testEndorsement;
        
        // Create test data for related objects (simplified for test)
        // Note: You'll need to adjust these based on your actual object relationships
        
        // Test Policy
        Policy__c testPolicy = new Policy__c(
            Name = 'Test Policy'
        );
        insert testPolicy;
        
        Endorsement_Policy__c testEndorsementPolicy = new Endorsement_Policy__c(
            Endorsement_Request__c = testEndorsement.Id,
            Policy__c = testPolicy.Id
        );
        insert testEndorsementPolicy;
        
        // Test Coverage (assuming you have these objects)
        // Coverage_Product__c testCoverageProduct = new Coverage_Product__c(
        //     Name = 'Test Coverage Product'
        // );
        // insert testCoverageProduct;
        
        // Coverage__c testCoverage = new Coverage__c(
        //     Coverage_Product__c = testCoverageProduct.Id,
        //     Limit__c = '100000',
        //     Deductible__c = '1000'
        // );
        // insert testCoverage;
        
        // Endorsement_Coverage__c testEndorsementCoverage = new Endorsement_Coverage__c(
        //     Endorsement_Request__c = testEndorsement.Id,
        //     Coverage__c = testCoverage.Id,
        //     New_Limit__c = '200000',
        //     New_Deductible__c = '2000'
        // );
        // insert testEndorsementCoverage;
    }
        */
    
    @isTest
    static void testGetEndorsementRequests() {

        // Create test Opportunity
        Opportunity testOpp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30)
        );
        insert testOpp;

        //Create Test Contact 
        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            Email = 'test@mycompany.com'
        );
        insert testContact;
        
        // Create test Endorsement Request
        Endorsement_Request__c testEndorsement = new Endorsement_Request__c(
            //Name = 'TEST-001',
            Opportunity__c = testOpp.Id,
            Subject__c = 'TEST-001',
            Effective_Date__c = Date.today(),
            Other_Request__c = 'Test other request',
            Process_Owner_p__c = 'Loyalty Team'
        );
        insert testEndorsement;
        
        // Create test data for related objects (simplified for test)
        // Note: You'll need to adjust these based on your actual object relationships
        
        // Test Policy
        Policy__c testPolicy = new Policy__c(
            Name = 'Test Policy'
        );
        insert testPolicy;
        
        Endorsement_Policy__c testEndorsementPolicy = new Endorsement_Policy__c(
            Endorsement_Request__c = testEndorsement.Id,
            Policy__c = testPolicy.Id
        );
        insert testEndorsementPolicy;

        // Get test data
        //Opportunity testOpp = [SELECT Id FROM Opportunity LIMIT 1];
        
        Test.startTest();
        List<OpportunityEndorsementsController.EndorsementRequestWrapper> result = 
            OpportunityEndorsementsController.getEndorsementRequests(testOpp.Id);
        Test.stopTest();
        
        // Assertions
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals(1, result.size(), 'Should return one endorsement request');
        
        OpportunityEndorsementsController.EndorsementRequestWrapper wrapper = result[0];
        System.assertEquals('TEST-001', wrapper.Subject, 'Name should match');
        System.assertEquals(Date.today(), wrapper.EffectiveDate, 'Effective date should match');
        System.assertEquals('Test other request', wrapper.OtherRequest, 'Other request should match');
        
        // Test policies
        System.assertNotEquals(null, wrapper.policies, 'Policies should not be null');
        System.assertEquals(1, wrapper.policies.size(), 'Should have one policy');
    }
    
    /*
    @isTest
    static void testGetEndorsementRequestsNoData() {
        // Create opportunity without endorsement requests
        Opportunity testOpp = new Opportunity(
            Name = 'Empty Opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30)
        );
        insert testOpp;
        
        Test.startTest();
        List<OpportunityEndorsementsController.EndorsementRequestWrapper> result = 
            OpportunityEndorsementsController.getEndorsementRequests(testOpp.Id);
        Test.stopTest();
        
        // Assertions
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals(0, result.size(), 'Should return empty list');
    }
    */

    /*
    @isTest
    static void testGetEndorsementRequestsInvalidId() {
        // Test with invalid/non-existent opportunity ID
        //Id fakeOpportunityId = TestUtils.getFakeId(Opportunity.SObjectType);
        Id fakeOpportunityId = '006DR54000KcgycYAB'; // Example of a fake Opportunity ID
        
        Test.startTest();
        List<OpportunityEndorsementsController.EndorsementRequestWrapper> result = 
            OpportunityEndorsementsController.getEndorsementRequests(fakeOpportunityId);
        Test.stopTest();
        
        // Assertions
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals(0, result.size(), 'Should return empty list for invalid ID');
    }
        */
    
    /*
    // Utility class for generating fake IDs in tests
    public class TestUtils {
        public static Id getFakeId(Schema.SObjectType sot) {
            String keyPrefix = sot.getDescribe().getKeyPrefix();
            String fakeId = keyPrefix + '000000000001';
            return Id.valueOf(fakeId);
        }
    }
        */
}