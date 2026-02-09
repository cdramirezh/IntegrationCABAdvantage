import { LightningElement, api, wire } from 'lwc';
import getEndorsementSummary from '@salesforce/apex/EndorsementRequestSummaryController.getEndorsementSummary';

export default class EndorsementSummary extends LightningElement {
    @api recordId;
    summaryData;
    error;

    @wire(getEndorsementSummary, { endorsementRequestId: '$recordId' })
    wiredSummary({ error, data }) {
        if (data) {
            this.summaryData = data;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.summaryData = undefined;
        }
    }
}