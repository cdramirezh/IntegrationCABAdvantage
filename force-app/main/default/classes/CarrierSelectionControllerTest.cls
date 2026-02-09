@isTest
private class CarrierSelectionControllerTest {

    
    @TestSetup
    static void makeData() {
        

        //create test Insurace_Company__c records
        List<Insurance_Company__c> companies = new List<Insurance_Company__c>{
            new Insurance_Company__c(Name = 'Test Company 1'),
            new Insurance_Company__c(Name = 'Test Company 2')
        };
        insert companies;

        //Create test MGA_Company__c record
        MGA_Company__c company = new MGA_Company__c(Name = 'Test MGA Company');
        insert company;

        //create a test MGA_Quote__c record
        MGA_Quote__c quote = new MGA_Quote__c(Name = 'Test Quote', MGA_Company__c = company.Id);
        insert quote;

        //create a test carrier__c record
        carrier__c carrier = new carrier__c(Insurance_Company__c = companies[0].Id, MGA_Company__c = company.Id);
        insert carrier;

        //create a test MGA_Quote_Insurance_Company__c record
        MGA_Quote_Insurance_Company__c quoteCompany = new MGA_Quote_Insurance_Company__c(MGA_Quote__c = quote.Id, Insurance_Company__c = companies[0].Id);
        insert quoteCompany;
    }


@IsTest
    static void shouldGetCarriers() {
        MGA_Quote__c quote = [SELECT Id FROM MGA_Quote__c LIMIT 1];
        List<carrier__c> result = CarrierSelectionController.getCarriers(quote.Id);
        System.assert(!result.isEmpty());
    }

@IsTest
    static void shouldGetExistingCompanies() {
        MGA_Quote__c quote = [SELECT Id FROM MGA_Quote__c LIMIT 1];
        List<Id> result = CarrierSelectionController.getExistingMGAQuoteInsuranceCompanies(quote.Id);
        System.assert(!result.isEmpty());
    }

@IsTest
    static void shouldCreateMGAQuoteInsuranceCompanies() {
        MGA_Quote__c quote = [SELECT Id FROM MGA_Quote__c LIMIT 1];
        List<Id> insuranceCompanyIds = new List<Id>();
        List<Insurance_Company__c> companies = [SELECT Id FROM Insurance_Company__c];
        for (Insurance_Company__c company : companies) {
            insuranceCompanyIds.add(company.Id);
        }
        CarrierSelectionController.createMGAQuoteInsuranceCompanies(quote.Id, insuranceCompanyIds);
        //List<MGA_Quote_Insurance_Company__c> quoteCompanies = [SELECT Id FROM MGA_Quote_Insurance_Company__c];
        //System.assert(quoteCompanies.size() == companies.size());
    }
}