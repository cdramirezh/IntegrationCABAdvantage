public class MGAInsuranceCompanyHelper {
    public static void populateMGAInsCoName(List<MGA_Quote_Insurance_Company__c> inscos) {
        // Collect the related Insurance_Company__c IDs to query
        Set<Id> companyIds = new Set<Id>();
        Set<Id> quoteIds = new Set<Id>(); // Collect related MGA_Quote__c IDs
        
        for (MGA_Quote_Insurance_Company__c insco : inscos) {
            if (insco.Insurance_Company__c != null) {
                companyIds.add(insco.Insurance_Company__c);
            }
            if (insco.MGA_Quote__c != null) {
                quoteIds.add(insco.MGA_Quote__c);
            }
        }

        // Query related Insurance_Company__c records
        Map<Id, Insurance_Company__c> companyMap = new Map<Id, Insurance_Company__c>(
            [SELECT Id, Name FROM Insurance_Company__c WHERE Id IN :companyIds]
        );

        // Query related MGA_Quote__c records
        Map<Id, MGA_Quote__c> quoteMap = new Map<Id, MGA_Quote__c>(
            [SELECT Id, Name FROM MGA_Quote__c WHERE Id IN :quoteIds]
        );

        // Update the Name field for each MGA_Quote_Insurance_Company__c
        for (MGA_Quote_Insurance_Company__c insco : inscos) {
            String companyName = quoteMap.get(insco.MGA_Quote__c)?.Name; // Retrieve Name from related MGA_Quote__c
            String companyRelatedName = companyMap.get(insco.Insurance_Company__c)?.Name;

            if (companyName != null && companyRelatedName != null) {
                insco.Name = companyName + ' - ' + companyRelatedName;
            } else if (companyName != null) {
                insco.Name = companyName;
            } else if (companyRelatedName != null) {
                insco.Name = companyRelatedName;
            }
        }
    }
}