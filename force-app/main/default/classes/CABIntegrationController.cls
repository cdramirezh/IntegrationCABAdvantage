public with sharing class CABIntegrationController {
    
    @AuraEnabled
    public static String searchCarrier(String dot) {
        Integer maxTimeout = 120 * 1000; // seconds
        // This has to be configured as a Named Credential to the CAB Advantage BOT Middleware Server
        String cabAdvantageBotEndpoint = 'callout:MyMiddlewareServer/search?dot=';
        try {
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint( cabAdvantageBotEndpoint + dot);
            request.setMethod('GET');
            request.setTimeout(maxTimeout);

            // HttpResponse response = http.send(request);
            
            // if (response.getStatusCode() == 200) {
            //     return response.getBody();
            // } else {
            //     throw new AuraHandledException('Error from server: ' + response.getStatus());
            // }

            return 'Mocked response for DOT: ' + dot;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}