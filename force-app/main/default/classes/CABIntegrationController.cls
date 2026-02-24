public with sharing class CABIntegrationController {
    
    public class CABResponse {
        public String carrierName;
        public String companyDBA; // Optional
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
        public String stateFiling; // Optional
    }

    @AuraEnabled
    public static String searchCarrier(String dot) {
        String cabAdvantageBotEndpoint = 'https://royalty-bot-production.up.railway.app/get_carrier_data?dot=';

        // 1. Security Check
        if (!Schema.sObjectType.Lead.isAccessible()) {
            throw new AuraHandledException('Insufficient privileges to access Lead records.');
        }
        
        // Check if lead exist and whether it's converted
        List<Lead> existingLeads = [SELECT Id, IsConverted, ConvertedAccountId 
                                    FROM Lead 
                                    WHERE USDOT__c = :dot 
                                    ORDER BY CreatedDate DESC LIMIT 1];

        if (!existingLeads.isEmpty()) {
            Lead foundLead = existingLeads[0];
            
            // If the Lead is converted and has associated Account, redirect to the Account
            if (foundLead.IsConverted && foundLead.ConvertedAccountId != null) {
                return 'REDIRECT_ACCOUNT:' + foundLead.ConvertedAccountId;
            }
            
            // If the Lead is not converted, redirect to the Lead
            return 'REDIRECT_LEAD:' + foundLead.Id;
        }

        // 2. Validación de longitud
        if (dot.length() < 5 || dot.length() > 8) {
            throw new AuraHandledException('El número DOT proporcionado no es válido (debe tener entre 5 y 8 dígitos).');
        }

        try {
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(cabAdvantageBotEndpoint + dot);
            request.setMethod('GET');
            request.setTimeout(120000);
            
            HttpResponse response = http.send(request);
            
            if (response.getStatusCode() != 200) {
                throw new AuraHandledException('Error del bot (' + response.getStatusCode() + '): ' + response.getStatus());
            }
            
            CABResponse data = (CABResponse) JSON.deserialize(response.getBody(), CABResponse.class);
            
            if (data == null || String.isBlank(data.carrierName)) {
                throw new AuraHandledException('El bot no encontró información para el DOT: ' + dot);
            }

            if (!Schema.sObjectType.Lead.isCreateable()) {
                throw new AuraHandledException('Insufficient privileges to create Lead records.');
            }
            
            // Mandatory fields
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

            // 5. Handling opcional fields (Avoid assigning nulls)
            if (String.isNotBlank(data.stateFiling)) {
                newLead.State_Filing__c = data.stateFiling;
            }
            
            if (String.isNotBlank(data.companyDBA)) {
                newLead.DBA__c = data.companyDBA;
            }

            insert newLead;
            return 'REDIRECT_NEW_LEAD:' + newLead.Id;

        } catch (Exception e) {
            throw new AuraHandledException('Error en la integración: ' + e.getMessage());
        }
    }
}