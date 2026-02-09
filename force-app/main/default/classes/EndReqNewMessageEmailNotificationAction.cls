public with sharing class EndReqNewMessageEmailNotificationAction {
    @InvocableMethod(label='Endorsement Req New Message Email Notification' description='Sends an email notification based on Message__c record')
    public static void sendEmail(List<Id> messageIds) {
        // Retrieve the org-wide email address ID for noreply@vantageins.us
        Id orgWideEmailId = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'noreply@vantageins.us' LIMIT 1].Id;

        // Retrieve the instance URL
        String baseUrl = URL.getOrgDomainUrl().toExternalForm();

        // Retrieve Message__c records with related Endorsement_Request__c details
        List<Message__c> messages = [
            SELECT Id, Body__c, Sender__r.Name, Sender__r.Email,
            /*
                    Chat__r.Endorsement_Request__r.Opportunity__r.Producer__r.Email, Chat__r.Endorsement_Request__r.Opportunity__r.Sales_Supervisor__r.Email, Chat__r.Endorsement_Request__r.Opportunity__r.IRM_Agent_Email__c, Chat__r.Endorsement_Request__r.Opportunity__r.Support_Agent_Email__c,
                    Chat__r.Endorsement_Request__r.Name, Chat__r.Endorsement_Request__c, Chat__r.Endorsement_Request__r.Company_Name__c
                    */
                    Chat__r.Endorsement_Request__r.Opportunity__r.Producer__r.Email,
                    Chat__r.Endorsement_Request__r.Name, Chat__r.Endorsement_Request__c, Chat__r.Endorsement_Request__r.Company_Name__c,
                    Chat__r.Endorsement_Request__r.Process_Owner__r.Name, Chat__r.Endorsement_Request__r.Process_Owner_p__c, Chat__r.Endorsement_Request__r.Subject__c,
                    Chat__r.Endorsement_Request__r.Opportunity__r.USDOT__c, Chat__r.Endorsement_Request__r.Status__c
            FROM Message__c 
            WHERE Id IN :messageIds
        ];
        
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

        for (Message__c message : messages) {
            // Validate if Producer_Email__c field has a value
            if (String.isNotBlank(message.Chat__r.Endorsement_Request__r.Opportunity__r.Producer__r.Email)) {
                // Create email message to notify the recipients
                Messaging.SingleEmailMessage recipientEmail = new Messaging.SingleEmailMessage();
                
                String subjectFilter = 'New Message in a Endorsement Request for ' + message.Chat__r.Endorsement_Request__r.Company_Name__c;
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

                // Populate toAddresses
                List<String> toAddresses = new List<String>();

                if (message.Chat__r.Endorsement_Request__r.Process_Owner_p__c == 'Sales Team') {
                    if (message.Chat__r.Endorsement_Request__r.Opportunity__r != null && message.Chat__r.Endorsement_Request__r.Opportunity__r.Producer__r != null && 
                        String.isNotBlank(message.Chat__r.Endorsement_Request__r.Opportunity__r.Producer__r.Email)) {
                        toAddresses.add(message.Chat__r.Endorsement_Request__r.Opportunity__r.Producer__r.Email);
                    }
                    //toAddresses.add('piztekweb@gmail.com');
                    toAddresses.add('loyalty@vantageins.us');
                    toAddresses.add('endorsements@vantageins.us');
                    toAddresses.add('support@vantageins.us');
                    /*
                    if (message.Chat__r.Endorsement_Request__r.Status__c == 'Submitted' || message.Chat__r.Endorsement_Request__r.Status__c == 'In Process' || message.Chat__r.Endorsement_Request__r.Status__c == 'Completed' || message.Chat__r.Endorsement_Request__r.Status__c == 'Rejected') {
                        toAddresses.add('support@vantageins.us');
                    }
                        */
                } else if (message.Chat__r.Endorsement_Request__r.Process_Owner_p__c == 'Loyalty Team') {
                    //toAddresses.add('royaltyservicesvpn1@gmail.com');
                    toAddresses.add('loyalty@vantageins.us');
                    toAddresses.add('endorsements@vantageins.us');
                    toAddresses.add('support@vantageins.us');
                    /*
                    if (message.Chat__r.Endorsement_Request__r.Status__c == 'Submitted' || message.Chat__r.Endorsement_Request__r.Status__c == 'In Process' || message.Chat__r.Endorsement_Request__r.Status__c == 'Completed' || message.Chat__r.Endorsement_Request__r.Status__c == 'Rejected') {
                        toAddresses.add('support@vantageins.us');
                    }
                        */
                } else if (message.Chat__r.Endorsement_Request__r.Process_Owner_p__c == 'Endorsements Team') {
                    //toAddresses.add('royaltyservicesvpn1@gmail.com');
                    toAddresses.add('loyalty@vantageins.us');
                    toAddresses.add('endorsements@vantageins.us');
                    toAddresses.add('support@vantageins.us');
                    /*
                    if (message.Chat__r.Endorsement_Request__r.Status__c == 'Submitted' || message.Chat__r.Endorsement_Request__r.Status__c == 'In Process' || message.Chat__r.Endorsement_Request__r.Status__c == 'Completed' || message.Chat__r.Endorsement_Request__r.Status__c == 'Rejected') {
                        toAddresses.add('support@vantageins.us');
                    }
                        */
                }

                

                // Set recipient and sender information
                /*
                recipientEmail.setToAddresses(new List<String>{ message.Chat__r.Endorsement_Request__r.Opportunity__r.Producer__r.Email, message.Chat__r.Endorsement_Request__r.Opportunity__r.Sales_Supervisor__r.Email });
                recipientEmail.setCcAddresses(new List<String>{ message.Chat__r.Endorsement_Request__r.Opportunity__r.Support_Agent_Email__c, message.Chat__r.Endorsement_Request__r.Opportunity__r.IRM_Agent_Email__c, 'Cfo@vantageins.us', 'Loyalty@vantageins.us' });
                */
                /*
                recipientEmail.setToAddresses(new List<String>{ message.Chat__r.Endorsement_Request__r.Opportunity__r.Producer__r.Email});
                recipientEmail.setCcAddresses(new List<String>{'Loyalty@vantageins.us','endorsements@vantageins.us'});
                */

                recipientEmail.setToAddresses(toAddresses);

                
                recipientEmail.setOrgWideEmailAddressId(orgWideEmailId); // Use org-wide email address
                
                // Set email threading attributes
                recipientEmail.setInReplyTo(threadIdentifier);
                recipientEmail.setReferences(threadIdentifier);

                // Set email subject, including the name of the related Endorsement_Request__c record
                String subject = 'New Message in a Endorsement for ' + message.Chat__r.Endorsement_Request__r.Company_Name__c + ' DOT# ' + 
                                 message.Chat__r.Endorsement_Request__r.Opportunity__r.USDOT__c + ' - ' + message.Chat__r.Endorsement_Request__r.Subject__c;
                recipientEmail.setSubject(subject);

                // Set email body with sender name, message content, and a link to the related Endorsement_Request__c record
                String body = 'You have received a new message:<br/><br/>' +
                              '<strong>Sender:</strong> ' + message.Sender__r.Name + '<br/>' +
                              '<strong>Message:</strong> ' + message.Body__c + '<br/><br/>' +
                              'View the related Endorsement Request here: <a href="' + 
                              baseUrl + '/' + message.Chat__r.Endorsement_Request__c + 
                              '">Endorsement Request: ' + message.Chat__r.Endorsement_Request__r.Name + '</a>';
                
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