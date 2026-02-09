public with sharing class ContactTaskReminderEmail {
    @InvocableMethod
    public static void sendReminderEmails() {
        // Calculate the target date (tomorrow)
        Date targetDate = System.today().addDays(1);

        // Query Contact_Task__c records due tomorrow
        List<Contact_Task__c> tasksDueTomorrow = [
            SELECT Id, Name, Producer__c, Producer__r.Email, Producer__r.Name, Potential_Client__c, Potential_Client__r.Name
            FROM Contact_Task__c 
            WHERE Due_Date__c = :targetDate AND Producer__r.Email != null
        ];

        if (tasksDueTomorrow.isEmpty()) {
            return; // No tasks to process
        }

        // Get the base URL for Salesforce
        String baseUrl = System.Url.getOrgDomainUrl().toExternalForm();

        // Prepare emails
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

        for (Contact_Task__c task : tasksDueTomorrow) {
            String taskUrl = baseUrl + '/' + task.Id; // Create link to the task
            String emailBody = 'Hello '+ task.Producer__r.Name + ',<br></br><br></br>This is a reminder for the following task due tomorrow:<br></br><br></br>' +
                'Task Name: <a href="' + taskUrl + '">' + task.Name + '</a><br></br><br></br>' +
                'Please ensure it is addressed promptly.<br></br><br></br>Best regards,<br></br>Your Team';

            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new List<String>{task.Producer__r.Email});
            email.setSubject('Reminder: Upcoming Task Due Tomorrow for '+ task.Potential_Client__r.Name);
            email.setHtmlBody(emailBody); // Use HTML for clickable link
            emails.add(email);
        }

        // Send emails
        Messaging.sendEmail(emails);
    }
}