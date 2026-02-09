@isTest
public with sharing class quoteCoveragesAssetsDisplayTest {

    @testSetup
    static void setupTestData() {

        // Create Lead
        Lead TestLead = new Lead(LastName = 'Clinton', Company = 'Test Company');
        insert TestLead;

        // Create test Policy Draft
        Policy_Draft__c testPolicyDraft = new Policy_Draft__c(Name = 'Test Policy Draft');
        insert testPolicyDraft;

        // Create Coverage Product
        Coverage_Product__c testCoverageProduct = new Coverage_Product__c(Name = 'Test Coverage Product');
        insert testCoverageProduct;

        // Create Vehicles, Trailers, and Drivers related to the Policy Draft
        List<Vehicle__c> vehicles = new List<Vehicle__c>();
        List<Trailer__c> trailers = new List<Trailer__c>();
        List<Driver__c> drivers = new List<Driver__c>();
        
        for (Integer i = 0; i < 2; i++) {
            vehicles.add(new Vehicle__c(Name = 'Vehicle ' + i, Lead__c = TestLead.Id));
            trailers.add(new Trailer__c(Name = 'Trailer ' + i, Lead__c = TestLead.Id));
            drivers.add(new Driver__c(Name = 'Driver ' + i, Lead__c = TestLead.Id, CDL__c='kjhgf-63547' + i));
        }

        insert vehicles;
        insert trailers;
        insert drivers;

        // Create Coverages with related Vehicles, Trailers, and Drivers
        List<Coverage__c> coverages = new List<Coverage__c>();
        List<Coverage_Vehicle__c> coverageVehicles = new List<Coverage_Vehicle__c>();
        List<Coverage_Trailer__c> coverageTrailers = new List<Coverage_Trailer__c>();
        List<Coverage_Driver__c> coverageDrivers = new List<Coverage_Driver__c>();

        for (Integer i = 0; i < 2; i++) {
            Coverage__c coverage = new Coverage__c(
                Policy_Draft__c = testPolicyDraft.Id,
                Coverage_Product__c = testCoverageProduct.Id // Set Coverage Product
            );
            coverages.add(coverage);
        }
        insert coverages;        

        // Create Coverage_Vehicle__c records and associate them with Coverages and Vehicles
        for (Integer i = 0; i < 2; i++) {
            Coverage_Vehicle__c cv = new Coverage_Vehicle__c(
                Coverage__c = coverages[i].Id,
                Vehicle__c = vehicles[i].Id
            );
            coverageVehicles.add(cv);

            Coverage_Trailer__c ct = new Coverage_Trailer__c(
                Coverage__c = coverages[i].Id,
                Trailer__c = trailers[i].Id
            );
            coverageTrailers.add(ct);

            Coverage_Driver__c cd = new Coverage_Driver__c(
                Coverage__c = coverages[i].Id,
                Driver__c = drivers[i].Id
            );
            coverageDrivers.add(cd);
        }
        insert coverageVehicles;
        insert coverageTrailers;
        insert coverageDrivers;

    }

    @isTest
    static void testGetGroupedVehiclesAndCoverages() {   
        
        // Fetch the Policy Draft Id
        Policy_Draft__c testPolicyDraft = [SELECT Id FROM Policy_Draft__c LIMIT 1];

        // Execute method and assert results
        Test.startTest();
        List<quoteCoveragesAssetsDisplay.VehicleWithCoverages> results =
            quoteCoveragesAssetsDisplay.getGroupedVehiclesAndCoverages(testPolicyDraft.Id);
        Test.stopTest();

        // Validate the results
        System.assertNotEquals(0, results.size(), 'There should be results returned');
        System.assertEquals('Vehicle 0', results[0].vehicleName, 'Vehicle name should match');
        System.assertEquals('Test Coverage Product', results[0].coverageNames, 'Coverage names should match the test data');
    }

    @isTest
    static void testGetGroupedTrailersAndCoverages() {   
        
        // Fetch the Policy Draft Id
        Policy_Draft__c testPolicyDraft = [SELECT Id FROM Policy_Draft__c LIMIT 1];

        // Execute method and assert results
        Test.startTest();
        List<quoteCoveragesAssetsDisplay.TrailerWithCoverages> results =
            quoteCoveragesAssetsDisplay.getGroupedTrailersAndCoverages(testPolicyDraft.Id);
        Test.stopTest();

        // Validate the results
        System.assertNotEquals(0, results.size(), 'There should be results returned');
        System.assertEquals('Trailer 0', results[0].trailerName, 'Vehicle name should match');
        System.assertEquals('Test Coverage Product', results[0].coverageNames, 'Coverage names should match the test data');
    }

    @isTest
    static void testGetGroupedDriversAndCoverages() {   
        
        // Fetch the Policy Draft Id
        Policy_Draft__c testPolicyDraft = [SELECT Id FROM Policy_Draft__c LIMIT 1];

        // Execute method and assert results
        Test.startTest();
        List<quoteCoveragesAssetsDisplay.DriverWithCoverages> results =
            quoteCoveragesAssetsDisplay.getGroupedDriversAndCoverages(testPolicyDraft.Id);
        Test.stopTest();

        // Validate the results
        System.assertNotEquals(0, results.size(), 'There should be results returned');
        System.assertEquals('Driver 0', results[0].driverName, 'Vehicle name should match');
        System.assertEquals('Test Coverage Product', results[0].coverageNames, 'Coverage names should match the test data');
    }

}