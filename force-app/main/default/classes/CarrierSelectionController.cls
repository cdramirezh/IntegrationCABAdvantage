public with sharing class CarrierSelectionController {
    @AuraEnabled(cacheable=true)
    public static List<carrier__c> getCarriers(Id MGAQuoteId) {
        MGA_Quote__c quote = [SELECT MGA_Company__c FROM MGA_Quote__c WHERE Id = :MGAQuoteId LIMIT 1];

        return [SELECT Id, Insurance_Company__c, Insurance_Company__r.Name 
                FROM carrier__c 
                WHERE MGA_Company__c = :quote.MGA_Company__c];
    }

    @AuraEnabled(cacheable=true)
    public static List<Id> getExistingMGAQuoteInsuranceCompanies(Id MGAQuoteId) {
        List<Id> existingCompanyIds = new List<Id>();

        for (MGA_Quote_Insurance_Company__c record : [SELECT Insurance_Company__c FROM MGA_Quote_Insurance_Company__c WHERE MGA_Quote__c = :MGAQuoteId]) {
            existingCompanyIds.add(record.Insurance_Company__c);
        }
        
        return existingCompanyIds;
    }

    @AuraEnabled
    public static void createMGAQuoteInsuranceCompanies(Id MGAQuoteId, List<Id> insuranceCompanyIds) {
        List<MGA_Quote_Insurance_Company__c> recordsToInsert = new List<MGA_Quote_Insurance_Company__c>();

        for (Id insuranceCompanyId : insuranceCompanyIds) {
            recordsToInsert.add(new MGA_Quote_Insurance_Company__c(
                MGA_Quote__c = MGAQuoteId,
                Insurance_Company__c = insuranceCompanyId
            ));
        }
        
        if (!recordsToInsert.isEmpty()) {
            insert recordsToInsert;
        }
    }
}