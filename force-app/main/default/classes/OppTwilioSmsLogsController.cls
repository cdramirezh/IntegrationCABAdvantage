public with sharing class OppTwilioSmsLogsController {
    @AuraEnabled(cacheable=true)
    public static List<TwilioSmsLogWrapper> getSmsLogs(String oppPhone) {
        List<TwilioSmsLogWrapper> smsLogs = new List<TwilioSmsLogWrapper>();

        String accountSid = 'ACf8d9d03dd0cb80150185c53b76093d68';
        String authToken = '9b28a93ec8c047663022c60db6b4d1e3';

        try {
            // Twilio API URL for fetching SMS messages
            String url = 'https://api.twilio.com/2010-04-01/Accounts/' + accountSid + '/Messages.json?To=' + EncodingUtil.urlEncode(oppPhone, 'UTF-8') + '&PageSize=20';

            // Create HTTP request
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(url);
            request.setMethod('GET');
            String basicAuth = 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf(accountSid + ':' + authToken));
            request.setHeader('Authorization', basicAuth);

            // Send the request and parse the response
            HttpResponse response = http.send(request);
            if (response.getStatusCode() == 200) {
                Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                List<Object> messages = (List<Object>) results.get('messages');

                // Create a set to store "from" numbers
                Set<String> fromNumbers = new Set<String>();
                for (Object messageObj : messages) {
                    Map<String, Object> message = (Map<String, Object>) messageObj;
                    String fromNumber = (String) message.get('from');
                    fromNumbers.add(fromNumber);
                }

                // Query Contacts with matching Producer_T_Number__c
                Map<String, String> fromNumberToContactName = new Map<String, String>();
                List<Contact> contacts = [
                    SELECT Producer_T_Number__c, Name
                    FROM Contact
                    WHERE Producer_T_Number__c IN :fromNumbers
                ];
                for (Contact contact : contacts) {
                    fromNumberToContactName.put(contact.Producer_T_Number__c, contact.Name);
                }

                // Build SMS log wrapper objects
                for (Object messageObj : messages) {
                    Map<String, Object> message = (Map<String, Object>) messageObj;
                    String smsSid = (String) message.get('sid');
                    String smsDate = (String) message.get('date_sent');
                    String fromNumber = (String) message.get('from');
                    String toNumber = (String) message.get('to');
                    String body = (String) message.get('body');

                    // Get contact name if it exists in the map
                    String producerName = fromNumberToContactName.containsKey(fromNumber) ? fromNumberToContactName.get(fromNumber) : fromNumber;

                    // Create SMS log wrapper
                    TwilioSmsLogWrapper log = new TwilioSmsLogWrapper(smsSid, smsDate, fromNumber, toNumber, body, producerName);
                    smsLogs.add(log);
                }
            } else {
                throw new AuraHandledException('Failed to retrieve SMS logs from Twilio: ' + response.getStatus());
            }
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving SMS logs: ' + e.getMessage());
        }

        return smsLogs;
    }

    // Wrapper class for SMS log data
    public class TwilioSmsLogWrapper {
        @AuraEnabled public String smsSid;
        @AuraEnabled public String smsDate;
        @AuraEnabled public String fromNumber;
        @AuraEnabled public String toNumber;
        @AuraEnabled public String body;
        @AuraEnabled public String producerName;

        public TwilioSmsLogWrapper(String smsSid, String smsDate, String fromNumber, String toNumber, String body, String producerName) {
            this.smsSid = smsSid;
            this.smsDate = smsDate;
            this.fromNumber = fromNumber;
            this.toNumber = toNumber;
            this.body = body;
            this.producerName = producerName;
        }
    }
}