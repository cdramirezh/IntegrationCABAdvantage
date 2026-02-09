import { LightningElement, api, wire, track } from 'lwc';
import getAvailableInsuranceCompanies from '@salesforce/apex/BinderRequestController.getAvailableInsuranceCompanies';
import saveSelectedCompanies from '@salesforce/apex/BinderRequestController.saveSelectedCompanies';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class BinderRequestDualListbox extends LightningElement {
    @api recordId; // This is the Binder_Request__c Id
    @track options = [];
    @track selectedValues = [];
    @track errors;

    @wire(getAvailableInsuranceCompanies, { binderRequestId: '$recordId' })
    wiredInsuranceCompanies({ error, data }) {
        if (data) {
            this.options = data.map((item) => ({
                label: item.label, // Bind_Name__c
                value: item.value, // Id
            }));
            this.errors = undefined;
        } else if (error) {
            this.errors = error.body.message;
            this.options = [];
        }
    }

    handleChange(event) {
        this.selectedValues = event.detail.value;
    }

    handleChange(event) {
        this.selected = event.detail.value;
    }

    handleSave() {
        if (this.selected.length === 0) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Please select at least one insurance company.',
                    variant: 'error'
                })
            );
            return;
        }

        this.isLoading = true;
        saveSelectedCompanies({
            binderRequestId: this.recordId,
            selectedInsuranceCompanyIds: this.selected
        })
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Insurance companies have been successfully related.',
                        variant: 'success'
                    })
                );
                this.isLoading = false;
                window.location.reload();
            })
            .catch((error) => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
                this.isLoading = false;
            });
    }
}