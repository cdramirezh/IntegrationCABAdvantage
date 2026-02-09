@isTest
public class PolicyDraftPDFController_v5_Test {

    @isTest
    static void testControllerInitialization() {
        // Create test data
        Lead lead = new Lead(
            FirstName = 'Test',
            LastName = 'Lead',
            Company = 'Test Company',
            USDOT__c = '12345',
            Phone = '123-456-7890',
            Email = 'testlead@example.com',
            Power_Units__c = 5,
            Radius__c = 'Local Less than 300 miles',
            Owner_DOB__c = Date.today().addYears(-30)
        );
        insert lead;

        Account account = new Account(
            Name = 'Test Account',
            Parking_Street__c = '123 Test St',
            Parking_City__c = 'Test City',
            Parking_State__c = 'TX',
            Parking_ZIP__c = '12345',
            Mailing_Street__c = '123 Test St',
            Mailing_City__c = 'Test City',
            Mailing_State__c = 'TX',
            Mailing_ZIP__c = '12345',
            Federal_Filing_MC__c = '12345',
            State_Filing__c = '12345',
            UIIA__c = true,
            SCAD_Code__c = '12345',
            DBA__c = 'Test Company',
            Company_Rep__c = 'Test Company Rep',
            Years_in_Business__c = 1,
            Owner_DOB__c = Date.today().addYears(-30)
        );
        insert account;

        Opportunity opportunity = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            AccountId = account.Id
        );
        insert opportunity;

        Contact contact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            Phone = '123-456-7890',
            Email = 'testing@company.co',
            AccountId = account.Id
        );
        insert contact;

        Policy_Draft__c LeadPolicyDraft = new Policy_Draft__c(
            Name = 'Test Policy Draft',
            Lead__c = lead.Id            
        );
        insert LeadPolicyDraft;

        Policy_Draft__c OppPolicyDraft = new Policy_Draft__c(
            Name = 'Test Policy Draft',
            Opportunity__c = opportunity.Id
        );
        insert OppPolicyDraft;

        // Create standard controller for the test
        ApexPages.StandardController standardController = new ApexPages.StandardController(LeadPolicyDraft);

        // Create standard controller for the test
        ApexPages.StandardController oppstandardController = new ApexPages.StandardController(OppPolicyDraft);

        // Instantiate the controller
        Test.startTest();
        PolicyDraftPDFController_v5 controller = new PolicyDraftPDFController_v5(standardController);
        PolicyDraftPDFController_v5 Oppcontroller = new PolicyDraftPDFController_v5(OppstandardController);
        Test.stopTest();

        // Assertions
        System.assertNotEquals(null, controller.policyDraft, 'Policy Draft should be initialized.');
        System.assertNotEquals(null, controller.relatedRecordData, 'Related record data should be fetched.');
        System.assert(controller.relatedRecordData.Company == 'Test Company', 'Company name should match the test Opp.');

        // Assertions
        System.assertNotEquals(null, Oppcontroller.policyDraft, 'Policy Draft should be initialized.');
        System.assertNotEquals(null, Oppcontroller.relatedRecordData, 'Related record data should be fetched.');
        System.assert(Oppcontroller.relatedRecordData.Company == 'Test Account', 'Company name should match the test Opp.');

        // Test coverages fetch
        List<Coverage__c> coverages = new List<Coverage__c>();
        for (Integer i = 0; i < 2; i++) {
            coverages.add(new Coverage__c(
                //Name = 'Coverage ' + i,
                Policy_Draft__c = LeadPolicyDraft.Id,
                Limit__c = 100000 + (i * 10000),
                Deductible__c = 500
            ));
        }
        insert coverages;

        // Test coverages fetch
        List<Coverage__c> oppcoverages = new List<Coverage__c>();
        for (Integer i = 0; i < 2; i++) {
            oppcoverages.add(new Coverage__c(
                //Name = 'Coverage ' + i,
                Policy_Draft__c = OppPolicyDraft.Id,
                Limit__c = 100000 + (i * 10000),
                Deductible__c = 500
            ));
        }
        insert oppcoverages;

        controller.fetchCoverages();
        System.assertEquals(2, controller.coverages.size(), 'Coverages should be fetched correctly.');

        Oppcontroller.fetchCoverages();
        System.assertEquals(2, Oppcontroller.coverages.size(), 'Coverages should be fetched correctly.');

        /*
        List<Coverage__c> Covs = controller.coverages;
        System.assertEquals(2, Covs.size(), 'Coverages should be fetched correctly.');
        */

        // Test policy vehicles
        Vehicle__c vehicle = new Vehicle__c(Name = 'Test Vehicle', Year__c = 2020);
        insert vehicle;

        Policy_Vehicle__c policyVehicle = new Policy_Vehicle__c(Policy_Draft__c = LeadPolicyDraft.Id, Vehicle__c = vehicle.Id, Status__c = 'Active');
        insert policyVehicle;

        Policy_Vehicle__c opppolicyVehicle = new Policy_Vehicle__c(Policy_Draft__c = OppPolicyDraft.Id, Vehicle__c = vehicle.Id, Status__c = 'Active');
        insert opppolicyVehicle;

        controller.fetchPolicyVehicles();
        System.assertEquals(1, controller.policyVehicles.size(), 'Policy vehicles should be fetched correctly.');

        Oppcontroller.fetchPolicyVehicles();
        System.assertEquals(1, Oppcontroller.policyVehicles.size(), 'Policy vehicles should be fetched correctly.');

        /*
        List<Policy_Vehicle__c> vehicles = controller.policyVehicles;
        System.assertEquals(1, vehicles.size(), 'Policy vehicles should be fetched correctly.');
        */
    }

}