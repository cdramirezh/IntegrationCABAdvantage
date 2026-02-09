@IsTest
public class PolicyDraftRestrictionsTriggerTest {
    @IsTest
    static void testUpdateTrigger() {        

        //User testUser = [SELECT Id FROM User WHERE UserName = 'sales@vantageins.us.vantcrm3' LIMIT 1];
        User testUser = [SELECT Id FROM User WHERE UserName = 'sales@vantageins.us' LIMIT 1];

        // Create a test Policy Draft record
        Policy_Draft__c policyDraft = new Policy_Draft__c(
            Status__c = 'Ready to Bind'
        );
        insert policyDraft;

        // Try to update the Policy Draft record as the test user
        System.runAs(testUser) {
            try {
                policyDraft.Status__c = 'Working';
                update policyDraft;
                System.assert(false, 'The trigger should have thrown an error.');
            } catch (Exception e) {
                System.assert(e.getMessage().contains('You cannot update this Policy Draft record because its status is "Ready to Bind" and you are not authorized.'));
            }
        }
    }

    @IsTest
    static void testDeleteTrigger() {    
        
        //User testUser = [SELECT Id FROM User WHERE UserName = 'sales@vantageins.us.vantcrm3' LIMIT 1];
        User testUser = [SELECT Id FROM User WHERE UserName = 'sales@vantageins.us' LIMIT 1];
        

        // Try to delete the Policy Draft record as the test user
        System.runAs(testUser) {
            // Create a test Policy Draft record
            Policy_Draft__c policyDraft = new Policy_Draft__c(
                Status__c = 'Ready to Bind'
            );
            insert policyDraft;

            try {
                delete policyDraft;
                System.assert(false, 'The trigger should have thrown an error.');
            } catch (Exception e) {
                System.assert(e.getMessage().contains('You cannot delete this Policy Draft record because its status is "Ready to Bind" and you are not authorized.'));
            }
        }
    }
}