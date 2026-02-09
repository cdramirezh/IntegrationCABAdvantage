@IsTest
public class TwilioSMSLogControllerTest {
    
    // Mock HTTP Response for Twilio API
    private class MockHttpResponseTwilio implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            
            // Mocked JSON response from Twilio
            res.setBody('{"messages":[{"sid":"SM1234567890","date_sent":"2023-10-10T10:00:00Z","from":"+1234567890","to":"+1987654321","body":"Test message 1"},{"sid":"SM0987654321","date_sent":"2023-10-10T11:00:00Z","from":"+0987654321","to":"+1987654321","body":"Test message 2"}]}');
            return res;
        }
    }

    @IsTest
    static void testGetSmsLogs() {
        // Set up test data
        String leadPhone = '+1987654321';
        
        // Create contacts that match the mocked Twilio numbers
        Contact contact1 = new Contact(	FirstName = 'John', LastName = 'Doe', Producer_T_Number__c = '+1234567890');
        Contact contact2 = new Contact(	FirstName = 'Jane', LastName = 'Smith', Producer_T_Number__c = '+0987654321');
        insert new List<Contact>{contact1, contact2};

        // Set up mock response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseTwilio());

        // Test method
        Test.startTest();
        List<TwilioSmsLogController.TwilioSmsLogWrapper> logs = TwilioSmsLogController.getSmsLogs(leadPhone);
        Test.stopTest();

        // Verify results
        System.assertEquals(2, logs.size(), 'The method should return 2 SMS logs');

        // Check the details of the first log
        TwilioSmsLogController.TwilioSmsLogWrapper log1 = logs[0];
        System.assertEquals('SM1234567890', log1.smsSid);
        System.assertEquals('2023-10-10T10:00:00Z', log1.smsDate);
        System.assertEquals('+1234567890', log1.fromNumber);
        System.assertEquals('+1987654321', log1.toNumber);
        System.assertEquals('Test message 1', log1.body);
        System.assertEquals('John Doe', log1.producerName);  // Should match the contact name

        // Check the details of the second log
        TwilioSmsLogController.TwilioSmsLogWrapper log2 = logs[1];
        System.assertEquals('SM0987654321', log2.smsSid);
        System.assertEquals('2023-10-10T11:00:00Z', log2.smsDate);
        System.assertEquals('+0987654321', log2.fromNumber);
        System.assertEquals('+1987654321', log2.toNumber);
        System.assertEquals('Test message 2', log2.body);
        System.assertEquals('Jane Smith', log2.producerName);  // Should match the contact name
    }
}