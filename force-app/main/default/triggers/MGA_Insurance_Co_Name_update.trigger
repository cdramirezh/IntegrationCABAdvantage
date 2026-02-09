trigger MGA_Insurance_Co_Name_update on MGA_Quote_Insurance_Company__c (before insert, before update) {
    if (Trigger.isBefore) {
        if (Trigger.isInsert || Trigger.isUpdate) {
            MGAInsuranceCompanyHelper.populateMGAInsCoName(Trigger.new);
        }
    }
}