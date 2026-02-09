@isTest
private class EndorsementApplicationControllerTest {


@IsTest
    static void testEndorsementApplicationController() {
        Test.startTest();
        
        // Create a test Endorsement Request record
        Endorsement_Request__c req = new Endorsement_Request__c();
        insert req;

        //Create a Test Vehicle record
        Vehicle__c vehicle = new Vehicle__c();
        insert vehicle;
        
        // Create a test Endorsement Vehicle record linked to the Endorsement Request
        Endorsement_Vehicle__c endvehicleadd = new Endorsement_Vehicle__c(
            Endorsement_Request__c = req.Id,
            Vehicle__c = vehicle.Id,
            Action__c = 'Add'
        );
        insert endvehicleadd;

        /*
        // Create a test Endorsement Vehicle record linked to the Endorsement Request
        Endorsement_Vehicle__c endvehicledel = new Endorsement_Vehicle__c(
            Endorsement_Request__c = req.Id,
            Vehicle__c = vehicle.Id,
            Action__c = 'Delete'
        );
        insert endvehicledel;

        // Create a test Endorsement Vehicle record linked to the Endorsement Request
        Endorsement_Vehicle__c endvehiclemod = new Endorsement_Vehicle__c(
            Endorsement_Request__c = req.Id,
            Vehicle__c = vehicle.Id,
            Action__c = 'Modify'
        );
        insert endvehiclemod;
        */
        
        // Create a StandardController for the Endorsement Request
        ApexPages.StandardController stdController = new ApexPages.StandardController(req);
        
        // Instantiate the EndorsementApplicationController and pass the StandardController as a parameter
        EndorsementApplicationController controller = new EndorsementApplicationController(stdController);
        
        // Verify that the controller is not null
        System.assertNotEquals(null, controller, 'Controller should not be null');
        
        // Verify that the endorsementVehiclestoAdd list contains the expected Endorsement Vehicle record
        System.assertEquals(1, controller.endorsementVehiclestoAdd.size(), 'endorsementVehiclestoAdd list should contain one record');
        System.assertEquals(endvehicleadd.Id, controller.endorsementVehiclestoAdd[0].Id, 'First record in endorsementVehiclestoAdd list should have the same Id as the test Endorsement Vehicle record');
        
        // Verify that the endorsementVehiclestoDelete and endorsementVehiclestoModify lists are empty
        //System.assertEquals(0, controller.endorsementVehiclestoDelete.size(), 'endorsementVehiclestoDelete list should be empty');
        //System.assertEquals(0, controller.endorsementVehiclestoModify.size(), 'endorsementVehiclestoModify list should be empty');
        
        Test.stopTest();
    }
}