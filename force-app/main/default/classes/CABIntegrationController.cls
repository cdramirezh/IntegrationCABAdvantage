public with sharing class CABIntegrationController {
    
    // Clase wrapper para mapear la respuesta del bot
    public class CABResponse {
        public CarrierData carrierData;
    }
    public class CarrierData {
        public String carrierName;
    }

    @AuraEnabled
    public static String searchCarrier(String dot) {
        Integer maxTimeout = 120 * 1000; // seconds
        // This has to be configured as a Named Credential to the CAB Advantage BOT Middleware Server
        String cabAdvantageBotEndpoint = 'https://royalty-bot-production.up.railway.app/get_carrier_data?dot=';

        // 1. Buscar si ya existe un Lead con ese DOT
        if (!Schema.sObjectType.Lead.isAccessible()) {
            throw new AuraHandledException('Insufficient privileges to access Lead records.');
        }
        
        List<Lead> existingLeads = [SELECT Id FROM Lead WHERE USDOT__c = :dot LIMIT 1];
        if (!existingLeads.isEmpty()) {
            // Devolvemos el ID para que el LWC pueda redirigir
            return 'REDIRECT:' + existingLeads[0].Id;
        }

        // 2. Simulación de validación de DOT (ej. debe tener entre 5 y 8 dígitos)
        if (dot.length() < 5 || dot.length() > 8) {
            throw new AuraHandledException('El número DOT proporcionado no es válido.');
        }

        try {
            // 3. Configuración del Callout (Simulado por ahora)
            // En un escenario real, aquí descomentarías el http.send(request)
            

            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint( cabAdvantageBotEndpoint + dot);
            request.setMethod('GET');
            request.setTimeout(maxTimeout);

            HttpResponse response = http.send(request);
            
            if (response.getStatusCode() != 200) {
                System.debug('Error response: ' + response.getBody());
                throw new AuraHandledException('Error from server: ' + response.getStatus());
            }
            
            // 4. Deserializar la respuesta
            CABResponse responseData = (CABResponse) JSON.deserialize(response.getBody(), CABResponse.class);
            
            if (responseData.carrierData == null || String.isBlank(responseData.carrierData.carrierName)) {
                throw new AuraHandledException('La respuesta del bot no contiene información válida del carrier.');
            }

            // 5. Crear el Lead con campos constantes y dinámicos
            if (!Schema.sObjectType.Lead.isCreateable()) {
                throw new AuraHandledException('Insufficient privileges to create Lead records.');
            }
            
            Lead newLead = new Lead();
            newLead.USDOT__c = dot; // Asegúrate de tener este campo en Lead
            newLead.Company = responseData.carrierData.carrierName; // Dinámico del bot
            newLead.LastName = responseData.carrierData.carrierName; // Requerido: usamos el nombre del carrier
            newLead.Owner_DOB__c = Date.newInstance(1980, 1, 1); // Constante por ahora
            newLead.Status = 'Unqualified';
            
            insert newLead;

            return newLead.Id;

        } catch (Exception e) {
            throw new AuraHandledException('Error procesando el carrier: ' + e.getMessage());
        }
    }
}