@isTest
private class FinanceRequestMGAQuotesInsControllerTest {

    static Policy_Draft__c testPolicyDraft {get; set;}
    static Finance_Request__c testFinanceRequest {get; set;}
    static MGA_Quote__c testMGAQuote {get; set;}
    static Insurance_Company__c testInsuranceCompany {get; set;}
    static MGA_Quote_Insurance_Company__c testMGAQuoteInsuranceCompany {get; set;}


    @testSetup
    static void setupTestData() {
        
        //Create a Test policy draft
        testPolicyDraft = new Policy_Draft__c();
        insert testPolicyDraft;

        //Create a Test finance request
        testFinanceRequest = new Finance_Request__c(Policy_Draft__c = testPolicyDraft.Id);
        insert testFinanceRequest;

        //Create a Test MGA_Company
        MGA_Company__c testMGACompany = new MGA_Company__c(Name = 'Test MGA Company');
        insert testMGACompany;

        //Create a Test MGA Quote
        MGA_Quote__c testMGAQuote = new MGA_Quote__c(Policy_Draft__c = testPolicyDraft.Id, MGA_Company__c = testMGACompany.Id);
        insert testMGAQuote;

        //Create a Test Insurance Company
        testInsuranceCompany = new Insurance_Company__c(Name = 'Test Insurance Company');
        insert testInsuranceCompany;      

        //Create a Test MGA Quote Insurance Company
        testMGAQuoteInsuranceCompany = new MGA_Quote_Insurance_Company__c(MGA_Quote__c = testMGAQuote.Id, Insurance_Company__c = testInsuranceCompany.Id);
        insert testMGAQuoteInsuranceCompany;

        //Create a Test Existing MGAs_Insurance_Co__c
        MGAs_Insurance_Co__c testMGAsInsuranceCo = new MGAs_Insurance_Co__c(Finance_Request__c = testFinanceRequest.Id, MGA_Quote_Insurance_Company__c = testMGAQuoteInsuranceCompany.Id);
        insert testMGAsInsuranceCo;

    }


@IsTest
    static void shouldGetExistingFinanceRequestInsuranceCompanies() {
        // Retrieve the test finance request created in @testSetup
        Finance_Request__c testFinanceRequest = [SELECT Id FROM Finance_Request__c LIMIT 1];
    
        List<Id> result = FinanceRequestMGAQuotesInsController.getExistingFinanceRequestInsuranceCompanies(testFinanceRequest.Id);
        System.assertEquals(1, result.size());
        
        //Retrieve the related MGA_Quote_Insurance_Company__c from test data
        MGAs_Insurance_Co__c relatedMGAsInsuranceCo = [SELECT MGA_Quote_Insurance_Company__c FROM MGAs_Insurance_Co__c LIMIT 1];
        System.assertEquals(relatedMGAsInsuranceCo.MGA_Quote_Insurance_Company__c, result[0]);
        
    }
    

@IsTest
    static void shouldCreateFinanceRequestInsuranceCompanies() {
        List<Id> insuranceCompanyIds = new List<Id>();

        // Retrieve the test MGA_Quote_Insurance_Company__c company created in @testSetup
        MGA_Quote_Insurance_Company__c testMGAQuoteInsuranceCompany = [SELECT Id FROM MGA_Quote_Insurance_Company__c LIMIT 1];
        insuranceCompanyIds.add(testMGAQuoteInsuranceCompany.Id);

        // Retrieve the test finance request created in @testSetup
        Finance_Request__c testFinanceRequest = [SELECT Id FROM Finance_Request__c LIMIT 1];

        Test.startTest();
        FinanceRequestMGAQuotesInsController.createFinanceRequestInsuranceCompanies(testFinanceRequest.Id, insuranceCompanyIds);
        Test.stopTest();

        List<MGAs_Insurance_Co__c> records = [SELECT Id, Finance_Request__c, MGA_Quote_Insurance_Company__c FROM MGAs_Insurance_Co__c];
        System.assertEquals(2, records.size());
        System.assertEquals(testFinanceRequest.Id, records[1].Finance_Request__c);

        //Retrieve the test testMGAQuoteInsuranceCompany from test data
        MGA_Quote_Insurance_Company__c relatedMGAQuoteInsuranceCo = [SELECT Id FROM MGA_Quote_Insurance_Company__c LIMIT 1];

        System.assertEquals(relatedMGAQuoteInsuranceCo.Id, records[1].MGA_Quote_Insurance_Company__c);
    }

@IsTest
    static void shouldgetRelatedMGAQuoteInsuranceCompanies() {
        // Retrieve the test finance request created in @testSetup
        Finance_Request__c testFinanceRequest = [SELECT Id FROM Finance_Request__c LIMIT 1];

        List<MGA_Quote_Insurance_Company__c> result = FinanceRequestMGAQuotesInsController.getRelatedMGAQuoteInsuranceCompanies(testFinanceRequest.Id);
        System.assertEquals(1, result.size());
        
        //Retrieve the related MGA_Quote_Insurance_Company__c from test data
        MGAs_Insurance_Co__c relatedMGAsInsuranceCo = [SELECT MGA_Quote_Insurance_Company__c FROM MGAs_Insurance_Co__c LIMIT 1];
        System.assertEquals(relatedMGAsInsuranceCo.MGA_Quote_Insurance_Company__c, result[0].Id);
    }



}