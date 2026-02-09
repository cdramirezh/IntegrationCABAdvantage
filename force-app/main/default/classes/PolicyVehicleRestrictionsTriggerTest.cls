@IsTest
public class PolicyVehicleRestrictionsTriggerTest {
    @IsTest
    static void testTrigger() {

        //User testUser = [SELECT Id FROM User WHERE UserName = 'sales@vantageins.us.vantcrm3' LIMIT 1];
        User testUser = [SELECT Id FROM User WHERE UserName = 'sales@vantageins.us' LIMIT 1];

        // Create a test Policy Draft record
        Policy_Draft__c policyDraft = new Policy_Draft__c(
            Status__c = 'Ready to Bind'
        );
        insert policyDraft;

        Vehicle__c vehicle = new Vehicle__c(
            Name = '1234567890'
        );
        insert vehicle;

        // Create a test policyVehicle record related to the Policy Draft
        Policy_Vehicle__c policyVehicle = new Policy_Vehicle__c(
            Policy_Draft__c = policyDraft.Id,
            Vehicle__c = vehicle.Id
        );

        // Try to insert the policyVehicle record as the test user
        System.runAs(testUser) {
            try {
                insert policyVehicle;
                System.assert(false, 'The trigger should have thrown an error.');
            } catch (Exception e) {
                System.assert(e.getMessage().contains('You cannot create a Policy Vehicle record because the related Policy Draft is in "Ready to Bind" status.'));
            }
        }
        
        // Update the Policy Draft status to allow insertions
        policyDraft.Status__c = 'Working';
        update policyDraft;

        // Try to insert the policyVehicle record as the test user
        System.runAs(testUser) {
            insert policyVehicle;
        }

        // Update the Policy Draft status to avoid deletions
        policyDraft.Status__c = 'Ready to Bind';
        update policyDraft;

        // Try to delete the policyVehicle record as the test user
        System.runAs(testUser) {
            try {
                delete policyVehicle;
                System.assert(false, 'The trigger should have thrown an error.');
            } catch (Exception e) {
                System.assert(e.getMessage().contains('You cannot delete this Policy Vehicle record because the related Policy Draft is in "Ready to Bind" status.'));
            }
        }

        // Try to update the policyVehicle record as the test user
        System.runAs(testUser) {
            try {
                policyVehicle.Status__c = 'Active';
                update policyVehicle;
                System.assert(false, 'The trigger should have thrown an error.');
            } catch (Exception e) {
                System.assert(e.getMessage().contains('You cannot update this Policy Vehicle record because the related Policy Draft is in "Ready to Bind" status.'));
            }
        }

        // Update the Policy Draft status to allow deletions
        policyDraft.Status__c = 'Working';
        update policyDraft;

        // Try to delete the policyVehicle record as the test user
        System.runAs(testUser) {
            delete policyVehicle;
        }
    }
}