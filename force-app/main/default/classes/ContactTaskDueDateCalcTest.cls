@isTest
public class ContactTaskDueDateCalcTest {
    @isTest
    static void testContactTaskDueDateTrigger() {
        // Test Case 1: Insert new Contact_Task__c records with various Type__c values
        List<Contact_Task__c> tasksToInsert = new List<Contact_Task__c>{
            new Contact_Task__c(Type__c = 'Call'),
            new Contact_Task__c(Type__c = 'Requesting information'),
            new Contact_Task__c(Type__c = 'Prospect New Venture'),
            new Contact_Task__c(Type__c = 'Positive'),
            new Contact_Task__c(Type__c = 'Follow up'),
            new Contact_Task__c(Type__c = 'Prospect Renewal'),
            new Contact_Task__c(Type__c = 'Follow up Renewal')
        };

        // Insert records
        Test.startTest();
        insert tasksToInsert;
        Test.stopTest();

        // Verify Due_Date__c for each record
        tasksToInsert = [SELECT Type__c, Due_Date__c FROM Contact_Task__c];

        Map<String, Integer> typeToDaysMap = new Map<String, Integer>{
            'Call' => 2,
            'Requesting information' => 3,
            'Prospect New Venture' => 6,
            'Positive' => 6,
            'Follow up' => 6,
            'Prospect Renewal' => 6,
            'Follow up Renewal' => 6
        };

        for (Contact_Task__c task : tasksToInsert) {
            Integer expectedDaysToAdd = typeToDaysMap.get(task.Type__c);
            Date expectedDueDate = calculateBusinessDate.addBusinessDays(System.today(), expectedDaysToAdd);
            System.assertEquals(expectedDueDate, task.Due_Date__c, 'The Due_Date__c should match the calculated date based on Type__c.');
        }

        // Test Case 2: Insert a record with no Type__c
        Contact_Task__c taskWithoutType = new Contact_Task__c();
        insert taskWithoutType;

        // Verify that Due_Date__c is null
        taskWithoutType = [SELECT Due_Date__c FROM Contact_Task__c WHERE Id = :taskWithoutType.Id];
        System.assertEquals(null, taskWithoutType.Due_Date__c, 'The Due_Date__c should remain null when Type__c is not specified.');

        // Test Case 3: Update a record and verify Due_Date__c recalculation
        Contact_Task__c existingTask = tasksToInsert[0]; // Take the first task
        existingTask.Type__c = 'Requesting information'; // Update Type__c to a different value
        update existingTask;

        existingTask = [SELECT Type__c, Due_Date__c FROM Contact_Task__c WHERE Id = :existingTask.Id];
        Integer updatedDaysToAdd = typeToDaysMap.get(existingTask.Type__c);
        Date updatedDueDate = calculateBusinessDate.addBusinessDays(System.today(), updatedDaysToAdd);
        System.assertEquals(updatedDueDate, existingTask.Due_Date__c, 'The Due_Date__c should be recalculated after updating Type__c.');
    }
}