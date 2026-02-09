@isTest
public with sharing class PolicyDraftStatusChangesNotificationTest {
    @isTest
    static void testSendEmail() {

        // Create Test Contact 
        Contact TestContact = new Contact(LastName = 'Biden', Email = 'contact@mycompany.com');
        insert TestContact;

        // Create Test Contact Sales Supervisor
        Contact TestContactSalesSupervisor = new Contact(LastName = 'Sales Supervisor', Email = 'salessupervisor@company.com');
        insert TestContactSalesSupervisor;

        // Create Test Contact Support Agent
        Contact TestContactSupportAgent = new Contact(LastName = 'Support Agent', Email = 'support@company.com');
        insert TestContactSupportAgent;

        // Create Test Contact IRM Agent
        Contact TestContactIRMAgent = new Contact(LastName = 'IRM Agent', Email = 'irm@company.com');
        insert TestContactIRMAgent;

        //Create Test Agency__c
        Agency__c TestAgency = new Agency__c(Name = 'Test Agency', Sales_Supervisor__c = TestContactSalesSupervisor.Id , IRM_Agent__c = TestContactIRMAgent.Id, Support_Agent__c = TestContactSupportAgent.Id, Additional_Email_for_Notifications_1__c = 'addemail@company.com');
        insert TestAgency;

        //Create Test Lead  
        Lead TestLead = new Lead(FirstName = 'Joe', LastName = 'Biden', Company = 'Vantage', Email = 'testlead@company.com', AgencyLookup__c = TestAgency.Id, Owner_DOB__c = Date.today());
        insert TestLead;        

        // Create test Policy Draft
        Policy_Draft__c testPolicyDraft = new Policy_Draft__c(Name = 'Test Draft', Producer__c = TestContact.Id, Lead__c = TestLead.Id);
        insert testPolicyDraft;

        // Store the ID of the test Policy Draft
        List<Id> policyDraftIds = new List<Id>{ testPolicyDraft.Id };
       

        Test.startTest();
        // Call the Invocable method
        PolicyDraftWorkingNotification.sendEmail(policyDraftIds);
        PolicyDraftBacktoOpenNotification.sendEmail(policyDraftIds);
        PolicyDrafSubmittedNotification.sendEmail(policyDraftIds);
        PolicyDraftReadyToBindNotification.sendEmail(policyDraftIds);
        PolicyDrafPlatformsNotification.sendEmail(policyDraftIds);
        Test.stopTest();

        // Since we can't verify the actual sending of emails directly,
        // we check that no exceptions are thrown and that logic runs to completion.
        // For full validation, use a logging strategy or inspect the EmailMessage object if available.
    }
}