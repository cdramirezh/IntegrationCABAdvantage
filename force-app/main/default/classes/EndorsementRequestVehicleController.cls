public with sharing class EndorsementRequestVehicleController {
    @AuraEnabled(cacheable=true)
    public static Map<String, List<Map<String, String>>> getRecordsByEndorsementRequest(Id endorsementRequestId) {
        Map<String, List<Map<String, String>>> result = new Map<String, List<Map<String, String>>>();

        // Fetch related Endorsement_Policy__c records
        List<Endorsement_Policy__c> endorsementPolicies = [
            SELECT Policy__c
            FROM Endorsement_Policy__c
            WHERE Endorsement_Request__c = :endorsementRequestId
        ];

        Set<Id> policyIds = new Set<Id>();
        for (Endorsement_Policy__c ep : endorsementPolicies) {
            policyIds.add(ep.Policy__c);
        }

        if (policyIds.isEmpty()) {
            result.put('vehicles', new List<Map<String, String>>());
            result.put('trailers', new List<Map<String, String>>());
            result.put('drivers', new List<Map<String, String>>());
            return result;
        }

        // Fetch Policy_Vehicle__c, Policy_Trailer__c, Policy_Driver__c
        Map<Id, String> uniqueVehicles = new Map<Id, String>();
        Map<Id, String> uniqueTrailers = new Map<Id, String>();
        Map<Id, String> uniqueDrivers = new Map<Id, String>();

        for (Policy_Vehicle__c pv : [
            SELECT Vehicle__c, Vehicle__r.Name
            FROM Policy_Vehicle__c
            WHERE Policy__c IN :policyIds
        ]) {
            if (!uniqueVehicles.containsKey(pv.Vehicle__c)) {
                uniqueVehicles.put(pv.Vehicle__c, pv.Vehicle__r.Name);
            }
        }

        for (Policy_Trailer__c pt : [
            SELECT Trailer__c, Trailer__r.Name
            FROM Policy_Trailer__c
            WHERE Policy__c IN :policyIds
        ]) {
            if (!uniqueTrailers.containsKey(pt.Trailer__c)) {
                uniqueTrailers.put(pt.Trailer__c, pt.Trailer__r.Name);
            }
        }

        for (Policy_Driver__c pd : [
            SELECT Driver__c, Driver__r.Name
            FROM Policy_Driver__c
            WHERE Policy__c IN :policyIds
        ]) {
            if (!uniqueDrivers.containsKey(pd.Driver__c)) {
                uniqueDrivers.put(pd.Driver__c, pd.Driver__r.Name);
            }
        }

        result.put('vehicles', convertMapToList(uniqueVehicles));
        result.put('trailers', convertMapToList(uniqueTrailers));
        result.put('drivers', convertMapToList(uniqueDrivers));

        return result;
    }

    // Helper method to convert Map<Id, String> to List<Map<String, String>>
    private static List<Map<String, String>> convertMapToList(Map<Id, String> inputMap) {
        List<Map<String, String>> outputList = new List<Map<String, String>>();
        for (Id key : inputMap.keySet()) {
            outputList.add(new Map<String, String>{'Id' => key, 'Name' => inputMap.get(key)});
        }
        return outputList;
    }

    @AuraEnabled
    public static Map<String, Object> createEndorsementRecords(
        Id endorsementRequestId,
        List<Id> vehicleIds,
        List<Id> trailerIds,
        List<Id> driverIds,
        String action
    ) {
        Map<String, Object> response = new Map<String, Object>();
        response.put('success', false);

        if ((vehicleIds == null || vehicleIds.isEmpty()) &&
            (trailerIds == null || trailerIds.isEmpty()) &&
            (driverIds == null || driverIds.isEmpty())) {
            response.put('message', 'No records selected.');
            return response;
        }

        List<SObject> endorsementRecordsToInsert = new List<SObject>();

        // Retrieve existing records to avoid duplicates
        Set<Id> existingVehicleIds = new Set<Id>();
        Set<Id> existingTrailerIds = new Set<Id>();
        Set<Id> existingDriverIds = new Set<Id>();

        // Fetch existing Endorsement_Vehicle__c records
        for (Endorsement_Vehicle__c ev : [
            SELECT Vehicle__c
            FROM Endorsement_Vehicle__c
            WHERE Endorsement_Request__c = :endorsementRequestId
        ]) {
            existingVehicleIds.add(ev.Vehicle__c);
        }

        // Fetch existing Endorsement_Trailer__c records
        for (Endorsement_Trailer__c et : [
            SELECT Trailer__c
            FROM Endorsement_Trailer__c
            WHERE Endorsement_Request__c = :endorsementRequestId
        ]) {
            existingTrailerIds.add(et.Trailer__c);
        }

        // Fetch existing Endorsement_Driver__c records
        for (Endorsement_Driver__c ed : [
            SELECT Driver__c
            FROM Endorsement_Driver__c
            WHERE Endorsement_Request__c = :endorsementRequestId
        ]) {
            existingDriverIds.add(ed.Driver__c);
        }

        // Process Vehicles
        if (vehicleIds != null) {
            for (Id vehicleId : vehicleIds) {
                if (!existingVehicleIds.contains(vehicleId)) {
                    endorsementRecordsToInsert.add(new Endorsement_Vehicle__c(
                        Endorsement_Request__c = endorsementRequestId,
                        Vehicle__c = vehicleId,
                        Action__c = action
                    ));
                }
            }
        }

        // Process Trailers
        if (trailerIds != null) {
            for (Id trailerId : trailerIds) {
                if (!existingTrailerIds.contains(trailerId)) {
                    endorsementRecordsToInsert.add(new Endorsement_Trailer__c(
                        Endorsement_Request__c = endorsementRequestId,
                        Trailer__c = trailerId,
                        Action__c = action
                    ));
                }
            }
        }

        // Process Drivers
        if (driverIds != null) {
            for (Id driverId : driverIds) {
                if (!existingDriverIds.contains(driverId)) {
                    endorsementRecordsToInsert.add(new Endorsement_Driver__c(
                        Endorsement_Request__c = endorsementRequestId,
                        Driver__c = driverId,
                        Action__c = action
                    ));
                }
            }
        }

        // Insert new records and handle any errors
        try {
            if (!endorsementRecordsToInsert.isEmpty()) {
                insert endorsementRecordsToInsert;
                response.put('success', true);
                response.put('message', 'Endorsement records created successfully.');
            } else {
                response.put('message', 'No new records to create. All selected records already exist.');
            }
        } catch (Exception e) {
            response.put('message', 'Error creating endorsement records: ' + e.getMessage());
        }

        return response;
    }
}