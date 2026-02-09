public with sharing class BinderRequestController {

    @AuraEnabled(cacheable=true)
    public static List<Map<String, String>> getAvailableInsuranceCompanies(Id binderRequestId) {
        Binder_Request__c binderRequest = [SELECT Policy_Draft__c FROM Binder_Request__c WHERE Id = :binderRequestId];

        List<Mga_Quote_Insurance_Company__c> insuranceCompanies = [
            SELECT Id, Bind_Name__c
            FROM Mga_Quote_Insurance_Company__c
            WHERE MGA_Quote__c IN (
                SELECT Id
                FROM MGA_Quote__c
                WHERE Policy_Draft__c = :binderRequest.Policy_Draft__c
            )
            AND Binder_Request__c = NULL
        ];

        List<Map<String, String>> options = new List<Map<String, String>>();
        for (Mga_Quote_Insurance_Company__c company : insuranceCompanies) {
            Map<String, String> option = new Map<String, String>();
            option.put('label', company.Bind_Name__c);
            option.put('value', company.Id);
            options.add(option);
        }

        return options;
    }


    @AuraEnabled
    public static void saveSelectedCompanies(Id binderRequestId, List<Id> selectedInsuranceCompanyIds) {
        if (binderRequestId == null || selectedInsuranceCompanyIds == null) {
            throw new AuraHandledException('Binder Request ID and selected insurance companies are required.');
        }

        // Update the selected records to relate them to the Binder_Request__c
        List<Mga_Quote_Insurance_Company__c> selectedCompanies = [
            SELECT Id, Binder_Request__c
            FROM Mga_Quote_Insurance_Company__c
            WHERE Id IN :selectedInsuranceCompanyIds
        ];

        for (Mga_Quote_Insurance_Company__c company : selectedCompanies) {
            company.Binder_Request__c = binderRequestId;
        }

        update selectedCompanies;
    }
}