import { LightningElement, api, track } from 'lwc';
import getAvailableCoverages from '@salesforce/apex/PolicyCoverageController.getAvailableCoverages';
import saveSelectedCoverages from '@salesforce/apex/PolicyCoverageController.saveSelectedCoverages';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class PolicyCoverage extends LightningElement {
    @api recordId; // Policy__c record ID passed from the flow
    @track options = []; // Coverage__c options for the dual listbox
    @track selected = []; // Selected Coverage__c IDs
    @track isLoading = true;

    connectedCallback() {
        this.fetchCoverages();
    }

    fetchCoverages() {
        this.isLoading = true;
        getAvailableCoverages({ policyId: this.recordId })
            .then((result) => {
                this.options = result;
                this.isLoading = false;
            })
            .catch((error) => {
                this.isLoading = false;
                this.showToast('Error', error.body.message, 'error');
            });
    }

    handleSave() {
        this.isLoading = true;
        saveSelectedCoverages({ policyId: this.recordId, selectedCoverageIds: this.selected })
            .then(() => {
                this.showToast('Success', 'Selected coverages saved successfully!', 'success');
                this.isLoading = false;
                this.fetchCoverages(); // Reload data after saving
            })
            .catch((error) => {
                this.isLoading = false;
                this.showToast('Error', error.body.message, 'error');
            });
    }

    handleChange(event) {
        this.selected = event.detail.value; // Update selected coverage IDs
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}