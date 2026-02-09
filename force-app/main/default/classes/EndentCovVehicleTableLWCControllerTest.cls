@isTest
public class EndentCovVehicleTableLWCControllerTest {       

    @isTest
    static void testGetVehicles() {
        //Endorsement_Request__c er = [SELECT Id FROM Endorsement_Request__c LIMIT 1];

        // Create Make
        Make__c make = new Make__c(Name = 'Test Make');
        insert make;

        // Create Vehicle
        Vehicle__c vehicle = new Vehicle__c(
            Name = 'Test Vehicle',
            //VIN__c = '123456789',
            Weight__c = 10000,
            Year__c = 2020,
            Make__c = make.Id,
            Value__c = 45000
        );
        insert vehicle;

        // Create Opportunity and Account if needed (mocked for potential reference)
        Account acc = new Account(Name = 'Test Account', Owner_DOB__c = Date.today());
        insert acc;

        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            AccountId = acc.Id,
            CloseDate = Date.today().addDays(30),
            StageName = 'Prospecting'
        );
        insert opp;

        // Create Endorsement_Request__c
        Endorsement_Request__c er = new Endorsement_Request__c(
            //Name = 'Test ER',
            Opportunity__c = opp.Id
        );
        insert er;

        // Create Endorsement_Vehicle__c
        Endorsement_Vehicle__c ev = new Endorsement_Vehicle__c(
            //Name = 'EV 001',
            Endorsement_Request__c = er.Id,
            Vehicle__c = vehicle.Id,
            Action__c = 'Modify',
            New_Value__c = 46000,
            New_VIN__c = '987654321',
            New_Weight__c = 11000,
            New_Year__c = 2021
        );
        insert ev;

        List<Endorsement_Vehicle__c> evList = [SELECT Id, New_Value__c FROM Endorsement_Vehicle__c];
        evList[0].New_Value__c = 55555;

        Test.startTest();
        List<Endorsement_Vehicle__c> results = EndorsementCovVehicleTableLWCController.getVehicles(er.Id);
        EndorsementCovVehicleTableLWCController.updateVehicles(evList);
        Test.stopTest();

        System.assertNotEquals(0, results.size(), 'Should return at least one vehicle');
        System.assertEquals('Modify', results[0].Action__c);
        System.assertNotEquals(null, results[0].Vehicle__r.Name);
        System.assertNotEquals(null, results[0].Vehicle__r.Make__r.Name);        

        Endorsement_Vehicle__c updated = [SELECT Id, New_Value__c FROM Endorsement_Vehicle__c WHERE Id = :evList[0].Id];
        System.assertEquals(55555, updated.New_Value__c);

    }
}