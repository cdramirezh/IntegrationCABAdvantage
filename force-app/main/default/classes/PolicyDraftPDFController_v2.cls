public class PolicyDraftPDFController_v2 {
    public Policy_Draft__c policyDraft { get; private set; }
    public List<Vehicle__c> vehicles { get; private set; }
    public List<Trailer__c> trailers { get; private set; }
    public List<Driver__c> drivers { get; private set; }
    public List<Commodity__c> commodities { get; private set; }
    public List<Coverage__c> coverages { get; private set; }
    public List<DriverWrapper> DriverWrappers { get; private set; }
    public List<VehicleWrapper> vehicleWrappers { get; private set; }
    public List<TrailerWrapper> TrailerWrappers { get; private set; }

    // Wrapper class to hold Driver and its coverage products
    public class DriverWrapper {
        public Driver__c Driver { get; set; }
        public String coverageProductNames { get; set; }
        public DriverWrapper(Driver__c Driver, String coverageProductNames) {
            this.Driver = Driver;
            this.coverageProductNames = coverageProductNames;
        }
    }

    // Wrapper class to hold Vehicle and its coverage products
    public class VehicleWrapper {
        public Vehicle__c vehicle { get; set; }
        public String coverageProductNames { get; set; }
        public VehicleWrapper(Vehicle__c vehicle, String coverageProductNames) {
            this.vehicle = vehicle;
            this.coverageProductNames = coverageProductNames;
        }
    }

    // Wrapper class to hold Trailer and its coverage products
    public class TrailerWrapper {
        public Trailer__c Trailer { get; set; }
        public String coverageProductNames { get; set; }
        public TrailerWrapper(Trailer__c Trailer, String coverageProductNames) {
            this.Trailer = Trailer;
            this.coverageProductNames = coverageProductNames;
        }
    }

    public PolicyDraftPDFController_v2(ApexPages.StandardController standardController) {
        this.policyDraft = (Policy_Draft__c) standardController.getRecord();

        // Initialize vehicleWrappers
        vehicleWrappers = new List<VehicleWrapper>();

        // Initialize TrailerWrappers
        TrailerWrappers = new List<TrailerWrapper>();

        // Initialize DriverWrappers
        DriverWrappers = new List<DriverWrapper>();

        if (policyDraft != null) {
            // Fetch related records for the Lead linked to the Policy_Draft__c record
            fetchRelatedRecords(policyDraft.Lead__c);            
            fetchDriverCoverageData();
            fetchVehicleCoverageData();
            fetchTrailerCoverageData();
        }

        coverages = [SELECT Id, Name, Policy_Draft__c, Limit__c, Deductible__c, Coverage_Product__c, Coverage_Product__r.Name
                        FROM Coverage__c
                        WHERE Policy_Draft__c = :policyDraft.Id];

    }

    private void fetchDriverCoverageData() {
        // Query coverage and related records
        List<Coverage__c> coverages = [
            SELECT Id, Coverage_Product__r.Name,
                (SELECT Driver__r.Id, Driver__r.Name, Driver__r.CDL__c, Driver__r.DOB__c, Driver__r.State__c, Driver__r.Hiring_Date__c, Driver__r.Experience__c FROM Coverage_Drivers__r)
            FROM Coverage__c
            WHERE Policy_Draft__c = :policyDraft.Id
        ];

        // Map to aggregate coverage product names by Driver
        Map<Id, Set<String>> DriverCoverageMap = new Map<Id, Set<String>>();
        Map<Id, Driver__c> DriversMap = new Map<Id, Driver__c>();

        for (Coverage__c coverage : coverages) {
            for (Coverage_Driver__c cv : coverage.Coverage_Drivers__r) {
                Driver__c Driver = cv.Driver__r;
                if (Driver != null) {
                    // Add Driver to map
                    DriversMap.put(Driver.Id, Driver);

                    // Add coverage product name to set
                    if (!DriverCoverageMap.containsKey(Driver.Id)) {
                        DriverCoverageMap.put(Driver.Id, new Set<String>());
                    }
                    DriverCoverageMap.get(Driver.Id).add(coverage.Coverage_Product__r.Name);
                }
            }
        }

        // Create wrapper instances
        for (Id DriverId : DriverCoverageMap.keySet()) {
            Driver__c Driver = DriversMap.get(DriverId);
            String coverageNames = String.join(new List<String>(DriverCoverageMap.get(DriverId)), ', ');
            DriverWrappers.add(new DriverWrapper(Driver, coverageNames));
        }
    }

    private void fetchVehicleCoverageData() {
        // Query coverage and related records
        List<Coverage__c> coverages = [
            SELECT Id, Coverage_Product__r.Name,
                (SELECT Vehicle__r.Id, Vehicle__r.Name, Vehicle__r.Make__r.Name, Vehicle__r.Type__c, Vehicle__r.Year__c, Vehicle__r.Value__c, Vehicle__r.Weight__c FROM Coverage_Vehicles__r)
            FROM Coverage__c
            WHERE Policy_Draft__c = :policyDraft.Id
        ];

        // Map to aggregate coverage product names by Vehicle
        Map<Id, Set<String>> vehicleCoverageMap = new Map<Id, Set<String>>();
        Map<Id, Vehicle__c> vehiclesMap = new Map<Id, Vehicle__c>();

        for (Coverage__c coverage : coverages) {
            for (Coverage_Vehicle__c cv : coverage.Coverage_Vehicles__r) {
                Vehicle__c vehicle = cv.Vehicle__r;
                if (vehicle != null) {
                    // Add vehicle to map
                    vehiclesMap.put(vehicle.Id, vehicle);

                    // Add coverage product name to set
                    if (!vehicleCoverageMap.containsKey(vehicle.Id)) {
                        vehicleCoverageMap.put(vehicle.Id, new Set<String>());
                    }
                    vehicleCoverageMap.get(vehicle.Id).add(coverage.Coverage_Product__r.Name);
                }
            }
        }

        // Create wrapper instances
        for (Id vehicleId : vehicleCoverageMap.keySet()) {
            Vehicle__c vehicle = vehiclesMap.get(vehicleId);
            String coverageNames = String.join(new List<String>(vehicleCoverageMap.get(vehicleId)), ', ');
            vehicleWrappers.add(new VehicleWrapper(vehicle, coverageNames));
        }
    }

    private void fetchTrailerCoverageData() {
        // Query coverage and related records
        List<Coverage__c> coverages = [
            SELECT Id, Coverage_Product__r.Name,
                (SELECT Trailer__r.Id, Trailer__r.Name, Trailer__r.Make__r.Name, Trailer__r.Type__c, Trailer__r.Year__c, Trailer__r.Value__c, Trailer__r.Weight__c FROM Coverage_Trailers__r)
            FROM Coverage__c
            WHERE Policy_Draft__c = :policyDraft.Id
        ];

        // Map to aggregate coverage product names by Trailer
        Map<Id, Set<String>> TrailerCoverageMap = new Map<Id, Set<String>>();
        Map<Id, Trailer__c> TrailersMap = new Map<Id, Trailer__c>();

        for (Coverage__c coverage : coverages) {
            for (Coverage_Trailer__c cv : coverage.Coverage_Trailers__r) {
                Trailer__c Trailer = cv.Trailer__r;
                if (Trailer != null) {
                    // Add Trailer to map
                    TrailersMap.put(Trailer.Id, Trailer);

                    // Add coverage product name to set
                    if (!TrailerCoverageMap.containsKey(Trailer.Id)) {
                        TrailerCoverageMap.put(Trailer.Id, new Set<String>());
                    }
                    TrailerCoverageMap.get(Trailer.Id).add(coverage.Coverage_Product__r.Name);
                }
            }
        }

        // Create wrapper instances
        for (Id TrailerId : TrailerCoverageMap.keySet()) {
            Trailer__c Trailer = TrailersMap.get(TrailerId);
            String coverageNames = String.join(new List<String>(TrailerCoverageMap.get(TrailerId)), ', ');
            TrailerWrappers.add(new TrailerWrapper(Trailer, coverageNames));
        }
    }

    private void fetchRelatedRecords(Id leadId) {
        // Retrieve related Vehicle__c records
        vehicles = [SELECT Id, Name, Make__c, Type__c, Year__c, Value__c, Weight__c
                    FROM Vehicle__c
                    WHERE Lead__c = :leadId];

        // Retrieve related Trailer__c records
        trailers = [SELECT Id, Name, Year__c
                    FROM Trailer__c
                    WHERE Lead__c = :leadId];

        // Retrieve related Driver__c records
        drivers = [SELECT Id, Name, CDL__c, DOB__c, State__c, Hiring_Date__c, Experience__c
                   FROM Driver__c
                   WHERE Lead__c = :leadId];

        // Retrieve related Commodity__c records
        commodities = [SELECT Id, Name, Percent__c
                       FROM Commodity__c
                       WHERE Lead__c = :leadId];
    }
    
}