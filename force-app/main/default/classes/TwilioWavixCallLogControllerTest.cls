@isTest
public class TwilioWavixCallLogControllerTest {

    // Mock class for the HTTP callout
    private class TwilioCalloutMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            // Mocked JSON response from Twilio API
            String responseBody = '{ "calls": [ ' +
                '{ "sid": "CA1234567890", "start_time": "2024-10-31", "direction": "inbound", "from": "+12345678901", "to": "+10987654321" },' +
                '{ "sid": "CA0987654321", "start_time": "2024-10-30", "direction": "outbound", "from": "+12345678901", "to": "+10987654322" } ] }';

            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody(responseBody);
            response.setStatusCode(200);
            return response;
        }
    }

    @testSetup
    static void setupTestData() {
        // Create a test Contact with Twilio number
        Contact testContact = new Contact(
            LastName = 'Test Producer',
            Twilio_Number__c = '+12345678901'
        );
        insert testContact;
    }

    @isTest
    static void testGetCallLogs() {
        // Set the mock response
        Test.setMock(HttpCalloutMock.class, new TwilioCalloutMock());

        // Retrieve the test contact
        Contact testContact = [SELECT Id, Twilio_Number__c FROM Contact WHERE LastName = 'Test Producer' LIMIT 1];

        // Start test execution
        Test.startTest();
        // Call the controller method
        List<TwilioWavixCallLogController.TwilioCallLogWrapper> callLogs = TwilioWavixCallLogController.getCallLogs(testContact.Twilio_Number__c);
        Test.stopTest();

        // Validate the response
        System.assertNotEquals(null, callLogs, 'Call logs should not be null.');
        System.assertEquals(2, callLogs.size(), 'There should be two call logs.');

        // Validate details for each call log
        TwilioWavixCallLogController.TwilioCallLogWrapper log1 = callLogs[0];
        System.assertEquals('CA1234567890', log1.callSid, 'SID should match the first mock call.');
        System.assertEquals('2024-10-31', log1.callDate, 'Date should match the first mock call.');
        System.assertEquals('inbound', log1.direction, 'Direction should match the first mock call.');
        System.assertEquals('+12345678901', log1.fromNumber, 'From number should match the first mock call.');
        System.assertEquals('+10987654321', log1.toNumber, 'To number should match the first mock call.');
        System.assertEquals('Test Producer', log1.producerName, 'Producer name should match the contact.');

        TwilioWavixCallLogController.TwilioCallLogWrapper log2 = callLogs[1];
        System.assertEquals('CA0987654321', log2.callSid, 'SID should match the second mock call.');
        System.assertEquals('2024-10-30', log2.callDate, 'Date should match the second mock call.');
        System.assertEquals('outbound', log2.direction, 'Direction should match the second mock call.');
        System.assertEquals('+12345678901', log2.fromNumber, 'From number should match the second mock call.');
        System.assertEquals('+10987654322', log2.toNumber, 'To number should match the second mock call.');
    }
}