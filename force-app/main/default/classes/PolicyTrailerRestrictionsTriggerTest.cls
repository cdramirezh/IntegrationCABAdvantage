@IsTest
public class PolicyTrailerRestrictionsTriggerTest {
    @IsTest
    static void testTrigger() {

        //User testUser = [SELECT Id FROM User WHERE UserName = 'sales@vantageins.us.vantcrm3' LIMIT 1];
        User testUser = [SELECT Id FROM User WHERE UserName = 'sales@vantageins.us' LIMIT 1];

        // Create a test Policy Draft record
        Policy_Draft__c policyDraft = new Policy_Draft__c(
            Status__c = 'Ready to Bind'
        );
        insert policyDraft;

        Trailer__c Trailer = new Trailer__c(
            Name = '1234567890'
        );
        insert Trailer;

        // Create a test policyTrailer record related to the Policy Draft
        Policy_Trailer__c policyTrailer = new Policy_Trailer__c(
            Policy_Draft__c = policyDraft.Id,
            Trailer__c = Trailer.Id
        );

        // Try to insert the policyTrailer record as the test user
        System.runAs(testUser) {
            try {
                insert policyTrailer;
                System.assert(false, 'The trigger should have thrown an error.');
            } catch (Exception e) {
                System.assert(e.getMessage().contains('You cannot create a Policy Trailer record because the related Policy Draft is in "Ready to Bind" status.'));
            }
        }
        
        // Update the Policy Draft status to allow insertions
        policyDraft.Status__c = 'Working';
        update policyDraft;

        // Try to insert the policyTrailer record as the test user
        System.runAs(testUser) {
            insert policyTrailer;
        }

        // Update the Policy Draft status to avoid deletions
        policyDraft.Status__c = 'Ready to Bind';
        update policyDraft;

        // Try to delete the policyTrailer record as the test user
        System.runAs(testUser) {
            try {
                delete policyTrailer;
                System.assert(false, 'The trigger should have thrown an error.');
            } catch (Exception e) {
                System.assert(e.getMessage().contains('You cannot delete this Policy Trailer record because the related Policy Draft is in "Ready to Bind" status.'));
            }
        }

        // Try to update the policyTrailer record as the test user
        System.runAs(testUser) {
            try {
                policyTrailer.Status__c = 'Active';
                update policyTrailer;
                System.assert(false, 'The trigger should have thrown an error.');
            } catch (Exception e) {
                System.assert(e.getMessage().contains('You cannot update this Policy Trailer record because the related Policy Draft is in "Ready to Bind" status.'));
            }
        }

        // Update the Policy Draft status to allow deletions
        policyDraft.Status__c = 'Working';
        update policyDraft;

        // Try to delete the policyTrailer record as the test user
        System.runAs(testUser) {
            delete policyTrailer;
        }
    }
}