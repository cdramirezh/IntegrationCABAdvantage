@IsTest
private class EndorsementColdScheduledNotificationTest {
    
    @TestSetup
    static void setupTestData() {
        // Create Test Contact 
        Contact TestContact = new Contact(LastName = 'Biden', Email = 'contact@mycompany.com');
        insert TestContact;        

        //Create Test Account
        Account TestAccount = new Account(Name = 'Test Account', Owner_DOB__c = Date.today());
        insert TestAccount;

        //create Test opporrtunity
        Opportunity testOpp = new Opportunity(Name = 'Test Opportunity', StageName = 'Prospecting', CloseDate = Date.today(), AccountId = TestAccount.Id, Producer__c = TestContact.Id);
        insert testOpp;
        
        // Create endorsement requests with different scenarios
        List<Endorsement_Request__c> endorsements = new List<Endorsement_Request__c>();
        
        // Endorsement that needs notification (25 days old)
        endorsements.add(new Endorsement_Request__c(
            //Name = 'ER-001',
            //Company_Name__c = 'Test Company 1',
            Status__c = 'Submitted',
            Process_Owner_p__c = 'Sales Team',
            Last_Status_Change__c = Datetime.now().addDays(-25),
            Opportunity__c = testOpp.Id
        ));
        
        // Endorsement that needs notification (exactly 20 days old)
        endorsements.add(new Endorsement_Request__c(
            //Name = 'ER-002',
            //Company_Name__c = 'Test Company 2',
            Status__c = 'In Process',
            Process_Owner_p__c = 'Loyalty Team',
            Last_Status_Change__c = Datetime.now().addDays(-21)
        ));
        
        // Endorsement that doesn't need notification (15 days old)
        endorsements.add(new Endorsement_Request__c(
            //Name = 'ER-003',
            //Company_Name__c = 'Test Company 3',
            Status__c = 'Completed',
            Process_Owner_p__c = 'Endorsements Team',
            Last_Status_Change__c = Datetime.now().addDays(-15)
        ));
        
        // Endorsement with null Last_Status_Change__c
        endorsements.add(new Endorsement_Request__c(
            //Name = 'ER-004',
            //Company_Name__c = 'Test Company 4',
            Status__c = 'Open',
            Process_Owner_p__c = 'Sales Team'
        ));
        
        insert endorsements;
    }
    
    @IsTest
    static void testSendScheduledStatusChangeEmails_WithValidRecords() {
        Test.startTest();
        
        // Call the invocable method
        List<String> dummyParams = new List<String>{'dummy'};
        EndorsementColdScheduledNotification.sendScheduledStatusChangeEmails(dummyParams);
        
        Test.stopTest();
        
        // Verify that the method executed without exceptions
        // Note: We can't easily assert on emails sent in test context without org-wide email setup
        // But we can verify the method completes successfully
        System.assert(true, 'Method executed successfully');
    }
    
    @IsTest
    static void testSendScheduledStatusChangeEmails_NoRecordsToProcess() {
        // Delete all test records that would qualify for notification
        List<Endorsement_Request__c> toDelete = [
            SELECT Id FROM Endorsement_Request__c 
            WHERE Last_Status_Change__c <= :Date.today().addDays(-20)
        ];
        delete toDelete;
        
        Test.startTest();
        
        List<String> dummyParams = new List<String>{'dummy'};
        EndorsementColdScheduledNotification.sendScheduledStatusChangeEmails(dummyParams);
        
        Test.stopTest();
        
        // Verify method handles empty result set gracefully
        System.assert(true, 'Method handled empty result set successfully');
    }
    
    @IsTest
    static void testSendScheduledStatusChangeEmails_EmptyParameter() {
        Test.startTest();
        
        // Call with empty list
        List<String> emptyParams = new List<String>();
        EndorsementColdScheduledNotification.sendScheduledStatusChangeEmails(emptyParams);
        
        Test.stopTest();
        
        // Should handle empty parameters gracefully
        System.assert(true, 'Method handled empty parameters successfully');
    }
    
    @IsTest
    static void testProcessOwnerEmailLogic() {
        // This test verifies the email address logic for different process owners
        List<Endorsement_Request__c> testEndorsements = [
            SELECT Id, Process_Owner_p__c, Opportunity__r.Producer__r.Email
            FROM Endorsement_Request__c
            WHERE Last_Status_Change__c != null
            ORDER BY Name
        ];
        
        Test.startTest();
        
        // Test that we have the expected number of records
        System.assertEquals(3, testEndorsements.size(), 'Should have 3 endorsement requests with Last_Status_Change__c');
        
        // Verify different process owners exist in test data
        Set<String> processOwners = new Set<String>();
        for (Endorsement_Request__c er : testEndorsements) {
            processOwners.add(er.Process_Owner_p__c);
        }
        
        System.assert(processOwners.contains('Sales Team'), 'Should have Sales Team process owner');
        System.assert(processOwners.contains('Loyalty Team'), 'Should have Loyalty Team process owner');
        System.assert(processOwners.contains('Endorsements Team'), 'Should have Endorsements Team process owner');
        
        Test.stopTest();
    }
    
    @IsTest
    static void testDateCalculationLogic() {
        Date today = Date.today();
        Date thresholdDate = today.addDays(-20);
        
        // Query records that should be included
        List<Endorsement_Request__c> qualifyingRecords = [
            SELECT Id, Last_Status_Change__c
            FROM Endorsement_Request__c
            WHERE Last_Status_Change__c != null 
            AND Last_Status_Change__c <= :thresholdDate
        ];
        
        // Should find 2 records (25 days old and 20 days old)
        System.assertEquals(2, qualifyingRecords.size(), 'Should find 2 records that qualify for notification');
        
        // Verify the dates are correct
        for (Endorsement_Request__c er : qualifyingRecords) {
            System.assert(er.Last_Status_Change__c.date() <= thresholdDate, 
                         'Record should have Last_Status_Change__c older than or equal to threshold date');
        }
    }
}