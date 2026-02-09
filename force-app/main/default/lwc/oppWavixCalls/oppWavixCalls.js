import { LightningElement, api, wire, track } from 'lwc';
import getWavixCallLogs from '@salesforce/apex/OppWavixCallsController.getWavixCallLogs';
import { getRecord } from 'lightning/uiRecordApi';
import PHONE_FIELD from '@salesforce/schema/Opportunity.Account_Phone__c';

export default class WavixCallLogsTable extends LightningElement {
    @api recordId;
    @track logs = [];
    @track columns = [
        { label: 'Date', fieldName: 'callDate' },
        { label: 'From', fieldName: 'producerName' },
        { label: 'Duration', fieldName: 'duration' },
    ];
    @track error;
    isLoading = true;

    @wire(getRecord, { recordId: '$recordId', fields: [PHONE_FIELD] })
    opportunity({ error, data }) {
        if (data) {
            const oppPhone = data.fields.Account_Phone__c.value;
            if (oppPhone) {
                this.fetchCallLogs(oppPhone);
            } else {
                this.isLoading = false; // Stop loading if no phone is found
            }
        } else if (error) {
            this.error = error;
            this.isLoading = false;
        }
    }

    fetchCallLogs(oppPhone) {
        getWavixCallLogs({ oppPhone })
            .then((result) => {
                this.logs = result;
                this.error = undefined;
            })
            .catch((error) => {
                this.error = error;
                this.logs = [];
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    get hasLogs() {
        return this.logs && this.logs.length > 0;
    }
}