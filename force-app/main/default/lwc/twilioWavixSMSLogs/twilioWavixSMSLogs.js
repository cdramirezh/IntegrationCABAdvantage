import { LightningElement, wire, api, track } from 'lwc';
import getSmsLogs from '@salesforce/apex/TwilioSmsLogController.getSmsLogs';
import { getRecord } from 'lightning/uiRecordApi';
import PHONE_FIELD from '@salesforce/schema/Lead.Phone';

export default class SmsLogTable extends LightningElement {
    @api recordId;
    @track smsLogs = [];
    @track noLogs = false;
    leadPhone;

    @wire(getRecord, { recordId: '$recordId', fields: [PHONE_FIELD] })
    wiredLead({ error, data }) {
        if (data) {
            this.leadPhone = data.fields.Phone.value;
            this.fetchSmsLogs();
        } else if (error) {
            console.error('Error fetching Lead phone:', error);
        }
    }

    fetchSmsLogs() {
        getSmsLogs({ leadPhone: this.leadPhone })
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