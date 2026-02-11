public with sharing class CABIntegrationController {
    
    // Clase wrapper optimizada para el nuevo payload
    public class CABResponse {
        public String carrierName;
        public List<PhoneData> carrierPhone;
        public List<String> carrierEmail;
        public List<String> companyRepresentative;
        public String mailingStreet;
        public String mailingCity;
        public String mailingState;
        public String mailingZIP;
        public String parkingStreet;
        public String parkingCity;
        public String parkingState;
        public String parkingZIP;
        public String federalFiling;
        public String stateFiling;
    }

    public class PhoneData {
        public String phoneNumber;
        public List<String> types;
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
            return 'REDIRECT:' + existingLeads[0].Id;
        }

        if (dot.length() < 5 || dot.length() > 8) {
            throw new AuraHandledException('El número DOT proporcionado no es válido.');
        }

        try {
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint( cabAdvantageBotEndpoint + dot);
            request.setMethod('GET');
            request.setTimeout(maxTimeout);

            HttpResponse response = http.send(request);
            
            if (response.getStatusCode() != 200) {
                throw new AuraHandledException('Error del bot (' + response.getStatusCode() + '): ' + response.getStatus());
            }
            
            // Deserializar la respuesta
            CABResponse data = (CABResponse) JSON.deserialize(response.getBody(), CABResponse.class);
            
            if (data == null || String.isBlank(data.carrierName)) {
                throw new AuraHandledException('El bot no devolvió datos para este DOT.');
            }

            // 4. Mapeo y Creación del Lead
            if (!Schema.sObjectType.Lead.isCreateable()) {
                throw new AuraHandledException('Insufficient privileges to create Lead records.');
            }
            
            Lead newLead = new Lead(
                USDOT__c = dot,
                Company = data.carrierName,
                LastName = data.carrierName,
                Status = 'Unqualified',
                Owner_DOB__c = Date.newInstance(1980, 1, 1),
                Mailing_Street__c = data.mailingStreet,
                Mailing_City__c = data.mailingCity,
                Mailing_State__c = data.mailingState,
                Mailing_ZIP__c = data.mailingZIP,
                Parking_Street__c = data.parkingStreet,
                Parking_City__c = data.parkingCity,
                Parking_State__c = data.parkingState,
                Parking_ZIP__c = data.parkingZIP,
                Federal_Filing__c = data.federalFiling,
                State_Filing__c = data.stateFiling
            );

            // Mapeo de listas (Email y Representante)
            if (data.carrierEmail != null && !data.carrierEmail.isEmpty()) {
                newLead.Email = data.carrierEmail[0];
            }
            if (data.companyRepresentative != null && !data.companyRepresentative.isEmpty()) {
                newLead.Company_Rep__c = data.companyRepresentative[0];
            }

            // Mapeo de Teléfonos por Tipo
            if (data.carrierPhone != null) {
                for (PhoneData p : data.carrierPhone) {
                    if (newLead.MobilePhone == null && p.types.contains('cell')) {
                        newLead.MobilePhone = p.phoneNumber;
                    }
                    if (newLead.Phone == null && p.types.contains('phone')) {
                        newLead.Phone = p.phoneNumber;
                    }
                }
            }
            
            insert newLead;

            return newLead.Id;

        } catch (Exception e) {
            throw new AuraHandledException('Error procesando el carrier: ' + e.getMessage());
        }
    }
}