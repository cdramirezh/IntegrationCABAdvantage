@isTest
private class EndorsementRequestSummaryControllerTest {

@IsTest 
static void testGetEndorsementSummary() {
        Endorsement_Request__c request = new Endorsement_Request__c();
        insert request;

        Policy__c policy = new Policy__c();
        insert policy;

        Endorsement_Policy__c endorsementPolicy = new Endorsement_Policy__c(
            Endorsement_Request__c = request.Id,
            Policy__c = policy.Id
        );
        insert endorsementPolicy;

        Coverage__c coverage = new Coverage__c();
        insert coverage;

        Endorsement_Coverage__c endorsementCoverage = new Endorsement_Coverage__c(
            Endorsement_Request__c = request.Id,
            Coverage__c = coverage.Id
        );
        insert endorsementCoverage;

        Vehicle__c vehicle = new Vehicle__c();
        insert vehicle;

        Endorsement_Vehicle__c endorsementVehicle = new Endorsement_Vehicle__c(
            Endorsement_Request__c = request.Id,
            Vehicle__c = vehicle.Id,
            Action__c = 'Add'
        );
        insert endorsementVehicle;

        Trailer__c trailer = new Trailer__c();
        insert trailer;

        Endorsement_Trailer__c endorsementTrailer = new Endorsement_Trailer__c(
            Endorsement_Request__c = request.Id,
            Trailer__c = trailer.Id,
            Action__c = 'Add'
        );
        insert endorsementTrailer;

        Driver__c driver = new Driver__c();
        driver.CDL__c = 'ABCD1234';
        insert driver;

        Endorsement_Driver__c endorsementDriver = new Endorsement_Driver__c(
            Endorsement_Request__c = request.Id,
            Driver__c = driver.Id,
            Action__c = 'Add'
        );
        insert endorsementDriver;

        Map<String, Object> result = EndorsementRequestSummaryController.getEndorsementSummary(request.Id);

        // Extracting lists from the returned map
        List<SObject> policies = (List<SObject>) result.get('policies');
        List<SObject> coverages = (List<SObject>) result.get('coverages');
        //List<SObject> vehicles = (List<SObject>) ((Map<String, List<SObject>>) result.get('vehicles')).get('Add');
        //List<SObject> trailers = (List<SObject>) ((Map<String, List<SObject>>) result.get('trailers')).get('Add');
        //List<SObject> drivers = (List<SObject>) ((Map<String, List<SObject>>) result.get('drivers')).get('Add');

        Map<String, List<SObject>> vehiclesData = (Map<String, List<SObject>>) result.get('vehicles');
        Integer vehiclesDataSize = vehiclesData.get('Add').size();

        //Assert.areEqual(1, vehiclesData.get('Add').size(), 'Expected exactly one vehicle to be returned in the Add group');

        Map<String, List<SObject>> trailersData = (Map<String, List<SObject>>) result.get('trailers');
        Integer trailersDataSize = trailersData.get('Add').size();
        //Assert.areEqual(1, trailersData.get('Add').size(), 'Expected exactly one vehicle to be returned in the Add group');

        Map<String, List<SObject>> driversData = (Map<String, List<SObject>>) result.get('drivers');
        Integer driversDataSize = driversData.get('Add').size();
        //Assert.areEqual(1, driversData.get('Add').size(), 'Expected exactly one vehicle to be returned in the Add group');


        Assert.areEqual(1, policies.size(), 'Expected at least one policy to be returned');
        Assert.areEqual(1, coverages.size(), 'Expected at least one coverage to be returned');
        //Assert.areEqual(1, vehicles.size(), 'Expected at least one vehicle to be returned');
        //Assert.areEqual(1, trailers.size(), 'Expected at least one trailer to be returned');
        //Assert.areEqual(1, drivers.size(), 'Expected at least one driver to be returned');
    }
}