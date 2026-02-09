import { LightningElement, api, track, wire } from 'lwc';
import getMessages from '@salesforce/apex/EndorsementRequestChatsController.getMessages';
import { refreshApex } from '@salesforce/apex';

export default class EndorsementRequestMessageDisplayComponent extends LightningElement {
    @api recordId; // Holds the Endorsement_Request__c record ID
    @track messages; // Holds message records for display
    wiredMessagesResult; // Stores the result of the wire for refresh

    @wire(getMessages, { endorseId: '$recordId' })
    wiredMessages(result) {
        this.wiredMessagesResult = result;
        if (result.data) {
            this.messages = result.data.map((msg, index) => {
                return {
                    ...msg,
                    cssClass: index % 2 === 0 ? 'slds-float_left' : 'slds-float_right',
                    senderName: msg.Sender__r.Name,
                    body: msg.Body__c,
                    createdDate: new Date(msg.CreatedDate).toLocaleString()
                };
            });
        } else if (result.error) {
            console.error('Error fetching messages:', result.error);
        }
    }

    handleMessageCreated() {
        refreshApex(this.wiredMessagesResult);
    }

    connectedCallback() {
        this.template.addEventListener('messagecreated', this.handleMessageCreated.bind(this));
    }
}