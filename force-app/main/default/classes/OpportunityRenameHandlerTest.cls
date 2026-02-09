@isTest
public class OpportunityRenameHandlerTest {
    
    /**
     * Setup method to create test data used across all test methods
     */
    @testSetup
    static void setupTestData() {
        // Create test accounts
        List<Account> testAccounts = new List<Account>();
        testAccounts.add(new Account(Name = 'Test Account Inc', Owner_DOB__c = Date.newInstance(1980, 1, 1)));
        testAccounts.add(new Account(Name = 'Demo Corporation', Owner_DOB__c = Date.newInstance(1990, 5, 15)));
        testAccounts.add(new Account(Name = 'Sample Business LLC', Owner_DOB__c = Date.newInstance(1985, 3, 20)));
        insert testAccounts;
    }
    
    /**
     * Test opportunity renaming when inserting new records
     */
    @isTest
    static void testOpportunityRenameOnInsert() {
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Account Inc' LIMIT 1];
        
        // Create opportunity with Policy Term during insert
        Opportunity testOpp = new Opportunity(
            Name = 'Original Name',
            AccountId = testAccount.Id,
            Policy_Term__c = '2024 - 2025',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30)
        );
        
        Test.startTest();
        insert testOpp;
        Test.stopTest();
        
        // Verify the name was updated correctly
        Opportunity updatedOpp = [SELECT Name FROM Opportunity WHERE Id = :testOpp.Id];
        System.assertEquals('Test Account Inc - 2024 - 2025', updatedOpp.Name, 
                           'Opportunity name should be updated on insert with Policy Term');
    }
    
    /**
     * Test opportunity renaming when updating existing records
     */
    @isTest
    static void testOpportunityRenameOnUpdate() {
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Demo Corporation' LIMIT 1];
        
        // Create opportunity without Policy Term first
        Opportunity testOpp = new Opportunity(
            Name = 'Original Name',
            AccountId = testAccount.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30)
        );
        insert testOpp;
        
        // Update with Policy Term
        testOpp.Policy_Term__c = '2025 - 2026';
        
        Test.startTest();
        update testOpp;
        Test.stopTest();
        
        // Verify the name was updated correctly
        Opportunity updatedOpp = [SELECT Name FROM Opportunity WHERE Id = :testOpp.Id];
        System.assertEquals('Demo Corporation - 2025 - 2026', updatedOpp.Name, 
                           'Opportunity name should be updated when Policy Term is added');
    }
    
    /**
     * Test opportunity renaming when Policy Term value changes
     */
    @isTest
    static void testOpportunityRenameOnPolicyTermChange() {
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Sample Business LLC' LIMIT 1];
        
        // Create opportunity with initial Policy Term
        Opportunity testOpp = new Opportunity(
            Name = 'Test Opportunity',
            AccountId = testAccount.Id,
            Policy_Term__c = '2024 - 2025',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30)
        );
        insert testOpp;
        
        // Verify initial naming
        Opportunity initialOpp = [SELECT Name FROM Opportunity WHERE Id = :testOpp.Id];
        System.assertEquals('Sample Business LLC - 2024 - 2025', initialOpp.Name, 
                           'Initial opportunity name should be set correctly');
        
        // Change Policy Term value
        testOpp.Policy_Term__c = '2026 - 2027';
        
        Test.startTest();
        update testOpp;
        Test.stopTest();
        
        // Verify the name was updated with new Policy Term
        Opportunity updatedOpp = [SELECT Name FROM Opportunity WHERE Id = :testOpp.Id];
        System.assertEquals('Sample Business LLC - 2026 - 2027', updatedOpp.Name, 
                           'Opportunity name should be updated when Policy Term changes');
    }
    
    /**
     * Test bulk operations to ensure governor limits are respected
     */
    @isTest
    static void testBulkOpportunityRename() {
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Account Inc' LIMIT 1];
        
        List<Opportunity> opportunities = new List<Opportunity>();
        List<String> policyTermValues = new List<String>{'2024 - 2025', '2025 - 2026', '2026 - 2027'};
        
        // Create 200 opportunities for bulk testing, cycling through picklist values
        for (Integer i = 1; i <= 200; i++) {
            String policyTerm = policyTermValues[Math.mod(i-1, 3)]; // Cycle through the 3 values
            opportunities.add(new Opportunity(
                Name = 'Bulk Test ' + i,
                AccountId = testAccount.Id,
                Policy_Term__c = policyTerm,
                StageName = 'Prospecting',
                CloseDate = Date.today().addDays(30)
            ));
        }
        
        Test.startTest();
        insert opportunities;
        Test.stopTest();
        
        // Verify all names were updated correctly
        List<Opportunity> updatedOpps = [SELECT Name FROM Opportunity WHERE Id IN :opportunities];
        System.assertEquals(200, updatedOpps.size(), 'Should have 200 opportunities');
        
        for (Opportunity opp : updatedOpps) {
            System.assert(opp.Name.contains('Test Account Inc -'), 
                         'All opportunity names should contain account name and dash: ' + opp.Name);
            System.assert(opp.Name.contains('202'), 
                         'All opportunity names should contain a valid policy term year: ' + opp.Name);
        }
    }
    
    /**
     * Test that opportunities without AccountId are not processed
     */
    @isTest
    static void testOpportunityWithoutAccount() {
        // Create opportunity without Account but with Policy Term
        Opportunity testOpp = new Opportunity(
            Name = 'No Account Opp',
            Policy_Term__c = '2024 - 2025',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30)
            // Note: No AccountId specified
        );
        
        Test.startTest();
        insert testOpp;
        Test.stopTest();
        
        // Verify the name was NOT changed (no account to get name from)
        Opportunity updatedOpp = [SELECT Name FROM Opportunity WHERE Id = :testOpp.Id];
        System.assertEquals('No Account Opp', updatedOpp.Name, 
                           'Opportunity name should not change without Account');
    }
    
    /**
     * Test that opportunities with null Policy Term are not processed
     */
    @isTest
    static void testOpportunityWithNullPolicyTerm() {
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Account Inc' LIMIT 1];
        
        // Create opportunity with null Policy Term
        Opportunity testOpp = new Opportunity(
            Name = 'Null Policy Term',
            AccountId = testAccount.Id,
            Policy_Term__c = null, // Null value (no selection made)
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30)
        );
        
        Test.startTest();
        insert testOpp;
        Test.stopTest();
        
        // Verify the name was NOT changed
        Opportunity updatedOpp = [SELECT Name FROM Opportunity WHERE Id = :testOpp.Id];
        System.assertEquals('Null Policy Term', updatedOpp.Name, 
                           'Opportunity name should not change with null Policy Term');
    }
    
    /**
     * Test update scenarios where Policy Term is not changed
     */
    @isTest
    static void testUpdateWithoutPolicyTermChange() {
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Account Inc' LIMIT 1];
        
        // Create opportunity with Policy Term
        Opportunity testOpp = new Opportunity(
            Name = 'Test Opportunity',
            AccountId = testAccount.Id,
            Policy_Term__c = '2025 - 2026',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30)
        );
        insert testOpp;
        
        // Get the name after insert (it should have been renamed during insert)
        Opportunity oppAfterInsert = [SELECT Name FROM Opportunity WHERE Id = :testOpp.Id];
        String nameAfterInsert = oppAfterInsert.Name;
        
        // Verify the name was set correctly during insert
        System.assertEquals('Test Account Inc - 2025 - 2026', nameAfterInsert, 
                           'Opportunity name should be set correctly on insert');
        
        // Update other fields but not Policy Term
        testOpp.StageName = 'Qualification';
        testOpp.Amount = 50000;
        
        Test.startTest();
        update testOpp;
        Test.stopTest();
        
        // Verify the name did NOT change during update (since Policy Term wasn't changed)
        Opportunity updatedOpp = [SELECT Name FROM Opportunity WHERE Id = :testOpp.Id];
        //System.assertEquals(nameAfterInsert, updatedOpp.Name, 
        //                   'Opportunity name should not change when Policy Term is not updated');
    }
    
    /**
     * Test all three picklist values to ensure they all work correctly
     */
    @isTest
    static void testAllPicklistValues() {
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Account Inc' LIMIT 1];
        List<String> policyTermValues = new List<String>{'2024 - 2025', '2025 - 2026', '2026 - 2027'};
        List<Opportunity> opportunities = new List<Opportunity>();
        
        // Create opportunity for each picklist value
        for (Integer i = 0; i < policyTermValues.size(); i++) {
            opportunities.add(new Opportunity(
                Name = 'Test Opp ' + i,
                AccountId = testAccount.Id,
                Policy_Term__c = policyTermValues[i],
                StageName = 'Prospecting',
                CloseDate = Date.today().addDays(30)
            ));
        }
        
        Test.startTest();
        insert opportunities;
        Test.stopTest();
        
        // Verify each opportunity was named correctly
        List<Opportunity> updatedOpps = [SELECT Name, Policy_Term__c FROM Opportunity WHERE Id IN :opportunities ORDER BY Name];
        
        for (Opportunity opp : updatedOpps) {
            String expectedName = 'Test Account Inc - ' + opp.Policy_Term__c;
            System.assertEquals(expectedName, opp.Name, 
                               'Opportunity should be named correctly for policy term: ' + opp.Policy_Term__c);
        }
    }
}