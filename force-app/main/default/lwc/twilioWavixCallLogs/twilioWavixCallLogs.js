import { LightningElement, wire, api, track } from 'lwc';
import getCallLogs from '@salesforce/apex/TwilioWavixCallLogController.getCallLogs';
import { getRecord } from 'lightning/uiRecordApi';
import PHONE_FIELD from '@salesforce/schema/Lead.Phone';

export default class CallLogTable extends LightningElement {
    @api recordId;
    @track callLogs = [];
    @track noLogs = false;
    leadPhone;

    @wire(getRecord, { recordId: '$recordId', fields: [PHONE_FIELD] })
    wiredLead({ error, data }) {
        if (data) {
            this.leadPhone = data.fields.Phone.value;
            this.fetchCallLogs();
        } else if (error) {
            console.error('Error fetching Lead phone:', error);
        }
    }

    fetchCallLogs() {
        getCallLogs({ leadPhone: this.leadPhone })
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