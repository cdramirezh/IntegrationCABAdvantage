public with sharing class PolicyDraftBacktoOpenNotification {
    @InvocableMethod(label='Policy Draft Back to Open Email Notification Action' 
                     description='Sends an email notification for a Policy Draft')
    public static void sendEmail(List<Id> policyDraftIds) {
        if (policyDraftIds == null || policyDraftIds.isEmpty()) {
            System.debug('No Policy Draft ID provided. Exiting method.');
            return;
        }

        Id policyDraftId = policyDraftIds[0]; // Since only one ID is expected

        // Retrieve the org-wide email address ID for noreply@vantageins.us
        Id orgWideEmailId = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'noreply@vantageins.us' LIMIT 1].Id;

        // Retrieve the instance URL
        String baseUrl = URL.getOrgDomainUrl().toExternalForm();

        // Retrieve the Policy_Draft__c record
        Policy_Draft__c policyDraft = [
            SELECT Name, Company_Name__c, 
                   Producer__r.Email, Sales_Supervisor_F__c, 
                   Support_Agent_Email_F__c, IRM_Agent_Email_F__c, 
                   Additional_Email_for_Notifications_1__c, Additional_Email_for_Notifications_2__c,
                   Renewal__c
            FROM Policy_Draft__c 
            WHERE Id = :policyDraftId
            LIMIT 1
        ];

        // Populate toAddresses
        List<String> toAddresses = new List<String>();
        if (String.isNotBlank(policyDraft.Producer__r.Email)) {
            toAddresses.add(policyDraft.Producer__r.Email);
        }
        if (String.isNotBlank(policyDraft.Sales_Supervisor_F__c)) {
            toAddresses.add(policyDraft.Sales_Supervisor_F__c);
        }                
        if (policyDraft.Renewal__c == true ) {
            toAddresses.add('loyalty@vantageins.us');
            toAddresses.add('support@vantageins.us');
            toAddresses.add('renewals@vantageins.us');
        } 

        // Populate ccAddresses
        List<String> ccAddresses = new List<String>();
        if (String.isNotBlank(policyDraft.Support_Agent_Email_F__c)) {
            ccAddresses.add(policyDraft.Support_Agent_Email_F__c);
        }
        if (String.isNotBlank(policyDraft.IRM_Agent_Email_F__c)) {
            ccAddresses.add(policyDraft.IRM_Agent_Email_F__c);
        }
        if (String.isNotBlank(policyDraft.Additional_Email_for_Notifications_1__c)) {
            ccAddresses.add(policyDraft.Additional_Email_for_Notifications_1__c);
        }
        if (String.isNotBlank(policyDraft.Additional_Email_for_Notifications_2__c)) {
            ccAddresses.add(policyDraft.Additional_Email_for_Notifications_2__c);
        }

        // Ensure there are recipients before sending the email
        if (toAddresses.isEmpty()) {
            System.debug('No valid recipients found. Email will not be sent.');
            return;
        }

        String subject = 'Policy Draft back to Open Status for ' + policyDraft.Company_Name__c;

        // Create the email message
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(toAddresses);
        email.setCcAddresses(ccAddresses);
        email.setOrgWideEmailAddressId(orgWideEmailId);
        email.setSubject( subject );  
        // Construct the email body
        String body = 'Your Policy Draft have been moved back to Open Status<br/><br/>' +
                      'Check it out here:<br/><br/>' +
                      '<strong>Policy Draft:</strong> ' + policyDraft.Name + 
                      ' for ' + policyDraft.Company_Name__c + '<br/><br/>' +
                      '<a href="' + baseUrl + '/' + policyDraftId + '">View Policy Draft</a>';

        email.setHtmlBody(body);

        // Send the email
        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ email });
    }
}