@isTest
private class CABIntegrationControllerTest {

    // Mock para simular la respuesta de la API externa
    private class CABHttpMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"carrierName": "Test Carrier", "carrierPhone": "123456", "mailingCity": "Miami"}');
            res.setStatusCode(200);
            return res;
        }
    }

    @isTest
    static void testSearchNewCarrier() {
        // Configurar el Mock
        Test.setMock(HttpCalloutMock.class, new CABHttpMock());

        Test.startTest();
        String result = CABIntegrationController.searchCarrier('123456');
        Test.stopTest();

        System.assert(result.contains('REDIRECT_NEW_LEAD'), 'Debería crear un nuevo Lead');
        
        Lead l = [SELECT Company FROM Lead WHERE USDOT__c = '123456' LIMIT 1];
        System.assertEquals('Test Carrier', l.Company);
    }

    @isTest
    static void testExistingLeadRedirect() {
        // Creamos un Lead existente para probar la rama del código de redirección
        Lead existing = new Lead(
            LastName = 'Existing',
            Company = 'Existing Co',
            USDOT__c = '99999',
            Status = 'Open'
        );
        insert existing;

        Test.startTest();
        String result = CABIntegrationController.searchCarrier('99999');
        Test.stopTest();

        System.assertEquals('REDIRECT_LEAD:' + existing.Id, result);
    }

    @isTest
    static void testInvalidDot() {
        try {
            CABIntegrationController.searchCarrier('123'); // Muy corto
            System.assert(false, 'Debería haber lanzado una excepción');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage() != null);
        }
    }
}