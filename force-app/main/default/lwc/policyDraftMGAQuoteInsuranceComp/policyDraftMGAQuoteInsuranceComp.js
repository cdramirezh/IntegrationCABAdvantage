import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getMGAQuotesWithInsurance from '@salesforce/apex/PolicyDraftMGAQuoteInsuranceComp.getMGAQuotesWithInsurance';

export default class MGAQuotePath extends NavigationMixin(LightningElement) {
    @api recordId;
    @track quotesWithInsurance = [];
    @track error;

    // Wire Apex method to get MGA_Quotes and related Insurance_Company__c records
    @wire(getMGAQuotesWithInsurance, { policyDraftId: '$recordId' })
    wiredMGAQuotes({ error, data }) {
        if (data) {
            this.quotesWithInsurance = data;
            this.error = undefined;
        } else if (error) {
            this.quotesWithInsurance = undefined;
            this.error = error;
        }
    }

    // Define the available status steps in the path component
    get statusOptions() {
        return [
            { label: 'Open', value: 'Open' },
            { label: 'Submitted', value: 'Submitted' },
            { label: 'Waiting for Quote', value: 'Waiting for Quote' },
            { label: 'Accepted', value: 'Accepted' },
            { label: 'Rejected', value: 'Rejected' }
        ];
    }

    // Navigate to MGA_Quote_Insurance_Company__c record page in a new tab
    navigateToRecord(event) {
        const recordId = event.currentTarget.dataset.recordId;

        this[NavigationMixin.GenerateUrl]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                objectApiName: 'MGA_Quote_Insurance_Company__c',
                actionName: 'view'
            }
        }).then(url => {
            window.open(url, '_blank');
        });
    }
}