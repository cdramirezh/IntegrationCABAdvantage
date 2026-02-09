public with sharing class DocumentPackageFileVFController {
    public String documentPackageId { get; set; }
    public List<FileWrapper> files { get; set; }
    
    public List<SelectOption> categories { get; set; }
    
    // Wrapper class to hold ContentVersion and editable fields
    public class FileWrapper {
        public Id id { get; set; }
        public String title { get; set; }
        public String category { get; set; }
        
        public FileWrapper(Id id, String title, String category) {
            this.id = id;
            this.title = title;
            this.category = category;
        }
    }

    // Constructor accepting the standard controller
    public DocumentPackageFileVFController(ApexPages.StandardController controller) {
        documentPackageId = controller.getId();
        files = new List<FileWrapper>();
        categories = getCategoryPicklistOptions();
        fetchFiles();
    }

    public void fetchFiles() {
        if (String.isBlank(documentPackageId)) {
            return;
        }
        
        List<ContentDocumentLink> contentDocumentLinks = [
            SELECT ContentDocumentId
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :documentPackageId
        ];

        List<Id> contentDocumentIds = new List<Id>();
        for (ContentDocumentLink link : contentDocumentLinks) {
            contentDocumentIds.add(link.ContentDocumentId);
        }

        if (!contentDocumentIds.isEmpty()) {
            List<ContentVersion> contentVersions = [
                SELECT Id, Title, category__c
                FROM ContentVersion
                WHERE ContentDocumentId IN :contentDocumentIds
            ];

            for (ContentVersion cv : contentVersions) {
                files.add(new FileWrapper(cv.Id, cv.Title, cv.category__c));
            }
        }
    }

    public List<SelectOption> getCategoryPicklistOptions() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Loss Run', 'Loss Run'));
        options.add(new SelectOption('MVR', 'MVR'));
        options.add(new SelectOption('IFTA', 'IFTA'));
        options.add(new SelectOption('Driver License', 'Driver License'));
        options.add(new SelectOption('Police Report', 'Police Report'));
        options.add(new SelectOption('Quote', 'Quote'));
        options.add(new SelectOption('Other', 'Other'));
        return options;
    }

    public PageReference saveFiles() {
        if (files.isEmpty()) {
            return null;
        }

        List<ContentVersion> updatedFiles = new List<ContentVersion>();
        for (FileWrapper wrapper : files) {
            updatedFiles.add(new ContentVersion(
                Id = wrapper.id,
                category__c = wrapper.category
            ));
        }

        if (!updatedFiles.isEmpty()) {
            update updatedFiles;
        }

        return null;
    }
}