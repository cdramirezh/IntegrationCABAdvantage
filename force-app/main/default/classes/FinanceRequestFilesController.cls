public with sharing class FinanceRequestFilesController {
    
    public class FileWrapper {
        @AuraEnabled public Id id;
        @AuraEnabled public String name;
        
        public FileWrapper(Id id, String name) {
            this.id = id;
            this.name = name;
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<FileWrapper> getRelatedFiles(Id financeRequestId) {
        List<FileWrapper> fileList = new List<FileWrapper>();        

        List<MGAs_Insurance_Co__c> relatedMGAInsuranceCompanies = [
            SELECT MGA_Quote_Insurance_Company__c 
            FROM MGAs_Insurance_Co__c 
            WHERE Finance_Request__c = :financeRequestId
        ];

        Set<Id> relatedMGAQuoteInsuranceCompanyIds = new Set<Id>();
        for (MGAs_Insurance_Co__c record : relatedMGAInsuranceCompanies) {
            if (record.MGA_Quote_Insurance_Company__c != null) {
                relatedMGAQuoteInsuranceCompanyIds.add(record.MGA_Quote_Insurance_Company__c);
            }
        }

        if (!relatedMGAQuoteInsuranceCompanyIds.isEmpty()) {
            List<ContentDocumentLink> contentLinks = [
                SELECT ContentDocumentId 
                FROM ContentDocumentLink 
                WHERE LinkedEntityId IN :relatedMGAQuoteInsuranceCompanyIds
            ];

            Set<Id> contentDocumentIds = new Set<Id>();
            for (ContentDocumentLink link : contentLinks) {
                contentDocumentIds.add(link.ContentDocumentId);
            }

            if (!contentDocumentIds.isEmpty()) {
                for (ContentDocument doc : [
                    SELECT Id, Title, FileExtension
                    FROM ContentDocument
                    WHERE Id IN :contentDocumentIds
                ]) {
                    fileList.add(new FileWrapper(doc.Id, doc.Title + '.' + doc.FileExtension));
                }
            }
        }
        return fileList;
    }

    @AuraEnabled
    public static String downloadSelectedFiles(List<Id> selectedDocumentIds, Id financeRequestId) {
        if (selectedDocumentIds.isEmpty()) {
            throw new AuraHandledException('No files selected for download.');
        }

        //Fetch Finance_request_c name
        Finance_Request__c fr = [SELECT Name FROM Finance_Request__c WHERE Id = :financeRequestId LIMIT 1];
        String financeRequestName = fr.Name;

        Compression.ZipWriter writer = new Compression.ZipWriter();

        for (ContentVersion cv : [
            SELECT PathOnClient, VersionData
            FROM ContentVersion
            WHERE ContentDocumentId IN :selectedDocumentIds
        ]) {
            writer.addEntry(cv.PathOnClient, cv.VersionData);
        }

        Blob zipBlob = writer.getArchive();

        ContentVersion zipFile = new ContentVersion(
            Title = financeRequestName + '_Selected_Files.zip',
            PathOnClient = financeRequestName + '_Selected_Files.zip',
            VersionData = zipBlob
        );
        insert zipFile;

        Id zipContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :zipFile.Id].ContentDocumentId;
        return zipContentDocumentId;
    }
}