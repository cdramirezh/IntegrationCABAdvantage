@IsTest
public class PolicyAssetBulkAdd_Test {
    @TestSetup
    static void setupTestData() {
        // Create test Account and Opportunity
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        Opportunity testOpportunity = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            AccountId = testAccount.Id
        );
        insert testOpportunity;

        // Create test Lead
        Lead testLead = new Lead(
            FirstName = 'Test',
            LastName = 'Lead',
            Company = 'Test Company',
            Status = 'Open - Not Contacted'
        );
        insert testLead;

        // Create test Policy Drafts
        Policy_Draft__c policyDraftWithOpportunity = new Policy_Draft__c(
            Opportunity__c = testOpportunity.Id,
            Status__c = 'Open'
        );
        insert policyDraftWithOpportunity;

        Policy_Draft__c policyDraftWithLead = new Policy_Draft__c(
            Lead__c = testLead.Id,
            Status__c = 'Open'
        );
        insert policyDraftWithLead;

        // Create related Vehicles, Trailers, and Drivers
        Vehicle__c vehicle1 = new Vehicle__c(Name = 'Vehicle 1', Account__c = testAccount.Id);
        Vehicle__c vehicle2 = new Vehicle__c(Name = 'Vehicle 2', Lead__c = testLead.Id);
        insert new List<Vehicle__c> { vehicle1, vehicle2 };

        Trailer__c trailer1 = new Trailer__c(Name = 'Trailer 1', Account__c = testAccount.Id);
        Trailer__c trailer2 = new Trailer__c(Name = 'Trailer 2', Lead__c = testLead.Id);
        insert new List<Trailer__c> { trailer1, trailer2 };

        Driver__c driver1 = new Driver__c(Name = 'Driver 1', Account__c = testAccount.Id, CDL__c = '12345');
        Driver__c driver2 = new Driver__c(Name = 'Driver 2', Lead__c = testLead.Id, CDL__c = '67890');
        insert new List<Driver__c> { driver1, driver2 };
    }

    @IsTest
    static void testGetVehicles() {
        // Retrieve Policy Drafts
        Policy_Draft__c policyDraftWithOpportunity = [SELECT Id FROM Policy_Draft__c WHERE Opportunity__c != null LIMIT 1];
        Policy_Draft__c policyDraftWithLead = [SELECT Id FROM Policy_Draft__c WHERE Lead__c != null LIMIT 1];

        // Test for Policy Draft with Opportunity
        List<Vehicle__c> vehiclesForOpportunity = PolicyAssetBulkAdd.getVehicles(policyDraftWithOpportunity.Id);
        System.assertEquals(1, vehiclesForOpportunity.size());
        System.assertEquals('Vehicle 1', vehiclesForOpportunity[0].Name);

        // Test for Policy Draft with Lead
        List<Vehicle__c> vehiclesForLead = PolicyAssetBulkAdd.getVehicles(policyDraftWithLead.Id);
        System.assertEquals(1, vehiclesForLead.size());
        System.assertEquals('Vehicle 2', vehiclesForLead[0].Name);
    }

    @IsTest
    static void testGetTrailers() {
        // Retrieve Policy Drafts
        Policy_Draft__c policyDraftWithOpportunity = [SELECT Id FROM Policy_Draft__c WHERE Opportunity__c != null LIMIT 1];
        Policy_Draft__c policyDraftWithLead = [SELECT Id FROM Policy_Draft__c WHERE Lead__c != null LIMIT 1];

        // Test for Policy Draft with Opportunity
        List<Trailer__c> trailersForOpportunity = PolicyAssetBulkAdd.getTrailers(policyDraftWithOpportunity.Id);
        System.assertEquals(1, trailersForOpportunity.size());
        System.assertEquals('Trailer 1', trailersForOpportunity[0].Name);

        // Test for Policy Draft with Lead
        List<Trailer__c> trailersForLead = PolicyAssetBulkAdd.getTrailers(policyDraftWithLead.Id);
        System.assertEquals(1, trailersForLead.size());
        System.assertEquals('Trailer 2', trailersForLead[0].Name);
    }

    @IsTest
    static void testGetDrivers() {
        // Retrieve Policy Drafts
        Policy_Draft__c policyDraftWithOpportunity = [SELECT Id FROM Policy_Draft__c WHERE Opportunity__c != null LIMIT 1];
        Policy_Draft__c policyDraftWithLead = [SELECT Id FROM Policy_Draft__c WHERE Lead__c != null LIMIT 1];

        // Test for Policy Draft with Opportunity
        List<Driver__c> driversForOpportunity = PolicyAssetBulkAdd.getDrivers(policyDraftWithOpportunity.Id);
        System.assertEquals(1, driversForOpportunity.size());
        System.assertEquals('Driver 1', driversForOpportunity[0].Name);

        // Test for Policy Draft with Lead
        List<Driver__c> driversForLead = PolicyAssetBulkAdd.getDrivers(policyDraftWithLead.Id);
        System.assertEquals(1, driversForLead.size());
        System.assertEquals('Driver 2', driversForLead[0].Name);
    }

    @IsTest
    static void testCreatePolicyAssetRecords() {
        // Retrieve Policy Draft and related records
        Policy_Draft__c policyDraft = [SELECT Id FROM Policy_Draft__c LIMIT 1];
        List<Vehicle__c> vehicles = [SELECT Id FROM Vehicle__c LIMIT 1];
        List<Trailer__c> trailers = [SELECT Id FROM Trailer__c LIMIT 1];
        List<Driver__c> drivers = [SELECT Id FROM Driver__c LIMIT 1];

        // Call method
        PolicyAssetBulkAdd.createPolicyAssetRecords(
            policyDraft.Id,
            new List<Id> { vehicles[0].Id },
            new List<Id> { trailers[0].Id },
            new List<Id> { drivers[0].Id }
        );

        // Verify records
        System.assertEquals(1, [SELECT COUNT() FROM Policy_Vehicle__c WHERE Policy_Draft__c = :policyDraft.Id]);
        System.assertEquals(1, [SELECT COUNT() FROM Policy_Trailer__c WHERE Policy_Draft__c = :policyDraft.Id]);
        System.assertEquals(1, [SELECT COUNT() FROM Policy_Driver__c WHERE Policy_Draft__c = :policyDraft.Id]);
    }
}