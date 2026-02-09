@IsTest
public class PolicyDriverRestrictionsTriggerTest {
    @IsTest
    static void testTrigger() {

        //User testUser = [SELECT Id FROM User WHERE UserName = 'sales@vantageins.us.vantcrm3' LIMIT 1];
        User testUser = [SELECT Id FROM User WHERE UserName = 'sales@vantageins.us' LIMIT 1];

        // Create a test Policy Draft record
        Policy_Draft__c policyDraft = new Policy_Draft__c(
            Status__c = 'Ready to Bind'
        );
        insert policyDraft;

        // Create a test policydriver record related to the Policy Draft
        Policy_Driver__c policydriver = new Policy_Driver__c(
            Policy_Draft__c = policyDraft.Id
        );

        // Try to insert the policydriver record as the test user
        System.runAs(testUser) {
            try {
                insert policydriver;
                System.assert(false, 'The trigger should have thrown an error.');
            } catch (Exception e) {
                System.assert(e.getMessage().contains('You cannot create a Policy Driver record because the related Policy Draft is in "Ready to Bind" status.'));
            }
        }
        
        // Update the Policy Draft status to allow insertions
        policyDraft.Status__c = 'Working';
        update policyDraft;

        // Try to insert the policydriver record as the test user
        System.runAs(testUser) {
            insert policydriver;
        }

        // Update the Policy Draft status to avoid deletions
        policyDraft.Status__c = 'Ready to Bind';
        update policyDraft;

        // Try to delete the policydriver record as the test user
        System.runAs(testUser) {
            try {
                delete policydriver;
                System.assert(false, 'The trigger should have thrown an error.');
            } catch (Exception e) {
                System.assert(e.getMessage().contains('You cannot delete this Policy Driver record because the related Policy Draft is in "Ready to Bind" status.'));
            }
        }

        // Try to update the policydriver record as the test user
        System.runAs(testUser) {
            try {
                policydriver.Status__c = 'Active';
                update policydriver;
                System.assert(false, 'The trigger should have thrown an error.');
            } catch (Exception e) {
                System.assert(e.getMessage().contains('You cannot update this Policy Driver record because the related Policy Draft is in "Ready to Bind" status.'));
            }
        }

        // Update the Policy Draft status to allow deletions
        policyDraft.Status__c = 'Working';
        update policyDraft;

        // Try to delete the policydriver record as the test user
        System.runAs(testUser) {
            delete policydriver;
        }
    }
}