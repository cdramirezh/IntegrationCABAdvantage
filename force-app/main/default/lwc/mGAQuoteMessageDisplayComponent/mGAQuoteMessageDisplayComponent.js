import { LightningElement, api, track, wire } from 'lwc';
import getMessages from '@salesforce/apex/MGAQuoteChatsController.getMessages';
import { refreshApex } from '@salesforce/apex';

export default class MessageDisplayComponent extends LightningElement {
    @api recordId; // Holds the MGA_Quote__c record ID
    @track messages; // Holds message records for display
    wiredMessagesResult; // Stores the result of the wire for refresh

    @wire(getMessages, { quoteId: '$recordId' })
    wiredMessages(result) {
        this.wiredMessagesResult = result;
        if (result.data) {
            this.messages = result.data.map((msg, index) => {
                return {
                    ...msg,
                    cssClass: index % 2 === 0 ? 'slds-float_left' : 'slds-float_right',
                    senderName: msg.Sender__r.Name,
                    body: msg.Body__c, // Ensure Body__c is mapped
                    createdDate: new Date(msg.CreatedDate).toLocaleString() // Format CreatedDate for display
                };
            });
        } else if (result.error) {
            console.error('Error fetching messages:', result.error);
        }
    }

    // Refresh messages when a new one is added
    handleMessageCreated() {
        refreshApex(this.wiredMessagesResult);
    }

    connectedCallback() {
        this.template.addEventListener('messagecreated', this.handleMessageCreated.bind(this));
    }
}