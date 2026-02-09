public with sharing class EndorsementRequestChatsController {

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
    public static void createMessage(Id endorseId, Id senderId, String body) {
        Chat__c chat = [SELECT Id FROM Chat__c WHERE Endorsement_Request__c = :endorseId LIMIT 1];
        Message__c newMessage = new Message__c(
            Body__c = body,
            Sender__c = senderId,
            Chat__c = chat.Id
        );
        insert newMessage;
    }

    @AuraEnabled(cacheable=true)
    public static List<Message__c> getMessages(Id endorseId) {
        Chat__c chat = [
            SELECT Id
            FROM Chat__c
            WHERE Endorsement_Request__c = :endorseId
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];
        
        if (chat == null) {
            return new List<Message__c>();
        }

        return [
            SELECT Id, Body__c, CreatedDate, Sender__c, Sender__r.Name
            FROM Message__c
            WHERE Chat__c = :chat.Id
            ORDER BY CreatedDate DESC
        ];
    }    

    @AuraEnabled(cacheable=true)
    public static Chat__c getLatestChat(Id endorseId) {
        return [
            SELECT Id, Endorsement_Request__c
            FROM Chat__c
            WHERE Endorsement_Request__c = :endorseId
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];
    }
}