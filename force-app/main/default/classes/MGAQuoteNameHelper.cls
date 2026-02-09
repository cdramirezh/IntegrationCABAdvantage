public class MGAQuoteNameHelper {
    public static void populateMGAQuoteName(List<MGA_Quote__c> quotes) {
        // Collect the related MGA_Company__c IDs to query
        Set<Id> companyIds = new Set<Id>();
        for (MGA_Quote__c quote : quotes) {
            if (quote.MGA_Company__c != null) {
                companyIds.add(quote.MGA_Company__c);
            }
        }

        // Query related MGA_Company__c records
        Map<Id, MGA_Company__c> companyMap = new Map<Id, MGA_Company__c>(
            [SELECT Id, Name FROM MGA_Company__c WHERE Id IN :companyIds]
        );

        // Update the Name field for each MGA_Quote__c
        for (MGA_Quote__c quote : quotes) {
            String companyName = quote.Company_Name__c; // Formula field
            String companyRelatedName = companyMap.get(quote.MGA_Company__c)?.Name;

            if (companyName != null && companyRelatedName != null) {
                quote.Name = companyName + ' - ' + companyRelatedName;
            } else if (companyName != null) {
                quote.Name = companyName;
            } else if (companyRelatedName != null) {
                quote.Name = companyRelatedName;
            }
        }
    }
}