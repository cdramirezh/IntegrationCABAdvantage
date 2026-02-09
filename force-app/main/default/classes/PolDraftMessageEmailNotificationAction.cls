public with sharing class PolDraftMessageEmailNotificationAction {
    @InvocableMethod(label='Policy Draft New Message Email Notification' description='Sends an email notification based on Message__c record')
    public static void sendEmail(List<Id> messageIds) {
        // Retrieve the org-wide email address ID for noreply@vantageins.us
        Id orgWideEmailId = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'noreply@vantageins.us' LIMIT 1].Id;

        // Retrieve the instance URL
        String baseUrl = URL.getOrgDomainUrl().toExternalForm();

        // Retrieve Message__c records with related Policy_Draft__c details
        List<Message__c> messages = [
            SELECT Id, Body__c, Sender__r.Name, Sender__r.Email, Related_Insurance_Co__c, Related_Insurance_Co__r.Insurance_Company__r.Name, Related_MGA_Quote__c, Related_MGA_Quote__r.MGA_Company__r.Name, 
                    Chat__r.Policy_Draft__r.Producer__r.Email, Chat__r.Policy_Draft__r.Sales_Supervisor__r.Email, Chat__r.Policy_Draft__r.IRM_Agent_Email__c, Chat__r.Policy_Draft__r.Support_Agent_Email__c,
                    Chat__r.Policy_Draft__r.Name, Chat__r.Policy_Draft__c, Chat__r.Policy_Draft__r.Company_Name__c
            FROM Message__c 
            WHERE Id IN :messageIds
        ];
        
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

        for (Message__c message : messages) {
            // Validate if Producer_Email__c field has a value
            if (String.isNotBlank(message.Chat__r.Policy_Draft__r.Producer__r.Email)) {
                // Create email message to notify the recipients
                Messaging.SingleEmailMessage recipientEmail = new Messaging.SingleEmailMessage();
                
                // Set recipient and sender information
                recipientEmail.setToAddresses(new List<String>{ message.Chat__r.Policy_Draft__r.Producer__r.Email, message.Chat__r.Policy_Draft__r.Sales_Supervisor__r.Email, 'kori@vantageins.us' });
                recipientEmail.setCcAddresses(new List<String>{ message.Chat__r.Policy_Draft__r.Support_Agent_Email__c, message.Chat__r.Policy_Draft__r.IRM_Agent_Email__c });
                recipientEmail.setOrgWideEmailAddressId(orgWideEmailId); // Use org-wide email address
                
                // Set email subject, including the name of the related Policy_Draft__c record
                String subject = 'New Message in a Policy Draft for ' + message.Chat__r.Policy_Draft__r.Company_Name__c;
                recipientEmail.setSubject(subject);

                // Set email body with sender name, message content, and a link to the related Policy_Draft__c record
                String body = 'You have received a new message:<br/><br/>' +
                              '<strong>Sender:</strong> ' + message.Sender__r.Name + '<br/>' +                              
                              '<strong>MGA Quote:</strong> ' + message.Related_MGA_Quote__r.MGA_Company__r.Name + '<br/>' +
                                '<strong>Insurance Company:</strong> ' + message.Related_Insurance_Co__r.Insurance_Company__r.Name + '<br/><br/>' +
                                '<strong>Message:</strong> ' + message.Body__c + '<br/><br/>' +
                              'View the related Policy Draft here: <a href="' + 
                              baseUrl + '/' + message.Chat__r.Policy_Draft__c + 
                              '">Policy Draft: ' + message.Chat__r.Policy_Draft__r.Name + '</a>';
                
                recipientEmail.setHtmlBody(body);
                
                // Add recipient email to list
                emails.add(recipientEmail);
            }
            
            /*
            // Send confirmation email to the sender if Sender__r.Email is populated
            if (message.Sender__r != null && String.isNotBlank(message.Sender__r.Email)) {
                Messaging.SingleEmailMessage senderConfirmationEmail = new Messaging.SingleEmailMessage();
                
                // Set recipient and subject for sender confirmation email
                senderConfirmationEmail.setToAddresses(new List<String>{ message.Sender__r.Email });
                senderConfirmationEmail.setOrgWideEmailAddressId(orgWideEmailId); // Use org-wide email address
                
                String subject = 'Confirmation of Your Policy Draft Message Submission for ' + message.Chat__r.Policy_Draft__r.Company_Name__c;
                senderConfirmationEmail.setSubject(subject);

                // Set email body to inform sender of message submission
                String senderBody = 'Hello ' + message.Sender__r.Name + ',<br/><br/>' +
                                    'You just sent a message regarding Policy Draft: ' + message.Chat__r.Policy_Draft__r.Name + '.<br/><br/>' +
                                    'Here is a copy of your message for reference:<br/><br/>' +
                                    '<strong>MGA Quote:</strong> ' + message.Related_MGA_Quote__r.MGA_Company__r.Name + '<br/>' +
                                    '<strong>Insurance Company:</strong> ' + message.Related_Insurance_Co__r.Insurance_Company__r.Name + '<br/><br/>' +
                                    '<strong>Message:</strong> ' + message.Body__c + '<br/><br/>' +
                                    'You can view the Policy Draft here: <a href="' + 
                                    baseUrl + '/' + message.Chat__r.Policy_Draft__c + 
                                    '">Policy Draft: ' + message.Chat__r.Policy_Draft__r.Name + '</a>' + '<br/><br/>' +
                                    'If you don’t recognize this activity, please contact the producer of the Policy Draft.';
                
                senderConfirmationEmail.setHtmlBody(senderBody);
                
                // Add sender confirmation email to list
                emails.add(senderConfirmationEmail);
            }
            */

        }
        
        // Send all emails if there are any
        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails);
        }
    }
}