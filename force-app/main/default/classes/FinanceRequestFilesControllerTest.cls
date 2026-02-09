@isTest
private class FinanceRequestFilesControllerTest {
    private static Id contentDocumentId;
    private static Id testFinanceRequestId;

    @testSetup
    static void setupTestData() {
        Policy_Draft__c testPolicyDraft = new Policy_Draft__c();
        insert testPolicyDraft;
        
        Finance_Request__c testFinanceRequest = new Finance_Request__c(Policy_Draft__c = testPolicyDraft.Id);
        insert testFinanceRequest;
        testFinanceRequestId = testFinanceRequest.Id;

        Insurance_Company__c testInsuranceCompany = new Insurance_Company__c(Name = 'Test Insurance Company');
        insert testInsuranceCompany;
        
        MGA_Quote_Insurance_Company__c testMGAQuoteInsCompany = new MGA_Quote_Insurance_Company__c( Insurance_Company__c = testInsuranceCompany.Id);
        insert testMGAQuoteInsCompany;
        
        MGAs_Insurance_Co__c testMGAsInsuranceCo = new MGAs_Insurance_Co__c(
            Finance_Request__c = testFinanceRequest.Id, 
            MGA_Quote_Insurance_Company__c = testMGAQuoteInsCompany.Id
        );
        insert testMGAsInsuranceCo;
        
        ContentVersion testContentVersion = new ContentVersion(
            Title = 'Test File',
            PathOnClient = 'TestFile.pdf',
            VersionData = Blob.valueOf('Test Data'),
            IsMajorVersion = true
        );
        insert testContentVersion;
        
        contentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :testContentVersion.Id].ContentDocumentId;
        
        ContentDocumentLink testContentDocumentLink = new ContentDocumentLink(
            LinkedEntityId = testMGAQuoteInsCompany.Id,
            ContentDocumentId = contentDocumentId,
            ShareType = 'V'
        );
        insert testContentDocumentLink;
    }
    
    @isTest
    static void testGetRelatedFiles() {

        testFinanceRequestId = [SELECT Id FROM Finance_Request__c LIMIT 1].Id;

        Test.startTest();
        List<FinanceRequestFilesController.FileWrapper> files = FinanceRequestFilesController.getRelatedFiles(testFinanceRequestId);
        Test.stopTest();
        
        System.assertEquals(1, files.size(), 'Expected one related file.');
        System.assertEquals('Test File.pdf', files[0].name);
    }
    
    @isTest
    static void testDownloadSelectedFiles() {

        //contentDocumentId = [SELECT ContentDocumentId FROM ContentVersion LIMIT 1].ContentDocumentId;
        //Id testFileId = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE ContentDocumentId = :contentDocumentId LIMIT 1].ContentDocumentId;

        MGA_Quote_Insurance_Company__c testMGAQuoteInsCompany = [SELECT Id FROM MGA_Quote_Insurance_Company__c LIMIT 1];
        Id testFileId = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :testMGAQuoteInsCompany.Id LIMIT 1].ContentDocumentId;

        testFinanceRequestId = [SELECT Id FROM Finance_Request__c LIMIT 1].Id;
        
        Test.startTest();
        String zipFileId = FinanceRequestFilesController.downloadSelectedFiles(new List<Id>{testFileId}, testFinanceRequestId);
        Test.stopTest();
        
        System.assertNotEquals(null, zipFileId, 'Expected a valid ZIP file ID.');
    }
    
    /*
    @isTest
    static void testDownloadSelectedFiles_NoFiles() {

        testFinanceRequestId = [SELECT Id FROM Finance_Request__c LIMIT 1].Id;

        try {
            Test.startTest();
            FinanceRequestFilesController.downloadSelectedFiles(new List<Id>(), testFinanceRequestId);
            Test.stopTest();
            System.assert(false, 'Expected an exception to be thrown.');
        } catch (AuraHandledException e) {
            System.assertEquals('No files selected for download.', e.getMessage());
        }
    }
        */
}