public with sharing class OppWavixCallsController {
    public class WavixCallLogWrapper {
        @AuraEnabled public String callDate;
        @AuraEnabled public String fromNumber;
        @AuraEnabled public String toNumber;
        @AuraEnabled public String duration;
        @AuraEnabled public String charge;
        @AuraEnabled public String destination;
        @AuraEnabled public String producerName; // New field for producer name

        public WavixCallLogWrapper(String callDate, String fromNumber, String toNumber, String duration, String charge, String destination, String producerName) {
            this.callDate = callDate;
            this.fromNumber = fromNumber;
            this.toNumber = toNumber;
            this.duration = duration;
            this.charge = charge;
            this.destination = destination;
            this.producerName = producerName; // Set producer name
        }
    }

    @AuraEnabled(cacheable=true)
    //public static List<WavixCallLogWrapper> getWavixCallLogs(String oppPhone, String fromDate, String toDate) {
    public static List<WavixCallLogWrapper> getWavixCallLogs(String oppPhone) {
        List<WavixCallLogWrapper> wavixLogs = new List<WavixCallLogWrapper>();
        String apiKey = 'fc33990728080c76f9676afd661029e1178a651832e9a581c5357bd8b42abc63';   
        
        //Date dtoToday = Date.today();
        //Date dfromToday = dtoToday.addDays(-30);
        //String toDate = dtoToday.year() + '-' + dtoToday.month() + '-' + dtoToday.day();
        //String fromDate = dfromToday.year() + '-' + dfromToday.month() + '-' + dfromToday.day();

        //String fromDate = '2024-11-01';
        //String toDate = '2024-11-30';

        Date currentDate = Date.today();
        Date sixMonthsBackDate = currentDate.addMonths(-6);

        String fromDate = String.valueOf(sixMonthsBackDate);
        String toDate = String.valueOf(currentDate);

        String url = 'https://api.wavix.com/v1/cdr?type=placed&from=' + fromDate + '&to=' + toDate + '&to_search=' + EncodingUtil.urlEncode(oppPhone, 'UTF-8') + '&per_page=100&appid=' + apiKey;
        
        try {
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(url);
            request.setMethod('GET');
            //request.setHeader('Authorization', 'Bearer ' + apiKey);

            HttpResponse response = http.send(request);

            if (response.getStatusCode() == 200) {
                Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                List<Object> items = (List<Object>) results.get('items');

                // Create a map to hold Contacts by Twilio number for faster lookup
                Map<String, String> contactProducerMap = new Map<String, String>();
                for (Contact c : [SELECT Id, Name, Producer_W_Number__c FROM Contact WHERE Producer_W_Number__c != NULL]) {
                    contactProducerMap.put(c.Producer_W_Number__c, c.Name);
                }

                for (Object itemObj : items) {
                    Map<String, Object> item = (Map<String, Object>) itemObj;
                    String callDate = (String) item.get('date');
                    String fromNumber = (String) item.get('from');
                    String toNumber = (String) item.get('to');
                    String duration = String.valueOf(item.get('duration'));  // Convert to String
                    String charge = (String) item.get('charge');
                    String destination = (String) item.get('destination');

                    // Retrieve the producer name based on the fromNumber
                    String producerName = contactProducerMap.get(fromNumber);

                    // If no producer found, set as 'Unknown'
                    if (producerName == null) {
                        producerName = 'Unknown';
                    }

                    // Create the wrapper and add to the list
                    WavixCallLogWrapper log = new WavixCallLogWrapper(callDate, fromNumber, toNumber, duration, charge, destination, producerName);
                    wavixLogs.add(log);
                }
            } else {
                throw new AuraHandledException('Failed to retrieve call logs from Wavix: ' + response.getStatus());
            }
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving Wavix call logs: ' + e.getMessage());
        }

        return wavixLogs;
    }
}