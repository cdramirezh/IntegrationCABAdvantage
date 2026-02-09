@isTest
private class BinderRequestAceptanceQControllerTest_v2 {


@IsTest
    private static void testRelatedRecordDataWrapper() {

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

        //create test binder request
        Binder_Request__c leadBinderRequest = new Binder_Request__c(
            Name = 'Test Binder Request',
            //Policy__c = policy.Id,
            Policy_Draft__c = LeadPolicyDraft.Id
        );
        insert leadBinderRequest;

        //create test binder request
        Binder_Request__c oppBinderRequest = new Binder_Request__c(
            Name = 'Test Binder Request',
            //Policy__c = policy.Id,
            Policy_Draft__c = OppPolicyDraft.Id
        );
        insert oppBinderRequest;

        //create test Policy_c
        Policy__c leadPolicy = new Policy__c(
            Name = 'Test Lead Policy',
            Binder_Request__c = leadBinderRequest.Id
        );
        insert leadPolicy;

        //create test Policy_c
        Policy__c oppPolicy = new Policy__c(
            Name = 'Test Opp Policy',
            Binder_Request__c = oppBinderRequest.Id
        );
        insert oppPolicy;

        //Create test coverage_product
        Coverage_Product__c coverageProduct1 = new Coverage_Product__c(
            Name = 'Automobile Liability',
            Abbreviation__c = 'AL'
        );
        insert coverageProduct1;

        //create test coverage
        Coverage__c coverage = new Coverage__c(
            //Name = 'Test Coverage',
            Policy_Draft__c = LeadPolicyDraft.Id,
            Coverage_Product__c = coverageProduct1.Id
        );
        insert coverage;

        //create test coverage
        AR_Coverage__c arcoverage = new AR_Coverage__c(
            //Name = 'Test Coverage',
            Binder_Request__c = leadBinderRequest.Id,
            Coverage_Product__c = coverageProduct1.Id
        );
        insert arcoverage;

        // Create standard controller for the test
        ApexPages.StandardController LeadstandardController = new ApexPages.StandardController(leadBinderRequest);

        // Create standard controller for the test
        ApexPages.StandardController oppstandardController = new ApexPages.StandardController(oppBinderRequest);

         // Instantiate the controller
         Test.startTest();
         BinderRequestAceptanceQController_v2 controller = new BinderRequestAceptanceQController_v2(LeadstandardController);
         //Policy__c leadFetchedPolicy = controller.fetchPolicyDates(leadBinderRequest.Id);
         //Policy__c oppFetchedPolicy = controller.fetchPolicyDates(oppBinderRequest.Id);
         //List<AR_Coverage__c> fetchedCoverages = controller.getCoverages();
         //List<Coverage__c> fetchedCoverages = controller.pdcoverages;
         List<AR_Coverage__c> fetchedCoverages = controller.pdcoverages;
         //String fetchedCoveragesAbbreviations = controller.getCoverageAbbreviations();
         String fetchedCoveragesAbbreviations = controller.coverageAbbreviationsString;
         Test.stopTest();

         
         //System.assertEquals(leadPolicy.Id, leadFetchedPolicy.Id);
         //System.assertEquals(oppPolicy.Id, oppFetchedPolicy.Id);
         System.assertEquals(arcoverage.Id, fetchedCoverages[0].Id);
         System.assertEquals('AL', fetchedCoveragesAbbreviations);
    }

    /*
@IsTest
    private static void testFetchPolicyDates() {

        // Create test data
        Policy__c policy = new Policy__c(
            Name = 'Test Policy',
            Binder_Request__c = null
        );
        insert policy;

        // Test fetch policy dates
        BinderRequestAceptanceQController_v2 controller = new BinderRequestAceptanceQController_v2(LeadstandardController);
        Policy__c fetchedPolicy = controller.fetchPolicyDates(policy.Id);
        System.assertEquals(policy.Id, fetchedPolicy.Id);

        // Test fetch policy dates with null binder request
        policy.Binder_Request__c = null;
        update policy;
        fetchedPolicy = controller.fetchPolicyDates(policy.Id);
        System.assertEquals(policy.Id, fetchedPolicy.Id);
        
    }
        */
}