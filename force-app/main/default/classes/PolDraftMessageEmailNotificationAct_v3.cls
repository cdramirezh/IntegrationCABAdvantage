public with sharing class PolDraftMessageEmailNotificationAct_v3 {
    @InvocableMethod(label='Policy Draft New Message Email Notification' description='Sends an email notification based on Message__c record')
    public static void sendEmail(List<Id> messageIds) {
        // Retrieve the org-wide email address ID for noreply@vantageins.us
        Id orgWideEmailId = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'noreply@vantageins.us' LIMIT 1].Id;

        // Retrieve the instance URL
        String baseUrl = URL.getOrgDomainUrl().toExternalForm();

        // Retrieve Message__c records with related Policy_Draft__c details
        List<Message__c> messages = [
            SELECT Id, Body__c, Sender__r.Name, Sender__r.Email, Related_Insurance_Co__c, Related_Insurance_Co__r.Insurance_Company__r.Name, 
                    Related_MGA_Quote__c, Related_MGA_Quote__r.MGA_Company__r.Name, 
                    Chat__r.Policy_Draft__r.Producer__r.Email, 
                    //Chat__r.Policy_Draft__r.Sales_Supervisor__r.Email, Chat__r.Policy_Draft__r.IRM_Agent_Email__c, Chat__r.Policy_Draft__r.Support_Agent_Email__c,
                    Chat__r.Policy_Draft__r.Sales_Supervisor_F__c, Chat__r.Policy_Draft__r.IRM_Agent_Email_F__c, 
                    Chat__r.Policy_Draft__r.Support_Agent_Email_F__c, Chat__r.Policy_Draft__r.Additional_Email_for_Notifications_1__c,
                    Chat__r.Policy_Draft__r.Additional_Email_for_Notifications_2__c, Chat__r.Policy_Draft__r.Renewal__c,
                    Chat__r.Policy_Draft__r.Name, Chat__r.Policy_Draft__c, Chat__r.Policy_Draft__r.Company_Name__c
            FROM Message__c 
            WHERE Id IN :messageIds
        ];

        // create an list of email to addresses if the email is not blank
        List<string> toAddresses = new List<string>();
        for (Message__c message : messages) {
            if (String.isNotBlank(message.Chat__r.Policy_Draft__r.Producer__r.Email)) {
                toAddresses.add(message.Chat__r.Policy_Draft__r.Producer__r.Email);
            }
            if (String.isNotBlank(message.Chat__r.Policy_Draft__r.Sales_Supervisor_F__c)) {
                toAddresses.add(message.Chat__r.Policy_Draft__r.Sales_Supervisor_F__c);
            }                    
            if (message.Chat__r.Policy_Draft__r.Renewal__c == true ) {
                toAddresses.add('loyalty@vantageins.us');
                toAddresses.add('support@vantageins.us');
                toAddresses.add('renewals@vantageins.us');                
            } 
        }

        // create an list of email cc addresses if the email is not blank
        List<string> ccAddresses = new List<string>();
        for (Message__c message : messages) {
            if (String.isNotBlank(message.Chat__r.Policy_Draft__r.Support_Agent_Email_F__c)) {
                ccAddresses.add(message.Chat__r.Policy_Draft__r.Support_Agent_Email_F__c);
            }
            if (String.isNotBlank(message.Chat__r.Policy_Draft__r.IRM_Agent_Email_F__c)) {
                ccAddresses.add(message.Chat__r.Policy_Draft__r.IRM_Agent_Email_F__c);
            }
            if (String.isNotBlank(message.Chat__r.Policy_Draft__r.Additional_Email_for_Notifications_1__c)) {
                ccAddresses.add(message.Chat__r.Policy_Draft__r.Additional_Email_for_Notifications_1__c);
            }
            if (String.isNotBlank(message.Chat__r.Policy_Draft__r.Additional_Email_for_Notifications_2__c)) {
                ccAddresses.add(message.Chat__r.Policy_Draft__r.Additional_Email_for_Notifications_2__c);
            }
        }        
        
        
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

        for (Message__c message : messages) {
            // Validate if Producer_Email__c field has a value
            if (String.isNotBlank(message.Chat__r.Policy_Draft__r.Producer__r.Email)) {
                // Create email message to notify the recipients
                Messaging.SingleEmailMessage recipientEmail = new Messaging.SingleEmailMessage();

                //String subjectFilter = 'New Message in a Policy Draft for ' + message.Chat__r.Policy_Draft__r.Company_Name__c;
                String subjectFilter = 'New Message in Policy Draft ' + message.Chat__r.Policy_Draft__r.Name + ' for ' + message.Chat__r.Policy_Draft__r.Company_Name__c;
                String threadIdentifier = ''; // Variable to store ThreadIdentifier

                List<EmailMessage> EmailMessages = [
                    SELECT Id, Subject, MessageIdentifier, ThreadIdentifier, CreatedDate 
                    FROM EmailMessage 
                    WHERE Subject LIKE :('%' + subjectFilter + '%') 
                    ORDER BY CreatedDate DESC 
                    LIMIT 1
                ];

                // Assign the ThreadIdentifier if a record is found
                if (!EmailMessages.isEmpty()) {
                    threadIdentifier = EmailMessages[0].ThreadIdentifier;
                }
                
                // Set recipient and sender information
                //recipientEmail.setToAddresses(new List<String>{ message.Chat__r.Policy_Draft__r.Producer__r.Email, message.Chat__r.Policy_Draft__r.Sales_Supervisor__r.Email });
                recipientEmail.setToAddresses(toAddresses);
                //recipientEmail.setCcAddresses(new List<String>{ message.Chat__r.Policy_Draft__r.Support_Agent_Email_F__c, message.Chat__r.Policy_Draft__r.IRM_Agent_Email_F__c, message.Chat__r.Policy_Draft__r.Additional_Email_for_Notifications_1__c });
                recipientEmail.setCcAddresses(ccAddresses);
                recipientEmail.setOrgWideEmailAddressId(orgWideEmailId); // Use org-wide email address

                //Set Thread identifier and References
                recipientEmail.setInReplyTo(threadIdentifier); // Set the ThreadIdentifier
                recipientEmail.setReferences(threadIdentifier); // Set the ThreadIdentifier
                
                // Set email subject, including the name of the related Policy_Draft__c record
                //String subject = 'New Message in a Policy Draft for ' + message.Chat__r.Policy_Draft__r.Company_Name__c;
                String subject = 'New Message in Policy Draft ' + message.Chat__r.Policy_Draft__r.Name + ' for ' + message.Chat__r.Policy_Draft__r.Company_Name__c;
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
          

        }
        
        // Send all emails if there are any
        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails);
        }
    }
}