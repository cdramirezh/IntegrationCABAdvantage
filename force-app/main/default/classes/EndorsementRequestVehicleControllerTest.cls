@isTest
private class EndorsementRequestVehicleControllerTest {


@IsTest
    static void testGetRecordsByEndorsementRequest() {
        
            Endorsement_Request__c request = new Endorsement_Request__c();
            insert request;

            Policy__c policy = new Policy__c();
            insert policy;

            Endorsement_Policy__c endorsementPolicy = new Endorsement_Policy__c(Endorsement_Request__c = request.Id, Policy__c = policy.Id);
            insert endorsementPolicy;

            Vehicle__c vehicle = new Vehicle__c();
            insert vehicle;

            Policy_Vehicle__c policyVehicle = new Policy_Vehicle__c(Policy__c = policy.Id, Vehicle__c = vehicle.Id);
            insert policyVehicle;

            Driver__c driver = new Driver__c(CDL__c = '123qwe456');
            insert driver;

            Policy_Driver__c policyDriver = new Policy_Driver__c(Policy__c = policy.Id, Driver__c = driver.Id);
            insert policyDriver;

            Trailer__c trailer = new Trailer__c();
            insert trailer;

            Policy_Trailer__c policyTrailer = new Policy_Trailer__c(Policy__c = policy.Id, Trailer__c = trailer.Id);
            insert policyTrailer;

            Map<String, List<Map<String, String>>> result = EndorsementRequestVehicleController.getRecordsByEndorsementRequest(request.Id);

            System.assertEquals(1, result.get('vehicles').size());
            System.assertEquals(1, result.get('trailers').size());
            System.assertEquals(1, result.get('drivers').size());
        
    }





@IsTest
    static void testCreateEndorsementRecords() {

        Endorsement_Request__c testrequest = new Endorsement_Request__c();
        insert testrequest;

        Policy__c testpolicy = new Policy__c();
        insert testpolicy;

        Endorsement_Policy__c testendorsementPolicy = new Endorsement_Policy__c(Endorsement_Request__c = testrequest.Id, Policy__c = testpolicy.Id);
        insert testendorsementPolicy;

        Vehicle__c testvehicle = new Vehicle__c(Name = 'Test Vehicle 2');
        insert testvehicle;

        Policy_Vehicle__c testpolicyVehicle = new Policy_Vehicle__c(Policy__c = testpolicy.Id, Vehicle__c = testvehicle.Id);
        insert testpolicyVehicle;

        Driver__c testdriver = new Driver__c(CDL__c = '123qwe456');
        insert testdriver;

        Policy_Driver__c testpolicyDriver = new Policy_Driver__c(Policy__c = testpolicy.Id, Driver__c = testdriver.Id);
        insert testpolicyDriver;

        Trailer__c testtrailer = new Trailer__c();
        insert testtrailer;

        Policy_Trailer__c testpolicyTrailer = new Policy_Trailer__c(Policy__c = testpolicy.Id, Trailer__c = testtrailer.Id);
        insert testpolicyTrailer;
        
        Test.startTest();
        List<Id> vehicleIds = new List<Id>();
        List<Id> trailerIds = new List<Id>();
        List<Id> driverIds = new List<Id>();

        // Fetch test data
        Endorsement_Request__c request = [SELECT Id FROM Endorsement_Request__c LIMIT 1];
        Vehicle__c vehicle = [SELECT Id FROM Vehicle__c LIMIT 1];
        Vehicle__c vehicle2 = [SELECT Id FROM Vehicle__c WHERE Name = 'Test Vehicle 2' LIMIT 1];
        Trailer__c trailer = [SELECT Id FROM Trailer__c LIMIT 1];
        Driver__c driver = [SELECT Id FROM Driver__c LIMIT 1];

        vehicleIds.add(vehicle.Id);
        vehicleIds.add(vehicle2.Id);
        trailerIds.add(trailer.Id);
        driverIds.add(driver.Id);

        // Call the method
        Map<String, Object> result = EndorsementRequestVehicleController.createEndorsementRecords(
            request.Id,
            vehicleIds,
            trailerIds,
            driverIds,
            'Add'
        );

        // Assert the results
        System.assertEquals(result.get('success'), true, 'Expected success to be true');

        Endorsement_Vehicle__c createdVehicle = [
            SELECT Id, Endorsement_Request__c, Vehicle__c, Action__c
            FROM Endorsement_Vehicle__c
            WHERE Vehicle__c = :vehicle.Id
            LIMIT 1
        ];
        System.assertNotEquals(null, createdVehicle, 'Expected one Endorsement_Vehicle__c record to be created');
        System.assertEquals(request.Id, createdVehicle.Endorsement_Request__c, 'Incorrect Endorsement_Request__c association');
        System.assertEquals(vehicle.Id, createdVehicle.Vehicle__c, 'Incorrect Vehicle__c association');
        System.assertEquals('Add', createdVehicle.Action__c, 'Incorrect Action__c value');

        Endorsement_Trailer__c createdTrailer = [
            SELECT Id, Endorsement_Request__c, Trailer__c, Action__c
            FROM Endorsement_Trailer__c
            WHERE Trailer__c = :trailer.Id
            LIMIT 1
        ];
        System.assertNotEquals(null, createdTrailer, 'Expected one Endorsement_Trailer__c record to be created');
        System.assertEquals(request.Id, createdTrailer.Endorsement_Request__c, 'Incorrect Endorsement_Request__c association');
        System.assertEquals(trailer.Id, createdTrailer.Trailer__c, 'Incorrect Trailer__c association');
        System.assertEquals('Add', createdTrailer.Action__c, 'Incorrect Action__c value');

        Endorsement_Driver__c createdDriver = [
            SELECT Id, Endorsement_Request__c, Driver__c, Action__c
            FROM Endorsement_Driver__c
            WHERE Driver__c = :driver.Id
            LIMIT 1
        ];
        System.assertNotEquals(null, createdDriver, 'Expected one Endorsement_Driver__c record to be created');
        System.assertEquals(request.Id, createdDriver.Endorsement_Request__c, 'Incorrect Endorsement_Request__c association');
        System.assertEquals(driver.Id, createdDriver.Driver__c, 'Incorrect Driver__c association');
        System.assertEquals('Add', createdDriver.Action__c, 'Incorrect Action__c value');

        Test.stopTest();
    }
}