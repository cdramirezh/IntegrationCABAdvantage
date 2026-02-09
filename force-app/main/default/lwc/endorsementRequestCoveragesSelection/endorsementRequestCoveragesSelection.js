import { LightningElement, api, wire, track } from 'lwc';
import getCoveragesByEndorsementRequest from '@salesforce/apex/EndorsementRequestCoverageController.getCoveragesByEndorsementRequest';
import createEndorsementCoverages from '@salesforce/apex/EndorsementRequestCoverageController.createEndorsementCoverages';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class EndorsementRequestCoverages extends LightningElement {
    @api recordId; // Id of the Endorsement_Request__c record
    @track coverages = []; // Checkbox group options
    @track selectedCoverages = []; // Selected Coverages

    // Fetch related Coverages via Apex
    @wire(getCoveragesByEndorsementRequest, { endorsementRequestId: '$recordId' })
    wiredCoverages({ error, data }) {
        if (data) {
            this.coverages = data.map(coverage => ({
                label: coverage.Coverage_Product__r.Name,
                value: coverage.Id
            }));
        } else if (error) {
            this.showToast('Error', 'Failed to fetch related coverages', 'error');
        }
    }

    // Handle checkbox selection change
    handleCoverageSelection(event) {
        this.selectedCoverages = event.detail.value;
    }

    // Handle button click to create Endorsements_Coverages__c records
    handleCreateEndorsementCoverages() {
        createEndorsementCoverages({
            endorsementRequestId: this.recordId,
            coverageIds: this.selectedCoverages
        })
            .then(result => {
                if (result.success) {
                    this.showToast('Success', result.message, 'success');
                    this.selectedCoverages = [];
                } else {
                    this.showToast('Error', result.message, 'error');
                }
            })
            .catch(error => {
                this.showToast('Error', 'Failed to create Endorsements Coverages', 'error');
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