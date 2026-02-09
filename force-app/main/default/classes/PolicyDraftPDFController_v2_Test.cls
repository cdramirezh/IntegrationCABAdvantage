@isTest
public class PolicyDraftPDFController_v2_Test {
    @isTest
    static void testPolicyDraftPDFController() {
        // Create a Lead record
        Lead testLead = new Lead(
            LastName = 'Test Lead',
            Company = 'Test Company',
            Status = 'Open'
        );
        insert testLead;

        // Create a Policy_Draft__c record linked to the Lead
        Policy_Draft__c testPolicyDraft = new Policy_Draft__c(
            Name = 'Test Policy Draft',
            Lead__c = testLead.Id
        );
        insert testPolicyDraft;

        // Create Vehicle__c records related to the Lead
        Vehicle__c testVehicle = new Vehicle__c(
            Name = 'Test Vehicle',
            Lead__c = testLead.Id,
            //Make__c = 'Test Make',
            //Type__c = 'Truck',
            Year__c = 2024,
            Value__c = 50000,
            Weight__c = 15000
        );
        insert testVehicle;

        // Create Trailer__c records related to the Lead
        Trailer__c testTrailer = new Trailer__c(
            Name = 'Test Trailer',
            Lead__c = testLead.Id,
            Year__c = 2020
        );
        insert testTrailer;

        // Create Driver__c records related to the Lead
        Driver__c testDriver = new Driver__c(
            Name = 'Test Driver',
            Lead__c = testLead.Id,
            CDL__c = '12345',
            DOB__c = Date.newInstance(1980, 1, 1),
            State__c = 'CA',
            Hiring_Date__c = Date.newInstance(2020, 1, 1),
            Experience__c = 10
        );
        insert testDriver;

        // Create a Coverage_Product__c record
        Coverage_Product__c testCoverageProduct = new Coverage_Product__c(
            Name = 'Test Coverage Product'
        );
        insert testCoverageProduct;

        // Create a Coverage__c record linked to the Policy_Draft__c
        Coverage__c testCoverage = new Coverage__c(
            //Name = 'Test Coverage',
            Policy_Draft__c = testPolicyDraft.Id,
            Coverage_Product__c = testCoverageProduct.Id
        );
        insert testCoverage;

        // Create Coverage_Vehicle__c records linking Coverage and Vehicle
        Coverage_Vehicle__c testCoverageVehicle = new Coverage_Vehicle__c(
            Coverage__c = testCoverage.Id,
            Vehicle__c = testVehicle.Id
        );
        insert testCoverageVehicle;

        // Create Coverage_Trailer__c records linking Coverage and Trailer
        Coverage_Trailer__c testCoverageTrailer = new Coverage_Trailer__c(
            Coverage__c = testCoverage.Id,
            Trailer__c = testTrailer.Id
        );
        insert testCoverageTrailer;

        // Create Coverage_Driver__c records linking Coverage and Driver
        Coverage_Driver__c testCoverageDriver = new Coverage_Driver__c(
            Coverage__c = testCoverage.Id,
            Driver__c = testDriver.Id
        );
        insert testCoverageDriver;

        // Test the controller
        ApexPages.StandardController sc = new ApexPages.StandardController(testPolicyDraft);
        PolicyDraftPDFController_v2 controller = new PolicyDraftPDFController_v2(sc);

        // Assertions to verify functionality
        System.assert(controller.policyDraft != null, 'Policy Draft should not be null');
        System.assertEquals(controller.policyDraft.Id, testPolicyDraft.Id, 'Policy Draft IDs should match');

        // Validate vehicle list
        System.assert(controller.vehicles != null, 'Vehicles list should not be null');
        System.assert(controller.vehicles.size() > 0, 'Vehicles list should not be empty');

        // Validate trailer list
        System.assert(controller.trailers != null, 'Trailers list should not be null');
        System.assert(controller.trailers.size() > 0, 'Trailers list should not be empty');

        // Validate driver list
        System.assert(controller.drivers != null, 'Drivers list should not be null');
        System.assert(controller.drivers.size() > 0, 'Drivers list should not be empty');

        // Validate coverage list
        System.assert(controller.coverages != null, 'Coverages list should not be null');
        System.assert(controller.coverages.size() > 0, 'Coverages list should not be empty');

        // Validate vehicle wrappers
        System.assert(controller.vehicleWrappers != null, 'Vehicle Wrappers should not be null');
        System.assert(controller.vehicleWrappers.size() > 0, 'Vehicle Wrappers list should not be empty');

        // Validate trailer wrappers
        System.assert(controller.TrailerWrappers != null, 'Trailer Wrappers should not be null');
        System.assert(controller.TrailerWrappers.size() > 0, 'Trailer Wrappers list should not be empty');

        // Validate driver wrappers
        System.assert(controller.DriverWrappers != null, 'Driver Wrappers should not be null');
        System.assert(controller.DriverWrappers.size() > 0, 'Driver Wrappers list should not be empty');
    }
}