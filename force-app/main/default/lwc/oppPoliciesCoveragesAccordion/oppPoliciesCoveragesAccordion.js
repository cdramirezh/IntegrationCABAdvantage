import { LightningElement, api, track, wire } from 'lwc';
import getPoliciesWithCoverages from '@salesforce/apex/OppPoliciesAndCoverages.getPoliciesWithCoverages';

export default class OpportunityPoliciesAccordion extends LightningElement {
    @api recordId; // Opportunity Id
    @track policies = [];
    @track error;

    columns = [
        { label: 'Coverage', fieldName: 'coverageProductName', type: 'text' },
        { label: 'Limit', fieldName: 'Limit__c', type: 'currency' },
        { label: 'Deductible', fieldName: 'Deductible__c', type: 'currency' },
        //{ label: 'Ins Co', fieldName: 'inscoName', type: 'text' }
    ];

    @wire(getPoliciesWithCoverages, { opportunityId: '$recordId' })
    wiredPolicies({ error, data }) {
        if (data) {
            this.policies = data.map(policyWrapper => {
                return {
                    ...policyWrapper,
                    policy: {
                        ...policyWrapper.policy,
                        formattedEffectiveDate: this.formatDate(policyWrapper.policy.Effective_Date__c),
                        formattedExpirationDate: this.formatDate(policyWrapper.policy.Expiration_Date__c),
                        mgacoName: policyWrapper.policy.MGA_Company__r?.Name,
                        insurancecoName: policyWrapper.policy.Insurance_Company__r?.Name,
                        url: '/' + policyWrapper.policy.Id,
                    },
                    coverages: policyWrapper.coverages.map(coverage => {
                        return {
                            ...coverage,
                            coverageProductName: coverage.Coverage_Product__r?.Name,
                            inscoName: coverage.Insurance_Company__r?.Name
                        };
                    })
                };
            });
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.policies = [];
        }
    }

    formatDate(dateString) {
        if (!dateString) return '';
        const [year, month, day] = dateString.split('-');
        return `${month}/${day}/${year}`;  // Returns date in mm/dd/yyyy format
    }

    toggleSection(event) {
        const sectionId = event.currentTarget.dataset.id;
        const content = this.template.querySelector(`div[data-content-id="${sectionId}"]`);
        const icon = this.template.querySelector(`span[data-icon-id="${sectionId}"]`);

        if (content.classList.contains('hidden')) {
            content.classList.remove('hidden');
            content.style.maxHeight = content.scrollHeight + 'px'; // Animate height
            icon.classList.add('rotate');
        } else {
            content.style.maxHeight = '0px';
            content.classList.add('hidden');
            icon.classList.remove('rotate');
        }
    }

    stopClickPropagation(event) {
        event.stopPropagation();
    }
    
}