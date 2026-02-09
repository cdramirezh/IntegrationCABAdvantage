public with sharing class BindReqNewMsgEmailNotificationAction_v3 {
    @InvocableMethod(label='Bind Req New Message Email Notification' description='Sends an email notification based on Message__c record')
    public static void sendEmail(List<Id> messageIds) {
        // Retrieve the org-wide email address ID for noreply@vantageins.us
        Id orgWideEmailId = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'noreply@vantageins.us' LIMIT 1].Id;

        // Retrieve the instance URL
        String baseUrl = URL.getOrgDomainUrl().toExternalForm();

        // Retrieve Message__c records with related Binder_Request__c details
        List<Message__c> messages = [
            SELECT Id, Body__c, Sender__r.Name, Sender__r.Email,
                   Chat__r.Binder_Request__r.Policy_Draft__r.Producer__r.Email,
                   //Chat__r.Binder_Request__r.Policy_Draft__r.IRM_Agent_Email__c, Chat__r.Binder_Request__r.Policy_Draft__r.Support_Agent_Email__c,
                   Chat__r.Binder_Request__r.Policy_Draft__r.Sales_Supervisor_F__c, Chat__r.Binder_Request__r.Policy_Draft__r.IRM_Agent_Email_F__c, 
                   Chat__r.Binder_Request__r.Policy_Draft__r.Support_Agent_Email_F__c, Chat__r.Binder_Request__r.Policy_Draft__r.Additional_Email_for_Notifications_1__c,
                   Chat__r.Binder_Request__r.Policy_Draft__r.Additional_Email_for_Notifications_2__c,
                   Chat__r.Binder_Request__r.Name, Chat__r.Binder_Request__c, Chat__r.Binder_Request__r.Company_Name__c
            FROM Message__c 
            WHERE Id IN :messageIds
        ];

        // create an list of email to addresses if the email is not blank
        List<string> toAddresses = new List<string>();
        for (Message__c message : messages) {
            if (String.isNotBlank(message.Chat__r.Binder_Request__r.Policy_Draft__r.Producer__r.Email)) {
                toAddresses.add(message.Chat__r.Binder_Request__r.Policy_Draft__r.Producer__r.Email);
            }
            if (String.isNotBlank(message.Chat__r.Binder_Request__r.Policy_Draft__r.Sales_Supervisor_F__c)) {
                toAddresses.add(message.Chat__r.Binder_Request__r.Policy_Draft__r.Sales_Supervisor_F__c);
            }
        }

        // create an list of email cc addresses if the email is not blank
        List<string> ccAddresses = new List<string>();
        for (Message__c message : messages) {
            if (String.isNotBlank(message.Chat__r.Binder_Request__r.Policy_Draft__r.Support_Agent_Email_F__c)) {
                ccAddresses.add(message.Chat__r.Binder_Request__r.Policy_Draft__r.Support_Agent_Email_F__c);
            }
            if (String.isNotBlank(message.Chat__r.Binder_Request__r.Policy_Draft__r.IRM_Agent_Email_F__c)) {
                ccAddresses.add(message.Chat__r.Binder_Request__r.Policy_Draft__r.IRM_Agent_Email_F__c);
            }
            if (String.isNotBlank(message.Chat__r.Binder_Request__r.Policy_Draft__r.Additional_Email_for_Notifications_1__c)) {
                ccAddresses.add(message.Chat__r.Binder_Request__r.Policy_Draft__r.Additional_Email_for_Notifications_1__c);
            }
            if (String.isNotBlank(message.Chat__r.Binder_Request__r.Policy_Draft__r.Additional_Email_for_Notifications_2__c)) {
                ccAddresses.add(message.Chat__r.Binder_Request__r.Policy_Draft__r.Additional_Email_for_Notifications_2__c);
            }
            ccAddresses.add('Cfo@vantageins.us');
            ccAddresses.add('Loyalty@vantageins.us');
        }    

        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

        for (Message__c message : messages) {
            if (String.isNotBlank(message.Chat__r.Binder_Request__r.Policy_Draft__r.Producer__r.Email)) {
                Messaging.SingleEmailMessage recipientEmail = new Messaging.SingleEmailMessage();

                String subjectFilter = 'New Message in a Binder Request for ' + message.Chat__r.Binder_Request__r.Company_Name__c;
                String threadIdentifier = '';

                // Query for the most recent email message with the same subject
                List<EmailMessage> emailMessages = [
                    SELECT Id, Subject, MessageIdentifier, ThreadIdentifier, CreatedDate 
                    FROM EmailMessage 
                    WHERE Subject LIKE :('%' + subjectFilter + '%') 
                    ORDER BY CreatedDate DESC 
                    LIMIT 1
                ];

                if (!emailMessages.isEmpty()) {
                    threadIdentifier = emailMessages[0].ThreadIdentifier;
                }

                // Set recipient information
                //recipientEmail.setToAddresses(new List<String>{ message.Chat__r.Binder_Request__r.Policy_Draft__r.Producer__r.Email, message.Chat__r.Binder_Request__r.Policy_Draft__r.Sales_Supervisor__r.Email });
                recipientEmail.setToAddresses(toAddresses);
                //recipientEmail.setCcAddresses(new List<String>{ message.Chat__r.Binder_Request__r.Policy_Draft__r.Support_Agent_Email_F__c, message.Chat__r.Binder_Request__r.Policy_Draft__r.IRM_Agent_Email_F__c, message.Chat__r.Binder_Request__r.Policy_Draft__r.Process_Supervisor_Email__c, 'Cfo@vantageins.us', 'Loyalty@vantageins.us' });
                recipientEmail.setCcAddresses(ccAddresses);
                //recipientEmail.setCcAddresses(new List<String>{ message.Chat__r.Binder_Request__r.Policy_Draft__r.Support_Agent_Email__c, message.Chat__r.Binder_Request__r.Policy_Draft__r.IRM_Agent_Email__c });
                recipientEmail.setOrgWideEmailAddressId(orgWideEmailId);

                // Set email threading attributes
                recipientEmail.setInReplyTo(threadIdentifier);
                recipientEmail.setReferences(threadIdentifier);

                // Set email subject and body
                String subject = 'New Message in a Binder Request for ' + message.Chat__r.Binder_Request__r.Company_Name__c;
                recipientEmail.setSubject(subject);

                String body = 'You have received a new message:<br/><br/>' +
                              '<strong>Sender:</strong> ' + message.Sender__r.Name + '<br/>' +
                              '<strong>Message:</strong> ' + message.Body__c + '<br/><br/>' +
                              'View the related Binder Request here: <a href="' + 
                              baseUrl + '/' + message.Chat__r.Binder_Request__c + 
                              '">Binder Request: ' + message.Chat__r.Binder_Request__r.Name + '</a>';
                recipientEmail.setHtmlBody(body);

                emails.add(recipientEmail);
            }
        }

        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails);
        }
    }
}