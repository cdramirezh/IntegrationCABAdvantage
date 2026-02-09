public with sharing class FinReqNewMessageEmailNotificationAction {
    @InvocableMethod(label='Finance Req New Message Email Notification' description='Sends an email notification based on Message__c record')
    public static void sendEmail(List<Id> messageIds) {
        // Retrieve the org-wide email address ID for noreply@vantageins.us
        Id orgWideEmailId = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'noreply@vantageins.us' LIMIT 1].Id;

        // Retrieve the instance URL
        String baseUrl = URL.getOrgDomainUrl().toExternalForm();

        // Retrieve Message__c records with related Finance_Request__c details
        List<Message__c> messages = [
            SELECT Id, Body__c, Sender__r.Name, Sender__r.Email,
            
                    Chat__r.Finance_Request__r.Name, Chat__r.Finance_Request__c, Chat__r.Finance_Request__r.Company_Name__c, Chat__r.Finance_Request__r.RecordType.Name,
                    Chat__r.Finance_Request__r.Policy_Draft__r.Producer__r.Email, 
                    Chat__r.Finance_Request__r.Policy_Draft__r.Sales_Supervisor__c,
                    //Chat__r.Finance_Request__r.Policy_Draft__r.IRM_Agent_Email__c, Chat__r.Finance_Request__r.Policy_Draft__r.Support_Agent_Email__c,

                    Chat__r.Finance_Request__r.Endorsement_Request__r.Opportunity__r.Producer__r.Email,
                    Chat__r.Finance_Request__r.Endorsement_Request__r.Opportunity__r.Sales_Supervisor__c
                    /*, Chat__r.Finance_Request__r.Endorsement_Request__r.Opportunity__r.Sales_Supervisor__r.Email,
                    Chat__r.Finance_Request__r.Endorsement_Request__r.Opportunity__r.IRM_Agent_Email__c, Chat__r.Finance_Request__r.Endorsement_Request__r.Opportunity__r.Support_Agent_Email__c
                    */
                    
            FROM Message__c 
            WHERE Id IN :messageIds
        ];
        
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

        for (Message__c message : messages) {
            // Validate if Producer_Email__c field has a value
            if (String.isNotBlank(message.Chat__r.Finance_Request__r.Endorsement_Request__r.Opportunity__r.Producer__r.Email) || String.isNotBlank(message.Chat__r.Finance_Request__r.Policy_Draft__r.Producer__r.Email)) {
                // Create email message to notify the recipients
                Messaging.SingleEmailMessage recipientEmail = new Messaging.SingleEmailMessage();
                
                String subjectFilter = 'New Message in a Finance Request for ' + message.Chat__r.Finance_Request__r.Company_Name__c;
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
                List<String> ccAddresses = new List<String>();
        
                if (message.Chat__r.Finance_Request__r.Policy_Draft__r != null) {
                    toAddresses.add(message.Chat__r.Finance_Request__r.Policy_Draft__r.Producer__r.Email);
                    toAddresses.add(message.Chat__r.Finance_Request__r.Policy_Draft__r.Sales_Supervisor__c);
                    //toAddresses.add(message.Chat__r.Finance_Request__r.Policy_Draft__r.Sales_Supervisor__r.Email);
                    toAddresses.add('cfo@vantageins.us');
                    //ccAddresses.add(message.Chat__r.Finance_Request__r.Policy_Draft__r.IRM_Agent_Email__c);
                } else if (message.Chat__r.Finance_Request__r.Endorsement_Request__r != null) {
                    toAddresses.add(message.Chat__r.Finance_Request__r.Endorsement_Request__r.Opportunity__r.Producer__r.Email);                    
                    toAddresses.add(message.Chat__r.Finance_Request__r.Endorsement_Request__r.Opportunity__r.Sales_Supervisor__c);
                    //toAddresses.add(message.Chat__r.Finance_Request__r.Policy_Draft__r.Sales_Supervisor__r.Email);
                    toAddresses.add('cfo@vantageins.us');
                    toAddresses.add('Loyalty@vantageins.us');
                }     

                // Set recipient and sender information
                recipientEmail.setToAddresses(toAddresses);
                //recipientEmail.setCcAddresses(ccAddresses);
                /*
                recipientEmail.setToAddresses(new List<String>{ message.Chat__r.Finance_Request__r.Policy_Draft__r.Producer__r.Email,
                                                                message.Chat__r.Finance_Request__r.Policy_Draft__r.Sales_Supervisor__r.Email });
                recipientEmail.setCcAddresses(new List<String>{ message.Chat__r.Finance_Request__r.Policy_Draft__r.Support_Agent_Email__c,
                                                                message.Chat__r.Finance_Request__r.Policy_Draft__r.IRM_Agent_Email__c });
                                                                */

                recipientEmail.setOrgWideEmailAddressId(orgWideEmailId); // Use org-wide email address
                
                // Set email threading attributes
                recipientEmail.setInReplyTo(threadIdentifier);
                recipientEmail.setReferences(threadIdentifier);

                // Set email subject, including the name of the related Finance_Request__c record
                String subject = 'New Message in a Finance Request for ' + message.Chat__r.Finance_Request__r.Company_Name__c;
                recipientEmail.setSubject(subject);

                // Set email body with sender name, message content, and a link to the related Finance_Request__c record
                String body = 'You have received a new message in a ' + message.Chat__r.Finance_Request__r.RecordType.Name +' request:<br/><br/>' +
                              '<strong>Sender:</strong> ' + message.Sender__r.Name + '<br/>' +
                              '<strong>Message:</strong> ' + message.Body__c + '<br/><br/>' +
                              'View the related Finance Request here: <a href="' + 
                              baseUrl + '/' + message.Chat__r.Finance_Request__c + 
                              '"> ' + message.Chat__r.Finance_Request__r.Name + '</a>';
                
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