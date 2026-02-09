public with sharing class EndorsementRequestSummaryController_v2 {
    public Id endorsementRequestId { get; private set; }

    public List<Endorsement_Policy__c> policies { get; private set; }
    public List<Endorsement_Coverage__c> coverages { get; private set; }
    public List<Endorsement_Vehicle__c> modifiedVehicles { get; private set; }
    public Integer modifiedVehiclesCount { get; private set; }
    public List<Endorsement_Driver__c> modifiedDrivers { get; private set; }
    public Integer modifiedDriversCount { get; private set; }
    public List<Endorsement_Trailer__c> modifiedTrailers { get; private set; }
    public Integer modifiedTrailersCount { get; private set; }
    public List<Endorsement_Commodity__c> modifiedCommodities { get; private set; }
    public Integer modifiedCommoditiesCount { get; private set; }
    public List<Endorsement_Vehicle__c> addedVehicles { get; private set; }
    public List<Endorsement_Driver__c> addedDrivers { get; private set; }
    public List<Endorsement_Trailer__c> addedTrailers { get; private set; }
    public Integer addedVehiclesCount { get; private set; }
    public Integer addedDriversCount { get; private set; }
    public Integer addedTrailersCount { get; private set; }
    public List<Endorsement_Commodity__c> addedCommodities { get; private set; }
    public Integer addedCommoditiesCount { get; private set; }
    public List<Endorsement_Vehicle__c> deletedVehicles { get; private set; }
    public List<Endorsement_Driver__c> deletedDrivers { get; private set; }
    public List<Endorsement_Trailer__c> deletedTrailers { get; private set; }
    public List<Endorsement_Commodity__c> deletedCommodities { get; private set; }
    public Integer deletedCommoditiesCount { get; private set; }
    public Integer deletedVehiclesCount { get; private set; }
    public Integer deletedDriversCount { get; private set; }
    public Integer deletedTrailersCount { get; private set; }

    public EndorsementRequestSummaryController_v2(ApexPages.StandardController stdController) {
        this.endorsementRequestId = stdController.getId();
        loadSummaryData();

        modifiedDriversCount = modifiedDrivers.size();
        modifiedVehiclesCount = modifiedVehicles.size();
        modifiedTrailersCount = modifiedTrailers.size();
        addedDriversCount = addedDrivers.size();
        addedVehiclesCount = addedVehicles.size();
        addedTrailersCount = addedTrailers.size();
        deletedDriversCount = deletedDrivers.size();
        deletedVehiclesCount = deletedVehicles.size();
        deletedTrailersCount = deletedTrailers.size();
        modifiedCommoditiesCount = modifiedCommodities.size();
        addedCommoditiesCount = addedCommodities.size();
        deletedCommoditiesCount = deletedCommodities.size();
        modifiedCommoditiesCount = modifiedCommodities.size();

    }

    private void loadSummaryData() {        
        
        //Retrieve Endorsement Request related Policies, Coverages, Vehicles, Drivers and Trailers

        policies = [
            SELECT Id, Policy__r.Name
            FROM Endorsement_Policy__c
            WHERE Endorsement_Request__c = :endorsementRequestId
        ];

        coverages = [
            SELECT Id, Coverage__r.Coverage_Product__r.Name, New_Limit__c, New_Deductible__c,
                   Coverage__r.Limit__c, Coverage__r.Deductible__c
            FROM Endorsement_Coverage__c
            WHERE Endorsement_Request__c = :endorsementRequestId
        ];

        modifiedVehicles = [
            SELECT Id, Vehicle__r.Name, Vehicle__r.Value__c, Vehicle__r.Weight__c,
                   New_VIN__c, New_Value__c, New_Weight__c, Vehicle__r.Make__r.Name,
                   Vehicle__r.Year__c
            FROM Endorsement_Vehicle__c
            WHERE Endorsement_Request__c = :endorsementRequestId AND Action__c = 'Modify'
        ];

        modifiedDrivers = [
            SELECT Id, Driver__r.Name, Driver__r.CDL__c, New_CDL__c
            FROM Endorsement_Driver__c
            WHERE Endorsement_Request__c = :endorsementRequestId AND Action__c = 'Modify'
        ];

        modifiedTrailers = [
            SELECT Id, Trailer__r.Name, Trailer__r.Value__c, Trailer__r.Weight__c,
                   New_VIN__c, New_Value__c, New_Weight__c, Trailer__r.Make__r.Name,
                   Trailer__r.Year__c, Trailer__r.Type__c
            FROM Endorsement_Trailer__c
            WHERE Endorsement_Request__c = :endorsementRequestId AND Action__c = 'Modify'
        ];

        modifiedCommodities = [
            SELECT Id, Commodity__r.Name, Commodity__r.Percent__c, New_Percent__c
            FROM Endorsement_Commodity__c
            WHERE Endorsement_Request__c = :endorsementRequestId AND Action__c = 'Modify'
        ];

        addedVehicles = [
            SELECT Id, Vehicle__r.Name, Vehicle__r.Value__c, Vehicle__r.Weight__c, Vehicle__r.Make__r.Name,
                   Vehicle__r.Year__c
            FROM Endorsement_Vehicle__c
            WHERE Endorsement_Request__c = :endorsementRequestId AND Action__c = 'Add'
        ];

        addedDrivers = [
            SELECT Id, Driver__r.Name, Driver__r.CDL__c
            FROM Endorsement_Driver__c
            WHERE Endorsement_Request__c = :endorsementRequestId AND Action__c = 'Add'
        ];

        addedTrailers = [
            SELECT Id, Trailer__r.Name, Trailer__r.Value__c, Trailer__r.Weight__c, Trailer__r.Make__r.Name,
                   Trailer__r.Year__c, Trailer__r.Type__c
            FROM Endorsement_Trailer__c
            WHERE Endorsement_Request__c = :endorsementRequestId AND Action__c = 'Add'
        ];

        addedCommodities = [
            SELECT Id, Commodity__r.Name, Commodity__r.Percent__c
            FROM Endorsement_Commodity__c
            WHERE Endorsement_Request__c = :endorsementRequestId AND Action__c = 'Add'
        ];

        deletedVehicles = [
            SELECT Id, Vehicle__r.Name, Vehicle__r.Value__c, Vehicle__r.Weight__c, Vehicle__r.Make__r.Name,
            Vehicle__r.Year__c
            FROM Endorsement_Vehicle__c
            WHERE Endorsement_Request__c = :endorsementRequestId AND Action__c = 'Delete'
        ];

        deletedDrivers = [
            SELECT Id, Driver__r.Name, Driver__r.CDL__c
            FROM Endorsement_Driver__c
            WHERE Endorsement_Request__c = :endorsementRequestId AND Action__c = 'Delete'
        ];

        deletedTrailers = [
            SELECT Id, Trailer__r.Name, Trailer__r.Value__c, Trailer__r.Weight__c, Trailer__r.Make__r.Name, Trailer__r.Type__c,
            Trailer__r.Year__c
            FROM Endorsement_Trailer__c
            WHERE Endorsement_Request__c = :endorsementRequestId AND Action__c = 'Delete'
        ];

        deletedCommodities = [
            SELECT Id, Commodity__r.Name, Commodity__r.Percent__c
            FROM Endorsement_Commodity__c
            WHERE Endorsement_Request__c = :endorsementRequestId AND Action__c = 'Delete'
        ];


    }
}