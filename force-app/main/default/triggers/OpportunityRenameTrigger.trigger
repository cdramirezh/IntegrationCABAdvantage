trigger OpportunityRenameTrigger on Opportunity (before update, before insert) {
    // Delegate to handler class for better code organization and testability
    OpportunityRenameHandler.handleOpportunityRename(Trigger.new, Trigger.oldMap);
}