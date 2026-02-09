@isTest
public class PolicyEndorsementController_Test {
    
    @TestSetup
    static void makeData() {

        // Create Policy
        Policy__c testPolicy = new Policy__c(
            Name = 'Test Policy',
            Effective_Date__c = Date.today().addDays(-30),
            Status__c = 'Active'
        );
        insert testPolicy;
        
        // Create Makes
        Make__c vehicleMake = new Make__c(Name = 'Ford');
        Make__c trailerMake = new Make__c(Name = 'Freightliner');
        insert new List<Make__c>{vehicleMake, trailerMake};
        
        // Create Vehicle
        Vehicle__c testVehicle = new Vehicle__c(
            Name = 'TEST123456789',
            Make__c = vehicleMake.Id,
            Year__c = 2020
        );
        insert testVehicle;
        
        // Create Trailer
        Trailer__c testTrailer = new Trailer__c(
            Name = 'TRAILER123456',
            Make__c = trailerMake.Id,
            Year__c = 2019
        );
        insert testTrailer;
        
        // Create Driver
        Driver__c testDriver = new Driver__c(
            Name = 'John Doe',
            CDL__c = 'CDL123456'
        );
        insert testDriver;
        
        // Create Policy Vehicle
        Policy_Vehicle__c policyVehicle = new Policy_Vehicle__c(
            Policy__c = testPolicy.Id,
            Vehicle__c = testVehicle.Id,
            Status__c = 'Active'
        );
        insert policyVehicle;
        
        // Create Policy Trailer
        Policy_Trailer__c policyTrailer = new Policy_Trailer__c(
            Policy__c = testPolicy.Id,
            Trailer__c = testTrailer.Id,
            Status__c = 'Active'
        );
        insert policyTrailer;
        
        // Create Policy Driver
        Policy_Driver__c policyDriver = new Policy_Driver__c(
            Policy__c = testPolicy.Id,
            Driver__c = testDriver.Id,
            Status__c = 'Active'
        );
        insert policyDriver;
        
        // Create Endorsement Request
        Endorsement_Request__c endorsementRequest = new Endorsement_Request__c(
            //Name = 'Test Endorsement',
            Effective_Date__c = Date.today().addDays(-15),
            Status__c = 'Completed',
            Process_Owner_p__c = 'Loyalty Team'
         );
        insert endorsementRequest;
        
        // Create Endorsement Policy junction
        Endorsement_Policy__c endorsementPolicy = new Endorsement_Policy__c(
            Endorsement_Request__c = endorsementRequest.Id,
            Policy__c = testPolicy.Id
        );
        insert endorsementPolicy;
        
        // Create additional Vehicle and Driver for endorsement
        Vehicle__c endorsementVehicle = new Vehicle__c(
            Name = 'ENDORSE123456',
            Make__c = vehicleMake.Id,
            Year__c = 2021
        );
        insert endorsementVehicle;
        
        Trailer__c endorsementTrailer = new Trailer__c(
            Name = 'ENDTRAILER123',
            Make__c = trailerMake.Id,
            Year__c = 2020
        );
        insert endorsementTrailer;
        
        Driver__c endorsementDriver = new Driver__c(
            Name = 'Jane Smith',
            CDL__c = 'CDL789012'
        );
        insert endorsementDriver;
        
        // Create Endorsement Vehicle
        Endorsement_Vehicle__c endorsementVehicleRec = new Endorsement_Vehicle__c(
            Endorsement_Request__c = endorsementRequest.Id,
            Vehicle__c = endorsementVehicle.Id,
            Action__c = 'Add'
        );
        insert endorsementVehicleRec;
        
        // Create Endorsement Trailer
        Endorsement_Trailer__c endorsementTrailerRec = new Endorsement_Trailer__c(
            Endorsement_Request__c = endorsementRequest.Id,
            Trailer__c = endorsementTrailer.Id,
            Action__c = 'Add'
        );
        insert endorsementTrailerRec;
        
        // Create Endorsement Driver
        Endorsement_Driver__c endorsementDriverRec = new Endorsement_Driver__c(
            Endorsement_Request__c = endorsementRequest.Id,
            Driver__c = endorsementDriver.Id,
            Action__c = 'Add'
        );
        insert endorsementDriverRec;
    }
    
