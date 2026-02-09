public with sharing class OppTwilioCallsController {
    @AuraEnabled(cacheable=true)
    public static List<TwilioCallLogWrapper> getCallLogs(String oppPhone) {
        List<TwilioCallLogWrapper> callLogs = new List<TwilioCallLogWrapper>();

        // Twilio credentials from custom settings (replace with your method of storing credentials)
        String accountSid = 'ACf8d9d03dd0cb80150185c53b76093d68';
        String authToken = '9b28a93ec8c047663022c60db6b4d1e3';

        try {
            // Prepare the Twilio API endpoint
            String url = 'https://api.twilio.com/2010-04-01/Accounts/' + accountSid + '/Calls.json?To=' + EncodingUtil.urlEncode(oppPhone, 'UTF-8') + '&PageSize=20';

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
                List<Object> calls = (List<Object>) results.get('calls');
                
                // Create a Set to store Twilio numbers for querying
                Set<String> twilioNumbers = new Set<String>();
                
                for (Object callObj : calls) {
                    Map<String, Object> call = (Map<String, Object>) callObj;
                    String fromNumber = (String) call.get('from');  // Retrieve From field
                    twilioNumbers.add(fromNumber);  // Collect Twilio numbers
                }

                // Query Contact records with Producer_T_Number__c not empty
                List<Contact> contacts = [
                    SELECT Id, Name, Producer_T_Number__c 
                    FROM Contact 
                    WHERE Producer_T_Number__c != null AND Producer_T_Number__c IN :twilioNumbers
                ];

                // Create a map to store Twilio numbers and corresponding contact names
                Map<String, String> twilioNumberToNameMap = new Map<String, String>();
                for (Contact contact : contacts) {
                    twilioNumberToNameMap.put(contact.Producer_T_Number__c, contact.Name);
                }

                // Build the call log wrapper objects
                for (Object callObj : calls) {
                    Map<String, Object> call = (Map<String, Object>) callObj;
                    String callSid = (String) call.get('sid');
                    String callDate = (String) call.get('start_time');
                    String direction = (String) call.get('direction');
                    String fromNumber = (String) call.get('from');  // Retrieve From field
                    String toNumber = (String) call.get('to');      // Retrieve To field

                    // Get the Producer Name from the map if it exists
                    String producerName = twilioNumberToNameMap.containsKey(fromNumber) ? twilioNumberToNameMap.get(fromNumber) : null;

                    // Create the call log wrapper object
                    TwilioCallLogWrapper log = new TwilioCallLogWrapper(callSid, callDate, direction, fromNumber, toNumber, producerName);
                    callLogs.add(log);
                }
            } else {
                throw new AuraHandledException('Failed to retrieve call logs from Twilio: ' + response.getStatus());
            }
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving call logs: ' + e.getMessage());
        }

        return callLogs;
    }

    public class TwilioCallLogWrapper {
        @AuraEnabled public String callSid;
        @AuraEnabled public String callDate;
        @AuraEnabled public String direction;
        @AuraEnabled public String fromNumber; // Renamed field for 'from' number
        @AuraEnabled public String toNumber;   // Renamed field for 'to' number
        @AuraEnabled public String producerName; // Added Producer Name

        public TwilioCallLogWrapper(String callSid, String callDate, String direction, String fromNumber, String toNumber, String producerName) {
            this.callSid = callSid;
            this.callDate = callDate;
            this.direction = direction;
            this.fromNumber = fromNumber;  // Initialize from number
            this.toNumber = toNumber;      // Initialize to number
            this.producerName = producerName; // Initialize Producer Name
        }
    }
}