public with sharing class EndorsementCovVehicleTableLWCController {
    @AuraEnabled(cacheable=true)
    public static List<Endorsement_Vehicle__c> getVehicles(Id endorsementRequestId) {
        return [
            SELECT Id, Name, Vehicle__r.Name, Action__c, Vehicle__r.Value__c, New_Value__c, New_VIN__c, New_Weight__c, New_Year__c,
                   Vehicle__r.Weight__c, Vehicle__r.Make__r.Name, Vehicle__r.Year__c
            FROM Endorsement_Vehicle__c
            WHERE Endorsement_Request__c = :endorsementRequestId
        ];
    }

    @AuraEnabled
    public static void updateVehicles(List<Endorsement_Vehicle__c> vehiclesToUpdate) {
        update vehiclesToUpdate;
    }
}