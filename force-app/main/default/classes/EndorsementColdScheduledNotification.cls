public with sharing class EndorsementColdScheduledNotification {
    
    @InvocableMethod(label='Cold Endorsements Request Email Notification' 
                     description='Queries all Endorsement Requests and sends email notifications for records where Last_Status_Change__c + 20 days >= TODAY')
    public static void sendScheduledStatusChangeEmails(List<String> dummyParameter) {
        
        try {
            // Calculate the date threshold (Today - 20 days)
            Date thresholdDate = Date.today().addDays(-20);
            
            System.debug('Threshold Date (Today - 20 days): ' + thresholdDate);
            
            // Query all Endorsement_Request__c records where Last_Status_Change__c + 20 days >= TODAY
            List<Endorsement_Request__c> endorsementsToNotify = [
                SELECT Id, Name, Company_Name__c, Status__c, Process_Owner_p__c, Last_Status_Change__c,
                       Opportunity__r.Producer__r.Email
                FROM Endorsement_Request__c
                WHERE Last_Status_Change__c != null 
                AND Status__c != 'Completed'
                AND Last_Status_Change__c <= :thresholdDate
                ORDER BY Last_Status_Change__c ASC
            ];
            
            System.debug('Found ' + endorsementsToNotify.size() + ' endorsement requests requiring notification');
            
            if (endorsementsToNotify.isEmpty()) {
                System.debug('No endorsement requests found that meet the 20-day criteria.');
                return;
            }
            
            // Get the org-wide email address ID
            Id orgWideEmailId;
            try {
                orgWideEmailId = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'noreply@vantageins.us' LIMIT 1].Id;
            } catch (QueryException e) {
                System.debug('Org-wide email address not found: ' + e.getMessage());
                // Continue without org-wide email if not found
            }
            
            // Get the base URL
            String baseUrl = URL.getOrgDomainUrl().toExternalForm();
            
            // Prepare list to hold all emails
            List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
            
            // Process each endorsement request
            for (Endorsement_Request__c endorsement : endorsementsToNotify) {
                
                System.debug('Processing endorsement: ' + endorsement.Name + ' - Last Status Change: ' + endorsement.Last_Status_Change__c);
                
                // Calculate days since last status change
                Integer daysSinceChange = Date.today().daysBetween(endorsement.Last_Status_Change__c.date());
                
                // Populate toAddresses based on Process_Owner_p__c
                List<String> toAddresses = getEmailAddresses(endorsement);
                
                if (toAddresses.isEmpty()) {
                    System.debug('No email addresses found for endorsement: ' + endorsement.Name);
                    continue;
                }
                
                // Create the email
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                
                // Set org-wide email address if available
                if (orgWideEmailId != null) {
                    email.setOrgWideEmailAddressId(orgWideEmailId);
                }
                
                email.setToAddresses(toAddresses);
                email.setSubject('Cold Endorsement Request Reminder for '  + endorsement.Company_Name__c + ' - ' + endorsement.Name );
                
                // Create email body
                String emailBody = buildEmailBody(endorsement, daysSinceChange, baseUrl);
                email.setHtmlBody(emailBody);
                
                emailsToSend.add(email);
                
                System.debug('Email prepared for endorsement: ' + endorsement.Name + ' to addresses: ' + toAddresses);
            }
            
            // Send all emails
            if (!emailsToSend.isEmpty()) {
                List<Messaging.SendEmailResult> results = Messaging.sendEmail(emailsToSend);
                
                // Log results
                for (Integer i = 0; i < results.size(); i++) {
                    Messaging.SendEmailResult result = results[i];
                    if (result.isSuccess()) {
                        System.debug('Email sent successfully for endorsement: ' + endorsementsToNotify[i].Name);
                    } else {
                        System.debug('Failed to send email for endorsement: ' + endorsementsToNotify[i].Name + 
                                   ' - Errors: ' + result.getErrors());
                    }
                }
            }
            
        } catch (Exception e) {
            System.debug('Error in sendScheduledStatusChangeEmails: ' + e.getMessage());
            System.debug('Stack trace: ' + e.getStackTraceString());
            throw e;
        }
    }
    
    /**
     * Helper method to determine email addresses based on Process_Owner_p__c
     */
    private static List<String> getEmailAddresses(Endorsement_Request__c endorsement) {
        List<String> toAddresses = new List<String>();
        
        if (endorsement.Process_Owner_p__c == 'Sales Team') {
            if (endorsement.Opportunity__r != null && endorsement.Opportunity__r.Producer__r != null && 
                String.isNotBlank(endorsement.Opportunity__r.Producer__r.Email)) {
                toAddresses.add(endorsement.Opportunity__r.Producer__r.Email);
            }
            toAddresses.add('loyalty@vantageins.us');
            toAddresses.add('endorsements@vantageins.us');
            toAddresses.add('support@vantageins.us');
            
        } else if (endorsement.Process_Owner_p__c == 'Loyalty Team') {
            toAddresses.add('loyalty@vantageins.us');
            toAddresses.add('endorsements@vantageins.us');
            toAddresses.add('support@vantageins.us');
            
        } else if (endorsement.Process_Owner_p__c == 'Endorsements Team') {
            toAddresses.add('loyalty@vantageins.us');
            toAddresses.add('endorsements@vantageins.us');
            toAddresses.add('support@vantageins.us');
        }
        
        return toAddresses;
    }

    

    
