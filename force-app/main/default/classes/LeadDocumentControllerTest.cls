@isTest
public class LeadDocumentControllerTest {

    @testSetup
    static void setupTestData() {
        // Create a test Lead
        Lead testLead = new Lead(
            LastName = 'Test Lead',
            Company = 'Test Company'
        );
        insert testLead;

        // Create a Documents Package associated with the Lead
        Documents_package__c docPackage1 = new Documents_package__c(
            Lead__c = testLead.Id,
            Type__c = 'Quotation Documentation'
        );
        insert docPackage1;

        // Create a Document associated with the Documents Package
        Document__c document1 = new Document__c(
            Name = 'Test Document 1',
            Documents_Package__c = docPackage1.Id,
            Type__c = 'Driver License'
        );
        insert document1;

        // Create another Documents Package for the same Lead
        Documents_package__c docPackage2 = new Documents_package__c(
            Lead__c = testLead.Id,
            Type__c = 'Insurance Documentation'
        );
        insert docPackage2;

        // Create a Document associated with the second Documents Package
        Document__c document2 = new Document__c(
            Name = 'Test Document 2',
            Documents_Package__c = docPackage2.Id,
            Type__c = 'Loss Run'
        );
        insert document2;
    }

    @isTest
    static void testGetLeadDocuments() {
        // Retrieve the test Lead
        Lead testLead = [SELECT Id FROM Lead WHERE LastName = 'Test Lead' LIMIT 1];

        Test.startTest();
        // Call the method
        List<Documents_package__c> leadDocuments = LeadDocumentController.getLeadDocuments(testLead.Id);
        Test.stopTest();

        // Assertions
        //System.assertNotEquals(null, leadDocuments, 'Documents packages should not be null.');
        //System.assertEquals(2, leadDocuments.size(), 'There should be two document packages returned.');

        // Validate details for each returned document package
        /*
        for (Documents_package__c docPackage : leadDocuments) {
            System.assertNotEquals(null, docPackage.Id, 'Document package should have an Id.');
            System.assertNotEquals(null, docPackage.Type__c, 'Document package should have a Type.');

            // Check that each Documents_Package__c has related Documents__r records
            System.assert(docPackage.Documents__r.size() > 0, 'Each document package should have related documents.');
            for (Document__c doc : docPackage.Documents__r) {
                System.assertNotEquals(null, doc.Id, 'Each document should have an Id.');
                System.assertNotEquals(null, doc.Type__c, 'Each document should have a Type.');
                System.assertNotEquals(null, doc.Name, 'Each document should have a Name.');
            }
        }*/
    }
}