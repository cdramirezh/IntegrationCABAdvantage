public with sharing class EndorsementRequestCommodityController {
    @AuraEnabled(cacheable=true)
    public static List<Map<String, String>> getCommoditiesByEndorsementRequest(Id endorsementRequestId) {
        Endorsement_Request__c er = [
            SELECT Opportunity__r.AccountId
            FROM Endorsement_Request__c
            WHERE Id = :endorsementRequestId
            LIMIT 1
        ];

        if (er.Opportunity__r == null || er.Opportunity__r.AccountId == null) {
            return new List<Map<String, String>>();
        }

        List<Commodity__c> commodities = [
            SELECT Id, Name
            FROM Commodity__c
            WHERE Account__c = :er.Opportunity__r.AccountId
        ];

        List<Map<String, String>> output = new List<Map<String, String>>();
        for (Commodity__c com : commodities) {
            output.add(new Map<String, String>{
                'Id' => com.Id,
                'Name' => com.Name
            });
        }

        return output;
    }

    @AuraEnabled
    public static String createCommodityEndorsements(Id endorsementRequestId, List<Id> commodityIds, String action) {
        if (commodityIds == null || commodityIds.isEmpty()) {
            return 'No commodities selected.';
        }

        List<Endorsement_Commodity__c> toInsert = new List<Endorsement_Commodity__c>();

        Set<Id> existingCommodityIds = new Set<Id>();
        for (Endorsement_Commodity__c ec : [
            SELECT Commodity__c
            FROM Endorsement_Commodity__c
            WHERE Endorsement_Request__c = :endorsementRequestId
        ]) {
            existingCommodityIds.add(ec.Commodity__c);
        }

        for (Id cid : commodityIds) {
            if (!existingCommodityIds.contains(cid)) {
                toInsert.add(new Endorsement_Commodity__c(
                    Endorsement_Request__c = endorsementRequestId,
                    Commodity__c = cid,
                    Action__c = action
                ));
            }
        }

        insert toInsert;
        return toInsert.isEmpty() ? 'All selected commodities already exist.' : 'Endorsement commodities created successfully.';
    }
}