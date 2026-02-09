public with sharing class FinanceRequestMGAQuotesInsController {
    @AuraEnabled(cacheable=true)
    public static List<MGA_Quote_Insurance_Company__c> getRelatedMGAQuoteInsuranceCompanies(Id financeRequestId) {
        // Obtener el Policy_Draft__c relacionado
        Finance_Request__c financeRequest = [
            SELECT Policy_Draft__c 
            FROM Finance_Request__c 
            WHERE Id = :financeRequestId
            LIMIT 1
        ];

        if (financeRequest.Policy_Draft__c == null) {
            return new List<MGA_Quote_Insurance_Company__c>();
        }

        // Obtener los MGA_Quote__c relacionados con Policy_Draft__c
        List<MGA_Quote__c> relatedQuotes = [
            SELECT Id 
            FROM MGA_Quote__c 
            WHERE Policy_Draft__c = :financeRequest.Policy_Draft__c
        ];

        if (relatedQuotes.isEmpty()) {
            return new List<MGA_Quote_Insurance_Company__c>();
        }

        // Obtener los MGA_Quote_Insurance_Company__c relacionados con los MGA_Quote__c
        return [
            SELECT Id, Name, Insurance_Company__c, Insurance_Company__r.Name, MGA_Quote__c
            FROM MGA_Quote_Insurance_Company__c
            WHERE MGA_Quote__c IN :relatedQuotes
        ];
    }

    @AuraEnabled(cacheable=true)
    public static List<Id> getExistingFinanceRequestInsuranceCompanies(Id financeRequestId) {
        List<Id> existingCompanyIds = new List<Id>();

        for (MGAs_Insurance_Co__c record : [
            SELECT MGA_Quote_Insurance_Company__c, MGA_Quote_Insurance_Company__r.Insurance_Company__c FROM MGAs_Insurance_Co__c 
            WHERE Finance_Request__c = :financeRequestId
        ]) {
            existingCompanyIds.add(record.MGA_Quote_Insurance_Company__c);
        }

        return existingCompanyIds;
    }

    @AuraEnabled
    public static void createFinanceRequestInsuranceCompanies(Id financeRequestId, List<Id> insuranceCompanyIds) {
        List<MGAs_Insurance_Co__c> recordsToInsert = new List<MGAs_Insurance_Co__c>();

        for (Id insuranceCompanyId : insuranceCompanyIds) {
            recordsToInsert.add(new MGAs_Insurance_Co__c(
                Finance_Request__c = financeRequestId,
                MGA_Quote_Insurance_Company__c = insuranceCompanyId
            ));
        }

        if (!recordsToInsert.isEmpty()) {
            insert recordsToInsert;
        }
    }
}