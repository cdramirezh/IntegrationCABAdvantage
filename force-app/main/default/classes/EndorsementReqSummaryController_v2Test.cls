@isTest
private class EndorsementReqSummaryController_v2Test {

@IsTest 
static void testGetEndorsementSummary() {
        Endorsement_Request__c request = new Endorsement_Request__c(Process_Owner_p__c = 'Sales Team');
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

        
/*
    }

    @IsTest
        static void testNoRelatedObjects() {
            Endorsement_Request__c request = new Endorsement_Request__c();
            insert request;
*/
            EndorsementRequestSummaryController_v2 controller = new EndorsementRequestSummaryController_v2(new ApexPages.StandardController(request));

            System.assertEquals(0, controller.modifiedDriversCount);
            System.assertEquals(0, controller.modifiedVehiclesCount);
            System.assertEquals(0, controller.modifiedTrailersCount);
            System.assertEquals(1, controller.addedDriversCount);
            System.assertEquals(1, controller.addedVehiclesCount);
            System.assertEquals(1, controller.addedTrailersCount);
            System.assertEquals(0, controller.deletedDriversCount);
            System.assertEquals(0, controller.deletedVehiclesCount);
            System.assertEquals(0, controller.deletedTrailersCount);
        }
}