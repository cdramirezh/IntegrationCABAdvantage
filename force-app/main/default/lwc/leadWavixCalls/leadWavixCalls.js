import { LightningElement, api, wire, track } from 'lwc';
import getWavixCallLogs from '@salesforce/apex/LeadWavixCallsController.getWavixCallLogs';
import { getRecord } from 'lightning/uiRecordApi';
//import PHONE_FIELD from '@salesforce/schema/Lead.Phone';
import PHONE_FIELD from '@salesforce/schema/Lead.Normalized_Phone__c';

export default class WavixCallLogsTable extends LightningElement {
    @api recordId;
    @track logs = [];
    @track columns = [
        { label: 'Date', fieldName: 'callDate' },
        //{ label: 'From', fieldName: 'fromNumber' },
        { label: 'From', fieldName: 'producerName' },
       // { label: 'To', fieldName: 'toNumber' },
        { label: 'Duration', fieldName: 'duration' },
        // { label: 'Charge', fieldName: 'charge' },
       // { label: 'Destination', fieldName: 'destination' },
    ];
    @track error;
    isLoading = true;

    @wire(getRecord, { recordId: '$recordId', fields: [PHONE_FIELD] })
    lead({ error, data }) {
        if (data) {
            const leadPhone = data.fields.Normalized_Phone__c.value;
            //const leadPhone = data.fields.Phone.value;
            if (leadPhone) {
                this.fetchCallLogs(leadPhone);
            } else {
                this.isLoading = false;  // Stop loading if no phone is found
            }
        } else if (error) {
            this.error = error;
            this.isLoading = false;
        }
    }

    fetchCallLogs(leadPhone) {
        //const fromDate = '2024-11-01';
        //const toDate = '2024-11-30';

        //getWavixCallLogs({ leadPhone, fromDate, toDate })
        getWavixCallLogs({ leadPhone })
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