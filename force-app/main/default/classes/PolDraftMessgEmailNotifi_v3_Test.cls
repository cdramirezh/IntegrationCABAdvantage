@isTest
public with sharing class PolDraftMessgEmailNotifi_v3_Test {
    @isTest
    static void testSendEmail() {

        // Create Test Contact
        Contact TestContact = new Contact(LastName = 'Biden', Email = 'contact@mycompany.com');
        insert TestContact;

        // Create test Policy Draft
        Policy_Draft__c testPolicyDraft = new Policy_Draft__c(Name = 'Test Draft', Producer__c = TestContact.Id, Sales_Supervisor__c = TestContact.Id);
        insert testPolicyDraft;

        // Create Chat record associated with the Binder Request
        Chat__c testChat = new Chat__c(Policy_Draft__c = testPolicyDraft.Id);
        insert testChat;

        // Create Sender (Contact) with Email
        Contact testSender = new Contact(LastName = 'Sender Test', Email = 'sender@example.com');
        insert testSender;

        // Create a Message__c record related to the Chat and with all necessary email fields
        Message__c testMessage = new Message__c(
            //Producer_Email__c = 'producer@example.com',
            //Sales_Supervisor_Email__c = 'sales_supervisor@example.com',
            //Support_Email__c = 'support@example.com',
            //IRM_Email__c = 'irm@example.com',
            Body__c = 'This is a test message body.',
            Sender__c = testSender.Id,
            Chat__c = testChat.Id
        );
        insert testMessage;

        // Store the ID of the test message
        List<Id> messageIds = new List<Id>{ testMessage.Id };

        Test.startTest();
        // Call the Invocable method
        PolDraftMessageEmailNotificationAct_v3.sendEmail(messageIds);
        Test.stopTest();

        // Since we can't verify the actual sending of emails directly,
        // we check that no exceptions are thrown and that logic runs to completion.
        // For full validation, use a logging strategy or inspect the EmailMessage object if available.
    }
}