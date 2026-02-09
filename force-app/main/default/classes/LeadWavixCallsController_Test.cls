@IsTest
public class LeadWavixCallsController_Test {
    @IsTest
    static void testGetWavixCallLogs() {
        // Setup: Create test data
        Contact contact1 = new Contact(
            FirstName = 'John',
            LastName = 'Doe',
            Producer_W_Number__c = '+1234567890'
        );
        insert contact1;

        Contact contact2 = new Contact(
            FirstName = 'Jane',
            LastName = 'Smith',
            Producer_W_Number__c = '+0987654321'
        );
        insert contact2;

        // Mock HTTP response for Wavix API
        Test.setMock(HttpCalloutMock.class, new WavixCallLogMock());

        // Call the controller method
        Test.startTest();
        List<LeadWavixCallsController.WavixCallLogWrapper> logs = LeadWavixCallsController.getWavixCallLogs(
            '+1234567890' // leadPhone
            //'2024-01-01',  // fromDate
            //'2024-01-31'   // toDate
        );
        Test.stopTest();

        // Assertions
        System.assertNotEquals(null, logs, 'Logs should not be null');
        System.assertEquals(2, logs.size(), 'There should be two logs returned');

        // Validate the first log
        System.assertEquals('+1234567890', logs[0].fromNumber, 'First log should have the correct fromNumber');
        System.assertEquals('John Doe', logs[0].producerName, 'First log should have the correct producer name');

        // Validate the second log
        System.assertEquals('+0987654321', logs[1].fromNumber, 'Second log should have the correct fromNumber');
        System.assertEquals('Jane Smith', logs[1].producerName, 'Second log should have the correct producer name');
    }

    // Mock class for HTTP Callout
    private class WavixCallLogMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Mock response body
            String responseBody = '{"items":[{' +
                '"date":"2024-01-15",' +
                '"from":"+1234567890",' +
                '"to":"+1123456789",' +
                '"duration":"120",' +
                '"charge":"0.50",' +
                '"destination":"USA"' +
                '},{' +
                '"date":"2024-01-20",' +
                '"from":"+0987654321",' +
                '"to":"+1987654321",' +
                '"duration":"300",' +
                '"charge":"1.00",' +
                '"destination":"Canada"' +
                '}]}';

            // Mock HTTP response
            HttpResponse response = new HttpResponse();
            response.setStatusCode(200);
            response.setBody(responseBody);
            return response;
        }
    }
}