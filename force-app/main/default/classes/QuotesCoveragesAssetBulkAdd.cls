public with sharing class QuotesCoveragesAssetBulkAdd {
    @AuraEnabled(cacheable=true)
    public static List<Vehicle__c> getVehicles(Id quoteId) {
        Policy_Draft__c quote = [SELECT Opportunity__c, Lead__c FROM Policy_Draft__c WHERE Id = :quoteId LIMIT 1];

        if (quote.Opportunity__c != null) {
            Opportunity opp = [SELECT AccountId FROM Opportunity WHERE Id = :quote.Opportunity__c LIMIT 1];
            return [SELECT Id, Name FROM Vehicle__c WHERE Account__c = :opp.AccountId];
        } else {
            return [SELECT Id, Name FROM Vehicle__c WHERE Lead__c = :quote.Lead__c];
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<Trailer__c> getTrailers(Id quoteId) {
        Policy_Draft__c quote = [SELECT Opportunity__c, Lead__c FROM Policy_Draft__c WHERE Id = :quoteId LIMIT 1];

        if (quote.Opportunity__c != null) {
            Opportunity opp = [SELECT AccountId FROM Opportunity WHERE Id = :quote.Opportunity__c LIMIT 1];
            return [SELECT Id, Name FROM Trailer__c WHERE Account__c = :opp.AccountId];
        } else {
            return [SELECT Id, Name FROM Trailer__c WHERE Lead__c = :quote.Lead__c];
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<Driver__c> getDrivers(Id quoteId) {
        Policy_Draft__c quote = [SELECT Opportunity__c, Lead__c FROM Policy_Draft__c WHERE Id = :quoteId LIMIT 1];

        if (quote.Opportunity__c != null) {
            Opportunity opp = [SELECT AccountId FROM Opportunity WHERE Id = :quote.Opportunity__c LIMIT 1];
            return [SELECT Id, Name FROM Driver__c WHERE Account__c = :opp.AccountId];
        } else {
            return [SELECT Id, Name FROM Driver__c WHERE Lead__c = :quote.Lead__c];
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<Coverage__c> getCoverages(Id quoteId) {
        return [SELECT Id, Name, Coverage_Product__r.Name FROM Coverage__c WHERE Policy_Draft__c = :quoteId];
    }

    @AuraEnabled
    public static void createCoverageAssignmentRecords(Id quoteId, List<Id> vehicleIds, List<Id> trailerIds, List<Id> driverIds, List<Id> coverageIds) {
        // Lists for each type of assignment
        List<Coverage_Vehicle__c> vehicleAssignments = new List<Coverage_Vehicle__c>();
        List<Coverage_Trailer__c> trailerAssignments = new List<Coverage_Trailer__c>();
        List<Coverage_Driver__c> driverAssignments = new List<Coverage_Driver__c>();

        // Create assignments for vehicles
        for (Id coverageId : coverageIds) {
            for (Id vehicleId : vehicleIds) {
                vehicleAssignments.add(new Coverage_Vehicle__c(Vehicle__c = vehicleId, Coverage__c = coverageId));
            }
        }

        // Create assignments for trailers
        for (Id coverageId : coverageIds) {
            for (Id trailerId : trailerIds) {
                trailerAssignments.add(new Coverage_Trailer__c(Trailer__c = trailerId, Coverage__c = coverageId));
            }
        }

        // Create assignments for drivers
        for (Id coverageId : coverageIds) {
            for (Id driverId : driverIds) {
                driverAssignments.add(new Coverage_Driver__c(Driver__c = driverId, Coverage__c = coverageId));
            }
        }

        // Insert records separately for each object type
        if (!vehicleAssignments.isEmpty()) {
            insert vehicleAssignments;
        }
        if (!trailerAssignments.isEmpty()) {
            insert trailerAssignments;
        }
        if (!driverAssignments.isEmpty()) {
            insert driverAssignments;
        }
    }
}