@isTest
public class QuotesCoveragesAssetBulkAddTest {

    @testSetup
    static void setupTestData() {
        // Create a test Lead
        Lead testLead = new Lead(LastName = 'Test Lead', Company = 'Test Company');
        insert testLead;
        
        // Create a test Policy Draft (Quote) associated with the Lead
        Policy_Draft__c testQuote = new Policy_Draft__c(Name = 'Test Quote', Lead__c = testLead.Id);
        insert testQuote;

        // Create Vehicles, Trailers, and Drivers associated with the Lead
        List<Vehicle__c> vehicles = new List<Vehicle__c>();
        List<Trailer__c> trailers = new List<Trailer__c>();
        List<Driver__c> drivers = new List<Driver__c>();
        
        for (Integer i = 0; i < 2; i++) {
            vehicles.add(new Vehicle__c(Name = 'Vehicle ' + i, Lead__c = testLead.Id));
            trailers.add(new Trailer__c(Name = 'Trailer ' + i, Lead__c = testLead.Id));
            drivers.add(new Driver__c(Name = 'Driver ' + i, Lead__c = testLead.Id, CDL__c = 'abcfg-1234'+ i));
        }
        insert vehicles;
        insert trailers;
        insert drivers;

        // Create Coverage records associated with the Policy Draft
        List<Coverage__c> coverages = new List<Coverage__c>();
        for (Integer j = 0; j < 2; j++) {
            coverages.add(new Coverage__c(Policy_Draft__c = testQuote.Id));
        }
        insert coverages;
    }

    @isTest
    static void testGetVehicles() {
        Policy_Draft__c testQuote = [SELECT Id FROM Policy_Draft__c LIMIT 1];

        Test.startTest();
        List<Vehicle__c> vehicles = QuotesCoveragesAssetBulkAdd.getVehicles(testQuote.Id);
        Test.stopTest();

        System.assertEquals(2, vehicles.size(), 'There should be two vehicles associated with the lead of the quote.');
    }

    @isTest
    static void testGetTrailers() {
        Policy_Draft__c testQuote = [SELECT Id FROM Policy_Draft__c LIMIT 1];

        Test.startTest();
        List<Trailer__c> trailers = QuotesCoveragesAssetBulkAdd.getTrailers(testQuote.Id);
        Test.stopTest();

        System.assertEquals(2, trailers.size(), 'There should be two trailers associated with the lead of the quote.');
    }

    @isTest
    static void testGetDrivers() {
        Policy_Draft__c testQuote = [SELECT Id FROM Policy_Draft__c LIMIT 1];

        Test.startTest();
        List<Driver__c> drivers = QuotesCoveragesAssetBulkAdd.getDrivers(testQuote.Id);
        Test.stopTest();

        System.assertEquals(2, drivers.size(), 'There should be two drivers associated with the lead of the quote.');
    }

    @isTest
    static void testGetCoverages() {
        Policy_Draft__c testQuote = [SELECT Id FROM Policy_Draft__c LIMIT 1];

        Test.startTest();
        List<Coverage__c> coverages = QuotesCoveragesAssetBulkAdd.getCoverages(testQuote.Id);
        Test.stopTest();

        System.assertEquals(2, coverages.size(), 'There should be two coverages associated with the policy draft (quote).');
    }

    @isTest
    static void testCreateCoverageAssignmentRecords() {
        Policy_Draft__c testQuote = [SELECT Id FROM Policy_Draft__c LIMIT 1];
        List<Vehicle__c> vehicles = [SELECT Id FROM Vehicle__c];
        List<Trailer__c> trailers = [SELECT Id FROM Trailer__c];
        List<Driver__c> drivers = [SELECT Id FROM Driver__c];
        List<Coverage__c> coverages = [SELECT Id FROM Coverage__c WHERE Policy_Draft__c = :testQuote.Id];

        // Prepare lists of IDs for the method
        List<Id> vehicleIds = new List<Id>();
        List<Id> trailerIds = new List<Id>();
        List<Id> driverIds = new List<Id>();
        List<Id> coverageIds = new List<Id>();

        for (Vehicle__c vehicle : vehicles) vehicleIds.add(vehicle.Id);
        for (Trailer__c trailer : trailers) trailerIds.add(trailer.Id);
        for (Driver__c driver : drivers) driverIds.add(driver.Id);
        for (Coverage__c coverage : coverages) coverageIds.add(coverage.Id);

        // Execute the method to create assignment records
        Test.startTest();
        QuotesCoveragesAssetBulkAdd.createCoverageAssignmentRecords(testQuote.Id, vehicleIds, trailerIds, driverIds, coverageIds);
        Test.stopTest();

        // Validate created Coverage Assignment records
        Integer expectedAssignments = coverageIds.size() * (vehicleIds.size() + trailerIds.size() + driverIds.size());
        
        List<Coverage_Vehicle__c> coverageVehicles = [SELECT Id FROM Coverage_Vehicle__c];
        List<Coverage_Trailer__c> coverageTrailers = [SELECT Id FROM Coverage_Trailer__c];
        List<Coverage_Driver__c> coverageDrivers = [SELECT Id FROM Coverage_Driver__c];

        System.assertEquals(vehicleIds.size() * coverageIds.size(), coverageVehicles.size(), 'The number of Coverage_Vehicle__c records should match the expected count.');
        System.assertEquals(trailerIds.size() * coverageIds.size(), coverageTrailers.size(), 'The number of Coverage_Trailer__c records should match the expected count.');
        System.assertEquals(driverIds.size() * coverageIds.size(), coverageDrivers.size(), 'The number of Coverage_Driver__c records should match the expected count.');
    }
}