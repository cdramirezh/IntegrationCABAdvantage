@IsTest
public class PolicyDraftChatController_v2_Test {

    @TestSetup
    static void setup() {
        // Create test Policy Draft record
        Policy_Draft__c policyDraft = new Policy_Draft__c(Name = 'Test Policy Draft');
        insert policyDraft;

        // Create a test Chat record related to the Policy Draft
        Chat__c chat = new Chat__c(Policy_Draft__c = policyDraft.Id);
        insert chat;

        // Create test Contacts
        List<Contact> contacts = new List<Contact>();
        for (Integer i = 0; i < 5; i++) {
            contacts.add(new Contact(LastName = 'Contact ' + i));
        }
        insert contacts;

        //Create  test MGA Company
        MGA_Company__c mgaCompany = new MGA_Company__c(Name = 'Test MGA Company');
        insert mgaCompany;

        // Create test Insurance Company
        Insurance_Company__c insco = new Insurance_Company__c(Name = 'Test Insurance Company');
        insert insco;

        // Create test MGA Quote and Insurance Company
        //MGA_Quote__c mgaQuote = new MGA_Quote__c(Name = 'Test MGA Quote', MGA_Company__c = mgaCompany.Id);
        MGA_Quote__c mgaQuote = new MGA_Quote__c(MGA_Company__c = mgaCompany.Id);
        insert mgaQuote;

        //MGA_Quote_Insurance_Company__c insuranceCompany = new MGA_Quote_Insurance_Company__c(Name = 'Test Insurance Company', Insurance_Company__c = insco.Id);
        MGA_Quote_Insurance_Company__c insuranceCompany = new MGA_Quote_Insurance_Company__c(Insurance_Company__c = insco.Id);
        insert insuranceCompany;

        // Create a test Message record
        Message__c message = new Message__c(
            Body__c = 'Test Message Body',
            Sender__c = contacts[0].Id,
            Chat__c = chat.Id,
            Related_MGA_Quote__c = mgaQuote.Id,
            Related_Insurance_Co__c = insuranceCompany.Id
        );
        insert message;
    }

    @IsTest
    static void testSearchContacts() {
        // Test the searchContacts method
        Test.startTest();
        List<Contact> results = PolicyDraftChatController_v2.searchContacts('Contact');
        Test.stopTest();

        // Assert the results
        System.assertNotEquals(0, results.size(), 'Contacts should be returned');
        System.assert(results[0].Name.contains('Contact'), 'Contact name should match search term');
    }

    @IsTest
static void testCreateMessage() {
    // Get test data
    Policy_Draft__c policyDraft = [SELECT Id FROM Policy_Draft__c LIMIT 1];
    Contact contact = [SELECT Id FROM Contact LIMIT 1];

    // Test the createMessage method
    Test.startTest();
    PolicyDraftChatController_v2.createMessage(policyDraft.Id, contact.Id, 'Test Message from Test Class');
    Test.stopTest();

    // Assert the Message was created
    List<Message__c> messages = [
        SELECT Id, Body__c, Sender__c, Chat__c
        FROM Message__c
        WHERE Chat__c IN (SELECT Id FROM Chat__c WHERE Policy_Draft__c = :policyDraft.Id)
        ORDER BY CreatedDate DESC
    ];

    System.assertEquals(2, messages.size(), 'One message should be created');
    System.assertEquals('Test Message from Test Class', messages[1].Body__c, 'Message body should match');
    System.assertEquals(contact.Id, messages[0].Sender__c, 'Sender should match the contact');
}


    @IsTest
    static void testGetMessages() {
        // Get test data
        Policy_Draft__c policyDraft = [SELECT Id FROM Policy_Draft__c LIMIT 1];

        // Test the getMessages method
        Test.startTest();
        List<Message__c> messages = PolicyDraftChatController_v2.getMessages(policyDraft.Id);
        Test.stopTest();

        // Assert the Messages were retrieved
        System.assertNotEquals(0, messages.size(), 'Messages should be returned');
        System.assertEquals('Test Message Body', messages[0].Body__c, 'Message body should match');
    }

    @IsTest
    static void testGetLatestChat() {
        // Get test data
        Policy_Draft__c policyDraft = [SELECT Id FROM Policy_Draft__c LIMIT 1];

        // Test the getLatestChat method
        Test.startTest();
        Chat__c latestChat = PolicyDraftChatController_v2.getLatestChat(policyDraft.Id);
        Test.stopTest();

        // Assert the latest Chat was retrieved
        System.assertNotEquals(null, latestChat, 'Latest chat should be returned');
        System.assertEquals(policyDraft.Id, latestChat.Policy_Draft__c, 'Chat should be related to the Policy Draft');
    }
}