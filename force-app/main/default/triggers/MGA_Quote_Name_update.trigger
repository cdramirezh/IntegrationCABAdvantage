trigger MGA_Quote_Name_update on MGA_Quote__c (before insert, before update) {
    if (Trigger.isBefore) {
        if (Trigger.isInsert || Trigger.isUpdate) {
            MGAQuoteNameHelper.populateMGAQuoteName(Trigger.new);
        }
    }
}