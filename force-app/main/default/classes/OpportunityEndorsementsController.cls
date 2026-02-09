public with sharing class OpportunityEndorsementsController {
    
    @AuraEnabled(cacheable=true)
    public static List<EndorsementRequestWrapper> getEndorsementRequests(Id opportunityId) {
        List<EndorsementRequestWrapper> wrapperList = new List<EndorsementRequestWrapper>();
        
        // Get all Endorsement Requests related to the Opportunity
        List<Endorsement_Request__c> endorsementRequests = [
            SELECT Id, Name, Subject__c, Effective_Date__c, Other_Request__c
            FROM Endorsement_Request__c
            WHERE Opportunity__c = :opportunityId
            ORDER BY CreatedDate DESC
        ];
        
        for (Endorsement_Request__c request : endorsementRequests) {
            EndorsementRequestWrapper wrapper = new EndorsementRequestWrapper();
            wrapper.Id = request.Id;
            wrapper.Subject = request.Subject__c;
            wrapper.Name = request.Name;
            wrapper.EffectiveDate = request.Effective_Date__c;
            wrapper.OtherRequest = request.Other_Request__c;
            
            // Load related data for each endorsement request
            wrapper.policies = getPolicies(request.Id);
            wrapper.coverages = getCoverages(request.Id);
            wrapper.addedVehicles = getVehicles(request.Id, 'Add');
            wrapper.addedTrailers = getTrailers(request.Id, 'Add');
            wrapper.addedDrivers = getDrivers(request.Id, 'Add');
            wrapper.addedCommodities = getCommodities(request.Id, 'Add');
            wrapper.deletedVehicles = getVehicles(request.Id, 'Delete');
            wrapper.deletedTrailers = getTrailers(request.Id, 'Delete');
            wrapper.deletedDrivers = getDrivers(request.Id, 'Delete');
            wrapper.deletedCommodities = getCommodities(request.Id, 'Delete');
            wrapper.modifiedVehicles = getVehicles(request.Id, 'Modify');
            wrapper.modifiedTrailers = getTrailers(request.Id, 'Modify');
            wrapper.modifiedDrivers = getDrivers(request.Id, 'Modify');
            wrapper.modifiedCommodities = getCommodities(request.Id, 'Modify');
            
            wrapperList.add(wrapper);
        }
        
        return wrapperList;
    }
    
    private static List<Endorsement_Policy__c> getPolicies(Id endorsementRequestId) {
        return [
            SELECT Id, Policy__r.Name
            FROM Endorsement_Policy__c
            WHERE Endorsement_Request__c = :endorsementRequestId
        ];
    }
    
    private static List<Endorsement_Coverage__c> getCoverages(Id endorsementRequestId) {
        return [
            SELECT Id, Coverage__r.Coverage_Product__r.Name, New_Limit__c, New_Deductible__c,
                   Coverage__r.Limit__c, Coverage__r.Deductible__c
            FROM Endorsement_Coverage__c
            WHERE Endorsement_Request__c = :endorsementRequestId
        ];
    }
    
    private static List<Endorsement_Vehicle__c> getVehicles(Id endorsementRequestId, String action) {
        return [
            SELECT Id, Vehicle__r.Name, Vehicle__r.Value__c, Vehicle__r.Weight__c,
                   New_VIN__c, New_Value__c, New_Weight__c, Vehicle__r.Make__r.Name,
                   Vehicle__r.Year__c
            FROM Endorsement_Vehicle__c
            WHERE Endorsement_Request__c = :endorsementRequestId 
            AND Action__c = :action
        ];
    }
    
    private static List<Endorsement_Trailer__c> getTrailers(Id endorsementRequestId, String action) {
        return [
            SELECT Id, Trailer__r.Name, Trailer__r.Value__c, Trailer__r.Weight__c,
                   New_VIN__c, New_Value__c, New_Weight__c, Trailer__r.Make__r.Name,
                   Trailer__r.Year__c, Trailer__r.Type__c
            FROM Endorsement_Trailer__c
            WHERE Endorsement_Request__c = :endorsementRequestId 
            AND Action__c = :action
        ];
    }
    
    private static List<Endorsement_Driver__c> getDrivers(Id endorsementRequestId, String action) {
        return [
            SELECT Id, Driver__r.Name, Driver__r.CDL__c, New_CDL__c
            FROM Endorsement_Driver__c
            WHERE Endorsement_Request__c = :endorsementRequestId 
            AND Action__c = :action
        ];
    }
    
    private static List<Endorsement_Commodity__c> getCommodities(Id endorsementRequestId, String action) {
        return [
            SELECT Id, Commodity__r.Name, Commodity__r.Percent__c, New_Percent__c
            FROM Endorsement_Commodity__c
            WHERE Endorsement_Request__c = :endorsementRequestId 
            AND Action__c = :action
        ];
    }
    
    // Wrapper class to structure the data for Lightning Web Component
    public class EndorsementRequestWrapper {
        @AuraEnabled public Id Id;
        @AuraEnabled public String Name;
        @AuraEnabled public String Subject;
        @AuraEnabled public Date EffectiveDate;
        @AuraEnabled public String OtherRequest;
        @AuraEnabled public List<Endorsement_Policy__c> policies;
        @AuraEnabled public List<Endorsement_Coverage__c> coverages;
        @AuraEnabled public List<Endorsement_Vehicle__c> addedVehicles;
        @AuraEnabled public List<Endorsement_Vehicle__c> deletedVehicles;
        @AuraEnabled public List<Endorsement_Vehicle__c> modifiedVehicles;
        @AuraEnabled public List<Endorsement_Trailer__c> addedTrailers;
        @AuraEnabled public List<Endorsement_Trailer__c> deletedTrailers;
        @AuraEnabled public List<Endorsement_Trailer__c> modifiedTrailers;
        @AuraEnabled public List<Endorsement_Driver__c> addedDrivers;
        @AuraEnabled public List<Endorsement_Driver__c> deletedDrivers;
        @AuraEnabled public List<Endorsement_Driver__c> modifiedDrivers;
        @AuraEnabled public List<Endorsement_Commodity__c> addedCommodities;
        @AuraEnabled public List<Endorsement_Commodity__c> deletedCommodities;
        @AuraEnabled public List<Endorsement_Commodity__c> modifiedCommodities;
    }
}