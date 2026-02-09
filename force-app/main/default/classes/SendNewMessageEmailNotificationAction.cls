public with sharing class SendNewMessageEmailNotificationAction {
    @InvocableMethod(label='Send Email Notification' description='Sends an email notification based on Message__c record')
    public static void sendEmail(List<Id> messageIds) {
        // Retrieve the org-wide email address ID for noreply@vantageins.us
        Id orgWideEmailId = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'noreply@vantageins.us' LIMIT 1].Id;

        // Retrieve the instance URL
        String baseUrl = URL.getOrgDomainUrl().toExternalForm();

        // Retrieve Message__c records with related MGA_Quote__c details
        List<Message__c> messages = [
            SELECT Id, Producer_Email__c, Sales_Supervisor_Email__c, Support_Email__c, IRM_Email__c, Body__c, Sender__r.Name, Sender__r.Email, 
                   Chat__r.MGA_Quote__r.Name, Chat__r.MGA_Quote__c, Chat__r.MGA_Quote__r.Company_Name__c
            FROM Message__c 
            WHERE Id IN :messageIds
        ];
        
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

        for (Message__c message : messages) {
            // Validate if Producer_Email__c field has a value
            if (String.isNotBlank(message.Producer_Email__c)) {
                // Create email message to notify the recipients
                Messaging.SingleEmailMessage recipientEmail = new Messaging.SingleEmailMessage();
                
                // Set recipient and sender information
                recipientEmail.setToAddresses(new List<String>{ message.Producer_Email__c, message.Sales_Supervisor_Email__c });
                recipientEmail.setCcAddresses(new List<String>{ message.Support_Email__c, message.IRM_Email__c });
                recipientEmail.setOrgWideEmailAddressId(orgWideEmailId); // Use org-wide email address
                
                // Set email subject, including the name of the related MGA_Quote__c record
                String subject = 'New Message in a Quote for ' + message.Chat__r.MGA_Quote__r.Company_Name__c;
                recipientEmail.setSubject(subject);

                // Set email body with sender name, message content, and a link to the related MGA_Quote__c record
                String body = 'You have received a new message:<br/><br/>' +
                              '<strong>Sender:</strong> ' + message.Sender__r.Name + '<br/>' +
                              '<strong>Message:</strong> ' + message.Body__c + '<br/><br/>' +
                              'View the related quote here: <a href="' + 
                              baseUrl + '/' + message.Chat__r.MGA_Quote__c + 
                              '">Quote: ' + message.Chat__r.MGA_Quote__r.Name + '</a>';
                
                recipientEmail.setHtmlBody(body);
                
                // Add recipient email to list
                emails.add(recipientEmail);
            }

            // Send confirmation email to the sender if Sender__r.Email is populated
            if (message.Sender__r != null && String.isNotBlank(message.Sender__r.Email)) {
                Messaging.SingleEmailMessage senderConfirmationEmail = new Messaging.SingleEmailMessage();
                
                // Set recipient and subject for sender confirmation email
                senderConfirmationEmail.setToAddresses(new List<String>{ message.Sender__r.Email });
                senderConfirmationEmail.setOrgWideEmailAddressId(orgWideEmailId); // Use org-wide email address
                
                String subject = 'Confirmation of Your MGA Quote Message Submission for ' + message.Chat__r.MGA_Quote__r.Company_Name__c;
                senderConfirmationEmail.setSubject(subject);

                // Set email body to inform sender of message submission
                String senderBody = 'Hello ' + message.Sender__r.Name + ',<br/><br/>' +
                                    'You just sent a message regarding Quote: ' + message.Chat__r.MGA_Quote__r.Name + '.<br/><br/>' +
                                    'Here is a copy of your message for reference:<br/><br/>' +
                                    '<strong>Message:</strong> ' + message.Body__c + '<br/><br/>' +
                                    'You can view the quote here: <a href="' + 
                                    baseUrl + '/' + message.Chat__r.MGA_Quote__c + 
                                    '">Quote: ' + message.Chat__r.MGA_Quote__r.Name + '</a>' + '<br/><br/>' +
                                    'If you don’t recognize this activity, please contact the producer of the quote.';
                
                senderConfirmationEmail.setHtmlBody(senderBody);
                
                // Add sender confirmation email to list
                emails.add(senderConfirmationEmail);
            }
        }
        
        // Send all emails if there are any
        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails);
        }
    }
}