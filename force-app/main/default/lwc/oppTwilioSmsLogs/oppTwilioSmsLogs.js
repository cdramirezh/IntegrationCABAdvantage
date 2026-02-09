import { LightningElement, wire, api, track } from 'lwc';
import getSmsLogs from '@salesforce/apex/OppTwilioSmsLogsController.getSmsLogs';
import { getRecord } from 'lightning/uiRecordApi';
import PHONE_FIELD from '@salesforce/schema/Opportunity.Account_Phone__c';

export default class SmsLogTable extends LightningElement {
    @api recordId;
    @track smsLogs = [];
    @track noLogs = false;
    oppPhone;

    @wire(getRecord, { recordId: '$recordId', fields: [PHONE_FIELD] })
    wiredOpportunity({ error, data }) {
        if (data) {
            this.oppPhone = data.fields.Account_Phone__c.value;
            this.fetchSmsLogs();
        } else if (error) {
            console.error('Error fetching Opportunity phone:', error);
        }
    }

    fetchSmsLogs() {
        getSmsLogs({ oppPhone: this.oppPhone })
            .then(result => {
                if (result.length > 0) {
                    this.smsLogs = result;
                    this.noLogs = false;
                } else {
                    this.noLogs = true;
                }
            })
            .catch(error => {
                console.error('Error fetching SMS logs:', error);
                this.noLogs = true;
            });
    }
}