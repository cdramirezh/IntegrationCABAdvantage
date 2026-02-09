@isTest
public class ReplicatePolicyAssetsTrigger_Test {
    @isTest
    static void testReplicatePolicyAssets() {
        // Create a Policy_Draft__c record
        Policy_Draft__c policyDraft = new Policy_Draft__c(Name = 'Test Draft');
        insert policyDraft;

        // Create a Binder_Request__c record
        Binder_Request__c binderRequest = new Binder_Request__c(Name = 'Test Binder', Policy_Draft__c = policyDraft.Id);
        insert binderRequest;

        // Create related Policy_Vehicle__c, Policy_Trailer__c, and Policy_Driver__c records
        Vehicle__c vehicle = new Vehicle__c(Name = 'Test Vehicle');
        Trailer__c trailer = new Trailer__c(Name = 'Test Trailer');
        Driver__c driver = new Driver__c(Name = 'Test Driver', CDL__c = 'xxx-xxx-xxxx');
        insert new List<sObject>{ vehicle, trailer, driver };

        Policy_Vehicle__c policyVehicle = new Policy_Vehicle__c(Vehicle__c = vehicle.Id, Policy_Draft__c = policyDraft.Id, Status__c = 'Active');
        Policy_Trailer__c policyTrailer = new Policy_Trailer__c(Trailer__c = trailer.Id, Policy_Draft__c = policyDraft.Id, Status__c = 'Active');
        Policy_Driver__c policyDriver = new Policy_Driver__c(Driver__c = driver.Id, Policy_Draft__c = policyDraft.Id);
        insert new List<sObject>{ policyVehicle, policyTrailer, policyDriver };

        // Create a Policy__c record
        Policy__c policy = new Policy__c(Name = 'Test Policy', Binder_Request__c = binderRequest.Id);
        insert policy;

        // Verify new related records
        List<Policy_Vehicle__c> newVehicles = [
            SELECT Policy__c, Vehicle__c
            FROM Policy_Vehicle__c
            WHERE Policy__c = :policy.Id
        ];
        List<Policy_Trailer__c> newTrailers = [
            SELECT Policy__c, Trailer__c
            FROM Policy_Trailer__c
            WHERE Policy__c = :policy.Id
        ];
        List<Policy_Driver__c> newDrivers = [
            SELECT Policy__c, Driver__c
            FROM Policy_Driver__c
            WHERE Policy__c = :policy.Id
        ];

        System.assertEquals(1, newVehicles.size());
        System.assertEquals(vehicle.Id, newVehicles[0].Vehicle__c);

        System.assertEquals(1, newTrailers.size());
        System.assertEquals(trailer.Id, newTrailers[0].Trailer__c);

        System.assertEquals(1, newDrivers.size());
        System.assertEquals(driver.Id, newDrivers[0].Driver__c);
    }
}