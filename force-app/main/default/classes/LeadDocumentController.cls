public with sharing class LeadDocumentController {
    @AuraEnabled(cacheable=true)
    public static List<Documents_package__c> getLeadDocuments(Id leadId) {
        return [
            SELECT Id, Type__c,
                (SELECT Id, Type__c, Name FROM Documents__r)
            FROM Documents_package__c
            WHERE Lead__c = :leadId
        ];
    }
}