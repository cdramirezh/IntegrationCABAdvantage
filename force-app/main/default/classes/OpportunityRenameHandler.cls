public class OpportunityRenameHandler {
    
    /**
     * Main method to handle opportunity renaming logic
     * @param newOpportunities - List of new/updated opportunities
     * @param oldOpportunityMap - Map of old opportunity values (null for insert)
     */
    public static void handleOpportunityRename(List<Opportunity> newOpportunities, Map<Id, Opportunity> oldOpportunityMap) {
        
        // Collect Account IDs for opportunities that need renaming
        Set<Id> accountIds = new Set<Id>();
        List<Opportunity> opportunitiesToRename = new List<Opportunity>();
        
        // Loop through opportunities to identify which ones need renaming
        for (Opportunity opp : newOpportunities) {
            Boolean shouldRename = false;
            
            // Check if this is an insert operation with Policy Term populated
            if (Trigger.isInsert && String.isNotBlank(opp.Policy_Term__c)) {
                shouldRename = true;
            } 
            // Check if this is an update operation and Policy Term was changed
            else if (Trigger.isUpdate && oldOpportunityMap != null) {
                Opportunity oldOpp = oldOpportunityMap.get(opp.Id);
                // Only rename if Policy Term actually changed and has a value
                if (opp.Policy_Term__c != oldOpp.Policy_Term__c && String.isNotBlank(opp.Policy_Term__c)) {
                    shouldRename = true;
                }
            }
            
            // Add to processing lists if criteria met
            if (shouldRename && opp.AccountId != null) {
                accountIds.add(opp.AccountId);
                opportunitiesToRename.add(opp);
            }
        }
        
        // Only proceed if we have opportunities to rename
        if (!opportunitiesToRename.isEmpty()) {
            // Query Account Names in bulk to avoid governor limits
            Map<Id, Account> accountMap = new Map<Id, Account>([
                SELECT Id, Name 
                FROM Account 
                WHERE Id IN :accountIds
            ]);
            
            // Update opportunity names with the new format
            for (Opportunity opp : opportunitiesToRename) {
                Account relatedAccount = accountMap.get(opp.AccountId);
                
                // Ensure account exists and Policy Term is not blank
                if (relatedAccount != null && String.isNotBlank(opp.Policy_Term__c)) {
                    // Set the new name format: "Account Name - Policy Term"
                    opp.Name = relatedAccount.Name + ' - ' + opp.Policy_Term__c;
                }
            }
        }
    }
    
    /**
     * Utility method to check if Policy Term field was actually changed
     * @param newOpp - New opportunity record
     * @param oldOpp - Old opportunity record
     * @return Boolean indicating if Policy Term changed
     */
    private static Boolean isPolicyTermChanged(Opportunity newOpp, Opportunity oldOpp) {
        if (oldOpp == null) return true; // New record
        return newOpp.Policy_Term__c != oldOpp.Policy_Term__c;
    }
}