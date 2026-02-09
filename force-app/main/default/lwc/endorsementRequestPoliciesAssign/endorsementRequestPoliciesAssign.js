import { LightningElement, api, wire, track } from 'lwc';
import getPoliciesByOpportunity from '@salesforce/apex/EndorsementRequestPolicyController.getPoliciesByOpportunity';
import createEndorsementPolicies from '@salesforce/apex/EndorsementRequestPolicyController.createEndorsementPolicies';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class EndorsementRequestPolicies extends LightningElement {
    @api recordId; // Id of the Endorsement_Request__c record
    @track policies = []; // Checkbox group options
    @track selectedPolicies = []; // Selected policies

    // Fetch related policies via Apex
    @wire(getPoliciesByOpportunity, { endorsementRequestId: '$recordId' })
    wiredPolicies({ error, data }) {
        if (data) {
            this.policies = data.map(policy => ({
                label: policy.Name,
                value: policy.Id
            }));
        } else if (error) {
            this.showToast('Error', 'Failed to fetch related policies', 'error');
        }
    }

    // Handle checkbox selection change
    handlePolicySelection(event) {
        this.selectedPolicies = event.detail.value;
    }

    // Handle button click to create Endorsement_Policy__c records
    handleCreateEndorsementPolicies() {
        createEndorsementPolicies({
            endorsementRequestId: this.recordId,
            policyIds: this.selectedPolicies
        })
            .then(result => {
                if (result.success) {
                    this.showToast('Success', result.message, 'success');
                    this.selectedPolicies = [];
                } else {
                    this.showToast('Error', result.message, 'error');
                }
            })
            .catch(error => {
                this.showToast('Error', 'Failed to create Endorsement Policies', 'error');
                console.error(error);
            });
    }

    // Utility to show toast messages
    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title,
                message,
                variant
            })
        );
    }
}