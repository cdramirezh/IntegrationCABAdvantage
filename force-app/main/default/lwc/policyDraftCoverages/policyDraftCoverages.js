import { LightningElement, api, wire, track } from 'lwc';
import getAvailableCoverageProducts from '@salesforce/apex/PolicyDraftCoverageController.getAvailableCoverageProducts';
import createCoverages from '@salesforce/apex/PolicyDraftCoverageController.createCoverages';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

export default class PolicyDraftCoverages extends NavigationMixin(LightningElement) {
    @api recordId;  // Policy Draft ID
    @track availableProducts = [];
    @track selectedProducts = [];
    @track error;

    @wire(getAvailableCoverageProducts)
    wiredProducts({ error, data }) {
        if (data) {
            this.availableProducts = data.map(product => ({
                label: product.Name,
                value: product.Id
            }));
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.showToast('Error', 'Error loading coverage products', 'error');
        }
    }

    handleProductSelection(event) {
        this.selectedProducts = event.detail.value;
    }

    handleSave() {
        if (this.selectedProducts.length === 0) {
            this.showToast('Error', 'Please select at least one coverage product', 'error');
            return;
        }

        createCoverages({ selectedCoverageProductIds: this.selectedProducts, policyDraftId: this.recordId })
            .then(() => {
                this.showToast('Success', 'Coverages created successfully', 'success');
                this.selectedProducts = [];  // Reset selection

                window.location.reload();
            })
            .catch(error => {
                this.showToast('Error', 'Error creating coverages', 'error');
            });
    }

    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }
}