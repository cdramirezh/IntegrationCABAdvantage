public class OppPolicyDraftQuotationController {
    @AuraEnabled(cacheable=true)
    public static List<PolicyWrapper> getPoliciesWithQuotesAndCompanies(Id OppId) {
        List<PolicyWrapper> result = new List<PolicyWrapper>();

        List<Policy_Draft__c> policyDrafts = [
            SELECT Id, Name, Status__c, CreatedDate
            FROM Policy_Draft__c
            WHERE Opportunity__c = :OppId
            //AND Status__c NOT IN ('Lost')
            ORDER BY CreatedDate DESC
        ];
                   

        Set<Id> policyDraftIds = new Set<Id>();
        for (Policy_Draft__c policy : policyDrafts) {
            policyDraftIds.add(policy.Id);
        }

        Map<Id, List<MGA_Quote__c>> policyToQuotesMap = new Map<Id, List<MGA_Quote__c>>();
        List<MGA_Quote__c> quotes = [
            SELECT Id, Name, Status__c, Indication__c, Policy_Draft__c, MGA_Company__c, MGA_Company__r.Name, CreatedDate
            FROM MGA_Quote__c
            WHERE Policy_Draft__c IN :policyDraftIds
            ORDER BY CreatedDate DESC
        ];

        Map<Id, List<Coverage__c>> policyToCoveragesMap = new Map<Id, List<Coverage__c>>();        
        List<Coverage__c> coverages = [
            SELECT Id, Name
            FROM Coverage__c
            WHERE Policy_Draft__c IN :policyDraftIds
        ];

        for (MGA_Quote__c quote : quotes) {
            if (!policyToQuotesMap.containsKey(quote.Policy_Draft__c)) {
                policyToQuotesMap.put(quote.Policy_Draft__c, new List<MGA_Quote__c>());
            }
            policyToQuotesMap.get(quote.Policy_Draft__c).add(quote);
        }

        Set<Id> quoteIds = new Set<Id>();
        for (MGA_Quote__c quote : quotes) {
            quoteIds.add(quote.Id);
        }

        Map<Id, List<MGA_Quote_Insurance_Company__c>> quoteToInsuranceCompaniesMap = new Map<Id, List<MGA_Quote_Insurance_Company__c>>();
        List<MGA_Quote_Insurance_Company__c> insuranceCompanies = [
            SELECT Id, Insurance_Company__r.Name, Premium__c, Top_Pick__c, Status__c, MGA_Quote__c, Status_Class__c
            FROM MGA_Quote_Insurance_Company__c
            WHERE MGA_Quote__c IN :quoteIds
        ];

        for (MGA_Quote_Insurance_Company__c insuranceCompany : insuranceCompanies) {
            if (!quoteToInsuranceCompaniesMap.containsKey(insuranceCompany.MGA_Quote__c)) {
                quoteToInsuranceCompaniesMap.put(insuranceCompany.MGA_Quote__c, new List<MGA_Quote_Insurance_Company__c>());
            }
            quoteToInsuranceCompaniesMap.get(insuranceCompany.MGA_Quote__c).add(insuranceCompany);
        }

        for (Policy_Draft__c policy : policyDrafts) {
            PolicyWrapper wrapper = new PolicyWrapper();
            wrapper.policy = policy;

            List<QuoteWithCompanies> quoteWithCompaniesList = new List<QuoteWithCompanies>();
            if (policyToQuotesMap.containsKey(policy.Id)) {
                for (MGA_Quote__c quote : policyToQuotesMap.get(policy.Id)) {
                    List<MGA_Quote_Insurance_Company__c> relatedInsuranceCompanies = quoteToInsuranceCompaniesMap.get(quote.Id);
                    if (relatedInsuranceCompanies == null) {
                        relatedInsuranceCompanies = new List<MGA_Quote_Insurance_Company__c>();
                    }
                    quoteWithCompaniesList.add(new QuoteWithCompanies(quote, relatedInsuranceCompanies));
                }
            }

            wrapper.quotesWithCompanies = quoteWithCompaniesList;
            result.add(wrapper);
        }

        return result;
    }

    public class PolicyWrapper {
        @AuraEnabled public Policy_Draft__c policy { get; set; }
        @AuraEnabled public List<QuoteWithCompanies> quotesWithCompanies { get; set; }

        public PolicyWrapper() {
            quotesWithCompanies = new List<QuoteWithCompanies>();
        }
    }

    public class QuoteWithCompanies {
        @AuraEnabled public MGA_Quote__c quote { get; set; }
        @AuraEnabled public List<MGA_Quote_Insurance_Company__c> insuranceCompanies { get; set; }

        public QuoteWithCompanies(MGA_Quote__c quote, List<MGA_Quote_Insurance_Company__c> insuranceCompanies) {
            this.quote = quote;
            this.insuranceCompanies = insuranceCompanies != null ? insuranceCompanies : new List<MGA_Quote_Insurance_Company__c>();
        }
    }
}