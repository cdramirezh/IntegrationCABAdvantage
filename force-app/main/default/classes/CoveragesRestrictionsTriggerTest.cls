@IsTest
public class CoveragesRestrictionsTriggerTest {
    @IsTest
    static void testTrigger() {

        //User testUser = [SELECT Id FROM User WHERE UserName = 'sales@vantageins.us.vantcrm3' LIMIT 1];
        User testUser = [SELECT Id FROM User WHERE UserName = 'sales@vantageins.us' LIMIT 1];

        // Create a test Policy Draft record
        Policy_Draft__c policyDraft = new Policy_Draft__c(
            Status__c = 'Ready to Bind'
        );
        insert policyDraft;

        // Create a test Coverage record related to the Policy Draft
        Coverage__c coverage = new Coverage__c(
            Policy_Draft__c = policyDraft.Id
        );

        // Try to insert the Coverage record as the test user
        System.runAs(testUser) {
            try {
                insert coverage;
                System.assert(false, 'The trigger should have thrown an error.');
            } catch (Exception e) {
                System.assert(e.getMessage().contains('You cannot create a Coverage record because the related Policy Draft is in "Ready to Bind" status.'));
            }
        }
        
        // Update the Policy Draft status to allow insertions
        policyDraft.Status__c = 'Working';
        update policyDraft;

        // Try to insert the Coverage record as the test user
        System.runAs(testUser) {
            insert coverage;
        }

        // Update the Policy Draft status to avoid deletions
        policyDraft.Status__c = 'Ready to Bind';
        update policyDraft;

        // Try to delete the Coverage record as the test user
        System.runAs(testUser) {
            try {
                delete coverage;
                System.assert(false, 'The trigger should have thrown an error.');
            } catch (Exception e) {
                System.assert(e.getMessage().contains('You cannot delete this Coverage record because the related Policy Draft is in "Ready to Bind" status.'));
            }
        }

        // Try to update the Coverage record as the test user
        System.runAs(testUser) {
            try {
                coverage.Limit__c = 1000;
                update coverage;
                System.assert(false, 'The trigger should have thrown an error.');
            } catch (Exception e) {
                System.assert(e.getMessage().contains('You cannot update this Coverage record because the related Policy Draft is in "Ready to Bind" status.'));
            }
        }

        // Update the Policy Draft status to allow deletions
        policyDraft.Status__c = 'Working';
        update policyDraft;

        // Try to delete the Coverage record as the test user
        System.runAs(testUser) {
            delete coverage;
        }
    }
}