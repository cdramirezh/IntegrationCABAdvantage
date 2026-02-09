@isTest
private class PolicyAssetControllerTest {

@isTest
    static void testGetPolicyAssets() { 

        // Create a test Policy_Draft__c record
        Policy_Draft__c testPolicyDraft = new Policy_Draft__c();
        insert testPolicyDraft;

        // Create a test Binder_Request__c record
        Binder_Request__c testBinderRequest = new Binder_Request__c(
            Policy_Draft__c = testPolicyDraft.Id
        );
        insert testBinderRequest;

         // Create a test Policy__c record
         Policy__c testPolicy = new Policy__c(Binder_Request__c = testBinderRequest.Id);
         insert testPolicy;

        // Create a test Policy_Vehicle__c record
        Policy_Vehicle__c testVehicle = new Policy_Vehicle__c(
            Policy_Draft__c = testPolicyDraft.Id,
            Status__c = 'Active'
        );
        insert testVehicle;

        // Create a test Policy_Trailer__c record
        Policy_Trailer__c testTrailer = new Policy_Trailer__c(
            Policy_Draft__c = testPolicyDraft.Id,
            Status__c = 'Active'
        );
        insert testTrailer;

        // Create a test Policy_Driver__c record
        Policy_Driver__c testDriver = new Policy_Driver__c(
            Policy_Draft__c = testPolicyDraft.Id,
            Status__c = 'Active'
        );
        insert testDriver;

        // Call the getPolicyAssets method
        Map<String, List<sObject>> result = PolicyAssetController.getPolicyAssets(testPolicy.Id);

        // Assertions
        System.assertEquals(3, result.size(), 'Expected 3 records');
        System.assertEquals(1, result.get('vehicles').size(), 'Expected 1 vehicle record');
        System.assertEquals(1, result.get('trailers').size(), 'Expected 1 trailer record');
        System.assertEquals(1, result.get('drivers').size(), 'Expected 1 driver record');
    }

@isTest
    static void testUpdatePolicyAssets() {
        // Create a test Policy__c record
        Policy__c testPolicy = new Policy__c();
        insert testPolicy;

        // Create test records for Policy_Vehicle__c, Policy_Trailer__c, and Policy_Driver__c
        List<Policy_Vehicle__c> vehicles = new List<Policy_Vehicle__c>();
        List<Policy_Trailer__c> trailers = new List<Policy_Trailer__c>();
        List<Policy_Driver__c> drivers = new List<Policy_Driver__c>();

        for (Integer i = 0; i < 3; i++) {
            vehicles.add(new Policy_Vehicle__c(Policy__c = testPolicy.Id, Status__c = 'Active'));
            trailers.add(new Policy_Trailer__c(Policy__c = testPolicy.Id, Status__c = 'Active'));
            drivers.add(new Policy_Driver__c(Policy__c = testPolicy.Id, Status__c = 'Active'));
        }

        insert vehicles;
        insert trailers;
        insert drivers;

        // Call the updatePolicyAssets method
        Test.startTest();
        PolicyAssetController.updatePolicyAssets(testPolicy.Id, new List<Id>{vehicles[0].Id, vehicles[1].Id, vehicles[2].Id}, new List<Id>{trailers[0].Id, trailers[1].Id, trailers[2].Id}, new List<Id>{drivers[0].Id, drivers[1].Id, drivers[2].Id});
        Test.stopTest();

        // Assertions
        List<Policy_Vehicle__c> updatedVehicles = [SELECT Id, Policy__c FROM Policy_Vehicle__c WHERE Id IN :new List<Id>{vehicles[0].Id, vehicles[1].Id, vehicles[2].Id}];
        List<Policy_Trailer__c> updatedTrailers = [SELECT Id, Policy__c FROM Policy_Trailer__c WHERE Id IN :new List<Id>{trailers[0].Id, trailers[1].Id, trailers[2].Id}];
        List<Policy_Driver__c> updatedDrivers = [SELECT Id, Policy__c FROM Policy_Driver__c WHERE Id IN :new List<Id>{drivers[0].Id, drivers[1].Id, drivers[2].Id}];

        System.assertEquals(testPolicy.Id, updatedVehicles[0].Policy__c, 'The policy should be associated with the vehicle');
        System.assertEquals(testPolicy.Id, updatedVehicles[1].Policy__c, 'The policy should be associated with the vehicle');
        System.assertEquals(testPolicy.Id, updatedVehicles[2].Policy__c, 'The policy should be associated with the vehicle');

        System.assertEquals(testPolicy.Id, updatedTrailers[0].Policy__c, 'The policy should be associated with the trailer');
        System.assertEquals(testPolicy.Id, updatedTrailers[1].Policy__c, 'The policy should be associated with the trailer');
        System.assertEquals(testPolicy.Id, updatedTrailers[2].Policy__c, 'The policy should be associated with the trailer');

        System.assertEquals(testPolicy.Id, updatedDrivers[0].Policy__c, 'The policy should be associated with the driver');
        System.assertEquals(testPolicy.Id, updatedDrivers[1].Policy__c, 'The policy should be associated with the driver');
        System.assertEquals(testPolicy.Id, updatedDrivers[2].Policy__c, 'The policy should be associated with the driver');
    }
}