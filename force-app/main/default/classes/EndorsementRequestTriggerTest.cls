@isTest
public class EndorsementRequestTriggerTest {
    
    // Utility method to create a user with specific alias
    private static User createUser(String alias) {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User u = new User(
            FirstName = 'Test',
            LastName = 'User_' + alias,
            Email = alias + '@test.com',
            Username = alias + '@test.com.' + System.currentTimeMillis(),
            Alias = alias,
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = p.Id
        );
        return u;
    }

    @isTest
    static void testOpenToVerificationAllowedForAnyUser() {
        User testUser = createUser('test1');
        insert testUser;

        System.runAs(testUser) {
            Endorsement_Request__c endRec = new Endorsement_Request__c(Status__c='Open');
            insert endRec;

            endRec.Status__c = 'Verification';
            Test.startTest();
            update endRec;
            Test.stopTest();
        }
    }

    @isTest
    static void testOpenToOtherThanVerificationFails() {
        User testUser = createUser('test2');
        insert testUser;

        System.runAs(testUser) {
            Endorsement_Request__c endRec = new Endorsement_Request__c(Status__c='Open');
            insert endRec;

            endRec.Status__c = 'In Process'; // Invalid transition

            Test.startTest();
            try {
                update endRec;
                System.assert(false, 'Expected error when updating status from Open to In Process');
            } catch (DmlException e) {
                System.assert(e.getMessage().contains('only move the status from Open to Verification'));
            }
            Test.stopTest();
        }
    }

    @isTest
    static void testVerificationUpdateFailsForNonKpino() {
        User testUser = createUser('notKpino');
        insert testUser;

        System.runAs(testUser) {
            Endorsement_Request__c endRec = new Endorsement_Request__c(Status__c='Verification');
            insert endRec;

            endRec.Status__c = 'Submitted';

            Test.startTest();
            try {
                update endRec;
                System.assert(false, 'Expected error when non-Kpino tries to update Verification status');
            } catch (DmlException e) {
                System.assert(e.getMessage().contains('Only Kpino can update the record'));
            }
            Test.stopTest();
        }
    }

    @isTest
    static void testVerificationUpdateAllowedForKpino() {
        User kpino = createUser('Kpino');
        insert kpino;

        System.runAs(kpino) {
            Endorsement_Request__c endRec = new Endorsement_Request__c(Status__c='Verification');
            insert endRec;

            endRec.Status__c = 'Submitted';

            Test.startTest();
            update endRec;
            Test.stopTest();
        }
    }

    @isTest
    static void testEditWhenStatusNotOpenFailsForNonKpino() {
        User testUser = createUser('test3');
        insert testUser;

        System.runAs(testUser) {
            Endorsement_Request__c endRec = new Endorsement_Request__c(Status__c='Submitted');
            insert endRec;

            endRec.Status__c = 'Open';

            Test.startTest();
            try {
                update endRec;
                System.assert(false, 'Expected error for editing non-Open status by non-Kpino');
            } catch (DmlException e) {
                System.assert(e.getMessage().contains('Only Kpino can edit the record'));
            }
            Test.stopTest();
        }
    }

    @isTest
    static void testEditWhenStatusNotOpenAllowedForKpino() {
        User kpino = createUser('Kpino');
        insert kpino;

        System.runAs(kpino) {
            Endorsement_Request__c endRec = new Endorsement_Request__c(Status__c='Submitted');
            insert endRec;

            endRec.Status__c = 'Verification';

            Test.startTest();
            update endRec;
            Test.stopTest();
        }
    }
}