@IsTest
public class MGAInsuranceCompanyHelper_Test {

    @TestSetup
    static void setupTestData() {
        // Create test Insurance Companies
        List<Insurance_Company__c> insuranceCompanies = new List<Insurance_Company__c>();
        for (Integer i = 1; i <= 2; i++) {
            insuranceCompanies.add(new Insurance_Company__c(Name = 'Insurance Company ' + i));
        }
        insert insuranceCompanies;

        //Create tes MGA Company
        MGA_Company__c mgaCompany = new MGA_Company__c(Name = 'Test MGA Company');
        insert mgaCompany;

        // Create test MGA Quotes
        List<MGA_Quote__c> quotes = new List<MGA_Quote__c>();
        for (Integer i = 1; i <= 2; i++) {
            quotes.add(new MGA_Quote__c(Name = 'Quote ' + i, MGA_Company__c = mgaCompany.Id));
        }
        insert quotes;

        // Create test MGA_Quote_Insurance_Company__c records
        List<MGA_Quote_Insurance_Company__c> inscoRecords = new List<MGA_Quote_Insurance_Company__c>();
        inscoRecords.add(new MGA_Quote_Insurance_Company__c(
            MGA_Quote__c = quotes[0].Id,
            Insurance_Company__c = insuranceCompanies[0].Id
        ));
        inscoRecords.add(new MGA_Quote_Insurance_Company__c(
            MGA_Quote__c = quotes[1].Id,
            Insurance_Company__c = insuranceCompanies[1].Id
        ));
        insert inscoRecords;
    }

    @IsTest
    static void testPopulateMGAInsCoName() {
        // Query the test MGA_Quote_Insurance_Company__c records
        List<MGA_Quote_Insurance_Company__c> inscoRecords = [
            SELECT Id, Name, MGA_Quote__c, Insurance_Company__c
            FROM MGA_Quote_Insurance_Company__c
        ];

        // Call the helper method
        MGAInsuranceCompanyHelper.populateMGAInsCoName(inscoRecords);

        // Assert that the Name field is correctly updated
        for (MGA_Quote_Insurance_Company__c insco : inscoRecords) {
            if (insco.MGA_Quote__c != null && insco.Insurance_Company__c != null) {
                MGA_Quote__c relatedQuote = [SELECT Name FROM MGA_Quote__c WHERE Id = :insco.MGA_Quote__c];
                Insurance_Company__c relatedCompany = [SELECT Name FROM Insurance_Company__c WHERE Id = :insco.Insurance_Company__c];
                System.assertEquals(
                    relatedQuote.Name + ' - ' + relatedCompany.Name,
                    insco.Name,
                    'Name should include both MGA Quote Name and Insurance Company Name'
                );
            } else if (insco.MGA_Quote__c != null) {
                MGA_Quote__c relatedQuote = [SELECT Name FROM MGA_Quote__c WHERE Id = :insco.MGA_Quote__c];
                System.assertEquals(
                    relatedQuote.Name,
                    insco.Name,
                    'Name should include only MGA Quote Name'
                );
            } else if (insco.Insurance_Company__c != null) {
                Insurance_Company__c relatedCompany = [SELECT Name FROM Insurance_Company__c WHERE Id = :insco.Insurance_Company__c];
                System.assertEquals(
                    relatedCompany.Name,
                    insco.Name,
                    'Name should include only Insurance Company Name'
                );
            }
        }
    }
}