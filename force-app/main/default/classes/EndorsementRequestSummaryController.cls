public with sharing class EndorsementRequestSummaryController {
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getEndorsementSummary(Id endorsementRequestId) {
        Map<String, Object> result = new Map<String, Object>();

        // Retrieve related Policies
        List<Endorsement_Policy__c> policies = [
            SELECT Id, Policy__c, Policy__r.Name FROM Endorsement_Policy__c WHERE Endorsement_Request__c = :endorsementRequestId
        ];
        result.put('policies', policies);

        // Retrieve related Coverages (Only show if New_Limit__c or New_Deductible__c is populated)
        List<Endorsement_Coverage__c> coverages = [
            //SELECT Id, Coverage__c, Coverage__r.Name, Coverage__r.Coverage_Product__r.Name, New_Limit__c, New_Deductible__c
            SELECT Id, Coverage__c, Coverage__r.Name, 
                    Coverage__r.Coverage_Product__r.Name, 
                    Coverage__r.Limit__c, Coverage__r.Deductible__c, 
                    New_Limit__c, New_Deductible__c
            FROM Endorsement_Coverage__c 
            WHERE Endorsement_Request__c = :endorsementRequestId 
            //AND (New_Limit__c != null OR New_Deductible__c != null)
        ];
        result.put('coverages', coverages);

        // Initialize grouped records
        Map<String, List<SObject>> groupedData = new Map<String, List<SObject>>();
        for (String action : new List<String>{'Add', 'Delete', 'Modify'}) {
            groupedData.put(action, new List<SObject>());
        }

        // Retrieve Vehicles grouped by Action__c (filtering out null values)
        for (Endorsement_Vehicle__c vehicle : [
            //SELECT Id, Vehicle__c, Vehicle__r.Name, Action__c
            SELECT Id, Vehicle__c, Vehicle__r.Name, Vehicle__r.Value__c, Vehicle__r.Weight__c,
                    New_Value__c, New_VIN__c, New_Weight__c, Action__c  
            FROM Endorsement_Vehicle__c 
            WHERE Endorsement_Request__c = :endorsementRequestId AND Vehicle__c != null
        ]) {
            groupedData.get(vehicle.Action__c).add(vehicle);
        }

        // Retrieve Trailers grouped by Action__c (filtering out null values)
        for (Endorsement_Trailer__c trailer : [
            SELECT Id, Trailer__c, Trailer__r.Name, Trailer__r.Value__c, Trailer__r.Weight__c,
            New_Value__c, New_VIN__c, New_Weight__c, Action__c 
            FROM Endorsement_Trailer__c 
            WHERE Endorsement_Request__c = :endorsementRequestId AND Trailer__c != null
        ]) {
            groupedData.get(trailer.Action__c).add(trailer);
        }

        // Retrieve Drivers grouped by Action__c (filtering out null values)
        for (Endorsement_Driver__c driver : [
            SELECT Id, Driver__c, Driver__r.Name, Driver__r.CDL__c, Driver__r.Experience__c, New_Driver_Name__c, New_CDL__c, Experience__c, Action__c 
            FROM Endorsement_Driver__c 
            WHERE Endorsement_Request__c = :endorsementRequestId AND Driver__c != null
        ]) {
            groupedData.get(driver.Action__c).add(driver);
        }

        result.put('vehicles', groupedData);
        result.put('trailers', groupedData);
        result.put('drivers', groupedData);

        return result;
    }
}