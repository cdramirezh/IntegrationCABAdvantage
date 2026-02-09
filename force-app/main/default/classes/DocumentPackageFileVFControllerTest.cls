@isTest
public class DocumentPackageFileVFControllerTest {

    // Test method to test the DocumentPackageFileVFController constructor and methods
    @isTest
    public static void testController() {
        // Step 1: Create test data
        Documents_Package__c testDocPackage = new Documents_Package__c();
        insert testDocPackage;

        // Step 2: Create a ContentVersion (which automatically creates a ContentDocument)
        ContentVersion contentVersion1 = new ContentVersion(
            Title = 'File1',
            PathOnClient = 'file1.txt',
            VersionData = Blob.valueOf('This is a test file'),
            category__c = 'Loss Run'
        );
        insert contentVersion1;

        // Step 3: Retrieve the ContentDocumentId after inserting the ContentVersion
        ContentVersion contentVer = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion1.Id LIMIT 1];

        ContentDocument contentDoc = [SELECT Id FROM ContentDocument WHERE Id = :contentVer.ContentDocumentId LIMIT 1];

        // Step 4: Link the ContentDocument to the Documents_Package__c
        ContentDocumentLink docLink1 = new ContentDocumentLink(
            ContentDocumentId = contentDoc.Id, // Use the ContentDocumentId here
            LinkedEntityId = testDocPackage.Id,
            ShareType = 'V'
        );
        insert docLink1;

        // Step 5: Simulate the controller
        ApexPages.StandardController sc = new ApexPages.StandardController(testDocPackage);
        DocumentPackageFileVFController controller = new DocumentPackageFileVFController(sc);

        // Step 6: Assert that files were fetched correctly
        System.assertNotEquals(controller.files, null, 'Files list should not be null');
        System.assertEquals(controller.files.size(), 1, 'Should retrieve one file');
        System.assertEquals(controller.files[0].title, 'File1', 'File title should be "File1"');
        System.assertEquals(controller.files[0].category, 'Loss Run', 'File category should be "Loss Run"');

        // Step 7: Test saveFiles method
        controller.files[0].category = 'MVR';
        Test.startTest();
        controller.saveFiles();
        Test.stopTest();

        // Step 8: Verify that the category was updated in the ContentVersion object
        ContentVersion updatedContentVersion = [SELECT category__c FROM ContentVersion WHERE Id = :contentVersion1.Id];
        System.assertEquals(updatedContentVersion.category__c, 'MVR', 'Category should be updated to "MVR"');
    }
}