    @isTest
    static void testGetEndorsementHistorySuccess() {
        // Get test policy
        Policy__c testPolicy = [SELECT Id FROM Policy__c LIMIT 1];
        
        Test.startTest();
        List<PolicyEndorsementController.EndorsementWrapper> results = 
            PolicyEndorsementController.getEndorsementHistory(testPolicy.Id);
        Test.stopTest();
        
        // Assertions
        System.assertNotEquals(null, results, 'Results should not be null');
        System.assert(results.size() > 0, 'Should return endorsement records');
        
        // Verify we have records from policy sale and endorsements
        Boolean foundPolicyVehicle = false;
        Boolean foundPolicyTrailer = false;
        Boolean foundPolicyDriver = false;
        Boolean foundEndorsementVehicle = false;
        Boolean foundEndorsementTrailer = false;
        Boolean foundEndorsementDriver = false;
        
        for (PolicyEndorsementController.EndorsementWrapper wrapper : results) {
            if (wrapper.endorsementRequestName == 'From Policy Sale') {
                if (wrapper.recordType == 'Vehicle') foundPolicyVehicle = true;
                if (wrapper.recordType == 'Trailer') foundPolicyTrailer = true;
                if (wrapper.recordType == 'Driver') foundPolicyDriver = true;
            } else {
                if (wrapper.recordType == 'Vehicle') foundEndorsementVehicle = true;
                if (wrapper.recordType == 'Trailer') foundEndorsementTrailer = true;
                if (wrapper.recordType == 'Driver') foundEndorsementDriver = true;
            }
            
            // Verify wrapper properties are populated
            System.assertNotEquals(null, wrapper.id, 'ID should not be null');
            System.assertNotEquals(null, wrapper.recordType, 'Record type should not be null');
            System.assertNotEquals(null, wrapper.action, 'Action should not be null');
        }
        
        System.assert(foundPolicyVehicle, 'Should find policy vehicle');
        System.assert(foundPolicyTrailer, 'Should find policy trailer');
        System.assert(foundPolicyDriver, 'Should find policy driver');
        System.assert(foundEndorsementVehicle, 'Should find endorsement vehicle');
        System.assert(foundEndorsementTrailer, 'Should find endorsement trailer');
        System.assert(foundEndorsementDriver, 'Should find endorsement driver');
    }
    
