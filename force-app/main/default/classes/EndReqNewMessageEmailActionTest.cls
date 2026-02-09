@isTest
public with sharing class EndReqNewMessageEmailActionTest {
    @isTest
    static void testSendEmail() {

        // Create Test Contact with Email
        Contact testContact = new Contact(LastName = 'Biden', Email = 'contact@mycompany.com');
        insert testContact;
        
        //Create Test Account
        Account testAccount = new Account(Name = 'Test Account', Owner_DOB__c = Date.today());
        insert testAccount;

        //Create Test Opportunity
        Opportunity testOpportunity = new Opportunity(Name = 'Test Opportunity', AccountId = testAccount.Id, CloseDate = Date.today(), StageName = 'Prospecting', 
                                                    Producer__c = testContact.Id);
        insert testOpportunity;        

        // Create test Endorsement Request
        Endorsement_Request__c testEnd = new Endorsement_Request__c(Opportunity__c = testOpportunity.Id, Process_Owner_p__c = 'Sales Team');
        insert testEnd;

        // Create Chat record associated with the Endorsement Request
        Chat__c testChat = new Chat__c(Endorsement_Request__c = testEnd.Id);
        insert testChat;

        // Create Sender (Contact) with Email
        Contact testSender = new Contact(LastName = 'Sender Test', Email = 'sender@example.com');
        insert testSender;

        // Create a Message__c record related to the Chat and with all necessary email fields
        Message__c testMessage = new Message__c(
            Body__c = 'This is a test message body.',
            Sender__c = testSender.Id,
            Chat__c = testChat.Id
        );
        insert testMessage;

        // Re-query the testMessage to ensure related fields are populated
        testMessage = [SELECT Id, Chat__r.Endorsement_Request__r.Opportunity__r.Producer__r.Email
                       FROM Message__c WHERE Id = :testMessage.Id LIMIT 1];
        
        // Assert that the Producer email is not null
        System.assertNotEquals(null, testMessage.Chat__r.Endorsement_Request__r.Opportunity__r.Producer__r.Email, 'Email should not be null');

        // Store the ID of the test message
        List<Id> messageIds = new List<Id>{ testMessage.Id };

        Test.startTest();
        // Call the Invocable method
        EndReqNewMessageEmailNotificationAction.sendEmail(messageIds);
        Test.stopTest();

        // Since we can't verify the actual sending of emails directly,
        // we check that no exceptions are thrown and that logic runs to completion.
        // For full validation, use a logging strategy or inspect the EmailMessage object if available.
    }
}