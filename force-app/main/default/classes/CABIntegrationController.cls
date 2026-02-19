public with sharing class CABIntegrationController {
    
    // Clase wrapper que coincide exactamente con tu payload definitivo
    public class CABResponse {
        public String carrierName;
        public String companyDBA; // Opcional
        public String carrierPhone;
        public String carrierMobile;
        public String carrierEmail;
        public String companyRepresentative;
        public String mailingStreet;
        public String mailingCity;
        public String mailingState;
        public String mailingZIP;
        public String parkingStreet;
        public String parkingCity;
        public String parkingState;
        public String parkingZIP;
        public String federalFiling;
        public String stateFiling; // Opcional
    }

    @AuraEnabled
    public static String searchCarrier(String dot) {
        String cabAdvantageBotEndpoint = 'https://royalty-bot-production.up.railway.app/get_carrier_data?dot=';

        // 1. Validaciones de Seguridad y Duplicados
        if (!Schema.sObjectType.Lead.isAccessible()) {
            throw new AuraHandledException('Insufficient privileges to access Lead records.');
        }
        
        List<Lead> existingLeads = [SELECT Id FROM Lead WHERE USDOT__c = :dot LIMIT 1];
        if (!existingLeads.isEmpty()) {
            return 'REDIRECT:' + existingLeads[0].Id;
        }

        if (dot.length() < 5 || dot.length() > 8) {
            throw new AuraHandledException('El número DOT proporcionado no es válido (debe tener entre 5 y 8 dígitos).');
        }

        try {
            // 2. Llamada al Middleware (Bot)
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            // Asegúrate de usar la Named Credential configurada
            request.setEndpoint(cabAdvantageBotEndpoint + dot);
            request.setMethod('GET');
            request.setTimeout(120000);
            System.debug('--- DEBUG: Llamando al Endpoint: ' + request.getEndpoint());
            HttpResponse response = http.send(request);
            System.debug('--- DEBUG: Status Code: ' + response.getStatusCode());
            System.debug('--- DEBUG: Body Recibido: ' + response.getBody());
            if (response.getStatusCode() != 200) {
                throw new AuraHandledException('Error del bot (' + response.getStatusCode() + '): ' + response.getStatus());
            }
            
            // 3. Deserialización del payload plano
            CABResponse data = (CABResponse) JSON.deserialize(response.getBody(), CABResponse.class);
            System.debug('--- DEBUG: Carrier Name parseado: ' + data.carrierName);
            if (data == null || String.isBlank(data.carrierName)) {
                throw new AuraHandledException('El bot no encontró información para el DOT: ' + dot);
            }

            // 4. Mapeo y Creación del Lead
            if (!Schema.sObjectType.Lead.isCreateable()) {
                throw new AuraHandledException('Insufficient privileges to create Lead records.');
            }
            
            // Campos base y obligatorios
            Lead newLead = new Lead(
                USDOT__c = dot,
                Company = data.carrierName,
                LastName = data.carrierName,
                Phone = data.carrierPhone,
                MobilePhone = data.carrierMobile,
                Email = data.carrierEmail,
                Company_Rep__c = data.companyRepresentative,
                Mailing_Street__c = data.mailingStreet,
                Mailing_City__c = data.mailingCity,
                Mailing_State__c = data.mailingState,
                Mailing_ZIP__c = data.mailingZIP,
                Parking_Street__c = data.parkingStreet,
                Parking_City__c = data.parkingCity,
                Parking_State__c = data.parkingState,
                Parking_ZIP__c = data.parkingZIP,
                Federal_Filing__c = data.federalFiling,
                Status = 'Unqualified'
            );

            // 5. Manejo de campos opcionales (evita asignar nulls)
            if (String.isNotBlank(data.stateFiling)) {
                newLead.State_Filing__c = data.stateFiling;
            }
            
            if (String.isNotBlank(data.companyDBA)) {
                newLead.DBA__c = data.companyDBA;
            }

            insert newLead;
            return newLead.Id;

        } catch (Exception e) {
            System.debug('--- ERROR: ' + e.getMessage());
            System.debug('--- STACKTRACE: ' + e.getStackTraceString());
            throw new AuraHandledException('Error en la integración: ' + e.getMessage());
        }
    }
}