    /*
    @isTest
    static void testGetEndorsementHistoryWithInactiveRecords() {
        // Get test policy and create inactive records
        Policy__c testPolicy = [SELECT Id FROM Policy__c LIMIT 1];
        Vehicle__c inactiveVehicle = [SELECT Id FROM Vehicle__c WHERE Name = 'TEST123456789' LIMIT 1];
        
        // Create inactive policy vehicle
        Policy_Vehicle__c inactivePolicyVehicle = new Policy_Vehicle__c(
            Policy__c = testPolicy.Id,
            Vehicle__c = inactiveVehicle.Id,
            Status__c = 'Inactive'
        );
        insert inactivePolicyVehicle;
        
        Test.startTest();
        List<PolicyEndorsementController.EndorsementWrapper> results = 
            PolicyEndorsementController.getEndorsementHistory(testPolicy.Id);
        Test.stopTest();
        
        // Verify inactive records are not included
        for (PolicyEndorsementController.EndorsementWrapper wrapper : results) {
            System.assertNotEquals(inactivePolicyVehicle.Id, wrapper.id, 
                'Inactive records should not be included');
        }
    }
    
    @isTest
    static void testGetEndorsementHistoryWithNonCompletedEndorsements() {
        // Get test policy
        Policy__c testPolicy = [SELECT Id FROM Policy__c LIMIT 1];
        
        // Create non-completed endorsement request
        Endorsement_Request__c pendingEndorsement = new Endorsement_Request__c(
            //Name = 'Pending Endorsement',
            Effective_Date__c = Date.today(),
            Status__c = 'Pending'
        );
        insert pendingEndorsement;
        
        Endorsement_Policy__c endorsementPolicy = new Endorsement_Policy__c(
            Endorsement_Request__c = pendingEndorsement.Id,
            Policy__c = testPolicy.Id
        );
        insert endorsementPolicy;
        
        Test.startTest();
        List<PolicyEndorsementController.EndorsementWrapper> results = 
            PolicyEndorsementController.getEndorsementHistory(testPolicy.Id);
        Test.stopTest();
        
        // Verify only completed endorsements are included
        for (PolicyEndorsementController.EndorsementWrapper wrapper : results) {
            System.assertNotEquals('Pending Endorsement', wrapper.endorsementRequestName,
                'Non-completed endorsements should not be included');
        }
    }
    
    @isTest
    static void testGetEndorsementHistoryEmptyResults() {
        // Create policy with no related records
        //Account emptyAccount = new Account(Name = 'Empty Account');
        //insert emptyAccount;
        
        Policy__c emptyPolicy = new Policy__c(
            Name = 'Empty Policy',
            //Account__c = emptyAccount.Id,
            Effective_Date__c = Date.today(),
            Status__c = 'Active'
        );
        insert emptyPolicy;
        
        Test.startTest();
        List<PolicyEndorsementController.EndorsementWrapper> results = 
            PolicyEndorsementController.getEndorsementHistory(emptyPolicy.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, results, 'Results should not be null');
        System.assertEquals(0, results.size(), 'Should return empty list for policy with no endorsements');
    }
    
    
    @isTest
    static void testGetEndorsementHistoryException() {
        Test.startTest();
        try {
            // Pass null policy ID to trigger exception
            PolicyEndorsementController.getEndorsementHistory(null);
            System.assert(false, 'Expected AuraHandledException');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('Error retrieving endorsement history'), 
                'Should throw AuraHandledException with proper message');
        }
        Test.stopTest();
    }
        
    
    @isTest
    static void testGetLatestEndorsementsSuccess() {
        Policy__c testPolicy = [SELECT Id FROM Policy__c LIMIT 1];
        
        Test.startTest();
        List<PolicyEndorsementController.EndorsementWrapper> results = 
            PolicyEndorsementController.getLatestEndorsements(testPolicy.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, results, 'Results should not be null');
        System.assert(results.size() > 0, 'Should return latest endorsement records');
        
        // Verify each unique combination appears only once
        Set<String> uniqueKeys = new Set<String>();
        for (PolicyEndorsementController.EndorsementWrapper wrapper : results) {
            String uniqueKey = wrapper.recordType + '_' + wrapper.identifier;
            System.assert(!uniqueKeys.contains(uniqueKey), 
                'Each unique record type and identifier combination should appear only once');
            uniqueKeys.add(uniqueKey);
        }
    }
    
    @isTest
    static void testGetLatestEndorsementsWithDuplicates() {
        Policy__c testPolicy = [SELECT Id FROM Policy__c LIMIT 1];
        Vehicle__c testVehicle = [SELECT Id FROM Vehicle__c WHERE Name = 'TEST123456789' LIMIT 1];
        
        // Create another endorsement request for the same vehicle (newer date)
        Endorsement_Request__c newerEndorsement = new Endorsement_Request__c(
            //Name = 'Newer Endorsement',
            Effective_Date__c = Date.today().addDays(-5),
            Status__c = 'Completed'
        );
        insert newerEndorsement;
        
        Endorsement_Policy__c endorsementPolicy = new Endorsement_Policy__c(
            Endorsement_Request__c = newerEndorsement.Id,
            Policy__c = testPolicy.Id
        );
        insert endorsementPolicy;
        
        Endorsement_Vehicle__c newerEndorsementVehicle = new Endorsement_Vehicle__c(
            Endorsement_Request__c = newerEndorsement.Id,
            Vehicle__c = testVehicle.Id,
            Action__c = 'Remove'
        );
        insert newerEndorsementVehicle;
        
        Test.startTest();
        List<PolicyEndorsementController.EndorsementWrapper> results = 
            PolicyEndorsementController.getLatestEndorsements(testPolicy.Id);
        Test.stopTest();
        
        // Verify the newer endorsement is returned for the vehicle
        Boolean foundNewerEndorsement = false;
        for (PolicyEndorsementController.EndorsementWrapper wrapper : results) {
            if (wrapper.recordType == 'Vehicle' && wrapper.identifier == 'Test Vehicle') {
                // Should find the newer endorsement, not the original policy vehicle
                if (wrapper.endorsementRequestName == 'Newer Endorsement') {
                    foundNewerEndorsement = true;
                }
                System.assertNotEquals('From Policy Sale', wrapper.endorsementRequestName,
                    'Should return newer endorsement, not original policy record');
            }
        }
        
        System.assert(foundNewerEndorsement, 'Should find the newer endorsement for the vehicle');
    }
    
    /*
    @isTest
    static void testGetLatestEndorsementsException() {
        Test.startTest();
        try {
            // Pass null policy ID to trigger exception
            PolicyEndorsementController.getLatestEndorsements(null);
            System.assert(false, 'Expected AuraHandledException');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('Error retrieving latest endorsements'), 
                'Should throw AuraHandledException with proper message');
        }
        Test.stopTest();
    }
        
    
    @isTest
    static void testEndorsementWrapperConstructor() {
        Test.startTest();
        
        // Test with all values
        PolicyEndorsementController.EndorsementWrapper wrapper1 = 
            new PolicyEndorsementController.EndorsementWrapper(
                'testId',
                'Test Endorsement',
                Date.today(),
                'Vehicle',
                'Test Vehicle',
                'Ford',
                2020,
                'John Doe',
                'Add'
            );
        
        System.assertEquals('testId', wrapper1.id);
        System.assertEquals('Test Endorsement', wrapper1.endorsementRequestName);
        System.assertEquals('Vehicle', wrapper1.recordType);
        System.assertEquals('Test Vehicle', wrapper1.identifier);
        System.assertEquals('Ford', wrapper1.Make);
        System.assertEquals(2020, wrapper1.Year);
        System.assertEquals('John Doe', wrapper1.DriverName);
        System.assertEquals('Add', wrapper1.action);
        System.assertNotEquals(null, wrapper1.endorsementCreatedDate);
        
        // Test with null values
        PolicyEndorsementController.EndorsementWrapper wrapper2 = 
            new PolicyEndorsementController.EndorsementWrapper(
                'testId2',
                'Test Endorsement 2',
                null,
                'Driver',
                null,
                null,
                null,
                null,
                null
            );
        
        System.assertEquals('', wrapper2.endorsementCreatedDate);
        System.assertEquals('', wrapper2.identifier);
        System.assertEquals('', wrapper2.Make);
        System.assertEquals(0, wrapper2.Year);
        System.assertEquals('', wrapper2.DriverName);
        System.assertEquals('', wrapper2.action);
        
        Test.stopTest();
    }
    
    @isTest
    static void testEndorsementDateComparator() {
        Test.startTest();
        
        PolicyEndorsementController.EndorsementDateComparator comparator = 
            new PolicyEndorsementController.EndorsementDateComparator();
        
        // Create wrappers with different dates
        PolicyEndorsementController.EndorsementWrapper older = 
            new PolicyEndorsementController.EndorsementWrapper(
                'older', 'Older', Date.today().addDays(-10), 'Vehicle', 'Test', 'Ford', 2020, '', 'Add'
            );
        
        PolicyEndorsementController.EndorsementWrapper newer = 
            new PolicyEndorsementController.EndorsementWrapper(
                'newer', 'Newer', Date.today().addDays(-5), 'Vehicle', 'Test', 'Ford', 2020, '', 'Add'
            );
        
        PolicyEndorsementController.EndorsementWrapper same = 
            new PolicyEndorsementController.EndorsementWrapper(
                'same', 'Same', Date.today().addDays(-5), 'Vehicle', 'Test', 'Ford', 2020, '', 'Add'
            );
        
        // Test comparisons
        System.assertEquals(-1, comparator.compare(newer, older), 'Newer should come before older');
        System.assertEquals(1, comparator.compare(older, newer), 'Older should come after newer');
        System.assertEquals(0, comparator.compare(newer, same), 'Same dates should be equal');
        
        Test.stopTest();
    }
    
    @isTest
    static void testSortingFunctionality() {
        Policy__c testPolicy = [SELECT Id FROM Policy__c LIMIT 1];
        
        Test.startTest();
        List<PolicyEndorsementController.EndorsementWrapper> results = 
            PolicyEndorsementController.getEndorsementHistory(testPolicy.Id);
        Test.stopTest();
        
        // Verify results are sorted by date (newest first)
        for (Integer i = 0; i < results.size() - 1; i++) {
            System.assert(
                results[i].rawCreatedDate >= results[i + 1].rawCreatedDate,
                'Results should be sorted by date, newest first'
            );
        }
    }
        */
}