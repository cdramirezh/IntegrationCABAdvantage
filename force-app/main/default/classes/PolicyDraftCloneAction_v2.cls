public class PolicyDraftCloneAction_v2 {
    
    public class CloneRequest {
        @InvocableVariable(required=true)
        public Id policyDraftId;
    }
    
    public class CloneResponse {
        @InvocableVariable
        public Id newPolicyDraftId;
        @InvocableVariable
        public String message;
        @InvocableVariable
        public Boolean success;
    }
    
    @InvocableMethod(label='Clone Policy Draft with Related Records' description='Clones a Policy Draft record along with all its related Coverage, Vehicle, Trailer, and Driver records')
    public static List<CloneResponse> clonePolicyDraft(List<CloneRequest> requests) {
        List<CloneResponse> responses = new List<CloneResponse>();
        
        for (CloneRequest request : requests) {
            CloneResponse response = new CloneResponse();
            
            try {
                // Query the original Policy Draft record
                Policy_Draft__c originalPolicy = [
                    SELECT Id, Name, Lead__c, Opportunity__c, Producer__c, CreatedDate, LastModifiedDate
                    FROM Policy_Draft__c 
                    WHERE Id = :request.policyDraftId
                    LIMIT 1
                ];
                
                // Create new Policy Draft record with specific fields only
                Policy_Draft__c clonedPolicy = new Policy_Draft__c();
                clonedPolicy.Name = originalPolicy.Name + ' - Clone';
                clonedPolicy.Status__c = 'Open';
                
                // Only populate lookup fields if they are populated in the original
                if (originalPolicy.Lead__c != null) {
                    clonedPolicy.Lead__c = originalPolicy.Lead__c;
                }
                if (originalPolicy.Opportunity__c != null) {
                    clonedPolicy.Opportunity__c = originalPolicy.Opportunity__c;
                }
                if (originalPolicy.Producer__c != null) {
                    clonedPolicy.Producer__c = originalPolicy.Producer__c;
                }
                insert clonedPolicy;
                
                // Clone Coverage records with specific fields only
                List<Coverage__c> originalCoverages = [
                    SELECT Id, Policy_Draft__c, Coverage_Product__c, Limit__c, Deductible__c
                    FROM Coverage__c 
                    WHERE Policy_Draft__c = :request.policyDraftId
                ];
                
                if (!originalCoverages.isEmpty()) {
                    List<Coverage__c> clonedCoverages = new List<Coverage__c>();
                    for (Coverage__c coverage : originalCoverages) {
                        Coverage__c clonedCoverage = new Coverage__c();
                        clonedCoverage.Policy_Draft__c = clonedPolicy.Id;
                        clonedCoverage.Coverage_Product__c = coverage.Coverage_Product__c;
                        clonedCoverage.Limit__c = coverage.Limit__c;
                        clonedCoverage.Deductible__c = coverage.Deductible__c;
                        clonedCoverages.add(clonedCoverage);
                    }
                    insert clonedCoverages;
                }
                
                // Clone Policy Vehicle records with specific fields only
                List<Policy_Vehicle__c> originalVehicles = [
                    SELECT Id, Policy_Draft__c, Vehicle__c
                    FROM Policy_Vehicle__c 
                    WHERE Policy_Draft__c = :request.policyDraftId
                ];
                
                if (!originalVehicles.isEmpty()) {
                    List<Policy_Vehicle__c> clonedVehicles = new List<Policy_Vehicle__c>();
                    for (Policy_Vehicle__c vehicle : originalVehicles) {
                        Policy_Vehicle__c clonedVehicle = new Policy_Vehicle__c();
                        clonedVehicle.Policy_Draft__c = clonedPolicy.Id;
                        clonedVehicle.Vehicle__c = vehicle.Vehicle__c;
                        clonedVehicles.add(clonedVehicle);
                    }
                    insert clonedVehicles;
                }
                
                // Clone Policy Trailer records with specific fields only
                List<Policy_Trailer__c> originalTrailers = [
                    SELECT Id, Policy_Draft__c, Trailer__c
                    FROM Policy_Trailer__c 
                    WHERE Policy_Draft__c = :request.policyDraftId
                ];
                
                if (!originalTrailers.isEmpty()) {
                    List<Policy_Trailer__c> clonedTrailers = new List<Policy_Trailer__c>();
                    for (Policy_Trailer__c trailer : originalTrailers) {
                        Policy_Trailer__c clonedTrailer = new Policy_Trailer__c();
                        clonedTrailer.Policy_Draft__c = clonedPolicy.Id;
                        clonedTrailer.Trailer__c = trailer.Trailer__c;
                        clonedTrailers.add(clonedTrailer);
                    }
                    insert clonedTrailers;
                }
                
                // Clone Policy Driver records with specific fields only
                List<Policy_Driver__c> originalDrivers = [
                    SELECT Id, Policy_Draft__c, Driver__c
                    FROM Policy_Driver__c 
                    WHERE Policy_Draft__c = :request.policyDraftId
                ];
                
                if (!originalDrivers.isEmpty()) {
                    List<Policy_Driver__c> clonedDrivers = new List<Policy_Driver__c>();
                    for (Policy_Driver__c driver : originalDrivers) {
                        Policy_Driver__c clonedDriver = new Policy_Driver__c();
                        clonedDriver.Policy_Draft__c = clonedPolicy.Id;
                        clonedDriver.Driver__c = driver.Driver__c;
                        clonedDrivers.add(clonedDriver);
                    }
                    insert clonedDrivers;
                }
                
                response.newPolicyDraftId = clonedPolicy.Id;
                response.success = true;
                response.message = 'Policy Draft cloned successfully with all related records.';
                
            } catch (Exception e) {
                response.success = false;
                response.message = 'Error cloning Policy Draft: ' + e.getMessage();
                System.debug('Error in PolicyDraftCloneAction: ' + e.getMessage());
            }
            
            responses.add(response);
        }
        
        return responses;
    }
}