import { LightningElement, api, wire, track } from 'lwc';
import getVehicles from '@salesforce/apex/QuotesCoveragesAssetBulkAdd.getVehicles';
import getTrailers from '@salesforce/apex/QuotesCoveragesAssetBulkAdd.getTrailers';
import getDrivers from '@salesforce/apex/QuotesCoveragesAssetBulkAdd.getDrivers';
import getCoverages from '@salesforce/apex/QuotesCoveragesAssetBulkAdd.getCoverages';
import createCoverageAssignmentRecords from '@salesforce/apex/QuotesCoveragesAssetBulkAdd.createCoverageAssignmentRecords';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

export default class QuoteVehicleCoverage extends NavigationMixin(LightningElement) {
    @api recordId; // quote__c Id
    @track vehicleOptions = [];
    @track trailerOptions = [];
    @track driverOptions = [];
    @track coverageOptions = [];
    @track selectedVehicles = [];
    @track selectedTrailers = [];
    @track selectedDrivers = [];
    @track selectedCoverages = [];

    // Fetch the vehicles related to the account of the quote and cache the result
    @wire(getVehicles, { quoteId: '$recordId' })
    wiredVehicles({ error, data }) {
        if (data) {
            this.vehicleOptions = data.map(vehicle => {
                return { label: vehicle.Name, value: vehicle.Id };
            });
        } else if (error) {
            this.showErrorToast(error);
        }
    }

    // Fetch the trailers related to the account of the quote
    @wire(getTrailers, { quoteId: '$recordId' })
    wiredTrailers({ error, data }) {
        if (data) {
            this.trailerOptions = data.map(trailer => {
                return { label: trailer.Name, value: trailer.Id };
            });
        } else if (error) {
            this.showErrorToast(error);
        }
    }

    // Fetch the drivers related to the account of the quote
    @wire(getDrivers, { quoteId: '$recordId' })
    wiredDrivers({ error, data }) {
        if (data) {
            this.driverOptions = data.map(driver => {
                return { label: driver.Name, value: driver.Id };
            });
        } else if (error) {
            this.showErrorToast(error);
        }
    }

    // Fetch the coverages related to the quote
    @wire(getCoverages, { quoteId: '$recordId' })
    wiredCoverages({ error, data }) {
        if (data) {
            this.coverageOptions = data.map(coverage => {
                return { label: coverage.Coverage_Product__r.Name, value: coverage.Id };
            });
        } else if (error) {
            this.showErrorToast(error);
        }
    }

    // Handle vehicle selection
    handleVehicleChange(event) {
        this.selectedVehicles = event.detail.value;
    }

    // Handle trailer selection
    handleTrailerChange(event) {
        this.selectedTrailers = event.detail.value;
    }

    // Handle driver selection
    handleDriverChange(event) {
        this.selectedDrivers = event.detail.value;
    }

    // Handle coverage selection
    handleCoverageChange(event) {
        this.selectedCoverages = event.detail.value;
    }

    // Save the selected vehicle, trailer, driver, and coverage records into the junction object
    handleSave() {
        if (this.selectedVehicles.length === 0 && this.selectedTrailers.length === 0 && this.selectedDrivers.length === 0 || this.selectedCoverages.length === 0) {
            this.showToast('Error', 'Please select at least one vehicle, trailer, driver, and one coverage.', 'error');
            return;
        }

        createCoverageAssignmentRecords({
            quoteId: this.recordId,
            vehicleIds: this.selectedVehicles,
            trailerIds: this.selectedTrailers,
            driverIds: this.selectedDrivers,
            coverageIds: this.selectedCoverages
        })
            .then(() => {
                this.showToast('Success', 'Records created successfully', 'success');

                window.location.reload();
            })
            .catch(error => {
                this.showErrorToast(error);
            });
    }

    // Utility to show toast messages
    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }

    // Utility to handle error toasts
    showErrorToast(error) {
        this.showToast('Error', 'An error occurred: ' + error.body.message, 'error');
    }
}