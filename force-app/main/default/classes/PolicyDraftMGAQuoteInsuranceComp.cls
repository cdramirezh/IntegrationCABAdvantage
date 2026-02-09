public with sharing class PolicyDraftMGAQuoteInsuranceComp {

    @AuraEnabled(cacheable=true)
    public static List<QuoteWithInsuranceWrapper> getMGAQuotesWithInsurance(Id policyDraftId) {
        List<MGA_Quote__c> quotes = [
            SELECT Id, Name, MGA_Company__r.Name, Status__c,
                   (SELECT Id, Name, Status__c, Insurance_Company__r.Name FROM MGA_Quote_Insurance_Companies__r ORDER BY CreatedDate DESC)
            FROM MGA_Quote__c
            WHERE Policy_Draft__c = :policyDraftId
        ];

        List<QuoteWithInsuranceWrapper> result = new List<QuoteWithInsuranceWrapper>();
        for (MGA_Quote__c quote : quotes) {
            QuoteWithInsuranceWrapper wrapper = new QuoteWithInsuranceWrapper();
            wrapper.quote = quote;
            
            // Check if there are any Insurance_Company__c records related to the MGA_Quote__c
            if (!quote.MGA_Quote_Insurance_Companies__r.isEmpty()) {
                wrapper.insuranceCompanies = new List<MGA_Quote_Insurance_Company__c>();
                for (MGA_Quote_Insurance_Company__c insuranceCompany : quote.MGA_Quote_Insurance_Companies__r) {
                    wrapper.insuranceCompanies.add(insuranceCompany);
                }
            } else {
                wrapper.insuranceCompanies = null; // No insurance companies found
            }
            
            result.add(wrapper);
        }
        return result;
    }

    public class QuoteWithInsuranceWrapper {
        @AuraEnabled public MGA_Quote__c quote { get; set; }
        @AuraEnabled public List<MGA_Quote_Insurance_Company__c> insuranceCompanies { get; set; }
    }

}