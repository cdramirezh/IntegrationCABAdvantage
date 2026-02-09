@IsTest
public class MGAQuoteNameHelper_Test {

    @TestSetup
    static void setupTestData() {
        // Create test MGA_Company__c records
        List<MGA_Company__c> companies = new List<MGA_Company__c>();
        for (Integer i = 1; i <= 2; i++) {
            companies.add(new MGA_Company__c(Name = 'MGA Company ' + i));
        }
        insert companies;

        // Create test MGA_Quote__c records with and without related MGA_Company__c
        List<MGA_Quote__c> quotes = new List<MGA_Quote__c>();
        quotes.add(new MGA_Quote__c(MGA_Company__c = companies[0].Id));
        quotes.add(new MGA_Quote__c(MGA_Company__c = companies[1].Id));
        quotes.add(new MGA_Quote__c(MGA_Company__c = companies[1].Id));
        quotes.add(new MGA_Quote__c(MGA_Company__c = companies[0].Id));
        quotes.add(new MGA_Quote__c(MGA_Company__c = companies[1].Id));
        insert quotes;
    }

    @IsTest
static void testPopulateMGAQuoteName() {
    // Query the test MGA_Quote__c records
    List<MGA_Quote__c> quotes = [
        SELECT Id, Name, Company_Name__c, MGA_Company__c
        FROM MGA_Quote__c
    ];

    // Call the helper method
    MGAQuoteNameHelper.populateMGAQuoteName(quotes);

    // Assert that the Name field is correctly updated
    for (MGA_Quote__c quote : quotes) {
        if (quote.Company_Name__c != null && quote.MGA_Company__c != null) {
            MGA_Company__c relatedCompany = [SELECT Name FROM MGA_Company__c WHERE Id = :quote.MGA_Company__c];
            System.assertEquals(
                quote.Company_Name__c + ' - ' + relatedCompany.Name,
                quote.Name,
                'Name should include both Company Name and MGA Company Name'
            );
        } else if (quote.Company_Name__c != null) {
            System.assertEquals(
                quote.Company_Name__c,
                quote.Name,
                'Name should include only Company Name'
            );
        } else if (quote.MGA_Company__c != null) {
            MGA_Company__c relatedCompany = [SELECT Name FROM MGA_Company__c WHERE Id = :quote.MGA_Company__c];
            System.assertEquals(
                relatedCompany.Name,
                quote.Name,
                'Name should include only MGA Company Name'
            );
        } else {
            System.assertEquals(
                null,
                quote.Name,
                'Name should be null if both Company Name and MGA Company Name are null'
            );
        }
    }
}

}