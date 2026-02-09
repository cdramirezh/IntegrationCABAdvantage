public with sharing class EndorsementStatusChangeNotification {
    @InvocableMethod(label='Endorsement Request Status Chage Email Notification Action' 
                     description='Sends an email notification for an Endorsement Request')
    public static void sendEmail(List<Id> endorsementRequestIds) {
        if (endorsementRequestIds == null || endorsementRequestIds.isEmpty()) {
            System.debug('No Endorsement Request ID provided. Exiting method.');
            return;
        }

        Id endorsementRequestId = endorsementRequestIds[0]; // Only one expected

        // Retrieve the org-wide email address ID for noreply@vantageins.us
        Id orgWideEmailId = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'noreply@vantageins.us' LIMIT 1].Id;

        // Retrieve the instance URL
        String baseUrl = URL.getOrgDomainUrl().toExternalForm();

        // Retrieve the Endorsement_Request__c record
        Endorsement_Request__c endorsement = [
            SELECT Name, Company_Name__c, Status__c, Process_Owner_p__c, Opportunity__r.Producer__r.Email                   
            FROM Endorsement_Request__c
            WHERE Id = :endorsementRequestId
            LIMIT 1
        ];
            
        // Populate toAddresses
        List<String> toAddresses = new List<String>();

        if (endorsement.Process_Owner_p__c == 'Sales Team') {
            if (endorsement.Opportunity__r != null && endorsement.Opportunity__r.Producer__r != null && 
                String.isNotBlank(endorsement.Opportunity__r.Producer__r.Email)) {
                toAddresses.add(endorsement.Opportunity__r.Producer__r.Email);
            }
            //toAddresses.add('piztekweb@gmail.com');
            toAddresses.add('loyalty@vantageins.us');
            toAddresses.add('endorsements@vantageins.us');
            toAddresses.add('support@vantageins.us');
            /*
            if (endorsement.Status__c == 'Submitted' || endorsement.Status__c == 'In Process' || endorsement.Status__c == 'Completed' || endorsement.Status__c == 'Rejected') {
                toAddresses.add('support@vantageins.us');
            }
                */
        } else if (endorsement.Process_Owner_p__c == 'Loyalty Team') {
            //toAddresses.add('royaltyservicesvpn1@gmail.com');
            toAddresses.add('loyalty@vantageins.us');
            toAddresses.add('endorsements@vantageins.us');
            toAddresses.add('support@vantageins.us');
            /*
            if (endorsement.Status__c == 'Submitted' || endorsement.Status__c == 'In Process' || endorsement.Status__c == 'Completed' || endorsement.Status__c == 'Rejected') {
                toAddresses.add('support@vantageins.us');
            }
                */
        } else if (endorsement.Process_Owner_p__c == 'Endorsements Team') {
            //toAddresses.add('royaltyservicesvpn1@gmail.com');
            toAddresses.add('loyalty@vantageins.us');
            toAddresses.add('endorsements@vantageins.us');
            toAddresses.add('support@vantageins.us');
            /*
            if (endorsement.Status__c == 'Submitted' || endorsement.Status__c == 'In Process' || endorsement.Status__c == 'Completed' || endorsement.Status__c == 'Rejected') {
                toAddresses.add('support@vantageins.us');
            }
                */
        }

        

        // Ensure there are recipients before sending the email
        if (toAddresses.isEmpty()) {
            System.debug('No valid recipients found. Email will not be sent.');
            return;
        }

        String subject = 'New Endorsement Status Change Notification for ' + endorsement.Company_Name__c;

        // Construct the email body
        String body = 'You have a new Endorsement Request Status change to <strong>'+ endorsement.Status__c + '</strong><br/><br/>' +
                      'Check it out here:<br/><br/>' +
                      '<strong>Endorsement Request:</strong> ' + endorsement.Name + 
                      ' for ' + endorsement.Company_Name__c + '<br/><br/>' +
                      '<a href="' + baseUrl + '/' + endorsementRequestId + '">View Endorsement Request</a>';

        // Create and send the email
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(toAddresses);
        //email.setCcAddresses(ccAddresses);
        email.setOrgWideEmailAddressId(orgWideEmailId);
        email.setSubject(subject);
        email.setHtmlBody(body);

        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ email });
    }
}