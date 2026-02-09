import { LightningElement, api, track } from 'lwc';
import getLatestChat from '@salesforce/apex/PolicyDraftChatController_v2.getLatestChat';

export default class MessageCreationComponent extends LightningElement {
    @api recordId;  // Holds the MGA_Quote__c record ID
    @track chatId;  // Holds the Chat__c ID related to MGA_Quote__c

    connectedCallback() {
        // Fetch the latest Chat__c record related to the MGA_Quote__c
        getLatestChat({ PolDraftId: this.recordId })
            .then((chat) => {
                this.chatId = chat.Id;
            })
            .catch((error) => {
                console.error('Error fetching latest Chat ID:', error);
            });
    }

    handleSuccess() {
        // Reload the page upon successful form submission
        location.reload();
    }
}