/*
    private static List<String> getEmailAddresses(Endorsement_Request__c endorsement) {
        List<String> toAddresses = new List<String>();
        toAddresses.add('techcenter@vantageins.us');

        return toAddresses;
    }
       */ 
    
    /**
     * Helper method to build the email body
     */
    private static String buildEmailBody(Endorsement_Request__c endorsement, Integer daysSinceChange, String baseUrl) {
        String emailBody = '<html><body>';
        emailBody += '<h2>Cold Endorsement Request Reminder</h2>';
        emailBody += '<p>This is an automated reminder that an endorsement request requires attention due to no status change in the past 20 days.</p>';
        emailBody += '<br/>';
        emailBody += '<table border="1" cellpadding="5" cellspacing="0" style="border-collapse: collapse;">';
        emailBody += '<tr><td><strong>Endorsement Name:</strong></td><td>' + (endorsement.Name != null ? endorsement.Name : '') + '</td></tr>';
        emailBody += '<tr><td><strong>Company Name:</strong></td><td>' + (endorsement.Company_Name__c != null ? endorsement.Company_Name__c : '') + '</td></tr>';
        emailBody += '<tr><td><strong>Current Status:</strong></td><td>' + (endorsement.Status__c != null ? endorsement.Status__c : '') + '</td></tr>';
        emailBody += '<tr><td><strong>Process Owner:</strong></td><td>' + (endorsement.Process_Owner_p__c != null ? endorsement.Process_Owner_p__c : '') + '</td></tr>';
        emailBody += '<tr><td><strong>Last Status Change:</strong></td><td>' + (endorsement.Last_Status_Change__c != null ? endorsement.Last_Status_Change__c.format() : '') + '</td></tr>';
        emailBody += '<tr><td><strong>Days Since Last Change:</strong></td><td>' + daysSinceChange + ' days</td></tr>';
        emailBody += '</table>';
        emailBody += '<br/>';
        emailBody += '<p><a href="' + baseUrl + '/lightning/r/Endorsement_Request__c/' + endorsement.Id + '/view">Click here to view the endorsement request</a></p>';
        emailBody += '<br/>';
        emailBody += '<p>Please review and update the status as appropriate.</p>';
        emailBody += '<p><em>This is an automated message. Please do not reply to this email.</em></p>';
        emailBody += '</body></html>';
        
        return emailBody;
    }
}