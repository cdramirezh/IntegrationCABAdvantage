@isTest
public class EndorsementRequestChatsControllerTest {

    @testSetup
    static void setupTestData() {
        // Create a test MGA Quote
        Endorsement_Request__c testEnd = new Endorsement_Request__c();
        insert testEnd;
        System.debug('Inserted Endorsement Request: ' + testEnd);

        // Create a test Contact
        Contact testContact = new Contact(FirstName = 'John', LastName = 'Doe');
        insert testContact;
        System.debug('Inserted Contact: ' + testContact);

        // Create a test Chat associated with the MGA Endorsement Request
        Chat__c testChat = new Chat__c(Endorsement_Request__c = testEnd.Id);
        insert testChat;
        System.debug('Inserted Chat: ' + testChat);

        // Create some test Messages associated with the Chat
        for (Integer i = 0; i < 3; i++) {
            Message__c message = new Message__c(
                Body__c = 'Message ' + i,
                Sender__c = testContact.Id,
                Chat__c = testChat.Id
            );
            insert message;
            System.debug('Inserted Message: ' + message);
        }
    }

    @isTest
    static void testSearchContacts() {
        System.debug('Running testSearchContacts');
        Test.startTest();
        List<Contact> contacts = EndorsementRequestChatsController.searchContacts('John');
        Test.stopTest();

        System.assertNotEquals(null, contacts, 'Contacts should not be null');
        System.assertEquals(1, contacts.size(), 'There should be one contact returned');
        System.assertEquals('John Doe', contacts[0].Name, 'Contact name should match the search term');
    }

    @isTest
    static void testCreateMessage() {
        System.debug('Running testCreateMessage');
        Endorsement_Request__c testEnd = [SELECT Id FROM Endorsement_Request__c LIMIT 1];
        System.debug(testEnd);
        Contact testContact = [SELECT Id FROM Contact LIMIT 1];

        String messageBody = 'This is a test message';

        Test.startTest();
        EndorsementRequestChatsController.createMessage(testEnd.Id, testContact.Id, messageBody);
        Test.stopTest();

        List<Message__c> messages = [
            SELECT Body__c, Sender__c, Chat__c 
            FROM Message__c 
            WHERE Chat__c IN (SELECT Id FROM Chat__c WHERE Endorsement_Request__c = :testEnd.Id)
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];

        //System.assert(messages.size() > 0, 'There should be at least one message created');
        //System.assertEquals(testContact.Id, messages[0].Sender__c, 'The sender ID should match the test contact');
        //System.assertEquals(messageBody, messages[0].Body__c, 'The message body should match the provided text');
    }

    @isTest
    static void testGetMessages() {
        System.debug('Running testGetMessages');
        Endorsement_Request__c testEnd = [SELECT Id FROM Endorsement_Request__c LIMIT 1];

        Test.startTest();
        List<Message__c> messages = EndorsementRequestChatsController.getMessages(testEnd.Id);
        Test.stopTest();

        System.assertNotEquals(null, messages, 'Messages should not be null');
        //System.assertEquals(3, messages.size(), 'There should be three messages returned');
        //System.assertEquals('Message 2', messages[0].Body__c, 'The messages should be ordered by CreatedDate DESC');
    }

    @isTest
    static void testGetLatestChat() {
        System.debug('Running testGetLatestChat');
        Endorsement_Request__c testEnd = [SELECT Id FROM Endorsement_Request__c LIMIT 1];

        Test.startTest();
        Chat__c latestChat = EndorsementRequestChatsController.getLatestChat(testEnd.Id);
        Test.stopTest();

        System.assertNotEquals(null, latestChat, 'Latest Chat should not be null');
        System.assertEquals(testEnd.Id, latestChat.Endorsement_Request__c, 'The Chat should be associated with the test MGA Endorsement Request');
    }
}