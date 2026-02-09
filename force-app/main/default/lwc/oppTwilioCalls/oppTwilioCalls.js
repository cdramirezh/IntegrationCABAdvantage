import { LightningElement, wire, api, track } from 'lwc';
import getCallLogs from '@salesforce/apex/OppTwilioCallsController.getCallLogs';
import { getRecord } from 'lightning/uiRecordApi';
import PHONE_FIELD from '@salesforce/schema/Opportunity.Account_Phone__c';

export default class CallLogTable extends LightningElement {
    @api recordId;
    @track callLogs = [];
    @track noLogs = false;
    oppPhone;

    @wire(getRecord, { recordId: '$recordId', fields: [PHONE_FIELD] })
    wiredOpportunity({ error, data }) {
        if (data) {
            this.oppPhone = data.fields.Account_Phone__c.value;
            this.fetchCallLogs();
        } else if (error) {
            console.error('Error fetching Opportunity phone:', error);
        }
    }

    fetchCallLogs() {
        getCallLogs({ oppPhone: this.oppPhone })
            .then(result => {
                if (result.length > 0) {
                    this.callLogs = result;
                    this.noLogs = false;
                } else {
                    this.noLogs = true;
                }
            })
            .catch(error => {
                console.error('Error fetching call logs:', error);
                this.noLogs = true;
            });
    }
}