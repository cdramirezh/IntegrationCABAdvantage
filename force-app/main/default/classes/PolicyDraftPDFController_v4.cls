public class PolicyDraftPDFController_v4 {
    public Policy_Draft__c policyDraft { get; private set; }
    public List<Vehicle__c> vehicles { get; private set; }
    public List<Trailer__c> trailers { get; private set; }
    public List<Driver__c> drivers { get; private set; }
    public List<Commodity__c> commodities { get; private set; }
    public List<Coverage__c> coverages { get; private set; }
    public List<Policy_Vehicle__c> policyVehicles { get; private set; }
    public List<Policy_Trailer__c> policyTrailers { get; private set; }
    public List<Policy_Driver__c> policyDrivers { get; private set; }
    public Integer numDrivers { get; private set; }


    public PolicyDraftPDFController_v4(ApexPages.StandardController standardController) {
        this.policyDraft = (Policy_Draft__c) standardController.getRecord();

        Policy_Draft__c pd = [SELECT Id, Lead__c FROM Policy_Draft__c WHERE Id = :policyDraft.Id LIMIT 1];

       

        if (policyDraft != null) {
            // Fetch related records for the Lead linked to the Policy_Draft__c record
            fetchRelatedRecords(pd.Lead__c); 
            fetchPolicyDrivers();
            fetchPolicyVehicles();
            fetchPolicyTrailers(); 
        }

        coverages = [SELECT Id, Name, Policy_Draft__c, Limit__c, Deductible__c, Coverage_Product__c, Coverage_Product__r.Name
                        FROM Coverage__c
                        WHERE Policy_Draft__c = :policyDraft.Id];

    }

    private void fetchPolicyDrivers() {
        // Query policy drivers
        policyDrivers = [
            SELECT Id, Driver__c, Status__c, Driver__r.Id, Driver__r.Name, Driver__r.CDL__c, Driver__r.DOB__c, Driver__r.State__c, Driver__r.Hiring_Date__c, Driver__r.Experience__c
            FROM Policy_Driver__c
            WHERE Policy_Draft__c = :policyDraft.Id
        ];

        numDrivers = policyDrivers.size();
    }

    private void fetchPolicyVehicles() {
        // Query policy vehicles
        policyVehicles = [
            SELECT Id, Vehicle__c, Status__c, Vehicle__r.Id, Vehicle__r.Name, Vehicle__r.Make__c, Vehicle__r.Make__r.Name, Vehicle__r.Type__c, Vehicle__r.Year__c, Vehicle__r.Value__c, Vehicle__r.Weight__c
            FROM Policy_Vehicle__c
            WHERE Policy_Draft__c = :policyDraft.Id
        ];
    }

    private void fetchPolicyTrailers() {
        // Query policy trailers
        policyTrailers = [
            SELECT Id, Trailer__c, Status__c, Trailer__r.Id, Trailer__r.Name, Trailer__r.Make__c, Trailer__r.Make__r.Name, Trailer__r.Type__c, Trailer__r.Year__c, Trailer__r.Value__c, Trailer__r.Weight__c
            FROM Policy_Trailer__c
            WHERE Policy_Draft__c = :policyDraft.Id
        ];
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