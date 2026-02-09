@isTest
public with sharing class EndorsementStatusChangeNotificationTest {
    @isTest
    static void testSendEmail() {

        // Create Test Contact 
        Contact TestContact = new Contact(LastName = 'Biden', Email = 'contact@mycompany.com');
        insert TestContact;        

        //Create Test Account
        Account TestAccount = new Account(Name = 'Test Account', Owner_DOB__c = Date.today());
        insert TestAccount;

        //create Test opporrtunity
        Opportunity TestOpportunity = new Opportunity(Name = 'Test Opportunity', StageName = 'Prospecting', CloseDate = Date.today(), AccountId = TestAccount.Id, Producer__c = TestContact.Id);
        insert TestOpportunity;

        //Create Sales Team Test Endorsement Request
        Endorsement_Request__c TestEndorsementRequest1 = new Endorsement_Request__c(Status__c = 'Open', Process_Owner_p__c = 'Sales Team', Opportunity__c = TestOpportunity.Id);
        insert TestEndorsementRequest1;

        //Create Loyalty Team Test Endorsement Request
        Endorsement_Request__c TestEndorsementRequest2 = new Endorsement_Request__c(Status__c = 'Open', Process_Owner_p__c = 'Loyalty Team', Opportunity__c = TestOpportunity.Id);
        insert TestEndorsementRequest2;
       
        //Create Endorsements Team Test Endorsement Request
        Endorsement_Request__c TestEndorsementRequest3 = new Endorsement_Request__c(Status__c = 'Open', Process_Owner_p__c = 'Endorsements Team', Opportunity__c = TestOpportunity.Id);
        insert TestEndorsementRequest3;

        // Store the ID of the test Endorsement Request
        List<Id> endorsementRequestId1 = new List<Id>{ TestEndorsementRequest1.Id };
        List<Id> endorsementRequestId2 = new List<Id>{TestEndorsementRequest2.Id};
        List<Id> endorsementRequestId3 = new List<Id>{TestEndorsementRequest3.Id};

        Test.startTest();
        // Call the Invocable method
        EndorsementStatusChangeNotification.sendEmail(endorsementRequestId1);
        EndorsementStatusChangeNotification.sendEmail(endorsementRequestId2);
        EndorsementStatusChangeNotification.sendEmail(endorsementRequestId3);
        Test.stopTest();

        // Since we can't verify the actual sending of emails directly,
        // we check that no exceptions are thrown and that logic runs to completion.
        // For full validation, use a logging strategy or inspect the EmailMessage object if available.
    }
}