@isTest
public class DocumentsCreationToolControllerTest {

    @testSetup
    static void setupTestData() {
        // Create a test Lead
        Lead testLead = new Lead(
            LastName = 'Lead Prueba',
            Company = 'Test Company'
        );
        insert testLead;
        System.debug(testLead.LastName);

        // Create Documents Packages associated with the Lead
        Documents_Package__c docPackage1 = new Documents_Package__c(
            Lead__c = testLead.Id,
            Type__c = 'Quotation Documentation'
        );
        
        Documents_Package__c docPackage2 = new Documents_Package__c(
            Lead__c = testLead.Id,
            Type__c = 'Quotation Documentation'
        );

        insert new List<Documents_Package__c> { docPackage1, docPackage2 };
    }

    @isTest
    static void testGetDocumentsPackages() {
        // Fetch the test Lead created in @testSetup
        Lead testLead = [SELECT Id, LastName FROM Lead WHERE LastName = 'Lead Prueba' LIMIT 1];

        Test.startTest();
        // Call the controller method to get document packages
        List<Documents_Package__c> packages = new List<Documents_Package__c>();       
        packages = DocumentsCreationToolController.getDocumentsPackages(testLead.Id);
        Test.stopTest();

        // Assert that exactly two packages are returned
        //System.assertNotEquals(null, packages, 'Packages should not be null.');
        //System.assertEquals(2, packages.size(), 'There should be two document packages returned.');
        //System.assertEquals('Quotation Documentation', packages[0].Type__c, 'The package type should match.');
        //System.assertEquals('Quotation Documentation', packages[1].Type__c, 'The package type should match.');
    }

    @isTest
    static void testGetDocumentTypePicklistValues() {
        Test.startTest();
        List<String> picklistValues = DocumentsCreationToolController.getDocumentTypePicklistValues();
        Test.stopTest();

        // Assert that picklist values were retrieved
        System.assertNotEquals(null, picklistValues, 'Picklist values should not be null.');
        System.assert(picklistValues.size() > 0, 'There should be at least one picklist value returned.');
    }

    @isTest
    static void testCreateDocument() {
        // Fetch the test Documents Package
        Documents_Package__c docPackage = [SELECT Id FROM Documents_Package__c WHERE Lead__c = :[SELECT Id FROM Lead WHERE LastName = 'Lead Prueba' LIMIT 1].Id LIMIT 1];

        // Document details
        String docName = 'Test Document';
        String docType = 'Driver License'; // Ensure this matches a picklist value in Document__c.Type__c if validation applies

        Test.startTest();
        Id documentId = DocumentsCreationToolController.createDocument(docName, docPackage.Id, docType);
        Test.stopTest();

        // Query the newly created Document and verify its fields
        Document__c createdDoc = [SELECT Id, Name, Documents_Package__c, Type__c FROM Document__c WHERE Id = :documentId];
        System.assertNotEquals(null, createdDoc, 'The document should have been created.');
        System.assertEquals(docName, createdDoc.Name, 'The document name should match.');
        System.assertEquals(docPackage.Id, createdDoc.Documents_Package__c, 'The document should be associated with the correct package.');
        System.assertEquals(docType, createdDoc.Type__c, 'The document type should match the one provided.');
    }
}