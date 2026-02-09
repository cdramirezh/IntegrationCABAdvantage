// carrierSelection.js
import { LightningElement, api, wire, track } from 'lwc';
import getCarriers from '@salesforce/apex/CarrierSelectionController.getCarriers';
import getExistingMGAQuoteInsuranceCompanies from '@salesforce/apex/CarrierSelectionController.getExistingMGAQuoteInsuranceCompanies';
import createMGAQuoteInsuranceCompanies from '@salesforce/apex/CarrierSelectionController.createMGAQuoteInsuranceCompanies';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class CarrierSelection extends LightningElement {
    @api recordId; // MGA_Quote__c Id
    @track carriers = [];
    selectedCarriers = new Set();
    existingInsuranceCompanyIds = new Set();

    @wire(getCarriers, { MGAQuoteId: '$recordId' })
    wiredCarriers({ error, data }) {
        if (data) {
            this.carriers = data.map(carrier => ({
                id: carrier.Insurance_Company__c,
                name: carrier.Insurance_Company__r.Name,
                selected: false
            }));
        } else if (error) {
            console.error(error);
        }
    }

    @wire(getExistingMGAQuoteInsuranceCompanies, { MGAQuoteId: '$recordId' })
    wiredExistingRecords({ error, data }) {
        if (data) {
            this.existingInsuranceCompanyIds = new Set(data);
        } else if (error) {
            console.error(error);
        }
    }

    handleCheckboxChange(event) {
        const carrierId = event.target.dataset.id;
        if (event.target.checked) {
            this.selectedCarriers.add(carrierId);
        } else {
            this.selectedCarriers.delete(carrierId);
        }
    }

    handleSave() {
        const newSelections = Array.from(this.selectedCarriers).filter(
            carrierId => !this.existingInsuranceCompanyIds.has(carrierId)
        );

        if (newSelections.length === 0) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'No New Selections',
                    message: 'All selected carriers are already associated.',
                    variant: 'warning'
                })
            );
            return;
        }

        createMGAQuoteInsuranceCompanies({
            MGAQuoteId: this.recordId,
            insuranceCompanyIds: newSelections
        })
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Records created successfully.',
                        variant: 'success'
                    })
                );
            })
            .catch(error => {
                console.error(error);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'An error occurred while creating records.',
                        variant: 'error'
                    })
                );
            });
    }
}