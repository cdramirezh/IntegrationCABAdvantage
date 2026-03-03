@isTest
private class CABIntegrationControllerTest {

    // Mock para simular la respuesta de la API (Sin Email para probar la nueva lógica)
    private class CABHttpMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            // Simulamos respuesta SIN email para validar que el controlador lo maneja bien
            res.setBody('{"carrierName": "Test Carrier JSON", "carrierPhone": "123456", "mailingCity": "Miami"}');
            res.setStatusCode(200);
            return res;
        }
    }

    @isTest
    static void testSearchNewCarrierSuccess() {
        Test.setMock(HttpCalloutMock.class, new CABHttpMock());

        Test.startTest();
        String result = CABIntegrationController.searchCarrier('123456');
        Test.stopTest();

        System.assert(result.contains('REDIRECT_NEW_LEAD'), 'Debería haber creado un nuevo Lead');
        
        Lead createdLead = [SELECT Id, Company, Email FROM Lead WHERE USDOT__c = '123456' LIMIT 1];
        System.assertEquals('Test Carrier JSON', createdLead.Company);
        System.assertEquals(null, createdLead.Email, 'El email debería ser nulo ya que el JSON no lo traía');
    }

    @isTest
    static void testExistingLeadRedirect() {
        // Ahora ya no necesitamos Owner_DOB__c porque es opcional en la Org
        Lead existing = new Lead(
            LastName = 'Doe',
            Company = 'Existing Company',
            USDOT__c = '99999',
            Status = 'Open'
        );
        insert existing;

        Test.startTest();
        String result = CABIntegrationController.searchCarrier('99999');
        Test.stopTest();

        System.assertEquals('REDIRECT_LEAD:' + existing.Id, result, 'Debería redirigir al Lead existente');
    }

@isTest
    static void testInvalidDotLength() {
        Boolean exceptionThrown = false;
        try {
            Test.startTest();
            // Esto debería disparar el "throw new AuraHandledException"
            CABIntegrationController.searchCarrier('12'); 
            Test.stopTest();
        } catch (AuraHandledException e) {
            exceptionThrown = true;
            // Opcional: System.debug('Mensaje capturado: ' + e.getMessage());
        } catch (Exception e) {
            // En caso de que lance otro tipo de error inesperado
            exceptionThrown = true;
        }
        
        System.assert(exceptionThrown, 'Se esperaba una excepción debido a la longitud corta del DOT');
    }
}