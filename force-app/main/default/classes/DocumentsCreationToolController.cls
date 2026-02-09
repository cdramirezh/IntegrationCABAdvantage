public with sharing class DocumentsCreationToolController {
    
    @AuraEnabled(cacheable=true)
    public static List<Documents_Package__c> getDocumentsPackages(Id leadId) {
        return [
            SELECT Id, Type__c
            FROM Documents_Package__c
            WHERE Lead__c = :leadId
        ];
    }

    @AuraEnabled(cacheable=true)
    public static List<String> getDocumentTypePicklistValues() {
        // Use a Schema utility to fetch picklist values dynamically
        List<String> picklistValues = new List<String>();
        Schema.DescribeFieldResult fieldResult = Document__c.Type__c.getDescribe();
        List<Schema.PicklistEntry> picklistEntries = fieldResult.getPicklistValues();
        
        for (Schema.PicklistEntry entry : picklistEntries) {
            picklistValues.add(entry.getLabel());
        }
        return picklistValues;
    }

    @AuraEnabled
    public static Id createDocument(String docName, Id packageId, String type) {
        Document__c newDoc = new Document__c();
        newDoc.Name = docName;
        newDoc.Documents_Package__c = packageId;
        newDoc.Type__c = type; // Set the Type__c field
        insert newDoc;
        return newDoc.Id;
    }
}