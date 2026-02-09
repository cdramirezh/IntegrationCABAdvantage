import { LightningElement, api, track } from 'lwc';
import getLatestChat from '@salesforce/apex/EndorsementRequestChatsController.getLatestChat';

export default class EndorsementRequestMessageCreationLWC extends LightningElement {
    @api recordId;  // Holds the Endorsement_Request__c record ID
    @track chatId;  // Holds the Chat__c ID related to Endorsement_Request__c

    connectedCallback() {
        // Fetch the latest Chat__c record related to the Endorsement_Request__c
        getLatestChat({ endorseId: this.recordId })
            .then((chat) => {
                this.chatId = chat ? chat.Id : null;
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