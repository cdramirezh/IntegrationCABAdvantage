public with sharing class PolicyDraftChatController_v2 {

    @AuraEnabled(cacheable=true)
    public static List<Contact> searchContacts(String searchTerm) {
        return [
            SELECT Id, Name 
            FROM Contact 
            WHERE Name LIKE :('%' + searchTerm + '%') 
            LIMIT 10
        ];
    }

    @AuraEnabled
    public static void createMessage(Id PolDraftId, Id senderId, String body) {
        Chat__c chat = [SELECT Id FROM Chat__c WHERE Policy_Draft__c = :PolDraftId LIMIT 1];
        Message__c newMessage = new Message__c(
            Body__c = body,
            Sender__c = senderId,
            Chat__c = chat.Id
        );
        insert newMessage;
    }

    @AuraEnabled(cacheable=true)
    public static List<Message__c> getMessages(Id PolDraftId) {
        // Retrieve the latest Chat__c associated with the Policy_Draft__c
        Chat__c chat = [
            SELECT Id
            FROM Chat__c
            WHERE Policy_Draft__c = :PolDraftId
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];
        
        if (chat == null) {
            return new List<Message__c>();  // Return empty list if no Chat__c exists
        }

        // Retrieve associated Message__c records
        return [
            SELECT Id, Body__c, CreatedDate, Sender__c, Sender__r.Name, Related_MGA_Quote__c, Related_Insurance_Co__c, Related_MGA_Quote__r.MGA_Company__r.Name, Related_Insurance_Co__r.Insurance_Company__r.Name
            FROM Message__c
            WHERE Chat__c = :chat.Id
            ORDER BY CreatedDate DESC
        ];
    }    

    @AuraEnabled(cacheable=true)
    public static Chat__c getLatestChat(Id PolDraftId) {
        return [
            SELECT Id, Policy_Draft__c
            FROM Chat__c
            WHERE Policy_Draft__c = :PolDraftId
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];
    }

}