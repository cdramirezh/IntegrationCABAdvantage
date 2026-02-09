import { LightningElement, api, wire, track } from 'lwc';
import getPoliciesWithQuotesAndCompanies from '@salesforce/apex/LeadPolicyDraftQuotationController.getPoliciesWithQuotesAndCompanies';

export default class LeadPolicyDrafts extends LightningElement {
    @api recordId; // Lead Id passed from the Lead record page
    @track policies = [];
    @track error;

    // Wire the Apex method to get Policy_Draft__c records with related MGA_Quote__c and Insurance Companies
    @wire(getPoliciesWithQuotesAndCompanies, { leadId: '$recordId' })
    wiredPolicies({ error, data }) {
        if (data) {
            this.policies = data; // This will now contain the PolicyWrapper with quotes and insurance companies
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.policies = [];
        }
    }

    // Navigate to MGA_Quote__c record page in a new tab
    navigateToRecord(event) {
        const recordId = event.currentTarget.dataset.recordId;

        this[NavigationMixin.GenerateUrl]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                objectApiName: 'MGA_Quote__c',
                actionName: 'view'
            }
        }).then(url => {
            window.open(url, '_blank');
        });
    }

}