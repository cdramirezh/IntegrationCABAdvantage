public with sharing class BinderRequestChatsController {

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
    public static void createMessage(Id bindId, Id senderId, String body) {
        Chat__c chat = [SELECT Id FROM Chat__c WHERE Binder_request__c = :bindId LIMIT 1];
        Message__c newMessage = new Message__c(
            Body__c = body,
            Sender__c = senderId,
            Chat__c = chat.Id
        );
        insert newMessage;
    }

    @AuraEnabled(cacheable=true)
    public static List<Message__c> getMessages(Id bindId) {
        // Retrieve the latest Chat__c associated with the Binder_request__c
        Chat__c chat = [
            SELECT Id
            FROM Chat__c
            WHERE Binder_request__c = :bindId
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];
        
        if (chat == null) {
            return new List<Message__c>();  // Return empty list if no Chat__c exists
        }

        // Retrieve associated Message__c records
        return [
            SELECT Id, Body__c, CreatedDate, Sender__c, Sender__r.Name
            FROM Message__c
            WHERE Chat__c = :chat.Id
            ORDER BY CreatedDate DESC
        ];
    }    

    @AuraEnabled(cacheable=true)
    public static Chat__c getLatestChat(Id bindId) {
        return [
            SELECT Id, Binder_request__c
            FROM Chat__c
            WHERE Binder_request__c = :bindId
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];
    }

}