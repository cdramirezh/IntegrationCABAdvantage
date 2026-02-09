@isTest
private class EndorsementRequestCoverageControllerTest {


@IsTest
    static void testGetCoveragesByEndorsementRequest() {
        // Create a test Endorsement_Request__c record
        Endorsement_Request__c request = new Endorsement_Request__c(); // Assuming you have a test factory method to create this record
        insert request;

        //Create Test Policy__c record
        Policy__c policy = new Policy__c(Name = 'Test Policy');
        insert policy;

        // Create a test Endorsement_Policy__c record related to the test Endorsement_Request__c
        Endorsement_Policy__c endpolicy = new Endorsement_Policy__c(Endorsement_Request__c = request.Id, Policy__c=policy.Id ); // Assuming you have a test factory method to create this record
        insert endpolicy;        

        // Create a test Coverage__c record related to the test Policy__c
        Coverage__c coverage = new Coverage__c(Policy__c = policy.Id);
        insert coverage;

        // Call the method being tested
        List<Coverage__c> coverages = EndorsementRequestCoverageController.getCoveragesByEndorsementRequest(request.Id);
        Map<String, Object> response = EndorsementRequestCoverageController.createEndorsementCoverages(request.Id, new List<Id>{coverage.Id});

        // Assert that the test Coverage__c record is returned
        System.assertEquals(1, coverages.size());
        System.assertEquals(coverage.Id, coverages[0].Id);
    }
}