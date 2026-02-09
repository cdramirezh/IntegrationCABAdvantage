@isTest
public class EndorsementReqCommodityControllerTest {

    public Account testAccount;
    public Opportunity testOpportunity;
    public Endorsement_Request__c testEndorsementRequest;
    public List<Commodity__c> testCommodities;
    public List<Endorsement_Commodity__c> testEndorsementCommodities;
    public List<Endorsement_Commodity__c> testExistingEndorsementCommodities;
    public List<Endorsement_Commodity__c> testNewEndorsementCommodities;
    public List<Endorsement_Commodity__c> testDeletedEndorsementCommodities;
    public List<Endorsement_Commodity__c> testAllEndorsementCommodities;

    @testSetup
    static void setupData() {
        // Create Account
        Account acc = new Account(Name = 'Test Account', Owner_DOB__c = Date.today());
        insert acc;

        // Create Opportunity
        Opportunity opp = new Opportunity(
            Name = 'Test Opp',
            AccountId = acc.Id,
            CloseDate = Date.today().addDays(30),
            StageName = 'Prospecting'
        );
        insert opp;

        // Create Endorsement_Request__c and link to Opportunity
        Endorsement_Request__c endorsementRequest = new Endorsement_Request__c(
            //Name = 'Test ER',
            Opportunity__c = opp.Id
        );
        insert endorsementRequest;

        // Create some Commodity__c records linked to the account
        List<Commodity__c> commodities = new List<Commodity__c>();
        for (Integer i = 0; i < 3; i++) {
            commodities.add(new Commodity__c(
                Name = 'Commodity ' + i,
                Account__c = acc.Id
            ));
        }
        insert commodities;

        // Create one existing Endorsement_Commodity__c record to test duplication check
        Endorsement_Commodity__c existingEC = new Endorsement_Commodity__c(
            Endorsement_Request__c = endorsementRequest.Id,
            Commodity__c = commodities[0].Id,
            Action__c = 'Delete'
        );
        insert existingEC;
    }

    @isTest
    static void testGetCommoditiesByEndorsementRequest() {
        // Get the Endorsement_Request__c
        Endorsement_Request__c er = [SELECT Id FROM Endorsement_Request__c LIMIT 1];

        Test.startTest();
        List<Map<String, String>> result = EndorsementRequestCommodityController.getCommoditiesByEndorsementRequest(er.Id);
        Test.stopTest();

        System.assertNotEquals(0, result.size(), 'Should return at least one commodity');
        System.assertEquals(true, result[0].containsKey('Id'));
        System.assertEquals(true, result[0].containsKey('Name'));
    }

    @isTest
    static void testCreateCommodityEndorsements() {
        // Get endorsement request and all commodity records
        Endorsement_Request__c er = [SELECT Id FROM Endorsement_Request__c LIMIT 1];
        List<Commodity__c> allCommodities = [SELECT Id FROM Commodity__c];

        // Select only those not already inserted
        List<Id> toCreate = new List<Id>();
        for (Commodity__c com : allCommodities) {
            if ([SELECT COUNT() FROM Endorsement_Commodity__c WHERE Commodity__c = :com.Id] == 0) {
                toCreate.add(com.Id);
            }
        }

        Test.startTest();
        String response = EndorsementRequestCommodityController.createCommodityEndorsements(
            er.Id, toCreate, 'Modify'
        );
        Test.stopTest();

        System.assertEquals('Endorsement commodities created successfully.', response);

        // Verify records were created
        List<Endorsement_Commodity__c> inserted = [
            SELECT Id FROM Endorsement_Commodity__c
            WHERE Endorsement_Request__c = :er.Id AND Commodity__c IN :toCreate
        ];
        System.assertEquals(toCreate.size(), inserted.size(), 'All selected commodities should be inserted');
    }

    @isTest
    static void testCreateCommodityEndorsements_EmptySelection() {
        Endorsement_Request__c er = [SELECT Id FROM Endorsement_Request__c LIMIT 1];

        Test.startTest();
        String result = EndorsementRequestCommodityController.createCommodityEndorsements(er.Id, new List<Id>(), 'Delete');
        Test.stopTest();

        System.assertEquals('No commodities selected.', result);
    }

    @isTest
    static void testCreateCommodityEndorsements_AllDuplicates() {
        // Use the commodity already linked in test setup
        Endorsement_Request__c er = [SELECT Id FROM Endorsement_Request__c LIMIT 1];
        Endorsement_Commodity__c existing = [SELECT Commodity__c FROM Endorsement_Commodity__c LIMIT 1];

        Test.startTest();
        String result = EndorsementRequestCommodityController.createCommodityEndorsements(
            er.Id, new List<Id>{existing.Commodity__c}, 'Delete'
        );
        Test.stopTest();

        System.assertEquals('All selected commodities already exist.', result);
    }
}